
//
//

#import "Utility.h"

@implementation Utility
@synthesize delegate;

#pragma mark - Setting Check Box Images

//+(void)setCheckBoxImage:(UIImageView *)checkBoxImage{
//    if ([checkBoxImage.image isEqual:[UIImage imageNamed:@"checkbox.png"]]) {
//        checkBoxImage.image = [UIImage imageNamed:@"checkbox-active.png"];
//    }else{
//        checkBoxImage.image = [UIImage imageNamed:@"checkbox.png"];
//    }
//}

#pragma mark Setting Radio Button Images

//+(void)setSingleRadioBtnImage:(UIImageView*)radioBtnImage{
//    if([radioBtnImage.image isEqual:[UIImage imageNamed: @"btn_radio_off_holo_light.png"]]){
//        radioBtnImage.image = [UIImage imageNamed:@"btn_radio_on_holo_light.png"];
//    }else{
//        radioBtnImage.image = [UIImage imageNamed: @"btn_radio_off_holo_light.png"];
//    }
//}

//+(void)setMultipleRadioBtnImage:(UIImageView *)firstRadioBtnImage secondRadioBtnImage:(UIImageView *)secondRadioBtnImage thirdRadioBtnImage:(UIImageView *)thirdRadioBtnImage{
//    
//    firstRadioBtnImage.image = [UIImage imageNamed: @"btn_radio_on_holo_light.png"];
//    secondRadioBtnImage.image = [UIImage imageNamed: @"btn_radio_off_holo_light.png"];
//    thirdRadioBtnImage.image = [UIImage imageNamed: @"btn_radio_off_holo_light.png"];
//}

+(void) set_TopLayout_VesionRelated :(NSLayoutConstraint* )topLayoutConstraint :(UIView*) topView :(UIViewController*)Controller {
    ;
    if (@available(iOS 11, *)) {
        // safe area constraints already set
    }
    else {
        if (topLayoutConstraint) {
            topLayoutConstraint = [topView.topAnchor constraintEqualToAnchor:Controller.topLayoutGuide.topAnchor];
            [topLayoutConstraint setActive:YES];
        }
    }
    
}

#pragma mark email validation

+(BOOL)validateEmail:(NSString*)email{
    
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    BOOL isValid = [emailTest evaluateWithObject:email];
    
    return isValid;
}

#pragma mark String is empty or not

+(BOOL)isEmpty:(NSString *)str
{
    if(str.length==0 || [str isKindOfClass:[NSNull class]] || [str isEqualToString:@""] ||[str  isEqualToString:NULL] || [str isEqualToString:@"(null)"] || str==nil || [str isEqualToString:@"<null>"]  || [str isEqualToString:@"null"]){
        return YES;
    }
    return NO;
}

#pragma mark Date Format Change Method

+(NSString *)getDateFromString:(NSString *)mySstring
{
    
    //NSString * dateString = [NSString stringWithFormat: @"%@",mySstring];
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd/MM/yyyy hh:mm a"];
    //NSDate* myDate = [dateFormatter dateFromString:mySstring];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"EEEE, MMMM dd yyyy, hh:mm a"];
    NSString *stringFromDate = [formatter stringFromDate:[dateFormatter dateFromString:mySstring]];
    
   NSLog(@"%@", stringFromDate);
    return stringFromDate;
}

#pragma mark - Setting Language

+(void)setLanguage:(NSString *)languageCode{
//    English - en
//    Danish - da
//    German - de
//    Swedish - sv
//    Norwegian - nb
    //languageCode = @"en";
    //NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"Localizable" ofType:@"strings" inDirectory:nil forLocalization:languageCode];
    
    //APPDELEGATE.bundle = [[NSBundle alloc] initWithPath:[bundlePath stringByDeletingLastPathComponent]];
    
    //APPDELEGATE.bundle = [NSBundle mainBundle];
    
    //NSLocalizedStringFromTableInBundle(@"login", nil, APPDELEGATE.bundle, nil);
    
    //NSLog(@"%@",[NSString stringWithFormat:NSLocalizedString(@"login", nil)]);
    //NSLog(@"%@",[NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"login", nil, APPDELEGATE.bundle, nil)]);
}

#pragma mark - Setting TableView Row Selected

