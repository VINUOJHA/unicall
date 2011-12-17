//
//  OutgoingViewController.h
//  OutgoingCall
//
//  Created by Hussain Yaqoob on 4/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>


@interface CallViewController : UIViewController {
	
	IBOutlet UILabel *_callerIdlbl;
	IBOutlet UILabel *_callstatuslbl;
	
	IBOutlet UILabel *_lblHold;
	IBOutlet UILabel *_lblSpeaker;
	IBOutlet UILabel *_lblMute;
	
	IBOutlet UIButton *_btnHold;
	IBOutlet UIButton *_btnSpeaker;
	//UIButton *_btnKeyboard;
	IBOutlet UIButton *_btnMute;
	//UIButton *_btnGps;
	
	IBOutlet UIButton *_btnEndCall;
	
	NSTimer *_callTimer;
	NSDate *_callTime;
	NSTimeInterval _duration;
	
	BOOL _isHold;
	BOOL _isSpeaker;
	BOOL _isMute;
	
	int hour;
	int min;
	int sec;

}

@property (nonatomic, retain) UILabel *_callerIdlbl;
@property (nonatomic, retain) UILabel *_callstatuslbl;

@property (nonatomic, retain) UILabel *_lblHold;
@property (nonatomic, retain) UILabel *_lblSpeaker;
@property (nonatomic, retain) UILabel *_lblMute;

@property (nonatomic, retain) UIButton *_btnHold;
@property (nonatomic, retain) UIButton *_btnSpeaker;
//@property (nonatomic, retain) UIButton *_btnKeyboard;
@property (nonatomic, retain) UIButton *_btnMute;
//@property (nonatomic, retain) UIButton *_btnGps;

@property (nonatomic, retain) UIButton *_btnEndCall;

@property (nonatomic, retain) NSTimer *_callTimer;
@property (nonatomic, retain) NSDate *_callTime;
@property (nonatomic, assign) NSTimeInterval _duration;

@property (readwrite, assign) BOOL _isHold;
@property (readwrite, assign) BOOL _isSpeaker;
@property (readwrite, assign) BOOL _isMute;

@property (nonatomic, assign) int min;
@property (nonatomic, assign) int sec;
@property (nonatomic, assign) int hour;

-(IBAction) muteCall:(id)sender;
-(IBAction) setSpeaker:(id)sender;
-(IBAction) holdCall:(id) sender;
//-(IBAction) showKeypad;

-(void) startCallTimer;
-(void)fireTimer;
-(IBAction)endCall:(id)sender;

@end
