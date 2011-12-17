//
//  SettingViewController.m
//  uniCall
//
//  Created by Hussain Yaqoob on 3/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SettingViewController.h"


@implementation SettingViewController

@synthesize txtUsername;
@synthesize txtPassword;
@synthesize status;

-(IBAction)hideKeyboard: (id)sender {
	[txtPassword resignFirstResponder];
	[txtUsername resignFirstResponder];
	
}

-(NSArray *)getResponse:(NSString *)request {
	status.text = @"enter getResponse";
	NSString *balanceQuery = [NSString stringWithFormat:@"https://gateway1.vectrafon.com/A2BCustomer_UI/vectrafon/API.php?username=%@&password=%@&%@",self.txtUsername.text, self.txtPassword.text, request];
	NSURL *url = [NSURL URLWithString:balanceQuery];
	NSURLRequest *theRequest = [NSURLRequest requestWithURL:url];
	NSURLResponse *resp = nil;
	NSError *err = nil;
	NSData *response = [NSURLConnection sendSynchronousRequest:theRequest returningResponse: &resp error:&err];
	NSString * theString = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
	NSArray *listItems = [theString componentsSeparatedByString:@"\n"];
	return listItems;
}

-(IBAction)login:(id)sender {
	
	if ((self.txtPassword.text!=nil)&&(self.txtUsername.text!=nil)) {

		NSArray *resp = [self getResponse:@"request=balance"];
		if ([[resp objectAtIndex:0] isEqualToString:@"200"]) {
			
			UILabel *balance = [[UILabel alloc] initWithFrame:CGRectMake(20, 192, 280, 32)];
			NSString *balanceText = [NSString stringWithFormat:@"Balance: $%@", [resp objectAtIndex:2]];
			balance.text = balanceText;
			balance.font = [UIFont systemFontOfSize: 20];
			balance.lineBreakMode = UILineBreakModeWordWrap;
			balance.numberOfLines = 0;
			balance.textColor = [UIColor whiteColor];
			balance.backgroundColor = [UIColor clearColor];
			balance.tag=50;
			[self.view addSubview: balance];
			[balance release];
			status.textColor = [UIColor greenColor];
			status.text = @"Login Successfully";
		} else {
			status.textColor = [UIColor redColor];
			status.text = [NSString stringWithFormat:@"Status: %@", [resp objectAtIndex:1]];
		}
	} else {
		status.text = @"Enter login not Resp";
	}
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

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
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
	[txtPassword release];
	[txtUsername release];
	[status release];
    [super dealloc];
}


@end
