/*
 *  PJSUAManager.c
 *  uniCall
 *
 *  Created by Hussain Yaqoob on 4/23/11.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

/* $Id: pjsua_app.c 3372 2010-11-18 05:15:04Z bennylp $ */
/* 
 * Copyright (C) 2008-2009 Teluu Inc. (http://www.teluu.com)
 * Copyright (C) 2003-2008 Benny Prijono <benny@prijono.org>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA 
 */


#include "PJSUAManager.h"
//#include "UniCallManager.h"
//#include "uniCallAppDelegate.h"

#define THIS_FILE	"PJSUAManager.c"
#define NO_LIMIT	(int)0x7FFFFFFF

//#define STEREO_DEMO
//#define TRANSPORT_ADAPTER_SAMPLE
//#define HAVE_MULTIPART_TEST

/* Ringtones		    US	       UK  */
#define RINGBACK_FREQ1	    440	    /* 400 */
#define RINGBACK_FREQ2	    480	    /* 450 */
#define RINGBACK_ON			2000    /* 400 */
#define RINGBACK_OFF	    4000    /* 200 */
#define RINGBACK_CNT	    1	    /* 2   */
#define RINGBACK_INTERVAL   4000    /* 2000 */

#define RING_FREQ1	    800
#define RING_FREQ2	    640
#define RING_ON		    200
#define RING_OFF	    100
#define RING_CNT	    3
#define RING_INTERVAL	3000


/* Call specific data */
struct call_data
{
    pj_timer_entry	    timer;
    pj_bool_t		    ringback_on;
    pj_bool_t		    ring_on;
};


/* Pjsua application data */
static struct app_config
{
    pjsua_config	    cfg;
    pjsua_logging_config    log_cfg;
    pjsua_media_config	    media_cfg;
    pj_bool_t		    no_refersub;
    pj_bool_t		    ipv6;
    pj_bool_t		    enable_qos;
    pj_bool_t		    no_tcp;
    pj_bool_t		    no_udp;
    pj_bool_t		    use_tls;
    pjsua_transport_config  udp_cfg;
    pjsua_transport_config  rtp_cfg;
    pjsip_redirect_op	    redir_op;

    unsigned		    acc_cnt;
    pjsua_acc_config	    acc_cfg[PJSUA_MAX_ACC];

    unsigned		    buddy_cnt;
    pjsua_buddy_config	    buddy_cfg[PJSUA_MAX_BUDDIES];

    struct call_data	    call_data[PJSUA_MAX_CALLS];

    pj_pool_t		   *pool;
    /* Compatibility with older pjsua */

    unsigned		    codec_cnt;
    pj_str_t		    codec_arg[32];
    unsigned		    codec_dis_cnt;
    pj_str_t                codec_dis[32];
    pj_bool_t		    null_audio;
    unsigned		    wav_count;
    pj_str_t		    wav_files[32];
    unsigned		    tone_count;
    pjmedia_tone_desc	    tones[32];
    pjsua_conf_port_id	    tone_slots[32];
    pjsua_player_id	    wav_id;
    pjsua_conf_port_id	    wav_port;
    pj_bool_t		    auto_play;
    pj_bool_t		    auto_play_hangup;
    pj_timer_entry	    auto_hangup_timer;
    pj_bool_t		    auto_loop;
    pj_bool_t		    auto_conf;
    pj_str_t		    rec_file;
    pj_bool_t		    auto_rec;
    pjsua_recorder_id	    rec_id;
    pjsua_conf_port_id	    rec_port;
    unsigned		    auto_answer;
    unsigned		    duration;

#ifdef STEREO_DEMO
    pjmedia_snd_port	   *snd;
    pjmedia_port	   *sc, *sc_ch1;
    pjsua_conf_port_id	    sc_ch1_slot;
#endif

    float		    mic_level,
			    speaker_level;

    int			    capture_dev, playback_dev;
    unsigned		    capture_lat, playback_lat;

    pj_bool_t		    no_tones;
    int			    ringback_slot;
    int			    ringback_cnt;
    pjmedia_port	   *ringback_port;
    int			    ring_slot;
    int			    ring_cnt;
    pjmedia_port	   *ring_port;

} app_config;


//static pjsua_acc_id	current_acc;
#define current_acc	pjsua_acc_get_default()
static pjsua_call_id	current_call = PJSUA_INVALID_ID;
static int		stdout_refresh = -1;
static const char      *stdout_refresh_text = "STDOUT_REFRESH";
static pj_bool_t	stdout_refresh_quit = PJ_FALSE;

static char some_buf[1024 * 3];

#ifdef STEREO_DEMO
static void stereo_demo();
#endif
#ifdef TRANSPORT_ADAPTER_SAMPLE
static pj_status_t transport_adapter_sample(void);
#endif
static pj_status_t create_ipv6_media_transports(void);
pj_status_t app_destroy(void);

static void ringback_start(pjsua_call_id call_id);
static void ring_start(pjsua_call_id call_id);
static void ring_stop(pjsua_call_id call_id);

pj_bool_t 	app_restart;
pj_log_func     *log_cb = NULL;

/*****************************************************************************
 * Configuration manipulation
 */

#if (defined(PJ_IPHONE_OS_HAS_MULTITASKING_SUPPORT) && \
    PJ_IPHONE_OS_HAS_MULTITASKING_SUPPORT!=0) || \
    defined(__IPHONE_4_0)
void keepAliveFunction(int timeout)
{
    int i;
    for (i=0; i<(int)pjsua_acc_get_count(); ++i) {
	if (!pjsua_acc_is_valid(i))
	    continue;

	if (app_config.acc_cfg[i].reg_timeout < timeout)
	    app_config.acc_cfg[i].reg_timeout = timeout;
	pjsua_acc_set_registration(i, PJ_TRUE);
    }
}
#endif

/* Set default config. */
static void default_config(struct app_config *cfg)
{
    char tmp[80];
    unsigned i;

    pjsua_config_default(&cfg->cfg);
    pj_ansi_sprintf(tmp, "PJSUA v%s/%s", pj_get_version(), PJ_OS_NAME);
    pj_strdup2_with_null(app_config.pool, &cfg->cfg.user_agent, tmp);

    pjsua_logging_config_default(&cfg->log_cfg);
    pjsua_media_config_default(&cfg->media_cfg);
    pjsua_transport_config_default(&cfg->udp_cfg);
    cfg->udp_cfg.port = 5060;
    pjsua_transport_config_default(&cfg->rtp_cfg);
    cfg->rtp_cfg.port = 4000;
    cfg->redir_op = PJSIP_REDIRECT_ACCEPT;
    cfg->duration = NO_LIMIT;
    cfg->wav_id = PJSUA_INVALID_ID;
    cfg->rec_id = PJSUA_INVALID_ID;
    cfg->wav_port = PJSUA_INVALID_ID;
    cfg->rec_port = PJSUA_INVALID_ID;
    cfg->mic_level = cfg->speaker_level = 1.0;
    cfg->capture_dev = PJSUA_INVALID_ID;
    cfg->playback_dev = PJSUA_INVALID_ID;
    cfg->capture_lat = PJMEDIA_SND_DEFAULT_REC_LATENCY;
    cfg->playback_lat = PJMEDIA_SND_DEFAULT_PLAY_LATENCY;
    cfg->ringback_slot = PJSUA_INVALID_ID;
    cfg->ring_slot = PJSUA_INVALID_ID;

    for (i=0; i<PJ_ARRAY_SIZE(cfg->acc_cfg); ++i)
	pjsua_acc_config_default(&cfg->acc_cfg[i]);

    for (i=0; i<PJ_ARRAY_SIZE(cfg->buddy_cfg); ++i)
	pjsua_buddy_config_default(&cfg->buddy_cfg[i]);
}

static int my_atoi(const char *cs)
{
    pj_str_t s;

    pj_cstr(&s, cs);
    if (cs[0] == '-') {
	s.ptr++, s.slen--;
	return 0 - (int)pj_strtoul(&s);
    } else if (cs[0] == '+') {
	s.ptr++, s.slen--;
	return pj_strtoul(&s);
    } else {
	return pj_strtoul(&s);
    }
}

/*
 * Dump application states.
 */
static void app_dump(pj_bool_t detail)
{
    pjsua_dump(detail);
}

/*
 * Print log of call states. Since call states may be too long for logger,
 * printing it is a bit tricky, it should be printed part by part as long 
 * as the logger can accept.
 */
static void log_call_dump(int call_id) 
{
    unsigned call_dump_len;
    unsigned part_len;
    unsigned part_idx;
    unsigned log_decor;

    pjsua_call_dump(call_id, PJ_TRUE, some_buf, 
		    sizeof(some_buf), "  ");
    call_dump_len = strlen(some_buf);

    log_decor = pj_log_get_decor();
    pj_log_set_decor(log_decor & ~(PJ_LOG_HAS_NEWLINE | PJ_LOG_HAS_CR));
    PJ_LOG(3,(THIS_FILE, "\n"));
    pj_log_set_decor(0);

    part_idx = 0;
    part_len = PJ_LOG_MAX_SIZE-80;
    while (part_idx < call_dump_len) {
	char p_orig, *p;

	p = &some_buf[part_idx];
	if (part_idx + part_len > call_dump_len)
	    part_len = call_dump_len - part_idx;
	p_orig = p[part_len];
	p[part_len] = '\0';
	PJ_LOG(3,(THIS_FILE, "%s", p));
	p[part_len] = p_orig;
	part_idx += part_len;
    }
    pj_log_set_decor(log_decor);
}

/*****************************************************************************
 * Console application
 */

static void ringback_start(pjsua_call_id call_id)
{
    if (app_config.no_tones)
	return;

    if (app_config.call_data[call_id].ringback_on)
	return;

    app_config.call_data[call_id].ringback_on = PJ_TRUE;

    if (++app_config.ringback_cnt==1 && 
	app_config.ringback_slot!=PJSUA_INVALID_ID) 
    {
	pjsua_conf_connect(app_config.ringback_slot, 0);
    }
}

static void ring_stop(pjsua_call_id call_id)
{
	//uniCallStopRinging();

    if (app_config.no_tones)
	return;

    if (app_config.call_data[call_id].ringback_on) {
	app_config.call_data[call_id].ringback_on = PJ_FALSE;

	pj_assert(app_config.ringback_cnt>0);
	if (--app_config.ringback_cnt == 0 && 
	    app_config.ringback_slot!=PJSUA_INVALID_ID) 
	{
	    pjsua_conf_disconnect(app_config.ringback_slot, 0);
	    pjmedia_tonegen_rewind(app_config.ringback_port);
	}
    }

    if (app_config.call_data[call_id].ring_on) {
	app_config.call_data[call_id].ring_on = PJ_FALSE;

	pj_assert(app_config.ring_cnt>0);
	if (--app_config.ring_cnt == 0 && 
	    app_config.ring_slot!=PJSUA_INVALID_ID) 
	{
	    pjsua_conf_disconnect(app_config.ring_slot, 0);
	    pjmedia_tonegen_rewind(app_config.ring_port);
	}
    }
}

static void ring_start(pjsua_call_id call_id)
{
    if (app_config.no_tones)
	return;

    if (app_config.call_data[call_id].ring_on)
	return;

    app_config.call_data[call_id].ring_on = PJ_TRUE;

    if (++app_config.ring_cnt==1 && 
	app_config.ring_slot!=PJSUA_INVALID_ID) 
    {
		pjsua_conf_connect(app_config.ring_slot, 0);
    }
	
	//uniCallStartRinging();
}

#ifdef HAVE_MULTIPART_TEST
  /*
   * Enable multipart in msg_data and add a dummy body into the
   * multipart bodies.
   */
  static void add_multipart(pjsua_msg_data *msg_data)
  {
      static pjsip_multipart_part *alt_part;

      if (!alt_part) {
	  pj_str_t type, subtype, content;

	  alt_part = pjsip_multipart_create_part(app_config.pool);

	  type = pj_str("text");
	  subtype = pj_str("plain");
	  content = pj_str("Sample text body of a multipart bodies");
	  alt_part->body = pjsip_msg_body_create(app_config.pool, &type,
						 &subtype, &content);
      }

      msg_data->multipart_ctype.type = pj_str("multipart");
      msg_data->multipart_ctype.subtype = pj_str("mixed");
      pj_list_push_back(&msg_data->multipart_parts, alt_part);
  }
