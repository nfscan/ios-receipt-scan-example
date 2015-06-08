//
//  NFNOCRService.h
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

#import <Foundation/Foundation.h>

// Libraries
#import <AFNetworking/AFNetworking.h>

// Beans
#import "TaxReceipt.h"

// Utils
#import "Constants.h"
#import "NetworkAvailabilityUtils.h"

// Categories
#import "UIImage+Common.h"

// Security
#import "PassCode.h"
#import "CounterSignCode.h"

typedef enum : NSUInteger {
    PROCESS_AUTH_REQUEST,
    PROCESS_START_REQUEST,
    PROCESS_CHECK_REQUEST,
    DONATE_REQUEST,
} RequestIdentifier;

@protocol NFNOCRServiceDelegate <NSObject>

-(void) sucessOnRequest:(RequestIdentifier)identifier jsonResponse:(NSDictionary *)jsonArray;
-(void) errorOnRequest:(RequestIdentifier)identifier jsonResponse:(NSDictionary *)jsonArray;

@end

@interface NFNOCRService : NSObject

@property(retain,nonatomic) id<NFNOCRServiceDelegate> delegate;

-(void) requestProcessAuth;
-(void) requestProcessStart:(NSString*) transactionId counterSignature:(NSString*)counterSignature receipt:(UIImage*) image;
-(void) requestProcessCheck:(NSString*) transactionId counterSignature:(NSString*)counterSignature;
-(void) requestDonate:(NSString*) transactionId receipt:(TaxReceipt*) receipt;

@end
