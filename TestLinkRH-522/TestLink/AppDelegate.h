//
//  AppDelegate.h
//  TestLink
//
//  Created by Pritesh Pethani on 12/10/16.
//  Copyright © 2016 Pritesh Pethani. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "Constant.h"



@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UINavigationController *nav;

@property (strong, nonatomic) CBCentralManager *manager;

@property (strong, nonatomic) CBPeripheral *peripheral;

@property (strong, nonatomic) NSMutableArray *xAxisValuesFinal, *xAxisDatesValuesFinal, *xAxisScaleValuesFinal;
//@property (strong, nonatomic) CBCentralManager *centralManager;

@end

