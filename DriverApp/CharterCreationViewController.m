//
//  DriverApp
//
//  Created by KangJie Lim on 1/8/17.
//  Copyright © 2017 Commute-Solutions. All rights reserved.
//

#import "CharterCreationViewController.h"
#import <GoogleMaps/GoogleMaps.h>
#import <GooglePlaces/GooglePlaces.h>

@interface CharterCreationViewController () <GMSAutocompleteViewControllerDelegate>
@property (strong, nonatomic) GMSMapView *charterMapView;

@end

@implementation CharterCreationViewController
static int controllerId = 0;
NetworkUtility *reachability;
NetworkStatus status;
NSUserDefaults *userPrefs;
NSString *token;
NSString *role;
CLLocationManager *locationManager;
GMSAutocompleteFilter *countryFilter;

UILabel *startLocation;
UILabel *endLocation;
UILabel *lblDate;
UILabel *lblPickupTime;
UILabel *lblDropOffTime;
UILabel *lblVehicleCapacity;
UILabel *lblVehicleQuantity;
UILabel *lblCost;
UIView *viewDetailBackground;
UIView *viewReturnTime;
UIImageView *oneWayImgView;
UIImageView *twoWayImgView;
UIImageView *disposalImgView;
UIButton *btnSetReturnTime;
bool isPickupTime;

NSString *numOfOnlineUsers;
NSString *currentView;
NSString *costInString;
NSString *disposalHrsInString;
NSString *serviceType;
UIAlertAction *aSetCost;
UIAlertAction *aSetDisposalHrs;

GMSMarker *pickupMarker;
GMSMarker *dropoffMarker;

NSString *startLocationString;
NSString *endLocationString;
double startLat;
double startLon;
double endLat;
double endLon;
NSString *dateInString;
NSString *pickUpTime;
NSString *dropOffTime;
NSString *pickupTimeInString;
NSString *returnTimeInString;
int busType;
int busQty;
NSString *remarks;
int expiryHrs;

