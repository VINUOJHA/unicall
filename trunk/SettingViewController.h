//
//  SettingViewController.h
//  uniCall
//
//  Created by Hussain Yaqoob on 3/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingViewController : UIViewController {
	IBOutlet UITextField *txtUsername;
	IBOutlet UITextField *txtPassword;
	IBOutlet UILabel *status;

}

@property (nonatomic, retain) UITextField *txtUsername;
@property (nonatomic, retain) UITextField *txtPassword;
@property (nonatomic, retain) UILabel *status;

-(IBAction)login:(id)sender;
-(IBAction)hideKeyboard:(id)sender;

@end
