//
//  NFNTesseractImageRecognizer.m
//  ios-receipt-scan-example
//
//  Created by Paulo Miguel Almeida on 4/24/15.
//  Copyright (c) 2015 Paulo Miguel Almeida Rodenas. All rights reserved.
//

#import "NFNTesseractImageRecognizer.h"

@interface NFNTesseractImageRecognizer()

@property (nonatomic, strong) NSOperationQueue *operationQueue;

@end

@implementation NFNTesseractImageRecognizer

-(instancetype)init{
    self = [super init];
    if(self){
        self.operationQueue = [[NSOperationQueue alloc] init];
    }
    return self;
}

-(void)recognizeText:(UIImage *)image  AndCompletion:(G8RecognitionOperationCallback) completion
{
    [self recognizeText:image AndCharWhitelist:nil AndCompletion:completion];
}

-(void)recognizeText:(UIImage *)image AndCharWhitelist:(NSString *)charWhitelist AndCompletion:(G8RecognitionOperationCallback) completion
{
    
    UIImage *bwImage = [image g8_blackAndWhite];
    
    G8RecognitionOperation *operation = [[G8RecognitionOperation alloc] initWithLanguage:@"eng"];
    
    operation.tesseract.language = @"eng";
    
    operation.tesseract.engineMode = G8OCREngineModeTesseractOnly;
    
    operation.tesseract.pageSegmentationMode = G8PageSegmentationModeAuto;
    
    if(charWhitelist){
        operation.tesseract.charWhitelist = charWhitelist;
    }
    
    //Setting tesseract variables parameters
    [operation.tesseract setVariableValue:@"false" forKey:kG8ParamLoadSystemDawg];
    [operation.tesseract setVariableValue:@"false" forKey:kG8ParamLoadFreqDawg];
    [operation.tesseract setVariableValue:@"false" forKey:kG8ParamLoadPuncDawg];
    [operation.tesseract setVariableValue:@"false" forKey:kG8ParamLoadNumberDawg];
    [operation.tesseract setVariableValue:@"false" forKey:kG8ParamLoadUnambigDawg];
    [operation.tesseract setVariableValue:@"false" forKey:kG8ParamLoadBigramDawg];
//    [operation.tesseract setVariableValue:@"false" forKey:kG8ParamLoadFixedLengthDawgs];
    
    operation.tesseract.image = bwImage;
    
    // Optionally limit the region in the image on which Tesseract should
    // perform recognition to a rectangle
    //operation.tesseract.rect = CGRectMake(20, 20, 100, 100);
    
    operation.recognitionCompleteBlock = completion;
    
    // Finally, add the recognition operation to the queue
    [self.operationQueue addOperation:operation];
}

@end
