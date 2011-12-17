//
//  IncomingCallViewController.m
//  uniCall
//
//  Created by Hussain Yaqoob on 4/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "IncomingCallViewController.h"
#import "uniCallAppDelegate.h"


@implementation IncomingCallViewController

@synthesize incomingNumber;

@synthesize map;
@synthesize zipAnnotation;

@synthesize btnAccept;
@synthesize btnDecline;

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
	uniCallAppDelegate *uniCallApp = (uniCallAppDelegate *)[[UIApplication sharedApplication] delegate];
	CallInfo *callInfo = [uniCallApp getCallInfo];
	self.incomingNumber.text = callInfo._name;
	
	if (callInfo._isLocation) {
		MKCoordinateRegion mapRegion;
		
		map = [[MKMapView alloc] initWithFrame:CGRectMake(20, 97, 280, 265)];
		map.mapType = MKMapTypeStandard;
		map.zoomEnabled = YES;
		map.scrollEnabled = YES;
		map.hidden = FALSE;
		
		//CLLocationCoordinate2D
		mapRegion.center.latitude= callInfo._latitude;
		mapRegion.center.longitude= callInfo._longitude;
		mapRegion.span.latitudeDelta=0.01;
		mapRegion.span.longitudeDelta=0.01;
		[map setRegion:mapRegion animated:YES];
		
		if (zipAnnotation!=nil) {
			[map removeAnnotation:zipAnnotation];
		}
		
		zipAnnotation = [[MKPlacemark alloc] initWithCoordinate:mapRegion.center
											  addressDictionary:nil];
		[map addAnnotation:zipAnnotation];
		
		[self.view addSubview:map];
	}
	
	//btnAccept.titleLabel.font = [UIFont SystemFontOfSize:20];
	[btnAccept setTitle:NSLocalizedString(@"Answer", @"")	forState:UIControlStateNormal];
	[btnAccept setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	
	UIImage *normalImage = [[UIImage imageNamed:@"button_green.png"] stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0];
	[btnAccept setBackgroundImage:normalImage forState:UIControlStateNormal];
	UIImage *pressedImage = [[UIImage imageNamed:@"button_green_pressed.png"] stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0];
	[btnAccept setBackgroundImage:pressedImage forState:UIControlStateHighlighted];
	
	//btnDecline.titleLabel.font = [UIFont SystemFontOfSize:20];
	[btnDecline setTitle:NSLocalizedString(@"Decline", @"")	forState:UIControlStateNormal];
	[btnDecline setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	
	normalImage = [[UIImage imageNamed:@"button_red.png"] stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0];
	[btnDecline setBackgroundImage:normalImage forState:UIControlStateNormal];
	pressedImage = [[UIImage imageNamed:@"button_red_pressed.png"] stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0];
	[btnDecline setBackgroundImage:pressedImage forState:UIControlStateHighlighted];
	
    [super viewDidLoad];
}

-(MKAnnotationView *)mapView:(MKMapView *)mapView
		   viewForAnnotation:(id <MKAnnotation>)annotation {
	MKPinAnnotationView *pinDrop = [[MKPinAnnotationView alloc] initWithAnnotation:annotation 
																   reuseIdentifier:@"caller"];
	pinDrop.animatesDrop = YES;
	pinDrop.canShowCallout = YES;
	pinDrop.pinColor = MKPinAnnotationColorPurple;
	
	return pinDrop;
	
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

-(IBAction) declineCall {
	//NSLog(@"UNICALLAPP :: INCOMINGCALLController :: INFO :: decline button pressed");
	uniCallAppDelegate *uniCallApp = (uniCallAppDelegate *)[[UIApplication sharedApplication] delegate];
	CallInfo *callInfo = [uniCallApp getCallInfo];
	callInfo._event = CALL_EVENT_DECLINE;
	[uniCallApp uniCallEventHandler];	
}

-(IBAction) acceptCall {
	uniCallAppDelegate *uniCallApp = (uniCallAppDelegate *)[[UIApplication sharedApplication] delegate];
	CallInfo *callInfo = [uniCallApp getCallInfo];
	callInfo._event = CALL_EVENT_ACCEPT;
	[uniCallApp uniCallEventHandler];
}

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
	[incomingNumber release];
	[map release];
	[zipAnnotation release];
	[btnDecline release];
	[btnAccept release];
    [super dealloc];
}


@end
