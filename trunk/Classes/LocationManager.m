//
//  LocationManager.m
//  uniCall
//
//  Created by Hussain Yaqoob on 6/17/11.
//  Copyright 2011 vectrafon. All rights reserved.
//

#import "LocationManager.h"


@implementation LocationManager

@synthesize locationManager;
@synthesize location;
@synthesize _enabled;

-(id)init {
	
#ifdef __IPHONE_4_0
	self._enabled = [CLLocationManager locationServicesEnabled];
#else
	self._enabled = TRUE;
#endif
	
    // Create the manager object
	self.locationManager = [[CLLocationManager alloc] init];
	locationManager.delegate = self;
	
	// It ultimately determines how the manager will
    // attempt to acquire location and thus, the amount of power that will be consumed.
    NSInteger accuracy = [[NSUserDefaults standardUserDefaults] integerForKey:kAppLocationAccuracy];
	switch (accuracy) {
		case 0:
			locationManager.desiredAccuracy = kCLLocationAccuracyBest;
			break;
		case 1:
			locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
			break;
		case 2:
			locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
			break;
		case 3:
			locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
			break;
		case 4:
			locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
			break;
		default:
			locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
			break;
	}
	//TODO: change the distance filter to more than this
	// and move stop updating to dealloc
	//locationManager.distanceFilter = kCLDistanceFilterNone

    // Once configured, the location manager must be "started".
    [locationManager startUpdatingLocation];
	
	return self;
}

-(void) dealloc {
	[locationManager release];
	[location release];
	[super dealloc];
}

-(BOOL) isEnabled {
	return _enabled;
	
}

#pragma mark -
#pragma mark CLLocation Delegate
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {

	// test that the horizontal accuracy does not indicate an invalid measurement
    if (newLocation.horizontalAccuracy < 0)
		return;
	
	self.location = newLocation;
	[manager stopUpdatingLocation]; 
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    // The location "unknown" error simply means the manager is currently unable to get the location.
    // We can ignore this error for the scenario of getting a single location fix, because we already have a 
    // timeout that will stop the location manager to save power.
    if ([error code] != kCLErrorLocationUnknown) {
		self._enabled = FALSE;
        [manager stopUpdatingLocation];
    }
}

@end
