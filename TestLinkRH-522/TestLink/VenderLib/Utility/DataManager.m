//
//  DataManager.m
//  Product Catalog
//
//  Created by Bhoomi Jagani on 25/11/14.
//  Copyright (c) 2014 Urvesh Patel. All rights reserved.
//

#import "DataManager.h"
#import <Foundation/Foundation.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <netinet/in.h>
#import "InterfaceUtility.h"
//#import "InterfaceUtility.h"
static DataManager *sharedMyManager = nil;

@implementation DataManager

#pragma mark Singleton Methods

@synthesize isConnectionReachable;
+ (id)sharedManager {
    @synchronized(self) {
        if(sharedMyManager == nil)
            sharedMyManager = [[super allocWithZone:NULL] init];
        [sharedMyManager checkForReachability];
    }
    return sharedMyManager;
}

+ (id)allocWithZone:(NSZone *)zone {
    return [self sharedManager] ;
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

// Internet Connectiong Checking Method.
+ (BOOL) checkInternet{
    
    //Test for Internet Connection
    NSString *hostName = @"www.google.com";
    Reachability *r = [Reachability reachabilityWithHostName:hostName];
    
    NetworkStatus internetStatus = [r currentReachabilityStatus];
    
    BOOL internet;
    
    if ((internetStatus != ReachableViaWiFi) && (internetStatus != ReachableViaWWAN)) {
        internet = NO;
    }
    else {
        internet = YES;
    }
    return internet;
}

#pragma mark reachbility code
-(void)checkForReachability
{
    /////////////Reachbility
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(reachabilityChanged:) name: kReachabilityChangedNotification object: nil];
    
    //Change the host name here to change the server your monitoring
    hostReach = [Reachability reachabilityWithHostName: @"www.google.co.in"] ;
    [hostReach startNotifier];
    
    internetReach = [Reachability reachabilityForInternetConnection];
    [internetReach startNotifier];
    
    wifiReach = [Reachability reachabilityForLocalWiFi] ;
    [wifiReach startNotifier];
    
    isConnectionReachable=[self isInternetReachable];
}

//Called by Reachability whenever status changes.
- (void) reachabilityChanged: (NSNotification* )note
{
    Reachability* curReach = [note object];
    if(curReach == hostReach)
    {
        if([curReach isReachable])
        {
//            [InterfaceUtility displayAlertViewWithTitle:@"DataManager" andMessage:@"Internet available"];

            NSString * temp = [NSString stringWithFormat:@"GOOGLE Reachable(%@)", curReach.currentReachabilityString];
            NSLog(@"%@", temp);
        }
        else
        {
            [InterfaceUtility displayAlertViewWithTitle:@"DataManager" andMessage:@"Internet is not available"];

            NSString * temp = [NSString stringWithFormat:@"GOOGLE Unreachable(%@)", curReach.currentReachabilityString];
            NSLog(@"%@", temp);
        }
    }
    else if (curReach == wifiReach){
        if([curReach isReachable])
        {
//            [InterfaceUtility displayAlertViewWithTitle:@"DataManager" andMessage:@"Internet available"];

            NSString * temp = [NSString stringWithFormat:@"LocalWIFI Reachable(%@)", curReach.currentReachabilityString];
            NSLog(@"%@", temp);
        }
        else{
            [InterfaceUtility displayAlertViewWithTitle:@"DataManager" andMessage:@"Internet is not available"];

            NSString * temp = [NSString stringWithFormat:@"LocalWIFI Unreachable(%@)", curReach.currentReachabilityString];
            NSLog(@"%@", temp);

        }
    }
    else if (curReach == internetReach){
        if([curReach isReachable])
        {
//            [InterfaceUtility displayAlertViewWithTitle:@"DataManager" andMessage:@"Internet available"];

            NSString * temp = [NSString stringWithFormat:@"InternetConnection Reachable(%@)", curReach.currentReachabilityString];
             NSLog(@"%@", temp);
        }
        else{
            [InterfaceUtility displayAlertViewWithTitle:@"DataManager" andMessage:@"Internet is not available"];

            NSString * temp = [NSString stringWithFormat:@"InternetConnection Unreachable(%@)", curReach.currentReachabilityString];
            NSLog(@"%@", temp);
        }
    }
    
    
   NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
    isConnectionReachable=![self isInternetReachable];
    
 
    
    
}

- (BOOL)isInternetReachable
{
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
    
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr*)&zeroAddress);
    SCNetworkReachabilityFlags flags;
    
    if(reachability == NULL)
        return false;
    
    if (!(SCNetworkReachabilityGetFlags(reachability, &flags)))
        return false;
    
    if ((flags & kSCNetworkReachabilityFlagsReachable) == 0)
        // if target host is not reachable
        return false;
    
    BOOL isReachable = false;
    
    if ((flags & kSCNetworkReachabilityFlagsConnectionRequired) == 0)
    {
        // if target host is reachable and no connection is required
        //  then we'll assume (for now) that your on Wi-Fi
        isReachable = true;
    }
    
    if ((((flags & kSCNetworkReachabilityFlagsConnectionOnDemand ) != 0) ||
         (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0))
    {
        // ... and the connection is on-demand (or on-traffic) if the
        //     calling application is using the CFSocketStream or higher APIs
        
        if ((flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0)
        {
            // ... and no [user] intervention is needed
            isReachable = true;
        }
    }
    
    if ((flags & kSCNetworkReachabilityFlagsIsWWAN) == kSCNetworkReachabilityFlagsIsWWAN)
    {
        // ... but WWAN connections are OK if the calling application
        //     is using the CFNetwork (CFSocketStream?) APIs.
        isReachable = true;
    }
    return isReachable;
}

@end
