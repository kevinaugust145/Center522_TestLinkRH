//
//  DataManager.h
//  Product Catalog
//
//  Created by Bhoomi Jagani on 25/11/14.
//  Copyright (c) 2014 Urvesh Patel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Reachability.h"
@interface DataManager : NSObject
{
    Reachability* hostReach;
    Reachability* internetReach;
    Reachability* wifiReach;

}
#pragma mark Singleton Methods
@property(nonatomic,assign)BOOL isConnectionReachable;

+ (id)sharedManager;
-(void)checkForReachability;
+ (BOOL) checkInternet;

@end
