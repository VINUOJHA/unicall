//
//  ContactDevelopersViewController.m
//  uniCall
//
//  Created by Hussain Yaqoob on 6/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ContactDevelopersViewController.h"


@implementation ContactDevelopersViewController

@synthesize iphoneDev;
@synthesize androidDev;
@synthesize error;

@synthesize composeEmail;
@synthesize composeSMS;

#pragma mark -
#pragma mark Dismiss Mail/SMS view controller

- (void)mailComposeController:(MFMailComposeViewController*)controller 
		  didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
	
	self.error.hidden = NO;
	// Notifies users about errors associated with the interface
	switch (result)
	{
		case MFMailComposeResultCancelled:
			self.error.text = NSLocalizedString(@"Result: Mail sending canceled", @"");
			break;
		case MFMailComposeResultSaved:
			self.error.text = NSLocalizedString(@"Result: Mail saved", @"");
			break;
		case MFMailComposeResultSent:
			self.error.text = NSLocalizedString(@"Result: Mail sent", @"");
			break;
		case MFMailComposeResultFailed:
			self.error.text = NSLocalizedString(@"Result: Mail sending failed", @"");
			break;
		default:
			self.error.text = NSLocalizedString(@"Result: Mail not sent", @"");
			break;
	}
	[self dismissModalViewControllerAnimated:YES];
}


// Dismisses the message composition interface when users tap Cancel or Send. Proceeds to update the 
// feedback message field with the result of the operation.
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller 
				 didFinishWithResult:(MessageComposeResult)result {
	
	self.error.hidden = NO;
	// Notifies users about errors associated with the interface
	switch (result)
	{
		case MessageComposeResultCancelled:
			self.error.text = NSLocalizedString(@"Result: SMS sending canceled", @"");
			break;
		case MessageComposeResultSent:
			self.error.text = NSLocalizedString(@"Result: SMS sent", @"");
			break;
		case MessageComposeResultFailed:
			self.error.text = NSLocalizedString(@"Result: SMS sending failed", @"");
			break;
		default:
			self.error.text = NSLocalizedString(@"Result: SMS not sent", @"");
			break;
	}
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark compose and send Email
-(IBAction) sendEmail:(id) sender {
	
	Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
	
	if (mailClass != nil) {
	
		if ([mailClass canSendMail]) {
			[self displayMailComposerSheet];
		}
		else {
			error.hidden = NO;
			error.text = NSLocalizedString(@"Device not configured to send mail.", @"");
		}
	}
	else	{
		error.hidden = NO;
		error.text = NSLocalizedString(@"Device not configured to send mail.", @"");
	}
}

// Displays an email composition interface inside the application. Populates all the Mail fields. 
-(void)displayMailComposerSheet 
{
	MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
	picker.mailComposeDelegate = self;
	
	[picker setSubject:NSLocalizedString(@"uniCall Application feedback", @"")];
	
	
	// Set up recipients
	NSArray *toRecipients = [NSArray arrayWithObject:@"husain.yaqoob@googlemail.com"]; 
	NSArray *ccRecipients = [NSArray arrayWithObjects:@"tareq.aljarrah@gmail.com", nil]; 	
	[picker setToRecipients:toRecipients];
	[picker setCcRecipients:ccRecipients];
	
	// Fill out the email body text
	NSString *emailBody = NSLocalizedString(@"Dear uniCall Developers,\n", @"");
	[picker setMessageBody:emailBody isHTML:NO];
	
	[self presentModalViewController:picker animated:YES];
	[picker release];
}

#pragma mark -
#pragma mark compse and send SMS
-(IBAction) sendSMS:(id) sender {

	Class messageClass = (NSClassFromString(@"MFMessageComposeViewController"));
	
	if (messageClass != nil) { 			
		// Check whether the current device is configured for sending SMS messages
		if ([messageClass canSendText]) {
			[self displaySMSComposerSheet];
		}
		else {	
			error.hidden = NO;
			error.text = NSLocalizedString(@"Device not configured to send SMS.", @"");			
		}
	}
	else {
		error.hidden = NO;
		error.text = NSLocalizedString(@"Device not configured to send SMS.", @"");
	}
}

// Displays an SMS composition interface inside the application. 
-(void)displaySMSComposerSheet 
{
	MFMessageComposeViewController *picker = [[MFMessageComposeViewController alloc] init];
	picker.messageComposeDelegate = self;
	
	[self presentModalViewController:picker animated:YES];
	[picker release];
}

#pragma mark -
#pragma mark View Lifecycle
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

	self.error.text = @"";
	self.title = NSLocalizedString(@"Developers", @"");
	[self.composeSMS setTitle:NSLocalizedString(@"Compose SMS", @"") 
					 forState:UIControlStateNormal];
	[self.composeEmail setTitle:NSLocalizedString(@"Compose Email", @"")
					   forState:UIControlStateNormal];
	self.iphoneDev.text = NSLocalizedString(@"Husain M. Y. Naser\nIPhone Developer\nuniCall Team", @"");
    self.androidDev.text = NSLocalizedString(@"Tareq Jarrah\nAndroid Developer\nuniCall Team", @"");
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
	[iphoneDev release];
	[androidDev release];
	[error release];
	
	[composeEmail release];
	[composeSMS release];
	
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
