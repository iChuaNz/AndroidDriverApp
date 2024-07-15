//
//  DriverApp
//
//  Created by KangJie Lim on 11/11/16.
//  Copyright © 2016 Commute-Solutions. All rights reserved.
//

#import "MapViewController.h"
#import <GoogleMaps/GoogleMaps.h>
#import "iToast.h"


@interface MapViewController () <UIPopoverPresentationControllerDelegate>
@property (strong, nonatomic) GMSMapView *mapView;

@end

@implementation MapViewController
NetworkUtility *reachability;
NetworkStatus status;
NSUserDefaults *userPrefs;
CLLocationManager *locationManager;
NSTimer *cameraTimer;
NSTimer *locationTimer;
NSTimer *proximityTimer;
NSTimer *dataTimer;
NSString *token;
NSString *role;
NSString *lang;

int *distanceFromCurrentLocation;
double mLongitude;
double mLatitude;
double mAltitude;
double mAccuracy;
double mSpeed;
NSString *mPollingDate;
NSString *mDate;
BOOL toShowMsg;
BOOL toTrack;
NSString *adhocCharterId;

UIView *busView;
UIImageView *currentLocationBus;
UIImage *busIcon;
GMSMarker *busMarker;
BOOL followLocation;
UILabel *lblAdhocMarquee;

NSMutableArray *referencedLocationData;
NSMutableArray *noOfPassengersPerStop;
CLLocation *currentLocationData;
CustomIOSAlertView *passengerAlert;
NSString *passengerName;
NSString *passengerGender;
BOOL isDropOff;

NSArray *jobDataResponse;
NSArray *pathDataResponse;
NSArray *passengersDataResponse;
NSDictionary *adhocDataResponse;

BOOL isSchoolBusTrip;
BOOL isInternalNFCEnabled;
BOOL isExternalNFCEnabled;
BOOL isAdhoc;

NSMutableArray *storedLongitude;
NSMutableArray *storedLatitude;
NSMutableArray *storedAltitude;
NSMutableArray *storedAccuracy;
NSMutableArray *storedSpeed;
NSMutableArray *storedDateTime;

int NFCSetting;
CBPeripheral *device;
NSString *deviceName;
NSUUID *deviceUUID;
BOOL hasSentApdu1;

NSMutableArray *passengerCanIdToday;
NSMutableArray *passengerCanIdTodayNoClearing;
NSMutableArray *passengerBoardingTimeToday;
NSMutableArray *passengerPickUpDropOffToday;

