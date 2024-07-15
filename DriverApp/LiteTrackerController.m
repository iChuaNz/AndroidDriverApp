//
//  DriverApp
//
//  Created by KangJie Lim on 26/10/17.
//  Copyright © 2017 Commute-Solutions. All rights reserved.
//

#import "LiteTrackerController.h"

@interface LiteTrackerController ()

@end

@implementation LiteTrackerController
NetworkUtility *reachability;
NetworkStatus status;
CLLocationManager *locationManager;
NSUserDefaults *userPrefs;
NSString *token;
NSString *role;

NSArray *jobDataResponse;
NSArray *passengersDataResponse;
BOOL isSchoolBusTrip;

double mLongitude;
double mLatitude;
double mAltitude;
double mAccuracy;
double mSpeed;
NSString *mDate;
NSString *mPollingDate;
BOOL toShowMsg;
BOOL hasFinishedJob;

NSMutableArray *storedLongitude;
NSMutableArray *storedLatitude;
NSMutableArray *storedAltitude;
NSMutableArray *storedAccuracy;
NSMutableArray *storedSpeed;
NSMutableArray *storedDateTime;
NSTimer *locationTimer;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[[UIView alloc] init]];
    UIBarButtonItem *btnMap = [[UIBarButtonItem alloc] initWithTitle:@"Map" style:UIBarButtonItemStylePlain target:self action:@selector(toMap)];
    [btnMap setTintColor:[UIColor whiteColor]];
    self.navigationItem.leftBarButtonItem = btnMap;
    self.navigationItem.title = @"Lite Mode";
    
    userPrefs = [NSUserDefaults standardUserDefaults];
    token = [userPrefs stringForKey:AUTHENTICATION_TOKEN];
    role = [userPrefs stringForKey:ROLE];
    toShowMsg = [userPrefs boolForKey:SHOW_MESSAGE];
    
    NSData *archivedData = [userPrefs objectForKey:PASSENGER_GENERAL_DATA];
    passengersDataResponse = [NSKeyedUnarchiver unarchiveObjectWithData:archivedData];
    archivedData = [userPrefs objectForKey:JOBARRAY];
    jobDataResponse = [NSKeyedUnarchiver unarchiveObjectWithData:archivedData];
    
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    reachability = [NetworkUtility reachabilityForInternetConnection];
    
    [self initialiseValues];
}

- (void)viewWillAppear:(BOOL)animated {
    [reachability startNotifier];
    status = [reachability currentReachabilityStatus];
    
    storedLongitude = [[NSMutableArray alloc] init];
    storedLatitude = [[NSMutableArray alloc] init];
    storedAccuracy = [[NSMutableArray alloc] init];
    storedAltitude = [[NSMutableArray alloc] init];
    storedSpeed = [[NSMutableArray alloc] init];
    storedDateTime = [[NSMutableArray alloc] init];
}

- (void)initialiseValues {
    //Welcome Text
    NSString *welcomeText = [[userPrefs stringForKey:USER_ID] uppercaseString];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH.mm"];
    NSString *strCurrentTime = [dateFormatter stringFromDate:[NSDate date]];
    if ([strCurrentTime floatValue] <= 19.00 && [strCurrentTime floatValue] >= 9.0) {
        welcomeText = [@"Good evening, " stringByAppendingString:welcomeText];
    } else {
        welcomeText = [@"Good morning, " stringByAppendingString:welcomeText];
    }
    
    welcomeText = [welcomeText stringByAppendingString:@". You will be driving "];
    welcomeText = [welcomeText stringByAppendingString:[userPrefs stringForKey:SERVICE_NAME]];
    welcomeText = [welcomeText stringByAppendingString:@". Have a safe trip."];
    [_lblAddress setText:welcomeText];
    
    //Time
    [_lblTime setText:@""];
    
    //Passenger Count
    [_lblPassengerCount setText:@""];
    
    //NFC View
    for (UIView *subUIView in _viewNFCResponse.subviews) {
        [subUIView removeFromSuperview];
    }
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    [locationManager startUpdatingLocation];
    
    hasFinishedJob = YES;
}

- (void)toMap {
    if (hasFinishedJob) {
        [self stopPollingLocation];
        [self performSegueWithIdentifier:@"toMap" sender:self];
    } else {
        UIAlertController *noLiteModeAlert = [UIAlertController alertControllerWithTitle:@"Sorry"
                                                                                 message:@"Lite mode is not available for adhoc jobs."
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *aOk = [UIAlertAction
                              actionWithTitle:@"Ok"
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction * action) {
                                  [self dismissViewControllerAnimated:YES completion:nil];
                              }];
        
        [noLiteModeAlert addAction:aOk];
        [self presentViewController:noLiteModeAlert animated:YES completion:nil];
    }
}

