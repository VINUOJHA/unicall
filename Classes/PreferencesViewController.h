//
//  SettingViewController.h
//  uniCall
//
//  Created by Hussain Yaqoob on 6/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface PreferencesViewController : UIViewController {
	
	IBOutlet UIScrollView *theScroller;
	
	IBOutlet UILabel *lblUsername;
	IBOutlet UILabel *lblPassword;
	IBOutlet UILabel *lblDomain;
	
	IBOutlet UITextField *txtUsername;
	IBOutlet UITextField *txtPassword;
	IBOutlet UITextField *txtDomain;
	
	IBOutlet UIButton *btnLogin;
	IBOutlet UIButton *btnCreateAccount;
	IBOutlet UILabel *navigationBar;
	IBOutlet UILabel *feedback;
	
}

@property (nonatomic, retain) UIScrollView *theScroller;

@property (nonatomic, retain) UILabel *lblUsername;
@property (nonatomic, retain) UILabel *lblPassword;
@property (nonatomic, retain) UILabel *lblDomain;

@property (nonatomic, retain) UITextField *txtUsername;
@property (nonatomic, retain) UITextField *txtPassword;
@property (nonatomic, retain) UITextField *txtDomain;

@property (nonatomic, retain) UIButton *btnLogin;
@property (nonatomic, retain) UIButton *btnCreateAccount;
@property (nonatomic, retain) UILabel *navigationBar;
@property (nonatomic, retain) UILabel *feedback;

-(void)present;
-(void)dismiss;

-(IBAction)login:(id)sender;
-(IBAction)createNewAccount:(id)sender;
-(IBAction)hideKeyboard:(id)sender;

@end