- (void)loadView {
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[[UIView alloc] init]];
    UIBarButtonItem *btnSideMenu = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(showHideButtonsAction)];
    [btnSideMenu setTintColor:[UIColor whiteColor]];
    self.navigationItem.rightBarButtonItem = btnSideMenu;
    
    self.navigationItem.title = @"Tracker";
    
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    reachability = [NetworkUtility reachabilityForInternetConnection];
    [locationManager requestWhenInUseAuthorization];
    [locationManager requestAlwaysAuthorization];
    [locationManager setPausesLocationUpdatesAutomatically:NO];
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:1.285
                                                            longitude:103.848
                                                                 zoom:16];
    _mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    _mapView.indoorEnabled = NO;
    _mapView.myLocationEnabled = NO;
    if (nil == locationManager) {
        locationManager = [[CLLocationManager alloc]init];
    }
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.headingFilter = 5;
    [locationManager startUpdatingLocation];
    [locationManager startUpdatingHeading];
    
    self.view = _mapView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    userPrefs = [NSUserDefaults standardUserDefaults];
    token = [userPrefs stringForKey:AUTHENTICATION_TOKEN];
    role = [userPrefs stringForKey:ROLE];
    lang = [userPrefs objectForKey:LANGUAGE];
    if ([lang isEqualToString:@"EN"]) {
        UIBarButtonItem *btnSettings = [[UIBarButtonItem alloc] initWithTitle:@"Settings" style:UIBarButtonItemStylePlain target:self action:@selector(toSettings)];
        [btnSettings setTintColor:[UIColor whiteColor]];
        self.navigationItem.leftBarButtonItem = btnSettings;
    } else if ([lang isEqualToString:@"CH"]) {
        UIBarButtonItem *btnSettings = [[UIBarButtonItem alloc] initWithTitle:@"设置" style:UIBarButtonItemStylePlain target:self action:@selector(toSettings)];
        [btnSettings setTintColor:[UIColor whiteColor]];
        self.navigationItem.leftBarButtonItem = btnSettings;
        
        self.navigationItem.title = @"追踪器";
    }
    
    [userPrefs setObject:@"map" forKey:LAST_SAVED_STATE];
    storedLongitude = [[NSMutableArray alloc] init];
    storedLatitude = [[NSMutableArray alloc] init];
    storedAccuracy = [[NSMutableArray alloc] init];
    storedAltitude = [[NSMutableArray alloc] init];
    storedSpeed = [[NSMutableArray alloc] init];
    storedDateTime = [[NSMutableArray alloc] init];
    
    [reachability startNotifier];
    status = [reachability currentReachabilityStatus];
    
    busView = [[UIView alloc] initWithFrame:CGRectMake(-15, -22.5, 30, 45)];
    currentLocationBus = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bus.png"]];
    [busView addSubview:currentLocationBus];
    busIcon = [self imageFromView:busView];
    busMarker = [[GMSMarker alloc] init];
    busMarker.icon = busIcon;

    toTrack = [userPrefs boolForKey:IS_TRACKING];
    followLocation = [userPrefs boolForKey:FOLLOW_CURRENT_LOCATION];
    toShowMsg = [userPrefs boolForKey:SHOW_MESSAGE];
    passengerCanIdToday = [[NSMutableArray alloc] init];
    
    NSData *archivedData = [userPrefs objectForKey:PASSENGER_LIST_TODAY];
    if (archivedData == nil) {
        passengerCanIdTodayNoClearing = [[NSMutableArray alloc] init];
    } else {
        passengerCanIdTodayNoClearing = [NSKeyedUnarchiver unarchiveObjectWithData:archivedData];
    }
    passengerBoardingTimeToday = [[NSMutableArray alloc] init];
    passengerPickUpDropOffToday = [[NSMutableArray alloc] init];
    [_mapView animateToLocation:CLLocationCoordinate2DMake(mLatitude, mLongitude)];
    if (toTrack) {
        [self startPollingLocation];
        [self startSendingDataPeriodically];
    }
    
    if (followLocation) {
        [self startCameraFollowing];
    } else {
        [self stopCameraFollowing];
    }
    [self getJobs];
    
    int jobStatus = [[adhocDataResponse objectForKey:@"jobStatus"] intValue];
    if (jobStatus == 99 || adhocDataResponse == nil) {
        isAdhoc = NO;
    } else {
        adhocCharterId = [adhocDataResponse objectForKey:@"busCharterId"];
        isAdhoc = YES;
        CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
        CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
        lblAdhocMarquee = [[UILabel alloc] initWithFrame:CGRectMake(0 , screenHeight - 83, screenWidth * 2, 33)];
        lblAdhocMarquee.backgroundColor = [UIColor blackColor];
        lblAdhocMarquee.textColor = UIColorFromRGB(0xF68B1F);
        lblAdhocMarquee.font = [UIFont systemFontOfSize:20];
    }
    
    [userPrefs setBool:isInternalNFCEnabled forKey:ENABLE_INTERNAL_NFC];
    [userPrefs setBool:isExternalNFCEnabled forKey:ENABLE_EXTERNAL_NFC];
    const BOOL didSave = [userPrefs synchronize];
    if (!didSave) {
        [self alertStatus:@"Memory is full" :@"Unable to save settings!"];
    }
    isDropOff = false;
    
    archivedData = [NSKeyedArchiver archivedDataWithRootObject:passengersDataResponse];
    [userPrefs setObject:archivedData forKey:PASSENGER_GENERAL_DATA];
    const BOOL didSave2 = [userPrefs synchronize];
    if (!didSave2) {
        [self alertStatus:@"Memory is full" :@"Unable to save settings!"];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [self drawRoutes];

    [userPrefs setInteger:[passengersDataResponse count] forKey:NO_OF_PASSENGERS];
    const BOOL didSave = [userPrefs synchronize];
    if (!didSave) {
        [self alertStatus:@"Memory is full" :@"Unable to save settings!"];
    }

    NFCSetting = (int)[userPrefs integerForKey:NFC_SETTINGS];
    if (NFCSetting == 1) {
        @try {
            _bluetoothManager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue()];
            _bluetoothReaderManager = [[ABTBluetoothReaderManager alloc] init];
            _bluetoothReaderManager.delegate = self;
            [self pairWithDevice];
        } @catch (NSException *exception) {
            if ([lang isEqualToString:@"EN"]) {
                UIAlertController * alertView = [UIAlertController
                                                 alertControllerWithTitle:@"Error!"
                                                 message:@"Unable to detect stored device! Please pair with a new NFC device or select 'No NFC' to proceed with tracking"
                                                 preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *okButton = [UIAlertAction
                                           actionWithTitle:@"Got it"
                                           style:UIAlertActionStyleDefault
                                           handler:^(UIAlertAction * action) {
                                               [self performSegueWithIdentifier:@"goToSettings" sender:self];
                                           }];
                [alertView addAction:okButton];
                [self presentViewController:alertView animated:YES completion:nil];
            } else if ([lang isEqualToString:@"CH"]) {
                UIAlertController * alertView = [UIAlertController
                                                 alertControllerWithTitle:@"Error!"
                                                 message:@"找不到蓝牙设备。请配对新的蓝牙设备，或选择'No NFC'。"
                                                 preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *okButton = [UIAlertAction
                                           actionWithTitle:@"OK"
                                           style:UIAlertActionStyleDefault
                                           handler:^(UIAlertAction * action) {
                                               [self performSegueWithIdentifier:@"goToSettings" sender:self];
                                           }];
                [alertView addAction:okButton];
                [self presentViewController:alertView animated:YES completion:nil];
            }
        }
    }
    if (toTrack) {
        [self startCheckingProximity];
    }

    if (isSchoolBusTrip) {
        if ([role isEqualToString:@"omo"]) {
            _navBar = [LGPlusButtonsView plusButtonsViewWithNumberOfButtons:7
                                                    firstButtonIsPlusButton:NO
                                                              showAfterInit:NO
                                                              actionHandler:^(LGPlusButtonsView *plusButtonView, NSString *title, NSString *description, NSUInteger index)
                       {
                           NSLog(@"actionHandler | title: %@, description: %@, index: %lu", title, description, (long unsigned)index);
                           if (index == 1) {
                               if (isDropOff) {
                                   if ([lang isEqualToString:@"EN"]) {
                                       [_navBar setDescriptionsTexts:@[@" ", @"Pick Up", @"To Charter Menu", @"Fetch Jobs", @"Send Data", @"View Passenger Details", @"Lite Mode"]];
                                   } else if ([lang isEqualToString:@"CH"]) {
                                       [_navBar setDescriptionsTexts:@[@" ", @"上车", @"去包车菜单", @"重新加载", @"发送数据", @"查看详情", @"精简版"]];
                                   }
                                   isDropOff = false;
                               } else {
                                   if ([lang isEqualToString:@"EN"]) {
                                       [_navBar setDescriptionsTexts:@[@" ", @"Drop Off", @"To Charter Menu", @"Fetch Jobs", @"Send Data", @"View Passenger Details", @"Lite Mode"]];
                                   } else if ([lang isEqualToString:@"CH"]) {
                                       [_navBar setDescriptionsTexts:@[@" ", @"下车", @"去包车菜单", @"重新加载", @"发送数据", @"查看详情", @"精简版"]];
                                   }
                                   isDropOff = true;
                               }
                           } else if (index == 2) {
                               [self toCharterMenu];
                           } else if (index == 3) {
                               [_mapView clear];
                               [self getJobs];
                               [self drawRoutes];
                               if ([lang isEqualToString:@"EN"]) {
                                   [[[iToast makeText:NSLocalizedString(@"Jobs refreshed", @"")] setGravity:iToastGravityBottom] show];
                               } else if ([lang isEqualToString:@"CH"]) {
                                   [[[iToast makeText:NSLocalizedString(@"地图刷新", @"")] setGravity:iToastGravityBottom] show];
                               }
                           } else if (index == 4) {
                               [self sendPassengerData];
                           } else if (index == 5) {
                               [self viewPassengerDetails];
                           } else if (index == 6) {
                               [self goLiteMode];
                           }
                       }];
            
            _navBar.showHideOnScroll = NO;
            _navBar.appearingAnimationType = LGPlusButtonsAppearingAnimationTypeCrossDissolveAndPop;
            _navBar.position = LGPlusButtonsViewPositionRightTop;
            
//            [_navBar setButtonsTitles:@[@" ", @"1", @"2"] forState:UIControlStateNormal];
            NSArray *btnImageArray = @[[NSNull new], [UIImage imageNamed:@"info"], [UIImage imageNamed:@"chartermenuorhome"], [UIImage imageNamed:@"refresh"], [UIImage imageNamed:@"send"]
                                       , [UIImage imageNamed:@"info"], [UIImage imageNamed:@"lite"]];
            [_navBar setButtonsImages:btnImageArray forState:UIControlStateNormal forOrientation:LGPlusButtonsViewOrientationAll];
            if ([lang isEqualToString:@"EN"]) {
                [_navBar setDescriptionsTexts:@[@" ", @"Select Mode", @"To Charter Menu", @"Fetch Jobs", @"Send Data", @"View Passenger Details", @"Lite Mode"]];
            } else if ([lang isEqualToString:@"CH"]) {
                [_navBar setDescriptionsTexts:@[@" ", @"选择模式", @"去包车菜单", @"重新加载", @"发送数据", @"查看详情", @"精简版"]];
            }
        } else {
            _navBar = [LGPlusButtonsView plusButtonsViewWithNumberOfButtons:6
                                                    firstButtonIsPlusButton:NO
                                                              showAfterInit:NO
                                                              actionHandler:^(LGPlusButtonsView *plusButtonView, NSString *title, NSString *description, NSUInteger index)
                       {
                           NSLog(@"actionHandler | title: %@, description: %@, index: %lu", title, description, (long unsigned)index);
                           if (index == 1) {
                               if (isDropOff) {
                                   if ([lang isEqualToString:@"EN"]) {
                                       [_navBar setDescriptionsTexts:@[@" ", @"Pick Up", @"Fetch Jobs", @"Send Data", @"View Passenger Details", @"Lite Mode"]];
                                   } else if ([lang isEqualToString:@"CH"]) {
                                       [_navBar setDescriptionsTexts:@[@" ", @"上车", @"重新加载", @"发送数据", @"查看详情", @"精简版"]];
                                   }
                                   isDropOff = false;
                               } else {
                                   if ([lang isEqualToString:@"EN"]) {
                                       [_navBar setDescriptionsTexts:@[@" ", @"Drop Off", @"Fetch Jobs", @"Send Data", @"View Passenger Details", @"Lite Mode"]];
                                   } else if ([lang isEqualToString:@"CH"]) {
                                       [_navBar setDescriptionsTexts:@[@" ", @"下车", @"重新加载", @"发送数据", @"查看详情", @"精简版"]];
                                   }
                                   isDropOff = true;
                               }
                           } else if (index == 2) {
                               [_mapView clear];
                               [self getJobs];
                               [self drawRoutes];
                               if ([lang isEqualToString:@"EN"]) {
                                   [[[iToast makeText:NSLocalizedString(@"Jobs refreshed", @"")] setGravity:iToastGravityBottom] show];
                               } else if ([lang isEqualToString:@"CH"]) {
                                   [[[iToast makeText:NSLocalizedString(@"地图刷新", @"")] setGravity:iToastGravityBottom] show];
                               }
                           } else if (index == 3) {
                               [self sendPassengerData];
                           } else if (index == 4) {
                               [self viewPassengerDetails];
                           } else if (index == 5) {
                               [self goLiteMode];
                           }
                       }];
            
            _navBar.showHideOnScroll = NO;
            _navBar.appearingAnimationType = LGPlusButtonsAppearingAnimationTypeCrossDissolveAndPop;
            _navBar.position = LGPlusButtonsViewPositionRightTop;
            
            NSArray *btnImageArray = @[[NSNull new], [UIImage imageNamed:@"info"], [UIImage imageNamed:@"refresh"], [UIImage imageNamed:@"send"], [UIImage imageNamed:@"info"]
                                       , [UIImage imageNamed:@"lite"]];
            [_navBar setButtonsImages:btnImageArray forState:UIControlStateNormal forOrientation:LGPlusButtonsViewOrientationAll];
            if ([lang isEqualToString:@"EN"]) {
                [_navBar setDescriptionsTexts:@[@" ", @"Select Mode", @"Fetch Jobs", @"Send Data", @"View Passenger Details", @"Lite Mode"]];
            } else if ([lang isEqualToString:@"CH"]) {
                [_navBar setDescriptionsTexts:@[@" ", @"选择模式", @"重新加载", @"发送数据", @"查看详情", @"精简版"]];
            }
        }
    } else {
        if ([role isEqualToString:@"omo"] && !isAdhoc) {
            _navBar = [LGPlusButtonsView plusButtonsViewWithNumberOfButtons:5
                                                    firstButtonIsPlusButton:NO
                                                              showAfterInit:NO
                                                              actionHandler:^(LGPlusButtonsView *plusButtonView, NSString *title, NSString *description, NSUInteger index)
                       {
                           NSLog(@"actionHandler | title: %@, description: %@, index: %lu", title, description, (long unsigned)index);
                           if (index == 1) {
                               [self toCharterMenu];
                           } else if (index == 2) {
                               [_mapView clear];
                               [self getJobs];
                               [self drawRoutes];
                               if ([lang isEqualToString:@"EN"]) {
                                   [[[iToast makeText:NSLocalizedString(@"Jobs refreshed", @"")] setGravity:iToastGravityBottom] show];
                               } else if ([lang isEqualToString:@"CH"]) {
                                   [[[iToast makeText:NSLocalizedString(@"地图刷新", @"")] setGravity:iToastGravityBottom] show];
                               }
                           } else if (index == 3) {
                               [self sendPassengerData];
                           } else if (index == 4) {
                               [self goLiteMode];
                           }
                       }];
            
            _navBar.showHideOnScroll = NO;
            _navBar.appearingAnimationType = LGPlusButtonsAppearingAnimationTypeCrossDissolveAndPop;
            _navBar.position = LGPlusButtonsViewPositionRightTop;
            
            NSArray *btnImageArray = @[[NSNull new], [UIImage imageNamed:@"chartermenuorhome"], [UIImage imageNamed:@"refresh"], [UIImage imageNamed:@"send"], [UIImage imageNamed:@"lite"]];
            [_navBar setButtonsImages:btnImageArray forState:UIControlStateNormal forOrientation:LGPlusButtonsViewOrientationAll];
            if ([lang isEqualToString:@"EN"]) {
                [_navBar setDescriptionsTexts:@[@" ", @"To Charter Menu", @"Fetch Jobs", @"Send Data", @"Lite Mode"]];
            } else if ([lang isEqualToString:@"CH"]) {
                [_navBar setDescriptionsTexts:@[@" ", @"去包车菜单", @"重新加载", @"发送数据", @"精简版"]];
            }
        } else if ([role isEqualToString:@"omo"] && isAdhoc) {
            _navBar = [LGPlusButtonsView plusButtonsViewWithNumberOfButtons:6
                                                    firstButtonIsPlusButton:NO
                                                              showAfterInit:NO
                                                              actionHandler:^(LGPlusButtonsView *plusButtonView, NSString *title, NSString *description, NSUInteger index)
                       {
                           NSLog(@"actionHandler | title: %@, description: %@, index: %lu", title, description, (long unsigned)index);
                           if (index == 1) {
                               [self toCharterMenu];
                           } else if (index == 2) {
                               [_mapView clear];
                               [self getJobs];
                               [self drawRoutes];
                               if ([lang isEqualToString:@"EN"]) {
                                   [[[iToast makeText:NSLocalizedString(@"Jobs refreshed", @"")] setGravity:iToastGravityBottom] show];
                               } else if ([lang isEqualToString:@"CH"]) {
                                   [[[iToast makeText:NSLocalizedString(@"地图刷新", @"")] setGravity:iToastGravityBottom] show];
                               }
                           } else if (index == 3) {
                               [self sendPassengerData];
                           } else if (index == 4) {
                               [self viewJobDetails];
                           } else if (index == 5) {
                               [self goLiteMode];
                           }
                       }];
            
            _navBar.showHideOnScroll = NO;
            _navBar.appearingAnimationType = LGPlusButtonsAppearingAnimationTypeCrossDissolveAndPop;
            _navBar.position = LGPlusButtonsViewPositionRightTop;
            
            NSArray *btnImageArray = @[[NSNull new], [UIImage imageNamed:@"chartermenuorhome"], [UIImage imageNamed:@"refresh"], [UIImage imageNamed:@"send"], [UIImage imageNamed:@"mapIcon"]
                                       , [UIImage imageNamed:@"lite"]];
            [_navBar setButtonsImages:btnImageArray forState:UIControlStateNormal forOrientation:LGPlusButtonsViewOrientationAll];
            if ([lang isEqualToString:@"EN"]) {
                [_navBar setDescriptionsTexts:@[@" ", @"To Charter Menu", @"Fetch Jobs", @"Send Data", @"View Job Details"]];
            } else if ([lang isEqualToString:@"CH"]) {
                [_navBar setDescriptionsTexts:@[@" ", @"去包车菜单", @"重新加载", @"发送数据", @"查看包车详情"]];
            }
        } else if (![role isEqualToString:@"omo"] && isAdhoc) {
            _navBar = [LGPlusButtonsView plusButtonsViewWithNumberOfButtons:5
                                                    firstButtonIsPlusButton:NO
                                                              showAfterInit:NO
                                                              actionHandler:^(LGPlusButtonsView *plusButtonView, NSString *title, NSString *description, NSUInteger index)
                       {
                           NSLog(@"actionHandler | title: %@, description: %@, index: %lu", title, description, (long unsigned)index);
                           if (index == 1) {
                               [_mapView clear];
                               [self getJobs];
                               [self drawRoutes];
                               if ([lang isEqualToString:@"EN"]) {
                                   [[[iToast makeText:NSLocalizedString(@"Jobs refreshed", @"")] setGravity:iToastGravityBottom] show];
                               } else if ([lang isEqualToString:@"CH"]) {
                                   [[[iToast makeText:NSLocalizedString(@"地图刷新", @"")] setGravity:iToastGravityBottom] show];
                               }
                           } else if (index == 2) {
                               [self sendPassengerData];
                           } else if (index == 3) {
                               [self viewJobDetails];
                           } else if (index == 4) {
                               [self goLiteMode];
                           }
                       }];
            
            _navBar.showHideOnScroll = NO;
            _navBar.appearingAnimationType = LGPlusButtonsAppearingAnimationTypeCrossDissolveAndPop;
            _navBar.position = LGPlusButtonsViewPositionRightTop;
            
            NSArray *btnImageArray = @[[NSNull new], [UIImage imageNamed:@"refresh"], [UIImage imageNamed:@"send"], [UIImage imageNamed:@"mapIcon"]];
            [_navBar setButtonsImages:btnImageArray forState:UIControlStateNormal forOrientation:LGPlusButtonsViewOrientationAll];
            if ([lang isEqualToString:@"EN"]) {
                [_navBar setDescriptionsTexts:@[@" ", @"Fetch Jobs", @"Send Data", @"View Job Details", @"Lite Mode"]];
            } else if ([lang isEqualToString:@"CH"]) {
                [_navBar setDescriptionsTexts:@[@" ", @"重新加载", @"发送数据", @"查看包车详情", @"精简版"]];
            }
        } else {
            _navBar = [LGPlusButtonsView plusButtonsViewWithNumberOfButtons:4
                                                    firstButtonIsPlusButton:NO
                                                              showAfterInit:NO
                                                              actionHandler:^(LGPlusButtonsView *plusButtonView, NSString *title, NSString *description, NSUInteger index)
                       {
                           NSLog(@"actionHandler | title: %@, description: %@, index: %lu", title, description, (long unsigned)index);
                           if (index == 1) {
                               [_mapView clear];
                               [self getJobs];
                               [self drawRoutes];
                               if ([lang isEqualToString:@"EN"]) {
                                   [[[iToast makeText:NSLocalizedString(@"Jobs refreshed", @"")] setGravity:iToastGravityBottom] show];
                               } else if ([lang isEqualToString:@"CH"]) {
                                   [[[iToast makeText:NSLocalizedString(@"地图刷新", @"")] setGravity:iToastGravityBottom] show];
                               }
                           } else if (index == 2) {
                               [self sendPassengerData];
                           } else if (index == 3) {
                               [self goLiteMode];
                           }
                       }];
            
            _navBar.showHideOnScroll = NO;
            _navBar.appearingAnimationType = LGPlusButtonsAppearingAnimationTypeCrossDissolveAndPop;
            _navBar.position = LGPlusButtonsViewPositionRightTop;
            
            NSArray *btnImageArray = @[[NSNull new], [UIImage imageNamed:@"refresh"], [UIImage imageNamed:@"send"], [UIImage imageNamed:@"lite"]];
            [_navBar setButtonsImages:btnImageArray forState:UIControlStateNormal forOrientation:LGPlusButtonsViewOrientationAll];
            if ([lang isEqualToString:@"EN"]) {
                [_navBar setDescriptionsTexts:@[@" ", @"Fetch Jobs", @"Send Data", @"Lite Mode"]];
            } else if ([lang isEqualToString:@"CH"]) {
                [_navBar setDescriptionsTexts:@[@" ", @"重新加载", @"发送数据", @"精简版"]];
            }
        }
    }
    
    [_navBar setButtonsTitleFont:[UIFont boldSystemFontOfSize:32.f] forOrientation:LGPlusButtonsViewOrientationAll];
    [_navBar setButtonsSize:CGSizeMake(52.f, 52.f) forOrientation:LGPlusButtonsViewOrientationAll];
    [_navBar setButtonsLayerCornerRadius:52.f/2.f forOrientation:LGPlusButtonsViewOrientationAll];
    [_navBar setButtonsBackgroundColor:UIColorFromRGB(0xF68B1F) forState:UIControlStateNormal];
    [_navBar setButtonsBackgroundColor:[UIColor orangeColor] forState:UIControlStateHighlighted];
    [_navBar setButtonsLayerShadowColor:[UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:1.f]];
    [_navBar setButtonsLayerShadowOpacity:0.5];
    [_navBar setButtonsLayerShadowRadius:3.f];
    [_navBar setButtonsLayerShadowOffset:CGSizeMake(0.f, 2.f)];
    
    [_navBar setDescriptionsTextColor:[UIColor whiteColor]];
    [_navBar setDescriptionsBackgroundColor:[UIColor colorWithWhite:0.f alpha:0.66]];
    [_navBar setDescriptionsLayerCornerRadius:6.f forOrientation:LGPlusButtonsViewOrientationAll];
    [_navBar setDescriptionsContentEdgeInsets:UIEdgeInsetsMake(4.f, 8.f, 4.f, 8.f) forOrientation:LGPlusButtonsViewOrientationAll];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [_navBar setButtonsSize:CGSizeMake(44.f, 44.f) forOrientation:LGPlusButtonsViewOrientationLandscape];
        [_navBar setButtonsLayerCornerRadius:44.f/2.f forOrientation:LGPlusButtonsViewOrientationLandscape];
        [_navBar setButtonsTitleFont:[UIFont systemFontOfSize:24.f] forOrientation:LGPlusButtonsViewOrientationLandscape];
    }
    [self.view addSubview:_navBar];
    
    if (isAdhoc) {
        CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
        CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
        UILabel *lblStartEndTrip = [[UILabel alloc] initWithFrame:CGRectMake(0 , screenHeight - 50, screenWidth, 50)];
        int jobStatus = [[adhocDataResponse objectForKey:@"jobStatus"] intValue];
        if (jobStatus == 0) {
            if ([lang isEqualToString:@"EN"]) {
                lblStartEndTrip.text = @"Start Trip ⇨";
            } else if ([lang isEqualToString:@"CH"]) {
                lblStartEndTrip.text = @"开始旅程 ⇨";
            }
            lblStartEndTrip.textColor = [UIColor whiteColor];
            lblStartEndTrip.textAlignment = NSTextAlignmentCenter;
            lblStartEndTrip.font = [UIFont systemFontOfSize:25];
            lblStartEndTrip.backgroundColor = [UIColor greenColor];
            
            UITapGestureRecognizer *onTapAction = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(startTripConfirmation:)];
            onTapAction.delegate = self;
            onTapAction.numberOfTapsRequired = 1;
            [lblStartEndTrip setUserInteractionEnabled:YES];
            [lblStartEndTrip addGestureRecognizer:onTapAction];
            [self.view addSubview:lblStartEndTrip];

            if ([lang isEqualToString:@"EN"]) {
                lblAdhocMarquee.text = @"   Tap the button below to start this adhoc job";
            } else if ([lang isEqualToString:@"CH"]) {
                lblAdhocMarquee.text = @"   点击下面的按钮开始包车";
            }
            [self.view addSubview:lblAdhocMarquee];
            [UIView animateWithDuration:7.5 delay:0.0 options: UIViewAnimationOptionRepeat
                             animations:^{
                                 lblAdhocMarquee.frame = CGRectMake(- screenWidth , screenHeight - 83, screenWidth * 2, 33);
                             } completion:^(BOOL finished){}];
        } else if (jobStatus == 1) {
            if ([lang isEqualToString:@"EN"]) {
                lblStartEndTrip.text = @"End Trip ⇨";
            } else if ([lang isEqualToString:@"CH"]) {
                 lblStartEndTrip.text = @"结束旅程 ⇨";
            }

            lblStartEndTrip.textColor = [UIColor whiteColor];
            lblStartEndTrip.textAlignment = NSTextAlignmentCenter;
            lblStartEndTrip.font = [UIFont systemFontOfSize:25];
            lblStartEndTrip.backgroundColor = [UIColor redColor];
            
            UITapGestureRecognizer *onTapAction = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(endTripConfirmation:)];
            onTapAction.delegate = self;
            [lblStartEndTrip setUserInteractionEnabled:YES];
            [lblStartEndTrip addGestureRecognizer:onTapAction];
            [self.view addSubview:lblStartEndTrip];
            
            lblAdhocMarquee = [[UILabel alloc] initWithFrame:CGRectMake(0 , screenHeight - 83, screenWidth, 33)];
            lblAdhocMarquee.backgroundColor = [UIColor whiteColor];
            lblAdhocMarquee.textColor = UIColorFromRGB(0xF68B1F);
            lblAdhocMarquee.font = [UIFont systemFontOfSize:20];
            if ([lang isEqualToString:@"EN"]) {
                lblAdhocMarquee.text = @"                                                  Job is in progress";
            } else if ([lang isEqualToString:@"CH"]) {
                lblAdhocMarquee.text = @"                                                  包车工作正在进行中";
            }
            [self.view addSubview:lblAdhocMarquee];
            [UIView animateWithDuration:7.5 delay:0.0 options: UIViewAnimationOptionRepeat
                             animations:^{
                                 lblAdhocMarquee.frame = CGRectMake(- screenWidth , screenHeight - 83, screenWidth * 2, 33);
                             } completion:^(BOOL finished){}];
        } else if (jobStatus == 2) {
            if ([lang isEqualToString:@"EN"]) {
                lblAdhocMarquee.text = @"          This job has already ended!";
            } else if ([lang isEqualToString:@"CH"]) {
                lblAdhocMarquee.text = @"          这工作趟已经完成。";
            }
            [self.view addSubview:lblAdhocMarquee];
            [UIView animateWithDuration:7.5 delay:0.0 options: UIViewAnimationOptionRepeat
                             animations:^{
                                 lblAdhocMarquee.frame = CGRectMake(- screenWidth , screenHeight - 83, screenWidth * 2, 33);
                             } completion:^(BOOL finished){}];
        } else if (jobStatus == 3) {
            if ([lang isEqualToString:@"EN"]) {
                lblAdhocMarquee.text = @"  Job has passed its allowance time therefore it has been deemed incomplete.";
            } else if ([lang isEqualToString:@"CH"]) {
                lblAdhocMarquee.text = @"  工作趟早已超过允许的时间，所以这份工作趟已被视为未完成。扣押的钱会用来赔偿未完成的工作趟。";
            }
            [self.view addSubview:lblAdhocMarquee];
            [UIView animateWithDuration:7.5 delay:0.0 options: UIViewAnimationOptionRepeat
                             animations:^{
                                 lblAdhocMarquee.frame = CGRectMake(- screenWidth , screenHeight - 83, screenWidth * 2, 33);
                             } completion:^(BOOL finished){}];
        }
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (void)startTripConfirmation:(UIGestureRecognizer *)sender {
    if ([lang isEqualToString:@"EN"]) {
        UIAlertController *confirmationAlert = [UIAlertController alertControllerWithTitle:@"Message"
                                                                                   message:@"Start this trip?"
                                                                            preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *aStart = [UIAlertAction
                                 actionWithTitle:@"Yes"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action) {
                                     [self startTrip];
                                 }];
        UIAlertAction *aCancel = [UIAlertAction
                                  actionWithTitle:@"Cancel"
                                  style:UIAlertActionStyleDefault
                                  handler:^(UIAlertAction * action) {
                                      [self dismissViewControllerAnimated:YES completion:nil];
                                  }];
        
        [confirmationAlert addAction:aStart];
        [confirmationAlert addAction:aCancel];
        [self presentViewController:confirmationAlert animated:YES completion:nil];
    } else if ([lang isEqualToString:@"CH"]) {
        UIAlertController *confirmationAlert = [UIAlertController alertControllerWithTitle:@"注意"
                                                                                   message:@"请确认这工作趟现在开始。"
                                                                            preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *aStart = [UIAlertAction
                                 actionWithTitle:@"是的"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action) {
                                     [self startTrip];
                                 }];
        UIAlertAction *aCancel = [UIAlertAction
                                  actionWithTitle:@"取消"
                                  style:UIAlertActionStyleDefault
                                  handler:^(UIAlertAction * action) {
                                      [self dismissViewControllerAnimated:YES completion:nil];
                                  }];
        
        [confirmationAlert addAction:aStart];
        [confirmationAlert addAction:aCancel];
        [self presentViewController:confirmationAlert animated:YES completion:nil];
    }

}

