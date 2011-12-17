/*
 *  PJSUAManager.h
 *  uniCall
 *
 *  Created by Hussain Yaqoob on 4/23/11.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef _PJSUAMANAGER_H
#define _PJSUAMANAGER_H

#include <pjsua-lib/pjsua.h>
#import "Constants.h"
#import "PJSUAServices.h"

pj_status_t app_init();

void app_start();

int pjsuamanager_account_register(const char* sip_domain, 
								  const char* sip_username,
								  const char* sip_password
								  );

int pjsuamanager_account_unregister(int acc_id);

int pjsuamanager_account_reregister(int acc_id);

int pjsuamanager_call_answer(int call_id,
							 int code
							 );

int pjsuamanager_make_new_call(char *url,
							   int acc_id
							   );

int pjsuamanager_make_new_call_with_location(char *url, int acc_id, double latitude, double longitude);


int pjsuamanager_call_hold(int call_id);

int pjsuamanager_call_reinvite(int call_id);

int pjsuamanager_call_mute(int call_id);

int pjsuamanager_call_unmute(int call_id);

void pjsuamanager_call_hangup(int call_id);

void pjsuamanager_call_hangup_all();

void pjsuamanager_send_dtmf(int call_id,
							char *dtmf
							);

void pjsuamanager_send_dtmf_info();

#endif /* _PJSUAMANAGER_H */