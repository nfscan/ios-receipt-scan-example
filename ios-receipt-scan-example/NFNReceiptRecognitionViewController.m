//
//  NFNReceiptRecognitionViewController.m
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

#import "NFNReceiptRecognitionViewController.h"

@interface NFNReceiptRecognitionViewController()

// Components
@property (weak, nonatomic) IBOutlet UIView *dataView;
@property (weak, nonatomic) IBOutlet UIView *thankYouView;

@property (weak, nonatomic) IBOutlet UITextField *cnpjTextField;
@property (weak, nonatomic) IBOutlet UITextField *cooTextField;
@property (weak, nonatomic) IBOutlet UITextField *dataTextField;
@property (weak, nonatomic) IBOutlet UITextField *valorTextField;
@property (weak, nonatomic) IBOutlet UIButton *donateButton;

// Delegates
@property (strong, nonatomic) CNPJFormatterTextFieldDelegate* cnpjFormatterDelegate;
@property (strong, nonatomic) DateFormatterTextFieldDelegate* dateFormatterDelegate;
@property (strong, nonatomic) CurrencyFormatterTextFieldDelegate* currencyFormatterTextFieldDelegate;
@property (strong, nonatomic) COOFormatterTextFieldDelegate* cooFormatterTextFieldDelegate;

// Http
@property (strong, nonatomic) NFNOCRService* ocrService;

// Security
@property (strong, nonatomic) NSString* transactionId;
@property (strong, nonatomic) NSString* counterSignature;

// Flow
@property (strong, nonatomic) TaxReceipt* receipt;
@property (strong, nonatomic) NSTimer *timer;
@property (nonatomic) int numberOfProcessCheckDone;

@end

@implementation NFNReceiptRecognitionViewController

#pragma mark - UIViewController lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Init OCR service instance
    self.ocrService = [[NFNOCRService alloc] init];
    self.ocrService.delegate = self;
    
    [self setupUI];
}

-(void) setupUI{
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"Processando";
    
    // Setting delegates to each UITextField
    self.cnpjFormatterDelegate = [[CNPJFormatterTextFieldDelegate alloc] init];
    self.dateFormatterDelegate = [[DateFormatterTextFieldDelegate alloc] init];
    self.currencyFormatterTextFieldDelegate = [[CurrencyFormatterTextFieldDelegate alloc] init];
    self.cooFormatterTextFieldDelegate = [[COOFormatterTextFieldDelegate alloc] init];
    self.cnpjTextField.delegate = self.cnpjFormatterDelegate;
    self.dataTextField.delegate = self.dateFormatterDelegate;
    self.valorTextField.delegate = self.currencyFormatterTextFieldDelegate;
    self.cooTextField.delegate = self.cooFormatterTextFieldDelegate;
    
    // Add Targets for Form validation
    [self.cnpjTextField  addTarget:self action:@selector(validateForm:) forControlEvents:UIControlEventEditingChanged];
    [self.dataTextField  addTarget:self action:@selector(validateForm:) forControlEvents:UIControlEventEditingChanged];
    [self.cooTextField   addTarget:self action:@selector(validateForm:) forControlEvents:UIControlEventEditingChanged];
    [self.valorTextField addTarget:self action:@selector(validateForm:) forControlEvents:UIControlEventEditingChanged];

    
    [self.ocrService requestProcessAuth];
}


#pragma mark - Action methods
- (IBAction)touchUpDataView:(id)sender {
    [self.view endEditing:YES];
}

- (IBAction)cameraButtonHandler:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)donateButtonHandler:(id)sender {
    self.dataView.hidden = YES;
    
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = [Constants DATE_FORMAT];
    
    self.receipt.cnpj = [self.cnpjTextField.text removeNonNumeric];
    self.receipt.date = [dateFormatter dateFromString:self.dataTextField.text];
    self.receipt.coo = self.cooTextField.text;
    self.receipt.total = [self.valorTextField.text doubleValue];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    
    __weak typeof(self) weakSelf = self;
    
    dispatch_queue_t serverDelaySimulationThread = dispatch_queue_create("com.github.nfscan.ios-receipt-scan-example.serverUpload", nil);
    dispatch_async(serverDelaySimulationThread, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.ocrService requestDonate:weakSelf.transactionId receipt:weakSelf.receipt];
        });
    });
    
}

#pragma mark - Network methods

