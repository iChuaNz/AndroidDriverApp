//
//  DriverApp
//
//  Created by KangJie Lim on 8/3/18.
//  Copyright © 2018 Commute-Solutions. All rights reserved.
//

#import "SingleContractViewController.h"

@interface SingleContractViewController ()

@end

@implementation SingleContractViewController
NSUserDefaults *userPrefs;
NSString *token;

- (void)loadView {
    [super loadView];
    self.navigationItem.title = @"Contract";
}

- (void)viewDidLoad {
    userPrefs = [NSUserDefaults standardUserDefaults];
    token = [userPrefs stringForKey:AUTHENTICATION_TOKEN];
    
    NSString *startDate = [_contract objectForKey:@"startDate"];
    NSString *endDate = [_contract objectForKey:@"endDate"];
    NSString *pickuptime = [_contract objectForKey:@"pickUpTime"];
    NSString *busType = [_contract objectForKey:@"busSize"];
    NSString *contractCost = [_contract objectForKey:@"contractCost"];
    NSString *info = [_contract objectForKey:@"additionalInfo"];
    
    NSNumber *numToBool = [_contract objectForKey:@"hasERP"];
    BOOL hasERP = [numToBool boolValue];
    numToBool = [_contract objectForKey:@"includesERP"];
    BOOL includesERP = [numToBool boolValue];
    
    _lblContractPeriod.text = [NSString stringWithFormat:@"%@ -> %@", startDate, endDate];
    _lblTime.text = pickuptime;
    _lblBusSize.text = busType;
    if (hasERP) {
        if (includesERP) {
            _lblCost.text = [NSString stringWithFormat:@"$%@ (Includes ERP)", contractCost];
        } else {
            _lblCost.text = [NSString stringWithFormat:@"$%@ (Does not include ERP)", contractCost];
        }
    } else {
        _lblCost.text = [NSString stringWithFormat:@"$%@ (No ERP)", contractCost];
    }
    
    NSString *contractPickupPoint1 = [_contract objectForKey:@"pickupPoint1Name"];
    NSString *contractPickupPoint2 = [_contract objectForKey:@"pickupPoint2Name"];
    NSString *contractPickupPoint3 = [_contract objectForKey:@"pickupPoint3Name"];
    NSString *contractDropoffPoint1 = [_contract objectForKey:@"dropoffPoint1Name"];
    NSString *contractDropoffPoint2 = [_contract objectForKey:@"dropoffPoint2Name"];
    NSString *contractDropoffPoint3 = [_contract objectForKey:@"dropoffPoint3Name"];
    
    [_btnPickup1 setTitle:contractPickupPoint1 forState:UIControlStateNormal];
    [_btnDropoff1 setTitle:contractDropoffPoint1 forState:UIControlStateNormal];
    
    if ([contractPickupPoint2 isEqualToString:@""]) {
        [_btnPickup2 setHidden:YES];
    } else {
        [_btnPickup2 setTitle:contractPickupPoint2 forState:UIControlStateNormal];
    }
    
    if ([contractPickupPoint3 isEqualToString:@""]) {
        [_btnPickup3 setHidden:YES];
    } else {
        [_btnPickup3 setTitle:contractPickupPoint3 forState:UIControlStateNormal];
    }
    
    if ([contractDropoffPoint2 isEqualToString:@""]) {
        [_btnDropoff2 setHidden:YES];
    } else {
        [_btnDropoff2 setTitle:contractDropoffPoint2 forState:UIControlStateNormal];
    }
    
    if ([contractDropoffPoint3 isEqualToString:@""]) {
        [_btnDropoff3 setHidden:YES];
    } else {
        [_btnDropoff3 setTitle:contractDropoffPoint3 forState:UIControlStateNormal];
    }
    
    if (info == nil || info == (NSString *)[NSNull null]) {
        _lblInfo.text = @"";
    } else {
        _lblInfo.text = info;
    }
}


- (IBAction)btnPickup1:(id)sender {
    NSString *mlatitude = [_contract objectForKey:@"pickupPoint1Lat"];
    NSString *mLongitude = [_contract objectForKey:@"pickupPoint1Lng"];
    NSString *directionsRequest = [NSString stringWithFormat:@"http://maps.google.com/maps?q=%@,%@", mlatitude, mLongitude];
    NSURL *directionsURL = [NSURL URLWithString:directionsRequest];
    [[UIApplication sharedApplication] openURL:directionsURL];
}

