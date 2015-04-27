//
//  NFNCameraRectDetectionViewController.h
//  ios-receipt-scan-example
//
//  Created by Paulo Miguel Almeida on 4/24/15.
//  Copyright (c) 2015 Paulo Miguel Almeida Rodenas. All rights reserved.
//

// Libraries
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import <CoreVideo/CoreVideo.h>
#import <CoreImage/CoreImage.h>
#import <ImageIO/ImageIO.h>
#import <GLKit/GLKit.h>
#import <GLKit/GLKit.h>

// View Controllers
#import "NFNTesseractRecognitionViewController.h"

@interface NFNCameraRectDetectionViewController : UIViewController<AVCaptureVideoDataOutputSampleBufferDelegate>

@end
