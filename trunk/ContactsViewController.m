//
//  ContactsViewController.m
//  uniCall
//
//  Created by Hussain Yaqoob on 3/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ContactsViewController.h"
#import "uniCallAppDelegate.h"

@interface ABPeoplePickerNavigationController ()

- (void)setAllowsCardEditing:(BOOL)allowCardEditing;
- (void)setAllowsCancel:(BOOL)allowsCancel;

@end

@implementation ContactsViewController
/*
- (id)init 
{
	self = [super init];
	if (self) 
	{
		// Initialization code
		self.tabBarItem = [[UITabBarItem alloc] initWithTabBarSystemItem: 
						   UITabBarSystemItemContacts tag:3];
		self.peoplePickerDelegate = self;
		self.navigationBar.barStyle = UIBarStyleBlackOpaque;
		
		[self setAllowsCardEditing:YES];
		[self setAllowsCancel:NO];
	}
	return self;
}
*/

- (void)setEditing:(BOOL)flag animated:(BOOL)animated {
	[super setEditing:flag animated:animated];
	if (flag == YES){
		// change view to an editable view
	}
	else {
		// save the changes if needed and change view to noneditable
	}
}

- (void)setAllowsCancel:(BOOL)allowsCancel{
	
}

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically.
- (void)loadView 
{
	[super loadView];
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	
	//ABPeoplePickerNavigationController *picker;
	//picker = [[ABPeoplePickerNavigationController alloc] init];
	//picker.peoplePickerDelegate = self;
	//[self presentModalViewController:picker animated:YES];
	//[picker release];
    [super viewDidLoad];
}
*/

- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker {
	
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker 
	  shouldContinueAfterSelectingPerson:(ABRecordRef)person {
	
	return YES;
	
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker 
	  shouldContinueAfterSelectingPerson:(ABRecordRef)person 
								property:(ABPropertyID)property 
							  identifier:(ABMultiValueIdentifier)identifier {
	
	ABMultiValueRef phoneProperty = ABRecordCopyValue(person, property);
	NSInteger phoneIndex = ABMultiValueGetIndexForIdentifier(phoneProperty, identifier);
	NSString *phone = (NSString *)ABMultiValueCopyValueAtIndex(phoneProperty, phoneIndex);
	NSLog(@"The phone number selected is %@:", phone);
	CFRelease(phoneProperty);
	[phone release];
	
	return NO;
}


- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:YES];
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
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
