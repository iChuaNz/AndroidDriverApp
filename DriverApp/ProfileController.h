//
//  DriverApp
//
//  Created by KangJie Lim on 27/9/17.
//  Copyright © 2017 Commute-Solutions. All rights reserved.
//

#ifndef ProfileController_h
#import <UIKit/UIKit.h>
#import "Constants.h"
#import <XLForm/XLForm.h>
#import "JobsViewController.h"
#import "LGPlusButtonsView.h"
#import "UserPreferences.h"
#import "XLFormViewController.h"
#import <Stripe.h>
#define ProfileController_h

@interface ProfileController : UIViewController <UITextFieldDelegate, STPPaymentCardTextFieldDelegate>
@property (strong, nonatomic) LGPlusButtonsView *navBar;
@property (nonatomic, retain) NSString *charterId;
@property (nonatomic, retain) NSDictionary *contract;
@property (nonatomic, retain) NSNumber *previousControllerView;
@property (nonatomic, retain) NSString *identifyingProperty;

@property (weak, nonatomic) IBOutlet UIView *bgWallet;
@property (weak, nonatomic) IBOutlet UIView *bgWithheld;
@property (weak, nonatomic) IBOutlet UIView *bgHistory;
@property (weak, nonatomic) IBOutlet UIView *bgCreditCard;

@property (weak, nonatomic) IBOutlet UILabel *lblUsername;
@property (weak, nonatomic) IBOutlet UILabel *lblWalletAmount;
@property (weak, nonatomic) IBOutlet UILabel *lblWithheldAmount;
@property (weak, nonatomic) IBOutlet UILabel *lblCreditCardNo;
@property (weak, nonatomic) IBOutlet UILabel *lblCreditCardExpiry;
@property (weak, nonatomic) IBOutlet UILabel *lblVersionNo;

- (IBAction)btnLogout2:(id)sender;

#define UIColorFromRGB(rgbValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0x00FF00) >>  8))/255.0 \
blue:((float)((rgbValue & 0x0000FF) >>  0))/255.0 \
alpha:1.0]
@end

#endif /* ProfileController_h */
