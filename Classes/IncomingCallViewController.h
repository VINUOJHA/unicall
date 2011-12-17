//
//  IncomingCallViewController.h
//  uniCall
//
//  Created by Hussain Yaqoob on 4/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface IncomingCallViewController : UIViewController <MKMapViewDelegate> {
	IBOutlet UILabel *incomingNumber;
	
	MKMapView *map;
	MKPlacemark *zipAnnotation;
	
	IBOutlet UIButton *btnAccept;
	IBOutlet UIButton *btnDecline;

}

@property (nonatomic, retain) UILabel *incomingNumber;

@property (nonatomic, retain) MKMapView *map;
@property (nonatomic, retain) MKPlacemark *zipAnnotation;

@property (nonatomic, retain) UIButton *btnAccept;
@property (nonatomic, retain) UIButton *btnDecline;

-(IBAction) declineCall;
-(IBAction) acceptCall;

@end