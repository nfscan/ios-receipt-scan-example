//
//  NFNOCRService.m
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

#import "NFNOCRService.h"

@interface NFNOCRService()
/**
 *  AFHTTPRequestOperationManager encapsulates the common patterns of communicating with a web application over HTTP
 */
@property (strong, nonatomic) AFHTTPRequestOperationManager *manager;

@end

@implementation NFNOCRService

/**
 *  Default constructor
 *
 *  @return self
 */
-(instancetype)init
{
    self = [super init];
    if(self){
        self.manager = [AFHTTPRequestOperationManager manager];
    }
    return self;
}

/**
 *  Request the process authentication endpoint
 */
-(void) requestProcessAuth
{
    [self.manager POST:[Constants PROCESS_AUTH_SERVICE] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
#ifdef DEBUG
        NSLog(@"JSON: %@", responseObject);
#endif
        if ([[responseObject valueForKey:@"success"]boolValue])
        {
            [self.delegate sucessOnRequest:PROCESS_AUTH_REQUEST jsonResponse:responseObject];
        }
        else
        {
            [self.delegate errorOnRequest:PROCESS_AUTH_REQUEST jsonResponse:responseObject];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
#ifdef DEBUG
        NSLog(@"Error: %@", error);
#endif
        [self.delegate errorOnRequest:PROCESS_AUTH_REQUEST jsonResponse:nil];

    }];
    
}

/**
 *  Request the process start endpoint
 *
 *  @param transactionId    transaction id generated on auth method
 *  @param counterSignature counter signature generated from your app
 *  @param image            UIImage to be processed
 *
 *  @see PassCode
 *  @see CounterSignCode
 */
-(void) requestProcessStart:(NSString*) transactionId counterSignature:(NSString*)counterSignature receipt:(UIImage*) image
{
    
    UIImage* resizedImage = [image resizeToWidth:800];
    NSString* base64String = [resizedImage base64StringFromImage:0.8];
    
    NSMutableDictionary *info = [NSMutableDictionary dictionary];
    [info setValue:base64String forKey:@"base64Image"];
    [info setValue:transactionId forKey:@"transactionId"];
    [info setValue:counterSignature forKey:@"counterSignature"];
    
    [self.manager POST:[Constants PROCESS_START_SERVICE] parameters:info success:^(AFHTTPRequestOperation *operation, id responseObject) {
#ifdef DEBUG
        NSLog(@"JSON: %@", responseObject);
#endif
        if ([[responseObject valueForKey:@"success"]boolValue])
        {
            [self.delegate sucessOnRequest:PROCESS_START_REQUEST jsonResponse:responseObject];
        }
        else
        {
            [self.delegate errorOnRequest:PROCESS_START_REQUEST jsonResponse:responseObject];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
#ifdef DEBUG
        NSLog(@"Error: %@", error);
#endif

        [self.delegate errorOnRequest:PROCESS_START_REQUEST jsonResponse:nil];

    }];
    
}

/**
 *  Request the process check endpoint
 *
 *  @param transactionId    transaction id generated on auth method
 *  @param counterSignature counter signature generated from your app
 */
-(void) requestProcessCheck:(NSString*) transactionId counterSignature:(NSString*)counterSignature
{
    NSDictionary *parameters = @{@"transactionId": transactionId, @"counterSignature": counterSignature};
    [self.manager POST:[Constants PROCESS_CHECK_SERVICE] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
#ifdef DEBUG
        NSLog(@"JSON: %@", responseObject);
#endif
        [self.delegate sucessOnRequest:PROCESS_CHECK_REQUEST jsonResponse:responseObject];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
#ifdef DEBUG
        NSLog(@"Error: %@", error);
#endif

        [self.delegate errorOnRequest:PROCESS_CHECK_REQUEST jsonResponse:nil];

    }];
}

/**
 *  Request the donation endpoint
 *
 *  @param transactionId transaction id generated on auth method
 *  @param receipt       Receipt object
 */
-(void) requestDonate:(NSString*) transactionId receipt:(TaxReceipt*) receipt
{
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = [Constants DATE_FORMAT];
    NSString* dateStr = [dateFormatter stringFromDate:receipt.date];
    
    NSDictionary *parameters = @{@"transactionId": transactionId, @"cnpj" : receipt.cnpj, @"coo": receipt.coo, @"date": dateStr, @"total" : [NSString stringWithFormat:@"%.2f",receipt.total]};
    
    [self.manager POST:[Constants DONATE_SERVICE] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
#ifdef DEBUG
        NSLog(@"JSON: %@", responseObject);
#endif
        [self.delegate sucessOnRequest:DONATE_REQUEST jsonResponse:responseObject];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
#ifdef DEBUG
        NSLog(@"Error: %@", error);
#endif

        [self.delegate errorOnRequest:DONATE_REQUEST jsonResponse:nil];

    }];
    
}


@end
