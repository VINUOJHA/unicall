//
//  SettingViewController.m
//  uniCall
//
//  Created by Hussain Yaqoob on 6/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PreferencesViewController.h"
#import "uniCallAppDelegate.h"

@implementation PreferencesViewController

@synthesize theScroller;

@synthesize lblUsername;
@synthesize lblPassword;
@synthesize lblDomain;

@synthesize txtUsername;
@synthesize txtPassword;
@synthesize txtDomain;

@synthesize btnLogin;
@synthesize btnCreateAccount;
@synthesize navigationBar;
@synthesize feedback;


#pragma mark -
#pragma mark View LifeCycle
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
	
	theScroller.contentSize = CGSizeMake(320.0, 600.0);

	navigationBar.text = NSLocalizedString(@"Setting", @"");
	lblUsername.text = NSLocalizedString(@"Username", @"");
	lblPassword.text = NSLocalizedString(@"Password", @"");
	lblDomain.text = NSLocalizedString(@"Domain", @"");
	[btnLogin setTitle:NSLocalizedString(@"Login", @"") 
			  forState:UIControlStateNormal
	 ];
	[btnCreateAccount setTitle:NSLocalizedString(@"CreateNewAccount", @"") 
			  forState:UIControlStateNormal
	 ];
	
	feedback.text = NSLocalizedString(@"To Change the settings, go to: \n Settings -> uniCall", @"");
	
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	NSString *username = [userDefaults stringForKey:kSipUsername];
	NSString *password = [userDefaults stringForKey:kSipPassword];
	NSString *domain = [userDefaults stringForKey:kSipDomain];
	
	if ([username length] != 0) {
		self.txtUsername.text = username;
	}
	if ([password length] != 0) {
		self.txtPassword.text = password;
	}
	if ([domain length] != 0) {
		self.txtDomain.text = domain;
	}
	
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
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[theScroller release];
	
	[lblUsername release];
	[lblPassword release];
	[lblDomain release];
	
	[txtUsername release];
	[txtPassword release];
	[txtDomain release];
	
	[btnLogin release];
	[btnCreateAccount release];
	[navigationBar release];
	[feedback release];
    [super dealloc];
}

#pragma mark -
#pragma mark <#label#>
-(IBAction)login:(id)sender {
	if ((self.txtUsername.text!=nil) && (self.txtPassword.text!=nil) && (self.txtDomain.text!=nil)
		&& [txtUsername.text length]!=0 && [txtPassword.text length]!=0 && [txtDomain.text length]!=0) {
		
		NSUserDefaults *info = [NSUserDefaults standardUserDefaults];
		[info setObject:txtUsername.text forKey:kSipUsername];
		[info setObject:txtPassword.text forKey:kSipPassword];
		[info setObject:txtDomain.text forKey:kSipDomain];
		[info synchronize];
		[self dismiss];
	} else {
		feedback.textColor = [UIColor redColor];
		self.feedback.text = NSLocalizedString(@"All fields required", @"");
	}

}

-(IBAction)createNewAccount:(id)sender {
	NSURL *website = [[NSURL alloc] initWithString:@"http://aspspider.info/unicall/registration.aspx"];
	[[UIApplication sharedApplication] openURL:website];
	[website release];	
}

-(IBAction)hideKeyboard: (id)sender {
	[txtPassword resignFirstResponder];
	[txtUsername resignFirstResponder];
	[txtDomain resignFirstResponder];
	
}


#pragma mark -
#pragma mark Present/Dismiss view
-(void)present {
	uniCallAppDelegate *uniCallApp = (uniCallAppDelegate *)[[UIApplication sharedApplication] delegate];
	[[uniCallApp tabBarController] presentModalViewController:self animated:YES];
}

-(void)dismiss {
	uniCallAppDelegate *uniCallApp = (uniCallAppDelegate *)[[UIApplication sharedApplication] delegate];
	[[uniCallApp tabBarController] dismissModalViewControllerAnimated:YES];
	[uniCallApp uniCallStartup];
}

@end
