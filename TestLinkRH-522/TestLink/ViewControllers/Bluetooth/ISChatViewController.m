//
//  ISChatViewController.m
//  MFi_SPP
//
//  Created by Rick on 13/11/11.
//
//

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

typedef enum {
	MFi_SPPViewController_RawMode = 0,
	MFi_SPPViewController_HexMode = 1,
	MFi_SPPViewController_LoopbackMode =2,
    MFi_SPPViewController_TimerMode =3
}MFi_SPPViewController_Mode;

@interface UIImage (colorImage)
+ (UIImage *) imageFromColor:(UIColor *)color;
@end
@implementation UIImage(colorImage)

+ (UIImage *) imageFromColor:(UIColor *)color {
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

@end

@interface ISString:NSObject
@property (assign,nonatomic) BOOL remote;
@property (assign,nonatomic) BOOL systemLog;
@property (retain,nonatomic) NSString *string;
@end

@implementation ISString
- (id)init {
    self = [super init];
    if (self) {
        _remote = NO;
        _systemLog = NO;
    }
    return self;
}
@end

@interface NSString (hexAddon)
+ (NSString *)convertHexToRaw:(NSString *)hexString;
+ (NSString *)convertRawToHex:(NSString *)rawString;

@end

@implementation NSString (hexAddon)
+ (NSString *)convertHexToRaw:(NSString *)hexString
{
	NSMutableString *rawString = [NSMutableString string];
	@try {
		NSUInteger location = 0;
		NSString *substring;
		unsigned intValue;
		while (1) {
			substring = [hexString substringWithRange:NSMakeRange(location, 2)];
			location+=3;
			NSScanner *scanner = [NSScanner scannerWithString:[NSString stringWithFormat:@"0x%@", substring]];
			if ([scanner scanHexInt:&intValue]) {
				char charValue[2] = {0};
				charValue[0] = intValue;
				[rawString appendString:[NSString stringWithCString:charValue encoding:NSMacOSRomanStringEncoding]];
			}
			if (location >= [hexString length]) {
				break;
			}
		}
	}
	@catch (NSException * e) {
		
	}
	return rawString;
}

+ (NSString *)convertRawToHex:(NSString *)rawString
{
	NSMutableString *hexString = [NSMutableString string];
	const unsigned char * asciiString = (const unsigned char *)[rawString cStringUsingEncoding:NSMacOSRomanStringEncoding];
	if (asciiString) {
		while (*asciiString != 0) {
			[hexString appendFormat:@"%02X ", *asciiString];
			asciiString++;
		}
	}
	return hexString;
}
@end

@interface ISChatViewController () <HPGrowingTextViewDelegate,UIScrollViewDelegate,TableAlertViewDelegate> {
    UIView *containerView;
    HPGrowingTextView *textView;
    BOOL showSetting;
    BOOL showKeyboard;
    UIView *settingView;
    UIPageControl *pageNumber;
    UIWebView *web;
    UILabel *statusLabel;
    UILabel *connectDevices;
    NSFileManager *fileManager;
    NSMutableArray *dirArray;
    NSMutableArray *_datas;
    MFi_SPPViewController_Mode mode;
    NSMutableArray *modeButton;
    BOOL checkProtocol;
    BOOL manualUpperProtocol;
    NSMutableString *content;
    UIButton *cancelButton;
    long fileReadOffset;
    BOOL writeAllowFlag;
    BOOL myTextView;
    
    NSString *txPath;
    float timer_second;
    NSInteger pattern_length;
    NSInteger pattern_times;
    NSTimer *_timer;
    int testPattenCount;

    NSTimeInterval startTime;
    NSTimeInterval endTime;
    
    BOOL allowReload;
    
    NSMutableArray *_loopBackQueue;


}
@property (retain) NSString *comparedPath;

@end

@implementation ISChatViewController
@synthesize comparedPath;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(keyboardWillShow:)
													 name:UIKeyboardWillShowNotification
												   object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(keyboardWillHide:)
													 name:UIKeyboardWillHideNotification
												   object:nil];
        showSetting = NO;
        showKeyboard = NO;
        self.wantsFullScreenLayout = YES;
        _datas = [[NSMutableArray alloc] init];
        mode = MFi_SPPViewController_RawMode;
        modeButton = [[NSMutableArray alloc] init];
        myTextView = NO;
        content = [[NSMutableString alloc] init];
        startTime = 0;
        allowReload = YES;
        _loopBackQueue = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithRed:219.0f/255.0f green:226.0f/255.0f blue:237.0f/255.0f alpha:1];
    [[ISControlManager sharedInstance] setDelegate:self];

    UIImageView *logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ISSC_logo"]];
    logo.frame = CGRectMake(5.0f, 25.0f, logo.frame.size.width, logo.frame.size.height);
    [self.view addSubview:logo];
    connectDevices = [[UILabel alloc] initWithFrame:CGRectMake(5.0f, logo.frame.origin.y+logo.frame.size.height, 310.0f, 20.0f)];
    connectDevices.backgroundColor = [UIColor clearColor];
    connectDevices.adjustsFontSizeToFitWidth = YES;
    [self.view addSubview:connectDevices];
    
    statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(logo.frame.size.width + 10.0f, 32.0f, 180.0f, 20.0f)];
    statusLabel.backgroundColor = [UIColor clearColor];
    statusLabel.textAlignment = NSTextAlignmentCenter;
    statusLabel.text = @"Disconnected";
    statusLabel.textColor = [UIColor redColor];
    [self.view addSubview:statusLabel];
    UIButton *connect = [UIButton buttonWithType:UIButtonTypeCustom];
    connect.frame = CGRectMake(statusLabel.frame.origin.x + statusLabel.frame.size.width +0.0f, 32.0f, 35.0f, 35.0f);
    [connect setBackgroundImage:[UIImage imageNamed:@"Connect_To"] forState:UIControlStateNormal];
    [connect addTarget:self action:@selector(scanDevices:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:connect];
    
    
    containerView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 40, 320, 40)];
    
	textView = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(36, 3, 210, 40)];
    textView.isScrollable = NO;
    textView.contentInset = UIEdgeInsetsMake(0, 5, 0, 5);
    
	textView.minNumberOfLines = 1;
	textView.maxNumberOfLines = 2;
	textView.returnKeyType = UIReturnKeySend;
    textView.keyboardType = UIKeyboardTypeASCIICapable;
	textView.font = [UIFont systemFontOfSize:15.0f];
	textView.delegate = self;
    textView.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(5, 0, 5, 0);
    textView.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:containerView];
	
    UIImage *rawEntryBackground = [UIImage imageNamed:@"MessageEntryInputField.png"];
    UIImage *entryBackground = [rawEntryBackground stretchableImageWithLeftCapWidth:13 topCapHeight:22];
    UIImageView *entryImageView = [[UIImageView alloc] initWithImage:entryBackground];
    entryImageView.frame = CGRectMake(35, 0, 218, 40);
    entryImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    UIImage *rawBackground = [UIImage imageNamed:@"MessageEntryBackground.png"];
    UIImage *background = [rawBackground stretchableImageWithLeftCapWidth:13 topCapHeight:22];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:background];
    imageView.frame = CGRectMake(0, 0, containerView.frame.size.width, containerView.frame.size.height);
    imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    textView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    // view hierachy
    [containerView addSubview:imageView];
    [containerView addSubview:textView];
    [containerView addSubview:entryImageView];
    
    UIImage *sendBtnBackground = [[UIImage imageNamed:@"MessageEntrySendButton.png"] stretchableImageWithLeftCapWidth:13 topCapHeight:0];
    UIImage *selectedSendBtnBackground = [[UIImage imageNamed:@"MessageEntrySendButton.png"] stretchableImageWithLeftCapWidth:13 topCapHeight:0];
    
	UIButton *doneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
	doneBtn.frame = CGRectMake(containerView.frame.size.width - 69, 8, 63, 27);
    doneBtn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
	[doneBtn setTitle:@"Done" forState:UIControlStateNormal];
    
    [doneBtn setTitleShadowColor:[UIColor colorWithWhite:0 alpha:0.4] forState:UIControlStateNormal];
    doneBtn.titleLabel.shadowOffset = CGSizeMake (0.0, -1.0);
    doneBtn.titleLabel.font = [UIFont boldSystemFontOfSize:18.0f];
    
    [doneBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[doneBtn addTarget:self action:@selector(hideSetting:) forControlEvents:UIControlEventTouchUpInside];
    [doneBtn setBackgroundImage:sendBtnBackground forState:UIControlStateNormal];
    [doneBtn setBackgroundImage:selectedSendBtnBackground forState:UIControlStateSelected];
	[containerView addSubview:doneBtn];
    containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    
    UIButton *setting = [UIButton buttonWithType:UIButtonTypeCustom];
    [setting setBackgroundImage:[UIImage imageNamed:@"setting"] forState:UIControlStateNormal];
    setting.frame = CGRectMake(3.0f, 5.0f, 30.0f, 30.0f);
    [containerView addSubview:setting];
    [setting addTarget:self action:@selector(showSetting:) forControlEvents:UIControlEventTouchUpInside];
    
    settingView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, self.view.bounds.size.height, self.view.bounds.size.width, 216.0f)];
    settingView.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:settingView];
    
    UIScrollView *settingScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0f, 2.0f, 320.0f, 200.0f)];
    settingScroll.contentSize = CGSizeMake(320.0f*2, 200.0f);
    [settingView addSubview:settingScroll];
    settingScroll.showsHorizontalScrollIndicator = NO;
    settingScroll.delegate = self;
    settingScroll.pagingEnabled = YES;
    
    web = [[UIWebView alloc] initWithFrame:CGRectMake(5.0f, connectDevices.frame.origin.y+connectDevices.frame.size.height +5.0f, 310.0f, self.view.frame.size.height - (connectDevices.frame.origin.y+connectDevices.frame.size.height +5.0f) - (containerView.frame.size.height+5.0f))];
    [self.view insertSubview:web belowSubview:containerView];
    web.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    web.backgroundColor = [UIColor whiteColor];
    web.dataDetectorTypes = UIDataDetectorTypeNone;
    web.opaque = NO;
    web.delegate = self;
    
    UIImage *normalBG = [UIImage imageFromColor:[UIColor colorWithRed:52.0f/255.0f green:152.0f/255.0f blue:219.0f/255.0f alpha:1.0f]];
    UIImage *selectBG = [UIImage imageFromColor:[UIColor colorWithRed:52.0f/255.0f green:136.0f/255.0f blue:194.0f/255.0f alpha:1.0f]];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(60.0f, 0.0f, 100.0f, 100.0f);
    [button setTitle:@"Raw" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [button setBackgroundImage:normalBG forState:UIControlStateNormal];
    [button setBackgroundImage:selectBG forState:UIControlStateHighlighted];
    button.layer.borderColor = [UIColor colorWithRed:52.0f/255.0f green:136.0f/255.0f blue:194.0f/255.0f alpha:1.0f].CGColor;
    button.layer.borderWidth = 1.0f;
    button.highlighted = YES;
    [button addTarget:self action:@selector(setMode:) forControlEvents:UIControlEventTouchUpInside];
    [settingScroll addSubview:button];
    button.tag = MFi_SPPViewController_RawMode;
    [modeButton addObject:button];
    
    button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(159.0f, 0.0f, 100.0f, 100.0f);
    [button setTitle:@"Hex" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [button setBackgroundImage:normalBG forState:UIControlStateNormal];
    [button setBackgroundImage:selectBG forState:UIControlStateHighlighted];
    button.layer.borderColor = [UIColor colorWithRed:52.0f/255.0f green:136.0f/255.0f blue:194.0f/255.0f alpha:1.0f].CGColor;
    button.layer.borderWidth = 1.0f;
    [button addTarget:self action:@selector(setMode:) forControlEvents:UIControlEventTouchUpInside];
    [settingScroll addSubview:button];
    button.tag = MFi_SPPViewController_HexMode;
    [modeButton addObject:button];

    button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(60.0f, 99.0f, 100.0f, 100.0f);
    [button setTitle:@"Loop" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [button setBackgroundImage:normalBG forState:UIControlStateNormal];
    [button setBackgroundImage:selectBG forState:UIControlStateHighlighted];
    button.layer.borderColor = [UIColor colorWithRed:52.0f/255.0f green:136.0f/255.0f blue:194.0f/255.0f alpha:1.0f].CGColor;
    button.layer.borderWidth = 1.0f;
    [button addTarget:self action:@selector(setMode:) forControlEvents:UIControlEventTouchUpInside];
    [settingScroll addSubview:button];
    button.tag = MFi_SPPViewController_LoopbackMode;
    [modeButton addObject:button];

    button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(159.0f, 99.0f, 100.0f, 100.0f);
    [button setTitle:@"Timer" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [button setBackgroundImage:normalBG forState:UIControlStateNormal];
    [button setBackgroundImage:selectBG forState:UIControlStateHighlighted];
    button.layer.borderColor = [UIColor colorWithRed:52.0f/255.0f green:136.0f/255.0f blue:194.0f/255.0f alpha:1.0f].CGColor;
    button.layer.borderWidth = 1.0f;
    [button addTarget:self action:@selector(setMode:) forControlEvents:UIControlEventTouchUpInside];
    [settingScroll addSubview:button];
    button.tag = MFi_SPPViewController_TimerMode;
    [modeButton addObject:button];

    button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(320.0f+10.0f, 0.0f, 100.0f, 100.0f);
    [button setTitle:@"Compare" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [button setBackgroundImage:normalBG forState:UIControlStateNormal];
    [button setBackgroundImage:selectBG forState:UIControlStateHighlighted];
    button.layer.borderColor = [UIColor colorWithRed:52.0f/255.0f green:136.0f/255.0f blue:194.0f/255.0f alpha:1.0f].CGColor;
    button.layer.borderWidth = 1.0f;
    [button addTarget:self action:@selector(selectCompareFile) forControlEvents:UIControlEventTouchUpInside];
    [settingScroll addSubview:button];
    
    button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(320.0f + 109.0f, 0.0f, 100.0f, 100.0f);
    [button setTitle:@"TX File" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [button setBackgroundImage:normalBG forState:UIControlStateNormal];
    [button setBackgroundImage:selectBG forState:UIControlStateHighlighted];
    button.layer.borderColor = [UIColor colorWithRed:52.0f/255.0f green:136.0f/255.0f blue:194.0f/255.0f alpha:1.0f].CGColor;
    button.layer.borderWidth = 1.0f;
    [button addTarget:self action:@selector(selectTxFile) forControlEvents:UIControlEventTouchUpInside];
    [settingScroll addSubview:button];
    
    button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(320.0f +10.0f, 99.0f, 100.0f, 100.0f);
    [button setTitle:@"Clear" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [button setBackgroundImage:normalBG forState:UIControlStateNormal];
    [button setBackgroundImage:selectBG forState:UIControlStateHighlighted];
    button.layer.borderColor = [UIColor colorWithRed:52.0f/255.0f green:136.0f/255.0f blue:194.0f/255.0f alpha:1.0f].CGColor;
    button.layer.borderWidth = 1.0f;
    [button addTarget:self action:@selector(clearViewText:) forControlEvents:UIControlEventTouchUpInside];
    [settingScroll addSubview:button];
    
    /*button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(320.0f + 109.0f, 99.0f, 100.0f, 100.0f);
    [button setTitle:@"MTU" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [button setBackgroundImage:normalBG forState:UIControlStateNormal];
    [button setBackgroundImage:selectBG forState:UIControlStateHighlighted];
    button.layer.borderColor = [UIColor colorWithRed:52.0f/255.0f green:136.0f/255.0f blue:194.0f/255.0f alpha:1.0f].CGColor;
    button.layer.borderWidth = 1.0f;
    [button addTarget:self action:@selector(setMTU:) forControlEvents:UIControlEventTouchUpInside];
    [settingScroll addSubview:button];*/

    button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(320.0f + 208.0f, 0.0f, 100.0f, 100.0f);
    [button setTitle:@"Save" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [button setBackgroundImage:normalBG forState:UIControlStateNormal];
    [button setBackgroundImage:selectBG forState:UIControlStateHighlighted];
    button.layer.borderColor = [UIColor colorWithRed:52.0f/255.0f green:136.0f/255.0f blue:194.0f/255.0f alpha:1.0f].CGColor;
    button.layer.borderWidth = 1.0f;
    [button addTarget:self action:@selector(save) forControlEvents:UIControlEventTouchUpInside];
    [settingScroll addSubview:button];

    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    if (![def objectForKey:@"writeWithResponse"]) {
        [def setBool:YES forKey:@"writeWithResponse"];
        [def synchronize];
    }

    button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(320.0f + 109.0f, 99.0f, 100.0f, 100.0f);
    [button setTitle:[def boolForKey:@"writeWithResponse"]?@"With Response (BLE Only)":@"Reliable Burst Transmit (BLE Only)" forState:UIControlStateNormal];
    [button.titleLabel setNumberOfLines:0];
    [button.titleLabel sizeToFit];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [button setBackgroundImage:normalBG forState:UIControlStateNormal];
    [button setBackgroundImage:selectBG forState:UIControlStateHighlighted];
    button.layer.borderColor = [UIColor colorWithRed:52.0f/255.0f green:136.0f/255.0f blue:194.0f/255.0f alpha:1.0f].CGColor;
    button.layer.borderWidth = 1.0f;
    [button addTarget:self action:@selector(writeWithResponse:) forControlEvents:UIControlEventTouchUpInside];
    [settingScroll addSubview:button];

     button = [UIButton buttonWithType:UIButtonTypeCustom];
     button.frame = CGRectMake(320.0f + 208.0f, 99.0f, 100.0f, 100.0f);
     [button setTitle:@"Device info" forState:UIControlStateNormal];
     [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
     [button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
     [button setBackgroundImage:normalBG forState:UIControlStateNormal];
     [button setBackgroundImage:selectBG forState:UIControlStateHighlighted];
     button.layer.borderColor = [UIColor colorWithRed:52.0f/255.0f green:136.0f/255.0f blue:194.0f/255.0f alpha:1.0f].CGColor;
     button.layer.borderWidth = 1.0f;
     [button addTarget:self action:@selector(showInfo:) forControlEvents:UIControlEventTouchUpInside];
     [settingScroll addSubview:button];

    pageNumber = [[UIPageControl alloc] initWithFrame:CGRectMake(0.0f, 200.0f, 320.0f, 16.0f)];
    pageNumber.numberOfPages = 2;
    pageNumber.currentPage = 0;
    [settingView addSubview:pageNumber];
    
    UILabel *version = [[UILabel alloc] initWithFrame:CGRectMake(5.0f, 50.0f, 50.0f, 100.0f)];
    version.numberOfLines = 0;
    version.font = [UIFont systemFontOfSize:[UIFont smallSystemFontSize]];
    version.textAlignment = NSTextAlignmentCenter;
    version.backgroundColor = [UIColor clearColor];
    version.text = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
    [settingScroll addSubview:version];
    
    fileManager = [NSFileManager defaultManager];
    
    NSString *path = [[NSBundle mainBundle] resourcePath];
    //NSString *path = [[NSString alloc] initWithFormat:@"%@/%@.app",NSHomeDirectory(), [[[NSBundle mainBundle] infoDictionary]   objectForKey:@"CFBundleName"]];
    NSDirectoryEnumerator *dirEnumerator = [fileManager enumeratorAtPath: path];
    
    dirArray = [[NSMutableArray alloc] init];
    
    NSString *currentFile;
    while (currentFile = [dirEnumerator nextObject]) {
        NSRange range = [currentFile rangeOfString:@".txt"];
        if (range.location != NSNotFound) {
            [dirArray addObject:currentFile];
        }
    }
    if ([dirArray count] == 0) {
        [dirArray addObject:@"No File"];
    }
    NSLog(@"dirarray count = %lu", (unsigned long)[dirArray count]);
    cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelButton.frame = CGRectMake(250.0f, logo.frame.origin.y+logo.frame.size.height, 70.0f, 20.0f);
    [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    cancelButton.hidden = YES;
    [cancelButton addTarget:self action:@selector(cancelSendingData:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cancelButton];
    if ([[ISControlManager sharedInstance] isConnect]) {
        for (ISDataPath *device in [[ISControlManager sharedInstance] connectedAccessory]) {
            [self accessoryDidConnect:device];
        }
    }
    
}

- (void)dealloc {
    [[ISControlManager sharedInstance] disconnectAllDevices];
}
- (void)scanDevices:(id)sender {
    UIActionSheet *act = [[UIActionSheet alloc] initWithTitle:@"Choose BT Type" completionBlock:
                          ^(NSUInteger buttonIndex, UIActionSheet *actionSheet) {
                              switch (buttonIndex) {
                                  case 0: // MFi
                                      [[ISControlManager sharedInstance] scanDeviceList:ISControlManagerTypeEA];
                                      break;
                                  case 1:  {// BLE
                                      MFi_DeviceListController *list = [[MFi_DeviceListController alloc] initWithStyle:UITableViewStyleGrouped];
                                      UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:list];
                                      [self presentViewController:nav animated:YES completion:nil];
                                  }
                                      break;
                                  default:
                                      break;
                              }
                          }
                                            cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"MFi",@"BLE",nil];
    [act showInView:self.view];
}

-(void)resignTextView
{
	[textView resignFirstResponder];
}

- (NSString *)compileOutputToHTML
{
	NSString *htmlBody = @"<html><head><title>viWave</title></head><body> \
    %@ \
    </body></html>";
	
	NSEnumerator *enumerator = [_datas objectEnumerator];
	ISString *message = [enumerator nextObject];
	NSMutableString *newContent = [NSMutableString string];
	//while (message = [enumerator nextObject]) {
	while (message) {
		if (message.remote) {
			[newContent appendString:@"<span style=\"color:red\">"];
		}else if (message.systemLog) {
			[newContent appendString:@"<span style=\"color:blue\">"];
		}else {
			[newContent appendString:@"<span>"];
		}
        
		if ((mode == MFi_SPPViewController_RawMode) || (mode == MFi_SPPViewController_TimerMode) || (message.systemLog)) {
			[newContent appendFormat:@"%@\n", message.string];
		}
		else if (mode == MFi_SPPViewController_LoopbackMode)
		{
			//[newContent appendFormat:@"%@\n", data];//temp solution for loop back mode
		}
		else {
			[newContent appendFormat:@"%@\n", [NSString convertRawToHex:message.string]];
		}
		[newContent appendString:@"</span>"];
		[newContent appendString:@"<br/>"];
        message = [enumerator nextObject];
	}
	return [NSString stringWithFormat:htmlBody, newContent];
}

- (void)reloadOutputView {
    if (allowReload) {
        [web loadHTMLString:[self compileOutputToHTML] baseURL:nil];
        allowReload = NO;
        double delayInSeconds = 1.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            allowReload = YES;
            [web loadHTMLString:[self compileOutputToHTML] baseURL:nil];
        });
    }
	// TODO implement scrollsToBottomAnimated
}

- (void)selectCompareFile {
    ISSCTableAlertView  *alert = [[ISSCTableAlertView alloc] initWithCaller:self data:dirArray title:@"Select a file to compare" buttonTitle:@"Don't compare" andContext:@"Compare"];
    [alert show];
}

- (void)selectTxFile {
    ISSCTableAlertView  *alert = [[ISSCTableAlertView alloc] initWithCaller:self data:dirArray title:@"Tx File" buttonTitle:@"Cancel" andContext:@"TxFile"] ;
    [alert show];
}

-(void) writeFile {
    //  NSLog(@"DataTransparentViewController] writeFile");
    if (!txPath)
        return;
    NSFileHandle *fileHandleRead = [NSFileHandle fileHandleForReadingAtPath:txPath];
    if (fileHandleRead == nil) {
        NSLog(@"open file fail");
    }
    NSData *data;
    //[fileHandleRead seekToFileOffset:fileReadOffset];
    data = [fileHandleRead readDataToEndOfFile];
    
    if ([data length]) {
        fileReadOffset += [data length];
        NSLog(@"offset = %ld",fileReadOffset);
        [[ISControlManager sharedInstance] writeData:data];
        ISString *tmp = [[ISString alloc] init];
        tmp.string = [[NSString alloc] initWithFormat:@"Writing file, Tx bytes = %ld", fileReadOffset];
        tmp.systemLog = YES;
        [self reloadOutputView];
    }
    //[data release];
    [fileHandleRead closeFile];
}

- (void)writeWithResponse:(UIButton *)sender {
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def setBool:![def boolForKey:@"writeWithResponse"] forKey:@"writeWithResponse"];
    [def synchronize];
    [self cancelSendingData:sender];
    if ([def boolForKey:@"writeWithResponse"]) {
        [sender setTitle:@"With Response (BLE Only)" forState:UIControlStateNormal];
    }
    else {
        [sender setTitle:@"Reliable Burst Transmit (BLE Only)" forState:UIControlStateNormal];
    }
}

- (void)setMode:(UIButton *)sender {
    if (mode!=sender.tag) {
        [self cancelSendingData:sender];
        if (sender.tag == MFi_SPPViewController_TimerMode && ![[ISControlManager sharedInstance] isConnect]) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Connection alert"  message:@"No connection" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: nil];
            [alertView show];
            return;
        }
        mode = (MFi_SPPViewController_Mode)sender.tag;
        [self reloadOutputView];
        if (mode == MFi_SPPViewController_LoopbackMode) {
            textView.internalTextView.editable = NO;
            if ([textView.internalTextView respondsToSelector:@selector(isSelectable)]) {
                textView.internalTextView.selectable = NO;
            }
            [_loopBackQueue removeAllObjects];
        }
        else if (mode == MFi_SPPViewController_TimerMode) {
            testPattenCount = 0;
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Input delta time between patterns" message:@"unit:ms" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK",nil];
            alert.alertViewStyle = UIAlertViewStylePlainTextInput;
            alert.tag = 1;
            [alert show];
        }
        else {
            textView.internalTextView.editable = YES;
            if ([textView.internalTextView respondsToSelector:@selector(isSelectable)]) {
                textView.internalTextView.selectable = YES;
            }
        }
    }
    else if (mode == MFi_SPPViewController_TimerMode) {
        testPattenCount = 0;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Input delta time between patterns" message:@"unit:ms" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK",nil];
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        alert.tag = 1;
        [alert show];
    }
    for (UIButton *but in modeButton) {
        if (but != sender) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0), dispatch_get_main_queue(), ^{
            [but setHighlighted:NO];
            });
        }
        else {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0), dispatch_get_main_queue(), ^{
            [but setHighlighted:YES];
            });
        }
    }
}

