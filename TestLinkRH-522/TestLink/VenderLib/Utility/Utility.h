//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
//#import "Globals.h"

@protocol UtilityDelegate;

@interface Utility : NSObject

@property(nonatomic,retain)id<UtilityDelegate> delegate;

+(BOOL)isEmpty:(NSString *)str;
#pragma mark - Setting Check Box Images
//+(void)setCheckBoxImage:(UIImageView *)checkBoxImage;

#pragma mark Setting Radio Button Images
//+(void)setSingleRadioBtnImage:(UIImageView*)radioBtnImage;
//+(void)setMultipleRadioBtnImage:(UIImageView *)firstRadioBtnImage secondRadioBtnImage:(UIImageView *)secondRadioBtnImage thirdRadioBtnImage:(UIImageView *)thirdRadioBtnImage;



#pragma mark email validation
+(BOOL)validateEmail:(NSString*)email;

#pragma mark Date Format Change Method
+(NSString *)getDateFromString:(NSString *)mySstring;

#pragma mark - Setting Language
+(void)setLanguage:(NSString *)languageCode;

#pragma mark - TableView Setting
//+(void)settingTableViewRowSelected:(UITableView *)myTableView selectedRow:(NSInteger)row;


//#pragma mark - TableView Setting
//-(void)shareActionToOtherApp;


#pragma mark - Currency Format
+(NSString*)convertGlobalCurrencyFormat:(double)value;

#pragma mark - Dynamic TextView
+(UITextView *)setTextViewFrame:(UITextView*)myLabel fontSize:(float)size;
+(UILabel *)setlableFrame:(UILabel*)myLabel fontSize:(float)size;

#pragma mark - Date Format Methods
+(NSString *)getStringFromDate:(NSDate *)dateval;


#pragma mark - Date Format1 Methods

+(NSString *)getStringFromString:(NSString *)strVal;


#pragma mark - Internet Checking
+(BOOL)CheckForInternet;

#pragma mark - UILable Text  struck through
+(void)addAttributeToLable:(UILabel *)lable value:(id)value;

#pragma mark - POPUP VIEWCONTROLLER
+ (void)setPresentationStyleForSelfController:(UIViewController *)selfController presentingController:(UIViewController *)presentingController;


#pragma mark - TextField PlaceHolder
+(void)setUITextfieldPlaceHolder:(UITextField *)textfield placeHolderText:(NSString *)strPlaceholder placeHolderColor:(UIColor *)color placeHolderFontName:(NSString *)fontName placeHolderFontSize:(CGFloat)fontSize;


+(NSMutableArray *) groupsWithDuplicatesRemoved:(NSArray *)  groups myKeyParameter:(NSString *)myKeyParameter;

+(UIImage *)resizeImage:(UIImage *)image;
@end

@protocol UtilityDelegate <NSObject>
@required
@end



