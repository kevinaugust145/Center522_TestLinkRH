//
//  MFi_SPPViewController.m
//  MFi_SPP
//
//  Created by James Chen on 12/2/10.
//  Copyright 2010 viWave. All rights reserved.
//

#import "MFi_SPPViewController.h"
#import "MFi_SPPAboutViewController.h"
#import "MFi_DeviceListController.h"
#import "UIActionSheet+BlockExtensions.h"

#import "ISControlManager.h"
#import "ISDataPath.h"
#import "ISSCButton.h"
#import "ISSCTableAlertView.h"

NSString *const MFi_SPP_Protocol[] = {@"com.issc.datapath", @"com.issc.datapath2", @"com.issc.datapath3", @"com.issc.datapath4", @"com.issc.datapath5", @"com.issc.datapath6", @"com.issc.datapath7"};

@interface MFi_SPPMessage : NSObject
{
	NSString *string;
	BOOL fromRemote;
}

@property (nonatomic, retain) NSString *string;
@property(nonatomic) BOOL fromRemote;

@end
@implementation MFi_SPPMessage
@synthesize string;
@synthesize fromRemote;
+ (MFi_SPPMessage *)createMessage:(NSString *)string fromRemote:(BOOL)fromRemote {
	MFi_SPPMessage *newMessage = [MFi_SPPMessage new];
	newMessage.string = string;
	newMessage.fromRemote = fromRemote;
	return [newMessage autorelease]; 
}
@end

@interface MFi_SPPViewController(viPrivate)
- (void)stopDataSession:(id)sender sessionIndex:(int)idx;
- (void)setSession:(EASession*)newSession sessionIndex:(int)idx;
+ (NSString *)convertHexToRaw:(NSString *)hexString;
+ (NSString *)convertRawToHex:(NSString *)rawString;

@end
@interface UIWebView(MFi_SPPViewController)

- (void)scrollsToBottomAnimated:(BOOL)animated;

@end
@implementation UIWebView(MFi_SPPViewController)
- (void)scrollsToBottomAnimated:(BOOL)animated {
	[self stringByEvaluatingJavaScriptFromString:
						@"dh=document.body.scrollHeight;"
						"ch=document.body.clientHeight;"
						"if(dh>ch){"
						"moveme=dh-ch;"
						"window.scrollTo(0,moveme);"
						"}"];
}
@end

@implementation MFi_SPPViewController

@synthesize webView;
@synthesize inputTextField;
@synthesize remoteLabel;
@synthesize statusLabel;
@synthesize timerLabel;
//@synthesize accessory;
//@synthesize accessory2;
@synthesize segmentedControl;
@synthesize cancelButton;
@synthesize dirArray;
@synthesize comparedPath;

// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
		_datas = [NSMutableArray new];
		//_timer = nil;
       // NSLog(@"_timer nil");
    }
    return self;
}
- (id)initWithCoder:(NSCoder *)aDecoder {
//	if (self == [super initWithCoder:aDecoder]) {
		_datas = [NSMutableArray new];
		
//	}
	return self;
}
/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    NSLog(@"viewDidLoad");
    [super viewDidLoad];
	webView.delegate = self;
	webView.scalesPageToFit = NO;
	webView.dataDetectorTypes = UIDataDetectorTypeNone;
	self.remoteLabel.text = accessories[0].accessory.name;
	_timer = nil;
//    fileManager = [[NSFileManager alloc] init];
   // currentPath = [fileManager currentDirectoryPath];
  //  NSArray *HomePath = NSHomeDirectory();
  //  currentPath = [HomePath objectAtIndex: 0];
 //   currentPath = NSHomeDirectory();
    content = [[NSMutableString alloc] initWithCapacity:500008];
//    NSLog(@"%@", currentPath);
    userAction_Flag = USER_ACTION_INPUT_DATA;
    userSegmentMode = MFi_SPPViewController_RawMode;
    // Observe keyboard hide and show notifications to resize the text view appropriately.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[ISControlManager sharedInstance] setDelegate:self];
    ISSCButton *button = [ISSCButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0.0f, 0.0f, 60.0f, 30.0f);
    [button addTarget:self action:@selector(selectCompareFile) forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:@"Compare" forState:UIControlStateNormal];
    button.titleLabel.adjustsFontSizeToFitWidth = YES;
    UIBarButtonItem *compareButton = [[[UIBarButtonItem alloc] initWithCustomView:button] autorelease];

    button = [ISSCButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0.0f, 0.0f, 60.0f, 30.0f);
    [button addTarget:self action:@selector(selectTxFile) forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:@" TX File " forState:UIControlStateNormal];
    button.titleLabel.adjustsFontSizeToFitWidth = YES;
    UIBarButtonItem *txFileButton = [[[UIBarButtonItem alloc] initWithCustomView:button] autorelease];

    NSArray *toolbarItems = [[NSArray alloc] initWithObjects:compareButton, txFileButton, nil];
    [self setToolbarItems:toolbarItems animated:NO];
    [toolbarItems release];
    [[self navigationController] setToolbarHidden: NO animated:NO];

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
    NSLog(@"dirarray count = %d", [dirArray count]);
    //[path release];
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/
- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
  //  NSLog(@"viewDidUnload");
	webView.delegate = nil;
	self.webView = nil;
    self.remoteLabel = nil;
    self.segmentedControl = nil;
	self.inputTextField = nil;
    self.statusLabel = nil;
    self.timerLabel = nil;
	self.cancelButton = nil;
 //   [fileManager release];
    //[content release];
    if (_timer != nil) {
         [_timer release];
         _timer = nil;
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
    [super viewDidUnload];
}


