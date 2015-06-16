//
//  UIImage+Common.h
//  IosBlurPanGestureExample
//
//  Version 0.0.1
//
//  The MIT License (MIT)
//
//  Copyright (c) 2015 Paulo Miguel Almeida Rodenas <paulo.ubuntu@gmail.com>
//
//  Get the latest version from here:
//
//  https://github.com/nfscan/ios-blur-pan-gesture
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

#import <UIKit/UIKit.h>

/**
 *  UIImage category that provides methods to deal with
 *  common image processings
 *  @author Paulo Miguel Almeida Rodenas &lt;paulo.ubuntu@gmail.com&gt;
 */
@interface UIImage (Common)
/**
 *  Crop a rect from image
 *
 *  @param rectOfInterest rect you want to crop
 *
 *  @return an image
 */
-(UIImage*) cropImage:(CGRect) rectOfInterest;

/**
 *  Draw an image over the current image within a rect
 *
 *  @param inputImage image you want to draw
 *  @param frame      rect where it'll be draw
 *
 *  @return an image
 */
-(UIImage *)drawImage:(UIImage *)inputImage inRect:(CGRect)frame;

/**
 *  Resize image keeping the aspect ratio
 *
 *  @param i_width width you want to resize to
 *
 *  @return an image
 */
-(UIImage*) resizeToWidth: (float) i_width;

/**
 *  Convert image to the base64 representation using JPEG
 *  representation and compression quality 1.0 (100%)
 *
 *  @return a NSString
 */

-(NSString*) base64StringFromImage;

/**
 *  Convert image to the base64 representation using JPEG
 *  representation and compression quality
 *
 *  @param quality compressiong quality
 *
 *  @return a NSString
 */
-(NSString*) base64StringFromImage:(float) quality;

@end