- (void)sendData:(NSString *)data{
	NSString *rawString = NULL;
 	if (mode == MFi_SPPViewController_RawMode) {
 		rawString = data;
	}
	else if (mode == MFi_SPPViewController_LoopbackMode)
	{
		rawString = data;
	}
	else {
		rawString = [NSString convertHexToRaw:data];
	}
    ISString *tmp = [[ISString alloc] init];
    tmp.string = rawString;
    tmp.remote = NO;
	[_datas addObject:tmp];
    [[ISControlManager sharedInstance] writeData:[rawString dataUsingEncoding:NSMacOSRomanStringEncoding]];
    [self reloadOutputView];
}

- (void)cancelSendingData:(id)sender {
    if (mode == MFi_SPPViewController_TimerMode) {
        if (_timer != nil) {
            [_timer invalidate];
            _timer = nil;
        }
    }
    [[ISControlManager sharedInstance] cancelWriteData];
    if (txPath) {
        txPath = nil;
    }
    cancelButton.hidden = YES;
}

- (void)scrollViewDidScroll:(UIScrollView *)sender {
    CGFloat width = sender.frame.size.width;
    NSInteger currentPage = ((sender.contentOffset.x - width / 2) / width) + 1;
    [pageNumber setCurrentPage:currentPage];
}

