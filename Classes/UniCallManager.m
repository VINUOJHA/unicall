//
//  UniCallManager.m
//  uniCall
//
//  Created by Hussain Yaqoob on 4/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#include <pthread.h>
#include "PJSUAManager.h"
#import "UniCallManager.h"
#import "uniCallAppDelegate.h"

typedef enum {
	INCOMING,
	OUTGOING
} DIRECTION;

struct active_call_t {
	int	callNo;
	DIRECTION direction;
};

@implementation UniCallManager

//uniCall**** functions will call pjsuamanager functions
//uniCallOn**** functions will be called from pjsuamanager fucntions

static BOOL activeCall;
static struct active_call_t activeCallInfo;
static pthread_mutex_t activecall_mutex = PTHREAD_MUTEX_INITIALIZER;

//precondition: activecall_mutex locked
BOOL isActiveCall()
{
	return activeCall;
}

//precondition: activecall_mutex locked
void setActiveCall(int callNo, DIRECTION direction)
{
	activeCall = YES;
	activeCallInfo.callNo = callNo;
	activeCallInfo.direction = direction;
}

//precondition: activecall_mutex locked
void freeActiveCall()
{
	activeCall = NO;
}

+(void)uniCallSystemInit
{
	uniCallAppDelegate *uniCallApp = (uniCallAppDelegate *)[[UIApplication sharedApplication] delegate];
	pj_status_t status;
	//init pjsua
	status = app_init();
	if (status != PJ_SUCCESS) {
		uniCallApp.registered = FALSE;
		NSLog(@"UniCallManager uniCallSystemInit() Initilization Error!!");
	} else {
		NSLog(@"UniCallManager Initialization OK");
	}
	//start pjsua
	app_start();
	
	//
	// Create User Account
	// Register user on the Sip Server
	//
	NSUserDefaults *info = [NSUserDefaults standardUserDefaults];
	const char *user_domain;
	const char *user_username;
	const char *user_password;
	NSInteger acc_id;
	user_domain = [[info objectForKey:kSipDomain] UTF8String];
	user_username = [[info objectForKey:kSipUsername] UTF8String];
	user_password = [[info objectForKey:kSipPassword] UTF8String];
	acc_id = pjsuamanager_account_register(user_domain, user_username, user_password);
	[info setInteger:acc_id forKey:kSipAccountID];
	[info synchronize];
	NSLog(@"account has been created with id= %d", acc_id);
	[uniCallApp updateUniCallAppStatus:@"Account created successfully" forLevel:APP_STATUS_GREEN];
	//return TRUE;
}

+(IBAction)uniCallMakeSipCall
{
	int   callNo;
	
	/*pthread_mutex_lock(&activecall_mutex);
	if(isActiveCall()) {
		pthread_mutex_unlock(&activecall_mutex);
		//return -1;
	}*/
	
	uniCallAppDelegate *uniCallApp = (uniCallAppDelegate *)[[UIApplication sharedApplication] delegate];
	CallInfo *callInfo = [uniCallApp getCallInfo];

	const char * dest;
	int user_id;
	
	NSString *sipURI = [[NSString alloc] initWithFormat:@"sip:%@@%@", callInfo._number, 
						[[NSUserDefaults standardUserDefaults] stringForKey:kSipDomain]];
	//NSLog(@" UNICallManager:: MakeSipCall:: sipuri: %@", sipURI);
		
	dest = [sipURI UTF8String];
	[sipURI release];
	user_id = [[NSUserDefaults standardUserDefaults] integerForKey:kSipAccountID];
	if ([uniCallApp.locationManager isEnabled]) {
		callNo = pjsuamanager_make_new_call_with_location((char *)dest, 
														  user_id, 
														  uniCallApp.locationManager.location.coordinate.latitude, 
														  uniCallApp.locationManager.location.coordinate.longitude
														  );
		NSLog(@"latitude:%f longitude:%f", uniCallApp.locationManager.location.coordinate.latitude, 
			  uniCallApp.locationManager.location.coordinate.longitude);
	} else {
		callNo = pjsuamanager_make_new_call((char *)dest, user_id);
	}
	
	if(callNo >= 0) {
		setActiveCall(callNo, OUTGOING); //outgoing
		callInfo._callNo = callNo;
	}
	
	//pthread_mutex_unlock(&activecall_mutex);
	//return callNo;
}

+(void) uniCallHangupCall
{
	//to check for error @later also
	int callNo = -1;
	
	pthread_mutex_lock(&activecall_mutex);
	if(isActiveCall()) {
		callNo = activeCallInfo.callNo;
	}
	pthread_mutex_unlock(&activecall_mutex);
	if (callNo>=0) {
		pjsuamanager_call_hangup(callNo);
		freeActiveCall();
	}
}

