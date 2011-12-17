//
//  uniCallAppDelegate.m
//  uniCall
//
//  Created by Hussain Yaqoob on 3/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "uniCallAppDelegate.h"
//#import "uniCallViewController.h"
#import "UniCallManager.h"
#import "KeypadViewConroller.h"


#pragma mark -
#pragma mark Tab bar coloured

//

@implementation uniCallAppDelegate

@synthesize status;

@synthesize callViewController;
@synthesize incomingCallViewController;

@synthesize historyViewController;
@synthesize keypadViewController;
@synthesize contactsViewController;
@synthesize moreViewController;

@synthesize registered;
@synthesize connected;
@synthesize _callInfo;

@synthesize soundFileURLRef;
@synthesize soundFileObject;

@synthesize connectivity;
@synthesize locationManager;

@synthesize window;
@synthesize tabBarController;
//@synthesize viewController;


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	
	/*
	 //chekc if the device support background multitasking
	 UIDevice* device = [UIDevice currentDevice];
	 BOOL backgroundSupported = NO;
	 if ([device respondsToSelector:@selector(isMultitaskingSupported)])
	 backgroundSupported = device.multitaskingSupported;
	 //
	 */
	
	
	//locaiton accuracy
	 
	
	[self initializeForFirstTime];
	connectivity = [[Connectivity alloc] init];
	locationManager = [[LocationManager alloc] init];
	
	// Override point for customization after application launch.
	
	//
	// History 
	//
	historyViewController = [[HistoryViewController alloc] initWithStyle:UITableViewStylePlain];
	UINavigationController *historyNavCont = [[[UINavigationController alloc] 
											   initWithRootViewController:historyViewController] autorelease];
	historyNavCont.navigationBar.barStyle = UIBarStyleDefault;
	historyViewController.title = NSLocalizedString(@"History", @"History View Controller title");
	historyViewController.tabBarItem.title = NSLocalizedString(@"History", @" Tab bar item - History title");
	historyViewController.tabBarItem.image = [UIImage imageNamed:@"History.png"];
	
	//
	// Keypad
	//
	keypadViewController = [[KeypadViewConroller alloc] initWithNibName:@"KeypadView" bundle:Nil];
	keypadViewController.tabBarItem.title = NSLocalizedString(@"Keypad", @" Tab bar item - keypad item title");
	keypadViewController.tabBarItem.image = [UIImage imageNamed:@"Keypad.png"];
	
	
	//
	// Contacts
	//
	ABPeoplePickerNavigationController *peoplePickerViewController = [[[ABPeoplePickerNavigationController alloc] init] autorelease];
	peoplePickerViewController.displayedProperties = [NSArray arrayWithObject:[NSNumber numberWithInt:kABPersonPhoneProperty]];
	peoplePickerViewController.peoplePickerDelegate = self;
	//UIBarButtonItem *button;
	//peoplePickerViewController.navigationItem.rightBarButtonItem = button;
	//peoplePickerViewController.navigationBarHidden = TRUE;
	//peoplePickerViewController.navigationBar.tintColor = [UIColor orangeColor];
	//peoplePickerViewController.delegate = self;
	contactsViewController = (ContactsViewController *)peoplePickerViewController;
	//contactsViewController.navigationItem.rightBarButtonItem = button;
	//contactsViewController = peoplePickerViewController;
	
	contactsViewController.tabBarItem.title = NSLocalizedString(@"Contacts", @" Tab bar item - Contacts item title");
	contactsViewController.tabBarItem.image = [UIImage imageNamed:@"Contacts.png"];
	
	//
	// More
	//
	moreViewController = [[MoreViewController alloc] initWithStyle:UITableViewStylePlain];
	moreViewController.tabBarItem.title = NSLocalizedString(@"More", @"More tab bar item title");
	moreViewController.tabBarItem.image = [UIImage imageNamed:@"More.png"];
	moreViewController.title = NSLocalizedString(@"More","More View Controller title");
	UINavigationController *moreNavCont = [[[UINavigationController alloc] initWithRootViewController:moreViewController] autorelease];
	moreNavCont.navigationBar.barStyle = UIBarStyleDefault;
	
	
	tabBarController = [[UITabBarController alloc] init];
	
	tabBarController.viewControllers = [NSArray arrayWithObjects:historyNavCont,
										keypadViewController, contactsViewController, 
										moreNavCont, nil];
	
	
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	[window addSubview:tabBarController.view];
	[moreNavCont release];
	[historyNavCont release];
	
	// Add the view controller's view to the window and display.
    //[window addSubview:viewController.view];
	callViewController = [[CallViewController alloc] initWithNibName:@"CallView" bundle:nil];
	incomingCallViewController = [[IncomingCallViewController alloc] initWithNibName:@"IncomingCallView" bundle:nil];
	
    [window makeKeyAndVisible];
	//[self initFromPreferences];
	[self uniCallStartup];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