- (void)endTripConfirmation:(UIGestureRecognizer *)sender {
    if ([lang isEqualToString:@"EN"]) {
        UIAlertController *confirmationAlert = [UIAlertController alertControllerWithTitle:@"Message"
                                                                                   message:@"End this trip?"
                                                                            preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *aEnd = [UIAlertAction
                               actionWithTitle:@"Yes"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action) {
                                   [self endTrip: @"NO"];
                               }];
        UIAlertAction *aEndNoPassenger = [UIAlertAction
                                          actionWithTitle:@"Passenger did not show up"
                                          style:UIAlertActionStyleDefault
                                          handler:^(UIAlertAction * action) {
                                              [self endTrip: @"YES"];
                                          }];
        UIAlertAction *aCancel = [UIAlertAction
                                  actionWithTitle:@"Cancel"
                                  style:UIAlertActionStyleDefault
                                  handler:^(UIAlertAction * action) {
                                      [self dismissViewControllerAnimated:YES completion:nil];
                                  }];
        
        [confirmationAlert addAction:aEnd];
        [confirmationAlert addAction:aEndNoPassenger];
        [confirmationAlert addAction:aCancel];
        [self presentViewController:confirmationAlert animated:YES completion:nil];
    } else if ([lang isEqualToString:@"CH"]) {
        UIAlertController *confirmationAlert = [UIAlertController alertControllerWithTitle:@"注意"
                                                                                   message:@"请确认您已经完成工作趟。"
                                                                            preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *aEnd = [UIAlertAction
                               actionWithTitle:@"是的"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action) {
                                   [self endTrip: @"NO"];
                               }];
        UIAlertAction *aEndNoPassenger = [UIAlertAction
                                          actionWithTitle:@"乘客没有出现"
                                          style:UIAlertActionStyleDefault
                                          handler:^(UIAlertAction * action) {
                                              [self endTrip: @"YES"];
                                          }];
        UIAlertAction *aCancel = [UIAlertAction
                                  actionWithTitle:@"取消"
                                  style:UIAlertActionStyleDefault
                                  handler:^(UIAlertAction * action) {
                                      [self dismissViewControllerAnimated:YES completion:nil];
                                  }];
        
        [confirmationAlert addAction:aEnd];
        [confirmationAlert addAction:aEndNoPassenger];
        [confirmationAlert addAction:aCancel];
        [self presentViewController:confirmationAlert animated:YES completion:nil];
    }
}

