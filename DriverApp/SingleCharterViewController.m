//
//  DriverApp
//
//  Created by KangJie Lim on 13/9/17.
//  Copyright © 2017 Commute-Solutions. All rights reserved.
//

#import "SingleCharterViewController.h"

@interface SingleCharterViewController ()
@property (strong, nonatomic) NSArray<NSDictionary *> *drivers;
@property (strong, nonatomic) NSArray<NSString *> *reasons;
@end

@implementation SingleCharterViewController
NSUserDefaults *userPrefs;
NSString *token;

BOOL isMyCharter;
BOOL isAccepted;
BOOL isCancelled;
BOOL isDisputable;
BOOL isCompleted;
BOOL canResubmit;
BOOL isReposted;

NSString *charterType;
NSString *charterAccessCode;
NSString *charterDate;
NSString *charterCost;
NSNumber *charterBusCapacity;
NSString *charterRemarks;
NSNumber *charterDisposalDuration;

NSArray *charterTime;
NSArray *charterStartName;
NSArray *charterStartLat;
NSArray *charterStartLon;
NSArray *charterEndName;
NSArray *charterEndLat;
NSArray *charterEndLon;

NSString *pocName;
NSString *pocContactNo;
NSString *pocNewName;
NSString *pocNewContactNo;
NSString *driverId;
NSString *driverName;
NSString *driverNameDetail;
NSString *driverVehicleNo;
NSString *driverContactNo;
NSString *trackingURL;

NSString *disputeProblem;
NSString *compensationAmount;
NSString *newCharterCost;
NSString *senderDesc;
NSString *reason;
NSString *message;
BOOL isSuccessful;
UILabel *lblSelectedRow;

- (void)loadView {
    [super loadView];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[[UIView alloc] init]];
    UIBarButtonItem *btnBack = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(toPreviousController)];
    [btnBack setTintColor:[UIColor whiteColor]];
    self.navigationItem.leftBarButtonItem = btnBack;
    self.singleMapView.delegate = self;
    self.charterDetailsView.delegate = self;
}

- (void)viewDidLoad {
    userPrefs = [NSUserDefaults standardUserDefaults];
    token = [userPrefs stringForKey:AUTHENTICATION_TOKEN];
    [self initialiseValues];
    [self retreiveCharterDetails];
    
    [_singleMapView animateToLocation:CLLocationCoordinate2DMake(1.360405, 103.819363)];
    [_singleMapView.settings setScrollGestures:NO];
    GMSMarker *pickupMarker = [[GMSMarker alloc] init];
    UIImage *ivPickupMarker = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"green_marker" ofType:@"png"]];
    pickupMarker.icon = ivPickupMarker;
    pickupMarker.position = CLLocationCoordinate2DMake([[charterStartLat objectAtIndex:0] doubleValue], [[charterStartLon objectAtIndex:0] doubleValue]);
    pickupMarker.map = _singleMapView;
    
    GMSMarker *dropoffMarker = [[GMSMarker alloc] init];
    UIImage *ivDropoffMarker = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"blue_marker" ofType:@"png"]];
    dropoffMarker.icon = ivDropoffMarker;
    dropoffMarker.position = CLLocationCoordinate2DMake([[charterEndLat objectAtIndex:0] doubleValue], [[charterEndLon objectAtIndex:0] doubleValue]);
    dropoffMarker.map = _singleMapView;
    
    [self.singleMapView animateToLocation:CLLocationCoordinate2DMake(1.360405, 103.819363)];
    [self.singleMapView animateToZoom:10.0];
    
