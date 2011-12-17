//
//  KeypadViewConroller.m
//  uniCall
//
//  Created by Hussain Yaqoob on 3/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "KeypadViewConroller.h"


@implementation KeypadViewConroller

@synthesize dialedNumber;
@synthesize lblCall;

@synthesize keypadOne;
@synthesize keypadTwo;
@synthesize keypadThree;
@synthesize keypadFour;
@synthesize keypadFive;
@synthesize keypadSix;
@synthesize keypadSeven;
@synthesize keypadNine;
@synthesize keypadZero;
@synthesize keypadEight;
@synthesize keypadStar;
@synthesize keypadHash;
@synthesize keypadDelete;
@synthesize keypadSipCall;
@synthesize keypadPhoneCall;

@synthesize silent;
@synthesize vibrate;

@synthesize deleteTimer;
@synthesize numTimerCount;

#pragma mark -
#pragma mark Viwe LifeCycle

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	
	//
	// assign images to keypad buttons
	//
	UIImage *pressedImageOne = [UIImage imageNamed:@"Keypad_1_Pressed.png"];
	[keypadOne setBackgroundImage:pressedImageOne forState:UIControlStateHighlighted];
	
	UIImage *pressedImageTwo = [UIImage imageNamed:@"Keypad_2_Pressed.png"];
	[keypadTwo setBackgroundImage:pressedImageTwo forState:UIControlStateHighlighted];
	
	UIImage *pressedImageThree = [UIImage imageNamed:@"Keypad_3_Pressed.png"];
	[keypadThree setBackgroundImage:pressedImageThree forState:UIControlStateHighlighted];
	
	UIImage *pressedImageFour = [UIImage imageNamed:@"Keypad_4_Pressed.png"];
	[keypadFour setBackgroundImage:pressedImageFour forState:UIControlStateHighlighted];
	
	UIImage *pressedImageFive = [UIImage imageNamed:@"Keypad_5_Pressed.png"];
	[keypadFive setBackgroundImage:pressedImageFive forState:UIControlStateHighlighted];
	
	UIImage *pressedImageSix = [UIImage imageNamed:@"Keypad_6_Pressed.png"];
	[keypadSix setBackgroundImage:pressedImageSix forState:UIControlStateHighlighted];
	
	UIImage *pressedImageSeven = [UIImage imageNamed:@"Keypad_7_Pressed.png"];
	[keypadSeven setBackgroundImage:pressedImageSeven forState:UIControlStateHighlighted];
	
	UIImage *pressedImageEight = [UIImage imageNamed:@"Keypad_8_Pressed.png"];
	[keypadEight setBackgroundImage:pressedImageEight forState:UIControlStateHighlighted];
	
	UIImage *pressedImageNine = [UIImage imageNamed:@"Keypad_9_Pressed.png"];
	[keypadNine setBackgroundImage:pressedImageNine forState:UIControlStateHighlighted];
	
	UIImage *pressedImageZero = [UIImage imageNamed:@"Keypad_0_Pressed.png"];
	[keypadZero setBackgroundImage:pressedImageZero forState:UIControlStateHighlighted];
	
	UIImage *pressedImageStar = [UIImage imageNamed:@"Keypad_star_Pressed.png"];
	[keypadStar setBackgroundImage:pressedImageStar forState:UIControlStateHighlighted];
	
	UIImage *pressedImageHash = [UIImage imageNamed:@"Keypad_#_Pressed.png"];
	[keypadHash setBackgroundImage:pressedImageHash forState:UIControlStateHighlighted];
	
	UIImage *pressedImageDelete = [UIImage imageNamed:@"Keypad_Delete_Pressed.png"];
	[keypadDelete setBackgroundImage:pressedImageDelete forState:UIControlStateHighlighted];
	
	UIImage *pressedImageSipCall = [UIImage imageNamed:@"Keypad_Call_Pressed.png"];
	[keypadSipCall setBackgroundImage:pressedImageSipCall forState:UIControlStateHighlighted];
	
	UIImage *pressedImagePhoneCall = [UIImage imageNamed:@"Keypad_AddContact_Pressed.png"];
	[keypadPhoneCall setBackgroundImage:pressedImagePhoneCall forState:UIControlStateHighlighted];
	
	//silent = [[NSUserDefaults standardUserDefaults] boolForKey:kAppSilent];
	//vibrate = [[NSUserDefaults standardUserDefaults] boolForKey:kAppVibrate];
	
	[lblCall setText:NSLocalizedString(@"Call", @"A button's title for calling")];
	numTimerCount = 0;
	
    [super viewDidLoad];
	
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
	
	[dialedNumber release];
	[lblCall release];
	
	[keypadOne release];
	[keypadTwo release];
	[keypadThree release];
	[keypadFour release];
	[keypadFive release];
	[keypadSix release];
	[keypadSeven release];
	[keypadNine release];
	[keypadZero release];
	[keypadEight release];
	[keypadStar release];
	[keypadHash release];
	[keypadDelete release];
	[keypadSipCall release];
	[keypadPhoneCall release];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dealloc {
	[deleteTimer release];
    [super dealloc];
}


