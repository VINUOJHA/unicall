//
//  LocationManager.h
//  uniCall
//
//  Created by Hussain Yaqoob on 6/17/11.
//  Copyright 2011 vectrafon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "Constants.h"

@interface LocationManager : NSObject <CLLocationManagerDelegate> {
	
	CLLocationManager *locationManager;
	CLLocation *location;
	BOOL _enabled;
}

@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, retain) CLLocation *location;
@property (nonatomic, assign) BOOL _enabled;

-(BOOL) isEnabled;

@end