- (void)viewJobDetails {
    NSDictionary *adhocJobDetails = [[NSDictionary alloc] init];
    NSString *adhocPickupName = @"";
    NSString *adhocDropOffName = @"";
    NSString *adhocPickupTime = @"";
    double adhocPickupNameLatitude = 0.0;
    double adhocPickupNameLongitude = 0.0;
    
    for (int i = 0; i < [jobDataResponse count]; i++) {
        adhocJobDetails = [jobDataResponse objectAtIndex:i];
        int adhocJobType = [[adhocJobDetails objectForKey:@"type"] intValue];
        if (adhocJobType == 1) {
            adhocDropOffName = [adhocJobDetails objectForKey:@"pointName"];
        } else {
            if ([adhocPickupName isEqualToString:@""]) {
                adhocPickupName = [adhocJobDetails objectForKey:@"pointName"];
                adhocPickupNameLatitude = [[adhocJobDetails objectForKey:@"latitude"] doubleValue];
                adhocPickupNameLongitude = [[adhocJobDetails objectForKey:@"longitude"] doubleValue];
                adhocPickupTime = [adhocJobDetails objectForKey:@"time"];
            }
        }
    }
    
    NSString *greetingsString;
    NSString *adhocJobDetailsMessage;
    if ([lang isEqualToString:@"EN"]) {
        greetingsString = @"Hello!";
        adhocJobDetailsMessage = [NSString stringWithFormat:@"You have an adhoc job from %@ to %@ at %@", adhocPickupName, adhocDropOffName, adhocPickupTime];
    } else if ([lang isEqualToString:@"CH"]) {
        greetingsString = @"您好";
        adhocJobDetailsMessage = [NSString stringWithFormat:@"您从 %@ 到 %@, 在 %@ 有一趟工作", adhocPickupName, adhocDropOffName, adhocPickupTime];
    }
    
    UIAlertController *viewJobDetailsAlert = [UIAlertController alertControllerWithTitle:greetingsString
                                                                              message:adhocJobDetailsMessage
                                                                       preferredStyle:UIAlertControllerStyleAlert];
    
    NSString *adhocPOCContactNo = [adhocDataResponse objectForKey:@"pocContactNo"];
    NSString *contactPOCMessage;
    if ([lang isEqualToString:@"EN"]) {
        
    } else if ([lang isEqualToString:@"CH"]) {
        
    }
    if (![adhocPOCContactNo isEqualToString:@""] && adhocPOCContactNo != nil) {
        if ([lang isEqualToString:@"EN"]) {
            contactPOCMessage = [NSString stringWithFormat:@"Call POC - %@", [adhocDataResponse objectForKey:@"pocName"]];
        } else if ([lang isEqualToString:@"CH"]) {
            contactPOCMessage = [NSString stringWithFormat:@"联系POC - %@", [adhocDataResponse objectForKey:@"pocName"]];
        }
        
        UIAlertAction *aContactPOC = [UIAlertAction
                              actionWithTitle:contactPOCMessage
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction * action) {
                                  NSString *phoneStr = [NSString stringWithFormat:@"tel:%@", adhocPOCContactNo];
                                  NSURL *phoneURL = [[NSURL alloc] initWithString:phoneStr];
                                  [[UIApplication sharedApplication] openURL:phoneURL];
                              }];
        [viewJobDetailsAlert addAction:aContactPOC];
    }
    
    NSString *navigateString;
    if ([lang isEqualToString:@"EN"]) {
        navigateString = @"Navigate me to first Pick Up Point";
    } else if ([lang isEqualToString:@"CH"]) {
        navigateString = @"导航到第一个接送点";
    }
    UIAlertAction *aNavigateToPickupPoint = [UIAlertAction
                          actionWithTitle:navigateString
                          style:UIAlertActionStyleDefault
                          handler:^(UIAlertAction * action) {
                              NSString *adhocLatitude = [NSString stringWithFormat:@"%lf", adhocPickupNameLatitude];
                              NSString *adhocLongitude = [NSString stringWithFormat:@"%lf", adhocPickupNameLongitude];
                              NSString *directionsRequest = [NSString stringWithFormat:@"http://maps.google.com/maps?q=%@,%@", adhocLatitude, adhocLongitude];
                              NSURL *directionsURL = [NSURL URLWithString:directionsRequest];
                              [[UIApplication sharedApplication] openURL:directionsURL];
                          }];
    
    NSString *cancelString;
    if ([lang isEqualToString:@"EN"]) {
        cancelString = @"Cancel";
    } else if ([lang isEqualToString:@"CH"]) {
        cancelString = @"取消";
    }
    UIAlertAction *aCancel = [UIAlertAction
                              actionWithTitle:cancelString
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction * action) {
                                  [self dismissViewControllerAnimated:YES completion:nil];
                              }];
    
    [viewJobDetailsAlert addAction:aNavigateToPickupPoint];
    [viewJobDetailsAlert addAction:aCancel];
    [self presentViewController:viewJobDetailsAlert animated:YES completion:nil];
}

- (void)goLiteMode {
//    if (isAdhoc) {
//        UIAlertController *noLiteModeAlert = [UIAlertController alertControllerWithTitle:@"Sorry"
//                                                                                        message:@"Lite mode is not available for adhoc jobs."
//                                                                                 preferredStyle:UIAlertControllerStyleAlert];
//        UIAlertAction *aCancel = [UIAlertAction
//                                  actionWithTitle:@"Ok"
//                                  style:UIAlertActionStyleDefault
//                                  handler:^(UIAlertAction * action) {
//                                      [self dismissViewControllerAnimated:YES completion:nil];
//                                  }];
//
//        [noLiteModeAlert addAction:aCancel];
//        [self presentViewController:noLiteModeAlert animated:YES completion:nil];
//    } else {
//        if (jobDataResponse != nil) {
//            NSData *archivedData = [NSKeyedArchiver archivedDataWithRootObject:jobDataResponse];
//            [userPrefs setObject:archivedData forKey:JOBARRAY];
//            [userPrefs synchronize];
//            [self performSegueWithIdentifier:@"goLite" sender:self];
//        } else {
//            UIAlertController *noLiteModeAlert = [UIAlertController alertControllerWithTitle:@"You don't have a job on hand."
//                                                                                     message:@""
//                                                                              preferredStyle:UIAlertControllerStyleAlert];
//            UIAlertAction *aCancel = [UIAlertAction
//                                      actionWithTitle:@"Ok"
//                                      style:UIAlertActionStyleDefault
//                                      handler:^(UIAlertAction * action) {
//                                          [self dismissViewControllerAnimated:YES completion:nil];
//                                      }];
//
//            [noLiteModeAlert addAction:aCancel];
//            [self presentViewController:noLiteModeAlert animated:YES completion:nil];
//        }
//    }
}

- (void)drawRoutes {
    /*JOB MARKER - START*/
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0,0,60,60)];
    UIView *timeView = [[UIView alloc] initWithFrame:CGRectMake(0,0,60,80)];
    UIImageView *pinImageView;
    referencedLocationData = [[NSMutableArray alloc] init];
    noOfPassengersPerStop = [[NSMutableArray alloc] init];
    
    UILabel *label = [UILabel new];
    label.font = [UIFont systemFontOfSize:13];
    label.textColor = [UIColor whiteColor];
    
    UILabel *timelabel = [UILabel new];
    timelabel.font = [UIFont boldSystemFontOfSize:25];
    timelabel.textColor = [UIColor blackColor];
    
    for (int i = 0; i < [jobDataResponse count]; i++) {
        NSDictionary *eachMarker = [jobDataResponse objectAtIndex:i];
        GMSMarker *marker = [[GMSMarker alloc] init];
        NSNumber *mType = [eachMarker objectForKey:@"type"];
        NSNumber *mNoOfPassengers = [eachMarker objectForKey:@"numberOfPassengers"];
        NSString *timeToReach = [eachMarker objectForKey:@"time"];
        
        pinImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"black.png"]];
        label.text = [NSString stringWithFormat:@" %@", timeToReach];
        [label sizeToFit];
        [timeView addSubview:pinImageView];
        [timeView addSubview:label];
        
        if ([mType intValue] == 1) {
            pinImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"blue_marker.png"]];
        } else {
            pinImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"green_marker.png"]];
        }
        timelabel.text = [NSString stringWithFormat:@"    %d", [mNoOfPassengers intValue]];
        [timelabel sizeToFit];
        [view addSubview:pinImageView];
        [view addSubview:timelabel];
        
        UIImage *markerIcon = [self imageFromView:timeView];
        marker.icon = markerIcon;
        marker.position = CLLocationCoordinate2DMake([eachMarker[@"latitude"] doubleValue], [eachMarker[@"longitude"] doubleValue]);
        marker.title = eachMarker[@"pointName"];
        marker.snippet = timeToReach;
        marker.map = _mapView;
        
        markerIcon = [self imageFromView:view];
        marker = [[GMSMarker alloc] init];
        marker.icon = markerIcon;
        marker.position = CLLocationCoordinate2DMake([eachMarker[@"latitude"] doubleValue], [eachMarker[@"longitude"] doubleValue]);
        marker.title = eachMarker[@"pointName"];
        marker.snippet = timeToReach;
        marker.map = _mapView;
        
        CLLocation *mLocation = [[CLLocation alloc] initWithLatitude:[eachMarker[@"latitude"] doubleValue] longitude:[eachMarker[@"longitude"] doubleValue]];
        [referencedLocationData addObject:mLocation];

        [noOfPassengersPerStop addObject:mNoOfPassengers];
    }
    /*JOB MARKER - END*/
    
    /*ROUTE - START*/
    GMSMutablePath *path = [GMSMutablePath path];
    
    for (int i = 0; i < [pathDataResponse count]; i++) {
        NSDictionary *mRoute = [pathDataResponse objectAtIndex:i];
        [path addCoordinate:CLLocationCoordinate2DMake([mRoute[@"latitude"] doubleValue], [mRoute[@"longitude"] doubleValue])];
    }
    GMSPolyline *polyline = [GMSPolyline polylineWithPath:path];
    polyline.strokeWidth = 3.3f;
    polyline.geodesic = YES;
    polyline.map = _mapView;
    polyline.strokeColor = [UIColor redColor];
    /*ROUTE - END*/
}