- (void)loadView {
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[[UIView alloc] init]];
    self.navigationItem.title = @"Create Charter";
    
    UIBarButtonItem *btnSideMenu = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(showHideButtonsAction)];
    [btnSideMenu setTintColor:[UIColor whiteColor]];
    self.navigationItem.rightBarButtonItem = btnSideMenu;
    
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    reachability = [NetworkUtility reachabilityForInternetConnection];
    [locationManager requestWhenInUseAuthorization];
    [locationManager requestAlwaysAuthorization];
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:1.390910
                                                            longitude:103.820629
                                                                 zoom:12];
    _charterMapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    _charterMapView.indoorEnabled = NO;
    _charterMapView.myLocationEnabled = NO;
    if (locationManager == nil) {
        locationManager = [[CLLocationManager alloc]init];
    }
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
    
    countryFilter = [[GMSAutocompleteFilter alloc] init];
    countryFilter.country = @"SG";

    self.view = _charterMapView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    userPrefs = [NSUserDefaults standardUserDefaults];
    token = [userPrefs stringForKey:AUTHENTICATION_TOKEN];
    role = [userPrefs stringForKey:ROLE];
    
    [self initialiseValues];
    if ([role isEqualToString:@"driver"]) {
        [self performSegueWithIdentifier:@"toTracker" sender:self];
    } else {
        [userPrefs setObject:@"charter" forKey:LAST_SAVED_STATE];
        [userPrefs synchronize];
        
        [reachability startNotifier];
        status = [reachability currentReachabilityStatus];
        
        CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
        CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
        
        //Start/End Background
        UIImage *ivStartEndBackground = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"addcharter_top" ofType:@"png"]];
        UIImageView* imgView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 70, screenWidth - 20, 110)];
        imgView.image = ivStartEndBackground;
        [self.view addSubview:imgView];
        
        //Start Location
        startLocation = [[UILabel alloc] initWithFrame:CGRectMake(66, 85, screenWidth - 93, 33)];
        [startLocation setBackgroundColor:[UIColor whiteColor]];
        [startLocation setText:@"  Please choose a pickup point"];
        [startLocation setTextColor:[UIColor grayColor]];
        [startLocation setFont: [UIFont fontWithName:@"HelveticaNeue" size:13]];
        [startLocation setLineBreakMode:NSLineBreakByTruncatingTail];
        [startLocation setNumberOfLines:1];
        startLocation.layer.masksToBounds = YES;
        startLocation.layer.cornerRadius = 12;
        UIButton *btnStartLocation = [UIButton buttonWithType:UIButtonTypeCustom];
        btnStartLocation.frame = CGRectMake(66, 85, screenWidth - 93, 33);
        [btnStartLocation addTarget:self action:@selector(setPickupLocation:) forControlEvents:UIControlEventTouchDown];
        [self.view addSubview:startLocation];
        [self.view addSubview:btnStartLocation];
        
        //End Location
        endLocation = [[UILabel alloc] initWithFrame:CGRectMake(66, 128, screenWidth - 93, 33)];
        [endLocation setBackgroundColor:[UIColor whiteColor]];
        [endLocation setText:@"  Please choose a drop off point"];
        [endLocation setTextColor:[UIColor grayColor]];
        [endLocation setFont: [UIFont fontWithName:@"HelveticaNeue" size:13]];
        [endLocation setLineBreakMode:NSLineBreakByTruncatingTail];
        [endLocation setNumberOfLines:1];
        endLocation.layer.masksToBounds = YES;
        endLocation.layer.cornerRadius = 12;
        UIButton *btnEndLocation = [UIButton buttonWithType:UIButtonTypeCustom];
        btnEndLocation.frame = CGRectMake(66, 128, screenWidth - 93, 33);
        [btnEndLocation addTarget:self action:@selector(setDropoffLocation:) forControlEvents:UIControlEventTouchDown];
        [self.view addSubview:endLocation];
        [self.view addSubview:btnEndLocation];
        
        //Mode Select
        UIView *modeBackground = [[UIView alloc] initWithFrame:CGRectMake(10, 170, screenWidth - 20, 40)];
        [modeBackground setBackgroundColor:UIColorFromRGB(0xF2F1EF)];
        
        UIImage *ivOneWay = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"oneway_icon" ofType:@"png"]];
        oneWayImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, modeBackground.bounds.size.width / 3, modeBackground.bounds.size.height)];
        [oneWayImgView setImage:ivOneWay];
        [oneWayImgView setContentMode:UIViewContentModeScaleAspectFit];
        [oneWayImgView.layer setBorderColor: [[UIColor orangeColor] CGColor]];
        [oneWayImgView.layer setBorderWidth:0.5];
        UIButton *btnSetToOneWay = [UIButton buttonWithType:UIButtonTypeCustom];
        btnSetToOneWay.frame = CGRectMake(0, 0, modeBackground.bounds.size.width / 3, modeBackground.bounds.size.height);
        [btnSetToOneWay addTarget:self action:@selector(isOneWay:) forControlEvents:UIControlEventTouchDown];
        [modeBackground addSubview:oneWayImgView];
        [modeBackground addSubview:btnSetToOneWay];
        
        UIImage *ivTwoWay = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"twoway_icon" ofType:@"png"]];
        twoWayImgView = [[UIImageView alloc] initWithFrame:CGRectMake(modeBackground.bounds.size.width / 3, 0, modeBackground.bounds.size.width / 3, modeBackground.bounds.size.height)];
        [twoWayImgView setImage:ivTwoWay];
        [twoWayImgView setContentMode:UIViewContentModeScaleAspectFit];
        [twoWayImgView.layer setBorderColor: [[UIColor orangeColor] CGColor]];
        [twoWayImgView.layer setBorderWidth:0.5];
        UIButton *btnSetToTwoWay = [UIButton buttonWithType:UIButtonTypeCustom];
        btnSetToTwoWay.frame = CGRectMake(modeBackground.bounds.size.width / 3, 0, modeBackground.bounds.size.width / 3, modeBackground.bounds.size.height);
        [btnSetToTwoWay addTarget:self action:@selector(isTwoWay:) forControlEvents:UIControlEventTouchDown];
        [modeBackground addSubview:twoWayImgView];
        [modeBackground addSubview:btnSetToTwoWay];
        
        UIImage *ivDisposal = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"disposal_icon" ofType:@"png"]];
        disposalImgView = [[UIImageView alloc] initWithFrame:CGRectMake((modeBackground.bounds.size.width / 3) * 2, 0, modeBackground.bounds.size.width / 3, modeBackground.bounds.size.height)];
        [disposalImgView setImage:ivDisposal];
        [disposalImgView setContentMode:UIViewContentModeScaleAspectFit];
        [disposalImgView.layer setBorderColor: [[UIColor orangeColor] CGColor]];
        [disposalImgView.layer setBorderWidth:0.5];
        UIButton *btnSetToDisposal = [UIButton buttonWithType:UIButtonTypeCustom];
        btnSetToDisposal.frame = CGRectMake((modeBackground.bounds.size.width / 3) * 2, 0, modeBackground.bounds.size.width / 3, modeBackground.bounds.size.height);
        [btnSetToDisposal addTarget:self action:@selector(isDisposal:) forControlEvents:UIControlEventTouchDown];
        [modeBackground addSubview:disposalImgView];
        [modeBackground addSubview:btnSetToDisposal];
        
        [self.view addSubview:modeBackground];
        
        //Online Users
        UIView *viewOnlineUsers = [[UIView alloc] initWithFrame:CGRectMake(10, 210, screenWidth - 20, 40)];
        [viewOnlineUsers setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.0]];
        UIImage *ivOnline = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"signal_green" ofType:@"png"]];
        UIImageView *onlineUserImgView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 15, 15)];
        [onlineUserImgView setImage:ivOnline];
        [onlineUserImgView setContentMode:UIViewContentModeScaleAspectFit];
        UITextView *txtOnlineUsers = [[UITextView alloc] initWithFrame:CGRectMake(20, -2, viewOnlineUsers.bounds.size.width / 2, viewOnlineUsers.bounds.size.height)];
        [txtOnlineUsers setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.0]];
        [txtOnlineUsers setText:[@"Users Online: " stringByAppendingString:numOfOnlineUsers]];
        [txtOnlineUsers setEditable:NO];
        [viewOnlineUsers addSubview:onlineUserImgView];
        [viewOnlineUsers addSubview:txtOnlineUsers];
         
        [self.view addSubview:viewOnlineUsers];
        
        //Add Charter
        UIView *viewAddCharter = [[UIView alloc] initWithFrame:CGRectMake(screenWidth - 100, (screenHeight / 2) + 33, 90, 90)];
        UIImage *ivAddCharter = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"add_charter" ofType:@"png"]];
        UIImageView *addCharterImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, viewAddCharter.bounds.size.width, viewAddCharter.bounds.size.height)];
        [addCharterImgView setImage:ivAddCharter];
        [viewAddCharter addSubview:addCharterImgView];
        UIButton *btnAddCharter = [UIButton buttonWithType:UIButtonTypeCustom];
        btnAddCharter.frame = CGRectMake(0, 0, viewAddCharter.bounds.size.width, viewAddCharter.bounds.size.height);
        [btnAddCharter addTarget:self action:@selector(addCharter:) forControlEvents:UIControlEventTouchDown];
        [viewAddCharter addSubview:btnAddCharter];
        
        [self.view addSubview:viewAddCharter];
        
        //Details Background
        viewDetailBackground = [[UIView alloc] initWithFrame:CGRectMake(10, screenHeight - 160, screenWidth - 20, 150)];
        [viewDetailBackground setBackgroundColor:UIColorFromRGB(0xF2F1EF)];
        
        //Date
        UIView *viewDate = [[UIView alloc] initWithFrame:CGRectMake(0, 0, viewDetailBackground.bounds.size.width / 3, 75)];
        [viewDate.layer setBorderColor: [[UIColor orangeColor] CGColor]];
        [viewDate.layer setBorderWidth:0.5];
        UIImage *ivDate = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"date_signage" ofType:@"png"]];
        UIImageView *dateImgView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 5, viewDate.bounds.size.height / 2 , viewDate.bounds.size.height / 2)];
        [dateImgView setImage:ivDate];
        [viewDate addSubview:dateImgView];
        lblDate = [[UILabel alloc] initWithFrame:CGRectMake(5, (viewDate.bounds.size.height / 2) + 5, viewDate.bounds.size.width - 5, viewDate.bounds.size.height / 2)];
        [lblDate setText:[NSString stringWithFormat:@"  %@", @"Select Date"]];
        [lblDate setFont: [UIFont fontWithName:@"HelveticaNeue" size:14]];
        [lblDate setTextColor:[UIColor grayColor]];
        [viewDate addSubview:lblDate];
        UIButton *btnSetDate = [UIButton buttonWithType:UIButtonTypeCustom];
        btnSetDate.frame = CGRectMake(0, 0, viewDetailBackground.bounds.size.width / 3, 75);
        [btnSetDate addTarget:self action:@selector(openDatePicker:) forControlEvents:UIControlEventTouchDown];
        [viewDate addSubview:btnSetDate];
        [viewDetailBackground addSubview:viewDate];
        
        //Pick Up Time
        UIView *viewPickupTime = [[UIView alloc] initWithFrame:CGRectMake(viewDetailBackground.bounds.size.width / 3, 0, viewDetailBackground.bounds.size.width / 3, 75)];
        [viewPickupTime.layer setBorderColor: [[UIColor orangeColor] CGColor]];
        [viewPickupTime.layer setBorderWidth:0.5];
        UIImage *ivTime = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"time_signage" ofType:@"png"]];
        UIImageView *timeImgView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 5, viewPickupTime.bounds.size.height / 2 , viewPickupTime.bounds.size.height / 2)];
        [timeImgView setImage:ivTime];
        [viewPickupTime addSubview:timeImgView];
        lblPickupTime = [[UILabel alloc] initWithFrame:CGRectMake(5, (viewPickupTime.bounds.size.height / 2) + 5, viewPickupTime.bounds.size.width - 5, viewPickupTime.bounds.size.height / 2)];
        [lblPickupTime setText:[NSString stringWithFormat:@"  %@", @"PickUp Time"]];
        [lblPickupTime setFont: [UIFont fontWithName:@"HelveticaNeue" size:14]];
        [lblPickupTime setTextColor:[UIColor grayColor]];
        [viewPickupTime addSubview:lblPickupTime];
        UIButton *btnSetPickupTime = [UIButton buttonWithType:UIButtonTypeCustom];
        btnSetPickupTime.frame = CGRectMake(0, 0, viewDetailBackground.bounds.size.width / 3, 75);
        [btnSetPickupTime addTarget:self action:@selector(openPickupTimePicker:) forControlEvents:UIControlEventTouchDown];
        [viewPickupTime addSubview:btnSetPickupTime];
        [viewDetailBackground addSubview:viewPickupTime];
        
        //Drop Off Time
        viewReturnTime = [[UIView alloc] initWithFrame:CGRectMake((viewDetailBackground.bounds.size.width / 3) * 2, 0, viewDetailBackground.bounds.size.width / 3, 75)];
        [viewReturnTime.layer setBorderColor: [[UIColor orangeColor] CGColor]];
        [viewReturnTime.layer setBorderWidth:0.5];
        UIImage *ivTime2 = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"time_signage" ofType:@"png"]];
        UIImageView *timeImgView2 = [[UIImageView alloc] initWithFrame:CGRectMake(10, 5, viewReturnTime.bounds.size.height / 2 , viewReturnTime.bounds.size.height / 2)];
        [timeImgView2 setImage:ivTime2];
        [viewReturnTime addSubview:timeImgView2];
        lblDropOffTime = [[UILabel alloc] initWithFrame:CGRectMake(5, (viewReturnTime.bounds.size.height / 2) + 5, viewReturnTime.bounds.size.width - 5, viewReturnTime.bounds.size.height / 2)];
        [lblDropOffTime setText:[NSString stringWithFormat:@"  %@", @"Return Time"]];
        [lblDropOffTime setFont: [UIFont fontWithName:@"HelveticaNeue" size:14]];
        [lblDropOffTime setTextColor:[UIColor grayColor]];
        [viewReturnTime addSubview:lblDropOffTime];
        btnSetReturnTime = [UIButton buttonWithType:UIButtonTypeCustom];
        btnSetReturnTime.frame = CGRectMake(0, 0, viewDetailBackground.bounds.size.width / 3, 75);
        [btnSetReturnTime addTarget:self action:@selector(openReturnTimePicker:) forControlEvents:UIControlEventTouchDown];
        [viewReturnTime addSubview:btnSetReturnTime];
        [viewDetailBackground addSubview:viewReturnTime];
        
        //Vehicle Capacity
        UIView *viewVehicleCapacity = [[UIView alloc] initWithFrame:CGRectMake(0, viewDetailBackground.bounds.size.height / 2, viewDetailBackground.bounds.size.width / 3, 75)];
        [viewVehicleCapacity.layer setBorderColor: [[UIColor orangeColor] CGColor]];
        [viewVehicleCapacity.layer setBorderWidth:0.5];
        UIImage *ivBusCapacity = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"buscapacity_icon" ofType:@"png"]];
        UIImageView *busCapacityImgView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 5, viewVehicleCapacity.bounds.size.height / 2 , viewVehicleCapacity.bounds.size.height / 2)];
        [busCapacityImgView setImage:ivBusCapacity];
        [viewVehicleCapacity addSubview:busCapacityImgView];
        lblVehicleCapacity = [[UILabel alloc] initWithFrame:CGRectMake(5, (viewReturnTime.bounds.size.height / 2) + 5, viewReturnTime.bounds.size.width - 5, viewReturnTime.bounds.size.height / 2)];
        [lblVehicleCapacity setText:[NSString stringWithFormat:@"  %@", @"Select Bus"]];
        [lblVehicleCapacity setFont: [UIFont fontWithName:@"HelveticaNeue" size:14]];
        [lblVehicleCapacity setTextColor:[UIColor grayColor]];
        [viewVehicleCapacity addSubview:lblVehicleCapacity];
        UIButton *btnVehicleCapacity = [UIButton buttonWithType:UIButtonTypeCustom];
        btnVehicleCapacity.frame = CGRectMake(0, 0, viewDetailBackground.bounds.size.width / 3, 75);
        [btnVehicleCapacity addTarget:self action:@selector(openBusCapacitySelection:) forControlEvents:UIControlEventTouchDown];
        [viewVehicleCapacity addSubview:btnVehicleCapacity];
        [viewDetailBackground addSubview:viewVehicleCapacity];
        
        //Vehicle Quantity
        UIView *viewVehicleQuantity = [[UIView alloc] initWithFrame:CGRectMake(viewDetailBackground.bounds.size.width / 3, viewDetailBackground.bounds.size.height / 2, viewDetailBackground.bounds.size.width / 3, 75)];
        [viewVehicleQuantity.layer setBorderColor: [[UIColor orangeColor] CGColor]];
        [viewVehicleQuantity.layer setBorderWidth:0.5];
        UIImage *ivBusQuantity = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"busquantity_icon" ofType:@"png"]];
        UIImageView *busQuantityImgView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 5, viewVehicleQuantity.bounds.size.height / 2 , viewVehicleQuantity.bounds.size.height / 2)];
        [busQuantityImgView setImage:ivBusQuantity];
        [viewVehicleQuantity addSubview:busQuantityImgView];
        lblVehicleQuantity = [[UILabel alloc] initWithFrame:CGRectMake(5, (viewReturnTime.bounds.size.height / 2) + 5, viewReturnTime.bounds.size.width - 5, viewReturnTime.bounds.size.height / 2)];
        [lblVehicleQuantity setText:@" 1 bus"];
        [lblVehicleQuantity setFont: [UIFont fontWithName:@"HelveticaNeue" size:14]];
        [viewVehicleQuantity addSubview:lblVehicleQuantity];
        RPVerticalStepper *stepper = [[RPVerticalStepper alloc] initWithFrame:CGRectMake(viewVehicleQuantity.bounds.size.width - 40, 7, 20, viewVehicleQuantity.bounds.size.height)];
        [stepper setValue:1.0f];
        [stepper setMinimumValue:1.0f];
        [stepper setMaximumValue:9.0f];
        [stepper setStepValue:1.0f];
        [stepper setAutoRepeat:YES];
        [stepper setAutoRepeatInterval:0.5f];
        stepper.delegate = self;
        [viewVehicleQuantity addSubview:stepper];
        [viewDetailBackground addSubview:viewVehicleQuantity];
        
        //Cost
        UIView *viewCost = [[UIView alloc] initWithFrame:CGRectMake((viewDetailBackground.bounds.size.width / 3) * 2, viewDetailBackground.bounds.size.height / 2, viewDetailBackground.bounds.size.width / 3, 75)];
        [viewCost.layer setBorderColor: [[UIColor orangeColor] CGColor]];
        [viewCost.layer setBorderWidth:0.5];
        UIImage *ivCost = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"cost_icon" ofType:@"png"]];
        UIImageView *costImgView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 5, viewCost.bounds.size.height / 2 , viewCost.bounds.size.height / 2)];
        [costImgView setImage:ivCost];
        [viewCost addSubview:costImgView];
        lblCost = [[UILabel alloc] initWithFrame:CGRectMake(5, (viewCost.bounds.size.height / 2) + 5, viewCost.bounds.size.width - 5, viewCost.bounds.size.height / 2)];
        [lblCost setText:[NSString stringWithFormat:@"  %@", @"Enter cost"]];
        [lblCost setFont: [UIFont fontWithName:@"HelveticaNeue" size:14]];
        [lblCost setTextColor:[UIColor grayColor]];
        [viewCost addSubview:lblCost];
        UIButton *btnCost = [UIButton buttonWithType:UIButtonTypeCustom];
        btnCost.frame = CGRectMake(0, 0, viewDetailBackground.bounds.size.width / 3, 75);
        [btnCost addTarget:self action:@selector(enterCostAlert:) forControlEvents:UIControlEventTouchDown];
        [viewCost addSubview:btnCost];
        [viewDetailBackground addSubview:viewCost];
        
        [self.view addSubview:viewDetailBackground];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [self isOneWay:self];
    
    if ([role isEqualToString:@"omo"]) {
        _navBar = [LGPlusButtonsView plusButtonsViewWithNumberOfButtons:8
                                                firstButtonIsPlusButton:NO
                                                          showAfterInit:NO
                                                          actionHandler:^(LGPlusButtonsView *plusButtonView, NSString *title, NSString *description, NSUInteger index)
                   {
                       NSLog(@"actionHandler | title: %@, description: %@, index: %lu", title, description, (long unsigned)index);
                       if (index == 1) {
                           [self performSegueWithIdentifier:@"toViewAvailableCharter" sender:self];
                       } else if (index == 2) {
                           [self performSegueWithIdentifier:@"toJobs" sender:@"subout"];
                       } else if (index == 3) {
                           [self performSegueWithIdentifier:@"toJobs" sender:@"scheduled"];
                       } else if (index == 4) {
                           [self performSegueWithIdentifier:@"toTracker" sender:self];
                       } else if (index == 5) {
                           [self performSegueWithIdentifier:@"toDispute" sender:self];
                       } else if (index == 6) {
                           [self performSegueWithIdentifier:@"toCreateContract" sender:self];
                       } else if (index == 7) {
                           [self performSegueWithIdentifier:@"toProfile" sender:self];
                       }
                   }];
        
        _navBar.showHideOnScroll = NO;
        _navBar.appearingAnimationType = LGPlusButtonsAppearingAnimationTypeCrossDissolveAndPop;
        _navBar.position = LGPlusButtonsViewPositionRightTop;
        
        NSArray *btnImageArray = @[[NSNull new], [UIImage imageNamed:@"availablecharterlist"], [UIImage imageNamed:@"mycharter"], [UIImage imageNamed:@"successfulbids"], [UIImage imageNamed:@"totracker"], [UIImage imageNamed:@"dispute"], [UIImage imageNamed:@"viewcontractjob"], [UIImage imageNamed:@"profile"]];
        [_navBar setButtonsImages:btnImageArray forState:UIControlStateNormal forOrientation:LGPlusButtonsViewOrientationAll];
        [_navBar setDescriptionsTexts:@[@" ", @"View Available Charters", @"My Subout Jobs", @"My Scheduled Jobs", @"To Tracker", @"Disputed Charters", @"Contract Services", @"Profile"]];
    } else {
        _navBar = [LGPlusButtonsView plusButtonsViewWithNumberOfButtons:7
                                                firstButtonIsPlusButton:NO
                                                          showAfterInit:NO
                                                          actionHandler:^(LGPlusButtonsView *plusButtonView, NSString *title, NSString *description, NSUInteger index)
                   {
                       NSLog(@"actionHandler | title: %@, description: %@, index: %lu", title, description, (long unsigned)index);
                       if (index == 1) {
                           [self performSegueWithIdentifier:@"toViewAvailableCharter" sender:self];
                       } else if (index == 2) {
                           [self performSegueWithIdentifier:@"toJobs" sender:self];
                       } else if (index == 3) {
                           [self performSegueWithIdentifier:@"toJobs" sender:self];
                       } else if (index == 4) {
                           [self performSegueWithIdentifier:@"toDispute" sender:self];
                       }  else if (index == 5) {
                           [self performSegueWithIdentifier:@"toCreateContract" sender:self];
                       } else if (index == 6) {
                           [self performSegueWithIdentifier:@"toProfile" sender:self];
                       }
                   }];
        
        _navBar.showHideOnScroll = NO;
        _navBar.appearingAnimationType = LGPlusButtonsAppearingAnimationTypeCrossDissolveAndPop;
        _navBar.position = LGPlusButtonsViewPositionRightTop;
        
        NSArray *btnImageArray = @[[NSNull new], [UIImage imageNamed:@"availablecharterlist"], [UIImage imageNamed:@"mycharter"], [UIImage imageNamed:@"successfulbids"], [UIImage imageNamed:@"dispute"], [UIImage imageNamed:@"viewcontractjob"], [UIImage imageNamed:@"profile"]];
        [_navBar setButtonsImages:btnImageArray forState:UIControlStateNormal forOrientation:LGPlusButtonsViewOrientationAll];
        [_navBar setDescriptionsTexts:@[@" ", @"View Available Charters", @"My Subout Jobs", @"My Scheduled Jobs", @"Disputed Charters", @"Contract Services", @"Profile"]];
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
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        [_navBar setButtonsSize:CGSizeMake(44.f, 44.f) forOrientation:LGPlusButtonsViewOrientationLandscape];
        [_navBar setButtonsLayerCornerRadius:44.f/2.f forOrientation:LGPlusButtonsViewOrientationLandscape];
        [_navBar setButtonsTitleFont:[UIFont systemFontOfSize:24.f] forOrientation:LGPlusButtonsViewOrientationLandscape];
    }
    [self.view addSubview:_navBar];

}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString: @"toJobs"]) {
        JobsViewController *destinationController = (JobsViewController *)segue.destinationViewController;
        destinationController.identifyingProperty = sender;
    }
}