- (void)dealloc {
   // NSLog(@"dealloc");	
    for (int i=0;i<MAX_ACCESSORIES;i++)
    {
        [self stopDataSession:self sessionIndex:i];
        [accessories[i].session release];
        [accessories[i].accessory release];
        [accessories[i].outgoingData release];
    }
	[_datas release];
    [content release];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:nil object:nil];
    [super dealloc];
}


#pragma mark - ISSmartWatchControlManagerDelegate
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
    self.remoteLabel.text = [list componentsJoinedByString:@" "];
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
    NSString *tmp = [[NSString alloc] initWithFormat:@"name = %@<br>fw_ver = %@<br>hw_ver = %@<br>manufacturer = %@<br>model_num = %@<br>serial_num = %@",accessory.name,accessory.firmwareRevision,accessory.hardwareRevision,accessory.manufacturer,accessory.modelNumber,accessory.serialNumber];
    [_datas addObject:[MFi_SPPMessage createMessage:tmp fromRemote:YES]];
    [self reloadOutputView];
    [tmp release];
    NSArray *connectedAccessory = [[ISControlManager sharedInstance] connectedAccessory];
    NSMutableArray *list = [NSMutableArray array];
    for (ISDataPath *device in connectedAccessory) {
        [list addObject:[device name]];
    }
    self.remoteLabel.text = [list componentsJoinedByString:@" "];
}

- (void)accessoryDidReadData:(NSData *)data {
    static uint8_t buf[1026];
    static int idx=0;
    static BOOL TrID = TRUE;
    unsigned int len = 0;
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
                    { //if duplicated data, ignore
                        // NSString str = [NSString stringWithCString:(const char *)buf encoding:NSMacOSRomanStringEncoding];
                        // NSLog(@"len=0x%04x, idx=%04x\n %s",pkt_len,idx, &buf[idx+2]);
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
            NSString *temp = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
            [ReceiveStr appendFormat:@"%@", temp];
            //NSLog(@"session=%d, %@",sessionIndex, ReceiveStr);
        }
        if ([ReceiveStr length] == 0)
        {
            [ReceiveStr release];
            return;
        }
        //   NSLog(ReceiveStr);
        //	NSString *ReceiveStr = [NSString stringWithCString:(const char *)buf encoding:NSMacOSRomanStringEncoding];
        //	NSLog(@"split end");
        if ([segmentedControl selectedSegmentIndex] == MFi_SPPViewController_LoopbackMode)
        {
            [[ISControlManager sharedInstance] writeData:[ReceiveStr dataUsingEncoding:NSUTF8StringEncoding]];
        }
        else {
            [_datas addObject:[MFi_SPPMessage createMessage:ReceiveStr fromRemote:YES]];
            [content appendString:ReceiveStr];
            //     [_datas removeAllObjects];///////////bb
            //	[_datas addObject:[MFi_SPPMessage createMessage: ReceiveStr fromRemote:YES]];////////bb
            //	[self reloadOutputView];//////////bb
            [self reloadOutputView];
            NSString *tmp = [[NSString alloc] initWithFormat:@"Bytes count = %d",[content length]];
            timerLabel.text = tmp;
            [tmp release];
            if (comparedPath && [comparedPath length] != 0) {
                [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(compare) object:nil];
                [self performSelector:@selector(compare) withObject:nil afterDelay:5.0];
            }
        }
        [ReceiveStr release];
        
    } else {
        NSLog(@"no data!");
    }
}

- (void)accessoryDidWriteData:(ISDataPath *)accessory bytes:(int)bytes complete:(BOOL)complete {
    timerLabel.text = [NSString stringWithFormat:@"Name:%@ bytes:%d Complete:%@",accessory.name,bytes,complete?@"YES":@"NO"];
    if (complete) {
        cancelButton.hidden = YES;
    }
}

- (void)selectCompareFile {
    ISSCTableAlertView  *alert = [[[ISSCTableAlertView alloc] initWithCaller:self data:dirArray title:@"Select a file to compare" buttonTitle:@"Don't compare" andContext:@"Compare"]  autorelease];
    [alert show];
}

- (void)selectTxFile {
    ISSCTableAlertView  *alert = [[[ISSCTableAlertView alloc] initWithCaller:self data:dirArray title:@"Tx File" buttonTitle:@"Cancel" andContext:@"TxFile"] autorelease];
    [alert show];
}

