//
//  MoreViewController.m
//  uniCall
//
//  Created by Hussain Yaqoob on 6/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MoreViewController.h"


@implementation MoreViewController

#define MoreTableRowsCount 4
#define MoreTableSectionsCount 1

#pragma mark -
#pragma mark Initialization

/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if ((self = [super initWithStyle:style])) {
    }
    return self;
}
*/


#pragma mark -
#pragma mark View lifecycle

/*
- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
*/

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
*/
/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return MoreTableSectionsCount;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return MoreTableRowsCount;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    // Configure the cell...
	switch (indexPath.row) {
		case TABLE_CELL_INDEX_VISIT:
			[[cell textLabel] setText:NSLocalizedString(@"Visit uniCall", @"")];
			cell.imageView.image = [UIImage imageNamed:@"table-visit.png"];
			//[cell setImage:[UIImage imageNamed:@"table-visit.png"]];
			break;
			
		case TABLE_CELL_INDEX_SHARE:
			[[cell textLabel] setText:NSLocalizedString(@"Share on Facebook", @"")];
			cell.imageView.image = [UIImage imageNamed:@"table-facebook.png"];
			//[cell setImage:[UIImage imageNamed:@"table-facebook.png"]];
			break;

		case TABLE_CELL_INDEX_CONTACT:
			[[cell textLabel] setText:NSLocalizedString(@"Contact Developers", @"")];
			cell.imageView.image = [UIImage imageNamed:@"table-contact.png"];
			//[cell setImage:[UIImage imageNamed:@"table-contact.png"]];
			break;

		case TABLE_CELL_INDEX_ABOUT:
			[[cell textLabel] setText:NSLocalizedString(@"About", @"")];
			cell.imageView.image = [UIImage imageNamed:@"table-about.png"];
			//[cell setImage:[UIImage imageNamed:@"table-about.png"]];
			break;

		default:
			break;
	}
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
	switch (indexPath.row) {
		case TABLE_CELL_INDEX_VISIT:
		{
			NSURL *website = [[NSURL alloc] initWithString:@"http://www.unicall.co.nr/"];
			[[UIApplication sharedApplication] openURL:website];
			[website release];
		}
			break;
			
		case TABLE_CELL_INDEX_SHARE:
		{
			NSURL *website = [[NSURL alloc] initWithString:@"https://www.facebook.com/pages/UniCall/105033512921710"];
			[[UIApplication sharedApplication] openURL:website];
			[website release];
		}
			break;
			
		case TABLE_CELL_INDEX_CONTACT:
		{
			ContactDevelopersViewController *detail = [[ContactDevelopersViewController alloc] initWithNibName:@"ContactDevelopersView" bundle:nil];
			[self.navigationController pushViewController:detail animated:YES];
			[detail release];
			break;
		}
			
		case TABLE_CELL_INDEX_ABOUT:
		{
			AboutViewController *about = [[AboutViewController alloc] initWithNibName:@"AboutView" bundle:nil];
			[self.navigationController pushViewController:about animated:YES];
			[about release];
			break;
		}
			
		default:
			break;
	}
	
	// Navigation logic may go here. Create and push another view controller.
	/*
	 <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
	 [self.navigationController pushViewController:detailViewController animated:YES];
	 [detailViewController release];
	 */
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end

