//
//  Connectivity.m
//  uniCall
//
//  Created by Hussain Yaqoob on 6/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Connectivity.h"
#import "Reachability.h"

@implementation Connectivity

@synthesize connected;

- (id)init {
	
	// Observe the kNetworkReachabilityChangedNotification. When that notification is posted, the
    // method "reachabilityChanged" will be called. 
    [[NSNotificationCenter defaultCenter] addObserver: self 
											 selector: @selector(reachabilityChanged:) 
												 name: kReachabilityChangedNotification 
											   object: nil];
	
    //Change the domainReah name here to change the server your monitoring
	//domainReah = [[Reachability reachabilityWithHostName: @"www.apple.com"] retain];
	domainReah = [[Reachability reachabilityWithHostName: [[NSUserDefaults standardUserDefaults] stringForKey:kSipDomain]] retain];
	[domainReah startNotifier];
	[self updateConnectivity: domainReah];
	
	return self;
}

-(BOOL)isConnected {
	return connected;
}

- (void) updateConnectivity: (Reachability*) curReach
{
    if(curReach == domainReah)
	{
	    NetworkStatus netStatus = [curReach currentReachabilityStatus];
		
		switch (netStatus)
		{
			case NotReachable:
			{
				self.connected = FALSE;
				break;
			}
				
			case ReachableViaWWAN:
			{
				self.connected = TRUE;
				break;
			}
			case ReachableViaWiFi:
			{
				self.connected = TRUE;
				break;
			}
		}
	}
}

//Called by Reachability whenever status changes.
- (void) reachabilityChanged: (NSNotification* )note
{
	Reachability* curReach = [note object];
	NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
	[self updateConnectivity: curReach];
}


@end