-(void)initialiseValues {
    busQty = 1;
    busType = 0;
    dateInString = @"";
    pickupTimeInString = @"";
    returnTimeInString = @"";
    disposalHrsInString = @"";
    remarks = @"";
    expiryHrs = 8;
    
    pickupMarker = [[GMSMarker alloc] init];
    UIImage *ivPickupMarker = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"green_marker" ofType:@"png"]];
    pickupMarker.icon = ivPickupMarker;
    
    dropoffMarker = [[GMSMarker alloc] init];
    UIImage *ivDropoffMarker = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"blue_marker" ofType:@"png"]];
    dropoffMarker.icon = ivDropoffMarker;
    
    [self getOnlineUsers];
}

#pragma mark - navigation bar
- (void)showHideButtonsAction {
    if (_navBar.isShowing)
        [_navBar hideAnimated:YES completionHandler:nil];
    else
        [_navBar showAnimated:YES completionHandler:nil];
}

- (void)setPickupLocation:(id)sender {
    GMSAutocompleteViewController *setPickupLocationController = [[GMSAutocompleteViewController alloc] init];
    [setPickupLocationController setAutocompleteFilter:countryFilter];
    setPickupLocationController.delegate = self;
    [self presentViewController:setPickupLocationController animated:YES completion:^{
        currentView = @"Pickup";
    }];
}

