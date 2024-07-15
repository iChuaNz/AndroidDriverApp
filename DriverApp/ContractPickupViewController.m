//
//  DriverApp
//
//  Created by KangJie Lim on 13/2/18.
//  Copyright © 2018 Commute-Solutions. All rights reserved.
//

#import "ContractPickupViewController.h"
#import <GoogleMaps/GoogleMaps.h>
#import <GooglePlaces/GooglePlaces.h>

@interface ContractPickupViewController () <GMSAutocompleteViewControllerDelegate>
@property (strong, nonatomic) GMSMapView *contractPickupMapView;

@end

@implementation ContractPickupViewController
NSUserDefaults *userPrefs;
NetworkUtility *reachability;
NetworkStatus status;
CLLocationManager *locationManager;
GMSAutocompleteFilter *countryFilter;

UIView *pickup1View;
UIView *pickup2View;
UIView *pickup3View;
UIImageView *ivPickup1;
UIImageView *ivPickup2;
UIImageView *ivPickup3;
UILabel *lblPickup1;
UILabel *lblPickup2;
UILabel *lblPickup3;
int currentLbl;
bool canProceed;

GMSMarker *pickup1Marker;
GMSMarker *pickup2Marker;
GMSMarker *pickup3Marker;

- (void)loadView {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[[UIView alloc] init]];
    self.navigationItem.title = @"Pick Up";
    
    UIBarButtonItem *btnSideMenu = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(showHideButtonsAction)];
    [btnSideMenu setTintColor:[UIColor whiteColor]];
    self.navigationItem.rightBarButtonItem = btnSideMenu;
    
    userPrefs = [NSUserDefaults standardUserDefaults];
    
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    reachability = [NetworkUtility reachabilityForInternetConnection];
    [locationManager requestWhenInUseAuthorization];
    [locationManager requestAlwaysAuthorization];
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:1.537633
                                                            longitude:103.820629
                                                                 zoom:10];
    _contractPickupMapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    _contractPickupMapView.indoorEnabled = NO;
    _contractPickupMapView.myLocationEnabled = NO;

    
    if (locationManager == nil) {
        locationManager = [[CLLocationManager alloc]init];
    }
    
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
    countryFilter = [[GMSAutocompleteFilter alloc] init];
    countryFilter.country = @"SG";
    self.view = _contractPickupMapView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    canProceed = NO;
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    UIImage *imgAdd = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"addrow" ofType:@"png"]];
    
    pickup1View = [[UIView alloc] initWithFrame:CGRectMake(5, 65, screenWidth - 10, screenHeight / 7)];
    [pickup1View setBackgroundColor:UIColorFromRGB(0xF68B1F)];
    ivPickup1 = [[UIImageView alloc] initWithFrame:CGRectMake(15 , pickup1View.bounds.size.height / 4, pickup1View.bounds.size.height / 2, pickup1View.bounds.size.height / 2)];
    [ivPickup1 setImage:imgAdd];
    [pickup1View addSubview:ivPickup1];
    UIButton *btnAddRemoveRow1 = [UIButton buttonWithType:UIButtonTypeCustom];
    btnAddRemoveRow1.frame = CGRectMake(15 , pickup1View.bounds.size.height / 4, pickup1View.bounds.size.height / 2, pickup1View.bounds.size.height / 2);
    btnAddRemoveRow1.tag = 27;
    [btnAddRemoveRow1 addTarget:self action:@selector(addRemoveRow:) forControlEvents:UIControlEventTouchDown];
    [pickup1View addSubview:btnAddRemoveRow1];
    lblPickup1 = [[UILabel alloc] initWithFrame:CGRectMake((pickup1View.bounds.size.height / 2) + 33, pickup1View.bounds.size.height / 4, pickup1View.bounds.size.width - pickup1View.bounds.size.height, pickup1View.bounds.size.height / 2)];
    [lblPickup1 setBackgroundColor:[UIColor whiteColor]];
    [lblPickup1 setText:@"  Please choose a pick up point"];
    [lblPickup1 setTextColor:[UIColor grayColor]];
    [lblPickup1 setFont: [UIFont fontWithName:@"HelveticaNeue" size:13]];
    [lblPickup1 setLineBreakMode:NSLineBreakByTruncatingTail];
    [lblPickup1 setNumberOfLines:1];
    lblPickup1.layer.masksToBounds = YES;
    lblPickup1.layer.cornerRadius = 12;
    [pickup1View addSubview:lblPickup1];
    UIButton *btnPickup1 = [UIButton buttonWithType:UIButtonTypeCustom];
    btnPickup1.frame = CGRectMake((pickup1View.bounds.size.height / 2) + 33, pickup1View.bounds.size.height / 4, pickup1View.bounds.size.width - pickup1View.bounds.size.height, pickup1View.bounds.size.height / 2);
    btnPickup1.tag = 24;
    [btnPickup1 addTarget:self action:@selector(setPickupLocation:) forControlEvents:UIControlEventTouchDown];
    [pickup1View addSubview:btnPickup1];
    [_contractPickupMapView addSubview:pickup1View];
    
    pickup2View = [[UIView alloc] initWithFrame:CGRectMake(5, 65 + (screenHeight / 7), screenWidth - 10, screenHeight / 7)];
    [pickup2View setBackgroundColor:UIColorFromRGB(0xF68B1F)];
    ivPickup2 = [[UIImageView alloc] initWithFrame:CGRectMake(15 , pickup2View.bounds.size.height / 4, pickup2View.bounds.size.height / 2, pickup2View.bounds.size.height / 2)];
    [ivPickup2 setImage:imgAdd];
    [pickup2View addSubview:ivPickup2];
    UIButton *btnAddRemoveRow2 = [UIButton buttonWithType:UIButtonTypeCustom];
    btnAddRemoveRow2.frame = CGRectMake(15 , pickup2View.bounds.size.height / 4, pickup2View.bounds.size.height / 2, pickup2View.bounds.size.height / 2);
    btnAddRemoveRow2.tag = 28;
    [btnAddRemoveRow2 addTarget:self action:@selector(addRemoveRow:) forControlEvents:UIControlEventTouchDown];
    [pickup2View addSubview:btnAddRemoveRow2];
    lblPickup2 = [[UILabel alloc] initWithFrame:CGRectMake((pickup2View.bounds.size.height / 2) + 33, pickup2View.bounds.size.height / 4, pickup2View.bounds.size.width - pickup2View.bounds.size.height, pickup2View.bounds.size.height / 2)];
    [lblPickup2 setBackgroundColor:[UIColor whiteColor]];
    [lblPickup2 setText:@"  Please choose a pick up point"];
    [lblPickup2 setTextColor:[UIColor grayColor]];
    [lblPickup2 setFont: [UIFont fontWithName:@"HelveticaNeue" size:13]];
    [lblPickup2 setLineBreakMode:NSLineBreakByTruncatingTail];
    [lblPickup2 setNumberOfLines:1];
    lblPickup2.layer.masksToBounds = YES;
    lblPickup2.layer.cornerRadius = 12;
    [pickup2View addSubview:lblPickup2];
    UIButton *btnPickup2 = [UIButton buttonWithType:UIButtonTypeCustom];
    btnPickup2.frame = CGRectMake((pickup2View.bounds.size.height / 2) + 33, pickup2View.bounds.size.height / 4, pickup2View.bounds.size.width - pickup2View.bounds.size.height, pickup2View.bounds.size.height / 2);
    btnPickup2.tag = 25;
    [btnPickup2 addTarget:self action:@selector(setPickupLocation:) forControlEvents:UIControlEventTouchDown];
    [pickup2View addSubview:btnPickup2];
    [pickup2View setHidden:YES];
    [_contractPickupMapView addSubview:pickup2View];
    
    pickup3View = [[UIView alloc] initWithFrame:CGRectMake(5, 65 + (screenHeight / 7) + (screenHeight / 7), screenWidth - 10, screenHeight / 7)];
    [pickup3View setBackgroundColor:UIColorFromRGB(0xF68B1F)];
    lblPickup3 = [[UILabel alloc] initWithFrame:CGRectMake((pickup3View.bounds.size.height / 2) + 33, pickup3View.bounds.size.height / 4, pickup3View.bounds.size.width - pickup3View.bounds.size.height, pickup3View.bounds.size.height / 2)];
    [lblPickup3 setBackgroundColor:[UIColor whiteColor]];
    [lblPickup3 setText:@"  Please choose a pick up point"];
    [lblPickup3 setTextColor:[UIColor grayColor]];
    [lblPickup3 setFont: [UIFont fontWithName:@"HelveticaNeue" size:13]];
    [lblPickup3 setLineBreakMode:NSLineBreakByTruncatingTail];
    [lblPickup3 setNumberOfLines:1];
    lblPickup3.layer.masksToBounds = YES;
    lblPickup3.layer.cornerRadius = 12;
    [pickup3View addSubview:lblPickup3];
    UIButton *btnPickup3 = [UIButton buttonWithType:UIButtonTypeCustom];
    btnPickup3.frame = CGRectMake((pickup3View.bounds.size.height / 2) + 33, pickup3View.bounds.size.height / 4, pickup3View.bounds.size.width - pickup3View.bounds.size.height, pickup3View.bounds.size.height / 2);
    btnPickup3.tag = 26;
    [btnPickup3 addTarget:self action:@selector(setPickupLocation:) forControlEvents:UIControlEventTouchDown];
    [pickup3View addSubview:btnPickup3];
    [pickup3View setHidden:YES];
    [_contractPickupMapView addSubview:pickup3View];
    
    UIButton *btnNextPage = [UIButton buttonWithType:UIButtonTypeCustom];
    btnNextPage.frame = CGRectMake(0, screenHeight - 50, screenWidth, 50);
    [btnNextPage setBackgroundColor:UIColorFromRGB(0xF68B1F)];
    [btnNextPage setTitle:@"Next" forState:UIControlStateNormal];
    [btnNextPage addTarget:self action:@selector(nextPage) forControlEvents:UIControlEventTouchDown];
    [_contractPickupMapView addSubview:btnNextPage];
}

