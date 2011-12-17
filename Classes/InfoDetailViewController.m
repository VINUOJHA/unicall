//
//  InfoDetailViewController.m
//  uniCall
//
//  Created by Hussain Yaqoob on 6/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "InfoDetailViewController.h"
#import "uniCallAppDelegate.h"


@implementation InfoDetailViewController

@synthesize name;
@synthesize number;
@synthesize type;
@synthesize date;
@synthesize time;
@synthesize duration;

@synthesize lblName;
@synthesize lblType;
@synthesize lblDate;
@synthesize lblTime;
@synthesize lblDuration;

@synthesize tableView;

#pragma mark -
#pragma mark View Life Cycle

 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
		//self.tableView.dataSource = self;
		//self.tableView.delegate = self;
    }
    return self;
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	self.lblName.text = self.name;
	self.lblType.text = self.type;
	self.lblDate.text = self.date;
	self.lblTime.text = self.time;
	self.lblDuration.text = self.duration;
	
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
	
	[lblName release];
	[lblType release];
	[lblDuration release];
	[lblTime release];
	[lblDate release];
	
	[number release];
	[name release];
	[type release];
	[duration release];
	[time release];
	[date release];
	
	[tableView release];
	
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return kTableSectionsNum;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return kTableRowsNum;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)localTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	static NSString *CellIdentifier = @"Cell";
	
	UITableViewCell *cell = [localTableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 
									   reuseIdentifier:CellIdentifier] autorelease];
		
	}
	
	// Configure the cell...
	[[cell textLabel] setText:NSLocalizedString(@"mobile", @"")];
	[[cell detailTextLabel] setText:number];
	[[cell detailTextLabel] setTextColor:[UIColor blueColor]];
	
    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
    // Navigation logic may go here. Create and push another view controller.
	/*
	 <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
	 [self.navigationController pushViewController:detailViewController animated:YES];
	 [detailViewController release];
	 */
	
	uniCallAppDelegate *uniCallApp = (uniCallAppDelegate *)[[UIApplication sharedApplication] delegate];
	[uniCallApp reinitCallInfo];
	CallInfo *callInfo = [uniCallApp getCallInfo];
	callInfo._event = CALL_EVENT_OUTGOING;
	callInfo._number = number;
	callInfo._name = name;
	callInfo._time = [[NSDate alloc] init];
	[uniCallApp uniCallEventHandler];

}

- (void)dealloc {
    [super dealloc];
}


@end