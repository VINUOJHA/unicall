//
//  UniCallManager.h
//  uniCall
//
//  Created by Hussain Yaqoob on 4/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#ifndef _UNICALLMANAGER_H
#	define _UNICALLMANAGER_H

#import <Foundation/Foundation.h>
#include <stdio.h>
#include <pjsua-lib/pjsua.h>
#include "Constants.h"
#import "CallInfo.h"

@interface UniCallManager : NSObject {
	
	
}

/*
 * Initilize System
 ************************************************************/
+(void)uniCallSystemInit;

/*
 * Make Sip call to sipurl(destination)
 ************************************************************/
//+(IBAction)uniCallMakeSipCall:(NSString *) SipURL;
+(IBAction)uniCallMakeSipCall;

/**
 * Pick up and answer the call
 ************************************************************/
+(void)uniCallAcceptCall:(int) callNo;

/*
 * Reject call
 ************************************************************/
+(void)uniCallDeclineCall:(int) callNo;

/*
 * Hangup Sip call
 ************************************************************/
+(void)uniCallHangupCall;

/*
 *
 ************************************************************/
+(void)uniCallHoldCall:(int) callNo;

/*
 * Release Hold
 ************************************************************/
+(void)uniCallUnHoldCall:(int)callNo;

/*
 *
 ************************************************************/
+(void)uniCallMuteCall:(int) callNo;

/*
 * 
 ************************************************************/
+(void)uniCallUnMuteCall:(int)callNo;


/*
 * Send DMTF Signal of charactor parameter -- c
 ************************************************************/
+(void)unicallSendDtmf:(int)callNo DTMFCharacter:(char*)c;


/*
 * on_incoming_call -> this function will be called from PJSUAMANGER
 ************************************************************/
void uniCallOnIncomingCall(const char *destNo, int callNo, int isHeader, float latitude, float longitude);

/*
 * on call connected, ready to voice speak
 * this function will be called from pjsuamanger
 */
void uniCallOnConnectedCall(int callNo, const char * dest);

/*
 * on call is hanguped or disconnected
 */
void uniCallOnDisconnectedCall(int callNo, char *reason);

/*
 *
 */
void uniCallOnRegistrationState(int account_id, int result, int status_code);

/*
 *
 */
void uniCallStartRinging();

/*
 *
 */
void uniCallStopRinging();

@end

#endif /* _UNICALLMANAGER_H */