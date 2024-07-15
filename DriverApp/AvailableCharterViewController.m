//
//  DriverApp
//
//  Created by KangJie Lim on 7/9/17.
//  Copyright © 2017 Commute-Solutions. All rights reserved.
//

#import "AvailableCharterViewController.h"

@interface AvailableCharterViewController ()<UITableViewDataSource, UITableViewDelegate>

@end

@implementation AvailableCharterViewController
static int controllerId = 1;
NSUserDefaults *userPrefs;
NSString *token;
NSString *role;

NSArray *availableChartersResponse;
BOOL hasNextPage;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[[UIView alloc] init]];
    self.navigationItem.title = @"Available Charters";
    
    UIBarButtonItem *btnSideMenu = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(showHideButtonsAction)];
    [btnSideMenu setTintColor:[UIColor whiteColor]];
    self.navigationItem.rightBarButtonItem = btnSideMenu;
    
    userPrefs = [NSUserDefaults standardUserDefaults];
    token = [userPrefs stringForKey:AUTHENTICATION_TOKEN];
    role = [userPrefs stringForKey:ROLE];
    
    hasNextPage = NO;
    [self getAvailableCharters];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Please Wait..."];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refreshControl];
}

- (void)viewWillAppear:(BOOL)animated {
    NSString *phoneModel = [userPrefs stringForKey:PHONE_MODEL];
    if ([phoneModel isEqualToString:@"1"] || [phoneModel isEqualToString:@"3G"] || [phoneModel isEqualToString:@"3GS"] || [phoneModel isEqualToString:@"4"] || [phoneModel isEqualToString:@"4S"]
        || [phoneModel isEqualToString:@"5"] || [phoneModel isEqualToString:@"5C"] || [phoneModel isEqualToString:@"5S"] || [phoneModel isEqualToString:@"SE"] || [phoneModel isEqualToString:@"6"]
        || [phoneModel isEqualToString:@"6S"] || [phoneModel isEqualToString:@"7"]) {
        if ([role isEqualToString:@"omo"]) {
            _navBar = [LGPlusButtonsView plusButtonsViewWithNumberOfButtons:7
                                                    firstButtonIsPlusButton:NO
                                                              showAfterInit:NO
                                                              actionHandler:^(LGPlusButtonsView *plusButtonView, NSString *title, NSString *description, NSUInteger index)
                       {
                           NSLog(@"actionHandler | title: %@, description: %@, index: %lu", title, description, (long unsigned)index);
                           if (index == 1) {
                               [self performSegueWithIdentifier:@"toAddNewCharter" sender:self];
                           } else if (index == 2) {
                               [self performSegueWithIdentifier:@"toJobs" sender:@"subout"];
                           } else if (index == 3) {
                               [self performSegueWithIdentifier:@"toJobs" sender:@"scheduled"];
                           } else if (index == 4) {
                               [self performSegueWithIdentifier:@"toTracker" sender:self];
                           } else if (index == 5) {
                               [self performSegueWithIdentifier:@"toDispute" sender:self];
                           } else if (index == 6) {
                               [self performSegueWithIdentifier:@"toProfile" sender:self];
                           }
                       }];
            
            _navBar.showHideOnScroll = NO;
            _navBar.appearingAnimationType = LGPlusButtonsAppearingAnimationTypeCrossDissolveAndPop;
            _navBar.position = LGPlusButtonsViewPositionRightTop;
            
            NSArray *btnImageArray = @[[NSNull new], [UIImage imageNamed:@"createcharter"], [UIImage imageNamed:@"mycharter"], [UIImage imageNamed:@"successfulbids"], [UIImage imageNamed:@"totracker"], [UIImage imageNamed:@"dispute"], [UIImage imageNamed:@"profile"]];
            [_navBar setButtonsImages:btnImageArray forState:UIControlStateNormal forOrientation:LGPlusButtonsViewOrientationAll];
            [_navBar setDescriptionsTexts:@[@"", @"Add New Charter", @"My Subout Jobs", @"My Scheduled Jobs", @"To Tracker", @"Disputed Charters", @"Profile"]];
        } else {
            _navBar = [LGPlusButtonsView plusButtonsViewWithNumberOfButtons:6
                                                    firstButtonIsPlusButton:NO
                                                              showAfterInit:NO
                                                              actionHandler:^(LGPlusButtonsView *plusButtonView, NSString *title, NSString *description, NSUInteger index)
                       {
                           NSLog(@"actionHandler | title: %@, description: %@, index: %lu", title, description, (long unsigned)index);
                           if (index == 1) {
                               [self performSegueWithIdentifier:@"toAddNewCharter" sender:self];
                           } else if (index == 2) {
                               [self performSegueWithIdentifier:@"toJobs" sender:@"subout"];
                           } else if (index == 3) {
                               [self performSegueWithIdentifier:@"toJobs" sender:@"scheduled"];
                           } else if (index == 4) {
                               [self performSegueWithIdentifier:@"toDispute" sender:self];
                           } else if (index == 5) {
                               [self performSegueWithIdentifier:@"toProfile" sender:self];
                           }
                       }];
            
            _navBar.showHideOnScroll = NO;
            _navBar.appearingAnimationType = LGPlusButtonsAppearingAnimationTypeCrossDissolveAndPop;
            _navBar.position = LGPlusButtonsViewPositionRightTop;
            
            NSArray *btnImageArray = @[[NSNull new], [UIImage imageNamed:@"createcharter"], [UIImage imageNamed:@"mycharter"], [UIImage imageNamed:@"successfulbids"], [UIImage imageNamed:@"dispute"], [UIImage imageNamed:@"profile"]];
            [_navBar setButtonsImages:btnImageArray forState:UIControlStateNormal forOrientation:LGPlusButtonsViewOrientationAll];
            [_navBar setDescriptionsTexts:@[@"", @"Add New Charter", @"My Subout Jobs", @"My Scheduled Jobs", @"Disputed Charters", @"Profile"]];
        }
    } else {
        if ([role isEqualToString:@"omo"]) {
            _navBar = [LGPlusButtonsView plusButtonsViewWithNumberOfButtons:6
                                                    firstButtonIsPlusButton:NO
                                                              showAfterInit:NO
                                                              actionHandler:^(LGPlusButtonsView *plusButtonView, NSString *title, NSString *description, NSUInteger index)
                       {
                           NSLog(@"actionHandler | title: %@, description: %@, index: %lu", title, description, (long unsigned)index);
                           if (index == 0) {
                               [self performSegueWithIdentifier:@"toAddNewCharter" sender:self];
                           } else if (index == 1) {
                               [self performSegueWithIdentifier:@"toJobs" sender:@"subout"];
                           } else if (index == 2) {
                               [self performSegueWithIdentifier:@"toJobs" sender:@"scheduled"];
                           } else if (index == 3) {
                               [self performSegueWithIdentifier:@"toTracker" sender:self];
                           } else if (index == 4) {
                               [self performSegueWithIdentifier:@"toDispute" sender:self];
                           } else if (index == 5) {
                               [self performSegueWithIdentifier:@"toProfile" sender:self];
                           }
                       }];
            
            _navBar.showHideOnScroll = NO;
            _navBar.appearingAnimationType = LGPlusButtonsAppearingAnimationTypeCrossDissolveAndPop;
            _navBar.position = LGPlusButtonsViewPositionRightTop;
            
            NSArray *btnImageArray = @[[UIImage imageNamed:@"createcharter"], [UIImage imageNamed:@"mycharter"], [UIImage imageNamed:@"successfulbids"], [UIImage imageNamed:@"totracker"], [UIImage imageNamed:@"dispute"], [UIImage imageNamed:@"profile"]];
            [_navBar setButtonsImages:btnImageArray forState:UIControlStateNormal forOrientation:LGPlusButtonsViewOrientationAll];
            [_navBar setDescriptionsTexts:@[@"Add New Charter", @"My Subout Jobs", @"My Scheduled Jobs", @"To Tracker", @"Disputed Charters", @"Profile"]];
        } else {
            _navBar = [LGPlusButtonsView plusButtonsViewWithNumberOfButtons:5
                                                    firstButtonIsPlusButton:NO
                                                              showAfterInit:NO
                                                              actionHandler:^(LGPlusButtonsView *plusButtonView, NSString *title, NSString *description, NSUInteger index)
                       {
                           NSLog(@"actionHandler | title: %@, description: %@, index: %lu", title, description, (long unsigned)index);
                           if (index == 0) {
                               [self performSegueWithIdentifier:@"toAddNewCharter" sender:self];
                           } else if (index == 1) {
                               [self performSegueWithIdentifier:@"toJobs" sender:@"subout"];
                           } else if (index == 2) {
                               [self performSegueWithIdentifier:@"toJobs" sender:@"scheduled"];
                           } else if (index == 3) {
                               [self performSegueWithIdentifier:@"toDispute" sender:self];
                           } else if (index == 4) {
                               [self performSegueWithIdentifier:@"toProfile" sender:self];
                           }
                       }];
            
            _navBar.showHideOnScroll = NO;
            _navBar.appearingAnimationType = LGPlusButtonsAppearingAnimationTypeCrossDissolveAndPop;
            _navBar.position = LGPlusButtonsViewPositionRightTop;
            
            NSArray *btnImageArray = @[[UIImage imageNamed:@"createcharter"], [UIImage imageNamed:@"mycharter"], [UIImage imageNamed:@"successfulbids"], [UIImage imageNamed:@"dispute"], [UIImage imageNamed:@"profile"]];
            [_navBar setButtonsImages:btnImageArray forState:UIControlStateNormal forOrientation:LGPlusButtonsViewOrientationAll];
            [_navBar setDescriptionsTexts:@[@"Add New Charter", @"My Subout Jobs", @"My Scheduled Jobs", @"Disputed Charters", @"Profile"]];
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
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        [_navBar setButtonsSize:CGSizeMake(44.f, 44.f) forOrientation:LGPlusButtonsViewOrientationLandscape];
        [_navBar setButtonsLayerCornerRadius:44.f/2.f forOrientation:LGPlusButtonsViewOrientationLandscape];
        [_navBar setButtonsTitleFont:[UIFont systemFontOfSize:24.f] forOrientation:LGPlusButtonsViewOrientationLandscape];
    }
    [self.view addSubview:_navBar];
    self.tableView.separatorColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)refresh:(UIRefreshControl *)refreshControl {
    [self refreshTableData];
    [refreshControl endRefreshing];
}

- (void)refreshTableData {
    AvailableCharterViewController *myController = [self.storyboard instantiateViewControllerWithIdentifier:@"AvailableCharterViewController"];
    [self.navigationController pushViewController:myController animated:NO];
}

#pragma mark - navigation bar
- (void)showHideButtonsAction {
    if (_navBar.isShowing) {
        [_navBar hideAnimated:YES completionHandler:nil];
    } else {
        [_navBar showAnimated:YES completionHandler:nil];
    }
}

#pragma mark - UITableView DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return availableChartersResponse.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"cellReuseIdentifier";
    NSInteger rowCount = indexPath.row;
    TableRow *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
    NSDictionary *aCharter = [availableChartersResponse objectAtIndex:rowCount];
    
    NSString *charterType = [aCharter objectForKey:@"serviceType"];
    NSString *charterDate = [aCharter objectForKey:@"date"];
    NSNumber *charterBusType = [aCharter objectForKey:@"busType"];
    NSString *charterCost = [aCharter objectForKey:@"cost"];
    NSString *charterExpiryDate = [aCharter objectForKey:@"expiryDate"];
    NSArray *array = [aCharter objectForKey:@"pickUpName"];
    NSString *charterPickUpName = [array objectAtIndex:0];
    array = [aCharter objectForKey:@"dropOffName"];
    NSString *charterDropOffName = [array objectAtIndex:0];
    array = [aCharter objectForKey:@"time"];
    NSString *charterTime = [array objectAtIndex:0];
    
    NSNumber *numToBool = [aCharter objectForKey:@"isMyCharter"];
    BOOL isMyCharter = [numToBool boolValue];
    
    if (!isMyCharter) {
        cell.ivIsOwnCharterIdentifier.alpha = 0.f;
    } else {
        cell.ivIsOwnCharterIdentifier.alpha = 1.f;
    }
    
    cell.lblDate.text = charterDate;
    if ([charterType isEqualToString:@"disposal"]) {
        NSString *charterTime2 = [array objectAtIndex:1];
        cell.lblTime.text = [NSString stringWithFormat:@"%@ - %@", charterTime, charterTime2];
        cell.lblCost.text = [NSString stringWithFormat:@"%@/hr", charterCost];
    } else {
        cell.lblTime.text = charterTime;
        cell.lblCost.text = charterCost;
    }
    
    cell.lblBusType.text = [NSString stringWithFormat:@"%d - Seater", [charterBusType intValue]];
    cell.lblStartName.text = charterPickUpName;
    cell.lblEndName.text = charterDropOffName;
    cell.lblExpiryDate.text = [NSString stringWithFormat:@"Expires %@", charterExpiryDate];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger rowCount = indexPath.row;
    if ([availableChartersResponse count] != 0) {
        NSDictionary *aCharter = [availableChartersResponse objectAtIndex:rowCount];
        _charterId = [aCharter objectForKey:@"id"];
        [self performSegueWithIdentifier:@"viewSelectedCharter" sender:self];
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"viewSelectedCharter"]) {
        SingleCharterViewController *destinationController = (SingleCharterViewController *)segue.destinationViewController;
        destinationController.charterId = _charterId;
        destinationController.previousControllerView = [NSNumber numberWithInt:controllerId];
    } else if ([segue.identifier isEqualToString: @"toJobs"]) {
        JobsViewController *destinationController = (JobsViewController *)segue.destinationViewController;
        destinationController.identifyingProperty = sender;
    }
}

#pragma mark - Get Available Charters
- (void)getAvailableCharters {
    __block NSInteger success = 0;
    if (token != nil && token != NULL) {
        NSURL *url = [NSURL URLWithString:AVAILABLE_CHARTER_URL];
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
                availableChartersResponse = [dataResponse objectForKey:@"charterList"];
                NSNumber *numToBool = [dataResponse objectForKey:@"hasMore"];
                hasNextPage = [numToBool boolValue];
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

@end