-(void)didSelectRowAtIndex:(NSInteger)row withContext:(id)context{
    NSString *tmp = (NSString *)context;
    if ([tmp isEqualToString:@"Compare"]) {
        NSLog(@"DataTransparentViewController] didSelectRowAtIndex Compare");
        if(row >= 0){
            comparedPath = [[NSString stringWithFormat:@"%@/%@",[[NSBundle mainBundle] resourcePath],[dirArray objectAtIndex:row]] retain];
            //comparedPath = [[NSString alloc] initWithFormat:@"%@/%@.app/%@",NSHomeDirectory(), [[[NSBundle mainBundle] infoDictionary]   objectForKey:@"CFBundleName"], [dirArray objectAtIndex:row]];
            NSLog(@"Did select %@", comparedPath);
        }
        else{
            NSLog(@"Selection cancelled");
            if (comparedPath) {
                [comparedPath release];
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
            txPath = [[NSString stringWithFormat:@"%@/%@",[[NSBundle mainBundle] resourcePath],[dirArray objectAtIndex:row]] retain];
            //txPath = [[NSString alloc] initWithFormat:@"%@/%@.app/%@",NSHomeDirectory(), [[[NSBundle mainBundle] infoDictionary]   objectForKey:@"CFBundleName"], [dirArray objectAtIndex:row]];
            fileReadOffset = 0;
            writeAllowFlag = TRUE;
            [self writeFile];
            cancelButton.hidden = NO;
        }
        else{
            NSLog(@"Selection cancelled");
            if (txPath) {
                [txPath release];
                txPath = nil;
            }
        }
        
    }
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
        int idx = 0;
        [[ISControlManager sharedInstance] writeData:data];
        [self.timerLabel setText:[[[NSString alloc] initWithFormat:@"Writing file, Tx bytes = %ld", fileReadOffset] autorelease]];
    }
    else {
        fileReadOffset = 0;
        NSString *str = [[NSString alloc] initWithFormat:@"file = %@",txPath];
        [txPath release];
        txPath = nil;
        cancelButton.hidden = YES;
        NSLog(@"tx complete");
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Tx File Complete" message:str delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        [str release];
        [alertView release];
    }
    //[data release];
    [fileHandleRead closeFile];
}

#pragma mark -
#pragma mark Responding to keyboard events

- (void)keyboardWillShow:(NSNotification *)notification {
	cancelButton.hidden = NO;
	CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
	CGRect newBounds = self.view.frame;
	newBounds.size.height -= (keyboardSize.height-129);
	self.view.frame = newBounds;
	[webView performSelector:@selector(scrollsToBottomAnimated:) withObject:nil afterDelay:0.1];
}
- (void)keyboardWillHide:(NSNotification *)notification {
	cancelButton.hidden = YES;
	CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
	CGRect newBounds = self.view.frame;
	newBounds.size.height += (keyboardSize.height-129);
	self.view.frame = newBounds;
	[webView performSelector:@selector(scrollsToBottomAnimated:) withObject:nil afterDelay:0.1];
}
- (void)stopDataSession:(id)sender sessionIndex:(int) idx{
   // NSLog(@"stopDataSession");
	[self setSession:NULL sessionIndex:idx];
}
- (void)writeDataToOutputStream:(int)idx {
  if ([accessories[idx].outgoingData length] > 0 ) {
//NSLog(@"writeDataOutputStream length>0");

	  NSInteger bytesWritten = [[accessories[idx].session outputStream] write:(const uint8_t *)[accessories[idx].outgoingData bytes]	maxLength:[accessories[idx].outgoingData length]];
	  NSLog(@"writeDataOutputStream length %d", bytesWritten);
    
      
      //////////////////////
/*      if (bytesWritten == -1) {//outputstream error
          NSLog(@"reopen output stream");
          [[accessories[idx].session outputStream] close];
          [[accessories[idx].session outputStream] open];
      }
*/
           
		if (bytesWritten < [accessories[idx].outgoingData length]) {
			NSLog(@"writeDataOutputStream second");
			NSData *originalData = accessories[idx].outgoingData;
			accessories[idx].outgoingData = [[NSMutableData alloc] initWithData:[originalData subdataWithRange:NSMakeRange(bytesWritten, [originalData length] - bytesWritten)]];
			[originalData release];
		} else {
			[accessories[idx].outgoingData release];
			accessories[idx].outgoingData = NULL;
		}
	}

}
- (NSString *)compileOutputToHTML
{
	NSString *htmlBody = @"<html><head><title>viWave</title></head><body> \
							%@ \
							</body></html>";
	
	NSEnumerator *enumerator = [_datas objectEnumerator];
	NSString *data;
	MFi_SPPMessage *message = [enumerator nextObject];
	NSMutableString *newContent = [NSMutableString new];
	//while (message = [enumerator nextObject]) {
	while (message) {	
        data = message.string;
		if (message.fromRemote) {
			[newContent appendString:@"<span style=\"color:red\">"];
		} else {
			[newContent appendString:@"<span>"];
		}

		if (([segmentedControl selectedSegmentIndex] == MFi_SPPViewController_RawMode) || ([segmentedControl selectedSegmentIndex] == MFi_SPPViewController_TimerMode)) {
			[newContent appendFormat:@"%@\n", data];
		} 
		else if ([segmentedControl selectedSegmentIndex] == MFi_SPPViewController_LoopbackMode)
		{
			//[newContent appendFormat:@"%@\n", data];//temp solution for loop back mode
		}
		else {
			[newContent appendFormat:@"%@\n", [[self class] convertRawToHex:data]];
		}
		[newContent appendString:@"</span>"];
		[newContent appendString:@"<br/>"];
        message = [enumerator nextObject];
	}
	return [NSString stringWithFormat:htmlBody, [newContent autorelease]];
}
- (void)webViewDidFinishLoad:(UIWebView *)aWebView {
   // NSLog(@"webViewDidFinishLoad");
	[webView performSelector:@selector(scrollsToBottomAnimated:) withObject:nil afterDelay:0.1];
}

- (void)reloadOutputView {
	[webView loadHTMLString:[self compileOutputToHTML] baseURL:nil];
	// TODO implement scrollsToBottomAnimated
}