//Code from Brett Schumann
-(void) keyboardWillShow:(NSNotification *)note{
    // get keyboard size and loctaion
	CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // Need to translate the bounds to account for rotation.
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    
	// get a rect for the textView frame
	CGRect containerFrame = containerView.frame;
    containerFrame.origin.y = self.view.bounds.size.height - (keyboardBounds.size.height + containerFrame.size.height);
	// animations settings
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
	
	// set views with new info
	containerView.frame = containerFrame;
    settingView.frame = CGRectMake(0.0f, containerView.frame.origin.y+containerView.frame.size.height, settingView.frame.size.width, settingView.frame.size.height);
    web.frame = CGRectMake(web.frame.origin.x, web.frame.origin.y, 310.0f, containerView.frame.origin.y - web.frame.origin.y - 5.0f);
	
	// commit animations
	[UIView commitAnimations];
    showKeyboard = YES;
    //showSetting = NO;
}

-(void) keyboardWillHide:(NSNotification *)note{
    if (!myTextView) {
        return;
    }
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    CGFloat size;
    if (showSetting) {
        size = 0.0f;
    }
    else {
        size = 216.0f;
    }
	// get a rect for the textView frame
	CGRect containerFrame = containerView.frame;
    containerFrame.origin.y = self.view.bounds.size.height - (size + containerFrame.size.height);
	
	// animations settings
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
	// set views with new info
	containerView.frame = containerFrame;
    settingView.frame = CGRectMake(0.0f, containerView.frame.origin.y+containerView.frame.size.height, settingView.frame.size.width, settingView.frame.size.height);
    web.frame = CGRectMake(web.frame.origin.x, web.frame.origin.y, 310.0f, containerView.frame.origin.y - web.frame.origin.y - 5.0f);

	// commit animations
	[UIView commitAnimations];
    showKeyboard = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showSetting:(UIButton *)sender {
    CGFloat size;
    /*if (showSetting) {
        size = 0.0f;
    }
    else {*/
        size = 216.0f;
    //}
    CGRect containerFrame = containerView.frame;
    containerFrame.origin.y = self.view.bounds.size.height - (size + containerFrame.size.height);
    if (showKeyboard) {
        [self resignTextView];
        containerView.frame = containerFrame;
        settingView.frame = CGRectMake(0.0f, containerView.frame.origin.y+containerView.frame.size.height, settingView.frame.size.width, settingView.frame.size.height);
        web.frame = CGRectMake(web.frame.origin.x, web.frame.origin.y, 310.0f, containerView.frame.origin.y - web.frame.origin.y - 5.0f);

    }
    else {
        [UIView animateWithDuration:0.3f animations:^{
            containerView.frame = containerFrame;
            settingView.frame = CGRectMake(0.0f, containerView.frame.origin.y+containerView.frame.size.height, settingView.frame.size.width, settingView.frame.size.height);
            web.frame = CGRectMake(web.frame.origin.x, web.frame.origin.y, 310.0f, containerView.frame.origin.y - web.frame.origin.y - 5.0f);

        }];
    }
    showSetting = YES;
    //[sender removeTarget:self action:@selector(showSetting:) forControlEvents:UIControlEventTouchUpInside];
    //[sender addTarget:self action:@selector(hideSetting:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)hideSetting:(UIButton *)sender {
    CGFloat size;
    //if (showSetting) {
        size = 0.0f;
    /*}
    else {
        size = 216.0f;
    }*/
    CGRect containerFrame = containerView.frame;
    containerFrame.origin.y = self.view.bounds.size.height - (size + containerFrame.size.height);
    if (showKeyboard) {
        [self resignTextView];
    }
    //else {
        [UIView animateWithDuration:0.3f animations:^{
            containerView.frame = containerFrame;
            settingView.frame = CGRectMake(0.0f, containerView.frame.origin.y+containerView.frame.size.height, settingView.frame.size.width, settingView.frame.size.height);
            web.frame = CGRectMake(web.frame.origin.x, web.frame.origin.y, 310.0f, containerView.frame.origin.y - web.frame.origin.y - 5.0f);

        }];
    //}
    showSetting = NO;
    if (!textView.text || [textView.text isEqualToString:@""]) {
        return;
    }
    //[growingTextView resignFirstResponder];
    [self sendData:textView.text];
    textView.text = @"";
}

- (void)clearViewText:(id)sender {
	NSString *htmlBody = @"<html><head><title>viWave</title></head><body> \
	</body></html>";
	
	[web loadHTMLString:htmlBody baseURL:nil];
    
    
    NSRange range;
    range.location = 0;
    range.length = [content length];
    [content deleteCharactersInRange:range];
    [_datas removeAllObjects];
    
}

- (void) compare {
    NSError *error = nil;
    NSString *file = [NSString stringWithFormat:@"%@/Documents/%f",NSHomeDirectory(), [[NSDate date] timeIntervalSince1970]];
    BOOL ret = [content writeToFile:file atomically:YES encoding:NSMacOSRomanStringEncoding error:&error];
    if (ret == TRUE) {
        //   NSLog(@"write to file OK");
        BOOL bResult = TRUE;
        if (comparedPath && [comparedPath length] != 0) {
            NSLog(@"compare...");
            bResult = [fileManager contentsEqualAtPath:comparedPath andPath:file];
            NSString *tmp = [[NSString alloc] initWithFormat:@"Rx bytes = %ld,  compare %@, time = %.3fs",[content length], bResult ?@"Pass":@"Fail",endTime-startTime];
            ISString *temp = [[ISString alloc] init];
            temp.string = tmp;
            temp.systemLog = YES;
            if ([_datas count] >0) {
            ISString *last = [_datas objectAtIndex:([_datas count]-1)];
            if ([last.string hasPrefix:@"Rx bytes"]) {
                [_datas removeObject:last];
            }
            }
            [_datas addObject:temp];
            [self reloadOutputView];
             if (bResult == false) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Compare Fail"  message:[NSString stringWithFormat:@"Please check /Documents/%@", file]  delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alertView show];
            }
        }
    }
    else {
        //  NSLog(@"write to file fail,%@, %@", file, [error localizedDescription]);
    }
    startTime = 0;
    endTime = 0;
}

