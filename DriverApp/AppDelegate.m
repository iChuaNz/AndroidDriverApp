//
//  DriverApp
//
//  Created by KangJie Lim on 10/11/16.
//  Copyright © 2016 Commute-Solutions. All rights reserved.
//

#import "AppDelegate.h"
@import GoogleMaps;
@import GooglePlaces;

#if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
@import UserNotifications;
#endif

// Implement UNUserNotificationCenterDelegate to receive display notification via APNS for devices
// running iOS 10 and above.
#if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
@interface AppDelegate () <UNUserNotificationCenterDelegate>
@end
#endif

#ifndef NSFoundationVersionNumber_iOS_9_x_Max
#define NSFoundationVersionNumber_iOS_9_x_Max 1299
#endif

@implementation AppDelegate
CLLocationManager *locationManager;
UIApplication *app;
NSUserDefaults *userPrefs;
double mLongitude;
double mLatitude;
double mAltitude;
double mAccuracy;
double mSpeed;
NSString *token;
NSString *mPollingDate;
BOOL locationStarted = FALSE;
NSString *const kGCMMessageIDKey = @"gcm.message_id";

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self.window makeKeyAndVisible];
    [[UINavigationBar appearance] setBarTintColor:UIColorFromRGB(0xF68B1F)];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    NSString *assetLocalPath = [[NSBundle mainBundle] pathForResource:@"LoadingScreen" ofType:@"png"];
    NSURL *assetURL = [[NSURL alloc] initFileURLWithPath:assetLocalPath];
    UIImageView *launcherImageView = [[UIImageView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [launcherImageView setImage: [UIImage animatedImageWithAnimatedGIFURL:assetURL]];
    [self.window addSubview:launcherImageView];
    [self.window bringSubviewToFront:launcherImageView];
    launcherImageView.layer.anchorPoint = CGPointMake(0, 0.5);
    launcherImageView.frame = [[UIScreen mainScreen] bounds];
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionTransitionCurlDown animations:^{
    } completion:^(BOOL finished){
        [launcherImageView removeFromSuperview];
    }];
    
    [GMSServices provideAPIKey:@"AIzaSyBH9LPkAElCsLdUkD8zCW0jS5aWn1jyauo"];
    [GMSPlacesClient provideAPIKey:@"AIzaSyBH9LPkAElCsLdUkD8zCW0jS5aWn1jyauo"];
    
//    [[STPPaymentConfiguration sharedConfiguration] setPublishableKey:STRIPE_DEBUG_KEY];
    [[STPPaymentConfiguration sharedConfiguration] setPublishableKey:STRIPE_LIVE_KEY];
    
    locationStarted = FALSE;
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    userPrefs = [NSUserDefaults standardUserDefaults];
    app = [UIApplication sharedApplication];
    
    [FIRApp configure];
    [FIRMessaging messaging].delegate = self;
    
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_7_1) {
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Wdeprecated-declarations"
        UIRemoteNotificationType allNotificationTypes =
        (UIRemoteNotificationTypeSound |
         UIRemoteNotificationTypeAlert |
         UIRemoteNotificationTypeBadge);
        [application registerForRemoteNotificationTypes:allNotificationTypes];
        #pragma clang diagnostic pop
    } else {
        if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_9_x_Max) {
            UIUserNotificationType allNotificationTypes =
            (UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge);
            UIUserNotificationSettings *settings =
            [UIUserNotificationSettings settingsForTypes:allNotificationTypes categories:nil];
            [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        } else {
            #if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
            [UNUserNotificationCenter currentNotificationCenter].delegate = self;
            UNAuthorizationOptions authOptions =
            UNAuthorizationOptionAlert
            | UNAuthorizationOptionSound
            | UNAuthorizationOptionBadge;
            [[UNUserNotificationCenter currentNotificationCenter] requestAuthorizationWithOptions:authOptions completionHandler:^(BOOL granted, NSError * _Nullable error) {
            }];
            #endif
        }
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    return YES;
}

