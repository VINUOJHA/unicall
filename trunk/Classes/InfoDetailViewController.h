//
//  InfoDetailViewController.h
//  uniCall
//
//  Created by Hussain Yaqoob on 6/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

//table constants
#define kTableRowsNum 1
#define kTableSectionsNum 1

@interface InfoDetailViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
	
	//Caller Info
	NSString *number;
	NSString *type;
	NSString *name;
	NSString *date;
	NSString *time;
	NSString *duration;
	
	IBOutlet UILabel *lblName;
	IBOutlet UILabel *lblType;
	IBOutlet UILabel *lblDate;
	IBOutlet UILabel *lblTime;
	IBOutlet UILabel *lblDuration;
	
	IBOutlet UITableView *tableView;
	
}

@property (nonatomic, retain) NSString *number;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *type;
@property (nonatomic, retain) NSString *date;
@property (nonatomic, retain) NSString *time;
@property (nonatomic, retain) NSString *duration;

@property (nonatomic, retain) UILabel *lblName;
@property (nonatomic, retain) UILabel *lblType;
@property (nonatomic, retain) UILabel *lblDate;
@property (nonatomic, retain) UILabel *lblTime;
@property (nonatomic, retain) UILabel *lblDuration;

@property (nonatomic, retain) UITableView *tableView;

@end