- (void)save {
    if ([content length] == 0) {
        return;
    }
    NSError *error = nil;
    NSString *file = [NSString stringWithFormat:@"%@/Documents/%f",NSHomeDirectory(), [[NSDate date] timeIntervalSince1970]];
    BOOL ret = [content writeToFile:file atomically:YES encoding:NSMacOSRomanStringEncoding error:&error];
    if (ret) {
        NSString *tmp = [[NSString alloc] initWithFormat:@"Save file name = %@ ,Rx bytes = %ld",file,[content length]];
        ISString *temp = [[ISString alloc] init];
        temp.string = tmp;
        temp.systemLog = YES;
        if ([_datas count] >0) {
        ISString *last = [_datas objectAtIndex:([_datas count]-1)];
        if ([last.string hasPrefix:@"Save file name"]) {
            [_datas removeObject:last];
        }
        }
        [_datas addObject:temp];
        [self reloadOutputView];
    }
}

- (void) SendTestPattern{
    NSLog(@"sendTestPattern1");
    
    if ([[ISControlManager sharedInstance] isConnect] && mode == MFi_SPPViewController_TimerMode)
    {
        NSLog(@"sendTestPattern2");
        NSString *tmp;
        if ([_datas count] >0) {
            ISString *last = [_datas objectAtIndex:([_datas count]-1)];
            if ([last.string hasPrefix:@"Timer ="]) {
                [_datas removeObject:last];
            }
        }
        testPattenCount++;
        NSLog(@"sendTestPattern3");
        if (pattern_times == 0) {
            tmp = [[NSString alloc] initWithFormat:@"Timer = %.3fs, Len = %ld, times = unlimited, Count = %d",timer_second,pattern_length, testPattenCount];
        }
        else {
            tmp = [[NSString alloc] initWithFormat:@"Timer = %.3fs, Len = %ld, times = %ld, Count = %d",timer_second,pattern_length, pattern_times,testPattenCount];
            if (testPattenCount >= pattern_times) {
                [_timer invalidate];
                _timer = nil;
                // NSLog(@"timer stop");
            }
        }
        ISString *temp = [[ISString alloc] init];
        temp.string = tmp;
        temp.systemLog = YES;
        [_datas addObject:temp];
        [self reloadOutputView];
         NSMutableString *pattern_str = [[NSMutableString alloc] initWithCapacity:pattern_length+10];
        for (int i=0; i<pattern_length-1; i++) {
            [pattern_str appendFormat:@"%d",testPattenCount%10];
        }
        [pattern_str appendFormat:@"\n"];
         [[ISControlManager sharedInstance] writeData:[pattern_str dataUsingEncoding:NSMacOSRomanStringEncoding]];
     }
    
}