#  define TEST_MULTIPART(msg_data)	add_multipart(msg_data)
#else
#  define TEST_MULTIPART(msg_data)
#endif

/*
 * Find next call when current call is disconnected or when user
 * press ']'
 */
static pj_bool_t find_next_call(void)
{
    int i, max;

    max = pjsua_call_get_max_count();
    for (i=current_call+1; i<max; ++i) {
	if (pjsua_call_is_active(i)) {
	    current_call = i;
	    return PJ_TRUE;
	}
    }

    for (i=0; i<current_call; ++i) {
	if (pjsua_call_is_active(i)) {
	    current_call = i;
	    return PJ_TRUE;
	}
    }

    current_call = PJSUA_INVALID_ID;
    return PJ_FALSE;
}


/*
 * Find previous call when user press '['
 */
static pj_bool_t find_prev_call(void)
{
    int i, max;

    max = pjsua_call_get_max_count();
    for (i=current_call-1; i>=0; --i) {
	if (pjsua_call_is_active(i)) {
	    current_call = i;
	    return PJ_TRUE;
	}
    }

    for (i=max-1; i>current_call; --i) {
	if (pjsua_call_is_active(i)) {
	    current_call = i;
	    return PJ_TRUE;
	}
    }

    current_call = PJSUA_INVALID_ID;
    return PJ_FALSE;
}


/* Callback from timer when the maximum call duration has been
 * exceeded.
 */
static void call_timeout_callback(pj_timer_heap_t *timer_heap,
				  struct pj_timer_entry *entry)
{
    pjsua_call_id call_id = entry->id;
    pjsua_msg_data msg_data;
    pjsip_generic_string_hdr warn;
    pj_str_t hname = pj_str("Warning");
    pj_str_t hvalue = pj_str("399 pjsua \"Call duration exceeded\"");

    PJ_UNUSED_ARG(timer_heap);

    if (call_id == PJSUA_INVALID_ID) {
	PJ_LOG(1,(THIS_FILE, "Invalid call ID in timer callback"));
	return;
    }
    
    /* Add warning header */
    pjsua_msg_data_init(&msg_data);
    pjsip_generic_string_hdr_init2(&warn, &hname, &hvalue);
    pj_list_push_back(&msg_data.hdr_list, &warn);

    /* Call duration has been exceeded; disconnect the call */
    PJ_LOG(3,(THIS_FILE, "Duration (%d seconds) has been exceeded "
			 "for call %d, disconnecting the call",
			 app_config.duration, call_id));
    entry->id = PJSUA_INVALID_ID;
    pjsua_call_hangup(call_id, 200, NULL, &msg_data);
}


/*
 * Handler when invite state has changed.
 */
static void on_call_state(pjsua_call_id call_id, pjsip_event *e)
{
    pjsua_call_info call_info;

    PJ_UNUSED_ARG(e);

    pjsua_call_get_info(call_id, &call_info);

    if (call_info.state == PJSIP_INV_STATE_DISCONNECTED) {

		/* Stop all ringback for this call */
		ring_stop(call_id);
			
		/* call UniCallManager */
		uniCallOnDisconnectedCall(call_id, call_info.last_status_text.ptr);
		
		
		/* Cancel duration timer, if any */
		if (app_config.call_data[call_id].timer.id != PJSUA_INVALID_ID) {
			struct call_data *cd = &app_config.call_data[call_id];
			pjsip_endpoint *endpt = pjsua_get_pjsip_endpt();

			cd->timer.id = PJSUA_INVALID_ID;
			pjsip_endpt_cancel_timer(endpt, &cd->timer);
		}

		/* Rewind play file when hangup automatically, 
		 * since file is not looped
		 */
		if (app_config.auto_play_hangup)
			pjsua_player_set_pos(app_config.wav_id, 0);


		PJ_LOG(3,(THIS_FILE, "Call %d is DISCONNECTED [reason=%d (%s)]", 
			  call_id,
			  call_info.last_status,
			  call_info.last_status_text.ptr));

		if (call_id == current_call) {
			find_next_call();
		}

		/* Dump media state upon disconnected */
		if (1) {
			PJ_LOG(5,(THIS_FILE, 
				  "Call %d disconnected, dumping media stats..", 
				  call_id));
			log_call_dump(call_id);
		}
	
	} else {

		if (app_config.duration!=NO_LIMIT && 
			call_info.state == PJSIP_INV_STATE_CONFIRMED) 
		{
			/*	inform UniCallManager	*/
			//@later -> dont check duration limit just the state
			//call_info.remote_contact.ptr
			uniCallOnConnectedCall(call_id, call_info.remote_info.ptr);
			
			/* Schedule timer to hangup call after the specified duration */
			struct call_data *cd = &app_config.call_data[call_id];
			pjsip_endpoint *endpt = pjsua_get_pjsip_endpt();
			pj_time_val delay;

			cd->timer.id = call_id;
			delay.sec = app_config.duration;
			delay.msec = 0;
			pjsip_endpt_schedule_timer(endpt, &cd->timer, &delay);
		}

		if (call_info.state == PJSIP_INV_STATE_EARLY) {
			int code;
			pj_str_t reason;
			pjsip_msg *msg;

			/* This can only occur because of TX or RX message */
			pj_assert(e->type == PJSIP_EVENT_TSX_STATE);

			if (e->body.tsx_state.type == PJSIP_EVENT_RX_MSG) {
			msg = e->body.tsx_state.src.rdata->msg_info.msg;
			} else {
			msg = e->body.tsx_state.src.tdata->msg;
			}

			code = msg->line.status.code;
			reason = msg->line.status.reason;

			/* Start ringback for 180 for UAC unless there's SDP in 180 */
			if (call_info.role==PJSIP_ROLE_UAC && code==180 && 
			msg->body == NULL && 
			call_info.media_status==PJSUA_CALL_MEDIA_NONE) 
			{
			ringback_start(call_id);
			}

			PJ_LOG(3,(THIS_FILE, "Call %d state changed to %s (%d %.*s)", 
				  call_id, call_info.state_text.ptr,
				  code, (int)reason.slen, reason.ptr));
		} else {
			PJ_LOG(3,(THIS_FILE, "Call %d state changed to %s", 
				  call_id,
				  call_info.state_text.ptr));
		}

		if (current_call==PJSUA_INVALID_ID)
			current_call = call_id;

    }
}


/**
 * Handler when there is incoming call.
 */
static void on_incoming_call(pjsua_acc_id acc_id, pjsua_call_id call_id,
			     pjsip_rx_data *rdata)
{
    pjsua_call_info call_info;

    PJ_UNUSED_ARG(acc_id);
	//PJ_UNUSED_ARG(rdata);
	
	//@later: maybe it is better to move the extracting code to UniCallManager
	
	//pjsip_msg_print(rdata->msg_info, buf, sizeof(buf));
	//pjsip_msg *msg = rdata->msg_info.msg;
	//const pj_str_t hname = pj_str("Location-Header");
	//pjsip_contact_hdr *h = (pjsip_contact_hdr*) pjsip_msg_find_hdr_by_name(msg, &hname, NULL);
	
	pjsip_msg *parsed_msg;
	pjsip_err_info_hdr *hdr;
	pj_str_t hname;
	//pj_str_t sname;
	int isHeader;
	float latitude;
	float longitude;
	
	hname = pj_str("Location-Header");
	parsed_msg = rdata->msg_info.msg;
	hdr = (pjsip_err_info_hdr *)pjsip_msg_find_hdr_by_name(parsed_msg, &hname, NULL);
	
	if(hdr!=NULL)
	{
		isHeader = 1;
		
		PJ_LOG(3,(THIS_FILE, "There is a header -- get location"));
		char headerInfo[128];
		pj_size_t size = 128;
		memset(headerInfo, '\0', 128);
		pjsip_hdr_print_on(hdr, headerInfo, size);
		//headerInfo should contain the location now
		printf("Header: %s \n", headerInfo);
		//extract data
		char header[30];
		char latit[25];
		char longi[25];
		sscanf(headerInfo, "%s %s %f %s %f", header, latit, &latitude, longi, &longitude);
		printf("Latitude: %f Longitude: %f", latitude, longitude);
		
	} else {
		isHeader = 0;
		latitude = 0.0;
		longitude = 0.0;
		PJ_LOG(3,(THIS_FILE, "There is no header - inform application"));
	}

    pjsua_call_get_info(call_id, &call_info);

    //@husain if (current_call==PJSUA_INVALID_ID)
	//@husain current_call = call_id;
/*@husain
#ifdef USE_GUI
    if (!showNotification(call_id))
	return;
#endif

    /* Start ringback */
    ring_start(call_id);
	
	/* call uniCallManager */
	uniCallOnIncomingCall(call_info.remote_info.ptr, call_id, isHeader, latitude, longitude);
	//uniCallOnIncomingCall(call_info.remote_info.ptr, call_id);
						 
    /*
	if (app_config.auto_answer > 0) {
		pjsua_call_answer(call_id, app_config.auto_answer, NULL, NULL);
    } else {
		//[[NSNotificationCenter defaultCenter] postNotificationName:nIncomingSipCall object:call_info.remote_info.ptr];
		//[UniCallManager uniCallOnIncomingCall:call_info.remote_info.ptr IncomingCallNumber:call_id];
		 //unicall_on_incoming_call(call_info.remote_info.ptr, call_id);
		
	}
	 

    if (app_config.auto_answer < 200) {
	PJ_LOG(3,(THIS_FILE,
		  "Incoming call for account %d!\n"
		  "From: %s\n"
		  "To: %s\n"
		  "Press a to answer or h to reject call",
		  acc_id,
		  call_info.remote_info.ptr,
		  call_info.local_info.ptr));
    }
	 */
}


/*
 * Handler when a transaction within a call has changed state.
 */
static void on_call_tsx_state(pjsua_call_id call_id,
			      pjsip_transaction *tsx,
			      pjsip_event *e)
{
    const pjsip_method info_method = 
    {
	PJSIP_OTHER_METHOD,
	{ "INFO", 4 }
    };

    if (pjsip_method_cmp(&tsx->method, &info_method)==0) {
	/*
	 * Handle INFO method.
	 */
	if (tsx->role == PJSIP_ROLE_UAC && 
	    (tsx->state == PJSIP_TSX_STATE_COMPLETED ||
	       (tsx->state == PJSIP_TSX_STATE_TERMINATED &&
	        e->body.tsx_state.prev_state != PJSIP_TSX_STATE_COMPLETED))) 
	{
	    /* Status of outgoing INFO request */
	    if (tsx->status_code >= 200 && tsx->status_code < 300) {
		PJ_LOG(4,(THIS_FILE, 
			  "Call %d: DTMF sent successfully with INFO",
			  call_id));
	    } else if (tsx->status_code >= 300) {
		PJ_LOG(4,(THIS_FILE, 
			  "Call %d: Failed to send DTMF with INFO: %d/%.*s",
			  call_id,
		          tsx->status_code,
			  (int)tsx->status_text.slen,
			  tsx->status_text.ptr));
	    }
	} else if (tsx->role == PJSIP_ROLE_UAS &&
		   tsx->state == PJSIP_TSX_STATE_TRYING)
	{
	    /* Answer incoming INFO with 200/OK */
	    pjsip_rx_data *rdata;
	    pjsip_tx_data *tdata;
	    pj_status_t status;

	    rdata = e->body.tsx_state.src.rdata;

	    if (rdata->msg_info.msg->body) {
		status = pjsip_endpt_create_response(tsx->endpt, rdata,
						     200, NULL, &tdata);
		if (status == PJ_SUCCESS)
		    status = pjsip_tsx_send_msg(tsx, tdata);

		PJ_LOG(3,(THIS_FILE, "Call %d: incoming INFO:\n%.*s", 
			  call_id,
			  (int)rdata->msg_info.msg->body->len,
			  rdata->msg_info.msg->body->data));
	    } else {
		status = pjsip_endpt_create_response(tsx->endpt, rdata,
						     400, NULL, &tdata);
		if (status == PJ_SUCCESS)
		    status = pjsip_tsx_send_msg(tsx, tdata);
	    }
	}
    }
}


