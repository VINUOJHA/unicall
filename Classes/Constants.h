/*
 *  Constants.h
 *  uniCall
 *
 *  Created by Hussain Yaqoob on 4/23/11.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

//constants for the setting preferences
#ifndef _CONSTANTS_H_
#define _CONSTANTS_H_

//define keys for application preferences || NSUserDefaults
#define kSipUsername	@"username"
#define kSipPassword	@"password"
#define kSipDomain		@"domain"
#define kSipProxy		@"proxy"
#define kSipAccountID	@"account_id"

#define kAppSilent		@"silent"
#define kAppVibrate		@"vibrate"

#define kAppLocationAccuracy @"accuracy"

//database
//#define kAppFirstTime	@"first_time_use"

#define kDBName			@"uniCalldb.sql"
#define kDBType			@"type"

//constants for notification center
#define kIncomingSipCall	@"nOnIncomingCallNotification"

//Reachability
#define kReachabilityChangedNotification @"kNetworkReachabilityChangedNotification"
/*!
 @abstract: constants for call events
 */
typedef enum CALL_STATUS {
	CALL_EVENT_HOLD,
	CALL_EVENT_UNHOLD,
	CALL_EVENT_MUTE,
	CALL_EVENT_UNMUTE
} CALL_STATUS;

typedef enum APP_STATUS {
	APP_STATUS_GREEN,
	APP_STATUS_WHITE,
	APP_STATUS_RED
} APP_STATUS;

typedef enum ALERTVIEW_TAG {
	ALERTVIEW_TAG_CONNECTIVITY,
	ALERTVIEW_TAG_REGISTERING
} ALERTVIEW_TAG;


#endif /* _CONSTANTS_H_ */