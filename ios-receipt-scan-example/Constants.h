//
//  Constants.h
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

/**
 *  Class that provides utility constants across the application
 *  @author Paulo Miguel Almeida Rodenas &lt;paulo.ubuntu@gmail.com&gt;
 */
@interface Constants : NSObject

// HTTP Endpoints
/**
 *  Return the process authentication http endpoint
 *
 *  @return a NSString
 */
+(NSString*) PROCESS_AUTH_SERVICE;

/**
 *  Return the process start http endpoint
 *
 *  @return a NSString
 */
+(NSString*) PROCESS_START_SERVICE;

/**
 *  Return the process check http endpoint
 *
 *  @return a NSString
 */
+(NSString*) PROCESS_CHECK_SERVICE;

/**
 *  Return the donate http endpoint
 *
 *  @return a NSString
 */
+(NSString*) DONATE_SERVICE;

// MISC

/**
 *  Return the Date format expected by the nfscan-server
 *
 *  @return a NSString
 */
+(NSString*) DATE_FORMAT;
@end