- (void)setMTU:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Input delta time between patterns" message:@"unit:ms" completionBlock:^(NSUInteger buttonIndex, UIAlertView *alertView) {
        if (buttonIndex != [alertView cancelButtonIndex]) {
            UITextField *text = [alertView textFieldAtIndex:0];
            if (text.text) {
                [[NSUserDefaults standardUserDefaults] setInteger:[text.text integerValue] forKey:@"MTU"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
        }
    } cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK",nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField *text = [alert textFieldAtIndex:0];
    text.keyboardType = UIKeyboardTypeNumberPad;
    text.text = [NSString stringWithFormat:@"%ld",[[NSUserDefaults standardUserDefaults] objectForKey:@"MTU"] ? [[NSUserDefaults standardUserDefaults] integerForKey:@"MTU"] : 20];
    [alert show];
}

- (void)showInfo:(id)sender {
    NSArray *connectedAccessory = [[ISControlManager sharedInstance] connectedAccessory];
    for (ISDataPath *device in connectedAccessory) {
        ISString *tmp = [[ISString alloc] init];
        tmp.string = [NSString stringWithFormat:@"name = %@<br>fw_ver = %@<br>hw_ver = %@<br>manufacturer = %@<br>model_num = %@<br>serial_num = %@",device.name,device.firmwareRevision,device.hardwareRevision,device.manufacturer,device.modelNumber,device.serialNumber];
        tmp.systemLog = YES;
        [_datas addObject:tmp];
    }
    [self reloadOutputView];

}

