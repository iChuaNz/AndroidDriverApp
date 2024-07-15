//
//  DriverApp
//
//  Created by KangJie Lim on 13/2/18.
//  Copyright © 2018 Commute-Solutions. All rights reserved.
//

#ifndef ContractPickupViewController_h
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreLocation/CoreLocation.h>
#import "UserPreferences.h"
#import "LGPlusButtonsView.h"
#import "NetworkUtility.h"
#define ContractPickupViewController_h

@interface ContractPickupViewController : UIViewController <CLLocationManagerDelegate, UITextFieldDelegate>
@property (strong, nonatomic) LGPlusButtonsView *navBar;
@property (nonatomic, retain) NSString *charterId;
@property (nonatomic, retain) NSDictionary *contract;
@property (nonatomic, retain) NSNumber *previousControllerView;
@property (nonatomic, retain) NSString *identifyingProperty;

#define UIColorFromRGB(rgbValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0x00FF00) >>  8))/255.0 \
blue:((float)((rgbValue & 0x0000FF) >>  0))/255.0 \
alpha:1.0]
@end

#endif /* ContractPickupViewController_h */