- (void)sendData:(id)sender sessionIndex:(int)idx{
		
	NSString *rawString = NULL;
	UITextField *temp = (UITextField *)sender;
	//NSLog(@"sendData");
 	if ([segmentedControl selectedSegmentIndex] == MFi_SPPViewController_RawMode) {
//		[sender resignFirstResponder];//hide small keyboard and end current edit session
		rawString = temp.text;
	}
	else if ([segmentedControl selectedSegmentIndex] == MFi_SPPViewController_LoopbackMode)
	{
		rawString = temp.text;
	}
	else {
//		[temp resignFirstResponder];//hide small keyboard and end current edit session
		rawString = [[self class] convertHexToRaw:inputTextField.text];
	}
	
	[_datas addObject:[MFi_SPPMessage createMessage:rawString fromRemote:NO]];
    [[ISControlManager sharedInstance] writeData:[rawString dataUsingEncoding:NSMacOSRomanStringEncoding]];
    [self reloadOutputView];
	temp.text = @"";
    return;

	if ([[accessories[idx].session outputStream] hasSpaceAvailable]) {
		[accessories[idx].outgoingData release];
		accessories[idx].outgoingData = (NSMutableData *)[[rawString dataUsingEncoding:NSMacOSRomanStringEncoding] retain];
		[self writeDataToOutputStream:idx];
	}	
	[self reloadOutputView];
	temp.text = @"";	
}

- (void)sendData:(id)sender {
    [self sendData:sender sessionIndex:0];
}

- (IBAction)cancelSendingData:(id)sender {
	[inputTextField resignFirstResponder];
    inputTextField.placeholder = @"";
    inputTextField.keyboardType = UIKeyboardTypeASCIICapable;
    if ([segmentedControl selectedSegmentIndex] == MFi_SPPViewController_TimerMode) {
        if (_timer == nil) {
            timerLabel.text = @"No timer";
        }
        userAction_Flag = USER_ACTION_INPUT_DELTA_TIME;
    }
    else {
        userAction_Flag = USER_ACTION_INPUT_DATA;
    }
    if (txPath) {
        [txPath release];
        txPath = nil;
        cancelButton.hidden = YES;
    }

}
+ (NSString *)convertHexToRaw:(NSString *)hexString
{
	NSMutableString *rawString = [NSMutableString new];
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
	return [rawString autorelease];
}
+ (NSString *)convertRawToHex:(NSString *)rawString
{
	NSMutableString *hexString = [NSMutableString new];
	const unsigned char * asciiString = (const unsigned char *)[rawString cStringUsingEncoding:NSMacOSRomanStringEncoding];
	if (asciiString) {
		while (*asciiString != 0) {
			[hexString appendFormat:@"%02X ", *asciiString];
			asciiString++;
		}
	}
	return [hexString autorelease];
}

- (void) SendTestPattern{
 //   NSLog(@"Send test pattern1");
    int idx = 0; //fixed in session1 temporarily

        
    //NSString *Str = [NSString stringWithString:@"1234567890"];
    NSLog(@"sendTestPattern1");
   // NSLog(Str);
    //if (accessories[idx].session != nil && [segmentedControl selectedSegmentIndex] == MFi_SPPViewController_TimerMode && [accessories[idx].outgoingData length] == 0)
    if ([[ISControlManager sharedInstance] isConnect] && [segmentedControl selectedSegmentIndex] == MFi_SPPViewController_TimerMode)
    {
        NSLog(@"sendTestPattern2");
        //if ([[accessories[idx].session outputStream] hasSpaceAvailable]) {
            NSString *tmp;
            testPattenCount++;
            NSLog(@"sendTestPattern3");
            if (pattern_times == 0) {
                tmp = [[NSString alloc] initWithFormat:@"Timer = %.3fs, Len = %d, times = unlimited, Count = %d",timer_second,pattern_length, testPattenCount];
            }
            else {
                tmp = [[NSString alloc] initWithFormat:@"Timer = %.3fs, Len = %d, times = %d, Count = %d",timer_second,pattern_length, pattern_times,testPattenCount];
                if (testPattenCount >= pattern_times) {
                    [_timer invalidate];
                    _timer = nil;
                    // NSLog(@"timer stop");
                }
            }
            timerLabel.text = tmp;
            [tmp release];
            NSMutableString *pattern_str = [[NSMutableString alloc] initWithCapacity:pattern_length+10];
            for (int i=0; i<pattern_length-1; i++) {
                [pattern_str appendFormat:@"%d",testPattenCount%10];
            }
            [pattern_str appendFormat:@"\n"];
       //     NSString *Str = [NSString stringWithFormat:@"%d", testPattenCount];
       //     [test_pattern_str insertString:Str atIndex:0];
       //     [test_pattern_str appendFormat:@"\n"];
            //[accessories[idx].outgoingData release];
            //accessories[idx].outgoingData = (NSMutableData *)[[pattern_str dataUsingEncoding:NSMacOSRomanStringEncoding] retain];
//            [accessories[idx].outgoingData release];
//            accessories[idx].outgoingData = [[Str dataUsingEncoding:NSMacOSRomanStringEncoding] retain];
           // NSLog(@"%@",pattern_str);
            //[self writeDataToOutputStream:idx];
        [[ISControlManager sharedInstance] writeData:[pattern_str dataUsingEncoding:NSMacOSRomanStringEncoding]];
            [pattern_str release];
            
        /*}
        else {
        //    [_timer invalidate];
        //    _timer = nil;
           // NSLog(@"Stream is not available");
        }*/
            
    }

}
- (IBAction)switchRawAndHex:(id)sender {	
	[self reloadOutputView];	
    if (_timer)
    {
        [_timer invalidate];
        _timer = nil;
    }
    userAction_Flag = USER_ACTION_INPUT_DATA;
    timerLabel.text = @"";
	if ([segmentedControl selectedSegmentIndex] == MFi_SPPViewController_HexMode) {
		inputTextField.autocorrectionType = UITextAutocorrectionTypeNo;
		inputTextField.hidden = NO;
        userSegmentMode = MFi_SPPViewController_HexMode;
	} else {
		if ([segmentedControl selectedSegmentIndex] == MFi_SPPViewController_LoopbackMode){
            userSegmentMode = MFi_SPPViewController_LoopbackMode;
			inputTextField.hidden = YES;
		}
        else if ([segmentedControl selectedSegmentIndex] == MFi_SPPViewController_TimerMode) {
            if ([[ISControlManager sharedInstance] isConnect]) {
                testPattenCount = 0;
                userAction_Flag = USER_ACTION_INPUT_DELTA_TIME;
                [inputTextField becomeFirstResponder]; 
                userSegmentMode = MFi_SPPViewController_TimerMode;
                inputTextField.hidden = NO;
            }
            else {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Connection alert"  message:@"No connection" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: nil];
                [alertView show];
                [alertView release];
                segmentedControl.selectedSegmentIndex = userSegmentMode;
                [self switchRawAndHex:nil];
            }
        }
		else { //raw mode
            userSegmentMode = MFi_SPPViewController_RawMode;
			inputTextField.hidden = NO;
		}

		inputTextField.autocorrectionType = UITextAutocorrectionTypeDefault;
	}	
}
- (void)setSession:(EASession*)newSession sessionIndex:(int)idx{
	[[accessories[idx].session inputStream] close];
	[[accessories[idx].session inputStream] removeFromRunLoop:[NSRunLoop currentRunLoop] 
									 forMode:NSDefaultRunLoopMode];
	[[accessories[idx].session outputStream] close];
	[[accessories[idx].session outputStream] removeFromRunLoop:[NSRunLoop currentRunLoop] 
									  forMode:NSDefaultRunLoopMode];

	[accessories[idx].session release];
    accessories[idx].session = [newSession retain];

	if (accessories[idx].session) {
       // NSLog(@"setSession, idx=%d",idx);
        [[accessories[idx].session inputStream] setDelegate:self];
		[[accessories[idx].session inputStream] scheduleInRunLoop:[NSRunLoop currentRunLoop]
										 forMode:NSDefaultRunLoopMode];
		[[accessories[idx].session inputStream] open];
		[[accessories[idx].session outputStream] setDelegate:self];
		[[accessories[idx].session outputStream] scheduleInRunLoop:[NSRunLoop currentRunLoop]
										  forMode:NSDefaultRunLoopMode];
		[[accessories[idx].session outputStream] open];
	}	
    else {
       // NSLog(@"setSession NULL");
    }
}



