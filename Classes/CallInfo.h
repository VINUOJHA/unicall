//
//  Call.h
//  uniCall
//
//  Created by Hussain Yaqoob on 4/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#ifndef _CALLINFO_H
# define _CALLINFO_H

#import <Foundation/Foundation.h>

// may be changed to CALL_TYPE or ADD CALL_TYPE like, hanguped,timeout
typedef enum CALL_TYPE {
	CALL_TYPE_CANCELLED = 0,		//CANCELED THE CALL BEFORE THE OTHER ANSWER IT
	CALL_TYPE_MISSED = 1,		//NOT ANSWERING THE INCOMING CALL
	CALL_TYPE_INCOMING = 2,		//END OR HANGUP THE INCOMING CALL
	CALL_TYPE_OUTGOING = 3		//INVITE OR CALLING OTHER EITHER ANSWER IT OR NOT
} CALL_TYPE; //for the database

typedef enum CALL_EVENT {
	CALL_EVENT_ACCEPT		= 101,
	//CALL_REJECT		= 102,
	CALL_EVENT_DECLINE	= 102,
	CALL_EVENT_END		= 201,
	CALL_EVENT_HANGUP		= 202,
	//CALL_CALLING	= 301,
	CALL_EVENT_INCOMING	= 301,
	CALL_EVENT_OUTGOING = 302,
	CALL_EVENT_CONNECTED	= 303,
	CALL_EVENT_DISCONNECTED = 304
} CALL_EVENT;

typedef struct LOCATION {
	int latitude;
	int longitude;
} LOCATION;

@interface CallInfo : NSObject {
	
	//CALL_DIRECTION	_direction;
	CALL_TYPE		_type;
	CALL_EVENT		_event;
	
	// Name of the location of the earthquake.
	NSDate			*_time;
	
	NSString		*_number;
	NSString		*_accout;
	NSString		*_name;
	NSTimeInterval	_duration;
	int				_callNo;
	
	// Latitude and longitude of the caller
	BOOL			_isLocation;
	double				_latitude;
	double				_longitude;
}

@property (nonatomic, retain) NSString *_name;
@property (nonatomic, retain) NSString *_account;
@property (nonatomic, retain) NSDate *_time;
@property (nonatomic, retain) NSString *_number;

//@property (readwrite) CALL_DIRECTION _direction;
@property (readwrite) CALL_TYPE _type;
@property (readwrite) CALL_EVENT _event;

@property (readwrite) NSTimeInterval _duration;
@property (readwrite) int	_callNo;

@property (readwrite, assign) BOOL _isLocation;
@property (readwrite, assign) double _latitude;
@property (readwrite, assign) double _longitude;

@end

#endif /* _CALLINFO_H */