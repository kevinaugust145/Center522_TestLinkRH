//
//  Constant.h
//  FestiLove
//
//  Created by Pritesh Pethani on 17/03/16.
//  Copyright © 2016 Pritesh Pethani. All rights reserved.
//

#ifndef Constant_h
#define Constant_h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>



//-----------APP DELEGATE ------------//

#import "AppDelegate.h"


//-----------APPLICATION NAME ------------//
#define Appname @"Testlink"

//---------HELPER CLASSES--------------//

#import "ISChatViewController.h"
#import "HPGrowingTextView.h"
#import "ISControlManager.h"
#import "MFi_DeviceListController.h"
#import "UIActionSheet+BlockExtensions.h"
#import "UIAlertView+BlockExtensions.h"
#import "ISDataPath.h"
#import "ISBLEDataPath.h"
#import "ISSCTableAlertView.h"

#import <QuartzCore/QuartzCore.h>

#import <Charts/Charts-Swift.h>
//---------VIEW CONTROLLER CLASSES--------------//
//HOME VC

//---------OTHER CONSTANT--------------//


#define APPDELEGATE ((AppDelegate *)[[UIApplication sharedApplication] delegate])
#define dataManager ((DataManager *)[DataManager sharedManager])
#define USERDEFAULT ((NSUserDefaults *)[NSUserDefaults standardUserDefaults])

#define B_UI_ORIENTATION_IS_PORTRAIT() UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation)
#define B_UI_ORIENTATION_IS_LANDSCAPE() UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)
//DEVICE HEIGHT

#define SHORT_IPHONE_HEIGHT 480.0f
#define IPHONE_5_HEIGHT 568.0f // includes iPhones 5S and 5C, and iPod 5
#define IPHONE_6_HEIGHT 667.0f
#define IPHONE_6PLUS_HEIGHT 736.0f


// http://stackoverflow.com/a/13156390/246142

//FINDING DEVICE

#define DEVICE_IS_IPAD ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
#define DEVICE_IS_IPHONE ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
#define DEVICE_IS_SHORT_IPHONE (DEVICE_IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == SHORT_IPHONE_HEIGHT)
#define IS_RETINA ([[UIScreen mainScreen] scale] >= 2.0)

// includes iPhones 5S and 5C

#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define SCREEN_MAX_LENGTH (MAX(SCREEN_WIDTH, SCREEN_HEIGHT))
#define SCREEN_MIN_LENGTH (MIN(SCREEN_WIDTH, SCREEN_HEIGHT))


#define IS_IPHONE_4_OR_LESS (DEVICE_IS_IPHONE && SCREEN_MAX_LENGTH < 568.0)

#define DEVICE_IS_IPHONE_5 (DEVICE_IS_IPHONE && SCREEN_MAX_LENGTH == IPHONE_5_HEIGHT)

#define DEVICE_IS_IPHONE_6 (DEVICE_IS_IPHONE && SCREEN_MAX_LENGTH == IPHONE_6_HEIGHT)
#define DEVICE_IS_IPHONE_6PLUS (DEVICE_IS_IPHONE && SCREEN_MAX_LENGTH == IPHONE_6PLUS_HEIGHT)

#define DEVICE_IS_SHORT_IPHONE_or_IPOD (SCREEN_MAX_LENGTH == SHORT_IPHONE_HEIGHT)
#define DEVICE_IS_IPHONE_5_or_IPOD_5 (SCREEN_MAX_LENGTH == IPHONE_5_HEIGHT) // includes iPhones 5S and 5C

#define DEVICE_IS_NON_RETINA ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] && ([UIScreen mainScreen].scale < 2.0))
#define DEVICE_IS_RETINA ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] && ([UIScreen mainScreen].scale == 2.0))
#define DEVICE_IS_RETINA_HD ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] && ([UIScreen mainScreen].scale == 3.0))

/**
 * System Versioning Preprocessor Macros
 * From: http://stackoverflow.com/a/5337804/246142
 */

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)


/**
 * Null, Nil, Empty String macros
 * From: http://koolistov.net/blog/2012/02/26/nil-null-empty-macros/
 */