#pragma mark - navigation bar
- (void)showHideButtonsAction {
    if (_navBar.isShowing)
        [_navBar hideAnimated:YES completionHandler:nil];
    else
        [_navBar showAnimated:YES completionHandler:nil];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation{
    currentLocationData = newLocation;
    
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd/MM/yyyy, H:mm:ss"];
    NSDate *sgDate = [NSDate date];
    mDate = [dateFormatter stringFromDate:sgDate];
    NSTimeInterval secondsInEightHours = 8 * 60 * 60;
    NSDate *dateEightHoursAhead = [sgDate dateByAddingTimeInterval:secondsInEightHours];

    mLongitude = newLocation.coordinate.longitude;
    mLatitude = newLocation.coordinate.latitude;
    mAltitude = newLocation.altitude;
    mAccuracy = newLocation.horizontalAccuracy;
    mSpeed = newLocation.speed;
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
    mPollingDate = [dateFormatter stringFromDate:dateEightHoursAhead];
    
    busMarker.position = CLLocationCoordinate2DMake(mLatitude, mLongitude);
    busMarker.map = _mapView;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
//    double heading = newHeading.trueHeading;
//    busMarker.groundAnchor = CGPointMake(0.5, 0.5);
//    busMarker.rotation = heading;
//    busMarker.map = _mapView;
    
//    double headingDegrees = (heading*M_PI/180);
    CLLocationDirection trueNorth = [newHeading trueHeading];
    [_mapView animateToBearing:trueNorth];
}

- (UIImage *)imageFromView:(UIView *) view {
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        UIGraphicsBeginImageContextWithOptions(view.frame.size, NO, [[UIScreen mainScreen] scale]);
    } else {
        UIGraphicsBeginImageContext(view.frame.size);
    }
    [view.layer renderInContext: UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (IBAction)toSettings {
    [self stopPollingLocation];
    [self stopCheckingProximity];
    [self stopCameraFollowing];
    [self sendPassengerData];
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    [self performSegueWithIdentifier:@"goToSettings" sender:self];
}

/* Camera centering - START */
- (void)startCameraFollowing {
    cameraTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(cameraCentering) userInfo:nil repeats:YES];
}

- (void)stopCameraFollowing {
    [cameraTimer invalidate];
    cameraTimer = nil;
}

- (void)cameraCentering {
    [_mapView animateToLocation:CLLocationCoordinate2DMake(mLatitude, mLongitude)];
}
/* Camera centering - END */

#pragma mark - Location Polling
- (void)startPollingLocation {
    locationTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(backgroundLocationPolling) userInfo:nil repeats:YES];
}

- (void)stopPollingLocation {
    [locationTimer invalidate];
    locationTimer = nil;
}

- (void)backgroundLocationPolling {
    if (status == NotReachable) {
        [storedLongitude addObject:[NSString stringWithFormat:@"%lf", mLongitude]];
        [storedLatitude addObject:[NSString stringWithFormat:@"%lf", mLatitude]];
        [storedAltitude addObject:[NSString stringWithFormat:@"%lf", mAltitude]];
        [storedAccuracy addObject:[NSString stringWithFormat:@"%lf", mAccuracy]];
        [storedSpeed addObject:[NSString stringWithFormat:@"%lf", mSpeed]];
        [storedDateTime addObject:[NSString stringWithFormat:@"%@", mPollingDate]];
        
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            if ([lang isEqualToString:@"EN"]) {
                [[[iToast makeText:NSLocalizedString(@"No Network detected. Storing location data into database...", @"")] setGravity:iToastGravityBottom] show];
            } else if ([lang isEqualToString:@"CH"]) {
                [[[iToast makeText:NSLocalizedString(@"No Network detected. Storing location data into database...", @"")] setGravity:iToastGravityBottom] show];
            }
        });
    } else {
        __block NSInteger success = 0;
        if (mAccuracy <= 0.0) {
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                if ([lang isEqualToString:@"EN"]) {
                    [[[iToast makeText:NSLocalizedString(@"Unable to retrieve locational updates from google. Retrying in 5 seconds...", @"")] setGravity:iToastGravityBottom] show];
                } else if ([lang isEqualToString:@"CH"]) {
                    [[[iToast makeText:NSLocalizedString(@"无法找到您的当前位置。 我们将在5秒后重试...", @"")] setGravity:iToastGravityBottom] show];
                }
            });
        } else {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                NSDictionary *locationList = [NSDictionary dictionaryWithObjectsAndKeys:
                                              [NSString stringWithFormat:@"%lf", mLongitude], @"longitude",
                                              [NSString stringWithFormat:@"%lf", mLatitude], @"latitude",
                                              [NSString stringWithFormat:@"%lf", mAltitude], @"altitude",
                                              [NSString stringWithFormat:@"%lf", mAccuracy], @"accuracy",
                                              [NSString stringWithFormat:@"%lf", mSpeed], @"Speed",
                                              mPollingDate, @"DateCreated",
                                              nil];
                
                NSMutableArray *locationArray = [[NSMutableArray alloc] init];
                [locationArray addObject:locationList];
                
                NSDictionary *jsonData = [NSDictionary dictionaryWithObjectsAndKeys:
                                          locationArray, @"locationList",
                                          mPollingDate, @"requestTime",
                                          nil];
                
                NSURL *url = [NSURL URLWithString:LOCATION_URL];
                NSError *error = [[NSError alloc] init];
                NSData *postData = [NSJSONSerialization dataWithJSONObject:jsonData options:NSJSONWritingPrettyPrinted error:&error];
                NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
                NSString *jsonString = [[NSString alloc] initWithData:postData encoding:NSUTF8StringEncoding];
                
                NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
                [request setURL:url];
                [request setHTTPMethod:@"POST"];
                [request setValue:token forHTTPHeaderField:@"token"];
                [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
                [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
                [request setHTTPBody:postData];
                
                NSHTTPURLResponse *response = nil;
                NSData *urlData=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
                NSLog(@"Response code: %ld", (long)[response statusCode]);
                NSLog(@"jsonData as string:\n%@", jsonString);
                NSLog(@"Location sent");
                
                if ([response statusCode] >= 200 && [response statusCode] < 300) {
                    NSError *error = nil;
                    NSDictionary *jsonResponse = [NSJSONSerialization
                                              JSONObjectWithData:urlData
                                              options:NSJSONReadingMutableContainers
                                              error:&error];
                    
                    success = [jsonResponse[@"success"] integerValue];

                    if (success == 1) {
                        if (toShowMsg){
                            dispatch_async(dispatch_get_main_queue(), ^(void){
                                if ([lang isEqualToString:@"EN"]) {
                                    [[[iToast makeText:NSLocalizedString(@"Location has been updated!", @"")] setGravity:iToastGravityBottom] show];
                                } else if ([lang isEqualToString:@"CH"]) {
                                    [[[iToast makeText:NSLocalizedString(@"位置更新！", @"")] setGravity:iToastGravityBottom] show];
                                }
                            });
                        }
                        [userPrefs setValue:mDate forKey:LAST_UPDATED_TIME];
                        const BOOL didSave = [userPrefs synchronize];
                        if (!didSave) {
                            [self alertStatus:@"Memory is full" :@"Unable to save settings!"];
                        }
                    } else {
                        NSString *error_msg = (NSString *) jsonResponse[@"error_message"];
                        if ([lang isEqualToString:@"EN"]) {
                            [self alertStatus:error_msg :@"Unable to send location data!"];
                        } else if ([lang isEqualToString:@"CH"]) {
                            [self alertStatus:@"无法发送数据！" :@""];
                        }
                    }
                } else {
                    NSLog(@"Connection lost momentarily");
                }
            });
            
            if ([storedLongitude count] > 0) {
                for (int i = 0; i < [storedLongitude count]; i++) {
                    dispatch_async(dispatch_get_main_queue(), ^(void){
                        if ([lang isEqualToString:@"EN"]) {
                            [[[iToast makeText:NSLocalizedString(@"Sending off stored locational data from database while offline..", @"")] setGravity:iToastGravityCenter] show];
                        } else if ([lang isEqualToString:@"CH"]) {
                            [[[iToast makeText:NSLocalizedString(@"发送存储的位置数据...", @"")] setGravity:iToastGravityCenter] show];
                        }
                    });
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                        NSDictionary *locationList = [NSDictionary dictionaryWithObjectsAndKeys:
                                                      [storedLongitude objectAtIndex:i], @"longitude",
                                                      [storedLatitude objectAtIndex:i], @"latitude",
                                                      [storedAltitude objectAtIndex:i], @"altitude",
                                                      [storedAccuracy objectAtIndex:i], @"accuracy",
                                                      [storedSpeed objectAtIndex:i], @"Speed",
                                                      [storedDateTime objectAtIndex:i], @"DateCreated",
                                                      nil];
                        
                        NSMutableArray *locationArray = [[NSMutableArray alloc] init];
                        [locationArray addObject:locationList];
                        
                        NSDictionary *jsonData = [NSDictionary dictionaryWithObjectsAndKeys:
                                                  locationArray, @"locationList",
                                                  mPollingDate, @"requestTime",
                                                  nil];
                        
                        NSURL *url = [NSURL URLWithString:LOCATION_URL];
                        NSError *error = [[NSError alloc] init];
                        NSData *postData = [NSJSONSerialization dataWithJSONObject:jsonData options:NSJSONWritingPrettyPrinted error:&error];
                        NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
                        NSString *jsonString = [[NSString alloc] initWithData:postData encoding:NSUTF8StringEncoding];
                        
                        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
                        [request setURL:url];
                        [request setHTTPMethod:@"POST"];
                        [request setValue:token forHTTPHeaderField:@"token"];
                        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
                        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
                        [request setHTTPBody:postData];
                        
                        NSHTTPURLResponse *response = nil;
                        NSData *urlData=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
                        NSLog(@"Response code: %ld", (long)[response statusCode]);
                        NSLog(@"jsonData as string:\n%@", jsonString);
                        
                        if ([response statusCode] >= 200 && [response statusCode] < 300) {
                            NSError *error = nil;
                            NSDictionary *jsonData = [NSJSONSerialization
                                                      JSONObjectWithData:urlData
                                                      options:NSJSONReadingMutableContainers
                                                      error:&error];
                            
                            success = [jsonData[@"success"] integerValue];
                            
                            if (success == 1) {
                                dispatch_async(dispatch_get_main_queue(), ^(void){
                                    if ([lang isEqualToString:@"EN"]) {
                                        [[[iToast makeText:NSLocalizedString(@"Location has been updated!", @"")] setGravity:iToastGravityBottom] show];
                                    } else if ([lang isEqualToString:@"CH"]) {
                                        [[[iToast makeText:NSLocalizedString(@"位置更新！", @"")] setGravity:iToastGravityBottom] show];
                                    }
                                });
                            } else {
                                NSString *error_msg = (NSString *) jsonData[@"error_message"];
                                [self alertStatus:error_msg :@"Unable to send location data!"];
                            }
                        } else {
                            if ([lang isEqualToString:@"EN"]) {
                                [self alertStatus:@"" :@"Unable to send location data!"];
                            } else if ([lang isEqualToString:@"CH"]) {
                                [self alertStatus:@"无法发送数据！" :@""];
                            }
                        }
                    });
                }
                [storedLongitude removeAllObjects];
                [storedLatitude removeAllObjects];
                [storedAccuracy removeAllObjects];
                [storedAltitude removeAllObjects];
                [storedSpeed removeAllObjects];
                [storedDateTime removeAllObjects];
            }
        }
    }
}