// [START receive_message]
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
//    Not used
     [[FIRMessaging messaging] appDidReceiveMessage:userInfo];
    if (userInfo[kGCMMessageIDKey]) {
        NSLog(@"Message ID: %@", userInfo[kGCMMessageIDKey]);
    }
    NSLog(@"%@", userInfo);
//    Not used
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
     [[FIRMessaging messaging] appDidReceiveMessage:userInfo];
    
    if (userInfo[kGCMMessageIDKey]) {
        NSLog(@"Message ID: %@", userInfo[kGCMMessageIDKey]);
    }
    NSLog(@"%@", userInfo);
    
    completionHandler(UIBackgroundFetchResultNewData);
}
// [END receive_message]

// [START ios_10_message_handling]
// Receive displayed notifications for iOS 10 devices.
#if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
// Handle incoming notification messages while app is in the foreground.
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification
         withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
    NSDictionary *userInfo = notification.request.content.userInfo;
     [[FIRMessaging messaging] appDidReceiveMessage:userInfo];

    if (userInfo[kGCMMessageIDKey]) {
        NSLog(@"Message ID: %@", userInfo[kGCMMessageIDKey]);
    }
    NSLog(@"%@", userInfo);
    
    completionHandler(UNNotificationPresentationOptionAlert);
}

// Handle notification messages after display notification is tapped by the user.
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response
    #if defined(__IPHONE_11_0)
         withCompletionHandler:(void(^)(void))completionHandler {
    #else
        withCompletionHandler:(void(^)())completionHandler {
    #endif
    NSDictionary *userInfo = response.notification.request.content.userInfo;
    NSDictionary *aps = [userInfo objectForKey:@"aps"];
    NSString *needsFurtherAction = [aps objectForKey:@"category"];
    if (needsFurtherAction != nil) {
        NSString *redirectedController = [userInfo objectForKey:@"extra"];
        NSLog(@"Requested to open %@", redirectedController);
        if ([redirectedController isEqualToString:@"viewCharter"]) {
            [userPrefs setObject:@"1" forKey:REDIRECT_INTENT];
        } else if  ([redirectedController isEqualToString:@"subbedoutcharter"]) {
            [userPrefs setObject:@"2" forKey:REDIRECT_INTENT];
        } else if  ([redirectedController isEqualToString:@"acceptedcharter"]) {
            [userPrefs setObject:@"3" forKey:REDIRECT_INTENT];
        } else if  ([redirectedController isEqualToString:@"dispute"]) {
            [userPrefs setObject:@"5" forKey:REDIRECT_INTENT];
        } else if  ([redirectedController isEqualToString:@"profile"]) {
            [userPrefs setObject:@"6" forKey:REDIRECT_INTENT];
        } else {
            NSString *busCharterId = [userInfo objectForKey:@"busCharterId"];
            [userPrefs setObject:busCharterId forKey:REDIRECT_INTENT];
        }
        [userPrefs synchronize];
    }
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    LoginViewController *myController = [storyboard instantiateViewControllerWithIdentifier:@"loginController"];
    [(UINavigationController *)self.window.rootViewController pushViewController:myController animated:YES];
    completionHandler();
}
#endif
// [END ios_10_message_handling]
    
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"Unable to register for remote notifications: %@", error);
}

// [START ios_10_data_message]
// Receive data messages on iOS 10+ directly from FCM (bypassing APNs) when the app is in the foreground.
// To enable direct data messages, you can set [Messaging messaging].shouldEstablishDirectChannel to YES.
- (void)messaging:(FIRMessaging *)messaging didReceiveMessage:(FIRMessagingRemoteMessage *)remoteMessage {
    NSLog(@"Received data message: %@", remoteMessage.appData);
}
// [END ios_10_data_message]

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSLog(@"APNs device token retrieved: %@", deviceToken);
    [FIRMessaging messaging].APNSToken = deviceToken;
}
    
- (void)applicationReceivedRemoteMessage:(nonnull FIRMessagingRemoteMessage *)remoteMessage {
    NSLog(@"Received data message: %@", remoteMessage.appData);
}
    