/*
 * Callback on media state changed event.
 * The action may connect the call to sound device, to file, or
 * to loop the call.
 */
static void on_call_media_state(pjsua_call_id call_id)
{
    pjsua_call_info call_info;

    pjsua_call_get_info(call_id, &call_info);

    /* Stop ringback */
    ring_stop(call_id);

    /* Connect ports appropriately when media status is ACTIVE or REMOTE HOLD,
     * otherwise we should NOT connect the ports.
     */
    if (call_info.media_status == PJSUA_CALL_MEDIA_ACTIVE ||
	call_info.media_status == PJSUA_CALL_MEDIA_REMOTE_HOLD)
    {
	pj_bool_t connect_sound = PJ_TRUE;

	/* Loopback sound, if desired */
	if (app_config.auto_loop) {
	    pjsua_conf_connect(call_info.conf_slot, call_info.conf_slot);
	    connect_sound = PJ_FALSE;
	}

	/* Automatically record conversation, if desired */
	if (app_config.auto_rec && app_config.rec_port != PJSUA_INVALID_ID) {
	    pjsua_conf_connect(call_info.conf_slot, app_config.rec_port);
	}

	/* Stream a file, if desired */
	if ((app_config.auto_play || app_config.auto_play_hangup) && 
	    app_config.wav_port != PJSUA_INVALID_ID)
	{
	    pjsua_conf_connect(app_config.wav_port, call_info.conf_slot);
	    connect_sound = PJ_FALSE;
	}

	/* Put call in conference with other calls, if desired */
	if (app_config.auto_conf) {
	    pjsua_call_id call_ids[PJSUA_MAX_CALLS];
	    unsigned call_cnt=PJ_ARRAY_SIZE(call_ids);
	    unsigned i;

	    /* Get all calls, and establish media connection between
	     * this call and other calls.
	     */
	    pjsua_enum_calls(call_ids, &call_cnt);

	    for (i=0; i<call_cnt; ++i) {
		if (call_ids[i] == call_id)
		    continue;
		
		if (!pjsua_call_has_media(call_ids[i]))
		    continue;

		pjsua_conf_connect(call_info.conf_slot,
				   pjsua_call_get_conf_port(call_ids[i]));
		pjsua_conf_connect(pjsua_call_get_conf_port(call_ids[i]),
				   call_info.conf_slot);

		/* Automatically record conversation, if desired */
		if (app_config.auto_rec && app_config.rec_port != PJSUA_INVALID_ID) {
		    pjsua_conf_connect(pjsua_call_get_conf_port(call_ids[i]), 
				       app_config.rec_port);
		}

	    }

	    /* Also connect call to local sound device */
	    connect_sound = PJ_TRUE;
	}

	/* Otherwise connect to sound device */
	if (connect_sound) {
	    pjsua_conf_connect(call_info.conf_slot, 0);
	    pjsua_conf_connect(0, call_info.conf_slot);

	    /* Automatically record conversation, if desired */
	    if (app_config.auto_rec && app_config.rec_port != PJSUA_INVALID_ID) {
		pjsua_conf_connect(call_info.conf_slot, app_config.rec_port);
		pjsua_conf_connect(0, app_config.rec_port);
	    }
	}
    }

    /* Handle media status */
    switch (call_info.media_status) {
		case PJSUA_CALL_MEDIA_ACTIVE:
		PJ_LOG(3,(THIS_FILE, "Media for call %d is active", call_id));
		break;

		case PJSUA_CALL_MEDIA_LOCAL_HOLD:
		PJ_LOG(3,(THIS_FILE, "Media for call %d is suspended (hold) by local",
			  call_id));
		break;

		case PJSUA_CALL_MEDIA_REMOTE_HOLD:
		PJ_LOG(3,(THIS_FILE, 
			  "Media for call %d is suspended (hold) by remote",
			  call_id));
		break;

		case PJSUA_CALL_MEDIA_ERROR:
		PJ_LOG(3,(THIS_FILE,
			  "Media has reported error, disconnecting call"));
		{
			pj_str_t reason = pj_str("ICE negotiation failed");
			pjsua_call_hangup(call_id, 500, &reason, NULL);
		}
		break;

		case PJSUA_CALL_MEDIA_NONE:
		PJ_LOG(3,(THIS_FILE, 
			  "Media for call %d is inactive",
			  call_id));
		break;

		default:
		pj_assert(!"Unhandled media status");
		break;
    }
}

/*
 * DTMF callback.
 */
static void call_on_dtmf_callback(pjsua_call_id call_id, int dtmf)
{
	//TODO:
	/* inform uniCallManager */
    PJ_LOG(3,(THIS_FILE, "Incoming DTMF on call %d: %c", call_id, dtmf));
}

/*
 * Redirection handler.
 */
static pjsip_redirect_op call_on_redirected(pjsua_call_id call_id, 
					    const pjsip_uri *target,
					    const pjsip_event *e)
{
    PJ_UNUSED_ARG(e);

    if (app_config.redir_op == PJSIP_REDIRECT_PENDING) {
	char uristr[PJSIP_MAX_URL_SIZE];
	int len;

	len = pjsip_uri_print(PJSIP_URI_IN_FROMTO_HDR, target, uristr, 
			      sizeof(uristr));
	if (len < 1) {
	    pj_ansi_strcpy(uristr, "--URI too long--");
	}

	PJ_LOG(3,(THIS_FILE, "Call %d is being redirected to %.*s. "
		  "Press 'Ra' to accept, 'Rr' to reject, or 'Rd' to "
		  "disconnect.",
		  call_id, len, uristr));
    }

    return app_config.redir_op;
}

/*
 * Handler registration status has changed.
 */
static void on_reg_state(pjsua_acc_id acc_id)
{
    PJ_UNUSED_ARG(acc_id);

	/*
	 @Hussain:
	 * Handle registration status 
	 *  PJSIP_ENOCREDENTIAL error:
	 * or
	 *  PJSIP_EFAILEDCREDENTIAL error:
	 *		wrong credential. Check if the username and password combination is correct.
	 */
	
	pjsua_acc_info info;
	
	int result = -1;
	
	pjsua_acc_get_info(acc_id, &info);
	
	if (info.status != PJSIP_SC_OK) {
		result = -1;
	} else {
		result = 0;
	}
	
	uniCallOnRegistrationState(acc_id, result, info.status);
	
}


/*
 * Handler for incoming presence subscription request
 */
static void on_incoming_subscribe(pjsua_acc_id acc_id,
				  pjsua_srv_pres *srv_pres,
				  pjsua_buddy_id buddy_id,
				  const pj_str_t *from,
				  pjsip_rx_data *rdata,
				  pjsip_status_code *code,
				  pj_str_t *reason,
				  pjsua_msg_data *msg_data)
{
    /* Just accept the request (the default behavior) */
    PJ_UNUSED_ARG(acc_id);
    PJ_UNUSED_ARG(srv_pres);
    PJ_UNUSED_ARG(buddy_id);
    PJ_UNUSED_ARG(from);
    PJ_UNUSED_ARG(rdata);
    PJ_UNUSED_ARG(code);
    PJ_UNUSED_ARG(reason);
    PJ_UNUSED_ARG(msg_data);
}


/*
 * Handler on buddy state changed.
 */
static void on_buddy_state(pjsua_buddy_id buddy_id)
{
    pjsua_buddy_info info;
    pjsua_buddy_get_info(buddy_id, &info);

    PJ_LOG(3,(THIS_FILE, "%.*s status is %.*s, subscription state is %s "
			 "(last termination reason code=%d %.*s)",
	      (int)info.uri.slen,
	      info.uri.ptr,
	      (int)info.status_text.slen,
	      info.status_text.ptr,
	      info.sub_state_name,
	      info.sub_term_code,
	      (int)info.sub_term_reason.slen,
	      info.sub_term_reason.ptr));
}


/*
 * Subscription state has changed.
 */
static void on_buddy_evsub_state(pjsua_buddy_id buddy_id,
				 pjsip_evsub *sub,
				 pjsip_event *event)
{
    char event_info[80];

    PJ_UNUSED_ARG(sub);

    event_info[0] = '\0';

    if (event->type == PJSIP_EVENT_TSX_STATE &&
	    event->body.tsx_state.type == PJSIP_EVENT_RX_MSG)
    {
	pjsip_rx_data *rdata = event->body.tsx_state.src.rdata;
	snprintf(event_info, sizeof(event_info),
		 " (RX %s)",
		 pjsip_rx_data_get_info(rdata));
    }

    PJ_LOG(4,(THIS_FILE,
	      "Buddy %d: subscription state: %s (event: %s%s)",
	      buddy_id, pjsip_evsub_get_state_name(sub),
	      pjsip_event_str(event->type),
	      event_info));

}


/**
 * Incoming IM message (i.e. MESSAGE request)!
 */
static void on_pager(pjsua_call_id call_id, const pj_str_t *from, 
		     const pj_str_t *to, const pj_str_t *contact,
		     const pj_str_t *mime_type, const pj_str_t *text)
{
    /* Note: call index may be -1 */
    PJ_UNUSED_ARG(call_id);
    PJ_UNUSED_ARG(to);
    PJ_UNUSED_ARG(contact);
    PJ_UNUSED_ARG(mime_type);

    PJ_LOG(3,(THIS_FILE,"MESSAGE from %.*s: %.*s (%.*s)",
	      (int)from->slen, from->ptr,
	      (int)text->slen, text->ptr,
	      (int)mime_type->slen, mime_type->ptr));
}


/**
 * Received typing indication
 */
static void on_typing(pjsua_call_id call_id, const pj_str_t *from,
		      const pj_str_t *to, const pj_str_t *contact,
		      pj_bool_t is_typing)
{
    PJ_UNUSED_ARG(call_id);
    PJ_UNUSED_ARG(to);
    PJ_UNUSED_ARG(contact);

    PJ_LOG(3,(THIS_FILE, "IM indication: %.*s %s",
	      (int)from->slen, from->ptr,
	      (is_typing?"is typing..":"has stopped typing")));
}


/**
 * Call transfer request status.
 */
static void on_call_transfer_status(pjsua_call_id call_id,
				    int status_code,
				    const pj_str_t *status_text,
				    pj_bool_t final,
				    pj_bool_t *p_cont)
{
    PJ_LOG(3,(THIS_FILE, "Call %d: transfer status=%d (%.*s) %s",
	      call_id, status_code,
	      (int)status_text->slen, status_text->ptr,
	      (final ? "[final]" : "")));

    if (status_code/100 == 2) {
	PJ_LOG(3,(THIS_FILE, 
	          "Call %d: call transfered successfully, disconnecting call",
		  call_id));
	pjsua_call_hangup(call_id, PJSIP_SC_GONE, NULL, NULL);
	*p_cont = PJ_FALSE;
    }
}


/*
 * Notification that call is being replaced.
 */
static void on_call_replaced(pjsua_call_id old_call_id,
			     pjsua_call_id new_call_id)
{
    pjsua_call_info old_ci, new_ci;

    pjsua_call_get_info(old_call_id, &old_ci);
    pjsua_call_get_info(new_call_id, &new_ci);

    PJ_LOG(3,(THIS_FILE, "Call %d with %.*s is being replaced by "
			 "call %d with %.*s",
			 old_call_id, 
			 (int)old_ci.remote_info.slen, old_ci.remote_info.ptr,
			 new_call_id,
			 (int)new_ci.remote_info.slen, new_ci.remote_info.ptr));
}


/*
 * NAT type detection callback.
 */
