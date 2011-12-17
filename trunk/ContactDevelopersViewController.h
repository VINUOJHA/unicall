//
//  ContactDevelopersViewController.h
//  uniCall
//
//  Created by Hussain Yaqoob on 6/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface ContactDevelopersViewController : UIViewController <MFMailComposeViewControllerDelegate, 
MFMessageComposeViewControllerDelegate, UINavigationControllerDelegate> {
	
	IBOutlet UILabel *iphoneDev;
	IBOutlet UILabel *androidDev;
	IBOutlet UILabel *error;
	
	IBOutlet UIButton *composeEmail;
	IBOutlet UIButton *composeSMS;
	
}

@property (nonatomic, retain) UILabel *iphoneDev;
@property (nonatomic, retain) UILabel *androidDev;
@property (nonatomic, retain) UILabel *error;

@property (nonatomic, retain) UIButton *composeEmail;
@property (nonatomic, retain) UIButton *composeSMS;

-(IBAction) sendSMS:(id) sender;
-(IBAction) sendEmail:(id) sender;

-(void)displayMailComposerSheet;
-(void)displaySMSComposerSheet;

@end