- (void)setDropoffLocation:(id)sender {
    GMSAutocompleteViewController *setDropoffLocationController = [[GMSAutocompleteViewController alloc] init];
    [setDropoffLocationController setAutocompleteFilter:countryFilter];
    setDropoffLocationController.delegate = self;
    [self presentViewController:setDropoffLocationController animated:YES completion:^{
        currentView = @"Dropoff";
    }];
}

#pragma mark - charter type
- (void)isOneWay:(id)sender {
    NSLog(@"One-Way");
    [oneWayImgView.layer setBorderWidth:2];
    [twoWayImgView.layer setBorderWidth:0.5];
    [disposalImgView.layer setBorderWidth:0.5];
    serviceType = @"oneway";
    [viewReturnTime removeFromSuperview];
}

- (void)isTwoWay:(id)sender {
    if (![serviceType isEqualToString:@"twoway"]) {
        UIAlertController *twoWayAlert = [UIAlertController alertControllerWithTitle:@"Important!"
                                                                             message:@"Please kindly note that all Two-way charters will be split into 2 x One-way charters for your convenience. Please also note that the pricing will be divided accordingly."
                                                                      preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *aAcknowledgement = [UIAlertAction
                                           actionWithTitle:@"OK"
                                           style:UIAlertActionStyleDefault
                                           handler:^(UIAlertAction * action) {
                                               NSLog(@"Two-Way");
                                               [oneWayImgView.layer setBorderWidth:0.5];
                                               [twoWayImgView.layer setBorderWidth:2];
                                               [disposalImgView.layer setBorderWidth:0.5];
                                               serviceType = @"twoway";
                                               [viewReturnTime removeFromSuperview];
                                               [viewDetailBackground addSubview:viewReturnTime];
                                               [btnSetReturnTime removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
                                               [btnSetReturnTime addTarget:self action:@selector(openReturnTimePicker:) forControlEvents:UIControlEventTouchDown];
                                               [lblDropOffTime setText:[NSString stringWithFormat:@"  %@", @"Return Time"]];
                                           }];
        [twoWayAlert addAction:aAcknowledgement];
        [self presentViewController:twoWayAlert animated:YES completion:nil];
    }
}

- (void)isDisposal:(id)sender {
    NSLog(@"Disposal");
    [oneWayImgView.layer setBorderWidth:0.5];
    [twoWayImgView.layer setBorderWidth:0.5];
    [disposalImgView.layer setBorderWidth:2];
    serviceType = @"disposal";
    [viewReturnTime removeFromSuperview];
    [viewDetailBackground addSubview:viewReturnTime];
    [btnSetReturnTime removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [btnSetReturnTime addTarget:self action:@selector(setDisposalHours:) forControlEvents:UIControlEventTouchDown];
    [lblDropOffTime setText:[NSString stringWithFormat:@" %@", @"Set Duration"]];
    [lblDropOffTime setTextColor:[UIColor grayColor]];
    
}

#pragma mark - stepper
- (void)stepperValueDidChange:(RPVerticalStepper *)stepper {
    busQty = (int) stepper.value;
    if (busQty == 1) {
        [lblVehicleQuantity setText:[NSString stringWithFormat:@" %d bus", busQty]];
    } else {
        [lblVehicleQuantity setText:[NSString stringWithFormat:@" %d buses", busQty]];
    }
}

#pragma mark - THDatePickerDelegate

- (void)datePickerDonePressed:(THDatePickerViewController *)datePicker {
    NSDate *selectedDate = datePicker.date;
    [self setCharterDate: selectedDate];
    [self dismissSemiModalView];
}

- (void)datePickerCancelPressed:(THDatePickerViewController *)datePicker {
    [self dismissSemiModalView];
}

- (void)datePicker:(THDatePickerViewController *)datePicker selectedDate:(NSDate *)selectedDate {
    [self setCharterDate: selectedDate];
}

#pragma mark - datepicker
- (void)setCharterDate:(NSDate *) date {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    dateFormatter.dateFormat = @"dd/MM/yyyy";
    dateInString = [dateFormatter stringFromDate: date];
    [lblDate setText:[NSString stringWithFormat:@"  %@", dateInString]];
    [lblDate setTextColor:[UIColor blackColor]];
}

- (void)openDatePicker:(id)sender {
    if(!self.datePicker) {
        self.datePicker = [THDatePickerViewController datePicker];
    }
    self.datePicker.date = [NSDate date];
    self.datePicker.delegate = self;
    [self.datePicker setAllowClearDate:NO];
    [self.datePicker setClearAsToday:YES];
    [self.datePicker setAutoCloseOnSelectDate:YES];
    [self.datePicker setAllowSelectionOfSelectedDate:YES];
    [self.datePicker setDisableHistorySelection:YES];
    [self.datePicker setDisableFutureSelection:NO];
    [self.datePicker setDaysInFutureSelection:90];
    [self.datePicker setAllowMultiDaySelection:NO];
    [self.datePicker setSelectedBackgroundColor:[UIColor colorWithRed:125/255.0 green:208/255.0 blue:0/255.0 alpha:1.0]];
    [self.datePicker setCurrentDateColor:[UIColor colorWithRed:242/255.0 green:121/255.0 blue:53/255.0 alpha:1.0]];
    
    [self.datePicker setDateHasItemsCallback:^BOOL(NSDate *date) {
        int tmp = (arc4random() % 30) + 1;
        if(tmp % 5 == 0) {
            return YES;
        }
        return NO;
    }];
    //[self.datePicker slideUpInView:self.view withModalColor:[UIColor lightGrayColor]];
    [self presentSemiViewController:self.datePicker withOptions:@{
                                                                  KNSemiModalOptionKeys.pushParentBack    : @(NO),
                                                                  KNSemiModalOptionKeys.animationDuration : @(0.5),
                                                                  KNSemiModalOptionKeys.shadowOpacity     : @(0.3),
                                                                  }];
}

#pragma mark - timepicker
- (void)setCharterTime:(UIDatePicker *) sender {
    NSLog(@"%@", sender.date);
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc]init];
    timeFormatter.dateFormat = @"HH:mm a";
    if (isPickupTime) {
        pickupTimeInString = [timeFormatter stringFromDate: sender.date];
        [lblPickupTime setText:[NSString stringWithFormat:@"  %@", pickupTimeInString]];
        [lblPickupTime setTextColor:[UIColor blackColor]];
    } else {
        returnTimeInString = [timeFormatter stringFromDate: sender.date];
        [lblDropOffTime setText:[NSString stringWithFormat:@"  %@", returnTimeInString]];
        [lblDropOffTime setTextColor:[UIColor blackColor]];
    }
}

- (void)openPickupTimePicker:(id)sender {
    CGRect toolbarTargetFrame = CGRectMake(0, self.view.bounds.size.height - 216 - 44, 320, 44);
    CGRect timePickerTargetFrame = CGRectMake(0, self.view.bounds.size.height - 216, 320, 216);
    isPickupTime = TRUE;
    
    UIView *darkView = [[UIView alloc] initWithFrame:self.view.bounds];
    darkView.alpha = 0;
    darkView.tag = 9;
    darkView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:darkView];
    
    UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height, 320, 44)];
    toolBar.backgroundColor = [UIColor brownColor];
    toolBar.tag = 11;
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissDateTimePicker:)];
    [toolBar setItems:[NSArray arrayWithObjects:spacer, doneButton, nil]];
    [self.view addSubview:toolBar];
    
    UIDatePicker *timePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height + 44, self.view.bounds.size.width, 216)];
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"NL"];
    timePicker.datePickerMode = UIDatePickerModeTime;
    timePicker.locale = locale;
    timePicker.tag = 10;
    [timePicker addTarget:self action:@selector(setCharterTime:) forControlEvents:UIControlEventValueChanged];
    timePicker.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:timePicker];
    
    [UIView beginAnimations:@"MoveIn" context:nil];
    toolBar.frame = toolbarTargetFrame;
    timePicker.frame = timePickerTargetFrame;
    darkView.alpha = 0.5;
    [UIView commitAnimations];
}