//+(void)settingTableViewRowSelected:(UITableView *)myTableView selectedRow:(NSInteger)row{
//    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
//    MVYMenuCustomCell *previousSelectedcell =(MVYMenuCustomCell *) [myTableView cellForRowAtIndexPath:APPDELEGATE.selectedIndexpath];
//    previousSelectedcell.lblBGCell.backgroundColor=[UIColor clearColor];
// //   previousSelectedcell.lblMenuFont.backgroundColor=[UIColor whiteColor];
//    
//    
//    MVYMenuCustomCell *cell =(MVYMenuCustomCell *) [myTableView cellForRowAtIndexPath:indexPath];
//    cell.lblBGCell.backgroundColor=[UIColor colorWithRed:(60.0/255.0) green:(2.0/255.0) blue:(2.0/255.0) alpha:0.9];
// //   cell.lblMenuFont.backgroundColor=[UIColor whiteColor];
//    APPDELEGATE.selectedIndexpath=indexPath;
//    
////    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
////    [myTableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
//    
//    //[myTableView.delegate tableView:APP_DELEGATE.menuVC.tableView didSelectRowAtIndexPath:indexPath];
//}


+(NSString*)convertGlobalCurrencyFormat:(double)value{
    
    NSString * convertedString = [NSString stringWithFormat:@"%.2f", value];
    
    NSString * leftPart;
    NSString * rightPart;
    
    if (([convertedString rangeOfString:@"."].location != NSNotFound)) {
        rightPart = [[convertedString componentsSeparatedByString:@"."] objectAtIndex:1];
        leftPart = [[convertedString componentsSeparatedByString:@"."] objectAtIndex:0];
    }else{
//        convertedString = [NSString stringWithFormat:@"%f",value];
//        return convertedString;
    }
    
    //NSLog(@"%d",[leftPart length]);
    NSMutableString *mu = [NSMutableString stringWithString:leftPart];
    
    if ([mu length] > 3) {
        [mu insertString:@"," atIndex:[mu length] - 3];
        //NSLog(@"String is %@ and length is %d", mu, [mu length]);
    }
    
    for (int i=7; i<[mu length]; i=i+4) {
        [mu insertString:@"," atIndex:[mu length] - i];
        //NSLog(@"%d",mu.length);
    }
        
    //    if ([mu length] > 3) {
    //        [mu insertString:@"." atIndex:[mu length] - 3];
    //        //NSLog(@"String is %@ and length is %d", mu, [mu length]);
    //    }
    //    if ([mu length] > 6) {
    //        [mu insertString:@"." atIndex:[mu length] - 6];
    //        //NSLog(@"String is %@ and length is %d", mu, [mu length]);
    //    }
    //    if ([mu length] > 9) {
    //        [mu insertString:@"." atIndex:[mu length] - 9];
    //        //NSLog(@"String is %@ and length is %d", mu, [mu length]);
    //    }
    
    convertedString = [[mu stringByAppendingString:@"."] stringByAppendingString:rightPart];
    
    return convertedString;
}



+(NSString *)getStringFromDate:(NSDate *)dateval
{
    NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
    
    [dateFormater setDateFormat:@"dd/MM/YYYY"];
    NSString *dateString=[dateFormater stringFromDate:dateval];
    return dateString ;
}



+(NSString *)getStringFromString:(NSString *)strVal
{
//        NSDateFormatter *format1 = [[NSDateFormatter alloc] init];
//        [format1 setDateFormat:@"dd/MM/yyyy hh:mm a"];
//        NSDate *date = [format1 dateFromString:strVal];
//        [format1 setDateFormat:@"EEEE, MMMM dd yyyy, hh:mm a"];
//        NSString* finalDateString = [format1 stringFromDate:date];
//        return finalDateString ;
    
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd/MM/yyyy hh:mm a"];
    //NSDate* myDate = [dateFormatter dateFromString:mySstring];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"EEEE, MMMM dd yyyy, hh:mm a"];
    NSString *stringFromDate = [formatter stringFromDate:[dateFormatter dateFromString:strVal]];
    
    NSLog(@"%@", stringFromDate);
    return stringFromDate;


}




#pragma mark - UILable Text  struck through
+(void)addAttributeToLable:(UILabel *)lable value:(id)value{
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:lable.text];
    [attributeString addAttribute:NSStrikethroughStyleAttributeName
                            value:value
                            range:NSMakeRange(0, [attributeString length])];
    lable.attributedText =attributeString;
    

}

#pragma mark - POPUP VIEWCONTROLLER

