    //
//  OutgoingViewController.m
//  OutgoingCall
//
//  Created by Hussain Yaqoob on 4/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CallViewController.h"
#import "uniCallAppDelegate.h"


@implementation CallViewController

@synthesize _callerIdlbl;
@synthesize _callstatuslbl;

@synthesize _lblHold;
@synthesize _lblSpeaker;
@synthesize _lblMute;

@synthesize _btnHold;
@synthesize _btnSpeaker;
//@synthesize _btnKeyboard;
@synthesize _btnMute;
//@synthesize _btnGps;
@synthesize _btnEndCall;

@synthesize _callTimer;
@synthesize _callTime;
@synthesize _duration;

@synthesize _isHold;
@synthesize _isSpeaker;
@synthesize _isMute;

@synthesize sec;
@synthesize min;
@synthesize hour;

/*
// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        
		// Custom initialization
		
		//self and background View
		self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
		//self.view.backgroundColor = [UIColor viewFlipsideBackgroundColor];
		UIImageView *background = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Call.png"]];
		//TODO: make to pic, call.png and call@2.png
		if (__IPHONE_3_0) {
			[background setFrame:CGRectMake(0, 0, 320, 480)];
		} else {
			[background setFrame:CGRectMake(0, 0, 640, 960)];
		}

		//background.image.size = CGSizeMake(320, 480);
		//background.image = [UIImage imageNamed:@"Call.png"];
		[self.view addSubview:background];
		//[background release];
		
		//top view
		CGRect callerIdFrame = CGRectMake(20, 11, 280, 38);
		self._callerIdlbl = [[UILabel alloc] initWithFrame:callerIdFrame];
		self._callerIdlbl.font = [UIFont fontWithName:@"Helvetica" size:30];
		self._callerIdlbl.textColor = [UIColor whiteColor];
		self._callerIdlbl.backgroundColor = [UIColor clearColor];
		//self._callerIdlbl.text = @"+973 36602271";
		[self._callerIdlbl setTextAlignment:UITextAlignmentCenter];
		
		CGRect callStatusFrame = CGRectMake( 20, 54, 280, 26);
		_callstatuslbl = [[UILabel alloc] initWithFrame:callStatusFrame];
		self._callstatuslbl.font = [UIFont systemFontOfSize:12];
		self._callstatuslbl.textColor = [UIColor whiteColor];
		self._callstatuslbl.backgroundColor = [UIColor clearColor];
		//self._callstatuslbl.text = @"MM :SS";
		[self._callstatuslbl setTextAlignment:UITextAlignmentCenter];
		
		[self.view addSubview:_callerIdlbl];
		[self.view addSubview:_callstatuslbl];
		
		//middle view -> buttons menu view		
		CGRect holdFrame = CGRectMake(115, 233, 94, 104);
		_btnHold = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
		_btnHold.frame = holdFrame;
		//[_btnHold setTitle:@"||" forState:UIControlStateNormal];
		[_btnHold setImage:[UIImage imageNamed:@"call_hold_pressed.png"]
									  forState:UIControlStateHighlighted];
		[_btnHold addTarget:self
					 action:@selector(holdCall:)
		   forControlEvents:UIControlEventTouchUpInside
		 ];

		CGRect speakerFrame = CGRectMake( 206, 128, 94, 104);
		_btnSpeaker = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
		_btnSpeaker.frame = speakerFrame;
		//[_btnSpeaker setTitle:@"Speaker" forState:UIControlStateNormal];
		[_btnSpeaker setImage:[UIImage imageNamed:@"Call_Speaker_Pressed.png"] forState:UIControlStateHighlighted];
		[_btnSpeaker addTarget:self
						action:@selector(setSpeaker)
			  forControlEvents:UIControlEventTouchUpInside
		 ];
		
		/*
		 CGRect keyboardFrame = CGRectMake(199, 200, 75, 65);
		_btnKeyboard = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
		_btnKeyboard.frame = keyboardFrame;
		[_btnKeyboard setTitle:@"Keypad" forState:UIControlStateNormal];
		[_btnKeyboard addTarget:self
						 action:@selector(showKeypad)
			   forControlEvents:UIControlEventTouchUpInside
		 ];
		 */
/*		
		CGRect muteFrame = CGRectMake(20, 128, 94, 104);
		_btnMute = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
		_btnMute.frame = muteFrame;
		//[_btnMute setTitle:@"Mute" forState:UIControlStateNormal];
		[_btnMute setImage:[UIImage imageNamed:@"call_mute_pressed.png"] forState:UIControlStateHighlighted];
		[_btnMute addTarget:self
					 action:@selector(muteCall)
		   forControlEvents:UIControlEventTouchUpInside
		 ];
		
		/*
		 CGRect gpsFrame = CGRectMake(162, 275, 75, 65);
		_btnGps = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
		_btnGps.frame = gpsFrame;
		[_btnGps setTitle:@"GPS" forState:UIControlStateNormal];
		*/