//    [_charterDetailsView setContentInset:UIEdgeInsetsMake(0, 5, 5, 5)];
    [_charterDetailsView setContentSize:CGSizeMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    
    CGFloat scrollViewHeight = _charterDetailsView.bounds.size.height;
    CGFloat scrollViewWidth = _charterDetailsView.bounds.size.width;
    
    UILabel *lblCharterId = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, scrollViewWidth, 20)];
    [lblCharterId setText:[NSString stringWithFormat:@"ID: %@", charterAccessCode]];
    [lblCharterId setFont: [UIFont fontWithName:@"HelveticaNeue-Bold" size:15]];
    [_charterDetailsView addSubview:lblCharterId];
    
    UILabel *lblCharterDate = [[UILabel alloc] initWithFrame:CGRectMake(5, 25, scrollViewWidth, 20)];
    [lblCharterDate setText:[NSString stringWithFormat:@"%@, %@", charterDate, [charterTime objectAtIndex:0]]];
    [lblCharterDate setFont: [UIFont fontWithName:@"HelveticaNeue-Bold" size:15]];
    [_charterDetailsView addSubview:lblCharterDate];
    
    UILabel *lblFrom = [[UILabel alloc] initWithFrame:CGRectMake(5, 50, scrollViewWidth, 20)];
    [lblFrom setText:@"From:"];
    [lblFrom setFont: [UIFont fontWithName:@"HelveticaNeue-Bold" size:15]];
    [lblFrom setTextColor:[UIColor greenColor]];
    UIButton *btnStartName = [UIButton buttonWithType: UIButtonTypeRoundedRect];
    [btnStartName setTitle:[charterStartName objectAtIndex:0] forState:UIControlStateNormal];
    [btnStartName addTarget:self action:@selector(openStartLocationInGoogleMap:) forControlEvents:UIControlEventTouchDown];
    btnStartName.frame = CGRectMake(5, 50, scrollViewWidth, 20);
    [_charterDetailsView addSubview:lblFrom];
    [_charterDetailsView addSubview:btnStartName];
    
    UILabel *lblTo = [[UILabel alloc] initWithFrame:CGRectMake(5, 75, scrollViewWidth, 20)];
    [lblTo setText:@"To:"];
    [lblTo setFont: [UIFont fontWithName:@"HelveticaNeue-Bold" size:15]];
    [lblTo setTextColor:[UIColor blueColor]];
    UIButton *btnEndName = [UIButton buttonWithType: UIButtonTypeRoundedRect];
    [btnEndName setTitle:[charterEndName objectAtIndex:0] forState:UIControlStateNormal];
    [btnEndName addTarget:self action:@selector(openEndLocationInGoogleMap:) forControlEvents:UIControlEventTouchDown];
    btnEndName.frame = CGRectMake(5, 75, scrollViewWidth, 20);
    [_charterDetailsView addSubview:lblTo];
    [_charterDetailsView addSubview:btnEndName];
    
    if ([charterStartName count] > 1) {
        UILabel *lblAdditionalPickUpPoints = [[UILabel alloc] initWithFrame:CGRectMake(5, 100, scrollViewWidth - 20, 100)];
        [lblAdditionalPickUpPoints setNumberOfLines:0];
        [lblAdditionalPickUpPoints setFont: [UIFont fontWithName:@"HelveticaNeue-Bold" size:15]];
        NSString *allPickUpPointsName = @"Additional Pick-Up Points\n";
        for (int i = 1; i < [charterStartName count]; i++) {
            allPickUpPointsName = [allPickUpPointsName stringByAppendingString:[NSString stringWithFormat:@"- %@\n", [charterStartName objectAtIndex:i]]];
        }
        [lblAdditionalPickUpPoints setText:allPickUpPointsName];
        [_charterDetailsView addSubview:lblAdditionalPickUpPoints];
        if ([charterEndName count] > 1) {
            UILabel *lblAdditionalDropOffPoints = [[UILabel alloc] initWithFrame:CGRectMake(5, 175, scrollViewWidth - 20, 100)];
            [lblAdditionalDropOffPoints setNumberOfLines:0];
            [lblAdditionalDropOffPoints setFont: [UIFont fontWithName:@"HelveticaNeue-Bold" size:15]];
            NSString *allDropOffPointsName = @"Additional Drop-Off Points\n";
            for (int i = 1; i < [charterEndName count]; i++) {
                allDropOffPointsName = [allDropOffPointsName stringByAppendingString:[NSString stringWithFormat:@"- %@\n", [charterEndName objectAtIndex:i]]];
            }
            [lblAdditionalDropOffPoints setText:allDropOffPointsName];
            [_charterDetailsView addSubview:lblAdditionalDropOffPoints];
            
            UILabel *lblBusCapacity = [[UILabel alloc] initWithFrame:CGRectMake(5, 250, scrollViewWidth, 20)];
            [lblBusCapacity setText:[NSString stringWithFormat:@"Bus Type: %@ - Seater", charterBusCapacity]];
            [lblBusCapacity setFont: [UIFont fontWithName:@"HelveticaNeue-Bold" size:15]];
            [_charterDetailsView addSubview:lblBusCapacity];
            
            if (![driverVehicleNo isEqualToString:@""]) {
                UILabel *lblVehicleNo = [[UILabel alloc] initWithFrame:CGRectMake(5, 275, scrollViewWidth, 20)];
                [lblVehicleNo setText:[NSString stringWithFormat:@"Vehicle No: %@", driverVehicleNo]];
                [lblVehicleNo setFont: [UIFont fontWithName:@"HelveticaNeue-Bold" size:15]];
                [_charterDetailsView addSubview:lblVehicleNo];
            }
        
            if ([charterDisposalDuration integerValue] > 3) {
                UILabel *lblDisposalHrs = [[UILabel alloc] initWithFrame:CGRectMake(5, 275, scrollViewWidth, 20)];
                [lblDisposalHrs setText:[NSString stringWithFormat:@"No. of Hrs(Disposal): %@", charterDisposalDuration]];
                [lblDisposalHrs setFont: [UIFont fontWithName:@"HelveticaNeue-Bold" size:15]];
                [_charterDetailsView addSubview:lblDisposalHrs];
                
                UILabel *lblRemarks = [[UILabel alloc] initWithFrame:CGRectMake(5, 300, scrollViewWidth - 20, 100)];
                [lblRemarks setNumberOfLines:0];
                if ([charterRemarks length] == 0) {
                    [lblRemarks setText:@"Additional Information: No extra information"];
                } else {
                    [lblRemarks setText:[NSString stringWithFormat:@"Additional Information: %@", charterRemarks]];
                }
                [lblRemarks setFont: [UIFont fontWithName:@"HelveticaNeue-Bold" size:15]];
                [_charterDetailsView addSubview:lblRemarks];
            } else {
                UILabel *lblRemarks = [[UILabel alloc] initWithFrame:CGRectMake(5, 275, scrollViewWidth - 20, 100)];
                [lblRemarks setNumberOfLines:0];
                if ([charterRemarks length] == 0) {
                    [lblRemarks setText:@"Additional Information: No extra information"];
                } else {
                    [lblRemarks setText:[NSString stringWithFormat:@"Additional Information: %@", charterRemarks]];
                }
                [lblRemarks setFont: [UIFont fontWithName:@"HelveticaNeue-Bold" size:15]];
                [_charterDetailsView addSubview:lblRemarks];
            }
        } else {
            UILabel *lblBusCapacity = [[UILabel alloc] initWithFrame:CGRectMake(5, 175, scrollViewWidth, 20)];
            [lblBusCapacity setText:[NSString stringWithFormat:@"Bus Type: %@ - Seater", charterBusCapacity]];
            [lblBusCapacity setFont: [UIFont fontWithName:@"HelveticaNeue-Bold" size:15]];
            [_charterDetailsView addSubview:lblBusCapacity];
            
            if (![driverVehicleNo isEqualToString:@""]) {
                UILabel *lblVehicleNo = [[UILabel alloc] initWithFrame:CGRectMake(5, 200, scrollViewWidth, 20)];
                [lblVehicleNo setText:[NSString stringWithFormat:@"Vehicle No: %@", driverVehicleNo]];
                [lblVehicleNo setFont: [UIFont fontWithName:@"HelveticaNeue-Bold" size:15]];
                [_charterDetailsView addSubview:lblVehicleNo];
            }
            
            if ([charterDisposalDuration integerValue] > 3) {
                UILabel *lblDisposalHrs = [[UILabel alloc] initWithFrame:CGRectMake(5, 200, scrollViewWidth, 20)];
                [lblDisposalHrs setText:[NSString stringWithFormat:@"No. of Hrs(Disposal): %@", charterDisposalDuration]];
                [lblDisposalHrs setFont: [UIFont fontWithName:@"HelveticaNeue-Bold" size:15]];
                [_charterDetailsView addSubview:lblDisposalHrs];
                
                UILabel *lblRemarks = [[UILabel alloc] initWithFrame:CGRectMake(5, 225, scrollViewWidth - 20, 100)];
                [lblRemarks setNumberOfLines:0];
                if ([charterRemarks length] == 0) {
                    [lblRemarks setText:@"Additional Information: No extra information"];
                } else {
                    [lblRemarks setText:[NSString stringWithFormat:@"Additional Information: %@", charterRemarks]];
                }
                [lblRemarks setFont: [UIFont fontWithName:@"HelveticaNeue-Bold" size:15]];
                [_charterDetailsView addSubview:lblRemarks];
            } else {
                UILabel *lblRemarks = [[UILabel alloc] initWithFrame:CGRectMake(5, 200, scrollViewWidth - 20, 100)];
                [lblRemarks setNumberOfLines:0];
                if ([charterRemarks length] == 0) {
                    [lblRemarks setText:@"Additional Information: No extra information"];
                } else {
                    [lblRemarks setText:[NSString stringWithFormat:@"Additional Information: %@", charterRemarks]];
                }
                [lblRemarks setFont: [UIFont fontWithName:@"HelveticaNeue-Bold" size:15]];
                [_charterDetailsView addSubview:lblRemarks];
            }
        }
    } else {
        if ([charterEndName count] > 1) {
            UILabel *lblAdditionalDropOffPoints = [[UILabel alloc] initWithFrame:CGRectMake(5, 100, scrollViewWidth - 20, 100)];
            [lblAdditionalDropOffPoints setNumberOfLines:0];
            [lblAdditionalDropOffPoints setFont: [UIFont fontWithName:@"HelveticaNeue-Bold" size:15]];
            NSString *allDropOffPointsName = @"Additional Drop-Off Points\n";
            for (int i = 1; i < [charterEndName count]; i++) {
                allDropOffPointsName = [allDropOffPointsName stringByAppendingString:[NSString stringWithFormat:@"- %@\n", [charterEndName objectAtIndex:i]]];
            }
            [lblAdditionalDropOffPoints setText:allDropOffPointsName];
            [_charterDetailsView addSubview:lblAdditionalDropOffPoints];
            
            UILabel *lblBusCapacity = [[UILabel alloc] initWithFrame:CGRectMake(5, 175, scrollViewWidth, 20)];
            [lblBusCapacity setText:[NSString stringWithFormat:@"Bus Type: %@ - Seater", charterBusCapacity]];
            [lblBusCapacity setFont: [UIFont fontWithName:@"HelveticaNeue-Bold" size:15]];
            [_charterDetailsView addSubview:lblBusCapacity];
            
            if (![driverVehicleNo isEqualToString:@""]) {
                UILabel *lblVehicleNo = [[UILabel alloc] initWithFrame:CGRectMake(5, 200, scrollViewWidth, 20)];
                [lblVehicleNo setText:[NSString stringWithFormat:@"Vehicle No: %@", driverVehicleNo]];
                [lblVehicleNo setFont: [UIFont fontWithName:@"HelveticaNeue-Bold" size:15]];
                [_charterDetailsView addSubview:lblVehicleNo];
            }
            
            if ([charterDisposalDuration integerValue] > 3) {
                UILabel *lblDisposalHrs = [[UILabel alloc] initWithFrame:CGRectMake(5, 200, scrollViewWidth, 20)];
                [lblDisposalHrs setText:[NSString stringWithFormat:@"No. of Hrs(Disposal): %@", charterDisposalDuration]];
                [lblDisposalHrs setFont: [UIFont fontWithName:@"HelveticaNeue-Bold" size:15]];
                [_charterDetailsView addSubview:lblDisposalHrs];
                
                UILabel *lblRemarks = [[UILabel alloc] initWithFrame:CGRectMake(5, 225, scrollViewWidth - 20, 100)];
                [lblRemarks setNumberOfLines:0];
                if ([charterRemarks length] == 0) {
                    [lblRemarks setText:@"Additional Information: No extra information"];
                } else {
                    [lblRemarks setText:[NSString stringWithFormat:@"Additional Information: %@", charterRemarks]];
                }
                [lblRemarks setFont: [UIFont fontWithName:@"HelveticaNeue-Bold" size:15]];
                [_charterDetailsView addSubview:lblRemarks];
            } else {
                UILabel *lblRemarks = [[UILabel alloc] initWithFrame:CGRectMake(5, 200, scrollViewWidth - 20, 100)];
                [lblRemarks setNumberOfLines:0];
                if ([charterRemarks length] == 0) {
                    [lblRemarks setText:@"Additional Information: No extra information"];
                } else {
                    [lblRemarks setText:[NSString stringWithFormat:@"Additional Information: %@", charterRemarks]];
                }
                [lblRemarks setFont: [UIFont fontWithName:@"HelveticaNeue-Bold" size:15]];
                [_charterDetailsView addSubview:lblRemarks];
            }
        } else {
            UILabel *lblBusCapacity = [[UILabel alloc] initWithFrame:CGRectMake(5, 100, scrollViewWidth, 20)];
            [lblBusCapacity setText:[NSString stringWithFormat:@"Bus Type: %@ - Seater", charterBusCapacity]];
            [lblBusCapacity setFont: [UIFont fontWithName:@"HelveticaNeue-Bold" size:15]];
            [_charterDetailsView addSubview:lblBusCapacity];
            
            if (![driverVehicleNo isEqualToString:@""]) {
                UILabel *lblVehicleNo = [[UILabel alloc] initWithFrame:CGRectMake(5, 125, scrollViewWidth, 20)];
                [lblVehicleNo setText:[NSString stringWithFormat:@"Vehicle No: %@", driverVehicleNo]];
                [lblVehicleNo setFont: [UIFont fontWithName:@"HelveticaNeue-Bold" size:15]];
                [_charterDetailsView addSubview:lblVehicleNo];
            }
        
            if ([charterDisposalDuration integerValue] > 3) {
                UILabel *lblDisposalHrs = [[UILabel alloc] initWithFrame:CGRectMake(5, 125, scrollViewWidth, 20)];
                [lblDisposalHrs setText:[NSString stringWithFormat:@"No. of Hrs(Disposal): %@", charterDisposalDuration]];
                [lblDisposalHrs setFont: [UIFont fontWithName:@"HelveticaNeue-Bold" size:15]];
                [_charterDetailsView addSubview:lblDisposalHrs];
                
                UILabel *lblRemarks = [[UILabel alloc] initWithFrame:CGRectMake(5, 150, scrollViewWidth - 20, 100)];
                [lblRemarks setNumberOfLines:0];
                if ([charterRemarks length] == 0) {
                    [lblRemarks setText:@"Additional Information: No extra information"];
                } else {
                    [lblRemarks setText:[NSString stringWithFormat:@"Additional Information: %@", charterRemarks]];
                }
                [lblRemarks setFont: [UIFont fontWithName:@"HelveticaNeue-Bold" size:15]];
                [_charterDetailsView addSubview:lblRemarks];
            } else {
                UILabel *lblRemarks = [[UILabel alloc] initWithFrame:CGRectMake(5, 125, scrollViewWidth - 20, 100)];
                [lblRemarks setNumberOfLines:0];
                if ([charterRemarks length] == 0) {
                    [lblRemarks setText:@"Additional Information: No extra information"];
                } else {
                    [lblRemarks setText:[NSString stringWithFormat:@"Additional Information: %@", charterRemarks]];
                }
                [lblRemarks setFont: [UIFont fontWithName:@"HelveticaNeue-Bold" size:15]];
                [_charterDetailsView addSubview:lblRemarks];
            }
        }
    }

    if (!isMyCharter && ([_previousControllerView intValue] == 1)) {
        UIButton *btnAcceptJob = [UIButton buttonWithType: UIButtonTypeRoundedRect];
        [btnAcceptJob setTitle:@"Take The Job" forState:UIControlStateNormal];
        [btnAcceptJob setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btnAcceptJob.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:20]];
        [btnAcceptJob setBackgroundColor:[UIColor redColor]];
        [btnAcceptJob addTarget:self action:@selector(acceptJob) forControlEvents:UIControlEventTouchDown];
        [btnAcceptJob setFrame:CGRectMake(5, scrollViewHeight + 225, scrollViewWidth - 10, 33)];
        [_charterDetailsView addSubview:btnAcceptJob];
    } else {
        if ([_previousControllerView intValue] > 1) {
            if (![driverNameDetail isEqualToString:@""] || ![pocName isEqualToString:@""]) {
                UIButton *btnAdditionalInfo = [UIButton buttonWithType: UIButtonTypeRoundedRect];
                [btnAdditionalInfo setTitle:@"Driver/POC Info" forState:UIControlStateNormal];
                [btnAdditionalInfo setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                [btnAdditionalInfo.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:20]];
                [btnAdditionalInfo setBackgroundColor:[UIColor orangeColor]];
                [btnAdditionalInfo addTarget:self action:@selector(viewAdditionalInfo) forControlEvents:UIControlEventTouchDown];
                [btnAdditionalInfo setFrame:CGRectMake(5, scrollViewHeight + 180, scrollViewWidth - 10, 33)];
                [_charterDetailsView addSubview:btnAdditionalInfo];
            }
            UIButton *btnOtherOptions = [UIButton buttonWithType: UIButtonTypeRoundedRect];
            [btnOtherOptions setTitle:@"Additional Actions" forState:UIControlStateNormal];
            [btnOtherOptions setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [btnOtherOptions.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:20]];
            [btnOtherOptions setBackgroundColor:[UIColor orangeColor]];
            [btnOtherOptions addTarget:self action:@selector(otherOptions) forControlEvents:UIControlEventTouchDown];
            [btnOtherOptions setFrame:CGRectMake(5, scrollViewHeight + 225, scrollViewWidth - 10, 33)];
            [_charterDetailsView addSubview:btnOtherOptions];
        }
    }
}

