//
//  HistoryViewController.h
//  uniCall
//
//  Created by Hussain Yaqoob on 6/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import </usr/include/sqlite3.h>
#include <stdio.h>


@interface HistoryViewController : UITableViewController <UIActionSheetDelegate> {
	
	int historyTableRowCount;
	
}

@property( nonatomic, assign) int historyTableRowCount;

-(NSInteger)retrieveHistoryCount;
-(void)retrieveHistory;

-(void)reloadTableData;

-(void)btnClear:(id) sender;

-(NSString *)calculateDuration:(int)durationInSec;

@end
