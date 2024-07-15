//
//  DriverApp
//
//  Created by KangJie Lim on 23/2/18.
//  Copyright © 2018 Commute-Solutions. All rights reserved.
//

#import "ContractDropoffViewController.h"
#import <GoogleMaps/GoogleMaps.h>
#import <GooglePlaces/GooglePlaces.h>

@interface ContractDropoffViewController () <GMSAutocompleteViewControllerDelegate>
@property (strong, nonatomic) GMSMapView *contractDropoffMapView;

@end

@implementation ContractDropoffViewController
NSUserDefaults *userPrefs;
NetworkUtility *reachability;
NetworkStatus status;
CLLocationManager *locationManager;
GMSAutocompleteFilter *countryFilter;

UIView *dropoff1View;
UIView *dropoff2View;
UIView *dropoff3View;
UIImageView *ivDropoff1;
UIImageView *ivDropoff2;
UIImageView *ivDropoff3;
UILabel *lblDropoff1;
UILabel *lblDropoff2;
UILabel *lblDropoff3;
int currentLbl;
bool canProceed;

GMSMarker *dropoff1Marker;
GMSMarker *dropoff2Marker;
GMSMarker *dropoff3Marker;

- (void)loadView {
    self.navigationItem.title = @"Drop Off";
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
    _contractDropoffMapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    _contractDropoffMapView.indoorEnabled = NO;
    _contractDropoffMapView.myLocationEnabled = NO;
    
    if (locationManager == nil) {
        locationManager = [[CLLocationManager alloc]init];
    }
    
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
    countryFilter = [[GMSAutocompleteFilter alloc] init];
    countryFilter.country = @"SG";
    self.view = _contractDropoffMapView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    canProceed = NO;
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    UIImage *imgAdd = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"addrow" ofType:@"png"]];
    
    dropoff1View = [[UIView alloc] initWithFrame:CGRectMake(5, 65, screenWidth - 10, screenHeight / 7)];
    [dropoff1View setBackgroundColor:UIColorFromRGB(0xF68B1F)];
    ivDropoff1 = [[UIImageView alloc] initWithFrame:CGRectMake(15 , dropoff1View.bounds.size.height / 4, dropoff1View.bounds.size.height / 2, dropoff1View.bounds.size.height / 2)];
    [ivDropoff1 setImage:imgAdd];
    [dropoff1View addSubview:ivDropoff1];
    UIButton *btnAddRemoveRow1 = [UIButton buttonWithType:UIButtonTypeCustom];
    btnAddRemoveRow1.frame = CGRectMake(15 , dropoff1View.bounds.size.height / 4, dropoff1View.bounds.size.height / 2, dropoff1View.bounds.size.height / 2);
    btnAddRemoveRow1.tag = 27;
    [btnAddRemoveRow1 addTarget:self action:@selector(addRemoveRow:) forControlEvents:UIControlEventTouchDown];
    [dropoff1View addSubview:btnAddRemoveRow1];
    lblDropoff1 = [[UILabel alloc] initWithFrame:CGRectMake((dropoff1View.bounds.size.height / 2) + 33, dropoff1View.bounds.size.height / 4, dropoff1View.bounds.size.width - dropoff1View.bounds.size.height, dropoff1View.bounds.size.height / 2)];
    [lblDropoff1 setBackgroundColor:[UIColor whiteColor]];
    [lblDropoff1 setText:@"  Please choose a drop off point"];
    [lblDropoff1 setTextColor:[UIColor grayColor]];
    [lblDropoff1 setFont: [UIFont fontWithName:@"HelveticaNeue" size:13]];
    [lblDropoff1 setLineBreakMode:NSLineBreakByTruncatingTail];
    [lblDropoff1 setNumberOfLines:1];
    lblDropoff1.layer.masksToBounds = YES;
    lblDropoff1.layer.cornerRadius = 12;
    [dropoff1View addSubview:lblDropoff1];
    UIButton *btnDropoff1 = [UIButton buttonWithType:UIButtonTypeCustom];
    btnDropoff1.frame = CGRectMake((dropoff1View.bounds.size.height / 2) + 33, dropoff1View.bounds.size.height / 4, dropoff1View.bounds.size.width - dropoff1View.bounds.size.height, dropoff1View.bounds.size.height / 2);
    btnDropoff1.tag = 24;
    [btnDropoff1 addTarget:self action:@selector(setDropoffLocation:) forControlEvents:UIControlEventTouchDown];
    [dropoff1View addSubview:btnDropoff1];
    [_contractDropoffMapView addSubview:dropoff1View];
    
    dropoff2View = [[UIView alloc] initWithFrame:CGRectMake(5, 65 + (screenHeight / 7), screenWidth - 10, screenHeight / 7)];
    [dropoff2View setBackgroundColor:UIColorFromRGB(0xF68B1F)];
    ivDropoff2 = [[UIImageView alloc] initWithFrame:CGRectMake(15 , dropoff2View.bounds.size.height / 4, dropoff2View.bounds.size.height / 2, dropoff2View.bounds.size.height / 2)];
    [ivDropoff2 setImage:imgAdd];
    [dropoff2View addSubview:ivDropoff2];
    UIButton *btnAddRemoveRow2 = [UIButton buttonWithType:UIButtonTypeCustom];
    btnAddRemoveRow2.frame = CGRectMake(15 , dropoff2View.bounds.size.height / 4, dropoff2View.bounds.size.height / 2, dropoff2View.bounds.size.height / 2);
    btnAddRemoveRow2.tag = 28;
    [btnAddRemoveRow2 addTarget:self action:@selector(addRemoveRow:) forControlEvents:UIControlEventTouchDown];
    [dropoff2View addSubview:btnAddRemoveRow2];
    lblDropoff2 = [[UILabel alloc] initWithFrame:CGRectMake((dropoff2View.bounds.size.height / 2) + 33, dropoff2View.bounds.size.height / 4, dropoff2View.bounds.size.width - dropoff2View.bounds.size.height, dropoff2View.bounds.size.height / 2)];
    [lblDropoff2 setBackgroundColor:[UIColor whiteColor]];
    [lblDropoff2 setText:@"  Please choose a drop off point"];
    [lblDropoff2 setTextColor:[UIColor grayColor]];
    [lblDropoff2 setFont: [UIFont fontWithName:@"HelveticaNeue" size:13]];
    [lblDropoff2 setLineBreakMode:NSLineBreakByTruncatingTail];
    [lblDropoff2 setNumberOfLines:1];
    lblDropoff2.layer.masksToBounds = YES;
    lblDropoff2.layer.cornerRadius = 12;
    [dropoff2View addSubview:lblDropoff2];
    UIButton *btnDropoff2 = [UIButton buttonWithType:UIButtonTypeCustom];
    btnDropoff2.frame = CGRectMake((dropoff2View.bounds.size.height / 2) + 33, dropoff2View.bounds.size.height / 4, dropoff2View.bounds.size.width - dropoff2View.bounds.size.height, dropoff2View.bounds.size.height / 2);
    btnDropoff2.tag = 25;
    [btnDropoff2 addTarget:self action:@selector(setDropoffLocation:) forControlEvents:UIControlEventTouchDown];
    [dropoff2View addSubview:btnDropoff2];
    [dropoff2View setHidden:YES];
    [_contractDropoffMapView addSubview:dropoff2View];
    
    dropoff3View = [[UIView alloc] initWithFrame:CGRectMake(5, 65 + (screenHeight / 7) + (screenHeight / 7), screenWidth - 10, screenHeight / 7)];
    [dropoff3View setBackgroundColor:UIColorFromRGB(0xF68B1F)];
    lblDropoff3 = [[UILabel alloc] initWithFrame:CGRectMake((dropoff3View.bounds.size.height / 2) + 33, dropoff3View.bounds.size.height / 4, dropoff3View.bounds.size.width - dropoff3View.bounds.size.height, dropoff3View.bounds.size.height / 2)];
    [lblDropoff3 setBackgroundColor:[UIColor whiteColor]];
    [lblDropoff3 setText:@"  Please choose a drop off point"];
    [lblDropoff3 setTextColor:[UIColor grayColor]];
    [lblDropoff3 setFont: [UIFont fontWithName:@"HelveticaNeue" size:13]];
    [lblDropoff3 setLineBreakMode:NSLineBreakByTruncatingTail];
    [lblDropoff3 setNumberOfLines:1];
    lblDropoff3.layer.masksToBounds = YES;
    lblDropoff3.layer.cornerRadius = 12;
    [dropoff3View addSubview:lblDropoff3];
    UIButton *btnDropoff = [UIButton buttonWithType:UIButtonTypeCustom];
    btnDropoff.frame = CGRectMake((dropoff3View.bounds.size.height / 2) + 33, dropoff3View.bounds.size.height / 4, dropoff3View.bounds.size.width - dropoff3View.bounds.size.height, dropoff3View.bounds.size.height / 2);
    btnDropoff.tag = 26;
    [btnDropoff addTarget:self action:@selector(setDropoffLocation:) forControlEvents:UIControlEventTouchDown];
    [dropoff3View addSubview:btnDropoff];
    [dropoff3View setHidden:YES];
    [_contractDropoffMapView addSubview:dropoff3View];
    
    UIButton *btnNextPage = [UIButton buttonWithType:UIButtonTypeCustom];
    btnNextPage.frame = CGRectMake(0, screenHeight - 50, screenWidth, 50);
    [btnNextPage setBackgroundColor:UIColorFromRGB(0xF68B1F)];
    [btnNextPage setTitle:@"Next" forState:UIControlStateNormal];
    [btnNextPage addTarget:self action:@selector(nextPage) forControlEvents:UIControlEventTouchDown];
    [_contractDropoffMapView addSubview:btnNextPage];
}