- (IBAction)btnPickup2:(id)sender {
    NSString *mlatitude = [_contract objectForKey:@"pickupPoint2Lat"];
    NSString *mLongitude = [_contract objectForKey:@"pickupPoint2Lng"];
    NSString *directionsRequest = [NSString stringWithFormat:@"http://maps.google.com/maps?q=%@,%@", mlatitude, mLongitude];
    NSURL *directionsURL = [NSURL URLWithString:directionsRequest];
    [[UIApplication sharedApplication] openURL:directionsURL];
}

- (IBAction)btnPickup3:(id)sender {
    NSString *mlatitude = [_contract objectForKey:@"pickupPoint3Lat"];
    NSString *mLongitude = [_contract objectForKey:@"pickupPoint3Lng"];
    NSString *directionsRequest = [NSString stringWithFormat:@"http://maps.google.com/maps?q=%@,%@", mlatitude, mLongitude];
    NSURL *directionsURL = [NSURL URLWithString:directionsRequest];
    [[UIApplication sharedApplication] openURL:directionsURL];
}

- (IBAction)btnDropoff1:(id)sender {
    NSString *mlatitude = [_contract objectForKey:@"dropoffPoint1Lat"];
    NSString *mLongitude = [_contract objectForKey:@"dropoffPoint1Lng"];
    NSString *directionsRequest = [NSString stringWithFormat:@"http://maps.google.com/maps?q=%@,%@", mlatitude, mLongitude];
    NSURL *directionsURL = [NSURL URLWithString:directionsRequest];
    [[UIApplication sharedApplication] openURL:directionsURL];
}

- (IBAction)btnDropoff2:(id)sender{
    NSString *mlatitude = [_contract objectForKey:@"dropoffPoint2Lat"];
    NSString *mLongitude = [_contract objectForKey:@"dropoffPoint2Lng"];
    NSString *directionsRequest = [NSString stringWithFormat:@"http://maps.google.com/maps?q=%@,%@", mlatitude, mLongitude];
    NSURL *directionsURL = [NSURL URLWithString:directionsRequest];
    [[UIApplication sharedApplication] openURL:directionsURL];
}

- (IBAction)btnDropoff3:(id)sender{
    NSString *mlatitude = [_contract objectForKey:@"dropoffPoint3Lat"];
    NSString *mLongitude = [_contract objectForKey:@"dropoffPoint3Lng"];
    NSString *directionsRequest = [NSString stringWithFormat:@"http://maps.google.com/maps?q=%@,%@", mlatitude, mLongitude];
    NSURL *directionsURL = [NSURL URLWithString:directionsRequest];
    [[UIApplication sharedApplication] openURL:directionsURL];
}

- (IBAction)btnCall:(id)sender{
    NSString *contactNo = [_contract objectForKey:@"contactNo"];
    UIAlertController *callAlert = [UIAlertController alertControllerWithTitle:contactNo
                                                                        message:@""
                                                                        preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *aCall = [UIAlertAction
                                     actionWithTitle:@"Call Me!"
                                     style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction * action) {
                                         NSString *contractId = [_contract objectForKey:@"id"];
                                         [self addToCallCounter:contractId];
                                     }];
    UIAlertAction *aCancel = [UIAlertAction
                              actionWithTitle:@"Cancel"
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction * action) {
                                  [self dismissViewControllerAnimated:YES completion:nil];
                              }];
    [callAlert addAction:aCall];
    [callAlert addAction:aCancel];
    [self presentViewController:callAlert animated:YES completion:nil];
}

#pragma mark - Call Counter
- (void)addToCallCounter: (NSString *)contractId {
    __block NSInteger success = 0;
    NSDictionary *contractIdData = [NSDictionary dictionaryWithObjectsAndKeys:
                                    contractId, @"id",
                                    nil];
    
    NSDictionary *jsonData = [NSDictionary dictionaryWithObjectsAndKeys:
                              contractIdData, @"data",
                              nil];
    
    NSURL *url = [NSURL URLWithString:CALL_COUNTER_URL];
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
            NSString *contactNo = [_contract objectForKey:@"contactNo"];
            NSString *phoneStr = [NSString stringWithFormat:@"tel:%@", contactNo];
            NSURL *phoneURL = [[NSURL alloc] initWithString:phoneStr];
            [[UIApplication sharedApplication] openURL:phoneURL];
        }
    } else {
        UIAlertController *cannotProceedAlert = [UIAlertController alertControllerWithTitle:@"Error!"
                                                                                    message:@"Unable to verify details. Contract still exist in server. Please try again."
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
