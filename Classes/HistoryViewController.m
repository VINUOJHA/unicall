//
//  HistoryViewController.m
//  uniCall
//
//  Created by Hussain Yaqoob on 6/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HistoryViewController.h"
#import "uniCallAppDelegate.h"
#import "InfoDetailViewController.h"

# define HistoryViewTableSections 1

@implementation HistoryViewController

@synthesize historyTableRowCount;


#pragma mark -
#pragma mark Initialization


- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if ((self = [super initWithStyle:style])) {
    }
    return self;
}


#pragma mark -
#pragma mark Database Interaction

-(NSInteger)retrieveHistoryCount {
	
	char *sqlStatment;
	sqlite3 *database;
	int returnCode;
	const char *databaseName;
	sqlite3_stmt *statment;
	int count = 0;
	
	NSString * dbName = [[NSString alloc] initWithString:kDBName];
	
	// Get the path to the documents directory and append the databaseName
	NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDir = [documentPaths objectAtIndex:0];
	NSString * databasePath = [documentsDir stringByAppendingPathComponent:dbName];
	
	databaseName = [databasePath UTF8String];
	
	returnCode = sqlite3_open(databaseName, &database);
	if (returnCode!=SQLITE_OK) {
		fprintf(stderr, "UNICALLAPP DATABASE :: ERROR :: Error in opening the uniCall databse. Error %s \n",
				sqlite3_errmsg(database));
		sqlite3_close(database);
		return count;
	}
	
	sqlStatment = sqlite3_mprintf("SELECT COUNT(*) FROM history");
	
	returnCode = sqlite3_prepare_v2(database,
									sqlStatment,
									strlen(sqlStatment),
									&statment,
									NULL);
	
	if (returnCode != SQLITE_OK) {
		fprintf(stderr, "UNICALLAPP DATABASE :: ERROR :: Error in preparation of count query. Error %s \n",
				sqlite3_errmsg(database));
		sqlite3_close(database);
		return count;
	}
	
	returnCode = sqlite3_step(statment);
	while (returnCode == SQLITE_ROW) {
		
		count = sqlite3_column_int(statment, 0);
		//printf("UNICALLAPP DATABASE :: INFO :: count: %d\n", count);
		returnCode = sqlite3_step(statment);
		
	}
	
	sqlite3_finalize(statment);
	sqlite3_free(sqlStatment);
	sqlite3_close(database);
	
	[dbName release];
	//[databasePath release];
	
	return count;
}

-(void)retrieveHistory {
	
	char *sqlStatment;
	sqlite3 *database;
	int returnCode;
	const char *databaseName;
	sqlite3_stmt *statment;
	
	NSString * dbName = [[NSString alloc] initWithString:kDBName];
	
	// Get the path to the documents directory and append the databaseName
	NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDir = [documentPaths objectAtIndex:0];
	NSString * databasePath = [documentsDir stringByAppendingPathComponent:dbName];
	
	databaseName = [databasePath UTF8String];
	
	returnCode = sqlite3_open(databaseName, &database);
	if (returnCode!=SQLITE_OK) {
		fprintf(stderr, "Error in opening the uniCall databse. Error %s \n",
				sqlite3_errmsg(database));
		sqlite3_close(database);
		return;
	}
	
	sqlStatment = sqlite3_mprintf("SELECT * FROM history");
	
	returnCode = sqlite3_prepare_v2(database,
									sqlStatment,
									strlen(sqlStatment),
									&statment,
									NULL);
	if (returnCode != SQLITE_OK) {
		fprintf(stderr, "UNICALLAPP DATABASE :: Error in preparation of query. Error %s \n",
				sqlite3_errmsg(database));
		sqlite3_close(database);
		return;
	}
	
	returnCode = sqlite3_step(statment);
	while (returnCode == SQLITE_ROW) {
		
		int id = sqlite3_column_int(statment, 0);
		int type = sqlite3_column_int(statment, 1);
		const unsigned char * name = sqlite3_column_text(statment, 2);
		const unsigned char * time = sqlite3_column_text(statment, 3);
		const unsigned char * date = sqlite3_column_text(statment, 4);
		const unsigned char * number = sqlite3_column_text(statment, 5);
		int duration = sqlite3_column_int(statment, 6);
		int location = sqlite3_column_int(statment, 7);
		double altitude = sqlite3_column_double(statment, 8);
		double longitude = sqlite3_column_double(statment, 9);
		
		printf("UNICALLAPP DATABASE :: INFO :: id = %d => \n %d \n %s \n %s \n %s \n %s \n %d \n %d \n %f \n %f \n",
			   id, type, name, time, date, number, duration, location, altitude, longitude);
		
		returnCode = sqlite3_step(statment);
		
	}
	
	sqlite3_finalize(statment);
	sqlite3_free(sqlStatment);
	sqlite3_close(database);
	
	[dbName release];
	//[databasePath release];
	
}

