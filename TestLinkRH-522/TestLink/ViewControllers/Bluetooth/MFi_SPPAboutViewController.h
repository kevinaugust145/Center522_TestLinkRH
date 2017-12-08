//
//  MFi_SPPAboutViewController.h
//  MFi_SPP
//
//  Created by James Chen on 12/29/10.
//  Copyright 2010 viWave. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FlipsideViewControllerDelegate;
@interface MFi_SPPAboutViewController : UIViewController {
	id <FlipsideViewControllerDelegate> delegate;
}
@property (nonatomic, assign) id <FlipsideViewControllerDelegate> delegate;
- (IBAction)done:(id)sender;
@end
@protocol FlipsideViewControllerDelegate
- (void)flipsideViewControllerDidFinish:(MFi_SPPAboutViewController *)controller;
@end