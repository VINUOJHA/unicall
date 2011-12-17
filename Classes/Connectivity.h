//
//  Connectivity.h
//  uniCall
//
//  Created by Hussain Yaqoob on 6/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Reachability;

@interface Connectivity : NSObject {
	
	Reachability *domainReah;
	
	BOOL connected;
}

@property (nonatomic, assign) BOOL connected;

-(BOOL)isConnected;

- (void) updateConnectivity: (Reachability*) curReach;

//Called by Reachability whenever status changes.
- (void) reachabilityChanged: (NSNotification* )note;

@end