- (void)openReturnTimePicker:(id)sender {
    CGRect toolbarTargetFrame = CGRectMake(0, self.view.bounds.size.height - 216 - 44, 320, 44);
    CGRect timePickerTargetFrame = CGRectMake(0, self.view.bounds.size.height - 216, 320, 216);
    isPickupTime = FALSE;
    
    UIView *darkView = [[UIView alloc] initWithFrame:self.view.bounds];
    darkView.alpha = 0;
    darkView.tag = 9;
    darkView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:darkView];
    
    UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height, 320, 44)];
    toolBar.backgroundColor = [UIColor brownColor];
    toolBar.tag = 11;
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissDateTimePicker:)];
    [toolBar setItems:[NSArray arrayWithObjects:spacer, doneButton, nil]];
    [self.view addSubview:toolBar];
    
    UIDatePicker *timePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height + 44, self.view.bounds.size.width, 216)];
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"NL"];
    timePicker.datePickerMode = UIDatePickerModeTime;
    timePicker.locale = locale;
    timePicker.tag = 10;
    [timePicker addTarget:self action:@selector(setCharterTime:) forControlEvents:UIControlEventValueChanged];
    timePicker.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:timePicker];
    
    [UIView beginAnimations:@"MoveIn" context:nil];
    toolBar.frame = toolbarTargetFrame;
    timePicker.frame = timePickerTargetFrame;
    darkView.alpha = 0.5;
    [UIView commitAnimations];
}