- (void)viewWillAppear:(BOOL)animated {
    _navBar = [LGPlusButtonsView plusButtonsViewWithNumberOfButtons:3
                                            firstButtonIsPlusButton:NO
                                                      showAfterInit:NO
                                                      actionHandler:^(LGPlusButtonsView *plusButtonView, NSString *title, NSString *description, NSUInteger index)
               {
                   NSLog(@"actionHandler | title: %@, description: %@, index: %lu", title, description, (long unsigned)index);
                   if (index == 1) {
                       [self performSegueWithIdentifier:@"toCharter" sender:self];
                   } else if (index == 2) {
                       [self performSegueWithIdentifier:@"toViewContract" sender:@"subout"];
                   }
               }];
    
    _navBar.showHideOnScroll = NO;
    _navBar.appearingAnimationType = LGPlusButtonsAppearingAnimationTypeCrossDissolveAndPop;
    _navBar.position = LGPlusButtonsViewPositionRightTop;
    
    NSArray *btnImageArray = @[[NSNull new], [UIImage imageNamed:@"createcharter"], [UIImage imageNamed:@"viewcontractjob"]];
    [_navBar setButtonsImages:btnImageArray forState:UIControlStateNormal forOrientation:LGPlusButtonsViewOrientationAll];
    [_navBar setDescriptionsTexts:@[@" ", @"Back to Charters", @"View All Contracts"]];
    
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

#pragma mark - navigation bar
- (void)showHideButtonsAction {
    if (_navBar.isShowing)
        [_navBar hideAnimated:YES completionHandler:nil];
    else
        [_navBar showAnimated:YES completionHandler:nil];
}

#pragma mark - Google AutoComplete
// Handle the user's selection.
- (void)viewController:(GMSAutocompleteViewController *)viewController
didAutocompleteWithPlace:(GMSPlace *)place {
    [self dismissViewControllerAnimated:YES completion:^{
        NSString *startLocationString = place.name;
        float lat = place.coordinate.latitude;
        float lng = place.coordinate.longitude;
        NSLog(@"Place name + location: %@, %@", startLocationString, place.formattedAddress);
        NSLog(@"Place coordinates: %f,%f", lat, lng);
        
        if (currentLbl == 1) {
            pickup1Marker.map = nil;
            pickup1Marker = [[GMSMarker alloc] init];
            [lblPickup1 setText:[NSString stringWithFormat:@"  %@", startLocationString]];
            [lblPickup1 setTextColor:[UIColor blackColor]];
            pickup1Marker.position = CLLocationCoordinate2DMake(lat, lng);
            pickup1Marker.map = _contractPickupMapView;
            
            [userPrefs setValue:startLocationString forKey:PICKUP1_STRING];
            [userPrefs setFloat:lat forKey:PICKUP1_LAT];
            [userPrefs setFloat:lng forKey:PICKUP1_LNG];
            
            canProceed = YES;
        } else if (currentLbl == 2) {
            pickup2Marker = [[GMSMarker alloc] init];
            [lblPickup2 setText:[NSString stringWithFormat:@"  %@", startLocationString]];
            [lblPickup2 setTextColor:[UIColor blackColor]];
            pickup2Marker.position = CLLocationCoordinate2DMake(lat, lng);
            pickup2Marker.map = _contractPickupMapView;
            
            [userPrefs setValue:startLocationString forKey:PICKUP2_STRING];
            [userPrefs setFloat:lat forKey:PICKUP2_LAT];
            [userPrefs setFloat:lng forKey:PICKUP2_LNG];
        } else if (currentLbl == 3) {
            pickup3Marker = [[GMSMarker alloc] init];
            [lblPickup3 setText:[NSString stringWithFormat:@"  %@", startLocationString]];
            [lblPickup3 setTextColor:[UIColor blackColor]];
            pickup3Marker.position = CLLocationCoordinate2DMake(lat, lng);
            pickup3Marker.map = _contractPickupMapView;
            
            [userPrefs setValue:startLocationString forKey:PICKUP3_STRING];
            [userPrefs setFloat:lat forKey:PICKUP3_LAT];
            [userPrefs setFloat:lng forKey:PICKUP3_LNG];
        }
        [userPrefs synchronize];
    }];
}

- (void)viewController:(nonnull GMSAutocompleteViewController *)viewController didFailAutocompleteWithError:(nonnull NSError *)error {
    [self dismissViewControllerAnimated:YES completion:nil];
    // TODO: handle the error.
    NSLog(@"Error: %@", [error description]);
}

- (void)wasCancelled:(nonnull GMSAutocompleteViewController *)viewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)setPickupLocation:(id)sender {
    NSInteger senderId = [sender tag];
    GMSAutocompleteViewController *setPickupLocationController = [[GMSAutocompleteViewController alloc] init];
    [setPickupLocationController setAutocompleteFilter:countryFilter];
    setPickupLocationController.delegate = self;
    [self presentViewController:setPickupLocationController animated:YES completion:^{
        switch (senderId) {
            case 24: currentLbl = 1;
                break;
            case 25: currentLbl = 2;
                break;
            case 26: currentLbl = 3;
                break;
        }
    }];
}