+ (void)setPresentationStyleForSelfController:(UIViewController *)selfController presentingController:(UIViewController *)presentingController
{
    if ([NSProcessInfo instancesRespondToSelector:@selector(isOperatingSystemAtLeastVersion:)])
    {
        //iOS 8.0 and above
        presentingController.providesPresentationContextTransitionStyle = YES;
        presentingController.definesPresentationContext = YES;
        
        [presentingController setModalPresentationStyle:UIModalPresentationOverCurrentContext];
    }
    else
    {
        [selfController setModalPresentationStyle:UIModalPresentationCurrentContext];
        [selfController.navigationController setModalPresentationStyle:UIModalPresentationCurrentContext];
    }
}

+(void)setUITextfieldPlaceHolder:(UITextField *)textfield placeHolderText:(NSString *)strPlaceholder placeHolderColor:(UIColor *)color placeHolderFontName:(NSString *)fontName placeHolderFontSize:(CGFloat)fontSize {
    textfield.attributedPlaceholder =
    [[NSAttributedString alloc]
     initWithString:  strPlaceholder
     attributes:@{
                  NSForegroundColorAttributeName: color,
                //  NSFontAttributeName: [UIFont fontWithName:fontName size:fontSize]
                  }];
    
}

+(NSMutableArray *) groupsWithDuplicatesRemoved:(NSArray *)  groups myKeyParameter:(NSString *)myKeyParameter {
    NSMutableArray * groupsFiltered = [[NSMutableArray alloc] init];    //This will be the array of groups you need
    NSMutableArray * groupNamesEncountered = [[NSMutableArray alloc] init]; //This is an array of group names seen so far
    
    NSString * name;        //Preallocation of group name
    for (NSDictionary * group in groups) {  //Iterate through all groups
        name =[group objectForKey:myKeyParameter]; //Get the group name
        if ([groupNamesEncountered indexOfObject: name]==NSNotFound) {  //Check if this group name hasn't been encountered before
            [groupNamesEncountered addObject:name]; //Now you've encountered it, so add it to the list of encountered names
            [groupsFiltered addObject:group];   //And add the group to the list, as this is the first time it's encountered
        }
    }
    return groupsFiltered;
}

+(UILabel *)setlableFrame:(UILabel*)myLabel fontSize:(float)size
{
    
    // CGSize possibleSize = [myLabel.text sizeWithFont:[UIFont fontWithName:RobotoRegularFont size:size] constrainedToSize:CGSizeMake(myLabel.frame.size.width, 9999) lineBreakMode:NSLineBreakByWordWrapping];
    
    
    CGRect textRect = [myLabel.text boundingRectWithSize:CGSizeMake(myLabel.frame.size.width, 9999)
                                                 options:NSStringDrawingUsesLineFragmentOrigin
                                              attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14.0]}
                                                 context:nil];
    
    CGSize possibleSize = textRect.size;
    
    
    CGRect newFrame = myLabel.frame;
    //myLabel.backgroundColor = [UIColor redColor];
    newFrame.size.height = possibleSize.height;
    //NSLog(@"Height of label %f",newFrame.size.height);
    //NSLog(@"Length of text %lu",(unsigned long)myLabel.text.length);
    myLabel.frame = newFrame;
    return myLabel;
}

+(UIImage *)resizeImage:(UIImage *)image
{
    float actualHeight = image.size.height;
    float actualWidth = image.size.width;
    float maxHeight = 640.0;
    float maxWidth = 640.0;
    float imgRatio = actualWidth/actualHeight;
    float maxRatio = maxWidth/maxHeight;
    float compressionQuality = 0.5;//50 percent compression
    
    if (actualHeight > maxHeight || actualWidth > maxWidth)
    {
        if(imgRatio < maxRatio)
        {
            //adjust width according to maxHeight
            imgRatio = maxHeight / actualHeight;
            actualWidth = imgRatio * actualWidth;
            actualHeight = maxHeight;
        }
        else if(imgRatio > maxRatio)
        {
            //adjust height according to maxWidth
            imgRatio = maxWidth / actualWidth;
            actualHeight = imgRatio * actualHeight;
            actualWidth = maxWidth;
        }
        else
        {
            actualHeight = maxHeight;
            actualWidth = maxWidth;
        }
    }
    
    CGRect rect = CGRectMake(0.0, 0.0, actualWidth, actualHeight);
    UIGraphicsBeginImageContext(rect.size);
    [image drawInRect:rect];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    NSData *imageData = UIImageJPEGRepresentation(img, compressionQuality);
    UIGraphicsEndImageContext();
    
    return [UIImage imageWithData:imageData];
    
}

@end