#pragma mark - dismiss pickers
- (void)dismissDateTimePicker:(id)sender {
    CGRect toolbarTargetFrame = CGRectMake(0, self.view.bounds.size.height, 320, 44);
    CGRect dateTimePickerTargetFrame = CGRectMake(0, self.view.bounds.size.height + 44, 320, 216);
    [UIView beginAnimations:@"MoveOut" context:nil];
    [self.view viewWithTag:9].alpha = 0;
    [self.view viewWithTag:10].frame = dateTimePickerTargetFrame;
    [self.view viewWithTag:11].frame = toolbarTargetFrame;
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(removeViews:)];
    [UIView commitAnimations];
}

- (void)removeViews:(id)object {
    [[self.view viewWithTag:9] removeFromSuperview];
    [[self.view viewWithTag:10] removeFromSuperview];
    [[self.view viewWithTag:11] removeFromSuperview];
}

#pragma mark - busType selection
- (void)openBusCapacitySelection:(id)sender {
    UIAlertController *busCapacityAlert = [UIAlertController alertControllerWithTitle:@"Hello!"
                                                                message:@"Please select the bus capacity you wish to charter."
                                                                preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *a11 = [UIAlertAction
                        actionWithTitle:@"11 - Seater"
                        style:UIAlertActionStyleDefault
                        handler:^(UIAlertAction * action) {
                            busType = 11;
                            [lblVehicleCapacity setText:[NSString stringWithFormat:@"  %@", @"11-Seater"]];
                            [lblVehicleCapacity setTextColor:[UIColor blackColor]];
                        }];
    
    UIAlertAction *a13 = [UIAlertAction
                        actionWithTitle:@"13 - Seater"
                        style:UIAlertActionStyleDefault
                        handler:^(UIAlertAction * action) {
                            busType = 13;
                            [lblVehicleCapacity setText:[NSString stringWithFormat:@"  %@", @"13-Seater"]];
                            [lblVehicleCapacity setTextColor:[UIColor blackColor]];
                        }];
    UIAlertAction *a19 = [UIAlertAction
                        actionWithTitle:@"19 - Seater"
                        style:UIAlertActionStyleDefault
                        handler:^(UIAlertAction * action) {
                            busType = 19;
                            [lblVehicleCapacity setText:[NSString stringWithFormat:@"  %@", @"19-Seater"]];
                            [lblVehicleCapacity setTextColor:[UIColor blackColor]];
                        }];
    UIAlertAction *a23 = [UIAlertAction
                          actionWithTitle:@"23 - Seater"
                          style:UIAlertActionStyleDefault
                          handler:^(UIAlertAction * action) {
                              busType = 23;
                              [lblVehicleCapacity setText:[NSString stringWithFormat:@"  %@", @"23-Seater"]];
                              [lblVehicleCapacity setTextColor:[UIColor blackColor]];
                          }];
    UIAlertAction *a40 = [UIAlertAction
                          actionWithTitle:@"40 - Seater"
                          style:UIAlertActionStyleDefault
                          handler:^(UIAlertAction * action) {
                              busType = 40;
                              [lblVehicleCapacity setText:[NSString stringWithFormat:@"  %@", @"40-Seater"]];
                              [lblVehicleCapacity setTextColor:[UIColor blackColor]];
                          }];
    UIAlertAction *a45 = [UIAlertAction
                          actionWithTitle:@"45 - Seater"
                          style:UIAlertActionStyleDefault
                          handler:^(UIAlertAction * action) {
                              busType = 45;
                              [lblVehicleCapacity setText:[NSString stringWithFormat:@"  %@", @"45-Seater"]];
                              [lblVehicleCapacity setTextColor:[UIColor blackColor]];
                          }];
    UIAlertAction *a49 = [UIAlertAction
                          actionWithTitle:@"49 - Seater"
                          style:UIAlertActionStyleDefault
                          handler:^(UIAlertAction * action) {
                              busType = 49;
                              [lblVehicleCapacity setText:[NSString stringWithFormat:@"  %@", @"49-Seater"]];
                              [lblVehicleCapacity setTextColor:[UIColor blackColor]];
                          }];
    UIAlertAction *aCancel = [UIAlertAction
                          actionWithTitle:@"Cancel"
                          style:UIAlertActionStyleDefault
                          handler:^(UIAlertAction * action) {
                              [self dismissViewControllerAnimated:YES completion:nil];
                          }];

    [busCapacityAlert addAction:a11];
    [busCapacityAlert addAction:a13];
    [busCapacityAlert addAction:a19];
    [busCapacityAlert addAction:a23];
    [busCapacityAlert addAction:a40];
    [busCapacityAlert addAction:a45];
    [busCapacityAlert addAction:a49];
    [busCapacityAlert addAction:aCancel];
    [self presentViewController:busCapacityAlert animated:YES completion:nil];
}

#pragma mark - Disposal Hrs
- (void)setDisposalHours:(id)sender {
    UIAlertController *disposalHrsAlert = [UIAlertController alertControllerWithTitle:@"Hello!"
                                                                        message:@"Please enter the duration of this charter."
                                                                        preferredStyle:UIAlertControllerStyleAlert];

    aSetDisposalHrs = [UIAlertAction
                       actionWithTitle:@"Confirm Disposal Hours"
                       style:UIAlertActionStyleDefault
                       handler:^(UIAlertAction * action) {
                           [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
                           [lblDropOffTime setText:[NSString stringWithFormat:@"  %@ hours", disposalHrsInString]];
                           [lblDropOffTime setTextColor:[UIColor blackColor]];
                       }];
    [aSetDisposalHrs setEnabled:NO];
    UIAlertAction *aCancelHrsInput = [UIAlertAction
                                      actionWithTitle:@"Cancel"
                                      style:UIAlertActionStyleDefault
                                      handler:^(UIAlertAction * action) {
                                          [self dismissViewControllerAnimated:YES completion:nil];
                                      }];
    [disposalHrsAlert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.tag = 13;
        textField.delegate = self;
        textField.keyboardType = UIKeyboardTypeNumberPad;
        textField.placeholder = @"e.g 3";
    }];
    
    [disposalHrsAlert addAction:aSetDisposalHrs];
    [disposalHrsAlert addAction:aCancelHrsInput];
    [self presentViewController:disposalHrsAlert animated:YES completion:nil];
}

#pragma mark - Cost Popup
- (void)enterCostAlert:(id)sender {
    UIAlertController *costAlert = [UIAlertController alertControllerWithTitle:@"Hello!"
                                                            message:@"Please enter the cost of this charter."
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    if ([serviceType isEqualToString:@"twoway"]) {
        [costAlert setMessage:@"Please enter the cost per trip."];
    } else if ([serviceType isEqualToString:@"disposal"]) {
        [costAlert setMessage:@"Please enter the cost per hour."];
    }
    
    aSetCost = [UIAlertAction
                     actionWithTitle:@"Set Price"
                     style:UIAlertActionStyleDefault
                     handler:^(UIAlertAction * action) {
                        [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
                         if ([serviceType isEqualToString:@"oneway"]) {
                             [lblCost setText:[NSString stringWithFormat:@"  $%@", costInString]];
                         } else if ([serviceType isEqualToString:@"twoway"]) {
                             [lblCost setText:[NSString stringWithFormat:@"  $%@/trip", costInString]];
                         } else if ([serviceType isEqualToString:@"disposal"]) {
                             [lblCost setText:[NSString stringWithFormat:@"  $%@/hr", costInString]];
                         }
                         [lblCost setTextColor:[UIColor blackColor]];
                     }];
    [aSetCost setEnabled:NO];
    UIAlertAction *aCancelCost = [UIAlertAction
                              actionWithTitle:@"Cancel"
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction * action) {
                                  [self dismissViewControllerAnimated:YES completion:nil];
                              }];
    [costAlert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.tag = 14;
        textField.delegate = self;
        textField.keyboardType = UIKeyboardTypeNumberPad;
        textField.placeholder = @"e.g $200";
    }];
    
    [costAlert addAction:aSetCost];
    [costAlert addAction:aCancelCost];
    [self presentViewController:costAlert animated:YES completion:nil];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    NSInteger txtId = textField.tag;
    if (txtId == 13) {
        disposalHrsInString = [textField.text stringByReplacingCharactersInRange:range withString:string];
        int intValue = [disposalHrsInString intValue];
        [aSetDisposalHrs setEnabled:(intValue >= 3 && intValue <= 24)];
    } else if (txtId == 14) {
        costInString = [textField.text stringByReplacingCharactersInRange:range withString:string];
        int intValue = [costInString intValue];
        [aSetCost setEnabled:(intValue >= 35)];
    } else if (txtId == 15) {
        remarks = [textField.text stringByReplacingCharactersInRange:range withString:string];
    } else if (txtId == 23) {
        expiryHrs = [textField.text intValue];
    }
    return YES;
}

#pragma mark - Add Charter
- (void)addCharter:(id)sender {
    NSLog(@"Add Charter");
    bool canProceed = YES;
    pickUpTime = [NSString stringWithFormat:@"%@ %@", dateInString, pickupTimeInString];
    dropOffTime = [NSString stringWithFormat:@"%@ %@", dateInString, returnTimeInString];
    
    if ([startLocationString length] == 0 || [endLocationString length] == 0 || startLon == 0 || startLat == 0 || endLat == 0 || endLon == 0 || [dateInString length] == 0 || [pickupTimeInString length] == 0) {
        canProceed = NO;
    }
    
    if ([serviceType isEqualToString:@"twoway"] && [returnTimeInString length] == 0) {
        canProceed = NO;
    }
    
    if ([serviceType isEqualToString:@"disposal"]) {
        int disposalHrs = [disposalHrsInString intValue];
        if (disposalHrs < 3) {
            canProceed = NO;
        }
    }
    
    if (!canProceed) {
        UIAlertController *cannotProceedAlert = [UIAlertController alertControllerWithTitle:@"Error!"
                                                                             message:@"Unable to process the information entered. Kindly check if you have filled in all required details before trying again. If the problem still persist, please try again later as the server may be busy. Alternatively, you may also contact your operations team."
                                                                             preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *aReturn = [UIAlertAction
                                           actionWithTitle:@"OK"
                                           style:UIAlertActionStyleDefault
                                           handler:^(UIAlertAction * action) {
                                                [self dismissViewControllerAnimated:YES completion:nil];
                                           }];
        [cannotProceedAlert addAction:aReturn];
        [self presentViewController:cannotProceedAlert animated:YES completion:nil];
    } else {
        UIAlertController *confirmationAlert = [UIAlertController alertControllerWithTitle:@"Hello!"
                                                                            message:@"Please check all information entered before submission of new charter. Please note that once the charter is submitted and there are changes to be made, You will have to go to your charters to delete it. You may also enter additional information for the charters and specify the expiry time (in hours) for the job to expire."
                                                                            preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *aAddCharter = [UIAlertAction
                    actionWithTitle:@"Create this Charter"
                    style:UIAlertActionStyleDefault
                    handler:^(UIAlertAction * action) {
                        [self addCharterToServer];
                    }];
        UIAlertAction *aCancelAddCharter = [UIAlertAction
                                      actionWithTitle:@"Cancel"
                                      style:UIAlertActionStyleDefault
                                      handler:^(UIAlertAction * action) {
                                          [self dismissViewControllerAnimated:YES completion:nil];
                                      }];
        [confirmationAlert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.tag = 15;
            textField.delegate = self;
            textField.placeholder = @"(Optional) Additional Info";
        }];
        
        [confirmationAlert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.tag = 23;
            textField.delegate = self;
            textField.placeholder = @"(Optional) Expiry time";
        }];
        
        [confirmationAlert addAction:aAddCharter];
        [confirmationAlert addAction:aCancelAddCharter];
        [self presentViewController:confirmationAlert animated:YES completion:nil];
    }
}

#pragma mark - Google AutoComplete
// Handle the user's selection.
- (void)viewController:(GMSAutocompleteViewController *)viewController
didAutocompleteWithPlace:(GMSPlace *)place {
    [self dismissViewControllerAnimated:YES completion:^{
        NSLog(@"Place name + location: %@, %@", place.name, place.formattedAddress);
        NSLog(@"Place coordinates: %f,%f", place.coordinate.latitude, place.coordinate.longitude);
        
        if ([currentView isEqualToString:@"Pickup"]) {
            startLocationString = place.name;
            startLat = place.coordinate.latitude;
            startLon = place.coordinate.longitude;
            [startLocation setText:[NSString stringWithFormat:@"  %@", startLocationString]];
            [startLocation setTextColor:[UIColor blackColor]];
            pickupMarker.position = CLLocationCoordinate2DMake(startLat, startLon);
            pickupMarker.map = _charterMapView;
            [_charterMapView animateToLocation:CLLocationCoordinate2DMake(startLat, startLon)];
        } else if ([currentView isEqualToString:@"Dropoff"]) {
            endLocationString = place.name;
            endLat = place.coordinate.latitude;
            endLon = place.coordinate.longitude;
            [endLocation setText:[NSString stringWithFormat:@"  %@", endLocationString]];
            [endLocation setTextColor:[UIColor blackColor]];
            dropoffMarker.position = CLLocationCoordinate2DMake(endLat, endLon);
            dropoffMarker.map = _charterMapView;
            [_charterMapView animateToLocation:CLLocationCoordinate2DMake(endLat, endLon)];
        }
        currentView = @"";
    }];
}

- (void)viewController:(GMSAutocompleteViewController *)viewController
didFailAutocompleteWithError:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:nil];
    // TODO: handle the error.
    NSLog(@"Error: %@", [error description]);
}