/*
 * @later: look at implementing selfaware Voip Application
 * http://developer.apple.com/library/ios/#DOCUMENTATION/iPhone/Conceptual/iPhoneOSProgrammingGuide/BackgroundExecution/BackgroundExecution.html
 */
- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */

	//[self setKeepAliveTimeout:(NSTimeInterval)300 handler:nil];
	//- (BOOL)setKeepAliveTimeout:(NSTimeInterval)timeout handler:(void(^)(void))keepAliveHandler __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_4_0);
	//- (void)clearKeepAliveTimeout __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_4_0);

}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}


/**
 *
 * Called when the application is about to terminate.
 * See also applicationDidEnterBackground:.
 **/
- (void)applicationWillTerminate:(UIApplication *)application {
	
}

#pragma mark -
#pragma mark BackgroundExecution


#pragma mark -
#pragma mark UserDefaultsInitilization

-(NSDictionary *)initDefaults {
	
	NSArray *keys = [[[NSArray alloc] initWithObjects:@"username", nil] autorelease];
	NSArray *values = [[[NSArray alloc] initWithObjects:@"Test", nil] autorelease];
	return [[[NSDictionary alloc] initWithObjects:values forKeys:keys] autorelease];

}

-(BOOL)initFromPreferences {
	/*
	 TODO: Check if the setting is complete,
	 if not alert user to complete it first
	 */
	BOOL initialized;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	
	/*
	[userDefaults registerDefaults: [self initDefaults]];
	UIAlertView *tempAlerView = [[UIAlertView alloc] initWithTitle:@"setting username"
														   message:[userDefaults stringForKey:kSipUsername]
														  delegate:nil
												 cancelButtonTitle:@"Ok"
												 otherButtonTitles:nil
								 ];
	*/
	
	NSString *username = [userDefaults stringForKey:kSipUsername];
	NSString *password = [userDefaults stringForKey:kSipPassword];
	NSString *domain = [userDefaults stringForKey:kSipDomain];
	
	if ((username==nil) || (password==nil) || (domain==nil)
		||([username length] == 0) || ([password length] == 0) || ([domain length] == 0)) {
		PreferencesViewController *setting = [[PreferencesViewController alloc] initWithNibName:@"PreferencesView" bundle:nil];
		[setting present];
		[setting release];
		initialized = FALSE;
	} else {
		initialized = TRUE;
	}

	return initialized;
	//[tempAlerView show];
	//[tempAlerView release];
}


#pragma mark -
#pragma mark uniCall lifecycle

-(void)uniCallStartup {
	//init ringing
	//file = [[NSString alloc] initWithFormat:@"ringtone"];
	//soundFile = [[NSBundle mainBundle]
	//					   pathForResource:file ofType:@"aif"];
	
	if ([self initFromPreferences]) {
		//check connected or not, if not alert user
		//init
		[self updateUniCallAppStatus:@"Worked?" forLevel:APP_STATUS_WHITE];
		//[self.keypadViewController updateUniCallAppStatus:@"uniCall Starting Up" forLevel:APP_STATUS_WHITE];
		//[self updateAppStatus:@"uniCall starting up" forLevel:APP_STATUS_WHITE];
		self._callInfo = [[CallInfo alloc] init];
		[UniCallManager uniCallSystemInit];
	} else {
		//<#statements#>
	}

	
}

