//
//  NFNTesseractImageRecognizer.h
//  ios-receipt-scan-example
//
//  Created by Paulo Miguel Almeida on 4/24/15.
//  Copyright (c) 2015 Paulo Miguel Almeida Rodenas. All rights reserved.
//

// Libraries
#import <Foundation/Foundation.h>
#import <TesseractOCR/TesseractOCR.h>
#import <TesseractOCR/G8RecognitionOperation.h>
#import <TesseractOCR/G8TesseractParameters.h>

@interface NFNTesseractImageRecognizer : NSObject

-(void)recognizeText:(UIImage *)image  AndCompletion:(G8RecognitionOperationCallback) completion;

-(void)recognizeText:(UIImage *)image AndCharWhitelist:(NSString *)charWhitelist AndCompletion:(G8RecognitionOperationCallback) completion;


@end