- (void)toPreviousController {
    if ([_previousControllerView intValue] == 1) {
        AvailableCharterViewController *myController = [self.storyboard instantiateViewControllerWithIdentifier:@"AvailableCharterViewController"];
        [self.navigationController pushViewController:myController animated:YES];
    } else if ([_previousControllerView intValue] == 2) {
        JobsViewController *myController = [self.storyboard instantiateViewControllerWithIdentifier:@"JobsViewController"];
        myController.identifyingProperty = @"subout";
        [self.navigationController pushViewController:myController animated:YES];
    } else if ([_previousControllerView intValue] == 3) {
        JobsViewController *myController = [self.storyboard instantiateViewControllerWithIdentifier:@"JobsViewController"];
        myController.identifyingProperty = @"scheduled";
        [self.navigationController pushViewController:myController animated:YES];
    } else {
        CharterCreationViewController *myController = [self.storyboard instantiateViewControllerWithIdentifier:@"CharterCreationView"];
        [self.navigationController pushViewController:myController animated:YES];
    }
}

- (void)openStartLocationInGoogleMap:(id)sender {
    NSString *mlatitude = [charterStartLat objectAtIndex:0];
    NSString *mLongitude = [charterStartLon objectAtIndex:0];
    NSString *directionsRequest = [NSString stringWithFormat:@"http://maps.google.com/maps?q=%@,%@", mlatitude, mLongitude];
    NSURL *directionsURL = [NSURL URLWithString:directionsRequest];
    [[UIApplication sharedApplication] openURL:directionsURL];
}

- (void)openEndLocationInGoogleMap:(id)sender {
    NSString *mlatitude = [charterEndLat objectAtIndex:0];
    NSString *mLongitude = [charterEndLon objectAtIndex:0];
    NSString *directionsRequest = [NSString stringWithFormat:@"http://maps.google.com/maps?q=%@,%@", mlatitude, mLongitude];
    NSURL *directionsURL = [NSURL URLWithString:directionsRequest];
    [[UIApplication sharedApplication] openURL:directionsURL];
}