-(void)uniCallShutdown {
	
	//unregister from the server
	
	//stop updating from the locationmanager
	
	//remove the program from observing the reachability
	
	//
	// In the process of program terminatino register user out process the disconnect and shutdown process
	//
}

#pragma mark -
#pragma mark Call info

-(void)reinitCallInfo {
	self._callInfo = nil;
	self._callInfo = [[CallInfo alloc] init];
	self._callInfo._duration = 0;
}

-(CallInfo *)getCallInfo {
	return self._callInfo;
}

#pragma mark -
#pragma mark uniCall Call Handler

-(IBAction)presentCallViewController {
	[[self tabBarController] presentModalViewController:callViewController animated:YES];
}

-(IBAction)dismissViewController {
	if ([[self tabBarController] modalViewController]) {
		[[self tabBarController] dismissModalViewControllerAnimated:NO];
	}
}

-(IBAction)presentIncomCallViewController {
	[[self tabBarController] presentModalViewController:incomingCallViewController animated:YES];
}

-(IBAction)callStatusHandler:(CALL_STATUS) call_status {
	switch (call_status) {
		case CALL_EVENT_HOLD:
			[UniCallManager uniCallHoldCall:_callInfo._callNo];
			break;
			
		case CALL_EVENT_UNHOLD:
			[UniCallManager uniCallUnHoldCall:_callInfo._callNo];
			break;
			
		case CALL_EVENT_MUTE:
			[UniCallManager uniCallMuteCall:_callInfo._callNo];
			break;
			
		case CALL_EVENT_UNMUTE:
			[UniCallManager uniCallUnMuteCall:_callInfo._callNo];
			break;
			
		default:
			break;
	}
}

