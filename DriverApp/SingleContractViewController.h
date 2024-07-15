//
//  DriverApp
//
//  Created by KangJie Lim on 8/3/18.
//  Copyright © 2018 Commute-Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"
#import "UserPreferences.h"

@interface SingleContractViewController: UIViewController <UIScrollViewDelegate>
@property (nonatomic, retain) NSString *charterId;
@property (nonatomic, retain) NSDictionary *contract;
@property (nonatomic, retain) NSNumber *previousControllerView;
@property (nonatomic, retain) NSString *identifyingProperty;

@property (weak, nonatomic) IBOutlet UILabel *lblContractPeriod;
@property (weak, nonatomic) IBOutlet UILabel *lblTime;
@property (weak, nonatomic) IBOutlet UILabel *lblBusSize;
@property (weak, nonatomic) IBOutlet UILabel *lblCost;

@property (weak, nonatomic) IBOutlet UIButton *btnPickup1;
@property (weak, nonatomic) IBOutlet UIButton *btnPickup2;
@property (weak, nonatomic) IBOutlet UIButton *btnPickup3;

@property (weak, nonatomic) IBOutlet UIButton *btnDropoff1;
@property (weak, nonatomic) IBOutlet UIButton *btnDropoff2;
@property (weak, nonatomic) IBOutlet UIButton *btnDropoff3;

@property (weak, nonatomic) IBOutlet UILabel *lblInfo;
@property (weak, nonatomic) IBOutlet UIButton *btnCall;

- (IBAction)btnPickup1:(id)sender;
- (IBAction)btnPickup2:(id)sender;
- (IBAction)btnPickup3:(id)sender;

- (IBAction)btnDropoff1:(id)sender;
- (IBAction)btnDropoff2:(id)sender;
- (IBAction)btnDropoff3:(id)sender;

- (IBAction)btnCall:(id)sender;

#define UIColorFromRGB(rgbValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0x00FF00) >>  8))/255.0 \
blue:((float)((rgbValue & 0x0000FF) >>  0))/255.0 \
alpha:1.0]
@end