- (void)viewWillAppear:(BOOL)animated {
    _navBar = [LGPlusButtonsView plusButtonsViewWithNumberOfButtons:3
                                            firstButtonIsPlusButton:NO
                                                      showAfterInit:NO
                                                      actionHandler:^(LGPlusButtonsView *plusButtonView, NSString *title, NSString *description, NSUInteger index)
               {
                   NSLog(@"actionHandler | title: %@, description: %@, index: %lu", title, description, (long unsigned)index);
                   if (index == 1) {
                       [userPrefs setValue:@"" forKey:PICKUP1_STRING];
                       [userPrefs setFloat:0 forKey:PICKUP1_LAT];
                       [userPrefs setFloat:0 forKey:PICKUP1_LNG];
                       
                       [userPrefs setValue:@"" forKey:PICKUP2_STRING];
                       [userPrefs setFloat:0 forKey:PICKUP2_LAT];
                       [userPrefs setFloat:0 forKey:PICKUP2_LNG];
                       
                       [userPrefs setValue:@"" forKey:PICKUP3_STRING];
                       [userPrefs setFloat:0 forKey:PICKUP3_LAT];
                       [userPrefs setFloat:0 forKey:PICKUP3_LNG];
                       
                       [userPrefs setValue:@"" forKey:DROPOFF1_STRING];
                       [userPrefs setFloat:0 forKey:DROPOFF1_LAT];
                       [userPrefs setFloat:0 forKey:DROPOFF1_LNG];
                       
                       [userPrefs setValue:@"" forKey:DROPOFF2_STRING];
                       [userPrefs setFloat:0 forKey:DROPOFF2_LAT];
                       [userPrefs setFloat:0 forKey:DROPOFF2_LNG];
                       
                       [userPrefs setValue:@"" forKey:DROPOFF3_STRING];
                       [userPrefs setFloat:0 forKey:DROPOFF3_LAT];
                       [userPrefs setFloat:0 forKey:DROPOFF3_LNG];
                       [userPrefs synchronize];
                       [self performSegueWithIdentifier:@"toCharter" sender:self];
                   } else if (index == 2) {
                       [userPrefs setValue:@"" forKey:PICKUP1_STRING];
                       [userPrefs setFloat:0 forKey:PICKUP1_LAT];
                       [userPrefs setFloat:0 forKey:PICKUP1_LNG];
                       
                       [userPrefs setValue:@"" forKey:PICKUP2_STRING];
                       [userPrefs setFloat:0 forKey:PICKUP2_LAT];
                       [userPrefs setFloat:0 forKey:PICKUP2_LNG];
                       
                       [userPrefs setValue:@"" forKey:PICKUP3_STRING];
                       [userPrefs setFloat:0 forKey:PICKUP3_LAT];
                       [userPrefs setFloat:0 forKey:PICKUP3_LNG];
                       
                       [userPrefs setValue:@"" forKey:DROPOFF1_STRING];
                       [userPrefs setFloat:0 forKey:DROPOFF1_LAT];
                       [userPrefs setFloat:0 forKey:DROPOFF1_LNG];
                       
                       [userPrefs setValue:@"" forKey:DROPOFF2_STRING];
                       [userPrefs setFloat:0 forKey:DROPOFF2_LAT];
                       [userPrefs setFloat:0 forKey:DROPOFF2_LNG];
                       
                       [userPrefs setValue:@"" forKey:DROPOFF3_STRING];
                       [userPrefs setFloat:0 forKey:DROPOFF3_LAT];
                       [userPrefs setFloat:0 forKey:DROPOFF3_LNG];
                       [userPrefs synchronize];
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
        NSString *endLocationString = place.name;
        float lat = place.coordinate.latitude;
        float lng = place.coordinate.longitude;
        NSLog(@"Place name + location: %@, %@", endLocationString, place.formattedAddress);
        NSLog(@"Place coordinates: %f,%f", lat, lng);
        
        if (currentLbl == 1) {
            dropoff1Marker.map = nil;
            dropoff1Marker = [[GMSMarker alloc] init];
            [lblDropoff1 setText:[NSString stringWithFormat:@"  %@", endLocationString]];
            [lblDropoff1 setTextColor:[UIColor blackColor]];
            dropoff1Marker.position = CLLocationCoordinate2DMake(lat, lng);
            dropoff1Marker.map = _contractDropoffMapView;
            
            [userPrefs setValue:endLocationString forKey:DROPOFF1_STRING];
            [userPrefs setFloat:lat forKey:DROPOFF1_LAT];
            [userPrefs setFloat:lng forKey:DROPOFF1_LNG];
            
            canProceed = YES;
        } else if (currentLbl == 2) {
            dropoff2Marker = [[GMSMarker alloc] init];
            [lblDropoff2 setText:[NSString stringWithFormat:@"  %@", endLocationString]];
            [lblDropoff2 setTextColor:[UIColor blackColor]];
            dropoff2Marker.position = CLLocationCoordinate2DMake(lat, lng);
            dropoff2Marker.map = _contractDropoffMapView;
            
            [userPrefs setValue:endLocationString forKey:DROPOFF2_STRING];
            [userPrefs setFloat:lat forKey:DROPOFF2_LAT];
            [userPrefs setFloat:lng forKey:DROPOFF2_LNG];
        } else if (currentLbl == 3) {
            dropoff3Marker = [[GMSMarker alloc] init];
            [lblDropoff3 setText:[NSString stringWithFormat:@"  %@", endLocationString]];
            [lblDropoff3 setTextColor:[UIColor blackColor]];
            dropoff3Marker.position = CLLocationCoordinate2DMake(lat, lng);
            dropoff3Marker.map = _contractDropoffMapView;
            
            [userPrefs setValue:endLocationString forKey:DROPOFF3_STRING];
            [userPrefs setFloat:lat forKey:DROPOFF3_LAT];
            [userPrefs setFloat:lng forKey:DROPOFF3_LNG];
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

- (void)setDropoffLocation:(id)sender {
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
        if ([dropoff2View isHidden]) {
            [dropoff2View setHidden:NO];
            [ivDropoff1 setImage:imgDelete];
        } else {
            [dropoff2View setHidden:YES];
            dropoff2Marker.map = nil;
            [lblDropoff2 setText:@"  Please choose a drop off point"];
            [lblDropoff2 setTextColor:[UIColor grayColor]];
            [userPrefs setValue:@"" forKey:DROPOFF2_STRING];
            [userPrefs setFloat:0 forKey:DROPOFF2_LAT];
            [userPrefs setFloat:0 forKey:DROPOFF2_LNG];
            
            [dropoff3View setHidden:YES];
            dropoff3Marker.map = nil;
            [lblDropoff3 setText:@"  Please choose a drop off point"];
            [lblDropoff3 setTextColor:[UIColor grayColor]];
            [userPrefs setValue:@"" forKey:DROPOFF3_STRING];
            [userPrefs setFloat:0 forKey:DROPOFF3_LAT];
            [userPrefs setFloat:0 forKey:DROPOFF3_LNG];
            
            [userPrefs synchronize];
            [ivDropoff1 setImage:imgAdd];
            [ivDropoff2 setImage:imgAdd];
        }
    } else if (senderId == 28) {
        if ([dropoff3View isHidden]) {
            [dropoff3View setHidden:NO];
            [ivDropoff2 setImage:imgDelete];
        } else {
            [dropoff3View setHidden:YES];
            dropoff3Marker.map = nil;
            [lblDropoff3 setText:@"  Please choose a drop off point"];
            [lblDropoff3 setTextColor:[UIColor grayColor]];
            [userPrefs setValue:@"" forKey:DROPOFF3_STRING];
            [userPrefs setFloat:0 forKey:DROPOFF3_LAT];
            [userPrefs setFloat:0 forKey:DROPOFF3_LNG];
            
            [userPrefs synchronize];
            [ivDropoff2 setImage:imgAdd];
        }
    }
}

- (void)nextPage {
    NSString *dropoff1String = [userPrefs stringForKey:DROPOFF1_STRING];
    if (canProceed || (![dropoff1String  isEqual: @""] && dropoff1String != nil)) {
        [self performSegueWithIdentifier:@"toContractDetails" sender:self];
    } else {
        UIAlertController *cannotProceedAlert = [UIAlertController alertControllerWithTitle:@"Error!"
                                                                                    message:@"Please choose at least 1 point for drop off."
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