#pragma mark - Get Jobs
- (void)getJobs {
    __block NSInteger success = 0;
    jobDataResponse = nil;
    pathDataResponse = nil;
    passengersDataResponse = nil;
    adhocDataResponse = nil;
    if (token != nil && token != NULL) {
        NSURL *url = [NSURL URLWithString:JOBS_URL];
        NSError *error = [[NSError alloc] init];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setURL:url];
        [request setHTTPMethod:@"GET"];
        [request setValue:token forHTTPHeaderField:@"token"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
   
        NSHTTPURLResponse *response = nil;
        NSData *urlData=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        NSLog(@"Response code: %ld", (long)[response statusCode]);

        if ([response statusCode] >= 200 && [response statusCode] < 300) {
            NSError *error = nil;
            NSDictionary *jsonResponse = [NSJSONSerialization
                                          JSONObjectWithData:urlData
                                          options:NSJSONReadingMutableContainers
                                          error:&error];

            success = [jsonResponse[@"success"] integerValue];
            NSDictionary *dataResponse = [jsonResponse objectForKey:@"data"];
 
            if (success == 1) {
                NSLog(@"Successfully retreived jobs!");
                NSLog(@"****************************");
                jobDataResponse = [dataResponse objectForKey:@"points"];
                pathDataResponse = [dataResponse objectForKey:@"path"];
                passengersDataResponse = [dataResponse objectForKey:@"passengers"];
                adhocDataResponse = [dataResponse objectForKey:@"adhoc"];
                
                NSString *serviceName = [dataResponse objectForKey:@"serviceName"];
                [userPrefs setValue:serviceName forKey:SERVICE_NAME];
                [userPrefs synchronize];
                
                NSNumber *numToBool = [dataResponse objectForKey:@"schoolBus"];
                isSchoolBusTrip = [numToBool boolValue];
                
                numToBool = [dataResponse objectForKey:@"internalNfc"];
                isInternalNFCEnabled = [numToBool boolValue];

                numToBool = [dataResponse objectForKey:@"externalNfc"];
                isExternalNFCEnabled = [numToBool boolValue];
            } else {
                NSString *error_msg = (NSString *) jsonResponse[@"error_message"];
                if ([lang isEqualToString:@"EN"]) {
                    [self alertStatus:error_msg :@"No jobs detected! Please contact your operations team."];
                } else if ([lang isEqualToString:@"CH"]) {
                    [self alertStatus:@"您暂时无工作趟，但仍能开始追踪器. 您可以重刷新趟，或者您也可以联络您的巴士运作服务员。" :@""];
                }
            }
        } else {
            if ([lang isEqualToString:@"EN"]) {
                [self alertStatus:@"" :@"Network is unstable. Please check your network settings. We will keep trying to connect in the meantime."];
            } else if ([lang isEqualToString:@"CH"]) {
                [self alertStatus:@"网络不稳定。请检查您的网络。 我们会继续尝试连接。" :@""];
            }
        }
    }
}

- (BOOL)checkPassenger: (NSString *)scannedCanId {
    if (scannedCanId == nil) {
        return FALSE;
    } else {
        if ([passengerCanIdToday containsObject:scannedCanId]) {
            //do nothing
        } else {
            [passengerCanIdToday addObject:scannedCanId];
            [passengerBoardingTimeToday addObject:mPollingDate];
            [passengerCanIdTodayNoClearing addObject:scannedCanId];
            NSData *archivedData = [NSKeyedArchiver archivedDataWithRootObject:passengerCanIdTodayNoClearing];
            [userPrefs setObject:archivedData forKey:PASSENGER_LIST_TODAY];
            const BOOL didSave = [userPrefs synchronize];
            if (!didSave) {
                [self alertStatus:@"Memory is full" :@"Unable to save settings!"];
            }
            
            if (isDropOff) {
                [passengerPickUpDropOffToday addObject:@"1"];
            } else {
                [passengerPickUpDropOffToday addObject:@"0"];
            }
        }
        
        for (int i = 0; i < [passengersDataResponse count]; i++) {
            NSDictionary *passenger = [passengersDataResponse objectAtIndex:i];
            NSString *canIdForComparison = [passenger objectForKey:@"ezlinkCanId"];
            
            if ([canIdForComparison isEqualToString:scannedCanId]) {
                passengerName = [passenger objectForKey:@"name"];
                passengerGender = [passenger objectForKey:@"gender"];
                return TRUE;
            }
        }
    }
    return FALSE;
}

#pragma mark - send passenger data
- (void)startSendingDataPeriodically {
    dataTimer = [NSTimer scheduledTimerWithTimeInterval:300.0 target:self selector:@selector(sendPassengerData) userInfo:nil repeats:YES];
}

- (void)stopSendingDataPeriodically {
    [dataTimer invalidate];
    dataTimer = nil;
}

- (void)sendPassengerData {
    int num = (int)[passengerCanIdToday count];
    if (num > 0) {
        __block NSInteger success = 0;
        NSDictionary *passengerValue;
        NSMutableArray *passengerArray = [[NSMutableArray alloc] init];
        for (int i = 0; i < [passengerCanIdToday count]; i++) {
            NSNumber *mode = @YES;
            if ([[passengerPickUpDropOffToday objectAtIndex:i] isEqualToString:@"0"]) {
                mode = @NO;
            }

            passengerValue = [NSDictionary dictionaryWithObjectsAndKeys:
                                [passengerCanIdToday objectAtIndex:i], @"ezlinkCanId",
                                [passengerBoardingTimeToday objectAtIndex:i], @"presentDateTime",
                                mode, @"isDropOff",
                                nil];
            [passengerArray addObject:passengerValue];
        }

        NSDictionary *jsonData = [NSDictionary dictionaryWithObjectsAndKeys:
                                    passengerArray, @"Attendances",
                                    nil];

        NSURL *url = [NSURL URLWithString:ATTENDANCE_URL];
        NSError *error = [[NSError alloc] init];
        NSData *postData = [NSJSONSerialization dataWithJSONObject:jsonData options:NSJSONWritingPrettyPrinted error:&error];
        NSString *jsonString = [[NSString alloc] initWithData:postData encoding:NSUTF8StringEncoding];

        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setURL:url];
        [request setHTTPMethod:@"POST"];
        [request setValue:token forHTTPHeaderField:@"token"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:postData];

        NSHTTPURLResponse *response = nil;
        NSData *urlData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        NSLog(@"Response code: %ld", (long)[response statusCode]);
        NSLog(@"jsonData as string:\n%@", jsonString);

        if ([response statusCode] >= 200 && [response statusCode] < 300)
        {
            NSError *error = nil;
            NSDictionary *jsonResponse = [NSJSONSerialization
                                      JSONObjectWithData:urlData
                                      options:NSJSONReadingMutableContainers
                                      error:&error];
                
            success = [jsonResponse[@"success"] integerValue];
            if (success == 1)
            {
                NSLog(@"Passenger List sent");
                if ([lang isEqualToString:@"EN"]) {
                    NSString *string = [NSString stringWithFormat:@"%i passenger data has been updated to the database!", num];
                    [[[iToast makeText:NSLocalizedString(string, @"")] setGravity:iToastGravityBottom] show];
                } else if ([lang isEqualToString:@"CH"]) {
                    NSString *string = [NSString stringWithFormat:@"%i 位旅客数据已上传！", num];
                    [[[iToast makeText:NSLocalizedString(string, @"")] setGravity:iToastGravityBottom] show];
                }

                passengerCanIdToday = [[NSMutableArray alloc] init];
                passengerBoardingTimeToday = [[NSMutableArray alloc] init];
            } else {
                NSString *error_msg = (NSString *) jsonResponse[@"error_message"];
                [self alertStatus:error_msg :@"Unable to send passenger data!"];
            }
        } else {
            if ([lang isEqualToString:@"EN"]) {
                [self alertStatus:@"" :@"Network is unstable. Please check your network settings. We will keep trying to connect in the meantime."];
            } else if ([lang isEqualToString:@"CH"]) {
                [self alertStatus:@"网络不稳定。请检查您的网络。 我们会继续尝试连接。" :@""];
            }
        }
    } else {
        if ([lang isEqualToString:@"EN"]) {
            [[[iToast makeText:NSLocalizedString(@"No data stored in passenger list", @"")] setGravity:iToastGravityBottom] show];
        } else if ([lang isEqualToString:@"CH"]) {
            [[[iToast makeText:NSLocalizedString(@"没有数据。", @"")] setGravity:iToastGravityBottom] show];
        }
    }
}

