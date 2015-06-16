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

/**
 * Enum that specifies which request we're performing
 * when receiving events through NFNOCRServiceDelegate
 *
 * @see NFNOCRServiceDelegate
 */
typedef enum : NSUInteger {
    PROCESS_AUTH_REQUEST,
    PROCESS_START_REQUEST,
    PROCESS_CHECK_REQUEST,
    DONATE_REQUEST,
} RequestIdentifier;

/**
 *  A delegate that acts on behalf of NFNOCRService when we receive http responses from nfscan-server
 *  @author Paulo Miguel Almeida Rodenas &lt;paulo.ubuntu@gmail.com&gt;
 */
@protocol NFNOCRServiceDelegate <NSObject>

/**
 *  Method called when the response is successfully received (HTTP Code 200) and parsed into a JSON array
 *
 *  @param identifier identifies which request this response if from
 *  @param jsonArray  a JSON array containing the response got from server
 */
-(void) sucessOnRequest:(RequestIdentifier)identifier jsonResponse:(NSDictionary *)jsonArray;

/**
 *  Method called when the response isn't received (HTTP Code != 200) correctly
 *
 *  @param identifier identifies which request this response if from
 *  @param jsonArray  a JSON array containing the response got from server if any
 */
-(void) errorOnRequest:(RequestIdentifier)identifier jsonResponse:(NSDictionary *)jsonArray;

@end

/**
 *  Class that deals with all http requests related to the donation flow
 *  @author Paulo Miguel Almeida Rodenas &lt;paulo.ubuntu@gmail.com&gt;
 */
@interface NFNOCRService : NSObject

/**
 *  delegate reference to a class that deals with http responses
 */
@property(retain,nonatomic) id<NFNOCRServiceDelegate> delegate;

/**
 *  Request the process authentication endpoint
 */
-(void) requestProcessAuth;

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
-(void) requestProcessStart:(NSString*) transactionId counterSignature:(NSString*)counterSignature receipt:(UIImage*) image;

/**
 *  Request the process check endpoint
 *
 *  @param transactionId    transaction id generated on auth method
 *  @param counterSignature counter signature generated from your app
 */
-(void) requestProcessCheck:(NSString*) transactionId counterSignature:(NSString*)counterSignature;

/**
 *  Request the donation endpoint
 *
 *  @param transactionId transaction id generated on auth method
 *  @param receipt       Receipt object
 */
-(void) requestDonate:(NSString*) transactionId receipt:(TaxReceipt*) receipt;

@end