-(IBAction)uniCallEventHandler{
	switch (self._callInfo._event) {
			
		case CALL_EVENT_ACCEPT:
			self._callInfo._type = CALL_TYPE_INCOMING;
			[UniCallManager uniCallAcceptCall:_callInfo._callNo];
			[self dismissViewController];			
			[self.callViewController startCallTimer];
			//self.callViewController._callerIdlbl.text = _callInfo._name;
			[self presentCallViewController];
			break;
			
		case CALL_EVENT_DECLINE:
			//NSLog(@"UNICALLAPP :: CALLHANDLER :: INFO :: decline button pressed");
			self._callInfo._type = CALL_TYPE_INCOMING;
			// handle duration and add to database
			[UniCallManager uniCallDeclineCall:_callInfo._callNo];
			//handle view
			//just temp ->
			[self dismissViewController];
			break;
			
		case CALL_EVENT_END:
			//TODO: check if the type is Cancelled or incoming or ....
			//_callInfo._duration = callViewController._duration;
			//
			//	set duration and type and save to database
			//
			//if ((self._callInfo._type == CALL_TYPE_OUTGOING) && ((self._callInfo._duration == 0) || (self._callInfo._duration == 0.0))) {
			//if(self._callInfo._type == CALL_TYPE_OUTGOING) && (self._callInfo
			//	self._callInfo._type == CALL_TYPE_CANCELLED;
			//}
			_callInfo._duration = callViewController._duration;
			[UniCallManager uniCallHangupCall];
			[self dismissViewController];
			break;
			
		case CALL_EVENT_OUTGOING:
			if ((self.registered) && [connectivity isConnected]) {
				
				self._callInfo._type = CALL_TYPE_CANCELLED;
				[UniCallManager uniCallMakeSipCall];
				[self performSelector:@selector(presentCallViewController)];
				self.callViewController._callerIdlbl.text = _callInfo._name;
				self.callViewController._callstatuslbl.text = NSLocalizedString(@"Connecting", @"");
				
			} else if ([connectivity isConnected] == FALSE) {
				
				UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ERROR", @"")
																	message:NSLocalizedString(@"In order for this program to work correctly you must be connected to the internet. To call using phone network press call", @"")
																   delegate:self
														  cancelButtonTitle:NSLocalizedString(@"Call", @"")
														  otherButtonTitles:NSLocalizedString(@"Ok", @""), nil
										  ];
				alertView.tag = ALERTVIEW_TAG_CONNECTIVITY;
				[alertView show];
				[alertView release];
				
			} else {
				
				UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ERROR", @"")
																	message:NSLocalizedString(@"An error occurred while registering. Please, Go to setting page and verify the credential. To call using phone network press call", @"")
																   delegate:self
														  cancelButtonTitle:NSLocalizedString(@"Call", @"")
														  otherButtonTitles:NSLocalizedString(@"Ok", @""), nil
										  ];
				alertView.tag = ALERTVIEW_TAG_REGISTERING;
				[alertView show];
				[alertView release];
				
			}
			
			break;
			
		case CALL_EVENT_INCOMING:
			
			//handle callType for database
			self._callInfo._type = CALL_TYPE_MISSED;		//TOSEE: may it is better to change location of type
			//self._callInfo._time = [[NSDate alloc] init];	//TODO: make sure this is the right time of the call
			
			//move it to incomingViewController ViewDidLoad
			//incomingCallViewController.incomingNumber.text = self._callInfo._name;
			[self presentIncomCallViewController];
			break;
			
		case CALL_EVENT_CONNECTED:
			self._callInfo._type = CALL_TYPE_OUTGOING;
			[self.callViewController startCallTimer];
			self.callViewController._callerIdlbl.text = _callInfo._name;
			break;
			
		case CALL_EVENT_DISCONNECTED:
			
			if (self._callInfo._type == CALL_TYPE_MISSED) {
				NSLog(@"UNICALLAPP :: CALLHANDLER :: INFO :: missed call");
				[self performSelector:@selector(addMissedCallToHistory)];
				
			} else if (self._callInfo._type == CALL_TYPE_INCOMING) {
				NSLog(@"UNICALLAPP :: CALLHANDLER :: INFO :: declined call");
				[self performSelector:@selector(addIncomingCallToHistory)];
				
			} else if (self._callInfo._type == CALL_TYPE_OUTGOING) {
				NSLog(@"UNICALLAPP :: CALLHANDLER :: INFO :: outgoing call");
				[self performSelector:@selector(addOutgoingCallToHistory)];
				
			} else if ((self._callInfo._type == CALL_TYPE_CANCELLED)) {
				NSLog(@"UNICALLAPP :: CALLHANDLER :: INFO :: cancelled call");
				[self performSelector:@selector(addCancelledCallToHistory)];
				
			} else {
				NSLog(@"UNICALLAPP :: CALLHANDLER :: INFO :: other option");
			}			
			
			self.callViewController._callstatuslbl.text = NSLocalizedString(@"Disconnected", @"");
			[self.callViewController endCall:nil];
			[self.historyViewController reloadTableData];
			break;
			
		default:
			break;
	}
}


#pragma mark -
#pragma mark AddressBook delegate

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
	
	NSMutableString *name = [[NSMutableString alloc] initWithString:(NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty)];
	[name appendString:@" "];
	[name appendString:(NSString *)ABRecordCopyValue(person, kABPersonLastNameProperty)];
	
	NSLog(@"The phone number selected is %@: For %@", phone, name);

	[self reinitCallInfo];
	CallInfo *callInfo = [self getCallInfo];
	callInfo._event = CALL_EVENT_OUTGOING;
	callInfo._number = phone;
	callInfo._name = name;
	callInfo._time = [[NSDate alloc] init];
	[self uniCallEventHandler];
	
	CFRelease(phoneProperty);
	[phone release];
	[name release];
	
	return NO;
}