- (void)otherOptions {
    UIAlertController *successfulJobTakeAlert = [UIAlertController alertControllerWithTitle:@"Options"
                                                                                    message:@"Select an action below"
                                                                             preferredStyle:UIAlertControllerStyleAlert];
    if (isMyCharter) {
        if (!isCompleted) {
            UIAlertAction *aRemoveListing = [UIAlertAction
                                             actionWithTitle:@"Remove Listing"
                                             style:UIAlertActionStyleDefault
                                             handler:^(UIAlertAction * action) {
                                                 [self deleteJob];
                                             }];
            [successfulJobTakeAlert addAction:aRemoveListing];
            
            if ([_previousControllerView intValue] == 2 && isAccepted) {
                UIAlertAction *aEditPOC = [UIAlertAction
                                           actionWithTitle:@"Edit POC"
                                           style:UIAlertActionStyleDefault
                                           handler:^(UIAlertAction * action) {
                                               [self dismissViewControllerAnimated:YES completion:nil];
                                               [self editPOC];
                                           }];
                [successfulJobTakeAlert addAction:aEditPOC];
            }
            
            if (canResubmit) {
                UIAlertAction *aResubmit = [UIAlertAction
                                           actionWithTitle:@"Resubmit Charter"
                                           style:UIAlertActionStyleDefault
                                           handler:^(UIAlertAction * action) {
                                               [self dismissViewControllerAnimated:YES completion:nil];
                                               [self resubmitCharter];
                                           }];
                [successfulJobTakeAlert addAction:aResubmit];
            }
        }
    } else {
        if ([_previousControllerView intValue] == 2) {
            if (!isCompleted) {
                UIAlertAction *aRemoveListing = [UIAlertAction
                                                 actionWithTitle:@"Remove Listing"
                                                 style:UIAlertActionStyleDefault
                                                 handler:^(UIAlertAction * action) {
                                                     [self deleteJob];
                                                 }];
                [successfulJobTakeAlert addAction:aRemoveListing];
            }
            
            if (isAccepted) {
                UIAlertAction *aEditPOC = [UIAlertAction
                                           actionWithTitle:@"Edit POC"
                                           style:UIAlertActionStyleDefault
                                           handler:^(UIAlertAction * action) {
                                               [self dismissViewControllerAnimated:YES completion:nil];
                                               [self editPOC];
                                           }];
                [successfulJobTakeAlert addAction:aEditPOC];
            }
        } else if ([_previousControllerView intValue] == 3) {
            if (!isCompleted) {
                UIAlertAction *aWithdraw = [UIAlertAction
                                            actionWithTitle:@"Withdraw from Charter"
                                            style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * action) {
                                                [self withdrawJob];
                                            }];
                [successfulJobTakeAlert addAction:aWithdraw];
                
                UIAlertAction *aEditDriver = [UIAlertAction
                                              actionWithTitle:@"Edit Driver"
                                              style:UIAlertActionStyleDefault
                                              handler:^(UIAlertAction * action) {
                                                  [self dismissViewControllerAnimated:YES completion:nil];
                                                  [self editDriver];
                                              }];
                [successfulJobTakeAlert addAction:aEditDriver];
            }
        }
    }
    
    if (isDisputable) {
        UIAlertAction *aDispute = [UIAlertAction
                                      actionWithTitle:@"Apply for Dispute"
                                      style:UIAlertActionStyleDefault
                                      handler:^(UIAlertAction * action) {
                                          [self disputeJob];
                                      }];
        [successfulJobTakeAlert addAction:aDispute];
    }
    
    if (![trackingURL isEqualToString:@""] && !isCompleted) {
        UIAlertAction *aTracking = [UIAlertAction
                                   actionWithTitle:@"Generate Tracking URL"
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * action) {
                                       [self dismissViewControllerAnimated:YES completion:nil];
                                       [self openTrackingURL];
                                   }];
        [successfulJobTakeAlert addAction:aTracking];
    }
    
    UIAlertAction *aCancel = [UIAlertAction
                              actionWithTitle:@"Cancel"
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction * action) {
                                  [self dismissViewControllerAnimated:YES completion:nil];
                              }];
    [successfulJobTakeAlert addAction:aCancel];
    [self presentViewController:successfulJobTakeAlert animated:YES completion:nil];
}

- (void)openTrackingURL {
    UIAlertController *trackingLinkAlert = [UIAlertController alertControllerWithTitle:@"Tracking URL"
                                                                                 message:@"You can now view or copy the tracking URL below. The link can be shared with POC to provide tracking. Please note that tracking will only be turned on 15mins before the Pick Up Time."
                                                                          preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *aOpenTrackingURL = [UIAlertAction
                              actionWithTitle:@"Open in Web Browser Only"
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction * action) {
                                  [self dismissViewControllerAnimated:YES completion:nil];
                                  [[UIApplication sharedApplication] openURL:[NSURL URLWithString:trackingURL]];
                              }];
    UIAlertAction *aCopyTrackingURL = [UIAlertAction
                              actionWithTitle:@"Copy to Clipboard Only"
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction * action) {
                                  UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                                  pasteboard.string = trackingURL;
                                  [self dismissViewControllerAnimated:YES completion:nil];
                                  UIAlertController *confirmationAlert = [UIAlertController alertControllerWithTitle:@"Copied!"
                                                                                                             message:@""
                                                                                                      preferredStyle:UIAlertControllerStyleAlert];
                                  UIAlertAction *aConfirmation = [UIAlertAction
                                                        actionWithTitle:@"OK"
                                                        style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction * action) {
                                                            [self dismissViewControllerAnimated:YES completion:nil];
                                                        }];
                                  [confirmationAlert addAction:aConfirmation];
                                  [self presentViewController:confirmationAlert animated:YES completion:nil];
                              }];
    UIAlertAction *aCopyandOpenTrackingURL = [UIAlertAction
                                              actionWithTitle:@"Copy to Clipboard and Open in Web Browser"
                                              style:UIAlertActionStyleDefault
                                              handler:^(UIAlertAction * action) {
                                                  UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                                                  pasteboard.string = trackingURL;
                                                  [self dismissViewControllerAnimated:YES completion:nil];
                                                  [[UIApplication sharedApplication] openURL:[NSURL URLWithString:trackingURL]];
                                              }];
    UIAlertAction *aCancel = [UIAlertAction
                              actionWithTitle:@"Cancel"
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction * action) {
                                  [self dismissViewControllerAnimated:YES completion:nil];
                              }];
    [trackingLinkAlert addAction:aOpenTrackingURL];
    [trackingLinkAlert addAction:aCopyTrackingURL];
    [trackingLinkAlert addAction:aCopyandOpenTrackingURL];
    [trackingLinkAlert addAction:aCancel];
    [self presentViewController:trackingLinkAlert animated:YES completion:nil];
}

- (void)viewAdditionalInfo {
    UIAlertController *additionalInfoAlert = [UIAlertController alertControllerWithTitle:@"Driver/POC Info"
                                                                                    message:@"Select an action below"
                                                                             preferredStyle:UIAlertControllerStyleAlert];
    if (![driverNameDetail isEqualToString:@""]) {
        UIAlertAction *aContactDriver= [UIAlertAction
                                      actionWithTitle:[NSString stringWithFormat:@"Call %@(Driver)", driverNameDetail]
                                      style:UIAlertActionStyleDefault
                                      handler:^(UIAlertAction * action) {
                                          NSString *phoneStr = [NSString stringWithFormat:@"tel:%@", driverContactNo];
                                          NSURL *phoneURL = [[NSURL alloc] initWithString:phoneStr];
                                          [[UIApplication sharedApplication] openURL:phoneURL];
                                      }];
        [additionalInfoAlert addAction:aContactDriver];
    }
    
    if (![pocName isEqualToString:@""]) {
        UIAlertAction *aContactPOC = [UIAlertAction
                                      actionWithTitle:[NSString stringWithFormat:@"Call %@(POC)", pocName]
                                      style:UIAlertActionStyleDefault
                                      handler:^(UIAlertAction * action) {
                                          NSString *phoneStr = [NSString stringWithFormat:@"tel:%@", pocContactNo];
                                          NSURL *phoneURL = [[NSURL alloc] initWithString:phoneStr];
                                          [[UIApplication sharedApplication] openURL:phoneURL];
                                      }];
        [additionalInfoAlert addAction:aContactPOC];
    }
    
    UIAlertAction *aCancel = [UIAlertAction
                              actionWithTitle:@"Cancel"
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction * action) {
                                  [self dismissViewControllerAnimated:YES completion:nil];
                              }];
    [additionalInfoAlert addAction:aCancel];
    [self presentViewController:additionalInfoAlert animated:YES completion:nil];
}

- (void)editDriver {
    [self getDrivers];
    UIAlertController *selectDriverAlert = [UIAlertController alertControllerWithTitle:@"Attention!"
                                                                               message:[NSString stringWithFormat:@"%@\n\n\n", message]
                                                                        preferredStyle:UIAlertControllerStyleAlert];
    
    _navBarMenu = [[MKDropdownMenu alloc] initWithFrame:CGRectMake(0, 66, [UIScreen mainScreen].bounds.size.width - 50, 25)];
    _navBarMenu.dataSource = self;
    _navBarMenu.delegate = self;
    
    _navBarMenu.dropdownShowsTopRowSeparator = NO;
    _navBarMenu.dropdownBouncesScroll = NO;
    _navBarMenu.dropdownRoundedCorners = UIRectCornerAllCorners;
    
    _navBarMenu.rowSeparatorColor = [UIColor colorWithWhite:1.0 alpha:0.2];
    _navBarMenu.rowTextAlignment = NSTextAlignmentCenter;
    
    _navBarMenu.useFullScreenWidth = YES;
    _navBarMenu.fullScreenInsetLeft = 15;
    _navBarMenu.fullScreenInsetRight = 15;
    
    lblSelectedRow = [[UILabel alloc] initWithFrame:CGRectMake(15, 96, [UIScreen mainScreen].bounds.size.width - 65, 25)];
    [lblSelectedRow setText:@"Driver Selected: None"];
    [lblSelectedRow setFont: [UIFont fontWithName:@"HelveticaNeue" size:14]];
    
    UIAlertAction *aOk = [UIAlertAction
                          actionWithTitle:@"Choose this Driver"
                          style:UIAlertActionStyleDefault
                          handler:^(UIAlertAction * action) {
                              [self updateDriver];
                          }];
    UIAlertAction *aCancel = [UIAlertAction
                              actionWithTitle:@"Cancel"
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction * action) {
                                  driverId = nil;
                                  driverName = nil;
                                  [self dismissViewControllerAnimated:YES completion:nil];
                              }];
    [selectDriverAlert.view addSubview:_navBarMenu];
    [selectDriverAlert.view addSubview:lblSelectedRow];
    [selectDriverAlert addAction:aOk];
    [selectDriverAlert addAction:aCancel];
    [self presentViewController:selectDriverAlert animated:YES completion:nil];
}

