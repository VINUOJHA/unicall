//
//  Call.m
//  uniCall
//
//  Created by Hussain Yaqoob on 4/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CallInfo.h"


@implementation CallInfo

//@synthesize _direction;
@synthesize _type;
@synthesize _event;
@synthesize _number;
@synthesize _time;
@synthesize _account;
@synthesize _name;
@synthesize _duration;
@synthesize _callNo;

@synthesize _isLocation;
@synthesize _latitude;
@synthesize _longitude;

-(void)dealloc {
	[_time release];
	[_number release];
	[_accout release];
	[_name release];
	[super dealloc];
}

@end