+(void)uniCallAcceptCall:(int)callNo
{
	//NSInteger callNo;
	//int temp = callNo;
	pjsuamanager_call_answer(callNo, 200); //200 PJSIP_SC_OK
	uniCallStopRinging();
}


+(void)uniCallDeclineCall:(int) callNo
{
	//NSLog(@" call id int = %d", callNo);
	//int temp = callNo;
	//NSLog(@" call id int = %d", temp);
	//to check for error @later also
	//TODO: solve thread problem with modalViewController
	//pthread_mutex_lock(&activecall_mutex);
	if(isActiveCall()) {
		//callNo = activeCallInfo.callNo;
		pjsuamanager_call_answer(callNo, 603); //603 PJSIP_SC_DECLINE
		freeActiveCall();
	}
	//pthread_mutex_unlock(&activecall_mutex);
	uniCallStopRinging();
	
}

+(void)uniCallHoldCall:(int)callNo
{
	pjsuamanager_call_hold(callNo);
}

+(void)uniCallUnHoldCall:(int)callNo
{
	pjsuamanager_call_reinvite(callNo);
}

+(void)uniCallMuteCall:(int)callNo
{
	pjsuamanager_call_mute(callNo);
}

+(void)uniCallUnMuteCall:(int)callNo
{
	pjsuamanager_call_unmute(callNo);
}

+(void)unicallSendDtmf:(int)callNo DTMFCharacter:(char*)c
{
	pjsuamanager_send_dtmf(callNo, c);
}

void uniCallOnIncomingCall(const char *destNo, int callNo, int isHeader, float latitude, float longitude)
{	
	static char phonename[128];
	static char phonenum[128];
	int len;
	
	pthread_mutex_lock(&activecall_mutex);
	if(isActiveCall()) {
		//answer busy -> PJSIP_SC_BUSY_HERE = 486
		pjsuamanager_call_answer(callNo, 486);
		//@ later -> add missed call
		pthread_mutex_unlock(&activecall_mutex);
		return;
	}
	// 'dest' is like this: -- "bob"<sip:200@any.sipprovider.com> --
	char *ptr;
	len = strlen(destNo);
	len = (len>=127) ? 127 : len;
	memcpy(phonename, destNo, len);
	memcpy(phonenum, destNo, len);
	
	phonename[len] = 0;
	ptr = strchr(&phonename[1], '"');
	if (ptr) *ptr = 0;
	len = strlen(&phonename[1]);
	memcpy(phonename, &phonename[1], len);
	phonename[len] = 0;
	
	// phonename has "bob" by now.
	// look for the actual sip number such as '200'.
	// if found, replace "bob".
	
	char* p1 = strstr(destNo, "<sip:");
	char* p2 = strstr(p1, "@");
	if (p1 && p2)
	{
		len = p2-p1-5; // p2 > p1+5 is always true
		if (len <= 127)
		{
			strncpy(phonenum, p1+5, len);
			phonenum[len] = 0;
		}
		else
		{
			strncpy(phonenum, destNo, len);
			phonenum[len] = 0;
		}

	}
	
	uniCallAppDelegate *uniCallApp = (uniCallAppDelegate *)[[UIApplication sharedApplication] delegate];
	[uniCallApp reinitCallInfo];
	// fill  call info after reinitilization
	CallInfo *callInfo = [uniCallApp getCallInfo];
	callInfo._event = CALL_EVENT_INCOMING;
	callInfo._number = [[NSString alloc] initWithUTF8String:phonenum];
	callInfo._name = [[NSString alloc] initWithUTF8String:phonename];
	callInfo._callNo = callNo;
	callInfo._time = [[NSDate alloc] init];
	//for now locaiton = 0;
	//DONE:: TODO:: change this
	if (isHeader == 1) {
		callInfo._isLocation = YES;
		callInfo._latitude = (double)latitude;
		callInfo._longitude = (double)longitude;
	} else {
		callInfo._isLocation = NO;
		callInfo._latitude = 0.0;
		callInfo._longitude = 0.0;		
	}
	
	[uniCallApp performSelectorOnMainThread:@selector(uniCallEventHandler) 
								 withObject:nil
							  waitUntilDone:(BOOL)NO
	 ];
	
	setActiveCall(callNo, INCOMING);
	uniCallStartRinging();
	pthread_mutex_unlock(&activecall_mutex);
}