- (void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)streamEvent
{
	switch (streamEvent) {
        case NSStreamEventHasBytesAvailable:
            // Process the incoming stream data.
			{
				static uint8_t buf[1026];
                static int idx=0;
                static BOOL TrID = TRUE;
				unsigned int len = 0;
                unsigned int pkt_len = 0;
                unsigned char sessionIndex = 0;
                
                int i;
                if (checkProtocol == TRUE) {
                    idx = 0;
                    manualUpperProtocol = FALSE;
                    TrID = TRUE;
                }       
                for (i = 0; i < MAX_ACCESSORIES; i++) {
                    if (stream == accessories[i].session.inputStream) {
                        sessionIndex = i;
                        break;
                    }
                }
        //        NSLog(@"session1,idx=%d",sessionIndex);
             //   NSLog(@"session idx=%d",sessionIndex);
            /*    if (stream == session[0].inputStream)
                {
                   // NSLog(@"session1,idx=%d",idx);
                    sessionIndex = 0;
                }
                else if (stream == session[1].inputStream)
                {
                   // NSLog(@"session2");
                    sessionIndex = 1;
                }*/
				len = [(NSInputStream *)stream read:&buf[idx] maxLength:1024-idx];
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
                                break;
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
                                { //if duplicated data, ignore
                                    // NSString str = [NSString stringWithCString:(const char *)buf encoding:NSMacOSRomanStringEncoding];
                                   // NSLog(@"len=0x%04x, idx=%04x\n %s",pkt_len,idx, &buf[idx+2]);
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
                         [ReceiveStr appendFormat:@"%s", &buf[0]];
                        //NSLog(@"session=%d, %@",sessionIndex, ReceiveStr);
                    }
                    if ([ReceiveStr length] == 0)
                    {
                        [ReceiveStr release];
                        break;
                    }
                 //   NSLog(ReceiveStr);
 				//	NSString *ReceiveStr = [NSString stringWithCString:(const char *)buf encoding:NSMacOSRomanStringEncoding];
				//	NSLog(@"split end");
					if ([segmentedControl selectedSegmentIndex] == MFi_SPPViewController_LoopbackMode)
					{
                        if (accessories[sessionIndex].outgoingData == NULL) {
                            accessories[sessionIndex].outgoingData = (NSMutableData *)[[ReceiveStr dataUsingEncoding:NSMacOSRomanStringEncoding] retain];
                        }
                        else
                        {
                            [accessories[sessionIndex].outgoingData appendData:[ReceiveStr dataUsingEncoding:NSMacOSRomanStringEncoding]];
                            
                        }

						if ([[accessories[sessionIndex].session outputStream] hasSpaceAvailable]) {
						//	[_outgoingData release];
                        //    NSLog([NSString stringWithCString:(const char *)buf]);
                            
							[self writeDataToOutputStream:sessionIndex];
						}
                        else
                        {
                            NSLog(@"No Space Available");
                            
                            
                        }
					}
					else { 
                        [content appendString:ReceiveStr];
                   //     [_datas removeAllObjects];///////////bb
					//	[_datas addObject:[MFi_SPPMessage createMessage: ReceiveStr fromRemote:YES]];////////bb
					//	[self reloadOutputView];//////////bb
                        [self reloadOutputView];
                        NSString *tmp = [[NSString alloc] initWithFormat:@"Bytes count = %d",[content length]];
                        timerLabel.text = tmp;
                        [tmp release];
                        if (comparedPath && [comparedPath length] != 0) {
                            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(compare) object:nil];
                            [self performSelector:@selector(compare) withObject:nil afterDelay:5.0];
                        }
					}
                    [ReceiveStr release];
					
				} else {
					NSLog(@"no data!");
				}
			}
            break;
			
        case NSStreamEventHasSpaceAvailable:
            {
                unsigned char sessionIndex = 0;
                
                for (int i = 0; i < MAX_ACCESSORIES; i++) {
                    if (stream == accessories[i].session.outputStream) {
                        sessionIndex = i;
                        break;
                    }
                }
                NSLog(@"NSStreamEventHasSpaceAcailable %d",sessionIndex);
             /*   if (stream == session[0].inputStream)
                {
                   // NSLog(@"NSStreamEventHasSpaceAcailable session1");
                    sessionIndex = 0;
                }
                else if (stream == session[1].inputStream)
                {
                   // NSLog(@"NSStreamEventHasSpaceAcailable session2");
                    sessionIndex = 1;
                }*/
                
                [self writeDataToOutputStream:sessionIndex];
            /*    if (sessionIndex == 0) {
                    if ([segmentedControl selectedSegmentIndex] == MFi_SPPViewController_TimerMode && _timer == nil) {
                        _timer = [NSTimer scheduledTimerWithTimeInterval:timer_second target:self selector:@selector(SendTestPattern) userInfo:nil repeats:YES];
                   // NSLog(@"restart timer");
                    } 
                }*/
           
            }
            
            break;
			
        default:
            break;
    }
}