#define NIL_IF_NULL(foo) ([[NSNull null] isEqual:foo] ? nil : foo)
#define NULL_IF_NIL(foo) ((foo == nil) ? [NSNull null] : foo)
#define EMPTY_IF_NIL(foo) ((foo == nil) ? @"" : foo)
#define EMPTY_IF_NULL(foo) ([[NSNull null] isEqual:foo] ? @"" : foo)



//NEW Constant

/*****************************/
/*   Useful Macro Function   */
/*****************************/

/*  Convert HTML Color Code to UIColor Ex. :0xCECECE    */
#define UIColorFromRGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

/*  Convert HTML Color Code with Alpha Value to UIColor Ex. :0xCECECE and Alpha Value Ex.:0.4   */

#define UIColorFromRGBWithAlpha(rgbValue, a) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:a]

/*  Get UIFont object from Font name and size   */

#define UIFontFromNameAndSize(_name_, _size_) ((UIFont *)[UIFont fontWithName:(NSString *)(_name_) size:(CGFloat)(_size_)])

/*  Get UIFont object from Font name and size seperated by ';'  Ex. : UIFontFromString(@"Arial;10.0f")  */

#define UIFontFromString(fontString) ((UIFont *)[UIFont fontWithName:[fontString componentsSeparatedByString:@";"][0] size:[[fontString componentsSeparatedByString:@";"][1] floatValue]])





#define showValidationAlert(messageT,title,alertTag) UIAlertView *alert=[[UIAlertView alloc] initWithTitle:messageT message:[NSString stringWithFormat:@"%@",title] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:@"cancel", nil];[alert show];alert.cancelButtonIndex = -1;alert.delegate = self;alert.tag = alertTag;
#define showAlert(messageT,title) UIAlertView *alert=[[UIAlertView alloc] initWithTitle:messageT message:title delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];[alert show];

#define showAlertOkAction(messageT,title) UIAlertView *alert=[[UIAlertView alloc] initWithTitle:messageT message:title delegate:nil cancelButtonTitle:@"OK"otherButtonTitles:nil, nil];[alert show];alert.tag = 102;alert.delegate = self;


#define showValidationAlertSettingsButton(messageT,title,alertTag) UIAlertView *alert=[[UIAlertView alloc] initWithTitle:messageT message:[NSString stringWithFormat:@"%@",title] delegate:nil cancelButtonTitle:@"Settings" otherButtonTitles:@"Cancel", nil];[alert show];alert.cancelButtonIndex = -1;alert.delegate = self;alert.tag = alertTag;

#define showValidationAlertCancel(messageT,title,alertTag) UIAlertView *alert=[[UIAlertView alloc] initWithTitle:messageT message:[NSString stringWithFormat:@"%@",title] delegate:nil cancelButtonTitle:@"Yes" otherButtonTitles:@"No", nil];[alert show];alert.cancelButtonIndex = -1;alert.delegate = self;alert.tag = alertTag;




#define FailureAlert @"Oops! Something went wrong. Please try again."

#define RobotoRegularFont @"Roboto-Regular"
#define MuseoSansFont @"MuseoSans"

#define fontAwesome @"FontAwesome"

/*****************************/
/*   Useful Macro Function   */
/*****************************/

//#define MainURL @"http://sc-dev.us-east-1.elasticbeanstalk.com/"

#define MainURL @"http://apidev.socialclinics.com/"
//#define MainURL @"https://api.socialclinics.com/"

#define LoginURL @"http://sc-dev.us-east-1.elasticbeanstalk.com/oauth/token"


#define addPostUrl @"posts"
#define addReviewUrl @"reviews"
#define loginUrl @"oauth/token"
#define logoutUrl @"oauth/revoke"
#define changePasswordUrl @"profile/password"
#define getProfileUrl @"profile"
#define mediaUpload @"session"

#define removeNetworkUrl @"profile/networks"


#define facebookPage @"authorize/facebook"
#define twitterPage @"authorize/twitter"
#define googlePage @"authorize/google"
#define yelpPage @"authorize/yelp"


#define imageUploadApiUrlTag 1001
#define loginApiUrlTag 1002
#define addPostApiUrlTag 1003
#define addReviewApiUrlTag 1004
#define logoutApiUrlTag 1005
#define changePasswordUrlTag 1006
#define getProfileUrlTag 1007
#define gettingImageApiUrlTag 1008

#endif /* Constant_h */
