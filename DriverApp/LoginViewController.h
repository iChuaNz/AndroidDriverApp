//
//  DriverApp
//
//  Created by KangJie Lim on 10/11/16.
//  Copyright © 2016 Commute-Solutions. All rights reserved.
//

#import <sys/utsname.h>
#import <UIKit/UIKit.h>
#import "Constants.h"
#import "UserPreferences.h"
#import "AvailableCharterViewController.h"
#import "JobsViewController.h"
#import "DisputeController.h"
#import "ProfileController.h"
#import "SingleCharterViewController.h"

@interface LoginViewController : UIViewController <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UILabel *lblGreeting;
@property (weak, nonatomic) IBOutlet UITextField *txtUserName;
@property (weak, nonatomic) IBOutlet UITextField *txtPassword;
@property (weak, nonatomic) IBOutlet UIButton *btnLogin;

@property (nonatomic, retain) NSString *charterId;
@property (nonatomic, retain) NSDictionary *contract;
@property (nonatomic, retain) NSNumber *previousControllerView;
@property (nonatomic, retain) NSString *identifyingProperty;

- (IBAction)btnLogin:(id)sender;
- (IBAction)toBackground:(id)sender;

@end

