//
//  NFNTesseractRecognitionViewController.m
//  ios-receipt-scan-example
//
//  Created by Paulo Miguel Almeida on 4/24/15.
//  Copyright (c) 2015 Paulo Miguel Almeida Rodenas. All rights reserved.
//

#import "NFNTesseractRecognitionViewController.h"

@interface NFNTesseractRecognitionViewController()
@property (weak, nonatomic) IBOutlet UIView *dataView;
@property (weak, nonatomic) IBOutlet UIView *thankYouView;


@property (weak, nonatomic) IBOutlet UILabel *cnpjLabel;
@property (weak, nonatomic) IBOutlet UILabel *cooLabel;
@property (weak, nonatomic) IBOutlet UILabel *dataLabel;
@property (weak, nonatomic) IBOutlet UILabel *valorLabel;

@end

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
    
    NFNTesseractImageRecognizer *tesseract = [[NFNTesseractImageRecognizer alloc] init];
    [tesseract recognizeText:self.image AndCompletion:^(G8Tesseract *tesseract) {
        
        NSLog(@"%s recognizedText: %@",__PRETTY_FUNCTION__,tesseract.recognizedText);
        [hud hide:YES];
        
        self.dataView.hidden = NO;
        self.thankYouView.hidden = YES;
    }];
}


#pragma mark - Action methods

- (IBAction)cameraButtonHandler:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)donateButtonHandler:(id)sender {
    self.dataView.hidden = YES;
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    
    dispatch_queue_t serverDelaySimulationThread = dispatch_queue_create("com.github.nfscan.ios-receipt-scan-example.serverUpload", nil);
    dispatch_async(serverDelaySimulationThread, ^{
        [NSThread sleepForTimeInterval:5.0];
        dispatch_async(dispatch_get_main_queue(), ^{
            //Your server communication code here
            
            self.thankYouView.hidden = NO;
            [hud hide:YES];
            
        });
    });
    
}



@end