- (void) compare {
    NSError *error = nil;
    NSString *file = [NSString stringWithFormat:@"%@/Documents/%f",NSHomeDirectory(), [[NSDate date] timeIntervalSince1970]];
    BOOL ret = [content writeToFile:file atomically:YES encoding:NSUTF8StringEncoding error:&error];
    if (ret == TRUE) {
        /*UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Save OK"  message:[NSString stringWithFormat:@"%@ was saved!",file] delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
        [alertView release];*/
        timerLabel.text = @"";
        //   NSLog(@"write to file OK");
        BOOL bResult = TRUE;
        if (comparedPath && [comparedPath length] != 0) {
            NSLog(@"compare...");
            bResult = [fileManager contentsEqualAtPath:comparedPath andPath:file];
            NSString *tmp = [[NSString alloc] initWithFormat:@"Rx bytes = %d,  compare %@",[content length], bResult ?@"Pass":@"Fail"];
            self.timerLabel.text = tmp;
            [tmp release];
            if (bResult == false) {
                
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Compare Fail"  message:[NSString stringWithFormat:@"Please check /Documents/%@.txt", file]  delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alertView show];
                [alertView release];
            }
        }
    }
    else {
        //  NSLog(@"write to file fail,%@, %@", file, [error localizedDescription]);
    }
}
- (EAAccessory *)obtainAccessoryForProtocol:(NSString *)protocolString
{
    NSArray *accessories_array = [[EAAccessoryManager sharedAccessoryManager]
							connectedAccessories];
    //	NSLog(@"connectedAccessories:%@", accessories);
    EAAccessory *accessory = nil;
    
    for (EAAccessory *obj in accessories_array) {
        if ([[obj protocolStrings] containsObject:protocolString]) {
            accessory = obj;
            NSLog(@"protocolStr: %@", [obj protocolStrings]);
            break;  //remove break; to print all accessories for testing
        }
        
    }
	
    return accessory;
}

- (void)setAccessories {
    
    //NSLog(@"setAccessories...");
    for (int i=0; i < MAX_ACCESSORIES; i++) {
//        if (accessories[i].accessory == NULL)
//            continue;
        EAAccessory* obj = [self obtainAccessoryForProtocol:MFi_SPP_Protocol[i]];
        if (obj != nil) {
            [self setAccessories:obj index:i];
        }        
    }
}