#pragma mark -
#pragma mark Application Status



#pragma mark -
#pragma mark keypad button pressed

-(IBAction)keypadOnePressed: (id)sender {
	self.dialedNumber.text = [dialedNumber.text stringByAppendingFormat:@"1"];
	[self palySoundForButton:@"1"];
}

-(IBAction)keypadTwoPressed: (id)sender {
	dialedNumber.text = [dialedNumber.text stringByAppendingFormat:@"2"];
	[self palySoundForButton:@"2"];
}

-(IBAction)keypadThreePressed: (id)sender {
	dialedNumber.text = [dialedNumber.text stringByAppendingFormat:@"3"];
	[self palySoundForButton:@"3"];
}

-(IBAction)keypadFourPressed: (id)sender {
	dialedNumber.text = [dialedNumber.text stringByAppendingFormat:@"4"];
	[self palySoundForButton:@"4"];
}

-(IBAction)keypadFiveressed: (id)sender {
	dialedNumber.text = [dialedNumber.text stringByAppendingFormat:@"5"];
	[self palySoundForButton:@"5"];
}

-(IBAction)keypadSixPressed: (id)sender {
	dialedNumber.text = [dialedNumber.text stringByAppendingFormat:@"6"];
	[self palySoundForButton:@"6"];
	
}

-(IBAction)keypadSevenPressed: (id)sender {
	dialedNumber.text = [dialedNumber.text stringByAppendingFormat:@"7"];
	[self palySoundForButton:@"7"];
	
}

-(IBAction)keypadEightPressed: (id)sender {
	dialedNumber.text = [dialedNumber.text stringByAppendingFormat:@"8"];
	[self palySoundForButton:@"8"];
	
}

-(IBAction)keypadNinePressed: (id)sender {
	dialedNumber.text = [dialedNumber.text stringByAppendingFormat:@"9"];
	[self palySoundForButton:@"9"];
}

-(IBAction)keypadZeroPressed: (id)sender {
	dialedNumber.text = [dialedNumber.text stringByAppendingFormat:@"0"];
	[self palySoundForButton:@"0"];
}

-(IBAction)keypadStarPressed: (id)sender {
	dialedNumber.text = [dialedNumber.text stringByAppendingFormat:@"*"];
	//[self palySoundForButton:@"*"];
	[self palySoundForButton:@"s"];
}

-(IBAction)keypadHashPressed: (id)sender {
	dialedNumber.text = [dialedNumber.text stringByAppendingFormat:@"#"];
	[self palySoundForButton:@"#"];
}

#pragma mark -
#pragma mark play sound for button

-(void)palySoundForButton:(NSString *) button {
	silent = [[NSUserDefaults standardUserDefaults] boolForKey:kAppSilent];
	if (!silent) {
		
		SystemSoundID soundID;
		NSString *file = [[NSString alloc] initWithFormat:@"keypad_sound_%@", button];
		NSString *soundFile = [[NSBundle mainBundle]
							   pathForResource:file ofType:@"aif"];
		AudioServicesCreateSystemSoundID((CFURLRef) [NSURL fileURLWithPath:soundFile], &soundID);
		AudioServicesPlaySystemSound(soundID);
		
		[file release];
		[soundFile release];
	
	}
}