/*		
		_lblMute = [[UILabel alloc] initWithFrame:CGRectMake(54, 193, 33, 21)];
		_lblMute.font = [UIFont fontWithName:@"Helvetica" size:13];
		_lblMute.textColor = [UIColor whiteColor];
		_lblMute.backgroundColor = [UIColor clearColor];
		_lblMute.text = NSLocalizedString(@"mute", @"Mute lable title's to mute the call");
		[_lblMute setTextAlignment:UITextAlignmentLeft];
		
		_lblSpeaker = [[UILabel alloc] initWithFrame:CGRectMake(227, 194, 50, 21)];
		_lblSpeaker.font = [UIFont fontWithName:@"Helvetica" size:13];
		_lblSpeaker.textColor = [UIColor whiteColor];
		_lblSpeaker.backgroundColor = [UIColor clearColor];
		_lblSpeaker.text = NSLocalizedString(@"speaker", @"Speaker lable title's to make the current call on the speaker mode");
		[_lblSpeaker setTextAlignment:UITextAlignmentLeft];
		
		_lblHold = [[UILabel alloc] initWithFrame:CGRectMake(147, 293, 29, 21)];
		_lblHold.font = [UIFont fontWithName:@"Helvetica" size:13];
		_lblHold.textColor = [UIColor whiteColor];
		_lblHold.backgroundColor = [UIColor clearColor];
		_lblHold.text = NSLocalizedString(@"hold", @"Hold lable title's to hold the current call");
		[_lblHold setTextAlignment:UITextAlignmentLeft];
		
		[self.view addSubview:_btnHold];
		[self.view addSubview:_btnSpeaker];
		//[self.view addSubview:_btnKeyboard];
		[self.view addSubview:_btnMute];
		//[self.view addSubview:_btnGps];
		[self.view addSubview:_lblMute];
		[self.view addSubview:_lblSpeaker];
		[self.view addSubview:_lblHold];
		
		//bottom view -> endCallView
		CGRect endCallFrame = CGRectMake(20, 400, 280, 48);
		_btnEndCall = [[UIButton alloc] initWithFrame:endCallFrame ];
		[_btnEndCall setTitle:NSLocalizedString(@"End Call", @"A button's title to end the current Call")
					 forState:UIControlStateNormal];
		[_btnEndCall addTarget:self
						action:@selector(endCall)
			  forControlEvents:UIControlEventTouchUpInside];
		
		_btnEndCall.titleLabel.font = [UIFont boldSystemFontOfSize:20];

		[_btnEndCall setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		
		UIImage *normalImage = [[UIImage imageNamed:@"button_red.png"] stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0];
		[_btnEndCall setBackgroundImage:normalImage forState:UIControlStateNormal];
		UIImage *pressedImage = [[UIImage imageNamed:@"button_red_pressed.png"] stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0];
		[_btnEndCall setBackgroundImage:pressedImage forState:UIControlStateHighlighted];		
		[self.view addSubview:_btnEndCall];

    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {	
	[super loadView];
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	
	[_btnHold setImage:[UIImage imageNamed:@"call_hold_pressed.png"]
			  forState:UIControlStateHighlighted];
	
	[_btnSpeaker setImage:[UIImage imageNamed:@"Call_Speaker_Pressed.png"] forState:UIControlStateHighlighted];
	
	[_btnMute setImage:[UIImage imageNamed:@"call_mute_pressed.png"] forState:UIControlStateHighlighted];
	
	_lblMute.text = NSLocalizedString(@"mute", @"Mute lable title's to mute the call");
	
	_lblSpeaker.text = NSLocalizedString(@"speaker", @"Speaker lable title's to make the current call on the speaker mode");
	
	_lblHold.text = NSLocalizedString(@"hold", @"Hold lable title's to hold the current call");
	
	[_btnEndCall setTitle:NSLocalizedString(@"End Call", @"A button's title to end the current Call")
				 forState:UIControlStateNormal];
	_btnEndCall.titleLabel.font = [UIFont boldSystemFontOfSize:20];	
	[_btnEndCall setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	
	UIImage *normalImage = [[UIImage imageNamed:@"button_red.png"] stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0];
	[_btnEndCall setBackgroundImage:normalImage forState:UIControlStateNormal];
	UIImage *pressedImage = [[UIImage imageNamed:@"button_red_pressed.png"] stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0];
	[_btnEndCall setBackgroundImage:pressedImage forState:UIControlStateHighlighted];

	[super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated {	
	self._isHold = FALSE;
	self._isMute = FALSE;
	self._isSpeaker = FALSE;
	
	[_btnHold setImage:nil forState:UIControlStateNormal];
	[_btnSpeaker setImage:nil forState:UIControlStateNormal];
	[_btnMute setImage:nil forState:UIControlStateNormal];
	
	self.min =0;
	self.sec = 0;
	
	uniCallAppDelegate *uniCallApp = (uniCallAppDelegate *)[[UIApplication sharedApplication] delegate];
	CallInfo *callInfo = [uniCallApp getCallInfo];
	self._callerIdlbl.text = callInfo._name;
	
	[super viewWillAppear:animated];
}

-(IBAction)endCall:(id)sender {
	//just testing timer -> location wrong
	[self._callTimer invalidate];
	
	uniCallAppDelegate *uniCallApp = (uniCallAppDelegate *)[[UIApplication sharedApplication] delegate];
	CallInfo *callInfo = [uniCallApp getCallInfo];
	callInfo._event = CALL_EVENT_END;
	[uniCallApp performSelectorOnMainThread:@selector(uniCallEventHandler)
								 withObject:nil
							  waitUntilDone:NO
	 ];
}

- (void)fireTimer{
	
	self._duration = -[_callTime timeIntervalSinceNow];
	NSLog(@"INFO	CallViewController	durtion=%f", (_duration));
	
	self.sec++;
	NSMutableString *duration = [[NSMutableString alloc] init];
	
	if (self.sec == 60) {
		self.min++;
		self.sec=0;
	}
	if (self.min == 60) {
		self.hour++;
		self.min =0;
	}
	
	if (hour) {
		[duration appendFormat:@"%02d:%02d:%02d", self.hour, self.min, self.sec];
	} else {
		[duration appendFormat:@"%02d:%02d", self.min, self.sec];
		
	}
	
	self._callstatuslbl.text = duration;
	
	[duration release];
	
}

-(void)startCallTimer {
	self._callTimer = [NSTimer scheduledTimerWithTimeInterval: 1.0
													   target: self 
													 selector: @selector(fireTimer) 
													 userInfo: nil 
													  repeats: YES
					   ];
	
	/* initilize the time */
	_callTime = [[NSDate alloc] init];
	
	NSLog(@"CallViewController Start timer %@", [_callTime description]);
}