#pragma mark - start job
- (void)startTrip {
    __block NSInteger success = 0;
    NSDictionary *startTripData = [NSDictionary dictionaryWithObjectsAndKeys:
                                 adhocCharterId, @"busCharterId",
                                 nil];
    
    NSDictionary *jsonData = [NSDictionary dictionaryWithObjectsAndKeys:
                              startTripData, @"data",
                              nil];
    
    if (token != nil && token != NULL) {
        NSURL *url = [NSURL URLWithString:START_TRIP_URL];
        NSError *error = [[NSError alloc] init];
        NSData *postData = [NSJSONSerialization dataWithJSONObject:jsonData options:NSJSONWritingPrettyPrinted error:&error];
        NSString *jsonString = [[NSString alloc] initWithData:postData encoding:NSUTF8StringEncoding];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setURL:url];
        [request setHTTPMethod:@"POST"];
        [request setValue:token forHTTPHeaderField:@"token"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:postData];
        
        NSHTTPURLResponse *response = nil;
        NSData *urlData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        NSLog(@"Response code: %ld", (long)[response statusCode]);
        NSLog(@"jsonData as string:\n%@", jsonString);
        
        if ([response statusCode] >= 200 && [response statusCode] < 300) {
            NSError *error = nil;
            NSDictionary *jsonResponse = [NSJSONSerialization
                                          JSONObjectWithData:urlData
                                          options:NSJSONReadingMutableContainers
                                          error:&error];
            success = [jsonResponse[@"success"] integerValue];
            if (success == 1) {
                NSDictionary *dataResponse = [jsonResponse objectForKey:@"data"];
                success = [dataResponse[@"success"] integerValue];
                if (success == 1) {
                    [userPrefs setBool:YES forKey:IS_TRACKING];
                    [userPrefs synchronize];
                    MapViewController *myController = [self.storyboard instantiateViewControllerWithIdentifier:@"MapView"];
                    [self.navigationController pushViewController:myController animated:NO];
                } else {
                    NSString *message = [dataResponse objectForKey:@"message"];
                    UIAlertController *confirmationAlert = [UIAlertController alertControllerWithTitle:@"Message"
                                                                                               message:message
                                                                                        preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *aCloseAlertView = [UIAlertAction
                                                      actionWithTitle:@"OK"
                                                      style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * action) {
                                                          [self dismissViewControllerAnimated:YES completion:nil];
                                                      }];
                    [confirmationAlert addAction:aCloseAlertView];
                    [self presentViewController:confirmationAlert animated:YES completion:nil];
                }
            } else {
                if ([lang isEqualToString:@"EN"]) {
                    UIAlertController *cannotProceedAlert = [UIAlertController alertControllerWithTitle:@"Error!"
                                                                                                message:@"Unable to verify job(s). Please try again."
                                                                                         preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *aReturn = [UIAlertAction
                                              actionWithTitle:@"OK"
                                              style:UIAlertActionStyleDefault
                                              handler:^(UIAlertAction * action) {
                                                  [self dismissViewControllerAnimated:YES completion:nil];
                                              }];
                    [cannotProceedAlert addAction:aReturn];
                    [self presentViewController:cannotProceedAlert animated:YES completion:nil];
                } else if ([lang isEqualToString:@"CH"]) {
                    UIAlertController *cannotProceedAlert = [UIAlertController alertControllerWithTitle:@"警报！"
                                                                                                message:@"无法验证工作趟。请检查您的网络。"
                                                                                         preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *aReturn = [UIAlertAction
                                              actionWithTitle:@"OK"
                                              style:UIAlertActionStyleDefault
                                              handler:^(UIAlertAction * action) {
                                                  [self dismissViewControllerAnimated:YES completion:nil];
                                              }];
                    [cannotProceedAlert addAction:aReturn];
                    [self presentViewController:cannotProceedAlert animated:YES completion:nil];
                }
            }
        } else {
            UIAlertController *concurrentLoginAlert = [UIAlertController alertControllerWithTitle:@"Error!"
                                                                                          message:@"Please log in again."
                                                                                   preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *aReturn = [UIAlertAction
                                      actionWithTitle:@"OK"
                                      style:UIAlertActionStyleDefault
                                      handler:^(UIAlertAction * action) {
                                          [self performSegueWithIdentifier:@"resetApp2" sender:self];
                                      }];
            [concurrentLoginAlert addAction:aReturn];
            [self presentViewController:concurrentLoginAlert animated:YES completion:nil];
        }
    }
}

#pragma mark - end job
- (void)endTrip:(NSString *)noShow {
    __block NSInteger success = 0;
    NSDictionary *endTripData;
    if ([noShow isEqualToString:@"YES"]) {
        endTripData = [NSDictionary dictionaryWithObjectsAndKeys:
                       adhocCharterId, @"busCharterId",
                       @YES, @"noShow",
                       nil];
    } else {
        endTripData = [NSDictionary dictionaryWithObjectsAndKeys:
                       adhocCharterId, @"busCharterId",
                       @NO, @"noShow",
                       nil];
    }

    
    NSDictionary *jsonData = [NSDictionary dictionaryWithObjectsAndKeys:
                              endTripData, @"data",
                              nil];
    
    if (token != nil && token != NULL) {
        NSURL *url = [NSURL URLWithString:END_TRIP_URL];
        NSError *error = [[NSError alloc] init];
        NSData *postData = [NSJSONSerialization dataWithJSONObject:jsonData options:NSJSONWritingPrettyPrinted error:&error];
        NSString *jsonString = [[NSString alloc] initWithData:postData encoding:NSUTF8StringEncoding];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setURL:url];
        [request setHTTPMethod:@"POST"];
        [request setValue:token forHTTPHeaderField:@"token"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:postData];
        
        NSHTTPURLResponse *response = nil;
        NSData *urlData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        NSLog(@"Response code: %ld", (long)[response statusCode]);
        NSLog(@"jsonData as string:\n%@", jsonString);
        
        if ([response statusCode] >= 200 && [response statusCode] < 300) {
            NSError *error = nil;
            NSDictionary *jsonResponse = [NSJSONSerialization
                                          JSONObjectWithData:urlData
                                          options:NSJSONReadingMutableContainers
                                          error:&error];
            success = [jsonResponse[@"success"] integerValue];
            if (success == 1) {
                NSDictionary *dataResponse = [jsonResponse objectForKey:@"data"];
                success = [dataResponse[@"success"] integerValue];
                if (success == 1) {
                    MapViewController *myController = [self.storyboard instantiateViewControllerWithIdentifier:@"MapView"];
                    [self.navigationController pushViewController:myController animated:NO];
                } else {
                    NSString *message = [dataResponse objectForKey:@"message"];
                    UIAlertController *confirmationAlert = [UIAlertController alertControllerWithTitle:@"Message"
                                                                                               message:message
                                                                                        preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *aCloseAlertView = [UIAlertAction
                                                      actionWithTitle:@"OK"
                                                      style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * action) {
                                                          [self dismissViewControllerAnimated:YES completion:nil];
                                                      }];
                    [confirmationAlert addAction:aCloseAlertView];
                    [self presentViewController:confirmationAlert animated:YES completion:nil];
                }
            } else {
                if ([lang isEqualToString:@"EN"]) {
                    UIAlertController *cannotProceedAlert = [UIAlertController alertControllerWithTitle:@"Error!"
                                                                                                message:@"Unable to verify job(s). Please try again."
                                                                                         preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *aReturn = [UIAlertAction
                                              actionWithTitle:@"OK"
                                              style:UIAlertActionStyleDefault
                                              handler:^(UIAlertAction * action) {
                                                  [self dismissViewControllerAnimated:YES completion:nil];
                                              }];
                    [cannotProceedAlert addAction:aReturn];
                    [self presentViewController:cannotProceedAlert animated:YES completion:nil];
                } else if ([lang isEqualToString:@"CH"]) {
                    UIAlertController *cannotProceedAlert = [UIAlertController alertControllerWithTitle:@"警报！"
                                                                                                message:@"无法验证工作趟。请检查您的网络。"
                                                                                         preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *aReturn = [UIAlertAction
                                              actionWithTitle:@"OK"
                                              style:UIAlertActionStyleDefault
                                              handler:^(UIAlertAction * action) {
                                                  [self dismissViewControllerAnimated:YES completion:nil];
                                              }];
                    [cannotProceedAlert addAction:aReturn];
                    [self presentViewController:cannotProceedAlert animated:YES completion:nil];
                }
            }
        } else {
            UIAlertController *concurrentLoginAlert = [UIAlertController alertControllerWithTitle:@"Error!"
                                                                                          message:@"Please log in again."
                                                                                   preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *aReturn = [UIAlertAction
                                      actionWithTitle:@"OK"
                                      style:UIAlertActionStyleDefault
                                      handler:^(UIAlertAction * action) {
                                          [self performSegueWithIdentifier:@"resetApp2" sender:self];
                                      }];
            [concurrentLoginAlert addAction:aReturn];
            [self presentViewController:concurrentLoginAlert animated:YES completion:nil];
        }
    }
}

#pragma mark - check proximity
- (void)startCheckingProximity {
    proximityTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(proximityCheck) userInfo:nil repeats:YES];
}

- (void)stopCheckingProximity {
    [proximityTimer invalidate];
    proximityTimer = nil;
}

- (void)proximityCheck {
    for (int i = 0; i <[referencedLocationData count]; i++) {
        int distance = [[referencedLocationData objectAtIndex:i] distanceFromLocation:currentLocationData];
        NSLog(@"Checking proximity...");
        if (distance < 150) {
            [referencedLocationData removeObjectAtIndex:i];
            NSString *soundFilePath;
            int noOfPassengers = [[noOfPassengersPerStop objectAtIndex:i] intValue];
            switch (noOfPassengers) {
                case 0:
                    soundFilePath = [[NSBundle mainBundle] pathForResource:@"zero" ofType:@"mp3"];
                    break;
                case 1:
                    soundFilePath = [[NSBundle mainBundle] pathForResource:@"one" ofType:@"mp3"];
                    break;
                case 2:
                    soundFilePath = [[NSBundle mainBundle] pathForResource:@"two" ofType:@"mp3"];
                    break;
                case 3:
                    soundFilePath = [[NSBundle mainBundle] pathForResource:@"three" ofType:@"mp3"];
                    break;
                case 4:
                    soundFilePath = [[NSBundle mainBundle] pathForResource:@"four" ofType:@"mp3"];
                    break;
                case 5:
                    soundFilePath = [[NSBundle mainBundle] pathForResource:@"five" ofType:@"mp3"];
                    break;
                case 6:
                    soundFilePath = [[NSBundle mainBundle] pathForResource:@"six" ofType:@"mp3"];
                    break;
                case 7:
                    soundFilePath = [[NSBundle mainBundle] pathForResource:@"seven" ofType:@"mp3"];
                    break;
                case 8:
                    soundFilePath = [[NSBundle mainBundle] pathForResource:@"eight" ofType:@"mp3"];
                    break;
                case 9:
                    soundFilePath = [[NSBundle mainBundle] pathForResource:@"nine" ofType:@"mp3"];
                    break;
                default:
                    soundFilePath = nil;
                    break;
            }

            [noOfPassengersPerStop removeObjectAtIndex:i];
            if (soundFilePath != nil) {
                NSURL *soundFileURL = [NSURL fileURLWithPath:soundFilePath];
                _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFileURL error:nil];
                _audioPlayer.numberOfLoops = 0;
                [_audioPlayer play];
            }
        }
    }
}

//- (void) openGoogleMap {
//    NSString *latlong = [NSString stringWithFormat:@"%lf,%lf", mLatitude, mLongitude];
//    NSString *url = [NSString stringWithFormat: @"http://maps.google.com/maps?ll=%@",
//                     [latlong stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
//    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
//}

- (void)toCharterMenu {
    [self stopPollingLocation];
    [self stopCheckingProximity];
    [self stopCameraFollowing];
    [self stopSendingDataPeriodically];
    [self performSegueWithIdentifier:@"toCharter" sender:self];
}

/* Bluetooth Reader - START*/
- (void)pairWithDevice {
    NSData *archivedDevice = [userPrefs objectForKey:BLUETOOTH_ADDRESS];
    deviceUUID = [NSKeyedUnarchiver unarchiveObjectWithData:archivedDevice];
    deviceName = [userPrefs stringForKey:BLUETOOTH_NAME];
    [self centralManagerDidUpdateState:_bluetoothManager];
//    NSArray<CBPeripheral *> *deviceArray = [_bluetoothManager retrievePeripheralsWithIdentifiers:deviceAddress];
//    NSLog(@"%@", deviceArray);
    
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    NSString *stateString = nil;
    switch(central.state)
    {
        case CBManagerStateResetting:
            NSLog(@"The connection with the system service was momentarily lost, update imminent.");
            break;
        case CBManagerStateUnsupported:
            stateString = @"The platform doesn't support Bluetooth Low Energy.";
            break;
        case CBManagerStateUnauthorized:
            stateString = @"The app is not authorized to use Bluetooth Low Energy.";
            break;
        case CBManagerStatePoweredOff:
            stateString = @"Bluetooth is currently powered off.";
            break;
        case CBManagerStatePoweredOn:
            [_bluetoothManager scanForPeripheralsWithServices:nil options:[NSDictionary dictionaryWithObjectsAndKeys:@NO, CBCentralManagerScanOptionAllowDuplicatesKey, nil]];
            break;
        default:
            NSLog(@"State unknown, update imminent.");
            break;
    }
    if (stateString != nil) {
        [self alertStatus:stateString :@"Bluetooth status"];
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI {
    NSString *peripheralName = [peripheral name];
    NSUUID *peripheralUUID = [peripheral identifier];
    
    if ([peripheralName isEqualToString:deviceName]) {
        if (peripheralUUID != deviceUUID) {
            NSLog(@"UUID has changed. But will still attempt to connect");
        }
        device = peripheral;
        [_bluetoothManager stopScan];
        [_bluetoothManager connectPeripheral:device options:nil];
    }
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    [_bluetoothReaderManager detectReaderWithPeripheral:device];
}

- (void)bluetoothReaderManager:(ABTBluetoothReaderManager *)bluetoothReaderManager didDetectReader:(ABTBluetoothReader *)reader peripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    if (error == nil) {
        _bluetoothReader = reader;
        _bluetoothReader.delegate = self;
        [_bluetoothReader attachPeripheral:device];
    } else {
        NSLog(@"%@", error);
        [self showDefaultBluetoothErrorMessage];
    }
}

- (void)bluetoothReader:(ABTBluetoothReader *)bluetoothReader didAttachPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    if (error == nil) {
        ABTAcr1255uj1Reader *ar1255uj1Reader = (ABTAcr1255uj1Reader *) _bluetoothReader;
        NSData *masterKey = [ABDHex byteArrayFromHexString:MASTER_KEY];
        [ar1255uj1Reader authenticateWithMasterKey:masterKey];
        if ([lang isEqualToString:@"EN"]) {
            UIAlertController * alertView = [UIAlertController
                                             alertControllerWithTitle:@"Permission Request"
                                             message:@"You have selected External NFC card reading. Tap Yes to proceed with bluetooth linking."
                                             preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okButton = [UIAlertAction
                                       actionWithTitle:@"Yes!"
                                       style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction * action) {
                                           uint8_t command[] = { 0xE0, 0x00, 0x00, 0x40, 0x01 };
                                           [ar1255uj1Reader transmitEscapeCommand:command length:sizeof(command)];
                                       }];
            
            UIAlertAction *noButton = [UIAlertAction
                                       actionWithTitle:@"No. I do not wish to use a reader."
                                       style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction * action) {
                                           [self alertStatus:@"Now proceeding with normal tracking with no card reading. Please restart app if you wish to link the device." :@"Tracking status"];
                                       }];
            [alertView addAction:okButton];
            [alertView addAction:noButton];
            [self presentViewController:alertView animated:YES completion:nil];
        } else if ([lang isEqualToString:@"CH"]) {
            UIAlertController * alertView = [UIAlertController
                                             alertControllerWithTitle:@"请求"
                                             message:@"点击'OK'进行蓝牙配对"
                                             preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okButton = [UIAlertAction
                                       actionWithTitle:@"OK!"
                                       style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction * action) {
                                           uint8_t command[] = { 0xE0, 0x00, 0x00, 0x40, 0x01 };
                                           [ar1255uj1Reader transmitEscapeCommand:command length:sizeof(command)];
                                       }];
            
            UIAlertAction *noButton = [UIAlertAction
                                       actionWithTitle:@"我不想用NFC"
                                       style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction * action) {
                                           [self alertStatus:@"已经注意到您的要求。 如果你想进行蓝牙配对，请重新启动应用程序。" :@"Tracking status"];
                                       }];
            [alertView addAction:okButton];
            [alertView addAction:noButton];
            [self presentViewController:alertView animated:YES completion:nil];
        }
    } else {
        NSLog(@"%@", error);
        [self showDefaultBluetoothErrorMessage];
    }
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"%@", error);
    [self showDefaultBluetoothErrorMessage];
}