#pragma mark -
#pragma mark make Call

//not implemented yet
-(IBAction)keypadSipCallPressed: (id)sender {
	
	if ([dialedNumber.text length] > 0) {
		//call sip
		uniCallAppDelegate *uniCallApp = (uniCallAppDelegate *)[[UIApplication sharedApplication] delegate];
		[uniCallApp reinitCallInfo];
		CallInfo *callInfo = [uniCallApp getCallInfo];
		callInfo._event = CALL_EVENT_OUTGOING;
		callInfo._number = dialedNumber.text;
		callInfo._time = [[NSDate alloc] init];
		[uniCallApp uniCallEventHandler];
	}
}

/*
 When the user wants to call but he is not register
*/


#pragma mark -
#pragma mark Add/Update Contact Button Pressed

-(IBAction)keypadAddContactPressed: (id)sender {
	
	if ([dialedNumber.text length] > 0) {
		UIActionSheet *actionSheet;
		actionSheet = [[UIActionSheet alloc] initWithTitle:nil
												  delegate:self
										 cancelButtonTitle:NSLocalizedString(@"Cancel", @"")
									destructiveButtonTitle:nil
										 otherButtonTitles:NSLocalizedString(@"Create New Contact", @""), NSLocalizedString(@"Add to Existing Contact", @""), nil];

		actionSheet.actionSheetStyle = UIBarStyleBlackTranslucent;
		uniCallAppDelegate *uniCallApp = (uniCallAppDelegate *)[[UIApplication sharedApplication] delegate];
		[actionSheet showInView:[uniCallApp tabBarController].view];
		[actionSheet release];
	}
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	
	//only one ActionSheet
	NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
	if([buttonTitle isEqualToString:NSLocalizedString(@"Create New Contact", @"")]) {
		//
		[self createNewContact:[dialedNumber text]];
	} else if ([buttonTitle isEqualToString:NSLocalizedString(@"Add to Existing Contact", @"")]) {
		//
		[self updateExistingContact];
	} else {
		//Cancel button pressed
	}
}

#pragma mark -
#pragma mark ABNewPersonViewController
- (void)createNewContact:(NSString *) mobileNumber
{
	ABNewPersonViewController *newPersonViewController = [[ABNewPersonViewController alloc] init];
	newPersonViewController.newPersonViewDelegate = self;
	
	//add number ot newPerson
	ABRecordRef person = ABPersonCreate();
	CFErrorRef error = NULL;
	ABMultiValueRef phone = ABMultiValueCreateMutable(kABStringPropertyType);

	bool didAdd = ABMultiValueAddValueAndLabel(phone, mobileNumber, kABPersonPhoneMobileLabel, NULL);
	
	if (didAdd == YES)
	{
		ABRecordSetValue(person, kABPersonPhoneProperty, phone, &error);
		if (error == NULL) {
			newPersonViewController.displayedPerson = person;
		} else {
			
		}
		
	}
	UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:newPersonViewController];
	[self presentModalViewController:navigation animated:YES];
	
	[newPersonViewController release];
	[navigation release];
	
}

- (void)newPersonViewController:(ABNewPersonViewController *)newPersonView 
	   didCompleteWithNewPerson:(ABRecordRef)person {
	
	[newPersonView dismissModalViewControllerAnimated:YES];
	
}

#pragma mark -
#pragma mark ABPeoplePickerNavigationControllerDelegate
-(void)updateExistingContact {
	
	ABPeoplePickerNavigationController *picker = [[ABPeoplePickerNavigationController alloc] init];
    picker.peoplePickerDelegate = self;
	// Display only a person's phone, email, and birthdate
	//NSArray *displayedItems = [NSArray arrayWithObjects:[NSNumber numberWithInt:kABPersonPhoneProperty], 
	//						   [NSNumber numberWithInt:kABPersonEmailProperty],
	//						   [NSNumber numberWithInt:kABPersonBirthdayProperty], nil];
	//
	
	//picker.displayedProperties = displayedItems;
	// Show the picker 
	[self presentModalViewController:picker animated:YES];
    [picker release];
}

- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker {
	
	[peoplePicker dismissModalViewControllerAnimated:YES];
	
}

// Called after a person has been selected by the user.
// Return YES if you want the person to be displayed.
// Return NO  to do nothing (the delegate is responsible for dismissing the peoplePicker).
- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker 
	  shouldContinueAfterSelectingPerson:(ABRecordRef)person {

	ABRecordID personID = ABRecordGetRecordID(person);
	[peoplePicker dismissModalViewControllerAnimated:NO];
	[self performSelector:@selector(presentSelectedPerson:) withObject:(id)personID];
	
	//peoplePicker.allowsEditing = YES;
	//peoplePicker.editing = YES;
	return NO;
	
}

-(void) presentSelectedPerson:(ABRecordID)personID {
	if ([self modalViewController]) {
		[self dismissModalViewControllerAnimated:NO];
	}
	
	// Fetch the address book 
	ABAddressBookRef addressBook = ABAddressBookCreate();
		
	//ABRecordRef person = (ABRecordRef)[people objectAtIndex:0];
	ABPersonViewController *picker = [[ABPersonViewController alloc] init] ;
	picker.personViewDelegate = self;
	ABRecordRef person = ABAddressBookGetPersonWithRecordID(addressBook, personID);
	CFErrorRef error = NULL;
	//ABMultiValueRef phone = ABMultiValueCreateMutable(kABStringPropertyType);
	ABMultiValueRef phone;
	
	CFTypeRef typeRef = ABRecordCopyValue(person, kABPersonPhoneProperty);
	if (ABMultiValueGetCount(typeRef) == 0)
		phone = ABMultiValueCreateMutable(kABStringPropertyType);
	else
		phone = ABMultiValueCreateMutableCopy (typeRef);
	
	//phone = ABMultiValueAddValueAndLabel(multiValue, [dialedNumber text], kABPersonPhoneMainLabel, 
	//									  NULL);  
	
	bool didAdd = ABMultiValueAddValueAndLabel(phone, [dialedNumber text], kABPersonPhoneMobileLabel, NULL);
	
	if (didAdd == YES)
	{
		ABRecordSetValue(person, kABPersonPhoneProperty, phone, &error);
		if (error == NULL) {
			picker.displayedPerson = person;
		} else {
			
		}
		
	}
	//picker.displayedPerson = person;
	UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Dismiss", @"")
																	style:UIBarButtonSystemItemCancel
																   target:self
																   action:@selector(dismissUpdateExistingContactView)
									];
	picker.navigationItem.backBarButtonItem = rightButton;
	// Allow users to edit the person’s information
	picker.allowsEditing = YES;
	picker.editing = YES;
	
	//[self presentModalViewController:picker animated:YES];
	UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:picker];
	//uniCallAppDelegate *uniCallApp = (uniCallAppDelegate *)[[UIApplication sharedApplication] delegate];
	//[[uniCallApp tabBarController].navigationController pushViewController:navigation animated:YES];

	//navigation.navigationController.navigationItem.leftBarButtonItem = rightButton;								
	//navigation.navigationItem.leftBarButtonItem = rightButton;
	[rightButton release];
	
	[self presentModalViewController:navigation animated:YES];
	
	[picker release];
	[navigation release];
		
		//[self.navigationController pushViewController:picker animated:YES];
	/*}
	else 
	{
		// Show an alert if "Appleseed" is not in Contacts
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" 
														message:@"Could not find Appleseed in the Contacts application" 
													   delegate:nil 
											  cancelButtonTitle:@"Cancel" 
											  otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
	
	[people release];
	CFRelease(addressBook);

	 */
	/*
	CFErrorRef error;
	
	ABAddressBookRef addressBook = ABAddressBookCreate();
	NSArray *people = (NSArray *)ABAddressBookCopyPeopleWithName(addressBook, CFSTR("Husain"));
	ABRecordRef person = (ABRecordRef)[people objectAtIndex:0];
	// Make a new ABMultiValue property for the phone number and add it to the person
	ABMultiValueRef multi = ABMultiValueCreateMutableCopy(ABRecordCopyValue(person, kABPersonPhoneProperty));
	bool didAdd = ABMultiValueAddValueAndLabel(multi, [dialedNumber text], kABPersonPhoneMobileLabel, NULL); 
	if (didAdd)
	{
		if(ABRecordSetValue(person, kABPersonPhoneProperty, multi, &error))
		{
			NSLog(@"Added kABPersonPhoneProperty for user");
		}
	}
	
	//NSLog(@"%@", s);
	if(ABAddressBookHasUnsavedChanges(addressBook))
	{
		NSLog(@"Never actually gets here");
	}
	
	ABAddressBookSave(addressBook, &error);
	 */
	
	//ABMutableMultiValueRef phoneNumberMultiValue =  ABMultiValueCreateMutableCopy (ABRecordCopyValue(person, kABPersonPhoneProperty));
	//ABMultiValueAddValueAndLabel(phoneNumberMultiValue, phone,  kABPersonPhoneMobileLabel, NULL);
	//ABRecordSetValue(person, kABPersonPhoneProperty, phoneNumberMultiValue, nil);
	//ABNewPersonViewController *newPersonViewController = [[ABNewPersonViewController alloc] init];
	//newPersonViewController.newPersonViewDelegate = self;
	
	//add number ot newPerson
	//ABRecordRef person = person;
	//CFErrorRef error = NULL;
	//ABMultiValueRef phone = ABMultiValueCreateMutable(kABStringPropertyType);
	
	//bool didAdd = ABMultiValueAddValueAndLabel(phone, mobileNumber, kABPersonPhoneMobileLabel, NULL);
	
	//if (didAdd == YES)
	//{
	//	ABRecordSetValue(person, kABPersonPhoneProperty, phone, &error);
	//	if (error == NULL) {
			//newPersonViewController.displayedPerson = person;
	//	} else {
	//		
	//	}
	//	
	//}
	//UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:newPersonViewController];
	//[self presentModalViewController:navigation animated:YES];
	
	//[newPersonViewController release];
	//[navigation release];
	

}