#pragma mark - ISControlManagerDelegate
- (void)accessoryDidDisconnect {
    if ([[ISControlManager sharedInstance] isConnect]) {
        statusLabel.text = @"Connected";
        statusLabel.textColor = [UIColor greenColor];
        checkProtocol = TRUE;
    } else {
        statusLabel.text = @"Disconnected";
        statusLabel.textColor = [UIColor redColor];
        // NSLog(@"Disconnected");
    }
    NSArray *connectedAccessory = [[ISControlManager sharedInstance] connectedAccessory];
    NSMutableArray *list = [NSMutableArray array];
    for (ISDataPath *device in connectedAccessory) {
        [list addObject:[device name]];
    }
    connectDevices.text = [list componentsJoinedByString:@","];
}

- (void)accessoryDidConnect:(ISDataPath *)accessory {
    if ([[ISControlManager sharedInstance] isConnect]) {
        statusLabel.text = @"Connected";
        statusLabel.textColor = [UIColor greenColor];
        checkProtocol = TRUE;
    } else {
        statusLabel.text = @"Disconnected";
        statusLabel.textColor = [UIColor redColor];
        // NSLog(@"Disconnected");
    }
    ISString *tmp = [[ISString alloc] init];
    //tmp.string = [NSString stringWithFormat:@"name = %@<br>fw_ver = %@<br>hw_ver = %@<br>manufacturer = %@<br>model_num = %@<br>serial_num = %@",accessory.name,accessory.firmwareRevision,accessory.hardwareRevision,accessory.manufacturer,accessory.modelNumber,accessory.serialNumber];
    tmp.string = [NSString stringWithFormat:@"name = %@",accessory.name];
    //tmp.remote = YES;
    tmp.systemLog = YES;
    [_datas addObject:tmp];
    [self reloadOutputView];
    NSArray *connectedAccessory = [[ISControlManager sharedInstance] connectedAccessory];
    NSMutableArray *list = [NSMutableArray array];
    for (ISDataPath *device in connectedAccessory) {
        [list addObject:[device name]];
    }
    connectDevices.text = [list componentsJoinedByString:@","];
}