-(void) clearAllHistory {

	char *st;
	sqlite3 *pDb;
	char *errorMsg;
	int returnCode;
	const char *databaseName;
	
	NSString * dbName = [[NSString alloc] initWithString:kDBName];
	
	// Get the path to the documents directory and append the databaseName
	NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDir = [documentPaths objectAtIndex:0];
	NSString * databasePath = [documentsDir stringByAppendingPathComponent:dbName];
	
	databaseName = [databasePath UTF8String];
	
	returnCode = sqlite3_open(databaseName, &pDb);
	if (returnCode != SQLITE_OK) {
		fprintf(stderr, "UNICALLAPP DATABASE :: ERROR :: Error in opening the uniCall database. Error %s \n", sqlite3_errmsg(pDb));
		sqlite3_close(pDb);
		return;
	}

	st = sqlite3_mprintf("DELETE FROM history");

	returnCode = sqlite3_exec(pDb, st, NULL, NULL, &errorMsg);

	if(returnCode != SQLITE_OK) {
		fprintf(stderr, "UNICALLAPP DATABASE :: ERROR :: Error in deleting from the history table. Error: %s", errorMsg);
		sqlite3_free(errorMsg);
	}

	sqlite3_free(st);
	sqlite3_close(pDb);

	[dbName release];
	//[databasePath release];
}



#pragma mark -
#pragma mark View lifecycle

-(void)reloadTableData {
	[self.tableView reloadData];
}
- (void)viewDidLoad {
    [super viewDidLoad];
	
	//self.title = @"History";
	UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Clear", @"")
																	style:UIBarButtonSystemItemCancel
																   target:self
																   action:@selector(btnClear:)
									];
	self.navigationItem.rightBarButtonItem = rightButton;
	self.navigationItem.hidesBackButton = YES;
	
	[rightButton release];
    	
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

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
#pragma mark ClearAll Button

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	
	switch (buttonIndex) {
		case 0:
			//Clear All button pressed
			NSLog(@"HistoryViewController:: You confirm \"Clear All History\" Action");
			[self clearAllHistory];
			break;
			
		case 1:
			//Cancel button pressed
			NSLog(@"HistoryViewController:: You Cancel \"Clear All History\" Action");
			break;

		default:
			break;
	}
}

-(void)btnClear:(id) sender {
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil 
															 delegate:self 
													cancelButtonTitle:NSLocalizedString(@"Cancel", @"") 
											   destructiveButtonTitle:NSLocalizedString(@"Clear All History", @"")
													otherButtonTitles:nil
								  ];
	actionSheet.actionSheetStyle = UIBarStyleBlackTranslucent;
	uniCallAppDelegate *uniCallApp = (uniCallAppDelegate *)[[UIApplication sharedApplication] delegate];
	[actionSheet showInView:[uniCallApp tabBarController].view];
	[actionSheet release];
	
}