static void on_nat_detect(const pj_stun_nat_detect_result *res)
{
    if (res->status != PJ_SUCCESS) {
	pjsua_perror(THIS_FILE, "NAT detection failed", res->status);
    } else {
	PJ_LOG(3, (THIS_FILE, "NAT detected as %s", res->nat_type_name));
    }
}


/*
 * MWI indication
 */
static void on_mwi_info(pjsua_acc_id acc_id, pjsua_mwi_info *mwi_info)
{
    pj_str_t body;
    
    PJ_LOG(3,(THIS_FILE, "Received MWI for acc %d:", acc_id));

    if (mwi_info->rdata->msg_info.ctype) {
	const pjsip_ctype_hdr *ctype = mwi_info->rdata->msg_info.ctype;

	PJ_LOG(3,(THIS_FILE, " Content-Type: %.*s/%.*s",
	          (int)ctype->media.type.slen,
		  ctype->media.type.ptr,
		  (int)ctype->media.subtype.slen,
		  ctype->media.subtype.ptr));
    }

    if (!mwi_info->rdata->msg_info.msg->body) {
	PJ_LOG(3,(THIS_FILE, "  no message body"));
	return;
    }

    body.ptr = mwi_info->rdata->msg_info.msg->body->data;
    body.slen = mwi_info->rdata->msg_info.msg->body->len;

    PJ_LOG(3,(THIS_FILE, " Body:\n%.*s", (int)body.slen, body.ptr));
}


/*
 * Transport status notification
 */
static void on_transport_state(pjsip_transport *tp, 
			       pjsip_transport_state state,
			       const pjsip_transport_state_info *info)
{
    char host_port[128];

    pj_ansi_snprintf(host_port, sizeof(host_port), "[%.*s:%d]",
		     (int)tp->remote_name.host.slen,
		     tp->remote_name.host.ptr,
		     tp->remote_name.port);

    switch (state) {
    case PJSIP_TP_STATE_CONNECTED:
	{
	    PJ_LOG(3,(THIS_FILE, "SIP %s transport is connected to %s",
		     tp->type_name, host_port));
	}
	break;

    case PJSIP_TP_STATE_DISCONNECTED:
	{
	    char buf[100];

	    snprintf(buf, sizeof(buf), "SIP %s transport is disconnected from %s",
		     tp->type_name, host_port);
	    pjsua_perror(THIS_FILE, buf, info->status);
	}
	break;

    default:
	break;
    }

#if defined(PJSIP_HAS_TLS_TRANSPORT) && PJSIP_HAS_TLS_TRANSPORT!=0

    if (!pj_ansi_stricmp(tp->type_name, "tls") && info->ext_info &&
	(state == PJSIP_TP_STATE_CONNECTED || 
	 ((pjsip_tls_state_info*)info->ext_info)->
			         ssl_sock_info->verify_status != PJ_SUCCESS))
    {
	pjsip_tls_state_info *tls_info = (pjsip_tls_state_info*)info->ext_info;
	pj_ssl_sock_info *ssl_sock_info = tls_info->ssl_sock_info;
	char buf[2048];
	const char *verif_msgs[32];
	unsigned verif_msg_cnt;

	/* Dump server TLS certificate */
	pj_ssl_cert_info_dump(ssl_sock_info->remote_cert_info, "  ",
			      buf, sizeof(buf));
	PJ_LOG(4,(THIS_FILE, "TLS cert info of %s:\n%s", host_port, buf));

	/* Dump server TLS certificate verification result */
	verif_msg_cnt = PJ_ARRAY_SIZE(verif_msgs);
	pj_ssl_cert_get_verify_status_strings(ssl_sock_info->verify_status,
					      verif_msgs, &verif_msg_cnt);
	PJ_LOG(3,(THIS_FILE, "TLS cert verification result of %s : %s",
			     host_port,
			     (verif_msg_cnt == 1? verif_msgs[0]:"")));
	if (verif_msg_cnt > 1) {
	    unsigned i;
	    for (i = 0; i < verif_msg_cnt; ++i)
		PJ_LOG(3,(THIS_FILE, "- %s", verif_msgs[i]));
	}

	if (ssl_sock_info->verify_status &&
	    !app_config.udp_cfg.tls_setting.verify_server) 
	{
	    PJ_LOG(3,(THIS_FILE, "PJSUA is configured to ignore TLS cert "
				 "verification errors"));
	}
    }

#endif

}

/*
 * Notification on ICE error.
 */
static void on_ice_transport_error(int index, pj_ice_strans_op op,
				   pj_status_t status, void *param)
{
    PJ_UNUSED_ARG(op);
    PJ_UNUSED_ARG(param);
    PJ_PERROR(1,(THIS_FILE, status,
	         "ICE keep alive failure for transport %d", index));
}

/*
 * Print buddy list.
 */
static void print_buddy_list(void)
{
    pjsua_buddy_id ids[64];
    int i;
    unsigned count = PJ_ARRAY_SIZE(ids);

    puts("Buddy list:");

    pjsua_enum_buddies(ids, &count);

    if (count == 0)
	puts(" -none-");
    else {
	for (i=0; i<(int)count; ++i) {
	    pjsua_buddy_info info;

	    if (pjsua_buddy_get_info(ids[i], &info) != PJ_SUCCESS)
		continue;

	    printf(" [%2d] <%.*s>  %.*s\n", 
		    ids[i]+1, 
		    (int)info.status_text.slen,
		    info.status_text.ptr, 
		    (int)info.uri.slen,
		    info.uri.ptr);
	}
    }
    puts("");
}


/*
 * Print account status.
 */
static void print_acc_status(int acc_id)
{
    char buf[80];
    pjsua_acc_info info;

    pjsua_acc_get_info(acc_id, &info);

    if (!info.has_registration) {
	pj_ansi_snprintf(buf, sizeof(buf), "%.*s", 
			 (int)info.status_text.slen,
			 info.status_text.ptr);

    } else {
	pj_ansi_snprintf(buf, sizeof(buf),
			 "%d/%.*s (expires=%d)",
			 info.status,
			 (int)info.status_text.slen,
			 info.status_text.ptr,
			 info.expires);

    }

    printf(" %c[%2d] %.*s: %s\n", (acc_id==current_acc?'*':' '),
	   acc_id,  (int)info.acc_uri.slen, info.acc_uri.ptr, buf);
    printf("       Online status: %.*s\n", 
	(int)info.online_status_text.slen,
	info.online_status_text.ptr);
}

/* Playfile done notification, set timer to hangup calls */
pj_status_t on_playfile_done(pjmedia_port *port, void *usr_data)
{
    pj_time_val delay;

    PJ_UNUSED_ARG(port);
    PJ_UNUSED_ARG(usr_data);

    /* Just rewind WAV when it is played outside of call */
    if (pjsua_call_get_count() == 0) {
	pjsua_player_set_pos(app_config.wav_id, 0);
	return PJ_SUCCESS;
    }

    /* Timer is already active */
    if (app_config.auto_hangup_timer.id == 1)
	return PJ_SUCCESS;

    app_config.auto_hangup_timer.id = 1;
    delay.sec = 0;
    delay.msec = 200; /* Give 200 ms before hangup */
    pjsip_endpt_schedule_timer(pjsua_get_pjsip_endpt(), 
			       &app_config.auto_hangup_timer, 
			       &delay);

    return PJ_SUCCESS;
}

/* Auto hangup timer callback */
static void hangup_timeout_callback(pj_timer_heap_t *timer_heap,
				    struct pj_timer_entry *entry)
{
    PJ_UNUSED_ARG(timer_heap);
    PJ_UNUSED_ARG(entry);

    app_config.auto_hangup_timer.id = 0;
    pjsua_call_hangup_all();
}

/*
 * Input simple string
 */
static pj_bool_t simple_input(const char *title, char *buf, pj_size_t len)
{
    char *p;

    printf("%s (empty to cancel): ", title); fflush(stdout);
    if (fgets(buf, len, stdin) == NULL)
	return PJ_FALSE;

    /* Remove trailing newlines. */
    for (p=buf; ; ++p) {
	if (*p=='\r' || *p=='\n') *p='\0';
	else if (!*p) break;
    }

    if (!*buf)
	return PJ_FALSE;
    
    return PJ_TRUE;
}


#define NO_NB	-2
struct input_result
{
    int	  nb_result;
    char *uri_result;
};


/*
 * Input URL.
 */
static void ui_input_url(const char *title, char *buf, int len, 
			 struct input_result *result)
{
    result->nb_result = NO_NB;
    result->uri_result = NULL;

    print_buddy_list();

    printf("Choices:\n"
	   "   0         For current dialog.\n"
	   "  -1         All %d buddies in buddy list\n"
	   "  [1 -%2d]    Select from buddy list\n"
	   "  URL        An URL\n"
	   "  <Enter>    Empty input (or 'q') to cancel\n"
	   , pjsua_get_buddy_count(), pjsua_get_buddy_count());
    printf("%s: ", title);

    fflush(stdout);
    if (fgets(buf, len, stdin) == NULL)
	return;
    len = strlen(buf);

    /* Left trim */
    while (pj_isspace(*buf)) {
	++buf;
	--len;
    }

    /* Remove trailing newlines */
    while (len && (buf[len-1] == '\r' || buf[len-1] == '\n'))
	buf[--len] = '\0';

    if (len == 0 || buf[0]=='q')
	return;

    if (pj_isdigit(*buf) || *buf=='-') {
	
	int i;
	
	if (*buf=='-')
	    i = 1;
	else
	    i = 0;

	for (; i<len; ++i) {
	    if (!pj_isdigit(buf[i])) {
		puts("Invalid input");
		return;
	    }
	}

	result->nb_result = my_atoi(buf);

	if (result->nb_result >= 0 && 
	    result->nb_result <= (int)pjsua_get_buddy_count()) 
	{
	    return;
	}
	if (result->nb_result == -1)
	    return;

	puts("Invalid input");
	result->nb_result = NO_NB;
	return;

    } else {
	pj_status_t status;

	if ((status=pjsua_verify_url(buf)) != PJ_SUCCESS) {
	    pjsua_perror(THIS_FILE, "Invalid URL", status);
	    return;
	}

	result->uri_result = buf;
    }
}

/*
 * List the ports in conference bridge
 */
static void conf_list(void)
{
    unsigned i, count;
    pjsua_conf_port_id id[PJSUA_MAX_CALLS];

    printf("Conference ports:\n");

    count = PJ_ARRAY_SIZE(id);
    pjsua_enum_conf_ports(id, &count);

    for (i=0; i<count; ++i) {
	char txlist[PJSUA_MAX_CALLS*4+10];
	unsigned j;
	pjsua_conf_port_info info;

	pjsua_conf_get_port_info(id[i], &info);

	txlist[0] = '\0';
	for (j=0; j<info.listener_cnt; ++j) {
	    char s[10];
	    pj_ansi_sprintf(s, "#%d ", info.listeners[j]);
	    pj_ansi_strcat(txlist, s);
	}
	printf("Port #%02d[%2dKHz/%dms/%d] %20.*s  transmitting to: %s\n", 
	       info.slot_id, 
	       info.clock_rate/1000,
	       info.samples_per_frame*1000/info.channel_count/info.clock_rate,
	       info.channel_count,
	       (int)info.name.slen, 
	       info.name.ptr,
	       txlist);

    }
    puts("");
}


/*
 * Send arbitrary request to remote host
 */
static void send_request(char *cstr_method, const pj_str_t *dst_uri)
{
    pj_str_t str_method;
    pjsip_method method;
    pjsip_tx_data *tdata;
    pjsip_endpoint *endpt;
    pj_status_t status;

    endpt = pjsua_get_pjsip_endpt();

    str_method = pj_str(cstr_method);
    pjsip_method_init_np(&method, &str_method);

    status = pjsua_acc_create_request(current_acc, &method, dst_uri, &tdata);

    status = pjsip_endpt_send_request(endpt, tdata, -1, NULL, NULL);
    if (status != PJ_SUCCESS) {
	pjsua_perror(THIS_FILE, "Unable to send request", status);
	return;
    }
}


/*
 * Change extended online status.
 */
