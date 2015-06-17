//
//  NFNCameraRectDetectionViewController.m
//  ios-receipt-scan-example
//
//  Version 0.0.1
//
//  The MIT License (MIT)
//
//  Copyright (c) 2015 Paulo Miguel Almeida Rodenas <paulo.ubuntu@gmail.com>
//
//  Get the latest version from here:
//
//  https://github.com/nfscan/ios-receipt-scan-example
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "NFNCameraRectDetectionViewController.h"

@interface NFNCameraRectDetectionViewController ()

@property (nonatomic,strong) AVCaptureSession *captureSession;
@property (nonatomic,strong) AVCaptureDevice *captureDevice;
@property (nonatomic,strong) EAGLContext *context;
@property (nonatomic, strong) AVCaptureStillImageOutput* stillImageOutput;
@property (nonatomic, assign) BOOL forceStop;

@property (nonatomic, strong) UIImage *imageTaken;

@end

@implementation NFNCameraRectDetectionViewController
{
    CIContext *_coreImageContext;
    GLuint _renderBuffer;
    GLKView *_glkView;
    
    BOOL _isStopped;
    
    CGFloat _imageDedectionConfidence;
    NSTimer *_borderDetectTimeKeeper;
    BOOL _borderDetectFrame;
    CIRectangleFeature *_borderDetectLastRectangleFeature;
    
    BOOL _isCapturing;
}

#pragma mark - UIViewController lifecycle

/**
 *  Prepares the receiver for service after it has been loaded from an Interface Builder archive, or nib file.
 *  The nib-loading infrastructure sends an awakeFromNib message to each object recreated from a nib archive, but only after all the objects in the archive have been loaded and initialized. When an object receives an awakeFromNib message, it is guaranteed to have all its outlet and action connections already established.
 * You must call the super implementation of awakeFromNib to give parent classes the opportunity to perform any additional initialization they require. Although the default implementation of this method does nothing, many UIKit classes provide non-empty implementations. You may call the super implementation at any point during your own awakeFromNib method.
 */
- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_backgroundMode) name:UIApplicationWillResignActiveNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_foregroundMode) name:UIApplicationDidBecomeActiveNotification object:nil];
}

/**
 *  Called after the controller's view is loaded into memory.
 *  This method is called after the view controller has loaded its view hierarchy into memory. This method is called regardless of whether the view hierarchy was loaded from a nib file or created programmatically in the loadView method. You usually override this method to perform additional initialization on views that were loaded from nib files.
 */
-(void)viewDidLoad
{
    [self setupCameraView];
}

/**
 *  Notifies the view controller that its view is about to be added to a view hierarchy.
 *  This method is called before the receiver's view is about to be added to a view hierarchy and before any animations are configured for showing the view. You can override this method to perform custom tasks associated with displaying the view. For example, you might use this method to change the orientation or style of the status bar to coordinate with the orientation or style of the view being presented. If you override this method, you must call super at some point in your implementation.
 *
 *  @param animated If YES, the view is being added to the window using an animation.
 */
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self start];
}

/**
 *  Notifies the view controller that its view is about to be removed from a view hierarchy.
 *  This method is called in response to a view being removed from a view hierarchy. This method is called before the view is actually removed and before any animations are configured.
 *  Subclasses can override this method and use it to commit editing changes, resign the first responder status of the view, or perform other relevant tasks. For example, you might use this method to revert changes to the orientation or style of the status bar that were made in the viewDidDisappear: method when the view was first presented. If you override this method, you must call super at some point in your implementation.
 *
 *  @param animated If YES, the view is being added to the window using an animation.
 */
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self stop];
}

/**
 *  Deallocates the memory occupied by the receiver.
 */
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/**
 *  Notifies the view controller that a segue is about to be performed.
 *  The default implementation of this method does nothing. Your view controller overrides this method when it needs to pass relevant data to the new view controller. The segue object describes the transition and includes references to both view controllers involved in the segue.
 *  Because segues can be triggered from multiple sources, you can use the information in the segue and sender parameters to disambiguate between different logical paths in your app. For example, if the segue originated from a table view, the sender parameter would identify the table view cell that the user tapped. You could use that information to set the data on the destination view controller.
 *
 *  @param segue  The segue object containing information about the view controllers involved in the segue.
 *  @param sender The object that initiated the segue. You might use this parameter to perform different actions based on which control (or other object) initiated the segue.
 */
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"CameraToTesseractSegue"])
    {
        NFNReceiptRecognitionViewController *vc = segue.destinationViewController;
        vc.image = self.imageTaken;
    }
}