- (void)addRemoveRow:(id)sender {
    NSInteger senderId = [sender tag];
        UIImage *imgAdd = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"addrow" ofType:@"png"]];
        UIImage *imgDelete = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"minusrow" ofType:@"png"]];
    if (senderId == 27) {
        if ([pickup2View isHidden]) {
            [pickup2View setHidden:NO];
            [ivPickup1 setImage:imgDelete];
        } else {
            [pickup2View setHidden:YES];
            pickup2Marker.map = nil;
            [lblPickup2 setText:@"  Please choose a pick up point"];
            [lblPickup2 setTextColor:[UIColor grayColor]];
            [userPrefs setValue:@"" forKey:PICKUP2_STRING];
            [userPrefs setFloat:0 forKey:PICKUP2_LAT];
            [userPrefs setFloat:0 forKey:PICKUP2_LNG];
            
            [pickup3View setHidden:YES];
            pickup3Marker.map = nil;
            [lblPickup3 setText:@"  Please choose a pick up point"];
            [lblPickup3 setTextColor:[UIColor grayColor]];
            [userPrefs setValue:@"" forKey:PICKUP3_STRING];
            [userPrefs setFloat:0 forKey:PICKUP3_LAT];
            [userPrefs setFloat:0 forKey:PICKUP3_LNG];
            
            [userPrefs synchronize];
            [ivPickup1 setImage:imgAdd];
            [ivPickup2 setImage:imgAdd];
        }
    } else if (senderId == 28) {
        if ([pickup3View isHidden]) {
            [pickup3View setHidden:NO];
            [ivPickup2 setImage:imgDelete];
        } else {
            [pickup3View setHidden:YES];
            pickup3Marker.map = nil;
            [lblPickup3 setText:@"  Please choose a pick up point"];
            [lblPickup3 setTextColor:[UIColor grayColor]];
            [userPrefs setValue:@"" forKey:PICKUP3_STRING];
            [userPrefs setFloat:0 forKey:PICKUP3_LAT];
            [userPrefs setFloat:0 forKey:PICKUP3_LNG];
            
            [userPrefs synchronize];
            [ivPickup2 setImage:imgAdd];
        }
    }
}

- (void)nextPage {
    NSString *pickup1String = [userPrefs stringForKey:PICKUP1_STRING];
    if (canProceed || (![pickup1String isEqual: @""] && pickup1String != nil)) {
        [self performSegueWithIdentifier:@"toContractDropoff" sender:self];
    } else {
        UIAlertController *cannotProceedAlert = [UIAlertController alertControllerWithTitle:@"Error!"
                                                                                    message:@"Please choose at least 1 point for pick up."
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

@end