static void change_online_status(void)
{
    char menuin[32];
    pj_bool_t online_status;
    pjrpid_element elem;
    int i, choice;

    enum {
	AVAILABLE, BUSY, OTP, IDLE, AWAY, BRB, OFFLINE, OPT_MAX
    };

    struct opt {
	int id;
	char *name;
    } opts[] = {
	{ AVAILABLE, "Available" },
	{ BUSY, "Busy"},
	{ OTP, "On the phone"},
	{ IDLE, "Idle"},
	{ AWAY, "Away"},
	{ BRB, "Be right back"},
	{ OFFLINE, "Offline"}
    };

    printf("\n"
	   "Choices:\n");
    for (i=0; i<PJ_ARRAY_SIZE(opts); ++i) {
	printf("  %d  %s\n", opts[i].id+1, opts[i].name);
    }

    if (!simple_input("Select status", menuin, sizeof(menuin)))
	return;

    choice = atoi(menuin) - 1;
    if (choice < 0 || choice >= OPT_MAX) {
	puts("Invalid selection");
	return;
    }

    pj_bzero(&elem, sizeof(elem));
    elem.type = PJRPID_ELEMENT_TYPE_PERSON;

    online_status = PJ_TRUE;

    switch (choice) {
    case AVAILABLE:
	break;
    case BUSY:
	elem.activity = PJRPID_ACTIVITY_BUSY;
	elem.note = pj_str("Busy");
	break;
    case OTP:
	elem.activity = PJRPID_ACTIVITY_BUSY;
	elem.note = pj_str("On the phone");
	break;
    case IDLE:
	elem.activity = PJRPID_ACTIVITY_UNKNOWN;
	elem.note = pj_str("Idle");
	break;
    case AWAY:
	elem.activity = PJRPID_ACTIVITY_AWAY;
	elem.note = pj_str("Away");
	break;
    case BRB:
	elem.activity = PJRPID_ACTIVITY_UNKNOWN;
	elem.note = pj_str("Be right back");
	break;
    case OFFLINE:
	online_status = PJ_FALSE;
	break;
    }

    pjsua_acc_set_online_status2(current_acc, online_status, &elem);
}


/*
 * Change codec priorities.
 */
static void manage_codec_prio(void)
{
    pjsua_codec_info c[32];
    unsigned i, count = PJ_ARRAY_SIZE(c);
    char input[32];
    char *codec, *prio;
    pj_str_t id;
    int new_prio;
    pj_status_t status;

    printf("List of codecs:\n");

    pjsua_enum_codecs(c, &count);
    for (i=0; i<count; ++i) {
	printf("  %d\t%.*s\n", c[i].priority, (int)c[i].codec_id.slen,
			       c[i].codec_id.ptr);
    }

    puts("");
    puts("Enter codec id and its new priority "
	 "(e.g. \"speex/16000 200\"), empty to cancel:");

    printf("Codec name (\"*\" for all) and priority: ");
    if (fgets(input, sizeof(input), stdin) == NULL)
	return;
    if (input[0]=='\r' || input[0]=='\n') {
	puts("Done");
	return;
    }

    codec = strtok(input, " \t\r\n");
    prio = strtok(NULL, " \r\n");

    if (!codec || !prio) {
	puts("Invalid input");
	return;
    }

    new_prio = atoi(prio);
    if (new_prio < 0) 
	new_prio = 0;
    else if (new_prio > PJMEDIA_CODEC_PRIO_HIGHEST) 
	new_prio = PJMEDIA_CODEC_PRIO_HIGHEST;

    status = pjsua_codec_set_priority(pj_cstr(&id, codec), 
				      (pj_uint8_t)new_prio);
    if (status != PJ_SUCCESS)
	pjsua_perror(THIS_FILE, "Error setting codec priority", status);
}

/*****************************************************************************
 * A simple module to handle otherwise unhandled request. We will register
 * this with the lowest priority.
 */

/* Notification on incoming request */
static pj_bool_t default_mod_on_rx_request(pjsip_rx_data *rdata)
{
    pjsip_tx_data *tdata;
    pjsip_status_code status_code;
    pj_status_t status;

    /* Don't respond to ACK! */
    if (pjsip_method_cmp(&rdata->msg_info.msg->line.req.method, 
			 &pjsip_ack_method) == 0)
	return PJ_TRUE;

    /* Create basic response. */
    if (pjsip_method_cmp(&rdata->msg_info.msg->line.req.method, 
			 &pjsip_notify_method) == 0)
    {
	/* Unsolicited NOTIFY's, send with Bad Request */
	status_code = PJSIP_SC_BAD_REQUEST;
    } else {
	/* Probably unknown method */
	status_code = PJSIP_SC_METHOD_NOT_ALLOWED;
    }
    status = pjsip_endpt_create_response(pjsua_get_pjsip_endpt(), 
					 rdata, status_code, 
					 NULL, &tdata);
    if (status != PJ_SUCCESS) {
	pjsua_perror(THIS_FILE, "Unable to create response", status);
	return PJ_TRUE;
    }

    /* Add Allow if we're responding with 405 */
    if (status_code == PJSIP_SC_METHOD_NOT_ALLOWED) {
	const pjsip_hdr *cap_hdr;
	cap_hdr = pjsip_endpt_get_capability(pjsua_get_pjsip_endpt(), 
					     PJSIP_H_ALLOW, NULL);
	if (cap_hdr) {
	    pjsip_msg_add_hdr(tdata->msg, pjsip_hdr_clone(tdata->pool, 
							   cap_hdr));
	}
    }

    /* Add User-Agent header */
    {
	pj_str_t user_agent;
	char tmp[80];
	const pj_str_t USER_AGENT = { "User-Agent", 10};
	pjsip_hdr *h;

	pj_ansi_snprintf(tmp, sizeof(tmp), "PJSUA v%s/%s", 
			 pj_get_version(), PJ_OS_NAME);
	pj_strdup2_with_null(tdata->pool, &user_agent, tmp);

	h = (pjsip_hdr*) pjsip_generic_string_hdr_create(tdata->pool,
							 &USER_AGENT,
							 &user_agent);
	pjsip_msg_add_hdr(tdata->msg, h);
    }

    pjsip_endpt_send_response2(pjsua_get_pjsip_endpt(), rdata, tdata, 
			       NULL, NULL);

    return PJ_TRUE;
}


/* The module instance. */
static pjsip_module mod_default_handler = 
{
    NULL, NULL,							/* prev, next.		*/
    { "mod-default-handler", 19 },		/* Name.			*/
    -1,									/* Id				*/
    PJSIP_MOD_PRIORITY_APPLICATION+99,	/* Priority	        */
    NULL,								/* load()			*/
    NULL,								/* start()			*/
    NULL,								/* stop()			*/
    NULL,								/* unload()			*/
    &default_mod_on_rx_request,			/* on_rx_request()	*/
    NULL,								/* on_rx_response()	*/
    NULL,								/* on_tx_request.	*/
    NULL,								/* on_tx_response()	*/
    NULL,								/* on_tsx_state()	*/

};




/*****************************************************************************
 * Public API
 */