#pragma mark - Background methods

/**
 *  Method called when UIApplicationWillResignActiveNotification is fired
 */
- (void)_backgroundMode
{
    self.forceStop = YES;
}

/**
 *  Method called when UIApplicationDidBecomeActiveNotification is fired
 */
- (void)_foregroundMode
{
    self.forceStop = NO;
}

/**
 *  Method called to enable border detection right after start the camera
 */
- (void)enableBorderDetectFrame
{
    _borderDetectFrame = YES;
}


#pragma mark - UI methods

/**
 *  Create a GLKView that will hold the Camera preview
 */
- (void)createGLKView
{
    if (self.context) return;
    
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    GLKView *view = [[GLKView alloc] initWithFrame:self.view.bounds];
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    view.translatesAutoresizingMaskIntoConstraints = YES;
    view.context = self.context;
    view.contentScaleFactor = 1.0f;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    [self.view insertSubview:view atIndex:0];
    _glkView = view;
    glGenRenderbuffers(1, &_renderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _renderBuffer);
    _coreImageContext = [CIContext contextWithEAGLContext:self.context];
    [EAGLContext setCurrentContext:self.context];
}

/**
 *  Hide/Show the GLKView
 *
 *  @param hidden     BOOL flag for hide/show
 *  @param completion code block handler to be executed after this operation
 */

- (void)hideGLKView:(BOOL)hidden completion:(void(^)())completion
{
    [UIView animateWithDuration:0.1 animations:^
     {
         _glkView.alpha = (hidden) ? 0.0 : 1.0;
     }
                     completion:^(BOOL finished)
     {
         if (!completion) return;
         completion();
     }];
}

/**
 *  Setup the Camera View and initializate the AutoFocus feature if available
 */