-(void) sucessOnRequest:(RequestIdentifier)identifier jsonResponse:(NSDictionary *)jsonArray
{
#ifdef DEBUG
    NSLog(@"%s",__PRETTY_FUNCTION__);
#endif
    
    if(identifier == PROCESS_AUTH_REQUEST)
    {

        self.transactionId = [jsonArray valueForKey:@"transactionId"];
        NSString* signature = [jsonArray valueForKey:@"signature"];
        
        PassCode *passCode = [[PassCode alloc] init];
        if([passCode validatePass:signature])
        {
            CounterSignCode* counterSign = [[CounterSignCode alloc] init];
            self.counterSignature = [counterSign generate:signature];
            
            [self.ocrService requestProcessStart:self.transactionId counterSignature:self.counterSignature receipt:self.image];
        }
        else
        {
            [self errorOnRequest:PROCESS_AUTH_REQUEST jsonResponse:jsonArray];
        }
        
    }else if(identifier == PROCESS_START_REQUEST)
    {
        self.timer = [NSTimer scheduledTimerWithTimeInterval: 3.0 target: self selector: @selector(checkProcessingStatus) userInfo: nil repeats: YES];
    }
    else if(identifier == PROCESS_CHECK_REQUEST)
    {
        NSDictionary* ocrTransactionJSON = [jsonArray valueForKey:@"ocrTransaction"];
        if([[ocrTransactionJSON valueForKey:@"processed"]boolValue])
        {
            [self.timer invalidate];
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            
            self.dataView.hidden = NO;
            self.thankYouView.hidden = YES;
            
            NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.dateFormat = [Constants DATE_FORMAT];
            
            TaxReceipt *receipt = [[TaxReceipt alloc] init];
            receipt.cnpj = [ocrTransactionJSON valueForKey:@"cnpj"];
            receipt.coo = [ocrTransactionJSON valueForKey:@"coo"];
            receipt.date = [dateFormatter dateFromString:[ocrTransactionJSON valueForKey:@"date"]] ;
            receipt.total = [[ocrTransactionJSON valueForKey:@"total"] doubleValue];
            
            self.cnpjTextField.text = receipt.cnpj;
            self.cooTextField.text = receipt.coo;
            self.dataTextField.text = [dateFormatter stringFromDate:receipt.date];
            self.valorTextField.text = [NSString stringWithFormat:@"%.2f", receipt.total];
            
            // Formatting data for the first time since it doesn't fire a UIControlEventEditingChanged event
            [self.cnpjFormatterDelegate reformat:self.cnpjTextField];
            [self.dateFormatterDelegate reformat:self.dataTextField];
            [self.cooFormatterTextFieldDelegate reformat:self.cooTextField];
            [self.currencyFormatterTextFieldDelegate reformat:self.valorTextField];
            
            // Validate whether or not we enable the doneButton. It's useful for when all field are being recognized somehow.
            [self commonValidateForm];

            
            self.receipt = receipt;
        }
    }
    else if(identifier == DONATE_REQUEST)
    {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        self.dataView.hidden = YES;
        self.thankYouView.hidden = NO;
    }
}

-(void) errorOnRequest:(RequestIdentifier)identifier jsonResponse:(NSDictionary *)jsonArray
{
#ifdef DEBUG
    NSLog(@"%s",__PRETTY_FUNCTION__);
#endif
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    NSString* alertMessage;
    
    if([NetworkAvailabilityUtils isConnected])
    {
        alertMessage = @"Something wen wrong";
    }
    else
    {
        alertMessage = @"No connection to internet";
    }
    
    
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"Error"
                                          message:alertMessage
                                          preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:NSLocalizedString(@"OK", @"OK action")
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                   [self.navigationController popViewControllerAnimated:YES];
                               }];
    
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - Utility methods

-(void) checkProcessingStatus
{
#ifdef DEBUG
    NSLog(@"%s",__PRETTY_FUNCTION__);
#endif
    self.numberOfProcessCheckDone += 1;
    if (self.numberOfProcessCheckDone < 30) // 90 seconds
    {
        [self.ocrService requestProcessCheck:self.transactionId counterSignature:self.counterSignature];
    }
    else
    {
        [self.timer invalidate];
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];

        UIAlertController *alertController = [UIAlertController
                                              alertControllerWithTitle:@"Error"
                                              message:@"An OCR process timeout has occurred. Are absolutely sure you're running the OCR service ?"
                                              preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"OK", @"OK action")
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action)
                                   {
                                       [self.navigationController popViewControllerAnimated:YES];
                                   }];
        
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
        
    }
}

-(void) validateForm:(UITextField *)textField
{
    if(textField == self.cnpjTextField )
    {
        [self.cnpjFormatterDelegate reformat:self.cnpjTextField];
    }
    else if(textField == self.dataTextField )
    {
        [self.dateFormatterDelegate reformat:self.dataTextField];
    }
    else if(textField == self.cooTextField )
    {
        [self.cooFormatterTextFieldDelegate reformat:self.cooTextField];
    }
    else if(textField == self.valorTextField )
    {
        [self.currencyFormatterTextFieldDelegate reformat:self.valorTextField];
    }
    
    // Validate whether or not we enable the doneButton
    [self commonValidateForm];
    
}

-(void) commonValidateForm
{
#ifdef DEBUG
    NSLog(@"%s self.cnpjFormatterDelegate: %d",__PRETTY_FUNCTION__, [self.cnpjFormatterDelegate validarCNPJ:[self.cnpjTextField.text removeNonNumeric]]);
    NSLog(@"%s self.dateFormatterDelegate: %d",__PRETTY_FUNCTION__, [self.dateFormatterDelegate validateDate:[self.dataTextField.text removeNonNumeric]]);
    NSLog(@"%s self.cooTextField.text.length == 6: %d",__PRETTY_FUNCTION__, self.cooTextField.text.length == 6);
    NSLog(@"%s [self.totalTextField.text doubleValue] > 0.f: %d",__PRETTY_FUNCTION__, [self.valorTextField.text doubleValue] > 0.f);
#endif
    
    [self.donateButton setEnabled:(
                                 [self.cnpjFormatterDelegate validarCNPJ:[self.cnpjTextField.text removeNonNumeric]] &&
                                 [self.dateFormatterDelegate validateDate:[self.dataTextField.text removeNonNumeric]] &&
                                 self.cooTextField.text.length == 6 &&
                                 [self.valorTextField.text doubleValue] > 0.f
                                 )];
}



@end