- (void)messaging:(nonnull FIRMessaging *)messaging didRefreshRegistrationToken:(nonnull NSString *)fcmToken {
    // Note that this callback will be fired everytime a new token is generated, including the first
    // time. So if you need to retrieve the token as soon as it is available this is where that
    // should be done.
    NSLog(@"FCM registration token: %@", fcmToken);
    // TODO: If necessary send token to application server.
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation* location = [locations lastObject];
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
    NSTimeInterval secondsInEightHours = 8*60*60;
    NSDate *sgDate = [NSDate date];
    NSDate *dateEightHoursAhead = [sgDate dateByAddingTimeInterval:secondsInEightHours];
    
    mLongitude = location.coordinate.longitude;
    mLatitude = location.coordinate.latitude;
    mAltitude = location.altitude;
    mAccuracy = location.horizontalAccuracy;
    mSpeed = location.speed;
    mPollingDate = [dateFormatter stringFromDate:dateEightHoursAhead];
}

//run background task
-(void)pollLocation: (int) time{
    //check if application is in background mode
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
        
        //create UIBackgroundTaskIdentifier and create tackground task, which starts after time
        __block UIBackgroundTaskIdentifier bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
            [app endBackgroundTask:bgTask];
            bgTask = UIBackgroundTaskInvalid;
        }];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            NSTimer* t = [NSTimer scheduledTimerWithTimeInterval:time target:self selector:@selector(backgroundLocationPolling) userInfo:nil repeats:NO];
            [[NSRunLoop currentRunLoop] addTimer:t forMode:NSDefaultRunLoopMode];
            [[NSRunLoop currentRunLoop] run];
        });
    }
}

- (void)backgroundLocationPolling {
    __block NSInteger success = 0;
    if (mAccuracy <= 0.0) {
        
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
            NSLog(@"jsonData as string:\n%@", jsonString);
            
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
            
            if ([response statusCode] >= 200 && [response statusCode] < 300)
            {
                NSString *responseData = [[NSString alloc]initWithData:urlData encoding:NSUTF8StringEncoding];
                NSLog(@"Response ==> %@", responseData);
                
                NSError *error = nil;
                NSDictionary *jsonData = [NSJSONSerialization
                                          JSONObjectWithData:urlData
                                          options:NSJSONReadingMutableContainers
                                          error:&error];

                success = [jsonData[@"success"] integerValue];

                if(success == 1) {
                    NSLog(@"Location has been updated!");
                } else {
                    NSString *error_msg = (NSString *) jsonData[@"error_message"];
                    NSLog(@"%@", error_msg);
                }
            } else {
                NSLog(@"Unable to send location data!");
            }
        });
    }
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    if ( [UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
        [locationManager startUpdatingLocation];
    }
    [self pollLocation: 5];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    [locationManager stopUpdatingLocation];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
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
    [self saveContext];
}

#pragma mark - Core Data stack

@synthesize persistentContainer = _persistentContainer;

- (NSPersistentContainer *)persistentContainer {
    // The persistent container for the application. This implementation creates and returns a container, having loaded the store for the application to it.
    @synchronized (self) {
        if (_persistentContainer == nil) {
            _persistentContainer = [[NSPersistentContainer alloc] initWithName:@"DriverApp"];
            [_persistentContainer loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription *storeDescription, NSError *error) {
                if (error != nil) {
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    
                    /*
                     Typical reasons for an error here include:
                     * The parent directory does not exist, cannot be created, or disallows writing.
                     * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                     * The device is out of space.
                     * The store could not be migrated to the current model version.
                     Check the error message to determine what the actual problem was.
                    */
                    NSLog(@"Unresolved error %@, %@", error, error.userInfo);
                    abort();
                }
            }];
        }
    }
    
    return _persistentContainer;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *context = self.persistentContainer.viewContext;
    NSError *error = nil;
    if ([context hasChanges] && ![context save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, error.userInfo);
        abort();
    }
}
    
@end
