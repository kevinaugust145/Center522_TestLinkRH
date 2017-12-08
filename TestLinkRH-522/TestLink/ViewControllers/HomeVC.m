//
//  HomeVC.m
//  TestLink
//
//  Created by Pritesh Pethani on 12/10/16.
//  Copyright © 2016 Pritesh Pethani. All rights reserved.
//

#import "HomeVC.h"

#import "ISChatViewController.h"
#import "HPGrowingTextView.h"
#import "ISControlManager.h"
#import "MFi_DeviceListController.h"
#import "UIActionSheet+BlockExtensions.h"
#import "UIAlertView+BlockExtensions.h"
#import "ISDataPath.h"
#import "ISBLEDataPath.h"
#import "ISSCTableAlertView.h"

#import "TestLink-Swift.h"

#import <QuartzCore/QuartzCore.h>
#import "Constant.h"



@interface HomeVC () <ChartViewDelegate>

@property (nonatomic, strong) IBOutlet LineChartView *chartView;
@property (nonatomic, strong) IBOutlet UISlider *sliderX;
@property (nonatomic, strong) IBOutlet UISlider *sliderY;
@property (nonatomic, strong) IBOutlet UITextField *sliderTextX;
@property (nonatomic, strong) IBOutlet UITextField *sliderTextY;

@end

@implementation HomeVC

- (void)viewDidLoad {
    
    [super viewDidLoad];
    ISControlManager *manager = [ISControlManager sharedInstance];
    
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)chartSettingsMethod {
    
}

-(IBAction)btnSkipCliked:(UIButton *)sender
{
    BlueToothOptionVC *obj = [[BlueToothOptionVC alloc]init];
    [self.navigationController pushViewController:obj animated:YES];
}

-(IBAction)btnScanCliked:(UIButton *)sender
{
//    [self isLECapableHardware];
    
    if ([self isLECapableHardware]) {
        
        MasterViewController *obj = [[MasterViewController alloc] init];
        [self.navigationController pushViewController:obj animated:YES];
        
//        MFi_DeviceListController *list = [[MFi_DeviceListController alloc] initWithStyle:UITableViewStyleGrouped];
//        [self.navigationController setNavigationBarHidden:NO];
//        [self.navigationController pushViewController:list animated:YES];
    }
    else{
        //[self openSettings];
    }
    
    
//    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:list];
//    [self presentViewController:nav animated:YES completion:nil];
}

- (BOOL) isLECapableHardware
{
    NSString * state = nil;
    
    switch ([APPDELEGATE.manager state])
    {
        case CBCentralManagerStateUnsupported:
            state = @"The platform/hardware doesn't support Bluetooth Low Energy.";
            break;
        case CBCentralManagerStateUnauthorized:
            state = @"The app is not authorized to use Bluetooth Low Energy.";
            break;
        case CBCentralManagerStatePoweredOff:
            state = @"Bluetooth is currently powered off.";
            break;
        case CBCentralManagerStatePoweredOn:
            NSLog(@"Bluetooth power on");
            return TRUE;
        case CBCentralManagerStateUnknown:
        default:
            return FALSE;
    }
    
    NSLog(@"Central manager state: %@", state);
    
    
    //Commented by Meet
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:Appname  message:state delegate:self cancelButtonTitle:@"Okay" otherButtonTitles: nil];
        [alertView show];
    
    return FALSE;
}

- (void)openSettings
{
    NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
    }

    
    //[[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    
   // [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=WIFI"]];
    
    

    
//    BOOL canOpenSettings = (&UIApplicationOpenSettingsURLString != NULL);
//    if (canOpenSettings) {
//        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
//        [[UIApplication sharedApplication] openURL:url];
//    }
}

@end