#pragma mark -
#pragma mark Start/Stop Ringing
-(void)startRinging {
	
    // Create the URL for the source audio file. The URLForResource:withExtension: method is
    //    new in iOS 4.0.
    NSURL *tapSound   = [[NSBundle mainBundle] URLForResource: @"test"
                                                withExtension: @"aif"];
	
    // Store the URL as a CFURLRef instance
    self.soundFileURLRef = (CFURLRef) [tapSound retain];
	
    // Create a system sound object representing the sound file.
    AudioServicesCreateSystemSoundID (
									  
									  soundFileURLRef,
									  &soundFileObject
									  );
	
	AudioServicesPlaySystemSound (soundFileObject);

}

-(void)stopRinging {
	AudioServicesDisposeSystemSoundID (soundFileObject);
	//CFRelease (soundID);
}

#pragma mark -
#pragma mark Database Interaction

-(void)initializeForFirstTime {
	
	NSString * databaseName = [[NSString alloc] initWithString:kDBName];
	
	// Get the path to the documents directory and append the databaseName
	NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDir = [documentPaths objectAtIndex:0];
	NSString * databasePath = [documentsDir stringByAppendingPathComponent:databaseName];
	// Check if the SQL database has already been saved to the users phone, if not then copy it over
	BOOL success;
	
	// Create a FileManager object, we will use this to check the status
	// of the database and to copy it over if required
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	// Check if the database has already been created in the users filesystem
	success = [fileManager fileExistsAtPath:databasePath];
	
	// If the database already exists then return without doing anything
	if(success) {
		//[databasePath release];
		[databaseName release];
		return;
	}
	
	// If not then proceed to copy the database from the application to the users filesystem
	
	// Get the path to the database in the application package
	NSString *databasePathFromApp = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:databaseName];
	
	// Copy the database from the package to the users filesystem
	[fileManager copyItemAtPath:databasePathFromApp toPath:databasePath error:nil];
	
	[fileManager release];
	[databaseName release];
	//[databasePath release];
	
	/*
	NSString * firstTime = [[NSUserDefaults standardUserDefaults] stringForKey:kAppFirstTime];
	NSComparisonResult result = [firstTime compare:@"NO"];
	if ( result != NSOrderedSame ) {
		
		//Create Database
		char *sqlStatment;
		sqlite3 *pDb;
		char *errorMsg;
		int returnCode;
		char *databaseName;
		
		databaseName = "uniCall.db";
		returnCode = sqlite3_open(databaseName, &pDb);
		if (returnCode != SQLITE_OK) {
			fprintf(stderr, "Error in opening the uniCall database. Error %s \n", sqlite3_errmsg(pDb));
			sqlite3_close(pDb);
			return;
		}
		
		sqlStatment = "DROP TABLE IF EXISTS history";
		returnCode = sqlite3_exec(pDb, sqlStatment, NULL, NULL, &errorMsg);
		if (returnCode != SQLITE_OK) {
			fprintf(stderr,	"Error in dropping table history. Error: %s \n", errorMsg);
			sqlite3_free(errorMsg);
		}
		
		sqlStatment = "CREATE TABLE history (id INTEGER PRIMARY KEY,"
		"type INTEGER,"
		"name VARCHAR(150),"
		"time VARCHAR(30),"
		"date VARCHAR(70),"
		"number VARCHAR(70),"
		"duration INTEGER,"
		"location INTEGER,"
		"altitude DOUBLE,"
		"longitude DOUBLE )";
		
		returnCode = sqlite3_exec( pDb, sqlStatment, NULL, NULL, &errorMsg);
		
		if (returnCode != SQLITE_OK) {
			fprintf(stderr, "UNICALLAPP DATABASE :: ERROR :: Error in creating the history table. Error: %s",
					errorMsg);
			sqlite3_free(errorMsg);
		}
		
		sqlite3_close(pDb);
		
		[[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:kAppFirstTime];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
	else {
		NSLog(@"UNICALLAPP DATABASE :: INFO :: Not First Time use");
		return;
	}
	
	[firstTime release];
	*/
}

