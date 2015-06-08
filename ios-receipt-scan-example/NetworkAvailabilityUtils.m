//
//  NetworkAvailabilityUtils.m
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

#import "NetworkAvailabilityUtils.h"

@implementation NetworkAvailabilityUtils

static NetworkAvailabilityUtils *instance;

static bool isConnected;

+(NetworkAvailabilityUtils*) instance
{
    if(instance == NULL)
    {
        instance = [[self alloc]init];
    }
    return instance;
}

+(BOOL) isConnected
{
    return isConnected;
}

- (id)init {
    if ( (self = [super init]) ) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkChanged:) name:kReachabilityChangedNotification object:nil];
        
        _reachability = [Reachability reachabilityForInternetConnection];
        [_reachability startNotifier];
        
        //Perform a first check in order to get the actual scenario
        [self networkChanged:nil];
    }
    return self;
}


- (void)networkChanged:(NSNotification *)notification
{
    
    NetworkStatus remoteHostStatus = [_reachability currentReachabilityStatus];
    
    if(remoteHostStatus == NotReachable)
    {
        NSLog(@"not reachable");
        isConnected = NO;
    }
    else if (remoteHostStatus == ReachableViaWiFi)
    {
        NSLog(@"wifi");
        isConnected = YES;
    }
    else if (remoteHostStatus == ReachableViaWWAN)
    {
        NSLog(@"carrier");
        isConnected = YES;
    }
}


@end
