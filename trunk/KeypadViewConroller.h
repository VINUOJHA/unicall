//
//  KeypadViewConroller.h
//  uniCall
//
//  Created by Hussain Yaqoob on 3/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

#import "uniCallAppDelegate.h"

@interface KeypadViewConroller : UIViewController <UIActionSheetDelegate, ABNewPersonViewControllerDelegate,
ABPeoplePickerNavigationControllerDelegate, ABPersonViewControllerDelegate> {
	
	IBOutlet UILabel *dialedNumber;
	IBOutlet UILabel *lblCall;
	
	IBOutlet UIButton *keypadOne;
	IBOutlet UIButton *keypadTwo;
	IBOutlet UIButton *keypadThree;
	IBOutlet UIButton *keypadFour;
	IBOutlet UIButton *keypadFive;
	IBOutlet UIButton *keypadSix;
	IBOutlet UIButton *keypadSeven;
	IBOutlet UIButton *keypadNine;
	IBOutlet UIButton *keypadZero;
	IBOutlet UIButton *keypadEight;
	IBOutlet UIButton *keypadStar;
	IBOutlet UIButton *keypadHash;
	IBOutlet UIButton *keypadDelete;
	IBOutlet UIButton *keypadSipCall;
	IBOutlet UIButton *keypadPhoneCall;
	
	BOOL silent;
	BOOL vibrate;
	
	int numTimerCount;
	NSTimer *deleteTimer;

}

@property (nonatomic, retain) UILabel *dialedNumber;
@property (nonatomic, retain) UILabel *lblCall;

@property (nonatomic, retain) UIButton *keypadOne;
@property (nonatomic, retain) UIButton *keypadTwo;
@property (nonatomic, retain) UIButton *keypadThree;
@property (nonatomic, retain) UIButton *keypadFour;
@property (nonatomic, retain) UIButton *keypadFive;
@property (nonatomic, retain) UIButton *keypadSix;
@property (nonatomic, retain) UIButton *keypadSeven;
@property (nonatomic, retain) UIButton *keypadEight;
@property (nonatomic, retain) UIButton *keypadNine;
@property (nonatomic, retain) UIButton *keypadZero;
@property (nonatomic, retain) UIButton *keypadStar;
@property (nonatomic, retain) UIButton *keypadHash;
@property (nonatomic, retain) UIButton *keypadDelete;
@property (nonatomic, retain) UIButton *keypadSipCall;
@property (nonatomic, retain) UIButton *keypadPhoneCall;

@property (nonatomic, assign) BOOL silent;
@property (nonatomic, assign) BOOL vibrate;

@property (nonatomic, retain) NSTimer *deleteTimer;
@property (nonatomic, assign) int numTimerCount;

-(IBAction)keypadOnePressed: (id)sender;
-(IBAction)keypadTwoPressed: (id)sender;
-(IBAction)keypadThreePressed: (id)sender;
-(IBAction)keypadFourPressed: (id)sender;
-(IBAction)keypadFiveressed: (id)sender;
-(IBAction)keypadSixPressed: (id)sender;
-(IBAction)keypadSevenPressed: (id)sender;
-(IBAction)keypadEightPressed: (id)sender;
-(IBAction)keypadNinePressed: (id)sender;
-(IBAction)keypadZeroPressed: (id)sender;
-(IBAction)keypadStarPressed: (id)sender;
-(IBAction)keypadHashPressed: (id)sender;

-(void)palySoundForButton:(NSString *) button;

-(IBAction)keypadSipCallPressed: (id)sender;

-(IBAction)keypadAddContactPressed: (id)sender;
- (void)createNewContact:(NSString *) mobileNumber;
- (void)updateExistingContact;
- (void) presentSelectedPerson:(ABRecordID)personID;
-(void) dismissUpdateExistingContactView;

-(IBAction)keypadDeletePressed: (id)sender;
-(IBAction)keypadDeleteUnPressed: (id)sender;
-(void)deleteNumber;

@end