void uniCallOnConnectedCall(int callNo, const char * dest)
{
	
	static char  phonenum[128];
	/*char        *ptr;
	char        *ptr2;
	
	ptr = strchr(dest, ':');
	if (ptr) {
		ptr ++;
		ptr2 = strchr(dest,'@');
		if (ptr2) {
			memcpy(phonenum, ptr, ptr2 - ptr + 1);
			phonenum[ptr2-ptr+1] = 0;
		}
	}
	 */
	
	char *ptr;
	int len;
	len = strlen(dest);
	len = (len>=127) ? 127 : len;
	memcpy(phonenum, dest, len);
	
	phonenum[len] = 0;
	ptr = strchr(&phonenum[1], '"');
	if (ptr) *ptr = 0;
	len = strlen(&phonenum[1]);
	memcpy(phonenum, &phonenum[1], len);
	phonenum[len] = 0;	
	
	uniCallAppDelegate *uniCallApp = (uniCallAppDelegate *)[[UIApplication sharedApplication] delegate];
	CallInfo *callInfo = [uniCallApp getCallInfo];
	callInfo._event = CALL_EVENT_CONNECTED;
	callInfo._name = [[NSString alloc] initWithUTF8String:phonenum];
	
	[uniCallApp performSelectorOnMainThread:@selector(uniCallEventHandler) 
								 withObject:nil
							  waitUntilDone:(BOOL)NO
	 ];
}

void uniCallOnDisconnectedCall(int callNo, char *reason)
{
	
	if(callNo != activeCallInfo.callNo && isActiveCall() )
		return;
	
	pthread_mutex_lock(&activecall_mutex);
	if(isActiveCall()) {
		freeActiveCall();
	}
	//NSLog(@"UniCallManager: Reason of Disconnecting ...");
	//fprintf(stdout, reason);
	//NSLog(@"UniCallManager: End of Reason");
	
	uniCallAppDelegate *uniCallApp = (uniCallAppDelegate *)[[UIApplication sharedApplication] delegate];
	CallInfo *callInfo = [uniCallApp getCallInfo];
	
	/*
	 if ((callInfo._type == CALL_TYPE_CANCELLED) && (callInfo._event == CALL_EVENT_END)) {
		
	} else {
		callInfo._type = CALL_TYPE_OUTGOING;
	}
	 */

		
	callInfo._event = CALL_EVENT_DISCONNECTED;
	
	[uniCallApp performSelectorOnMainThread:@selector(uniCallEventHandler) 
								 withObject:nil
							  waitUntilDone:(BOOL)NO
	 ];
	uniCallStopRinging();
	pthread_mutex_unlock(&activecall_mutex);
}

void uniCallOnRegistrationState(int account_id, int result, int status_code)
{
	NSLog(@"UniCallManager: Registration ...");
	NSLog(@"accound:%d, result:%d, code:%d", account_id, result, status_code);
	
	//stringForSipCode:(int)Code
	NSString *reason;
	switch (status_code) {
		case PJSIP_SC_OK:
			reason = [[NSString alloc] initWithFormat:@"Registration OK"];
			break;
		// Server Failure 5xx.
		case PJSIP_SC_BAD_GATEWAY:
			reason = [[NSString alloc] initWithFormat:@"Bad Gateway"];
			break;
		case PJSIP_SC_SERVICE_UNAVAILABLE:
			reason = [[NSString alloc] initWithFormat:@"Service unavailable"];
			break;
		case PJSIP_ENOCREDENTIAL:
			reason = [[NSString alloc] initWithFormat:@"wrong password or username"];
			break;
		case PJSIP_EFAILEDCREDENTIAL:
			reason = [[NSString alloc] initWithFormat:@"faild credential"];
			break;
		default:
			reason = [[NSString alloc] initWithFormat:@"Error: Default"];
			break;
	}
	
	NSLog(@"Reason: %@", reason);
	[reason release];
	
	if (result != -1) {
		//OK
		uniCallAppDelegate *uniCallApp = (uniCallAppDelegate *)[[UIApplication sharedApplication] delegate];
		[uniCallApp updateUniCallAppStatus:@"Registration Succeed" forLevel:APP_STATUS_GREEN];
		uniCallApp.registered = TRUE;
		
	} else {
		//ERROR
		uniCallAppDelegate *uniCallApp = (uniCallAppDelegate *)[[UIApplication sharedApplication] delegate];
		[uniCallApp updateUniCallAppStatus:@"Registration Failed ..." forLevel:APP_STATUS_GREEN];
		uniCallApp.registered = FALSE;
		
	}

}

void uniCallStartRinging()
{
	//uniCallAppDelegate *uniCallApp = (uniCallAppDelegate *)[[UIApplication sharedApplication] delegate];
	//[uniCallApp startRinging];
}

void uniCallStopRinging()
{
	//uniCallAppDelegate *uniCallApp = (uniCallAppDelegate *)[[UIApplication sharedApplication] delegate];
	//[uniCallApp stopRinging];
}

@end