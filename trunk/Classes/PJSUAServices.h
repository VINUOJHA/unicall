/*
 *  PJSUAServices.h
 *  uniCall
 *
 *  Created by Hussain Yaqoob on 5/2/11.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef _PJSUASERVICES_H
#define _PJSUASERVICES_H

//extern calles -> used in pjsuamanager

extern void
uniCallOnIncomingCall(const char *destNo, 
					  int callNo, 
					  int isHeader, 
					  float latitude, 
					  float longitude
					  );

extern void
uniCallOnConnectedCall(int callNo,
					   const char * dest);

extern void
uniCallOnDisconnectedCall(int callNo,
						  char *reason);

extern void
uniCallOnRegistrationState(int account_id,
						   int result,
						   int status_code);

extern void
uniCallStartRinging();

extern void 
uniCallStopRinging();

#endif /* _PJSUASERVICES_H */