pj_status_t app_init()
{
    pjsua_transport_id transport_id = -1;
    pjsua_transport_config tcp_cfg;
    unsigned i;
    pj_status_t status;

    app_restart = PJ_FALSE;

    /* Create pjsua */
    status = pjsua_create();
    if (status != PJ_SUCCESS)
	return status;

    /* Create pool for application */
    app_config.pool = pjsua_pool_create("pjsua-app", 1000, 1000);

    /* Initialize default config */
    default_config(&app_config);
    
    /* Initialize application callbacks */
    app_config.cfg.cb.on_call_state = &on_call_state;
    app_config.cfg.cb.on_call_media_state = &on_call_media_state;
    app_config.cfg.cb.on_incoming_call = &on_incoming_call;
    app_config.cfg.cb.on_call_tsx_state = &on_call_tsx_state;
    app_config.cfg.cb.on_dtmf_digit = &call_on_dtmf_callback;
    app_config.cfg.cb.on_call_redirected = &call_on_redirected;
    app_config.cfg.cb.on_reg_state = &on_reg_state;
    app_config.cfg.cb.on_incoming_subscribe = &on_incoming_subscribe;
    app_config.cfg.cb.on_buddy_state = &on_buddy_state;
    app_config.cfg.cb.on_buddy_evsub_state = &on_buddy_evsub_state;
    app_config.cfg.cb.on_pager = &on_pager;
    app_config.cfg.cb.on_typing = &on_typing;
    app_config.cfg.cb.on_call_transfer_status = &on_call_transfer_status;
    app_config.cfg.cb.on_call_replaced = &on_call_replaced;
    app_config.cfg.cb.on_nat_detect = &on_nat_detect;
    app_config.cfg.cb.on_mwi_info = &on_mwi_info;
    app_config.cfg.cb.on_transport_state = &on_transport_state;
    app_config.cfg.cb.on_ice_transport_error = &on_ice_transport_error;
    app_config.log_cfg.cb = log_cb;

    /* Set sound device latency */
    if (app_config.capture_lat > 0)
	app_config.media_cfg.snd_rec_latency = app_config.capture_lat;
    if (app_config.playback_lat)
	app_config.media_cfg.snd_play_latency = app_config.playback_lat;

    /* Initialize pjsua */
    status = pjsua_init(&app_config.cfg, &app_config.log_cfg,
			&app_config.media_cfg);
    if (status != PJ_SUCCESS)
	return status;

    /* Initialize our module to handle otherwise unhandled request */
    status = pjsip_endpt_register_module(pjsua_get_pjsip_endpt(),
					 &mod_default_handler);
    if (status != PJ_SUCCESS)
	return status;

#ifdef STEREO_DEMO
    stereo_demo();
#endif

    /* Initialize calls data */
    for (i=0; i<PJ_ARRAY_SIZE(app_config.call_data); ++i) {
	app_config.call_data[i].timer.id = PJSUA_INVALID_ID;
	app_config.call_data[i].timer.cb = &call_timeout_callback;
    }

    /* Optionally registers WAV file */
    for (i=0; i<app_config.wav_count; ++i) {
	pjsua_player_id wav_id;
	unsigned play_options = 0;

	if (app_config.auto_play_hangup)
	    play_options |= PJMEDIA_FILE_NO_LOOP;

	status = pjsua_player_create(&app_config.wav_files[i], play_options, 
				     &wav_id);
	if (status != PJ_SUCCESS)
	    goto on_error;

	if (app_config.wav_id == PJSUA_INVALID_ID) {
	    app_config.wav_id = wav_id;
	    app_config.wav_port = pjsua_player_get_conf_port(app_config.wav_id);
	    if (app_config.auto_play_hangup) {
		pjmedia_port *port;

		pjsua_player_get_port(app_config.wav_id, &port);
		status = pjmedia_wav_player_set_eof_cb(port, NULL, 
						       &on_playfile_done);
		if (status != PJ_SUCCESS)
		    goto on_error;

		pj_timer_entry_init(&app_config.auto_hangup_timer, 0, NULL, 
				    &hangup_timeout_callback);
	    }
	}
    }

    /* Optionally registers tone players */
    for (i=0; i<app_config.tone_count; ++i) {
	pjmedia_port *tport;
	char name[80];
	pj_str_t label;
	pj_status_t status;

	pj_ansi_snprintf(name, sizeof(name), "tone-%d,%d",
			 app_config.tones[i].freq1, 
			 app_config.tones[i].freq2);
	label = pj_str(name);
	status = pjmedia_tonegen_create2(app_config.pool, &label,
					 8000, 1, 160, 16, 
					 PJMEDIA_TONEGEN_LOOP,  &tport);
	if (status != PJ_SUCCESS) {
	    pjsua_perror(THIS_FILE, "Unable to create tone generator", status);
	    goto on_error;
	}

	status = pjsua_conf_add_port(app_config.pool, tport, 
				     &app_config.tone_slots[i]);
	pj_assert(status == PJ_SUCCESS);

	status = pjmedia_tonegen_play(tport, 1, &app_config.tones[i], 0);
	pj_assert(status == PJ_SUCCESS);
    }

    /* Optionally create recorder file, if any. */
    if (app_config.rec_file.slen) {
	status = pjsua_recorder_create(&app_config.rec_file, 0, NULL, 0, 0,
				       &app_config.rec_id);
	if (status != PJ_SUCCESS)
	    goto on_error;

	app_config.rec_port = pjsua_recorder_get_conf_port(app_config.rec_id);
    }

    pj_memcpy(&tcp_cfg, &app_config.udp_cfg, sizeof(tcp_cfg));

    /* Create ringback tones */
    if (app_config.no_tones == PJ_FALSE) {
	unsigned i, samples_per_frame;
	pjmedia_tone_desc tone[RING_CNT+RINGBACK_CNT];
	pj_str_t name;

	samples_per_frame = app_config.media_cfg.audio_frame_ptime * 
			    app_config.media_cfg.clock_rate *
			    app_config.media_cfg.channel_count / 1000;

	/* Ringback tone (call is ringing) */
	name = pj_str("ringback");
	status = pjmedia_tonegen_create2(app_config.pool, &name, 
					 app_config.media_cfg.clock_rate,
					 app_config.media_cfg.channel_count, 
					 samples_per_frame,
					 16, PJMEDIA_TONEGEN_LOOP, 
					 &app_config.ringback_port);
	if (status != PJ_SUCCESS)
	    goto on_error;

	pj_bzero(&tone, sizeof(tone));
	for (i=0; i<RINGBACK_CNT; ++i) {
	    tone[i].freq1 = RINGBACK_FREQ1;
	    tone[i].freq2 = RINGBACK_FREQ2;
	    tone[i].on_msec = RINGBACK_ON;
	    tone[i].off_msec = RINGBACK_OFF;
	}
	tone[RINGBACK_CNT-1].off_msec = RINGBACK_INTERVAL;

	pjmedia_tonegen_play(app_config.ringback_port, RINGBACK_CNT, tone,
			     PJMEDIA_TONEGEN_LOOP);


	status = pjsua_conf_add_port(app_config.pool, app_config.ringback_port,
				     &app_config.ringback_slot);
	if (status != PJ_SUCCESS)
	    goto on_error;

	/* Ring (to alert incoming call) */
	name = pj_str("ring");
	status = pjmedia_tonegen_create2(app_config.pool, &name, 
					 app_config.media_cfg.clock_rate,
					 app_config.media_cfg.channel_count, 
					 samples_per_frame,
					 16, PJMEDIA_TONEGEN_LOOP, 
					 &app_config.ring_port);
	if (status != PJ_SUCCESS)
	    goto on_error;

	for (i=0; i<RING_CNT; ++i) {
	    tone[i].freq1 = RING_FREQ1;
	    tone[i].freq2 = RING_FREQ2;
	    tone[i].on_msec = RING_ON;
	    tone[i].off_msec = RING_OFF;
	}
	tone[RING_CNT-1].off_msec = RING_INTERVAL;

	pjmedia_tonegen_play(app_config.ring_port, RING_CNT, 
			     tone, PJMEDIA_TONEGEN_LOOP);

	status = pjsua_conf_add_port(app_config.pool, app_config.ring_port,
				     &app_config.ring_slot);
	if (status != PJ_SUCCESS)
	    goto on_error;

    }

    /* Add UDP transport unless it's disabled. */
    if (!app_config.no_udp) {
	pjsua_acc_id aid;
	pjsip_transport_type_e type = PJSIP_TRANSPORT_UDP;

	status = pjsua_transport_create(type,
					&app_config.udp_cfg,
					&transport_id);
	if (status != PJ_SUCCESS)
	    goto on_error;

	/* Add local account */
	pjsua_acc_add_local(transport_id, PJ_TRUE, &aid);
	//pjsua_acc_set_transport(aid, transport_id);
	pjsua_acc_set_online_status(current_acc, PJ_TRUE);

	if (app_config.udp_cfg.port == 0) {
	    pjsua_transport_info ti;
	    pj_sockaddr_in *a;

	    pjsua_transport_get_info(transport_id, &ti);
	    a = (pj_sockaddr_in*)&ti.local_addr;

	    tcp_cfg.port = pj_ntohs(a->sin_port);
	}
    }

    /* Add UDP IPv6 transport unless it's disabled. */
    if (!app_config.no_udp && app_config.ipv6) {
	pjsua_acc_id aid;
	pjsip_transport_type_e type = PJSIP_TRANSPORT_UDP6;
	pjsua_transport_config udp_cfg;

	udp_cfg = app_config.udp_cfg;
	if (udp_cfg.port == 0)
	    udp_cfg.port = 5060;
	else
	    udp_cfg.port += 10;
	status = pjsua_transport_create(type,
					&udp_cfg,
					&transport_id);
	if (status != PJ_SUCCESS)
	    goto on_error;

	/* Add local account */
	pjsua_acc_add_local(transport_id, PJ_TRUE, &aid);
	//pjsua_acc_set_transport(aid, transport_id);
	pjsua_acc_set_online_status(current_acc, PJ_TRUE);

	if (app_config.udp_cfg.port == 0) {
	    pjsua_transport_info ti;
	    pj_sockaddr_in *a;

	    pjsua_transport_get_info(transport_id, &ti);
	    a = (pj_sockaddr_in*)&ti.local_addr;

	    tcp_cfg.port = pj_ntohs(a->sin_port);
	}
    }

    /* Add TCP transport unless it's disabled */
    if (!app_config.no_tcp) {
	status = pjsua_transport_create(PJSIP_TRANSPORT_TCP,
					&tcp_cfg, 
					&transport_id);
	if (status != PJ_SUCCESS)
	    goto on_error;

	/* Add local account */
	pjsua_acc_add_local(transport_id, PJ_TRUE, NULL);
	pjsua_acc_set_online_status(current_acc, PJ_TRUE);

    }


#if defined(PJSIP_HAS_TLS_TRANSPORT) && PJSIP_HAS_TLS_TRANSPORT!=0
    /* Add TLS transport when application wants one */
    if (app_config.use_tls) {

	pjsua_acc_id acc_id;

	/* Copy the QoS settings */
	tcp_cfg.tls_setting.qos_type = tcp_cfg.qos_type;
	pj_memcpy(&tcp_cfg.tls_setting.qos_params, &tcp_cfg.qos_params, 
		  sizeof(tcp_cfg.qos_params));

	/* Set TLS port as TCP port+1 */
	tcp_cfg.port++;
	status = pjsua_transport_create(PJSIP_TRANSPORT_TLS,
					&tcp_cfg, 
					&transport_id);
	tcp_cfg.port--;
	if (status != PJ_SUCCESS)
	    goto on_error;
	
	/* Add local account */
	pjsua_acc_add_local(transport_id, PJ_FALSE, &acc_id);
	pjsua_acc_set_online_status(acc_id, PJ_TRUE);
    }
#endif

    if (transport_id == -1) {
	PJ_LOG(1,(THIS_FILE, "Error: no transport is configured"));
	status = -1;
	goto on_error;
    }


    /* Add accounts */
    for (i=0; i<app_config.acc_cnt; ++i) {
	status = pjsua_acc_add(&app_config.acc_cfg[i], PJ_TRUE, NULL);
	if (status != PJ_SUCCESS)
	    goto on_error;
	pjsua_acc_set_online_status(current_acc, PJ_TRUE);
    }

    /* Add buddies */
    for (i=0; i<app_config.buddy_cnt; ++i) {
	status = pjsua_buddy_add(&app_config.buddy_cfg[i], NULL);
	if (status != PJ_SUCCESS)
	    goto on_error;
    }

    /* Optionally disable some codec */
    for (i=0; i<app_config.codec_dis_cnt; ++i) {
	pjsua_codec_set_priority(&app_config.codec_dis[i],PJMEDIA_CODEC_PRIO_DISABLED);
    }

    /* Optionally set codec orders */
    for (i=0; i<app_config.codec_cnt; ++i) {
	pjsua_codec_set_priority(&app_config.codec_arg[i],
				 (pj_uint8_t)(PJMEDIA_CODEC_PRIO_NORMAL+i+9));
    }

    /* Add RTP transports */
#ifdef TRANSPORT_ADAPTER_SAMPLE
    status = transport_adapter_sample();

#else
    if (app_config.ipv6)
	status = create_ipv6_media_transports();
    else
	status = pjsua_media_transports_create(&app_config.rtp_cfg);
#endif
    if (status != PJ_SUCCESS)
	goto on_error;

    /* Use null sound device? */
#ifndef STEREO_DEMO
    if (app_config.null_audio) {
	status = pjsua_set_null_snd_dev();
	if (status != PJ_SUCCESS)
	    return status;
    }
#endif

    if (app_config.capture_dev  != PJSUA_INVALID_ID ||
        app_config.playback_dev != PJSUA_INVALID_ID) 
    {
	status = pjsua_set_snd_dev(app_config.capture_dev, 
				   app_config.playback_dev);
	if (status != PJ_SUCCESS)
	    goto on_error;
    }

    return PJ_SUCCESS;

on_error:
    app_destroy();
    return status;
}


static int stdout_refresh_proc(void *arg)
{
    PJ_UNUSED_ARG(arg);

    /* Set thread to lowest priority so that it doesn't clobber
     * stdout output
     */
    pj_thread_set_prio(pj_thread_this(), 
		       pj_thread_get_prio_min(pj_thread_this()));

    while (!stdout_refresh_quit) {
	pj_thread_sleep(stdout_refresh * 1000);
	puts(stdout_refresh_text);
	fflush(stdout);
    }

    return 0;
}

void app_start()
{
    pj_thread_t *stdout_refresh_thread = NULL;
    pj_status_t status;

    /* Start pjsua */
    status = pjsua_start();
    if (status != PJ_SUCCESS) {
	app_destroy();
	//return status;
    }

    /* //Start console refresh thread
    if (stdout_refresh > 0) {
	pj_thread_create(app_config.pool, "stdout", &stdout_refresh_proc,
			 NULL, 0, 0, &stdout_refresh_thread);
    }

    console_app_main(&uri_arg); */

    if (stdout_refresh_thread) {
	stdout_refresh_quit = PJ_TRUE;
	pj_thread_join(stdout_refresh_thread);
	pj_thread_destroy(stdout_refresh_thread);
    }

    //return PJ_SUCCESS;
}

pj_status_t app_destroy(void)
{
    pj_status_t status;
    unsigned i;

#ifdef STEREO_DEMO
    if (app_config.snd) {
	pjmedia_snd_port_destroy(app_config.snd);
	app_config.snd = NULL;
    }
    if (app_config.sc_ch1) {
	pjsua_conf_remove_port(app_config.sc_ch1_slot);
	app_config.sc_ch1_slot = PJSUA_INVALID_ID;
	pjmedia_port_destroy(app_config.sc_ch1);
	app_config.sc_ch1 = NULL;
    }
    if (app_config.sc) {
	pjmedia_port_destroy(app_config.sc);
	app_config.sc = NULL;
    }
#endif

    /* Close ringback port */
    if (app_config.ringback_port && 
	app_config.ringback_slot != PJSUA_INVALID_ID) 
    {
	pjsua_conf_remove_port(app_config.ringback_slot);
	app_config.ringback_slot = PJSUA_INVALID_ID;
	pjmedia_port_destroy(app_config.ringback_port);
	app_config.ringback_port = NULL;
    }

    /* Close ring port */
    if (app_config.ring_port && app_config.ring_slot != PJSUA_INVALID_ID) {
	pjsua_conf_remove_port(app_config.ring_slot);
	app_config.ring_slot = PJSUA_INVALID_ID;
	pjmedia_port_destroy(app_config.ring_port);
	app_config.ring_port = NULL;
    }

    /* Close tone generators */
    for (i=0; i<app_config.tone_count; ++i) {
	pjsua_conf_remove_port(app_config.tone_slots[i]);
    }

    if (app_config.pool) {
	pj_pool_release(app_config.pool);
	app_config.pool = NULL;
    }

    status = pjsua_destroy();

    pj_bzero(&app_config, sizeof(app_config));

    return status;
}


