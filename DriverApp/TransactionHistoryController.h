//
//  DriverApp
//
//  Created by KangJie Lim on 29/9/17.
//  Copyright © 2017 Commute-Solutions. All rights reserved.
//

#ifndef TransactionHistoryController_h
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "Constants.h"
#import "UserPreferences.h"
#import "DisputeTableRow.h"
#define TransactionHistoryController_h

@interface TransactionHistoryController : UITableViewController
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

#endif /* TransactionHistoryController_h */