- (IBAction) muteCall:(id)sender
{
	if (self._isMute) {
		uniCallAppDelegate *uniCallApp = (uniCallAppDelegate *)[[UIApplication sharedApplication] delegate];
		[uniCallApp callStatusHandler:CALL_EVENT_UNMUTE];
		
		[_btnMute setImage:nil forState:UIControlStateNormal];
		_isMute = NO;
	} else {
		uniCallAppDelegate *uniCallApp = (uniCallAppDelegate *)[[UIApplication sharedApplication] delegate];
		[uniCallApp callStatusHandler:CALL_EVENT_MUTE];
		
		[_btnMute setImage:[UIImage imageNamed:@"call_mute_pressed"] forState:UIControlStateNormal];
		_isMute = YES;
	}

}

-(IBAction) holdCall:(id) sender
{
	if (self._isHold) {
		uniCallAppDelegate *uniCallApp = (uniCallAppDelegate *)[[UIApplication sharedApplication] delegate];
		[uniCallApp callStatusHandler:CALL_EVENT_UNHOLD];
		_isHold = NO;
		[_btnHold setImage:[UIImage imageNamed:nil] forState:UIControlStateNormal];
	} else {
		uniCallAppDelegate *uniCallApp = (uniCallAppDelegate *)[[UIApplication sharedApplication] delegate];
		[uniCallApp callStatusHandler:CALL_EVENT_HOLD];
		_isHold = YES;
		[_btnHold setImage:[UIImage imageNamed:@"call_hold_pressed.png"] forState:UIControlStateNormal];
	}

}

-(IBAction) setSpeaker:(id)sender
{
	
	//Set the value of a property.
	//This function can be called to set the value for a property of the AudioSession.
	
	OSStatus status;
	
	if (self._isSpeaker) {
		UInt32 none = kAudioSessionOverrideAudioRoute_None;
		status = AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute, 
										  sizeof(none),
										  &none);
		self._isSpeaker = FALSE;
		[_btnSpeaker setImage:nil forState:UIControlStateNormal];
	} else {
		UInt32 speaker = kAudioSessionOverrideAudioRoute_Speaker;
		status = AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute, 
										  sizeof(speaker),
										  &speaker);
		self._isSpeaker = TRUE;
		[_btnSpeaker setImage:[UIImage imageNamed:@"Call_Speaker_Pressed.png"] forState:UIControlStateNormal];
	}
	//the operation was successful.
	if (status != kAudioSessionNoError) {
		//TODO: delete alert
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ERROR"
														message:@"An error occured while setting the speaker"
													   delegate:nil
											  cancelButtonTitle:@"Ok"
											  otherButtonTitles:nil
							  ];
		[alert show];
		[alert release];
		NSLog(@"CallViewController ERROR can not set the speaker");
	}
	
}

- (IBAction) showKeypad
{
	//show keypad
	
	//hide keypad
	
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[_callTime release];
	[_callerIdlbl release];
	
	[_lblHold release];
	[_lblSpeaker release];
	[_lblMute release];
	
	[_callstatuslbl release];
	[_btnHold release];
	[_btnSpeaker release];
	//[_btnKeyboard release];
	[_btnMute release];
	[_btnEndCall release];
	[_callTimer release];
    [super dealloc];
}

@end