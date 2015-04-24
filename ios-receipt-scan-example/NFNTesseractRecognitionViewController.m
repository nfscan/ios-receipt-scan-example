//
//  NFNTesseractRecognitionViewController.m
//  ios-receipt-scan-example
//
//  Created by Paulo Miguel Almeida on 4/24/15.
//  Copyright (c) 2015 Paulo Miguel Almeida Rodenas. All rights reserved.
//

#import "NFNTesseractRecognitionViewController.h"

@implementation NFNTesseractRecognitionViewController

#pragma mark - UIViewController lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupUI];
}

-(void) setupUI{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"Loading";
    
    NFNTesseractImageRecognizer *tesseract = [[NFNTesseractImageRecognizer alloc] init];
    [tesseract recognizeText:self.image AndCompletion:^(G8Tesseract *tesseract) {
        
        NSLog(@"%s recognizedText: %@",__PRETTY_FUNCTION__,tesseract.recognizedText);
        [hud hide:YES];
    }];
}

@end