- (void)editPOC {
    UIAlertController *editPOCAlert = [UIAlertController alertControllerWithTitle:@"Hello!"
                                                                       message:@"Please enter the new POC details. Leave blank if there are no change."
                                                                preferredStyle:UIAlertControllerStyleAlert];
    [editPOCAlert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.tag = 16;
        textField.delegate = self;
        textField.placeholder = @"Enter POC name here";
    }];
    
    [editPOCAlert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.tag = 17;
        textField.delegate = self;
        textField.keyboardType = UIKeyboardTypeNumberPad;
        textField.placeholder = @"Enter POC Contact Number";
    }];
    
    UIAlertAction *aSubmitNewPOCDetails = [UIAlertAction
                actionWithTitle:@"Submit"
                style:UIAlertActionStyleDefault
                handler:^(UIAlertAction * action) {
                    [self updatePOC];
                }];
    UIAlertAction *aCancelEdit = [UIAlertAction
                                  actionWithTitle:@"Cancel"
                                  style:UIAlertActionStyleDefault
                                  handler:^(UIAlertAction * action) {
                                      [self dismissViewControllerAnimated:YES completion:nil];
                                  }];
    
    [editPOCAlert addAction:aSubmitNewPOCDetails];
    [editPOCAlert addAction:aCancelEdit];
    [self presentViewController:editPOCAlert animated:YES completion:nil];
}

- (void)resubmitCharter {
    UIAlertController *updateCharterAlert = [UIAlertController alertControllerWithTitle:@"Hello!"
                                                                          message:@"Please enter a new sub out price. Leave blank if there are no change. Amount is in SGD($) "
                                                                   preferredStyle:UIAlertControllerStyleAlert];
    [updateCharterAlert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.tag = 22;
        textField.delegate = self;
        textField.placeholder = @"(Optional) eg. 200";
    }];
    
    UIAlertAction *aResubmitNewCharter = [UIAlertAction
                                           actionWithTitle:@"Resubmit"
                                           style:UIAlertActionStyleDefault
                                           handler:^(UIAlertAction * action) {
                                               [self updateJob];
                                           }];
    UIAlertAction *aCancelEdit = [UIAlertAction
                                  actionWithTitle:@"Cancel"
                                  style:UIAlertActionStyleDefault
                                  handler:^(UIAlertAction * action) {
                                      [self dismissViewControllerAnimated:YES completion:nil];
                                  }];
    
    [updateCharterAlert addAction:aResubmitNewCharter];
    [updateCharterAlert addAction:aCancelEdit];
    [self presentViewController:updateCharterAlert animated:YES completion:nil];
}

- (void)disputeJob {
    UIAlertController *disputeJobAlert = [UIAlertController alertControllerWithTitle:@"Report a problem"
                                                                          message:@"Please enter the problem you have encountered."
                                                                   preferredStyle:UIAlertControllerStyleAlert];
    [disputeJobAlert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.tag = 18;
        textField.delegate = self;
        textField.placeholder = @"Enter the problem you have encountered";
    }];
    
    [disputeJobAlert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.tag = 19;
        textField.delegate = self;
        textField.keyboardType = UIKeyboardTypeNumberPad;
        textField.placeholder = @"Enter the amount to be compensated - e.g $100";
    }];
    
    UIAlertAction *aComfirmDispute = [UIAlertAction
                                           actionWithTitle:@"Submit"
                                           style:UIAlertActionStyleDefault
                                           handler:^(UIAlertAction * action) {
                                               [self dismissViewControllerAnimated:YES completion:nil];
                                               [self confirmation];
                                           }];
    UIAlertAction *aCancelEdit = [UIAlertAction
                                  actionWithTitle:@"Cancel"
                                  style:UIAlertActionStyleDefault
                                  handler:^(UIAlertAction * action) {
                                      [self dismissViewControllerAnimated:YES completion:nil];
                                  }];
    
    [disputeJobAlert addAction:aComfirmDispute];
    [disputeJobAlert addAction:aCancelEdit];
    [self presentViewController:disputeJobAlert animated:YES completion:nil];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    NSInteger txtId = textField.tag;
    if (txtId == 16) {
        pocNewName = [textField.text stringByReplacingCharactersInRange:range withString:string];
    } else if (txtId == 17) {
        pocNewContactNo = [textField.text stringByReplacingCharactersInRange:range withString:string];
    } else if (txtId == 18) {
        disputeProblem = [textField.text stringByReplacingCharactersInRange:range withString:string];
    } else if (txtId == 19) {
        compensationAmount = [textField.text stringByReplacingCharactersInRange:range withString:string];
    } else if (txtId == 22) {
        newCharterCost = [textField.text stringByReplacingCharactersInRange:range withString:string];
    }
    return YES;
}

- (void)confirmation {
    NSString *confirmationMessage = @"Please check the details you have entered:\n";
    confirmationMessage = [confirmationMessage stringByAppendingString:disputeProblem];
    if (compensationAmount != nil && ![compensationAmount isEqualToString:@""]) {
        confirmationMessage = [confirmationMessage stringByAppendingString:@"\nAmount you wish to be compensated: $"];
        confirmationMessage = [confirmationMessage stringByAppendingString:compensationAmount];
    }

    UIAlertController *comfirmDisputeJobAlert = [UIAlertController alertControllerWithTitle:@"Report a problem"
                                                                             message:confirmationMessage
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *aSubmitNewDispute = [UIAlertAction
                                        actionWithTitle:@"Submit"
                                        style:UIAlertActionStyleDefault
                                        handler:^(UIAlertAction * action) {
                                            [self newDispute];
                                        }];
    UIAlertAction *aCancel = [UIAlertAction
                                  actionWithTitle:@"Cancel"
                                  style:UIAlertActionStyleDefault
                                  handler:^(UIAlertAction * action) {
                                      [self dismissViewControllerAnimated:YES completion:nil];
                                  }];
    
    [comfirmDisputeJobAlert addAction:aSubmitNewDispute];
    [comfirmDisputeJobAlert addAction:aCancel];
    [self presentViewController:comfirmDisputeJobAlert animated:YES completion:nil];
}

#pragma mark - MKDropdownMenuDataSource
- (NSInteger)numberOfComponentsInDropdownMenu:(MKDropdownMenu *)dropdownMenu {
    return 1;
}

- (NSInteger)dropdownMenu:(MKDropdownMenu *)dropdownMenu numberOfRowsInComponent:(NSInteger)component {
    if ([senderDesc isEqualToString:@"accept"]) {
        return [_drivers count];
    } else if ([senderDesc isEqualToString:@"delete"] || [senderDesc isEqualToString:@"withdraw"]) {
        return [_reasons count];
    } else {
        return 0;
    }
}

#pragma mark - MKDropdownMenuDelegate
- (NSString *)dropdownMenu:(MKDropdownMenu *)dropdownMenu titleForComponent:(NSInteger)component {
    if ([senderDesc isEqualToString:@"accept"]) {
        return @"Select Driver";
    } else if ([senderDesc isEqualToString:@"delete"] || [senderDesc isEqualToString:@"withdraw"]) {
        return @"Select Reason";
    } else {
        return @"~";
    }
}

- (NSString *)dropdownMenu:(MKDropdownMenu *)dropdownMenu titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if ([senderDesc isEqualToString:@"accept"]) {
        NSDictionary *aDriver = [_drivers objectAtIndex:row];
        NSString *name = [aDriver objectForKey:@"driverName"];
        return name;
    } else if ([senderDesc isEqualToString:@"delete"] || [senderDesc isEqualToString:@"withdraw"]) {
        NSString *aReason = [_reasons objectAtIndex:row];
        return aReason;
    } else {
        return @"~";
    }
}

- (UIColor *)dropdownMenu:(MKDropdownMenu *)dropdownMenu backgroundColorForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [UIColor whiteColor];
}

- (UIColor *)dropdownMenu:(MKDropdownMenu *)dropdownMenu backgroundColorForHighlightedRowsInComponent:(NSInteger)component {
    return [UIColor orangeColor];
}