- (void)setAccessories:(id)newAccessory index:(int)idx {
    
    NSLog(@"setAccessories1 %d", idx);
     
    if (newAccessory != accessories[idx].accessory) {
        NSLog(@"setAccessories2 %d", idx);
        [accessories[idx].accessory setDelegate:NULL];
        [self setSession:NULL sessionIndex:idx];
        [accessories[idx].accessory release];
        accessories[idx].accessory = [newAccessory retain];
        [accessories[idx].accessory setDelegate:self];
        self.navigationItem.title = accessories[idx].accessory.name;
        self.remoteLabel.text = accessories[idx].accessory.name;
        if (accessories[idx].accessory) {
            EASession *newSession = [[EASession alloc] initWithAccessory:accessories[idx].accessory
                                                             forProtocol:MFi_SPP_Protocol[idx]];
            [self setSession:newSession sessionIndex:idx];
            [newSession release];
            statusLabel.text = @"Connected";
            statusLabel.textColor = [UIColor greenColor];
            checkProtocol = TRUE;
            //  NSLog(@"connected");
            NSString *tmp = [[NSString alloc] initWithFormat:@"name = %@<br>fw_ver = %@<br>hw_ver = %@<br>manufacturer = %@<br>model_num = %@<br>serial_num = %@",accessories[idx].accessory.name,accessories[idx].accessory.firmwareRevision,accessories[idx].accessory.hardwareRevision,accessories[idx].accessory.manufacturer,accessories[idx].accessory.modelNumber,accessories[idx].accessory.serialNumber];
            [_datas addObject:[MFi_SPPMessage createMessage:tmp fromRemote:YES]];
            [self reloadOutputView];
            [tmp release];
        } else {
            statusLabel.text = @"Disconnected";
            statusLabel.textColor = [UIColor redColor];
            // NSLog(@"Disconnected");
        }
    }       
}
/*
- (void)setAccessory:(EAAccessory*)newAccessory {
    NSLog(@"setAccessory");
        
        if (newAccessory != accessory) {
            [accessory setDelegate:NULL];
            [self setSession:NULL sessionIndex:0];
            [accessory release];
            accessory = [newAccessory retain];
            [accessory setDelegate:self];
            self.navigationItem.title = accessory.name;
            self.remoteLabel.text = accessory.name;
            if (accessory) {
                EASession *newSession = [[EASession alloc] initWithAccessory:accessory
                                                                 forProtocol:MFi_SPP_Protocol[0]];
                [self setSession:newSession sessionIndex:0];
                [newSession release];
                statusLabel.text = @"Connected";
                statusLabel.textColor = [UIColor greenColor];
                checkProtocol = TRUE;
              //  NSLog(@"connected");
            } else {
                statusLabel.text = @"Disconnected";
                statusLabel.textColor = [UIColor redColor];
               // NSLog(@"Disconnected");
            }
        }       
    
}
- (void)setAccessory2:(EAAccessory*)newAccessory {
        if (newAccessory != accessory2) {
            [accessory2 setDelegate:NULL];
            [self setSession:NULL sessionIndex:1];
            [accessory2 release];
            accessory2 = [newAccessory retain];
            [accessory2 setDelegate:self];
      //      self.navigationItem.title = accessory2.name;
      //      self.remoteLabel.text = accessory2.name;
            if (accessory2) {
                EASession *newSession = [[EASession alloc] initWithAccessory:accessory2
                                                                 forProtocol:MFi_SPP_Protocol[1]];
                [self setSession:newSession sessionIndex:1];
                [newSession release];
                statusLabel.text = @"Connected";
                statusLabel.textColor = [UIColor greenColor];
                checkProtocol = TRUE;
              //  NSLog(@"connected");
            } else {
                statusLabel.text = @"Disconnected";
                statusLabel.textColor = [UIColor redColor];
              //  NSLog(@"Disconnected");
            }
        }            
}*/
- (void)accessoryDidDisconnect:(EAAccessory *)theAccessory {
    NSLog(@"accessoryDidDisconnect");
    for (int i=0; i < MAX_ACCESSORIES; i++) {
        if (theAccessory == accessories[i].accessory) {
           [self setAccessories:NULL index:i];
            break;
        }
    }
/*    if (theAccessory == accessory) {
            [self setAccessory:NULL];
    }        
    else if (theAccessory == accessory2) {
        [self setAccessory2:NULL];
    } */
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
  //  NSLog(@"textFieldShouldReturn");
    inputTextField.placeholder = @"";
    [inputTextField resignFirstResponder];
    if (textField == inputTextField) {
        
        if (userAction_Flag == USER_ACTION_INPUT_FILE_NAME) {
            NSError *error = nil;
            NSString *file = [NSString stringWithFormat:@"%@/Documents/%@",NSHomeDirectory(), inputTextField.text];
            BOOL ret = [content writeToFile:file atomically:YES encoding:NSUTF8StringEncoding error:&error];
            if (ret == TRUE) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Save OK"  message:[NSString stringWithFormat:@"%@ was saved!",file] delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alertView show];
                [alertView release];
                timerLabel.text = @"";
             //   NSLog(@"write to file OK");
                BOOL bResult = TRUE;
                if (comparedPath && [comparedPath length] != 0) {
                    NSLog(@"compare...");
                    bResult = [fileManager contentsEqualAtPath:comparedPath andPath:file];
                    
                    if (bResult == false) {
                        
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Compare Fail"  message:[NSString stringWithFormat:@"Please check /Documents/%@.txt", inputTextField.text]  delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                        [alertView show];
                        [alertView release];
                    }
                }
            }
            else {
              //  NSLog(@"write to file fail,%@, %@", file, [error localizedDescription]);
            }
            userAction_Flag = USER_ACTION_INPUT_DATA;
        }
        else if (userAction_Flag == USER_ACTION_INPUT_DELTA_TIME) {
            float miliSecond = [inputTextField.text integerValue];
            if (miliSecond != 0) {                
            timer_second = (miliSecond/1000);
            userAction_Flag = USER_ACTION_INPUT_PATTERN_LENGTH;
            [inputTextField becomeFirstResponder]; 
            }
            else {
                [inputTextField becomeFirstResponder];
            }
        }
        else if (userAction_Flag == USER_ACTION_INPUT_PATTERN_LENGTH) {
            pattern_length = [inputTextField.text integerValue];
            if (pattern_length != 0) {
                userAction_Flag = USER_ACTION_INPUT_PATTERN_TIMES;
                [inputTextField becomeFirstResponder];                               
            }
            else {
                [inputTextField becomeFirstResponder];
            }
            
        }
        else if (userAction_Flag == USER_ACTION_INPUT_PATTERN_TIMES) {
            pattern_times = [inputTextField.text integerValue];

            if (_timer) {
                [_timer invalidate];
                _timer = nil;
            }
            NSString *tmp;
            if (pattern_times == 0) {
                tmp = [[NSString alloc] initWithFormat:@"Timer = %.3fs, Len = %d, times = unlimited",timer_second,pattern_length];
            }
            else {
                tmp = [[NSString alloc] initWithFormat:@"Timer = %.3fs, Len = %d, times = %d",timer_second,pattern_length,pattern_times];
            }
            timerLabel.text = tmp;
            [tmp release];
            _timer = [NSTimer scheduledTimerWithTimeInterval:timer_second target:self selector:@selector(SendTestPattern) userInfo:nil repeats:YES]; 
            
        }
        else {
            
            [self sendData:textField sessionIndex:0];
        }
        
        inputTextField.text = @"";
    }    

	return YES;
}
- (BOOL) textFieldDidBeginEditing: (UITextField *)textField
{
   // NSLog(@"textFieldDidBeginEditing");
    if (textField == inputTextField) {
        inputTextField.keyboardType = UIKeyboardTypeASCIICapable;
        if (userAction_Flag == USER_ACTION_INPUT_FILE_NAME) {
            inputTextField.placeholder = @"input file name";
            inputTextField.returnKeyType = UIReturnKeyDone;
        }
        else if (userAction_Flag == USER_ACTION_INPUT_DELTA_TIME) {
            inputTextField.placeholder = @"input delta time between patterns, unit:ms";
            inputTextField.returnKeyType = UIReturnKeyDone;
            inputTextField.keyboardType = UIKeyboardTypeASCIICapable;//UIKeyboardTypeNumbersAndPunctuation; //for iphone4 issue
        }
        else if (userAction_Flag == USER_ACTION_INPUT_PATTERN_LENGTH) {
            inputTextField.placeholder = @"input pattern length, unit:byte";
            inputTextField.returnKeyType = UIReturnKeyDone;
            inputTextField.keyboardType = UIKeyboardTypeASCIICapable;//UIKeyboardTypeNumbersAndPunctuation;
        }
        else if (userAction_Flag == USER_ACTION_INPUT_PATTERN_TIMES) {
            inputTextField.placeholder = @"input repeat times, 0:unlimited";
            inputTextField.returnKeyType = UIReturnKeyDone;
            inputTextField.keyboardType = UIKeyboardTypeASCIICapable;//UIKeyboardTypeNumbersAndPunctuation;
        }
        else {
            inputTextField.placeholder = @"";
            inputTextField.returnKeyType = UIReturnKeySend;
        }
    }
        
    return YES;
}
- (BOOL) textFieldDidEndEditing: (UITextField *)textField
{
//    inputTextField.placeholder = @"";
    return YES;

    
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    //NSLog(@"string = %@", string);
	if (userAction_Flag == USER_ACTION_INPUT_FILE_NAME) {
        return YES;
    }
    else if (userAction_Flag == USER_ACTION_INPUT_DELTA_TIME || userAction_Flag == USER_ACTION_INPUT_PATTERN_LENGTH) {
        NSCharacterSet *unacceptedInput = [[NSCharacterSet characterSetWithCharactersInString:@"1234567890"] invertedSet];
		if ([[string componentsSeparatedByCharactersInSet:unacceptedInput] count] > 1)
			return NO;
		else {
            if ([self.inputTextField.text length] > 20) {
                return NO;
            }
			return YES;
        }
    }
    else if ([segmentedControl selectedSegmentIndex] == MFi_SPPViewController_HexMode) {
		NSCharacterSet *unacceptedInput = [[NSCharacterSet characterSetWithCharactersInString:@" ABCDEFabcdef1234567890"] invertedSet];
		if ([[string componentsSeparatedByCharactersInSet:unacceptedInput] count] > 1)
			return NO;
		else {
            if ([self.inputTextField.text length] > 20) {
                return NO;
            }
			return YES;
        }
	}
    if ([self.inputTextField.text length] > 20) {
        return NO;
    }
	return YES;
}
- (void)flipsideViewControllerDidFinish:(MFi_SPPAboutViewController *)controller {
    
	[self dismissModalViewControllerAnimated:YES];
}
- (IBAction)showInfo:(id)sender {    
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
                                      [list release];
                                      [nav release];
                                  }
                                      break;
                                  default:
                                      break;
                              }
                          }
                                            cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"MFi",@"BLE",nil];
    [act showInView:self.view];
    [act release];
}

- (IBAction)clearViewText:(id)sender {
	NSString *htmlBody = @"<html><head><title>viWave</title></head><body> \
	</body></html>";
	
	[webView loadHTMLString:htmlBody baseURL:nil];
    
    
    NSRange range;
    range.location = 0;
    range.length = [content length];
    [content deleteCharactersInRange:range];        
    [_datas removeAllObjects];
    timerLabel.text = @"";
    
}

- (void)showBluetoothAccessoryPickerWithNameFilter:(NSPredicate *)predicate completion:(EABluetoothAccessoryPickerCompletion)completion{
    return;
}

- (IBAction)saveAsFile:(id)sender {
   // NSLog(@"saveAsFile");
    userAction_Flag = USER_ACTION_INPUT_FILE_NAME;
    [inputTextField becomeFirstResponder];

}


@end