- (BOOL)personViewController:(ABPersonViewController *)personViewController shouldPerformDefaultActionForPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier {
	[self dismissModalViewControllerAnimated:NO];
	return YES;
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker 
	  shouldContinueAfterSelectingPerson:(ABRecordRef)person 
								property:(ABPropertyID)property 
							  identifier:(ABMultiValueIdentifier)identifier {
	
	return NO;
}

-(void) dismissUpdateExistingContactView {
	[self dismissModalViewControllerAnimated:NO];
}


#pragma mark -
#pragma mark delete number
-(IBAction)keypadDeletePressed: (id)sender {
	self.deleteTimer = [NSTimer scheduledTimerWithTimeInterval:0.1
														target:self
													  selector:@selector(deleteNumber)
													  userInfo:nil
													   repeats:YES
						];
	NSLog(@"KeypadViewController:: KeypadDeletePressed:: delete button pressed");
}

-(void)deleteNumber {
	if ([dialedNumber.text length] > 0) {

		if (numTimerCount == 0) {
			dialedNumber.text = [dialedNumber.text substringToIndex:[dialedNumber.text length]-1];
			numTimerCount++;
		} else if (numTimerCount < 3) {
			numTimerCount++;
		} else if (numTimerCount < 7) {
			dialedNumber.text = [dialedNumber.text substringToIndex:[dialedNumber.text length]-1];
			numTimerCount++;
		} else {
			dialedNumber.text = [dialedNumber.text substringToIndex:[dialedNumber.text length]-1];
			dialedNumber.text = [dialedNumber.text substringToIndex:[dialedNumber.text length]-1];
		}

		
	} else {
		[deleteTimer invalidate];
	}

}

-(IBAction)keypadDeleteUnPressed: (id)sender {
	[deleteTimer invalidate];
	numTimerCount = 0;
	NSLog(@"KeypadViewController:: KeypadDeleteUnPressed:: delete button un-pressed");
}

@end