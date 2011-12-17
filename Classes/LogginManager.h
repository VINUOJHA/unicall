//
//  LogginManager.h
//  uniCall
//
//  Created by Hussain Yaqoob on 4/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#ifndef _LOGGINMANAGER_H_
#define _LOGGINMANAGER_H_

//#include <cstdio>
//#include <fstream>
//#include <list>

// Configuration Log Enumeration


//Log Type ? to Where
enum LogType {
	LOG_NONE   = 0,
	LOG_STDERR = 2,
	LOG_FILE   = 3
};

//Log Level? which 
enum LogLevel {
	LOG_FATAL    = 0,
	LOG_ERROR    = 1,
	LOG_WARNING  = 2,
	LOG_DEBUG    = 4,
	LOG_INFO     = 5,
};

#ifndef UNICALL_DEFAULT_LOG_LEVEL
#    define UNICALL_DEFAULT_LOG_LEVEL LOG_WARNING
#endif

#ifndef UNICALL_DEFAULT_LOG_TYPE
#    define UNICALL_DEFAULT_LOG_TYPE LOG_STDERR
#endif
				
#import <Foundation/Foundation.h>
#include <unistd.h>

//Logging manager for the project
//contains the logging priority
//Fata Error Warning Info
//NSLOG("fileName	LEVEL	MSG");

@interface LogginManager : NSObject {
	/* 
	 Give the choice to redirect the log to file
	 *********************************************
	// Set permissions for our NSLog file
	umask(022);
	
	// Save stderr so it can be restored.
	int stderrSave = dup(STDERR_FILENO);
	
	// Send stderr to our file
	FILE *newStderr = freopen("/tmp/redirect.log", "a", stderr);
	
	NSLog(@"This goes to the file");
	
	// Flush before restoring stderr
	fflush(stderr);
	
	// Now restore stderr, so new output goes to console.
	dup2(stderrSave, STDERR_FILENO);
	close(stderrSave);
	
	// This NSLog will go to the console.
	NSLog(@"This goes to the console");
	 */
	/*
	 http://www.opensg.org/browser/trunk/Source/Base/Base/OSGLog.h
	 */
	bool		_enabled;
/*	LogType		_logType;
	LogLevel	_logLevel;

*/}
/*
-(bool) getEnabled (void);
-(void) setEnabled (bool value = true);


-(void) Log(LogType logType = LOG_STDERR,
			LogLevel logLevel = LOG_INFO);
-(void) initLog ( void );
*/
@end
#endif