// User canceled the operation.
- (void)wasCancelled:(GMSAutocompleteViewController *)viewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

// Turn the network activity indicator on and off again.
- (void)didRequestAutocompletePredictions:(GMSAutocompleteViewController *)viewController {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)didUpdateAutocompletePredictions:(GMSAutocompleteViewController *)viewController {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

#pragma mark - charter API
- (void)addCharterToServer {
    __block NSInteger success = 0;
    NSDictionary *charterData = [NSDictionary dictionaryWithObjectsAndKeys:
                                 costInString, @"cost",
                                 @(busType), @"busType",
                                 @([disposalHrsInString intValue]), @"disposalDuration",
                                 @(busQty), @"busQty",
                                 serviceType, @"serviceType",
                                 startLocationString, @"pickUpName",
                                 endLocationString, @"dropOffName",
                                 pickUpTime, @"pickUpTime",
                                 dropOffTime, @"dropOffTime",
                                 @(startLat), @"pickupLatitude",
                                 @(startLon), @"pickupLongitude",
                                 @(endLat), @"dropOffLatitude",
                                 @(endLon), @"dropOffLongitude",
                                 remarks, @"remarks",
                                 nil];
    
    NSDictionary *jsonData = [NSDictionary dictionaryWithObjectsAndKeys:
                              charterData, @"data",
                              nil];
    
    NSURL *url = [NSURL URLWithString:CREATE_CHARTER_URL];
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

        } else {
            UIAlertController *cannotProceedAlert = [UIAlertController alertControllerWithTitle:@"Error!"
                                                                                        message:@"Unable to verify job(s). Please check your internet connection."
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
    } else if ([response statusCode] == 401 || [response statusCode] == 0) {
        UIAlertController *concurrentLoginAlert = [UIAlertController alertControllerWithTitle:@"Error!"
                                                                                    message:@"Please log in again."
                                                                                    preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *aReturn = [UIAlertAction
                                  actionWithTitle:@"OK"
                                  style:UIAlertActionStyleDefault
                                  handler:^(UIAlertAction * action) {
                                      [userPrefs setValue:nil forKey:AUTHENTICATION_TOKEN];
                                      [userPrefs setValue:nil forKey:LAST_UPDATED_TIME];
                                      [userPrefs synchronize];
                                      [self performSegueWithIdentifier:@"reset2" sender:self];
                                  }];
        [concurrentLoginAlert addAction:aReturn];
        [self presentViewController:concurrentLoginAlert animated:YES completion:nil];
    } else {
        UIAlertController *cannotProceedAlert = [UIAlertController alertControllerWithTitle:@"Error!"
                                                                                    message:@"Unable to connect to server. Please contact your operations team."
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

#pragma mark - Get Online Users
- (void)getOnlineUsers {
    __block NSInteger success = 0;
    numOfOnlineUsers = @"0";
    if (token != nil && token != NULL) {
        NSURL *url = [NSURL URLWithString:GET_ONLINE_USERS_URL];
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
                numOfOnlineUsers = [dataResponse objectForKey:@"onlineUsers"];
            }
        } else if ([response statusCode] == 401 || [response statusCode] == 0) {
            UIAlertController *concurrentLoginAlert = [UIAlertController alertControllerWithTitle:@"Error!"
                                                                                          message:@"Please log in again."
                                                                                   preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *aReturn = [UIAlertAction
                                      actionWithTitle:@"OK"
                                      style:UIAlertActionStyleDefault
                                      handler:^(UIAlertAction * action) {
                                          [userPrefs setValue:nil forKey:AUTHENTICATION_TOKEN];
                                          [userPrefs setValue:nil forKey:LAST_UPDATED_TIME];
                                          [userPrefs synchronize];
                                          [self performSegueWithIdentifier:@"reset2" sender:self];
                                      }];
            [concurrentLoginAlert addAction:aReturn];
            [self presentViewController:concurrentLoginAlert animated:YES completion:nil];
        }
    } else {
        UIAlertController *noInternetAlert = [UIAlertController alertControllerWithTitle:@"Error!"
                                                                                 message:@"Unable to connect to server. Please check your internet connection."
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *aOk = [UIAlertAction
                              actionWithTitle:@"OK"
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction * action) {
                                  [self dismissViewControllerAnimated:YES completion:nil];
                              }];
        [noInternetAlert addAction:aOk];
        [self presentViewController:noInternetAlert animated:YES completion:nil];
    }
}

@end
