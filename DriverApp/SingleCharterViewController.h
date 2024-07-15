//
//  DriverApp
//
//  Created by KangJie Lim on 13/9/17.
//  Copyright © 2017 Commute-Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>
#import "Constants.h"
#import "UserPreferences.h"
#import "CustomIOSAlertView.h"
#import "MKDropdownMenu.h"
#import "CharterCreationViewController.h"
#import "AvailableCharterViewController.h"
#import "JobsViewController.h"

@interface SingleCharterViewController : UIViewController <GMSMapViewDelegate, UIScrollViewDelegate, UITextFieldDelegate, MKDropdownMenuDataSource, MKDropdownMenuDelegate>
@property (strong, nonatomic) IBOutlet GMSMapView *singleMapView;
@property (strong, nonatomic) IBOutlet UIScrollView *charterDetailsView;
@property (strong, nonatomic) MKDropdownMenu *navBarMenu;
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