- (void)accessoryDidReadData:(ISDataPath *)accessory data:(NSData *)data {
    static uint8_t buf[1026];
    static NSInteger idx=0;
    static BOOL TrID = TRUE;
    NSUInteger len = 0;
    unsigned int pkt_len = 0;
    if (checkProtocol == TRUE) {
        idx = 0;
        manualUpperProtocol = FALSE;
        TrID = TRUE;
    }
    if ([data length] > 1024-idx) {
        len = 1024-idx;
    }
    else {
        len = [data length];
    }
    [data getBytes:&buf[idx] length:len];
    if (len) {
        len = idx + len; //add previous length
        buf[len] = 0;
        // NSLog(@"buf=%s", buf);
        if (checkProtocol == TRUE)
        {
            if ((buf[0]&0x7f) == 0x00 && buf[1] == 0x08)
            {
                if (len >= 8)
                {
                    if (strncmp((char *)&buf[2], "ISSC_SPP", 8) == 0)
                    {
                        manualUpperProtocol = TRUE;
                        len = len - 10;
                        memmove(buf, &buf[10], len);
                        checkProtocol = FALSE;
                        // NSLog(@"manualUpperProtocol = true");
                    }
                }
                else
                {
                    idx = len;
                    return;
                }
            }
            else
            {
                checkProtocol = FALSE;
            }
        }//checkProtocol == TRUE
        NSMutableString *ReceiveStr = [NSMutableString new];
        if (manualUpperProtocol == TRUE)
        {
            // NSLog(@"total len=0x%04x",len);
            idx = 0;
            do
            {
                // NSLog(@"remaind len=0x%04x",len);
                if (len < 2)
                { //incomplete data
                    // idx = idx + len;
                    break;
                }
                else
                {
                    pkt_len = (((buf[idx]&0x7F)<<8) | buf[idx+1]);
                    
                    if (len < pkt_len+2)
                    { //incomplete data
                        //   idx = idx + len;
                        break;
                    }
                    //  idx = 0;
                    uint8_t backup = buf[idx + pkt_len + 2];
                    buf[idx + pkt_len + 2] = 0x00;
                    BOOL tmpID = TRUE;
                    if ((buf[idx]>>7)==0)
                    {
                        tmpID = FALSE;
                    }
                    if (TrID != tmpID)
                    {
                        [ReceiveStr appendFormat:@"%s", &buf[idx+2]];
                        TrID = tmpID;
                    }
                    idx = idx + pkt_len + 2;//move to next packet
                    len = len - pkt_len - 2;;
                    buf[idx] = backup;
                }
            }while (1);
            if (len > 0)
            {
                char tmp[1024];
                memcpy(tmp, &buf[idx], len);
                memcpy(buf, tmp, len);
                idx = len;
            }
            else
            {
                idx = 0;
            }
        }//if (checkProtocol == TRUE)
        else {
            NSLog(@"%@",data);
            NSString *temp = [[NSString alloc] initWithData:data encoding:NSMacOSRomanStringEncoding];
            [ReceiveStr appendFormat:@"%@", temp];
        }
        if ([ReceiveStr length] == 0)
        {
            return;
        }
        if (mode == MFi_SPPViewController_LoopbackMode)
        {
            if ([accessory isKindOfClass:[ISBLEDataPath class]]) {
                NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
                if ([def boolForKey:@"writeWithResponse"]) {
                    if ([_loopBackQueue count] == 0) {
                        [[ISControlManager sharedInstance] writeData:[ReceiveStr dataUsingEncoding:NSMacOSRomanStringEncoding] withAccessory:accessory];
                    }
                    [_loopBackQueue addObject:@{@"accessory": accessory,@"ReceiveStr":ReceiveStr}];
                }
                else {
                    [[ISControlManager sharedInstance] writeData:[ReceiveStr dataUsingEncoding:NSMacOSRomanStringEncoding] withAccessory:accessory];
                }
            }
            else {
                [[ISControlManager sharedInstance] writeData:[ReceiveStr dataUsingEncoding:NSMacOSRomanStringEncoding] withAccessory:accessory];
            }
         }
        else {
            ISString *tmp = [[ISString alloc] init];
            tmp.string = ReceiveStr;
            tmp.remote = YES;
            //[_datas addObject:tmp];
            [content appendString:ReceiveStr];
            ISString *temp = [[ISString alloc] init];
            temp.string  = [[NSString alloc] initWithFormat:@"Bytes count = %ld",[content length]];
            temp.systemLog = YES;
            if ([_datas count] >0) {
            ISString *last = [_datas objectAtIndex:([_datas count]-1)];
            if ([last.string hasPrefix:@"Bytes count"]) {
                [_datas removeObject:last];
            }
            }
            [_datas addObject:temp];
            [self reloadOutputView];
            if (comparedPath && [comparedPath length] != 0) {
                if (startTime == 0) {
                    startTime = [NSDate timeIntervalSinceReferenceDate];
                }
                endTime = [NSDate timeIntervalSinceReferenceDate];
                [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(compare) object:nil];
                [self performSelector:@selector(compare) withObject:nil afterDelay:5.0];
            }
        }
    
    } else {
        NSLog(@"no data!");
    }
}

