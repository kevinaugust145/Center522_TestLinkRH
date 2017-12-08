


#import <UIKit/UIKit.h>
#import <ExternalAccessory/ExternalAccessory.h>
#import "MFi_SPPAboutViewController.h"
//#import <Foundation/NSFileManager.h>
#import "ISSCTableAlertView.h"

#define MAX_ACCESSORIES 7
//extern NSString *const MFi_SPP_Protocol[7];
enum {
	MFi_SPPViewController_RawMode = 0,
	MFi_SPPViewController_HexMode = 1,
	MFi_SPPViewController_LoopbackMode =2,
    MFi_SPPViewController_TimerMode =3
};

enum {
    USER_ACTION_INPUT_DATA = 0,
    USER_ACTION_INPUT_FILE_NAME = 1,
    USER_ACTION_INPUT_DELTA_TIME = 2,
    USER_ACTION_INPUT_PATTERN_LENGTH = 3,
    USER_ACTION_INPUT_PATTERN_TIMES = 4
};
typedef struct _STURCT_ACCESSORY_ {
    EASession *session;
	EAAccessory *accessory;
	NSMutableData *outgoingData;
}STRUCT_ACCESSORY;

@interface MFi_SPPViewController : UIViewController<UITextViewDelegate, 
													NSStreamDelegate, 
													EAAccessoryDelegate, 
													FlipsideViewControllerDelegate, 
													UIWebViewDelegate,
                                                    TableAlertViewDelegate> {
	UITextField *inputTextField;
    UITextField *fileNameField;
	UILabel *remoteLabel;
	UILabel *statusLabel;
    UILabel *timerLabel;
	UIButton *cancelButton;
	UIWebView *webView;
	UIButton *clearTextButton;
														
	
	UISegmentedControl *segmentedControl;
//	EASession *session[2];
 //   EASession *backup_session;
 //   EASession *session2;
//	EAAccessory *accessory;
//    EAAccessory *accessory2;
    STRUCT_ACCESSORY accessories[MAX_ACCESSORIES];
//	NSMutableData *_outgoingData[2];
    float timer_second;
    int pattern_length;
    int pattern_times;
 //   NSMutableString *test_pattern_str;
//	NSMutableData *_incomingData;
	
	NSMutableArray *_datas;
    NSTimer *_timer;
    int testPattenCount;
    NSMutableString *content;
//    NSString *currentPath;
//    NSFileManager *fileManager;
    int userAction_Flag;
    int userSegmentMode;
    BOOL checkProtocol;
    BOOL manualUpperProtocol;
    NSFileManager *fileManager;
    long fileReadOffset;
    BOOL writeAllowFlag;
                                                        
    NSString *txPath;

}
@property (nonatomic, retain) IBOutlet UIWebView *webView;
@property (nonatomic, retain) IBOutlet UITextField *inputTextField;
@property (nonatomic, retain) IBOutlet UILabel *remoteLabel;
@property (nonatomic, retain) IBOutlet UILabel *statusLabel;
@property (nonatomic, retain) IBOutlet UILabel *timerLabel;
@property (nonatomic, retain) IBOutlet UISegmentedControl *segmentedControl;
@property (nonatomic, retain) IBOutlet UIButton *cancelButton;
//@property (nonatomic, retain) EAAccessory *accessory;
//@property (nonatomic, retain) EAAccessory *accessory2;
@property (retain, nonatomic) NSMutableArray *dirArray;
@property (retain) NSString *comparedPath;



- (IBAction)switchRawAndHex:(id)sender;
- (IBAction)sendData:(id)sender;
- (IBAction)showInfo:(id)sender;
- (IBAction)cancelSendingData:(id)sender;
- (IBAction)clearViewText:(id)sender;
- (IBAction)saveAsFile:(id)sender;

- (EAAccessory *)obtainAccessoryForProtocol:(NSString *)protocolString;
- (void)setAccessories;
- (void)setAccessories:(id)newAccessory index:(int)idx;
- (void)SendTestPattern;

@end