-(void) insertCallInfoIntoDatabase:(CALL_TYPE)type 
						callerName:(NSString *)name 
						  callTime:(NSString *)time 
						  callDate:(NSString *)date 
					  callerNumber:(NSString *)number 
					  callDuratoin:(int)duration 
						isLocation:(int)location	// 0 => FALSE, 1 => TRUE
					callerAltitude:(double)altitude 
				   callerLongitude:(double)longitude
{
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
	
	const char *theName = [name UTF8String];
	const char *theTime = [time UTF8String];
	const char *theDate = [date UTF8String];
	const char *theNumber = [number UTF8String];
	
	st = sqlite3_mprintf("INSERT INTO history (type, name, time, date, number, duration, location, altitude, longitude) VALUES"
						 " (%d, '%q', '%q', '%q', '%q', %d, %d, %f, %f)",
						 type, theName, theTime, theDate, theNumber, duration, location, altitude, longitude);
	
	returnCode = sqlite3_exec(pDb, st, NULL, NULL, &errorMsg);
	
	if(returnCode != SQLITE_OK) {
		fprintf(stderr, "UNICALLAPP DATABASE :: ERROR :: Error in inserting into the history table. Error: %s", errorMsg);
		sqlite3_free(errorMsg);
	}
	
	sqlite3_free(st);
	
	sqlite3_close(pDb);
	
	[dbName release];
	//[databasePath release];

}

-(void) addMissedCallToHistory {
	
	NSDateFormatter *formatterDate = [[NSDateFormatter alloc] init];
	[formatterDate setDateStyle:NSDateFormatterLongStyle];
	NSDateFormatter *formatterTime = [[NSDateFormatter alloc] init];
	[formatterTime setDateFormat:@"hh:mm a"];
	
	int location;
	
	if(self._callInfo._isLocation)
		location = 1;
	else
		location = 0;
	
	[self insertCallInfoIntoDatabase:CALL_TYPE_MISSED 
						  callerName:self._callInfo._name 
							callTime:[formatterTime stringFromDate:self._callInfo._time]
							callDate:[formatterDate stringFromDate:self._callInfo._time]
						callerNumber:self._callInfo._number
						callDuratoin:0 
						  isLocation:location 
					  callerAltitude:self._callInfo._latitude
					 callerLongitude:self._callInfo._longitude
	 ];
	
	[formatterDate release];
	[formatterTime release];
}

-(void) addIncomingCallToHistory {
	
	NSDateFormatter *formatterDate = [[NSDateFormatter alloc] init];
	[formatterDate setDateStyle:NSDateFormatterLongStyle];
	NSDateFormatter *formatterTime = [[NSDateFormatter alloc] init];
	[formatterTime setDateFormat:@"hh:mm a"];
	
	int location;
	
	if(self._callInfo._isLocation)
		location = 1;
	else
		location = 0;
	
	[self insertCallInfoIntoDatabase:CALL_TYPE_INCOMING 
						  callerName:self._callInfo._name 
							callTime:[formatterTime stringFromDate:self._callInfo._time]
							callDate:[formatterDate stringFromDate:self._callInfo._time]
						callerNumber:self._callInfo._number
						callDuratoin:(int)self.callViewController._duration 
						  isLocation:location 
					  callerAltitude:self._callInfo._latitude
					 callerLongitude:self._callInfo._longitude
	 ];
	
	[formatterDate release];
	[formatterTime release];
}