- (IBAction)btnDriverInput:(id)sender {
    NSString *btnTitle = [sender currentTitle];
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    if ([btnTitle isEqualToString:@"Start Trip"]) {
        hasFinishedJob = NO;
        [self startPollingLocation];
        [sender setTitle:@"I've Arrived" forState:UIControlStateNormal];
        //TODO: start checking proximity, on bluetooth
    } else if ([btnTitle isEqualToString:@"I've Arrived"]) {
        if (YES) { //TODO: check if have more pick up point
            [sender setTitle:@"Going to Next Stop" forState:UIControlStateNormal];
        } else {
            [sender setTitle:@"End Trip" forState:UIControlStateNormal];
        }
    } else if ([btnTitle isEqualToString:@"Going to Next Stop"]) {
        //TODO: Call Server to send notification
    } else if ([btnTitle isEqualToString:@"End Trip"]) {
        [self stopPollingLocation];
        [self performSegueWithIdentifier:@"toMap" sender:self];
    }
}

#pragma mark - Location Polling
- (void)startPollingLocation {
    locationTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(backgroundLocationPolling) userInfo:nil repeats:YES];
}

- (void)stopPollingLocation {
    [locationTimer invalidate];
    locationTimer = nil;
}

- (void)backgroundLocationPolling {
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd/MM/yyyy, H:mm:ss"];
    NSDate *sgDate = [NSDate date];
    mDate = [dateFormatter stringFromDate:sgDate];
    NSTimeInterval secondsInEightHours = 8 * 60 * 60;
    NSDate *dateEightHoursAhead = [sgDate dateByAddingTimeInterval:secondsInEightHours];
    
    CLLocation *cllocation = [locationManager location];
    mLongitude = cllocation.coordinate.longitude;
    mLatitude = cllocation.coordinate.latitude;
    mAltitude = cllocation.altitude;
    mAccuracy = cllocation.horizontalAccuracy;
    mSpeed = cllocation.speed;
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
    mPollingDate = [dateFormatter stringFromDate:dateEightHoursAhead];
    
    if (status == NotReachable) {
        [storedLongitude addObject:[NSString stringWithFormat:@"%lf", mLongitude]];
        [storedLatitude addObject:[NSString stringWithFormat:@"%lf", mLatitude]];
        [storedAltitude addObject:[NSString stringWithFormat:@"%lf", mAltitude]];
        [storedAccuracy addObject:[NSString stringWithFormat:@"%lf", mAccuracy]];
        [storedSpeed addObject:[NSString stringWithFormat:@"%lf", mSpeed]];
        [storedDateTime addObject:[NSString stringWithFormat:@"%@", mPollingDate]];
        
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [[[iToast makeText:NSLocalizedString(@"No Network detected. Storing location data into database...", @"")] setGravity:iToastGravityBottom] show];
        });
    } else {
        __block NSInteger success = 0;
        if (mAccuracy <= 0.0) {
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                [[[iToast makeText:NSLocalizedString(@"Unable to retrieve locational updates from google. Retrying in 5 seconds...", @"")] setGravity:iToastGravityBottom] show];
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
                        [userPrefs setValue:mDate forKey:LAST_UPDATED_TIME];
                        [userPrefs synchronize];
                        if (toShowMsg){
                            dispatch_async(dispatch_get_main_queue(), ^(void){
                                [[[iToast makeText:NSLocalizedString(@"Location has been updated!", @"")] setGravity:iToastGravityBottom] show];
                            });
                        }
                    }
                } else {
                    NSLog(@"Connection lost momentarily");
                }
            });
            
            if ([storedLongitude count] > 0) {
                for (int i = 0; i < [storedLongitude count]; i++) {
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
                                [storedLongitude removeAllObjects];
                                [storedLatitude removeAllObjects];
                                [storedAccuracy removeAllObjects];
                                [storedAltitude removeAllObjects];
                                [storedSpeed removeAllObjects];
                                [storedDateTime removeAllObjects];
                            }
                        }
                    });
                }
            }
        }
        
        
        //TODO: check proximity
        
        
        
        
        
        
        
        
        
        
        
    }
}

#pragma mark - Send Notification to customer
- (void)sendNotification {
    
}

@end
