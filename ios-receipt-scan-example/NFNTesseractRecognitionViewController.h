//
//  NFNTesseractRecognitionViewController.h
//  ios-receipt-scan-example
//
//  Created by Paulo Miguel Almeida on 4/24/15.
//  Copyright (c) 2015 Paulo Miguel Almeida Rodenas. All rights reserved.
//

// Libraries
#import <UIKit/UIKit.h>
#import <MBProgressHUD/MBProgressHUD.h>

// Services
#import "NFNTesseractImageRecognizer.h"

@interface NFNTesseractRecognitionViewController : UIViewController

@property (strong, nonatomic) UIImage* image;

@end