-(void) addOutgoingCallToHistory {
	
	NSDateFormatter *formatterDate = [[NSDateFormatter alloc] init];
	[formatterDate setDateStyle:NSDateFormatterLongStyle];
	NSDateFormatter *formatterTime = [[NSDateFormatter alloc] init];
	[formatterTime setDateFormat:@"hh:mm a"];
	
	int location;
	
	if(self._callInfo._isLocation)
		location = 1;
	else
		location = 0;
	
	[self insertCallInfoIntoDatabase:CALL_TYPE_OUTGOING 
						  callerName:self._callInfo._name 
							callTime:[formatterTime stringFromDate:self._callInfo._time]
							callDate:[formatterDate stringFromDate:self._callInfo._time]
						callerNumber:self._callInfo._number
						callDuratoin:(int)self.callViewController._duration 
						  isLocation:location 
					  callerAltitude:self._callInfo._latitude
					 callerLongitude:self._callInfo._longitude
	 ];
	
	[formatterDate release];
	[formatterTime release];
}

-(void) addCancelledCallToHistory {
	
	NSDateFormatter *formatterDate = [[NSDateFormatter alloc] init];
	[formatterDate setDateStyle:NSDateFormatterLongStyle];
	NSDateFormatter *formatterTime = [[NSDateFormatter alloc] init];
	[formatterTime setDateFormat:@"hh:mm a"];
	
	int location;
	
	if(self._callInfo._isLocation)
		location = 1;
	else
		location = 0;
	
	[self insertCallInfoIntoDatabase:CALL_TYPE_CANCELLED 
						  callerName:self._callInfo._name 
							callTime:[formatterTime stringFromDate:self._callInfo._time]
							callDate:[formatterDate stringFromDate:self._callInfo._time]
						callerNumber:self._callInfo._number
						callDuratoin:0 
						  isLocation:location 
					  callerAltitude:self._callInfo._latitude
					 callerLongitude:self._callInfo._longitude
	 ];
	
	[formatterDate release];
	[formatterTime release];
}

#pragma mark -
#pragma mark uniCallAppDelegate status

-(void)updateUniCallAppStatus:(NSString *)message forLevel:(APP_STATUS)status_colour {
	
	//NSString *msg = [[NSString alloc] initWithString:message];
	switch (status_colour) {
		case APP_STATUS_GREEN:
		{
			status.text = message;
			status.textColor = [UIColor greenColor];
		}
			break;
			
		case APP_STATUS_WHITE:
		{
			status.text = message;
			status.textColor = [UIColor whiteColor];
		}
			break;
			
		case APP_STATUS_RED:
		{
			status.text = message;
			status.textColor = [UIColor redColor];
		}
			break;
			
		default:
			break;
	}
	//[msg release];
	
}

#pragma mark -
#pragma mark UIAlertView delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	
	if ((alertView.tag = ALERTVIEW_TAG_REGISTERING) || (alertView.tag = ALERTVIEW_TAG_CONNECTIVITY)) {
		
		switch (buttonIndex) {
			case 0:
				{
					//Call button presseed
					NSString *dialedNumberString = [[NSString alloc] initWithFormat:@"tel:%@", self._callInfo._number];
					//NSString *dialedNumberString = [NSString stringWithFormat:@"tel:%@", self.dialedNumber.text];
					[[UIApplication sharedApplication] openURL:[NSURL URLWithString: dialedNumberString]];
					[dialedNumberString release];
					NSLog(@"call button pressed");
				}
				break;
			case 1:
				//Ok button pressed
				//do nothing
				break;

			default:
				break;
		}
	
	}
}

#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
	// move to unicall shutdown
	//AudioServicesDisposeSystemSoundID (soundFileObject);
	CFRelease (soundFileURLRef);
	//
	
	[status release];
	
	[_callInfo release];
    //[viewController release];
	[incomingCallViewController release];
	[callViewController release];
	
	[connectivity release];
	[locationManager release];
	
	[keypadViewController release];
	[historyViewController release];
	[contactsViewController release];
	[moreViewController release];
	
	[tabBarController release];
	[window release];
    [super dealloc];
}


@end