- (void)dropdownMenu:(MKDropdownMenu *)dropdownMenu didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if ([senderDesc isEqualToString:@"accept"]) {
        NSDictionary *aDriver = [_drivers objectAtIndex:row];
        driverId = [aDriver objectForKey:@"driverId"];
        [lblSelectedRow setText:[NSString stringWithFormat:@"Driver Selected: %@", [aDriver objectForKey:@"driverName"]]];
    } else if ([senderDesc isEqualToString:@"delete"] || [senderDesc isEqualToString:@"withdraw"]) {
        reason = [_reasons objectAtIndex:row];
        [lblSelectedRow setText:[NSString stringWithFormat:@"➡️ %@", reason]];
    }
    [dropdownMenu closeAllComponentsAnimated:YES];
}

- (void)initialiseValues {
    _drivers = [[NSArray alloc] init];
    _reasons = [[NSArray alloc] init];
    
    isMyCharter = NO;
    isAccepted = NO;
    isCancelled = NO;
    isDisputable = NO;
    isCompleted = NO;
    isReposted = NO;
    
    charterType = nil;
    charterAccessCode = nil;
    charterDate = nil;
    charterCost = nil;
    charterBusCapacity = nil;
    charterRemarks = nil;
    charterDisposalDuration = nil;
    
    charterTime = nil;
    charterStartName = nil;
    charterStartLat = nil;
    charterStartLon = nil;
    charterEndName = nil;
    charterEndLat = nil;
    charterEndLon = nil;
    
    pocName = nil;
    pocContactNo = nil;
    pocNewName = @"";
    pocNewContactNo = @"";
    driverId = nil;
    driverName = nil;
    driverNameDetail = nil;
    driverVehicleNo = nil;
    driverContactNo = nil;
    trackingURL = nil;
    
    senderDesc = nil;
    message = nil;
    isSuccessful = NO;
}

