//
//  DriverApp
//
//  Created by KangJie Lim on 11/11/16.
//  Copyright © 2016 Commute-Solutions. All rights reserved.
//

#ifndef SettingsViewController_h
#import <UIKit/UIKit.h>
#import "Constants.h"
#import "MapViewController.h"
#import "UserPreferences.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "ACSBluetooth.h"
#import <XLForm/XLForm.h>
#import "XLFormViewController.h"
#define SettingsViewController_h

@interface SettingsViewController : XLFormViewController <CBCentralManagerDelegate>
@property (nonatomic) CBCentralManager *bluetoothManager;
/** Array of peripherals. */
@property (nonatomic) NSMutableArray *peripherals;

@property (nonatomic, retain) NSString *charterId;
@property (nonatomic, retain) NSDictionary *contract;
@property (nonatomic, retain) NSNumber *previousControllerView;
@property (nonatomic, retain) NSString *identifyingProperty;
@end


#endif /* SettingsViewController_h */
