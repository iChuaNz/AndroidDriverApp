//
//  DriverApp
//
//  Created by KangJie Lim on 10/11/16.
//  Copyright © 2016 Commute-Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <CoreLocation/CoreLocation.h>
#import "UIImage+animatedGIF.h"
#import "Constants.h"
#import "UserPreferences.h"
#import <Stripe.h>
#import "LoginViewController.h"
@import Firebase;
@import FirebaseMessaging;

@interface AppDelegate : UIResponder <UIApplicationDelegate, CLLocationManagerDelegate, FIRMessagingDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (readonly, strong) NSPersistentContainer *persistentContainer;

#define UIColorFromRGB(rgbValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0x00FF00) >>  8))/255.0 \
blue:((float)((rgbValue & 0x0000FF) >>  0))/255.0 \
alpha:1.0]

- (void)saveContext;

@end