#pragma mark - Retrieve Charter Details
- (void)retreiveCharterDetails {
    __block NSInteger success = 0;
    NSDictionary *charterIdData = [NSDictionary dictionaryWithObjectsAndKeys:
                              _charterId, @"busCharterId",
                              nil];
    NSDictionary *jsonData = [NSDictionary dictionaryWithObjectsAndKeys:
                              charterIdData, @"data",
                              nil];
    NSURL *url = [NSURL URLWithString:VIEW_CHARTER_URL];
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
            NSDictionary *charterDetails = [dataResponse objectForKey:@"details"];
            
            charterType = [charterDetails objectForKey:@"serviceType"];
            charterAccessCode = [charterDetails objectForKey:@"accessCode"];
            charterDate = [charterDetails objectForKey:@"date"];
            charterCost = [charterDetails objectForKey:@"cost"];
            charterBusCapacity = [charterDetails objectForKey:@"busType"];
            charterRemarks = [charterDetails objectForKey:@"remarks"];
            charterDisposalDuration = [charterDetails objectForKey:@"disposalDuration"];
            
            charterTime = [charterDetails objectForKey:@"time"];
            charterStartName = [charterDetails objectForKey:@"pickUpName"];
            charterStartLat = [charterDetails objectForKey:@"pickupLatitude"];
            charterStartLon = [charterDetails objectForKey:@"pickupLongitude"];
            charterEndName = [charterDetails objectForKey:@"dropOffName"];
            charterEndLat = [charterDetails objectForKey:@"dropOffLatitude"];
            charterEndLon = [charterDetails objectForKey:@"dropOffLongitude"];
            
            pocName = [charterDetails objectForKey:@"pocName"];
            pocContactNo = [charterDetails objectForKey:@"pocContactNo"];
            driverNameDetail = [charterDetails objectForKey:@"driverName"];
            driverVehicleNo = [charterDetails objectForKey:@"vehicleNo"];
            driverContactNo = [charterDetails objectForKey:@"driverContact"];
            trackingURL = [charterDetails objectForKey:@"url"];
            
            NSNumber *numToBool = [charterDetails objectForKey:@"isMyCharter"];
            isMyCharter = [numToBool boolValue];
            numToBool = [charterDetails objectForKey:@"isAccepted"];
            isAccepted = [numToBool boolValue];
            numToBool = [charterDetails objectForKey:@"isCancelled"];
            isCancelled = [numToBool boolValue];
            numToBool = [charterDetails objectForKey:@"isDisputable"];
            isDisputable = [numToBool boolValue];
            numToBool = [charterDetails objectForKey:@"isCompleted"];
            isCompleted = [numToBool boolValue];
            numToBool = [charterDetails objectForKey:@"canResubmit"];
            canResubmit = [numToBool boolValue];
            numToBool = [charterDetails objectForKey:@"isReposted"];
            isReposted = [numToBool boolValue];
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

#pragma mark - Accept Job
- (void)acceptJob {
    __block NSInteger success = 0;
    NSDictionary *charterIdData;
    _drivers = [[NSArray alloc] init];
    if (driverId == nil) {
        charterIdData = [NSDictionary dictionaryWithObjectsAndKeys:
                         _charterId, @"busCharterId",
                         nil];
    } else {
        charterIdData = [NSDictionary dictionaryWithObjectsAndKeys:
                         _charterId, @"busCharterId",
                         driverId, @"driverId",
                         nil];
    }
    NSDictionary *jsonData = [NSDictionary dictionaryWithObjectsAndKeys:
                              charterIdData, @"data",
                              nil];
    NSURL *url = [NSURL URLWithString:ACCEPT_CHARTER_URL];
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
            NSNumber *numToBool = [dataResponse objectForKey:@"success"];
            isSuccessful = [numToBool boolValue];
            senderDesc = @"accept";
            _drivers = [dataResponse objectForKey:@"driversList"];
            message = [dataResponse objectForKey:@"message"];
            [self performSuccessfulOperation];
        } else {
            UIAlertController *unSuccessfulJobTakeAlert = [UIAlertController alertControllerWithTitle:@"Error!"
                                                                                              message:message
                                                                                       preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *aOk = [UIAlertAction
                                  actionWithTitle:@"OK"
                                  style:UIAlertActionStyleDefault
                                  handler:^(UIAlertAction * action) {
                                      [self dismissViewControllerAnimated:YES completion:nil];
                                  }];
            [unSuccessfulJobTakeAlert addAction:aOk];
            [self presentViewController:unSuccessfulJobTakeAlert animated:YES completion:nil];
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

#pragma mark - Delete Job
- (void)deleteJob {
    __block NSInteger success = 0;
    NSDictionary *charterIdData;
    _reasons = [[NSArray alloc] init];
    if (reason == nil) {
        charterIdData = [NSDictionary dictionaryWithObjectsAndKeys:
                         _charterId, @"busCharterId",
                         nil];
    } else {
        charterIdData = [NSDictionary dictionaryWithObjectsAndKeys:
                         _charterId, @"busCharterId",
                         reason, @"reasons",
                         nil];
    }
    NSDictionary *jsonData = [NSDictionary dictionaryWithObjectsAndKeys:
                              charterIdData, @"data",
                              nil];
    NSURL *url = [NSURL URLWithString:CANCEL_CHARTER_URL];
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
            NSNumber *numToBool = [dataResponse objectForKey:@"success"];
            isSuccessful = [numToBool boolValue];
            senderDesc = @"delete";
            _reasons = [dataResponse objectForKey:@"reasons"];
            message = [dataResponse objectForKey:@"message"];
            [self performSuccessfulOperation];
        } else {
            UIAlertController *unSuccessfulJobDeleteAlert = [UIAlertController alertControllerWithTitle:@"Error!"
                                                                                              message:message
                                                                                       preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *aOk = [UIAlertAction
                                  actionWithTitle:@"OK"
                                  style:UIAlertActionStyleDefault
                                  handler:^(UIAlertAction * action) {
                                      [self dismissViewControllerAnimated:YES completion:nil];
                                  }];
            [unSuccessfulJobDeleteAlert addAction:aOk];
            [self presentViewController:unSuccessfulJobDeleteAlert animated:YES completion:nil];
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

#pragma mark - Update Job
- (void)updateJob {
    __block NSInteger success = 0;
    NSDictionary *charterData = [NSDictionary dictionaryWithObjectsAndKeys:
                                _charterId, @"busCharterId",
                                newCharterCost, @"cost",
                                nil];
    
    NSDictionary *jsonData = [NSDictionary dictionaryWithObjectsAndKeys:
                              charterData, @"data",
                              nil];
    
    NSURL *url = [NSURL URLWithString:UPDATE_CHARTER_URL];
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
                                                  [self toPreviousController];
                                              }];
            [confirmationAlert addAction:aCloseAlertView];
            [self presentViewController:confirmationAlert animated:YES completion:nil];
        } else {
            UIAlertController *cannotProceedAlert = [UIAlertController alertControllerWithTitle:@"Error!"
                                                                                        message:@"Unable to verify transaction. Card is not modified. Please try again."
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

#pragma mark - Withdraw Job
- (void) withdrawJob {
    __block NSInteger success = 0;
    NSDictionary *charterIdData;
    _reasons = [[NSArray alloc] init];
    if (reason == nil) {
        charterIdData = [NSDictionary dictionaryWithObjectsAndKeys:
                         _charterId, @"busCharterId",
                         nil];
    } else {
        charterIdData = [NSDictionary dictionaryWithObjectsAndKeys:
                         _charterId, @"busCharterId",
                         reason, @"reasons",
                         nil];
    }
    NSDictionary *jsonData = [NSDictionary dictionaryWithObjectsAndKeys:
                              charterIdData, @"data",
                              nil];
    NSURL *url = [NSURL URLWithString:WITHDRAW_CHARTER_URL];
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
            NSNumber *numToBool = [dataResponse objectForKey:@"success"];
            isSuccessful = [numToBool boolValue];
            senderDesc = @"withdraw";
            _reasons = [dataResponse objectForKey:@"reasons"];
            message = [dataResponse objectForKey:@"message"];
            [self performSuccessfulOperation];
        } else {
            UIAlertController *unSuccessfulJobDeleteAlert = [UIAlertController alertControllerWithTitle:@"Error!"
                                                                                                message:message
                                                                                         preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *aOk = [UIAlertAction
                                  actionWithTitle:@"OK"
                                  style:UIAlertActionStyleDefault
                                  handler:^(UIAlertAction * action) {
                                      [self dismissViewControllerAnimated:YES completion:nil];
                                  }];
            [unSuccessfulJobDeleteAlert addAction:aOk];
            [self presentViewController:unSuccessfulJobDeleteAlert animated:YES completion:nil];
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

#pragma mark - Get Driver
- (void)getDrivers {
    __block NSInteger success = 0;
    _drivers = [[NSArray alloc] init];
    if (token != nil && token != NULL) {
        NSURL *url = [NSURL URLWithString:GET_DRIVER_URL];
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
            if (success == 1) {
                NSDictionary *dataResponse = [jsonResponse objectForKey:@"data"];
                _drivers = [dataResponse objectForKey:@"driversList"];
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

#pragma mark - Update Driver
- (void)updateDriver {
    __block NSInteger success = 0;
    NSDictionary *driverData = [NSDictionary dictionaryWithObjectsAndKeys:
                                 _charterId, @"busCharterId",
                                 driverId, @"driverId",
                                 nil];
    
    NSDictionary *jsonData = [NSDictionary dictionaryWithObjectsAndKeys:
                              driverData, @"data",
                              nil];
    if (token != nil && token != NULL) {
        NSURL *url = [NSURL URLWithString:UPDATE_DRIVER_URL];
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
                NSInteger driverChanged = [dataResponse[@"success"] integerValue];
                if (driverChanged == 1) {
                    UIAlertAction *aCloseAlertView = [UIAlertAction
                                                      actionWithTitle:@"OK"
                                                      style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * action) {
                                                          [self toPreviousController];
                                                      }];
                    [confirmationAlert addAction:aCloseAlertView];
                } else {
                    UIAlertAction *aCloseAlertView = [UIAlertAction
                                                      actionWithTitle:@"OK"
                                                      style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * action) {
                                                          [self dismissViewControllerAnimated:YES completion:nil];
                                                      }];
                    [confirmationAlert addAction:aCloseAlertView];
                }
                [self presentViewController:confirmationAlert animated:YES completion:nil];
            } else {
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

#pragma mark - Update POC
- (void)updatePOC {
    __block NSInteger success = 0;
    NSDictionary *pocData = [NSDictionary dictionaryWithObjectsAndKeys:
                                 _charterId, @"busCharterId",
                                pocNewName, @"pocName",
                                pocNewContactNo, @"pocContactNo",
                                nil];
    
    NSDictionary *jsonData = [NSDictionary dictionaryWithObjectsAndKeys:
                              pocData, @"data",
                              nil];
    if (token != nil && token != NULL) {
        NSURL *url = [NSURL URLWithString:UPDATE_POC_URL];
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
                NSInteger pocChanged = [dataResponse[@"success"] integerValue];
                if (pocChanged == 1) {
                    UIAlertAction *aCloseAlertView = [UIAlertAction
                                                      actionWithTitle:@"OK"
                                                      style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * action) {
                                                          [self toPreviousController];
                                                      }];
                    [confirmationAlert addAction:aCloseAlertView];
                } else {
                    UIAlertAction *aCloseAlertView = [UIAlertAction
                                                      actionWithTitle:@"OK"
                                                      style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * action) {
                                                          [self dismissViewControllerAnimated:YES completion:nil];
                                                      }];
                    [confirmationAlert addAction:aCloseAlertView];
                }
                [self presentViewController:confirmationAlert animated:YES completion:nil];
            } else {
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

#pragma mark - Submit New Dispute
- (void)newDispute {
    __block NSInteger success = 0;
    NSDictionary *disputeData = [NSDictionary dictionaryWithObjectsAndKeys:
                                _charterId, @"id",
                                disputeProblem, @"reasons",
                                compensationAmount , @"cost",
                                nil];
    
    NSDictionary *jsonData = [NSDictionary dictionaryWithObjectsAndKeys:
                              disputeData, @"data",
                              nil];
    
    if (token != nil && token != NULL) {
        NSURL *url = [NSURL URLWithString:NEW_DISPUTE_URL];
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
                NSInteger pocChanged = [dataResponse[@"success"] integerValue];
                if (pocChanged == 1) {
                    UIAlertAction *aCloseAlertView = [UIAlertAction
                                                      actionWithTitle:@"OK"
                                                      style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * action) {
                                                          [self toPreviousController];
                                                      }];
                    [confirmationAlert addAction:aCloseAlertView];
                } else {
                    UIAlertAction *aCloseAlertView = [UIAlertAction
                                                      actionWithTitle:@"OK"
                                                      style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * action) {
                                                          [self dismissViewControllerAnimated:YES completion:nil];
                                                      }];
                    [confirmationAlert addAction:aCloseAlertView];
                }
                [self presentViewController:confirmationAlert animated:YES completion:nil];
            } else {
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

- (void)performSuccessfulOperation {
    if ([senderDesc isEqualToString:@"accept"]) {
        if ([_drivers count] == 0) {
            if (isSuccessful) {
                UIAlertController *successfulJobTakeAlert = [UIAlertController alertControllerWithTitle:@"Congratulations!"
                                                                                                message:message
                                                                                         preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *aOk = [UIAlertAction
                                      actionWithTitle:@"OK"
                                      style:UIAlertActionStyleDefault
                                      handler:^(UIAlertAction * action) {
                                          [self toPreviousController];
                                      }];
                [successfulJobTakeAlert addAction:aOk];
                [self presentViewController:successfulJobTakeAlert animated:YES completion:nil];
            } else {
                UIAlertController *unSuccessfulJobTakeAlert = [UIAlertController alertControllerWithTitle:@"Error!"
                                                                                                  message:message
                                                                                           preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *aOk = [UIAlertAction
                                      actionWithTitle:@"OK"
                                      style:UIAlertActionStyleDefault
                                      handler:^(UIAlertAction * action) {
                                          [self dismissViewControllerAnimated:YES completion:nil];
                                      }];
                [unSuccessfulJobTakeAlert addAction:aOk];
                [self presentViewController:unSuccessfulJobTakeAlert animated:YES completion:nil];
            }
        } else {
            UIAlertController *selectDriverAlert = [UIAlertController alertControllerWithTitle:@"Attention!"
                                                                                       message:[NSString stringWithFormat:@"%@\n\n\n", message]
                                                                                preferredStyle:UIAlertControllerStyleAlert];
            
            _navBarMenu = [[MKDropdownMenu alloc] initWithFrame:CGRectMake(0, 66, [UIScreen mainScreen].bounds.size.width - 50, 25)];
            _navBarMenu.dataSource = self;
            _navBarMenu.delegate = self;
            
            _navBarMenu.dropdownShowsTopRowSeparator = NO;
            _navBarMenu.dropdownBouncesScroll = NO;
            _navBarMenu.dropdownRoundedCorners = UIRectCornerAllCorners;
            
            _navBarMenu.rowSeparatorColor = [UIColor colorWithWhite:1.0 alpha:0.2];
            _navBarMenu.rowTextAlignment = NSTextAlignmentCenter;
            
            _navBarMenu.useFullScreenWidth = YES;
            _navBarMenu.fullScreenInsetLeft = 15;
            _navBarMenu.fullScreenInsetRight = 15;
            
            lblSelectedRow = [[UILabel alloc] initWithFrame:CGRectMake(15, 96, [UIScreen mainScreen].bounds.size.width - 65, 25)];
            [lblSelectedRow setText:@"Driver Selected: None"];
            [lblSelectedRow setFont: [UIFont fontWithName:@"HelveticaNeue" size:14]];
            
            UIAlertAction *aOk = [UIAlertAction
                                  actionWithTitle:@"Choose this Driver"
                                  style:UIAlertActionStyleDefault
                                  handler:^(UIAlertAction * action) {
                                      [self acceptJob];
                                  }];
            UIAlertAction *aCancel = [UIAlertAction
                                      actionWithTitle:@"Cancel"
                                      style:UIAlertActionStyleDefault
                                      handler:^(UIAlertAction * action) {
                                          driverId = nil;
                                          driverName = nil;
                                          [self dismissViewControllerAnimated:YES completion:nil];
                                      }];
            [selectDriverAlert.view addSubview:_navBarMenu];
            [selectDriverAlert.view addSubview:lblSelectedRow];
            [selectDriverAlert addAction:aOk];
            [selectDriverAlert addAction:aCancel];
            [self presentViewController:selectDriverAlert animated:YES completion:nil];
        }
    } else if ([senderDesc isEqualToString:@"delete"]) {
        if ([_reasons count] == 0) {
            if (isSuccessful) {
                UIAlertController *successfulJobDeleteAlert = [UIAlertController alertControllerWithTitle:@"Attention!"
                                                                                                message:message
                                                                                         preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *aOk = [UIAlertAction
                                      actionWithTitle:@"OK"
                                      style:UIAlertActionStyleDefault
                                      handler:^(UIAlertAction * action) {
                                          [self toPreviousController];
                                      }];
                [successfulJobDeleteAlert addAction:aOk];
                [self presentViewController:successfulJobDeleteAlert animated:YES completion:nil];
            } else {
                UIAlertController *unSuccessfulJobDeleteAlert = [UIAlertController alertControllerWithTitle:@"Error!"
                                                                                                  message:message
                                                                                           preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *aOk = [UIAlertAction
                                      actionWithTitle:@"OK"
                                      style:UIAlertActionStyleDefault
                                      handler:^(UIAlertAction * action) {
                                          [self dismissViewControllerAnimated:YES completion:nil];
                                      }];
                [unSuccessfulJobDeleteAlert addAction:aOk];
                [self presentViewController:unSuccessfulJobDeleteAlert animated:YES completion:nil];
            }
        } else {
            UIAlertController *selectDeleteReasonAlert = [UIAlertController alertControllerWithTitle:@"Attention!"
                                                                                       message:[NSString stringWithFormat:@"%@\n\n\n", message]
                                                                                preferredStyle:UIAlertControllerStyleAlert];
            
            _navBarMenu = [[MKDropdownMenu alloc] initWithFrame:CGRectMake(0, 115, [UIScreen mainScreen].bounds.size.width - 50, 25)];
            _navBarMenu.dataSource = self;
            _navBarMenu.delegate = self;
            
            _navBarMenu.dropdownShowsTopRowSeparator = NO;
            _navBarMenu.dropdownBouncesScroll = NO;
            _navBarMenu.dropdownRoundedCorners = UIRectCornerAllCorners;
            
            _navBarMenu.rowSeparatorColor = [UIColor colorWithWhite:1.0 alpha:0.2];
            _navBarMenu.rowTextAlignment = NSTextAlignmentCenter;
            
            _navBarMenu.useFullScreenWidth = YES;
            _navBarMenu.fullScreenInsetLeft = 15;
            _navBarMenu.fullScreenInsetRight = 15;
            
            lblSelectedRow = [[UILabel alloc] initWithFrame:CGRectMake(15, 140, [UIScreen mainScreen].bounds.size.width - 65, 25)];
            [lblSelectedRow setText:@"\n"];
            [lblSelectedRow setFont: [UIFont fontWithName:@"HelveticaNeue" size:14]];
            
            UIAlertAction *aOk = [UIAlertAction
                                  actionWithTitle:@"Proceed"
                                  style:UIAlertActionStyleDefault
                                  handler:^(UIAlertAction * action) {
                                      [self deleteJob];
                                  }];
            UIAlertAction *aCancel = [UIAlertAction
                                      actionWithTitle:@"Cancel"
                                      style:UIAlertActionStyleDefault
                                      handler:^(UIAlertAction * action) {
                                          reason = nil;
                                          [self dismissViewControllerAnimated:YES completion:nil];
                                      }];
            [selectDeleteReasonAlert.view addSubview:_navBarMenu];
            [selectDeleteReasonAlert.view addSubview:lblSelectedRow];
            [selectDeleteReasonAlert addAction:aOk];
            [selectDeleteReasonAlert addAction:aCancel];
            [self presentViewController:selectDeleteReasonAlert animated:YES completion:nil];
        }
    } else if ([senderDesc isEqualToString:@"withdraw"]) {
        if ([_reasons count] == 0) {
            if (isSuccessful) {
                UIAlertController *successfulJobDeleteAlert = [UIAlertController alertControllerWithTitle:@"Attention!"
                                                                                                  message:message
                                                                                           preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *aOk = [UIAlertAction
                                      actionWithTitle:@"OK"
                                      style:UIAlertActionStyleDefault
                                      handler:^(UIAlertAction * action) {
                                          [self toPreviousController];
                                      }];
                [successfulJobDeleteAlert addAction:aOk];
                [self presentViewController:successfulJobDeleteAlert animated:YES completion:nil];
            } else {
                UIAlertController *unSuccessfulJobDeleteAlert = [UIAlertController alertControllerWithTitle:@"Error!"
                                                                                                    message:message
                                                                                             preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *aOk = [UIAlertAction
                                      actionWithTitle:@"OK"
                                      style:UIAlertActionStyleDefault
                                      handler:^(UIAlertAction * action) {
                                          [self dismissViewControllerAnimated:YES completion:nil];
                                      }];
                [unSuccessfulJobDeleteAlert addAction:aOk];
                [self presentViewController:unSuccessfulJobDeleteAlert animated:YES completion:nil];
            }
        } else {
            UIAlertController *selectDeleteReasonAlert = [UIAlertController alertControllerWithTitle:@"Attention!"
                                                                                             message:[NSString stringWithFormat:@"%@\n\n\n", message]
                                                                                      preferredStyle:UIAlertControllerStyleAlert];
            
            _navBarMenu = [[MKDropdownMenu alloc] initWithFrame:CGRectMake(0, 88, [UIScreen mainScreen].bounds.size.width - 50, 25)];
            _navBarMenu.dataSource = self;
            _navBarMenu.delegate = self;
            
            _navBarMenu.dropdownShowsTopRowSeparator = NO;
            _navBarMenu.dropdownBouncesScroll = NO;
            _navBarMenu.dropdownRoundedCorners = UIRectCornerAllCorners;
            
            _navBarMenu.rowSeparatorColor = [UIColor colorWithWhite:1.0 alpha:0.2];
            _navBarMenu.rowTextAlignment = NSTextAlignmentCenter;
            
            _navBarMenu.useFullScreenWidth = YES;
            _navBarMenu.fullScreenInsetLeft = 15;
            _navBarMenu.fullScreenInsetRight = 15;
            
            lblSelectedRow = [[UILabel alloc] initWithFrame:CGRectMake(15, 113, [UIScreen mainScreen].bounds.size.width - 65, 25)];
            [lblSelectedRow setText:@"\n"];
            [lblSelectedRow setFont: [UIFont fontWithName:@"HelveticaNeue" size:14]];
            
            UIAlertAction *aOk = [UIAlertAction
                                  actionWithTitle:@"Proceed"
                                  style:UIAlertActionStyleDefault
                                  handler:^(UIAlertAction * action) {
                                      [self withdrawJob];
                                  }];
            UIAlertAction *aCancel = [UIAlertAction
                                      actionWithTitle:@"Cancel"
                                      style:UIAlertActionStyleDefault
                                      handler:^(UIAlertAction * action) {
                                          reason = nil;
                                          [self dismissViewControllerAnimated:YES completion:nil];
                                      }];
            [selectDeleteReasonAlert.view addSubview:_navBarMenu];
            [selectDeleteReasonAlert.view addSubview:lblSelectedRow];
            [selectDeleteReasonAlert addAction:aOk];
            [selectDeleteReasonAlert addAction:aCancel];
            [self presentViewController:selectDeleteReasonAlert animated:YES completion:nil];
        }
    }
}

@end