-(NSString *)calculateDuration:(int)durationInSec {
	
	int hour;
	int min;
	int sec;
	int temp;
	
	NSString *min_str = [[NSString alloc] initWithString:NSLocalizedString(@"min", @"")];
	NSString *sec_str = [[NSString alloc] initWithString:NSLocalizedString(@"sec", @"")];
	
	NSMutableString *duration = [[[NSMutableString alloc] init] autorelease];
	hour = durationInSec / 3600;
	durationInSec = durationInSec - (hour * 3600);
	
	temp = durationInSec % 3600;
	min = temp / 60;
	durationInSec = durationInSec - (min * 60);
	
	sec = durationInSec;
	
	if (hour) {
		[duration appendFormat:@"%02d:%02d:%02d", hour, min, sec];
	} else if (min) {
		[duration appendFormat:@"%02d %@ %02d %@", min, min_str, sec, sec_str];		
	} else {
		[duration appendFormat:@"%02d %@", sec, sec_str];
	}
	
	[min_str release];
	[sec_str release];
	
	return duration;
	
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return HistoryViewTableSections;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	self.historyTableRowCount = [self retrieveHistoryCount];
    return historyTableRowCount;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	int rowid = self.historyTableRowCount - indexPath.row;
	
	static NSString *CellIdentifier = @"Cell";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle 
									   reuseIdentifier:CellIdentifier] autorelease];
		cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
		
	}
	
	char *sqlStatment;
	sqlite3 *database;
	int returnCode;
	const char *databaseName;
	sqlite3_stmt *statment;
	
	NSString * dbName = [[NSString alloc] initWithString:kDBName];
	
	// Get the path to the documents directory and append the databaseName
	NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDir = [documentPaths objectAtIndex:0];
	NSString * databasePath = [documentsDir stringByAppendingPathComponent:dbName];
	
	databaseName = [databasePath UTF8String];
	returnCode = sqlite3_open(databaseName, &database);
	if (returnCode!=SQLITE_OK) {
		fprintf(stderr, "Error in opening the uniCall databse. Error %s \n",
				sqlite3_errmsg(database));
		sqlite3_close(database);
		return cell;
	}
	
	sqlStatment = sqlite3_mprintf("SELECT type, name, number FROM history WHERE id=%d", rowid);
	
	returnCode = sqlite3_prepare_v2(database,
									sqlStatment,
									strlen(sqlStatment),
									&statment,
									NULL);
	if (returnCode != SQLITE_OK) {
		fprintf(stderr, "UNICALLAPP DATABASE :: Error in preparation of query. Error %s \n",
				sqlite3_errmsg(database));
		sqlite3_close(database);
		return cell;
	}
	
	returnCode = sqlite3_step(statment);
	while (returnCode == SQLITE_ROW) {
		
		NSInteger type = sqlite3_column_int(statment, 0);
		const unsigned char * name = sqlite3_column_text(statment, 1);
		const unsigned char * number = sqlite3_column_text(statment, 2);
		
		// Configure the cell...
		printf("UNICALLAPP DATABASE :: INFO :: name= %s", name);
		if ( strcmp((const char *)name, "(NULL)") != 0 ) {
			[[cell textLabel] setText:[NSString stringWithUTF8String:(const char *)name]];
		} else {
			[[cell textLabel] setText:[NSString stringWithUTF8String:(const char *)number]];
		}

		 switch (type) {
				 case CALL_TYPE_MISSED:
					 [[cell detailTextLabel] setText:NSLocalizedString(@"Missed Call", @"")];
					[[cell detailTextLabel] setTextColor:[UIColor redColor]];
					 //[[cell detailTextLabel] setTextColor:[UIColor redColor]];
					 break;
				 case CALL_TYPE_CANCELLED:
					 [[cell detailTextLabel] setText:NSLocalizedString(@"Cancelled Call", @"")];
					 [[cell detailTextLabel] setTextColor:[UIColor grayColor]];
					 break;
				 case CALL_TYPE_INCOMING:
					 [[cell detailTextLabel] setText:NSLocalizedString(@"Incoming Call", @"")];
 					 [[cell detailTextLabel] setTextColor:[UIColor grayColor]];
					 break;
				 case CALL_TYPE_OUTGOING:
					 [[cell detailTextLabel] setText:NSLocalizedString(@"Outgoing Call", @"")];
					 [[cell detailTextLabel] setTextColor:[UIColor grayColor]];
					 break;
		 };
		
		returnCode = sqlite3_step(statment);
		
	}
	
	sqlite3_finalize(statment);
	sqlite3_free(sqlStatment);
	sqlite3_close(database);
	
	[dbName release];
	
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
	
	// Navigation logic may go here. Create and push another view controller.

	InfoDetailViewController *detailViewController = [[InfoDetailViewController alloc] initWithNibName:@"InfoDetailView" bundle:nil];
	detailViewController.title = @"Info";
	
	// ...
	int rowid = self.historyTableRowCount - indexPath.row;
	char *sqlStatment;
	sqlite3 *database;
	int returnCode;
	__strong const char *databaseName;
	sqlite3_stmt *statment;
	
	NSString * dbName = [[NSString alloc] initWithString:kDBName];
	
	// Get the path to the documents directory and append the databaseName
	NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDir = [documentPaths objectAtIndex:0];
	NSString * databasePath = [documentsDir stringByAppendingPathComponent:dbName];
	
	databaseName = [databasePath UTF8String];
	returnCode = sqlite3_open(databaseName, &database);
	if (returnCode!=SQLITE_OK) {
		fprintf(stderr, "Error in opening the uniCall databse. Error %s \n",
				sqlite3_errmsg(database));
		sqlite3_close(database);
		return;
	}
	
	sqlStatment = sqlite3_mprintf("SELECT * FROM history WHERE id=%d", rowid);
	
	returnCode = sqlite3_prepare_v2(database,
									sqlStatment,
									strlen(sqlStatment),
									&statment,
									NULL);
	if (returnCode != SQLITE_OK) {
		fprintf(stderr, "UNICALLAPP DATABASE :: Error in preparation of query. Error %s \n",
				sqlite3_errmsg(database));
		sqlite3_close(database);
		return;
	}
	
	returnCode = sqlite3_step(statment);
	while (returnCode == SQLITE_ROW) {
		
		//int id = sqlite3_column_int(statment, 0);
		NSInteger type = sqlite3_column_int(statment, 1);
		const unsigned char * name = sqlite3_column_text(statment, 2);
		const unsigned char * time = sqlite3_column_text(statment, 3);
		const unsigned char * date = sqlite3_column_text(statment, 4);
		const unsigned char * number = sqlite3_column_text(statment, 5);
		int duration = sqlite3_column_int(statment, 6);
		//int location = sqlite3_column_int(statment, 7);
		//double altitude = sqlite3_column_double(statment, 8);
		//double longitude = sqlite3_column_double(statment, 9);
		
		detailViewController.number = [NSString stringWithUTF8String:(const char *)number];
		detailViewController.date = [NSString stringWithUTF8String:(const char *)date];
		detailViewController.time = [NSString stringWithUTF8String:(const char *)time];
		
		if ( strcmp((const char *)name, "(NULL)") != 0 ) {
			detailViewController.name = [NSString stringWithUTF8String:(const char *)name];
		} else {
			detailViewController.name = NSLocalizedString(@"Unknown Name", @"");
		}
		
		switch (type) {
			case CALL_TYPE_MISSED:
				detailViewController.type = NSLocalizedString(@"Incoming Call", @"");
				detailViewController.duration = NSLocalizedString(@"missed", @"");
				break;
			case CALL_TYPE_CANCELLED:
				detailViewController.type = NSLocalizedString(@"Outgoing Call", @"");
				detailViewController.duration = NSLocalizedString(@"cancelled", @"");
				break;
			case CALL_TYPE_INCOMING:
				detailViewController.type = NSLocalizedString(@"Incoming Call", @"");
				detailViewController.duration = [self calculateDuration:duration];
				break;
			case CALL_TYPE_OUTGOING:
				detailViewController.type = @"Outgoing Call";
				//if (duration != 0 || duration != NULL) {
					detailViewController.duration = [self calculateDuration:duration];
				//}
				//detailViewController.duration = @"";
				break;
		};
		
		returnCode = sqlite3_step(statment);
		
	}
	
	sqlite3_finalize(statment);
	sqlite3_free(sqlStatment);
	sqlite3_close(database);
	
	[dbName release];

	// Pass the selected object to the new view controller.
	[self.navigationController pushViewController:detailViewController animated:YES];
	[detailViewController release];
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