- (void)setupCameraView
{
    [self createGLKView];
    
    NSArray *possibleDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    AVCaptureDevice *device = [possibleDevices firstObject];
    if (!device) return;
    
    _imageDedectionConfidence = 0.0;
    
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    self.captureSession = session;
    [session beginConfiguration];
    self.captureDevice = device;
    
    NSError *error = nil;
    AVCaptureDeviceInput* input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    session.sessionPreset = AVCaptureSessionPresetPhoto;
    [session addInput:input];
    
    AVCaptureVideoDataOutput *dataOutput = [[AVCaptureVideoDataOutput alloc] init];
    [dataOutput setAlwaysDiscardsLateVideoFrames:YES];
    [dataOutput setVideoSettings:@{(id)kCVPixelBufferPixelFormatTypeKey:@(kCVPixelFormatType_32BGRA)}];
    [dataOutput setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
    [session addOutput:dataOutput];
    
    self.stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    [session addOutput:self.stillImageOutput];
    
    AVCaptureConnection *connection = [dataOutput.connections firstObject];
    [connection setVideoOrientation:AVCaptureVideoOrientationPortrait];
    
    if (device.isFlashAvailable)
    {
        [device lockForConfiguration:nil];
        [device setFlashMode:AVCaptureFlashModeOff];
        [device unlockForConfiguration];
        
        if ([device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus])
        {
            [device lockForConfiguration:nil];
            [device setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
            [device unlockForConfiguration];
        }
    }
    
    [session commitConfiguration];
}

#pragma mark - Action methods

/**
 *  Called when a tap gesture event if fired fot he Camera view
 *
 *  @param sender sender instance to the component that fired this event
 */
- (IBAction)focusGesture:(UITapGestureRecognizer *)sender {

    if (sender.state == UIGestureRecognizerStateRecognized)
    {
        CGPoint location = [sender locationInView:self.view];
        
        [self focusAtPoint:location completionHandler:nil];
    }
    
}

/**
 *  Called when touch up event is fired for snap still button
 *
 *  @param sender instance to the component that fired this event
 */
- (IBAction)touchUpSnapStillImageButton:(id)sender {
    [self captureImageWithCompletionHander:^(id data) {
        UIImage *image = ([data isKindOfClass:[NSData class]]) ? [UIImage imageWithData:data] : data;
        self.imageTaken = image;
        
        [self performSegueWithIdentifier:@"CameraToTesseractSegue" sender:self];
    }];
}

/**
 *  Start the camera capturing
 */
- (void)start
{
    _isStopped = NO;
    
    [self.captureSession startRunning];
    
    _borderDetectTimeKeeper = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(enableBorderDetectFrame) userInfo:nil repeats:YES];
    
    [self hideGLKView:NO completion:nil];
}

/**
 *  Stop the camera capturing
 */
- (void)stop
{
    _isStopped = YES;
    
    [self.captureSession stopRunning];
    
    [_borderDetectTimeKeeper invalidate];
    
    [self hideGLKView:YES completion:nil];
}

/**
 *  Focus Camera at a specific point
 *
 *  @param point             point where you want to focus at
 *  @param completionHandler code block to be executed at completion
 */
- (void)focusAtPoint:(CGPoint)point completionHandler:(void(^)())completionHandler
{
    AVCaptureDevice *device = self.captureDevice;
    CGPoint pointOfInterest = CGPointZero;
    CGSize frameSize = self.view.bounds.size;
    pointOfInterest = CGPointMake(point.y / frameSize.height, 1.f - (point.x / frameSize.width));
    
    if ([device isFocusPointOfInterestSupported] && [device isFocusModeSupported:AVCaptureFocusModeAutoFocus])
    {
        NSError *error;
        if ([device lockForConfiguration:&error])
        {
            if ([device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus])
            {
                [device setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
                [device setFocusPointOfInterest:pointOfInterest];
            }
            
            if([device isExposurePointOfInterestSupported] && [device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure])
            {
                [device setExposurePointOfInterest:pointOfInterest];
                [device setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
                if(completionHandler){
                    completionHandler();
                }
            }
            
            [device unlockForConfiguration];
        }
    }
    else
    {
        completionHandler();
    }
}

/**
 *  Capture an image from Camera
 *
 *  @param completionHandler code block to be executed at completion
 */
- (void)captureImageWithCompletionHander:(void(^)(id data))completionHandler
{
    if (_isCapturing) return;
    
    __typeof__(self) __weak weakSelf = self;
    
    [self hideGLKView:YES completion:^
     {
         [weakSelf hideGLKView:NO completion:^
          {
              [weakSelf hideGLKView:YES completion:nil];
          }];
     }];
    
    _isCapturing = YES;
    
    AVCaptureConnection *videoConnection = nil;
    for (AVCaptureConnection *connection in self.stillImageOutput.connections)
    {
        for (AVCaptureInputPort *port in [connection inputPorts])
        {
            if ([[port mediaType] isEqual:AVMediaTypeVideo] )
            {
                videoConnection = connection;
                break;
            }
        }
        if (videoConnection) break;
    }
    
    [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler: ^(CMSampleBufferRef imageSampleBuffer, NSError *error)
     {
         NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
         CIImage *enhancedImage = [CIImage imageWithData:imageData];
         enhancedImage = [self filteredImageUsingContrastFilterOnImage:enhancedImage];
         
         if (rectangleDetectionConfidenceHighEnough(_imageDedectionConfidence))
         {
             CIRectangleFeature *rectangleFeature = [self biggestRectangleInRectangles:[[self highAccuracyRectangleDetector] featuresInImage:enhancedImage]];
             
             if (rectangleFeature)
             {
                 enhancedImage = [self correctPerspectiveForImage:enhancedImage withFeatures:rectangleFeature];
             }
         }
         
         UIGraphicsBeginImageContext(CGSizeMake(enhancedImage.extent.size.height, enhancedImage.extent.size.width));
         [[UIImage imageWithCIImage:enhancedImage scale:1.0 orientation:UIImageOrientationRight] drawInRect:CGRectMake(0,0, enhancedImage.extent.size.height, enhancedImage.extent.size.width)];
         UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
         UIGraphicsEndImageContext();
         
         [weakSelf hideGLKView:NO completion:nil];
         completionHandler(image);
         
         _isCapturing = NO;
     }];
}


#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate methods

/**
 *  Notifies the delegate that a new video frame was written.
 *  Delegates receive this message whenever the output captures and outputs a new video frame, decoding or re-encoding it as specified by its videoSettings property.
 *  Delegates can use the provided video frame in conjunction with other APIs for further processing.
 *  This method is called on the dispatch queue specified by the output’s sampleBufferCallbackQueue property. It is called periodically, so it must be efficient to prevent capture performance problems, including dropped frames. If you need to reference the CMSampleBuffer object outside of the scope of this method, you must CFRetain it and then CFRelease it when you are finished with it.
 *  To maintain optimal performance, some sample buffers directly reference pools of memory that may need to be reused by the device system and other capture inputs. This is frequently the case for uncompressed device native capture where memory blocks are copied as little as possible. If multiple sample buffers reference such pools of memory for too long, inputs will no longer be able to copy new samples into memory and those samples will be dropped.
 *  If your application is causing samples to be dropped by retaining the provided CMSampleBufferRef objects for too long, but it needs access to the sample data for a long period of time, consider copying the data into a new buffer and then releasing the sample buffer (if it was previously retained) so that the memory it references can be reused.
 *
 *  @param captureOutput The capture output object.
 *  @param sampleBuffer  A CMSampleBuffer object containing the video frame data and additional information about the frame, such as its format and presentation time.

 *  @param connection    The connection from which the video was received.
 */
-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    if (self.forceStop) return;
    if (_isStopped || _isCapturing || !CMSampleBufferIsValid(sampleBuffer)) return;
    
    CVPixelBufferRef pixelBuffer = (CVPixelBufferRef)CMSampleBufferGetImageBuffer(sampleBuffer);
    
    CIImage *image = [CIImage imageWithCVPixelBuffer:pixelBuffer];
    
    image = [self filteredImageUsingContrastFilterOnImage:image];

    if (_borderDetectFrame)
    {
        _borderDetectLastRectangleFeature = [self biggestRectangleInRectangles:[[self highAccuracyRectangleDetector] featuresInImage:image]];
        _borderDetectFrame = NO;
    }
    
    if (_borderDetectLastRectangleFeature)
    {
        _imageDedectionConfidence += .5;
        
        image = [self drawHighlightOverlayForPoints:image topLeft:_borderDetectLastRectangleFeature.topLeft topRight:_borderDetectLastRectangleFeature.topRight bottomLeft:_borderDetectLastRectangleFeature.bottomLeft bottomRight:_borderDetectLastRectangleFeature.bottomRight];
    }
    else
    {
        _imageDedectionConfidence = 0.0f;
    }
    
    if (self.context && _coreImageContext)
    {
        [_coreImageContext drawImage:image inRect:self.view.bounds fromRect:image.extent];
        [self.context presentRenderbuffer:GL_RENDERBUFFER];
        
        [_glkView setNeedsDisplay];
    }
}

#pragma mark - Image processing methods

/**
 *  Draw an image over the UIImage showing likely the rectangle found
 *
 *  @param image       image to be drawn over camera
 *  @param topLeft     top left coordinates
 *  @param topRight    top right coordinates
 *  @param bottomLeft  bottom left coordinates
 *  @param bottomRight bottom right coordinates
 *
 *  @return a image
 */
- (CIImage *)drawHighlightOverlayForPoints:(CIImage *)image topLeft:(CGPoint)topLeft topRight:(CGPoint)topRight bottomLeft:(CGPoint)bottomLeft bottomRight:(CGPoint)bottomRight
{
    CIImage *overlay = [CIImage imageWithColor:[CIColor colorWithRed:1.0 green:0.79 blue:0.04 alpha:0.5]];
    overlay = [overlay imageByCroppingToRect:image.extent];
    overlay = [overlay imageByApplyingFilter:@"CIPerspectiveTransformWithExtent" withInputParameters:@{@"inputExtent":[CIVector vectorWithCGRect:image.extent],@"inputTopLeft":[CIVector vectorWithCGPoint:topLeft],@"inputTopRight":[CIVector vectorWithCGPoint:topRight],@"inputBottomLeft":[CIVector vectorWithCGPoint:bottomLeft],@"inputBottomRight":[CIVector vectorWithCGPoint:bottomRight]}];
    
    return [overlay imageByCompositingOverImage:image];
}

/**
 *  Apply constrast filter to an image. This is particulary helpful when trying to detect features on an image
 *
 *  @param image a CIImage you want o apply this filter
 *
 *  @return a CIImage
 */
- (CIImage *)filteredImageUsingContrastFilterOnImage:(CIImage *)image
{
    return [CIFilter filterWithName:@"CIColorControls" withInputParameters:@{@"inputContrast":@(1.1),kCIInputImageKey:image}].outputImage;
}

/**
 *  Apply perspective correction filter to an image to make it more suitable to an OCR tool
 *
 *  @param image            a CIImage you want o apply this filter
 *  @param rectangleFeature rectangle feature instance that contains all necessary points for this filter
 *
 *  @return a CIImage
 *
 *  @see http://opencv-code.com/tutorials/automatic-perspective-correction-for-quadrilateral-objects/
 */
- (CIImage *)correctPerspectiveForImage:(CIImage *)image withFeatures:(CIRectangleFeature *)rectangleFeature
{
    NSMutableDictionary *rectangleCoordinates = [NSMutableDictionary new];
    rectangleCoordinates[@"inputTopLeft"] = [CIVector vectorWithCGPoint:rectangleFeature.topLeft];
    rectangleCoordinates[@"inputTopRight"] = [CIVector vectorWithCGPoint:rectangleFeature.topRight];
    rectangleCoordinates[@"inputBottomLeft"] = [CIVector vectorWithCGPoint:rectangleFeature.bottomLeft];
    rectangleCoordinates[@"inputBottomRight"] = [CIVector vectorWithCGPoint:rectangleFeature.bottomRight];
    return [image imageByApplyingFilter:@"CIPerspectiveCorrection" withInputParameters:rectangleCoordinates];
}

/**
 *  Get instance of the high accuracy rectangle detector
 *
 *  @return a CIDetector instance
 */
- (CIDetector *)highAccuracyRectangleDetector
{
    static CIDetector *detector = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
                  {
                      detector = [CIDetector detectorOfType:CIDetectorTypeRectangle context:nil options:@{CIDetectorAccuracy : CIDetectorAccuracyHigh}];
                  });
    return detector;
}

/**
 *  Calculates the biggest rectangle as possible among all rectangles found in an image
 *
 *  @param rectangles rectangles found
 *
 *  @return a rectangle feature instance that contains all necessary points for this filter
 */
- (CIRectangleFeature *)biggestRectangleInRectangles:(NSArray *)rectangles
{
    if (![rectangles count]) return nil;
    
    float halfPerimiterValue = 0;
    
    CIRectangleFeature *biggestRectangle = [rectangles firstObject];
    
    for (CIRectangleFeature *rect in rectangles)
    {
        CGPoint p1 = rect.topLeft;
        CGPoint p2 = rect.topRight;
        CGFloat width = hypotf(p1.x - p2.x, p1.y - p2.y);
        
        CGPoint p3 = rect.topLeft;
        CGPoint p4 = rect.bottomLeft;
        CGFloat height = hypotf(p3.x - p4.x, p3.y - p4.y);
        
        CGFloat currentHalfPerimiterValue = height + width;
        
        if (halfPerimiterValue < currentHalfPerimiterValue)
        {
            halfPerimiterValue = currentHalfPerimiterValue;
            biggestRectangle = rect;
        }
    }
    
    return biggestRectangle;
}

/**
 *  Check whether or not a specific detected rectangle has enough confidence to be considered a real rectangle
 *
 *  @param confidence confidence value you've found
 *
 *  @return YES if it's confident enough, NO otherwise.
 */
BOOL rectangleDetectionConfidenceHighEnough(float confidence)
{
    return (confidence > 1.0);
}


@end