#ifdef STEREO_DEMO
/*
 * In this stereo demo, we open the sound device in stereo mode and
 * arrange the attachment to the PJSUA-LIB conference bridge as such
 * so that channel0/left channel of the sound device corresponds to
 * slot 0 in the bridge, and channel1/right channel of the sound
 * device corresponds to slot 1 in the bridge. Then user can independently
 * feed different media to/from the speakers/microphones channels, by
 * connecting them to slot 0 or 1 respectively.
 *
 * Here's how the connection looks like:
 *
   +-----------+ stereo +-----------------+ 2x mono +-----------+
   | AUDIO DEV |<------>| SPLITCOMB   left|<------->|#0  BRIDGE |
   +-----------+        |            right|<------->|#1         |
                        +-----------------+         +-----------+
 */
static void stereo_demo()
{
    pjmedia_port *conf;
    pj_status_t status;

    /* Disable existing sound device */
    conf = pjsua_set_no_snd_dev();

    /* Create stereo-mono splitter/combiner */
    status = pjmedia_splitcomb_create(app_config.pool, 
				      conf->info.clock_rate /* clock rate */,
				      2	    /* stereo */,
				      2 * conf->info.samples_per_frame,
				      conf->info.bits_per_sample,
				      0	    /* options */,
				      &app_config.sc);
    pj_assert(status == PJ_SUCCESS);

    /* Connect channel0 (left channel?) to conference port slot0 */
    status = pjmedia_splitcomb_set_channel(app_config.sc, 0 /* ch0 */, 
					   0 /*options*/,
					   conf);
    pj_assert(status == PJ_SUCCESS);

    /* Create reverse channel for channel1 (right channel?)... */
    status = pjmedia_splitcomb_create_rev_channel(app_config.pool,
						  app_config.sc,
						  1  /* ch1 */,
						  0  /* options */,
						  &app_config.sc_ch1);
    pj_assert(status == PJ_SUCCESS);

    /* .. and register it to conference bridge (it would be slot1
     * if there's no other devices connected to the bridge)
     */
    status = pjsua_conf_add_port(app_config.pool, app_config.sc_ch1, 
				 &app_config.sc_ch1_slot);
    pj_assert(status == PJ_SUCCESS);
    
    /* Create sound device */
    status = pjmedia_snd_port_create(app_config.pool, -1, -1, 
				     conf->info.clock_rate,
				     2	    /* stereo */,
				     2 * conf->info.samples_per_frame,
				     conf->info.bits_per_sample,
				     0, &app_config.snd);
    pj_assert(status == PJ_SUCCESS);


    /* Connect the splitter to the sound device */
    status = pjmedia_snd_port_connect(app_config.snd, app_config.sc);
    pj_assert(status == PJ_SUCCESS);

}
#endif
	
#ifdef TRANSPORT_ADAPTER_SAMPLE
static pj_status_t create_transport_adapter(pjmedia_endpt *med_endpt, int port,
					    pjmedia_transport **p_tp)
{
    pjmedia_transport *udp;
    pj_status_t status;

    /* Create the UDP media transport */
    status = pjmedia_transport_udp_create(med_endpt, NULL, port, 0, &udp);
    if (status != PJ_SUCCESS)
	return status;

    /* Create the adapter */
    status = pjmedia_tp_adapter_create(med_endpt, NULL, udp, p_tp);
    if (status != PJ_SUCCESS) {
	pjmedia_transport_close(udp);
	return status;
    }

    return PJ_SUCCESS;
}

static pj_status_t transport_adapter_sample(void)
{
    pjsua_media_transport tp[PJSUA_MAX_CALLS];
    pj_status_t status;
    int port = 7000;
    unsigned i;

    for (i=0; i<app_config.cfg.max_calls; ++i) {
	status = create_transport_adapter(pjsua_get_pjmedia_endpt(), 
					  port + i*10,
					  &tp[i].transport);
	if (status != PJ_SUCCESS)
	    return status;
    }

    return pjsua_media_transports_attach(tp, i, PJ_TRUE);
}
#endif

static pj_status_t create_ipv6_media_transports(void)
{
    pjsua_media_transport tp[PJSUA_MAX_CALLS];
    pj_status_t status;
    int port = app_config.rtp_cfg.port;
    unsigned i;

    for (i=0; i<app_config.cfg.max_calls; ++i) {
	enum { MAX_RETRY = 10 };
	pj_sock_t sock[2];
	pjmedia_sock_info si;
	unsigned j;

	/* Get rid of uninitialized var compiler warning with MSVC */
	status = PJ_SUCCESS;

	for (j=0; j<MAX_RETRY; ++j) {
	    unsigned k;

	    for (k=0; k<2; ++k) {
		pj_sockaddr bound_addr;

		status = pj_sock_socket(pj_AF_INET6(), pj_SOCK_DGRAM(), 0, &sock[k]);
		if (status != PJ_SUCCESS)
		    break;

		status = pj_sockaddr_init(pj_AF_INET6(), &bound_addr,
					  &app_config.rtp_cfg.bound_addr, 
					  (unsigned short)(port+k));
		if (status != PJ_SUCCESS)
		    break;

		status = pj_sock_bind(sock[k], &bound_addr, 
				      pj_sockaddr_get_len(&bound_addr));
		if (status != PJ_SUCCESS)
		    break;
	    }
	    if (status != PJ_SUCCESS) {
		if (k==1)
		    pj_sock_close(sock[0]);

		if (port != 0)
		    port += 10;
		else
		    break;

		continue;
	    }

	    pj_bzero(&si, sizeof(si));
	    si.rtp_sock = sock[0];
	    si.rtcp_sock = sock[1];
	
	    pj_sockaddr_init(pj_AF_INET6(), &si.rtp_addr_name, 
			     &app_config.rtp_cfg.public_addr, 
			     (unsigned short)(port));
	    pj_sockaddr_init(pj_AF_INET6(), &si.rtcp_addr_name, 
			     &app_config.rtp_cfg.public_addr, 
			     (unsigned short)(port+1));

	    status = pjmedia_transport_udp_attach(pjsua_get_pjmedia_endpt(),
						  NULL,
						  &si,
						  0,
						  &tp[i].transport);
	    if (port != 0)
		port += 10;
	    else
		break;

	    if (status == PJ_SUCCESS)
		break;
	}

	if (status != PJ_SUCCESS) {
	    pjsua_perror(THIS_FILE, "Error creating IPv6 UDP media transport", 
			 status);
	    for (j=0; j<i; ++j) {
		pjmedia_transport_close(tp[j].transport);
	    }
	    return status;
	}
    }

    return pjsua_media_transports_attach(tp, i, PJ_TRUE);
}
	
#pragma mark -
#pragma mark uniCall Main Functions

int pjsuamanager_account_register( const char* sip_domain, const char* sip_username, const char* sip_password) {
	
	char id[80], registrar[80], realm[80], uname[80], passwd[50];
	int account_id;
	pjsua_acc_config acc_cfg;
	pj_status_t status;
	
	sprintf(id, "sip:%s@%s", sip_username, sip_domain);	//SIP URL -> sip:SIP_USER@SIP_DOMAIN
	sprintf(registrar, "sip:%s", sip_domain);			//URL of the Register -> sip:SIP_DOMAIN
	sprintf(realm, "%s", sip_domain);					//Auth Realm -> SIP_DOMAIN
	sprintf(uname, "%s", sip_username);					//Auth Username -> SIP_USER
	sprintf(passwd, "%s", sip_password);				//Auth Password -> SIP_PASS

	pjsua_acc_config_default(&acc_cfg);
	acc_cfg.id = pj_str(id);
	acc_cfg.reg_uri = pj_str(registrar);
	acc_cfg.cred_count = 1;
	acc_cfg.cred_info[0].scheme = pj_str("Digest");
	//change the realm to support asterisk
	//acc_cfg.cred_info[0].realm = pj_str(realm);
	acc_cfg.cred_info[0].realm = pj_str("*");
	acc_cfg.cred_info[0].username = pj_str(uname);
	acc_cfg.cred_info[0].data_type = 0;
	acc_cfg.cred_info[0].data = pj_str(passwd);
	
	status = pjsua_acc_add(&acc_cfg, PJ_TRUE, &account_id);
	if (status != PJ_SUCCESS) {
		pjsua_perror(THIS_FILE, "Error adding new account", status);
	}
	return account_id;
}

/* Make call! : */
//printf("(You currently have %d calls)\n", pjsua_call_get_count());
int pjsuamanager_make_new_call(char *url, int acc_id) {
	
	pj_str_t dest_uri;
	pj_status_t status;
	int call_id = -1;
	
	//TODO: may be better to use pjsua_verify_sip_url(sip_url);
	if ((status=pjsua_verify_url(url)) != PJ_SUCCESS) {
		pjsua_perror(THIS_FILE, "Invalid URL", status);
		return call_id;
	}
	
	dest_uri = pj_str(url);
	
	//pjsua_msg_data msg_data;
	//pjsip_generic_string_hdr my_hdr;
	
	//pj_str_t hname = pj_str("Location-Header");
    //pj_str_t hvalue = pj_str("LONGITUDE:0.0 LATITUDE:0.0");
	
    //pjsua_msg_data_init(&msg_data);
    //pjsip_generic_string_hdr_init2(&my_hdr, &hname, &hvalue);
    //pj_list_push_back(&msg_data.hdr_list, &my_hdr);
	
	/**
	 * Make outgoing call to the specified URI using the specified account.
	 *
	 * @param acc_id	The account to be used.
	 * @param dst_uri	URI to be put in the To header (normally is the same
	 *			as the target URI).
	 * @param options	Options (must be zero at the moment).
	 * @param user_data	Arbitrary user data to be attached to the call, and
	 *			can be retrieved later.
	 * @param msg_data	Optional headers etc to be added to outgoing INVITE
	 *			request, or NULL if no custom header is desired.
	 * @param p_call_id	Pointer to receive call identification.
	 *
	 * @return		PJ_SUCCESS on success, or the appropriate error code.
	 */
	//pjsua_call_make_call( acc_id, &dest_uri, 0, NULL, &msg_data, &call_id);
	pjsua_call_make_call( acc_id, &dest_uri, 0, NULL, NULL, &call_id);
	
	return call_id;
}

int pjsuamanager_make_new_call_with_location(char *url, int acc_id, double latitude, double longitude) {
	
	pj_str_t dest_uri;
	pj_status_t status;
	int call_id = -1;
	char header[128];
	
	//TODO: may be better to use pjsua_verify_sip_url(sip_url);
	if ((status=pjsua_verify_url(url)) != PJ_SUCCESS) {
		pjsua_perror(THIS_FILE, "Invalid URL", status);
		return call_id;
	}
	
	dest_uri = pj_str(url);
	
	pjsua_msg_data msg_data;
	pjsip_generic_string_hdr my_hdr;
	
	pj_str_t hname = pj_str("Location-Header");
	sprintf(header, "LATITUDE: %f LONGITUDE: %f", latitude, longitude);
    pj_str_t hvalue = pj_str(header);
	
    pjsua_msg_data_init(&msg_data);
    pjsip_generic_string_hdr_init2(&my_hdr, &hname, &hvalue);
    pj_list_push_back(&msg_data.hdr_list, &my_hdr);
	
	pjsua_call_make_call( acc_id, &dest_uri, 0, NULL, &msg_data, &call_id);
	
	return call_id;
}


/***********************
 * Unregister
 ***********************/
int pjsuamanager_account_unregister(int acc_id) {

	pj_status_t status = pjsua_acc_set_registration(acc_id, PJ_FALSE);
	if (status != PJ_SUCCESS) {
		//handle error
		return -1;
	}
	return 1;
}
	
/*
 * Re-register
 ***********************/
int pjsuamanager_account_reregister(int acc_id) {
	
	pj_status_t status = pjsua_acc_set_registration(acc_id, PJ_TRUE);
	if (status != PJ_SUCCESS) {
		//handle error
		return -1;
	}
	return 1;
}

