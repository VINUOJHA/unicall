//
//  uniCallAppDelegate.h
//  uniCall
//
//  Created by Hussain Yaqoob on 3/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

#import </usr/include/sqlite3.h>

#import "IncomingCallViewController.h"

#import "HistoryViewController.h"
#import "ContactsViewController.h"
#import "MoreViewController.h"
#import "PreferencesViewController.h"

#import "CallViewController.h"
#import "CallInfo.h"
#import "Constants.h"

#import "Connectivity.h"
#import "LocationManager.h"

@class uniCallViewController;

@class KeypadViewConroller;

@interface uniCallAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate,
ABPeoplePickerNavigationControllerDelegate> {
	
	IBOutlet UILabel *status;
	
	CallViewController *callViewController;
	IncomingCallViewController *incomingCallViewController;
	
	HistoryViewController *historyViewController;
	KeypadViewConroller *keypadViewController;
	ContactsViewController *contactsViewController;
	MoreViewController *moreViewController;
	
	BOOL registered;
	BOOL connected;
	CallInfo *_callInfo;
	
	Connectivity *connectivity;
	LocationManager *locationManager;
	
	CFURLRef		soundFileURLRef;
	SystemSoundID	soundFileObject;
	
	UIWindow *window;
	UITabBarController *tabBarController;
}

@property (nonatomic, retain) UILabel *status;

@property (nonatomic, retain) CallViewController *callViewController;
@property (nonatomic, retain) IncomingCallViewController *incomingCallViewController;

@property (nonatomic, retain) HistoryViewController *historyViewController;
@property (nonatomic, retain) KeypadViewConroller *keypadViewController;
@property (nonatomic, retain) ContactsViewController *contactsViewController;
@property (nonatomic, retain) MoreViewController *moreViewController;

@property (nonatomic, assign) BOOL registered;
@property (nonatomic, assign) BOOL connected;
@property (nonatomic, retain) CallInfo *_callInfo;

@property (nonatomic, retain) Connectivity *connectivity;
@property (nonatomic, retain) LocationManager *locationManager;

@property (readwrite)	CFURLRef		soundFileURLRef;
@property (readonly)	SystemSoundID	soundFileObject;

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) UITabBarController *tabBarController;

-(void)uniCallStartup;
-(void)uniCallShutdown;

-(void)startRinging;
-(void)stopRinging;

-(void)reinitCallInfo;
-(CallInfo *)getCallInfo;
-(void)updateUniCallAppStatus:(NSString *)message forLevel:(APP_STATUS)status_colour;

-(void)initializeForFirstTime;
-(void) insertCallInfoIntoDatabase:(CALL_TYPE)type 
						callerName:(NSString *)name 
						  callTime:(NSString *)time 
						  callDate:(NSString *)date 
					  callerNumber:(NSString *)number 
					  callDuratoin:(int)duration 
						isLocation:(int)location	// 0 => FALSE, 1 => TRUE
					callerAltitude:(double)altitude 
				   callerLongitude:(double)longitude;
-(void) addCancelledCallToHistory;
-(void) addMissedCallToHistory;
-(void) addIncomingCallToHistory;
-(void) addOutgoingCallToHistory;

-(IBAction)presentCallViewController;
-(IBAction)dismissViewController;
-(IBAction)presentIncomCallViewController;

-(IBAction)callStatusHandler:(CALL_STATUS) status;
-(IBAction)uniCallEventHandler;

@end