- (void)bluetoothReader:(ABTBluetoothReader *)bluetoothReader didChangeCardStatus:(ABTBluetoothReaderCardStatus)cardStatus error:(NSError *)error {
    NSString *btStatus = [self ABD_stringFromCardStatus:cardStatus];

    if ([btStatus isEqualToString:@"Present"]) {
        NSData *apdu1 = [ABDHex byteArrayFromHexString:APDU1];
        [_bluetoothReader transmitApdu:apdu1];
        hasSentApdu1 = TRUE;
    } else if ([btStatus isEqualToString:@"Absent"]) {
        hasSentApdu1 = FALSE;
    }
}

- (void)bluetoothReader:(ABTBluetoothReader *)bluetoothReader didReturnResponseApdu:(NSData *)apdu error:(NSError *)error {
    if (hasSentApdu1) {
        NSData *apdu2 = [ABDHex byteArrayFromHexString:APDU2];
        [_bluetoothReader transmitApdu:apdu2];
        hasSentApdu1 = FALSE;
    } else {
        NSString *result = [ABDHex hexStringFromByteArray:apdu];
        result = [result stringByReplacingOccurrencesOfString:@" " withString:@""];
        
//        NSData *byteResult = [ABDHex byteArrayFromHexString:result];
//        NSUInteger byteResultSize = byteResult.length;
//        byteResultSize = byteResultSize - 2;
//        
//        uint8_t *readBytes = (uint8_t *)[byteResult bytes];
//        _outputStream = [[NSOutputStream alloc] initToMemory];
//        [_outputStream open];
//        [_outputStream write:readBytes maxLength:byteResultSize];
//        NSData *purseBuff = [_outputStream propertyForKey:NSStreamDataWrittenToMemoryStreamKey];
//        [_outputStream close];
//
//        uint8_t *extractBytes = (uint8_t *)[purseBuff bytes];
//        NSString *canId = [ABDHex hexStringFromByteArray:extractBytes length:8];
        
        NSString *canId = nil;
        @try {
            canId = [result substringWithRange:NSMakeRange(16, 16)];
        } @catch (NSException *exception) {
            //do nothing
        }
        NSLog(@"%@", canId);
        if (canId == nil) {
            [self authenticationAlert:@"unknown.png" :@"unknown"];
            [self nameDisplay:@"Error" :@"Please tap again."];
        } else {
            if ([self checkPassenger:canId]) {
                [self authenticationAlert:@"ok.png" :@"correct"];
                [self nameDisplay:passengerName :passengerGender];
            } else {
                [self authenticationAlert:@"wrong.png" :@"failure"];
                if ([lang isEqualToString:@"EN"]) {
                    [self nameDisplay:@"Unknown" :@"Unable to identify passenger!"];
                } else if ([lang isEqualToString:@"CH"]) {
                    [self nameDisplay:@"未知的乘客" :@"无法识别乘客！"];
                }
            }
        }
    }
}

- (void)showDefaultBluetoothErrorMessage {
    if ([lang isEqualToString:@"EN"]) {
        UIAlertController * alertView = [UIAlertController
                                         alertControllerWithTitle:@"Error!"
                                         message:@"Unable to connect to stored device! Please pair with a new NFC device or select 'No NFC' to proceed with tracking"
                                         preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okButton = [UIAlertAction
                                   actionWithTitle:@"Got it"
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * action) {
                                       [self performSegueWithIdentifier:@"goToSettings" sender:self];
                                   }];
        [alertView addAction:okButton];
        [self presentViewController:alertView animated:YES completion:nil];
    } else if ([lang isEqualToString:@"CH"]) {
        UIAlertController * alertView = [UIAlertController
                                         alertControllerWithTitle:@""
                                         message:@"无法找到之前匹配的设备。请选择新的设备或重启NFC设备和定位系统。"
                                         preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okButton = [UIAlertAction
                                   actionWithTitle:@"OK"
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * action) {
                                       [self performSegueWithIdentifier:@"goToSettings" sender:self];
                                   }];
        [alertView addAction:okButton];
        [self presentViewController:alertView animated:YES completion:nil];
    }
}

- (NSString *)ABD_stringFromCardStatus:(ABTBluetoothReaderCardStatus)cardStatus {
    
    NSString *string = nil;
    
    switch (cardStatus) {
            
        case ABTBluetoothReaderCardStatusUnknown:
            string = @"Unknown";
            break;
            
        case ABTBluetoothReaderCardStatusAbsent:
            string = @"Absent";
            break;
            
        case ABTBluetoothReaderCardStatusPresent:
            string = @"Present";
            break;
            
        case ABTBluetoothReaderCardStatusPowered:
            string = @"Powered";
            break;
            
        case ABTBluetoothReaderCardStatusPowerSavingMode:
            string = @"Power Saving Mode";
            break;
            
        default:
            string = @"Unknown";
            break;
    }
    
    return string;
}

/* Bluetooth Reader - END*/

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)alertStatus:(NSString *)msg :(NSString *)title {
    UIAlertController *alertView = [UIAlertController alertControllerWithTitle:title
                                                                    message:msg
                                                                    preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *aCloseAlertView = [UIAlertAction
                                  actionWithTitle:@"OK"
                                  style:UIAlertActionStyleDefault
                                  handler:^(UIAlertAction * action) {
                                      [self dismissViewControllerAnimated:YES completion:nil];
                                  }];
    [alertView addAction:aCloseAlertView];
    [self presentViewController:alertView animated:YES completion:nil];
}

-(void)hideAuthenticationAlert {
    [self performSelector:@selector(dismissAuthenticationAlert:) withObject:passengerAlert afterDelay:1];
}

-(void)dismissAuthenticationAlert:(UIAlertView *) alertView {
    [passengerAlert close];
}

-(void)viewPassengerDetails {
    DetailsViewController *details = [[DetailsViewController alloc] init];
    details.modalPresentationStyle = UIModalPresentationPopover;
    details.preferredContentSize = CGSizeMake([[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height - 150);
    
    UIPopoverPresentationController *popover = details.popoverPresentationController;
    popover.delegate = self;
    popover.sourceView = self.view;
    popover.sourceRect = CGRectMake([[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height, 1, 1);
    popover.permittedArrowDirections = UIPopoverArrowDirectionAny;
    
    [self presentViewController:details animated:YES completion:nil];
}

- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller {
    return UIModalPresentationNone;
}

- (void)authenticationAlert:(NSString *)imagePath :(NSString *)soundPath {
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
    UIImage *image = [UIImage imageNamed:imagePath];
    imageView.contentMode=UIViewContentModeCenter;
    [imageView setImage:image];
    
    passengerAlert = [[CustomIOSAlertView alloc] init];
    [passengerAlert setButtonTitles: nil];
    [passengerAlert setContainerView:imageView];
    [passengerAlert show];
    
    NSString *soundFilePath = [[NSBundle mainBundle] pathForResource:soundPath ofType:@"mp3"];
    NSURL *soundFileURL = [NSURL fileURLWithPath:soundFilePath];
    _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFileURL error:nil];
    _audioPlayer.numberOfLoops = 0;
    [_audioPlayer play];
    [self hideAuthenticationAlert];
}

- (void)nameDisplay:(NSString *)name : (NSString *)gender {
    NSString *particulars = [NSString stringWithFormat:@"%@, %@", name, gender];
    [[[[iToast makeText:particulars] setFontSize:15] setGravity:iToastGravityBottom] show];
}

@end