int pjsuamanager_call_answer(int call_id, int code) {
	
	//Obtain detail information about the specified call.
	//pjsua_call_get_info(current_call, &call_info);
	/*
	 * Must check again!
	 * Call may have been disconnected while the user is answering
	 */
	pj_status_t status;
	status = pjsua_call_answer(call_id, code, NULL, NULL);
	if(status != PJ_SUCCESS) {
		//handle error
		return -1;
	}
	return 1;
}

/*
 * Hold call.
 */
int pjsuamanager_call_hold(int call_id) {
	//if (current_call != -1)
	pj_status_t status;
	status = pjsua_call_set_hold(call_id, NULL);
	if (status != PJ_SUCCESS) {
		//handle error
		return -1;
	}
	return 1;
	//else PJ_LOG(3,(THIS_FILE, "No current call"));
}

/*
 * Mute call.
 */
int pjsuamanager_call_mute(int call_id) {
	
	pjsua_call_info call_info;
	pj_status_t status;
	pjsua_call_get_info(call_id, &call_info);
	status = pjsua_conf_disconnect(call_info.conf_slot, 0);
	if(status!=PJ_SUCCESS)
	{
		PJ_LOG(3,(THIS_FILE,"DisconnectSoundPort pjsua_conf_disconnect 1 fail %d",status));
	}
	//return (status==PJ_SUCCESS);
	
	status = pjsua_conf_adjust_rx_level(0 /* pjsua_conf_port_id slot*/, 0.0f);
	return (status==PJ_SUCCESS);
}

/*
 * Un-Mute call.
 */
int pjsuamanager_call_unmute(int call_id) {

	pjsua_call_info call_info;
	pj_status_t status;
	pjsua_call_get_info(call_id, &call_info);
	status = pjsua_conf_disconnect(0,call_info.conf_slot);
	if(status!=PJ_SUCCESS)
	{
		PJ_LOG(3,(THIS_FILE,"DisconnectSoundPort pjsua_conf_disconnect 2 fail %d",status));
	}
	//return (status==PJ_SUCCESS);
	
	status = pjsua_conf_adjust_rx_level(0 /* pjsua_conf_port_id slot*/, 1.0f);
	return (status==PJ_SUCCESS);
}


/*
 * Send re-INVITE (to release hold, etc).
 */
int pjsuamanager_call_reinvite(int call_id) {
	//if (current_call != -1)
	pj_status_t status;
	status = pjsua_call_reinvite(call_id, PJ_TRUE, NULL);;
	if (status != PJ_SUCCESS) {
		//handle error
		return -1;
	}
	return 1;
	//else PJ_LOG(3,(THIS_FILE, "No current call"));
}

/*
 * Hangup all calls
 * I should not need this
 */
void pjsuamanager_call_hangup_all() {
	//error return type later
	pjsua_call_hangup_all();
}

/*
 * Hangup current calls
 */
void pjsuamanager_call_hangup(int call_id) {
	//edit to return status or the type of error
	// @TODO: edit code; -> PJSIP_SC_OK = 200,
	pjsua_call_hangup(call_id, 0, NULL, NULL);
}

/*
 * Send DTMF strings.
 */
void pjsuamanager_send_dtmf(int call_id, char *dtmf) {

	if (!pjsua_call_has_media(current_call)) {
		PJ_LOG(3,(THIS_FILE, "Media is not established yet!"));
	} else {
		pj_str_t digits;
		pj_status_t status;
		
		digits = pj_str(dtmf);
		status = pjsua_call_dial_dtmf(call_id, &digits);
		if (status != PJ_SUCCESS) {
			pjsua_perror(THIS_FILE, "Unable to send DTMF", status);
		} else {
			puts("DTMF digits enqueued for transmission");
		}
	}
}

/* Send DTMF with INFO */
void pjsuamanager_send_dtmf_info() {
	//implement later
	/*
	const pj_str_t SIP_INFO = pj_str("INFO");
	pj_str_t digits;
	int i;
	pj_status_t status;

	digits = pj_str(buf);
	for (i=0; i<digits.slen; ++i) {
		char body[80];
		
		pjsua_msg_data_init(&msg_data);
		msg_data.content_type = pj_str("application/dtmf-relay");
		
		pj_ansi_snprintf(body, sizeof(body),
						 "Signal=%c\r\n"
						 "Duration=160",
						 buf[i]);
		msg_data.msg_body = pj_str(body);
		
		status = pjsua_call_send_request(current_call, &SIP_INFO, 
										 &msg_data);
		if (status != PJ_SUCCESS) {
			break;
		}
	}*/
}

/*
 * Send UPDATE
 */
void pjsuamanager_call_update(int call_id) {
/*	if (current_call != -1) {
		
		pjsua_call_update(current_call, 0, NULL);
		
	} else {
		PJ_LOG(3,(THIS_FILE, "No current call"));
	}*/
}

/*
 * Change codec priorities.
 */
void pjsuamanager_manage_codec_prio(void)
{
	/*pjsua_codec_info c[32];
	unsigned i, count = PJ_ARRAY_SIZE(c);
	char input[32];
	char *codec, *prio;
	pj_str_t id;
	int new_prio;
	pj_status_t status;
	
	printf("List of codecs:\n");
	
	pjsua_enum_codecs(c, &count);
	for (i=0; i<count; ++i) {
		printf("  %d\t%.*s\n", c[i].priority, (int)c[i].codec_id.slen,
			   c[i].codec_id.ptr);
	}
	
	puts("");
	puts("Enter codec id and its new priority "
		 "(e.g. \"speex/16000 200\"), empty to cancel:");
	
	printf("Codec name (\"*\" for all) and priority: ");
	if (fgets(input, sizeof(input), stdin) == NULL)
		return;
	if (input[0]=='\r' || input[0]=='\n') {
		puts("Done");
		return;
	}
	
	codec = strtok(input, " \t\r\n");
	prio = strtok(NULL, " \r\n");
	
	if (!codec || !prio) {
		puts("Invalid input");
		return;
	}
	
	new_prio = atoi(prio);
	if (new_prio < 0) 
		new_prio = 0;
	else if (new_prio > PJMEDIA_CODEC_PRIO_HIGHEST) 
		new_prio = PJMEDIA_CODEC_PRIO_HIGHEST;
	
	status = pjsua_codec_set_priority(pj_cstr(&id, codec), 
									  (pj_uint8_t)new_prio);
	if (status != PJ_SUCCESS)
		pjsua_perror(THIS_FILE, "Error setting codec priority", status);*/
}

/*
 * echo [0|1|txt]
 */
void pjsuamanager_set_echo()
{
	/*
	if (pj_ansi_strnicmp(menuin, "echo", 4)==0) {
		pj_str_t tmp;
		
		tmp.ptr = menuin+5;
		tmp.slen = pj_ansi_strlen(menuin)-6;
		
		if (tmp.slen < 1) {
			puts("Usage: echo [0|1]");
			break;
		}
		
		cmd_echo = *tmp.ptr != '0' || tmp.slen!=1;
	}
	 */
}


	
/* Send instant messaeg */

void pjsuamanager_send_im() {

	/* i is for call index to send message, if any *
	i = -1;
	
	/* Make compiler happy. *
	uri = NULL;
	
	/* Input destination. *
	ui_input_url("Send IM to", buf, sizeof(buf), &result);
	if (result.nb_result != NO_NB) {
		
		if (result.nb_result == -1) {
			puts("You can't send broadcast IM like that!");
			continue;
			
		} else if (result.nb_result == 0) {
			
			i = current_call;
			
		} else {
			pjsua_buddy_info binfo;
			pjsua_buddy_get_info(result.nb_result-1, &binfo);
			tmp.ptr = buf;
			pj_strncpy_with_null(&tmp, &binfo.uri, sizeof(buf));
			uri = buf;
		}
		
	} else if (result.uri_result) {
		uri = result.uri_result;
	}
	
	
	/* Send typing indication. *
	if (i != -1)
		pjsua_call_send_typing_ind(i, PJ_TRUE, NULL);
	else {
		pj_str_t tmp_uri = pj_str(uri);
		pjsua_im_typing(current_acc, &tmp_uri, PJ_TRUE, NULL);
	}
	
	/////////////////////* Input the IM . *
	if (!simple_input("Message", text, sizeof(text))) {
		/*
		 * Cancelled.
		 * Send typing notification too, saying we're not typing.
		 *
		if (i != -1)
			pjsua_call_send_typing_ind(i, PJ_FALSE, NULL);
		else {
			pj_str_t tmp_uri = pj_str(uri);
			pjsua_im_typing(current_acc, &tmp_uri, PJ_FALSE, NULL);
		}
		continue;
	}
	
	tmp = pj_str(text);
	
	/////////////////////* Send the IM
	if (i != -1)
		pjsua_call_send_im(i, NULL, &tmp, NULL, NULL);
	else {
		pj_str_t tmp_uri = pj_str(uri);
		pjsua_im_send(current_acc, &tmp_uri, NULL, &tmp, NULL, NULL);
	} */
}

////////////////////////////////////////////////////////////////////////////////////////////

int pjsip_set_stunserver(const char *stunserver)
{
	//app_config.cfg.stun_host = pj_str(stunserver);
	return 0;
}


void pjsip_set_codec(int preferred_codec)	
{/*
  pjsua_codec_info c[32];
  unsigned i, count = PJ_ARRAY_SIZE(c);
  pj_str_t id;
  pj_status_t status;
  
  switch (preferred_codec) {
  case CODEC_G711_ALAW:
  pj_cstr(&id, "PCMA/8000/1");
  break;
  case CODEC_G711_ULAW:
  pj_cstr(&id, "PCMU/8000/1");
  break;
  #ifdef IAX_SUPPORT_G729			
  case CODEC_G729:
  pj_cstr(&id, "G729/8000/1");
  break;
  #endif			
  default:
  pj_cstr(&id, "GSM/8000/1");
  break;
  }
  printf("List of codecs:\n");
  
  pjsua_enum_codecs(c, &count);
  for (i=0; i<count; ++i) {
  printf("  %d\t%.*s\n", c[i].priority, (int)c[i].codec_id.slen,
  c[i].codec_id.ptr);
  if(PJMEDIA_CODEC_PRIO_HIGHEST == c[i].priority) {
  if(pj_stricmp(&id, &(c[i].codec_id)) != 0) {
  status = pjsua_codec_set_priority(&id, 128);
  }
  } else {
  if(pj_stricmp(&id, &(c[i].codec_id)) == 0) {
  status = pjsua_codec_set_priority(&id, PJMEDIA_CODEC_PRIO_HIGHEST);
  }
  }
  }
  
  pjsua_enum_codecs(c, &count);
  for (i=0; i<count; ++i) {
  printf("  %d\t%.*s\n", c[i].priority, (int)c[i].codec_id.slen,
  c[i].codec_id.ptr);
  }*/
}


/*************************************************************************************/
/* port from 1-65535                                                                 */
/* int return  -1                                                                    */
/*              0                                                                    */
/*************************************************************************************/
int pjsip_set_rtp_port(int port)
{
	if(port < 0 || port > 65535) return -1;
	app_config.rtp_cfg.port = port;
	if (app_config.rtp_cfg.port == 0) {
		enum { START_PORT=4000 };
		unsigned range;
		
		range = (65535-START_PORT-PJSUA_MAX_CALLS*2);
		app_config.rtp_cfg.port = START_PORT + ((pj_rand() % range) & 0xFFFE);
	}
	return 0;
}

/***************************************************************************************/
/* Proxy URL                                                                           */
/***************************************************************************************/
void pjsip_set_proxy(int regid, const char *proxy)
{
	pjsua_acc_config *cur_acc;	
	if(regid>=0 && regid<app_config.acc_cnt) {
		cur_acc->proxy[cur_acc->proxy_cnt++] = pj_str(pj_optarg);
		//app_config.acc_cfg[regid].proxy[ app_config.acc_cfg[regid].proxy_cnt++ ] = pj_str(proxy);
	}
}