- (void)accessoryDidWriteData:(ISDataPath *)accessory bytes:(int)bytes complete:(BOOL)complete {
    if (mode == MFi_SPPViewController_LoopbackMode) {
        NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
        if (![def boolForKey:@"writeWithResponse"] && [accessory isKindOfClass:[ISBLEDataPath class]]) {
            return;
        }
        if ([_loopBackQueue count] == 0) {
            return;
        }
        if (!complete && [accessory isKindOfClass:[ISBLEDataPath class]]) {
            return;
        }
        [_loopBackQueue removeObjectAtIndex:0];
        if ([_loopBackQueue count] > 0) {
            NSDictionary *dis = [_loopBackQueue objectAtIndex:0];
            [[ISControlManager sharedInstance] writeData:[dis[@"ReceiveStr"] dataUsingEncoding:NSMacOSRomanStringEncoding] withAccessory:dis[@"accessory"]];
        }
        return;
    }
    if (!txPath) {
        return;
    }
    ISString *tmp = [[ISString alloc] init];
    tmp.string = [NSString stringWithFormat:@"Name:%@ bytes:%d Complete:%@",accessory.name,bytes,complete?@"YES":@"NO"];
    tmp.systemLog = YES;
    if ([_datas count] >0) {
        ISString *last = [_datas objectAtIndex:([_datas count]-1)];
        if ([last.string hasPrefix:@"Name:"]) {
            [_datas removeObject:last];
        }
    }
    [_datas addObject:tmp];
    [self reloadOutputView];
    if (complete) {
        cancelButton.hidden = YES;
        txPath = nil;
    }
}

#pragma mark - HPGrowingTextViewDelegate

- (BOOL)growingTextViewShouldReturn:(HPGrowingTextView *)growingTextView {
    if (!growingTextView.text || [growingTextView.text isEqualToString:@""]) {
        return YES;
    }
    //[growingTextView resignFirstResponder];
    [self sendData:growingTextView.text];
    growingTextView.text = @"";
    return YES;
}


- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height
{
    float diff = (growingTextView.frame.size.height - height);
    
	CGRect r = containerView.frame;
    r.size.height -= diff;
    r.origin.y += diff;
	containerView.frame = r;
    web.frame = CGRectMake(web.frame.origin.x, web.frame.origin.y, 310.0f, containerView.frame.origin.y - web.frame.origin.y - 5.0f);
    
}

- (BOOL)growingTextViewShouldBeginEditing:(HPGrowingTextView *)growingTextView {
    myTextView = YES;
    return YES;
}

- (void)growingTextViewDidEndEditing:(HPGrowingTextView *)growingTextView {
    myTextView = NO;
}

#pragma mark - TableAlertViewDelegate
-(void)didSelectRowAtIndex:(NSInteger)row withContext:(id)context{
    NSString *tmp = (NSString *)context;
    if ([tmp isEqualToString:@"Compare"]) {
        NSLog(@"DataTransparentViewController] didSelectRowAtIndex Compare");
        if(row >= 0){
            comparedPath = [NSString stringWithFormat:@"%@/%@",[[NSBundle mainBundle] resourcePath],[dirArray objectAtIndex:row]];
            //comparedPath = [[NSString alloc] initWithFormat:@"%@/%@.app/%@",NSHomeDirectory(), [[[NSBundle mainBundle] infoDictionary]   objectForKey:@"CFBundleName"], [dirArray objectAtIndex:row]];
            NSLog(@"Did select %@", comparedPath);
        }
        else{
            NSLog(@"Selection cancelled");
            if (comparedPath) {
                comparedPath = nil;
            }
        }
        NSRange range;
        range.location = 0;
        range.length = [content length];
        [content deleteCharactersInRange:range];
    }
    else {
        if (row >= 0) {
            txPath = [NSString stringWithFormat:@"%@/%@",[[NSBundle mainBundle] resourcePath],[dirArray objectAtIndex:row]];
            //txPath = [[NSString alloc] initWithFormat:@"%@/%@.app/%@",NSHomeDirectory(), [[[NSBundle mainBundle] infoDictionary]   objectForKey:@"CFBundleName"], [dirArray objectAtIndex:row]];
            fileReadOffset = 0;
            writeAllowFlag = TRUE;
            [self writeFile];
            cancelButton.hidden = NO;
        }
        else{
            NSLog(@"Selection cancelled");
            if (txPath) {
                txPath = nil;
            }
        }
        
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    CGPoint bottomOffset = CGPointMake(0, web.scrollView.contentSize.height - web.scrollView.bounds.size.height);
    [web.scrollView setContentOffset:bottomOffset animated:NO];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != [alertView cancelButtonIndex]) {
        switch (alertView.tag) {
            case 1: {
                float miliSecond = [[alertView textFieldAtIndex:0].text floatValue];
                if (miliSecond != 0) {
                    timer_second = (miliSecond/1000);
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Input pattern length" message:@"unit:byte" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK",nil];
                    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
                    alert.tag = 2;
                    [alert show];
                }
                else {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Input delta time between patterns" message:@"unit:ms" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK",nil];
                    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
                    alert.tag = 1;
                    [alert show];
                }
            }
                break;
            case 2: {
                pattern_length = [[alertView textFieldAtIndex:0].text integerValue];
                if (pattern_length != 0) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Input repeat times" message:@"0:unlimited" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK",nil];
                    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
                    alert.tag = 3;
                    [alert show];
                }
                else {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Input pattern length" message:@"unit:byte" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK",nil];
                    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
                    alert.tag = 2;
                    [alert show];
                }

            }
                break;
            case 3: {
                pattern_times = [[alertView textFieldAtIndex:0].text integerValue];
                if (_timer) {
                    [_timer invalidate];
                    _timer = nil;
                }
                NSString *tmp;
                if (pattern_times == 0) {
                    tmp = [[NSString alloc] initWithFormat:@"Timer = %.3fs, Len = %ld, times = unlimited",timer_second,pattern_length];
                }
                else {
                    tmp = [[NSString alloc] initWithFormat:@"Timer = %.3fs, Len = %ld, times = %ld",timer_second,pattern_length,pattern_times];
                }
                ISString *temp = [[ISString alloc] init];
                temp.string = tmp;
                temp.systemLog = YES;
                [_datas addObject:temp];
                [self reloadOutputView];
                _timer = [NSTimer scheduledTimerWithTimeInterval:timer_second target:self selector:@selector(SendTestPattern) userInfo:nil repeats:YES];
                cancelButton.hidden = NO;

            }
                break;
            default:
                break;
        }
    }
    else {
        /*mode = MFi_SPPViewController_RawMode;
        for (UIButton *but in modeButton) {
            if (but.tag != MFi_SPPViewController_RawMode) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0), dispatch_get_main_queue(), ^{
                    [but setHighlighted:NO];
                });
            }
            else {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0), dispatch_get_main_queue(), ^{
                    [but setHighlighted:YES];
                });
            }
        }*/

    }
}

@end
