//
//  DriverApp
//
//  Created by KangJie Lim on 26/9/17.
//  Copyright © 2017 Commute-Solutions. All rights reserved.
//

#import "DisputeController.h"

@interface DisputeController ()<UITableViewDataSource, UITableViewDelegate>

@end

@implementation DisputeController
static int controllerId = 5;
NSUserDefaults *userPrefs;
NSString *token;
NSString *role;

NSArray *disputeList;
NSString *argumentString;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[[UIView alloc] init]];
    self.navigationItem.title = @"Disputes";
    
    UIBarButtonItem *btnSideMenu = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(showHideButtonsAction)];
    [btnSideMenu setTintColor:[UIColor whiteColor]];
    self.navigationItem.rightBarButtonItem = btnSideMenu;
    
    userPrefs = [NSUserDefaults standardUserDefaults];
    token = [userPrefs stringForKey:AUTHENTICATION_TOKEN];
    role = [userPrefs stringForKey:ROLE];
    
    [self viewDisputeList];
}

- (void) viewWillAppear:(BOOL)animated {
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
                               [self performSegueWithIdentifier:@"toViewAvailableCharter" sender:self];
                           } else if (index == 3) {
                               [self performSegueWithIdentifier:@"toJobs" sender:@"subout"];
                           } else if (index == 4) {
                               [self performSegueWithIdentifier:@"toJobs" sender:@"scheduled"];
                           } else if (index == 5) {
                               [self performSegueWithIdentifier:@"toTracker" sender:self];
                           } else if (index == 6) {
                               [self performSegueWithIdentifier:@"toProfile" sender:self];
                           }
                       }];
            
            _navBar.showHideOnScroll = NO;
            _navBar.appearingAnimationType = LGPlusButtonsAppearingAnimationTypeCrossDissolveAndPop;
            _navBar.position = LGPlusButtonsViewPositionRightTop;
            
            NSArray *btnImageArray = @[[NSNull new], [UIImage imageNamed:@"createcharter"], [UIImage imageNamed:@"availablecharterlist"], [UIImage imageNamed:@"mycharter"], [UIImage imageNamed:@"successfulbids"], [UIImage imageNamed:@"totracker"], [UIImage imageNamed:@"profile"]];
            [_navBar setButtonsImages:btnImageArray forState:UIControlStateNormal forOrientation:LGPlusButtonsViewOrientationAll];
            [_navBar setDescriptionsTexts:@[@"", @"Add New Charter", @"View Available Charters", @"My Subout Jobs", @"My Scheduled Jobs", @"To Tracker", @"Profile"]];
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
                               [self performSegueWithIdentifier:@"toViewAvailableCharter" sender:self];
                           } else if (index == 3) {
                               [self performSegueWithIdentifier:@"toJobs" sender:@"subout"];
                           } else if (index == 4) {
                               [self performSegueWithIdentifier:@"toJobs" sender:@"scheduled"];
                           } else if (index == 5) {
                               [self performSegueWithIdentifier:@"toProfile" sender:self];
                           }
                       }];
            
            _navBar.showHideOnScroll = NO;
            _navBar.appearingAnimationType = LGPlusButtonsAppearingAnimationTypeCrossDissolveAndPop;
            _navBar.position = LGPlusButtonsViewPositionRightTop;
            
            NSArray *btnImageArray = @[[NSNull new], [UIImage imageNamed:@"createcharter"], [UIImage imageNamed:@"availablecharterlist"], [UIImage imageNamed:@"mycharter"], [UIImage imageNamed:@"successfulbids"], [UIImage imageNamed:@"profile"]];
            [_navBar setButtonsImages:btnImageArray forState:UIControlStateNormal forOrientation:LGPlusButtonsViewOrientationAll];
            [_navBar setDescriptionsTexts:@[@"", @"Add New Charter", @"View Available Charters", @"My Subout Jobs", @"My Scheduled Jobs", @"Profile"]];
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
                               [self performSegueWithIdentifier:@"toViewAvailableCharter" sender:self];
                           } else if (index == 2) {
                               [self performSegueWithIdentifier:@"toJobs" sender:@"subout"];
                           } else if (index == 3) {
                               [self performSegueWithIdentifier:@"toJobs" sender:@"scheduled"];
                           } else if (index == 4) {
                               [self performSegueWithIdentifier:@"toTracker" sender:self];
                           } else if (index == 5) {
                               [self performSegueWithIdentifier:@"toProfile" sender:self];
                           }
                       }];
            
            _navBar.showHideOnScroll = NO;
            _navBar.appearingAnimationType = LGPlusButtonsAppearingAnimationTypeCrossDissolveAndPop;
            _navBar.position = LGPlusButtonsViewPositionRightTop;
            
            NSArray *btnImageArray = @[[UIImage imageNamed:@"createcharter"], [UIImage imageNamed:@"availablecharterlist"], [UIImage imageNamed:@"mycharter"], [UIImage imageNamed:@"successfulbids"], [UIImage imageNamed:@"totracker"], [UIImage imageNamed:@"profile"]];
            [_navBar setButtonsImages:btnImageArray forState:UIControlStateNormal forOrientation:LGPlusButtonsViewOrientationAll];
            [_navBar setDescriptionsTexts:@[@"Add New Charter", @"View Available Charters", @"My Subout Jobs", @"My Scheduled Jobs", @"To Tracker", @"Profile"]];
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
                               [self performSegueWithIdentifier:@"toViewAvailableCharter" sender:self];
                           } else if (index == 2) {
                               [self performSegueWithIdentifier:@"toJobs" sender:@"subout"];
                           } else if (index == 3) {
                               [self performSegueWithIdentifier:@"toJobs" sender:@"scheduled"];
                           } else if (index == 4) {
                               [self performSegueWithIdentifier:@"toProfile" sender:self];
                           }
                       }];
            
            _navBar.showHideOnScroll = NO;
            _navBar.appearingAnimationType = LGPlusButtonsAppearingAnimationTypeCrossDissolveAndPop;
            _navBar.position = LGPlusButtonsViewPositionRightTop;
            
            NSArray *btnImageArray = @[[UIImage imageNamed:@"createcharter"], [UIImage imageNamed:@"availablecharterlist"], [UIImage imageNamed:@"mycharter"], [UIImage imageNamed:@"successfulbids"], [UIImage imageNamed:@"profile"]];
            [_navBar setButtonsImages:btnImageArray forState:UIControlStateNormal forOrientation:LGPlusButtonsViewOrientationAll];
            [_navBar setDescriptionsTexts:@[@"Add New Charter", @"View Available Charters", @"My Subout Jobs", @"My Scheduled Jobs", @"Profile"]];
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

#pragma mark - UITableView DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return disputeList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"cellReuseIdentifier2";
    NSInteger rowCount = indexPath.row;
    DisputeTableRow *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    NSDictionary *aDispute = [disputeList objectAtIndex:rowCount];
    
    NSString *accessCode = [aDispute objectForKey:@"accessCode"];
    NSString *charterDetails = [aDispute objectForKey:@"details"];
    double disputeCost = [[aDispute objectForKey:@"cost"] doubleValue];
    NSNumber *numToBool = [aDispute objectForKey:@"requiresAction"];
    BOOL requiresAction = [numToBool boolValue];
    numToBool = [aDispute objectForKey:@"isSettled"];
    BOOL isSettled = [numToBool boolValue];
    numToBool = [aDispute objectForKey:@"pendingAdmin"];
    BOOL pendingAdmin = [numToBool boolValue];
    
    cell.lblDisputeId.text = accessCode;
    cell.lblDisputeAmount.text = [NSString stringWithFormat:@"$%.2f", disputeCost];
    cell.lblDisputeCharterDetails.text = charterDetails;
    [cell.lblDisputeCharterDetails sizeToFit];
    if (requiresAction) {
        cell.lblDisputeStatus.text = @"Requires action. Tap me to view.";
        cell.lblDisputeStatus.textColor = [UIColor redColor];
    }
    if (pendingAdmin) {
        cell.lblDisputeStatus.text = @"Pending";
    }
    
    if (isSettled) {
        cell.lblDisputeStatus.text = @"Settled";
        cell.lblDisputeStatus.textColor = [UIColor greenColor];
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger rowCount = indexPath.row;
    if ([disputeList count] != 0) {
        NSDictionary *aDispute = [disputeList objectAtIndex:rowCount];
        _charterId = [aDispute objectForKey:@"id"];
        NSNumber *numToBool = [aDispute objectForKey:@"requiresAction"];
        BOOL requiresAction = [numToBool boolValue];
        NSString *disputeReason = [aDispute objectForKey:@"reasons"];
        NSString *rebukeReason = [aDispute objectForKey:@"rebukeReason"];
        NSString *adminInput = [aDispute objectForKey:@"adminInput"];
        
        NSString *disputeAlertMessage = @"Please confirm the dispute below.\n\n";
        disputeAlertMessage = [disputeAlertMessage stringByAppendingString:[NSString stringWithFormat:@"Problem raised: %@\n\n", disputeReason]];
        if (![rebukeReason isEqualToString:@""] && rebukeReason != nil) {
            disputeAlertMessage = [disputeAlertMessage stringByAppendingString:[NSString stringWithFormat:@"Your argument: %@\n\n", rebukeReason]];
        }
        if (![adminInput isEqualToString:@""] && adminInput != nil) {
            disputeAlertMessage = [disputeAlertMessage stringByAppendingString:[NSString stringWithFormat:@"Admin: %@", adminInput]];
        }
        
        UIAlertController *disputeDetailsAlert = [UIAlertController alertControllerWithTitle:@"Dispute"
                                                                                    message:disputeAlertMessage
                                                                             preferredStyle:UIAlertControllerStyleAlert];
        
        if (requiresAction) {
            [disputeDetailsAlert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
                textField.tag = 20;
                textField.delegate = self;
                textField.placeholder = @"Enter reason for disagreeing to the charges here";
            }];
            
            UIAlertAction *aProceedAndAgree = [UIAlertAction
                                               actionWithTitle:@"Yes - I agree to compensate for the charge"
                                               style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction * action) {
                                                   [self updateResponse:@YES :@""];
                                               }];
            UIAlertAction *aProceedAndDisagree = [UIAlertAction
                                                  actionWithTitle:@"No - I do not agree to compensate for the charge"
                                                  style:UIAlertActionStyleDefault
                                                  handler:^(UIAlertAction * action) {
                                                      [self updateResponse:@NO :argumentString];
                                                  }];
            
            [disputeDetailsAlert addAction:aProceedAndAgree];
            [disputeDetailsAlert addAction:aProceedAndDisagree];
        }

        UIAlertAction *aCancel = [UIAlertAction
                                  actionWithTitle:@"Cancel"
                                  style:UIAlertActionStyleDefault
                                  handler:^(UIAlertAction * action) {
                                      [self dismissViewControllerAnimated:YES completion:nil];
                                  }];
        [disputeDetailsAlert addAction:aCancel];
        
        [self presentViewController:disputeDetailsAlert animated:YES completion:nil];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    NSInteger txtId = textField.tag;
    if (txtId == 20) {
        argumentString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    }
    return YES;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString: @"toJobs"]) {
        JobsViewController *destinationController = (JobsViewController *)segue.destinationViewController;
        destinationController.identifyingProperty = sender;
    }
}

#pragma mark - navigation bar
- (void)showHideButtonsAction {
    if (_navBar.isShowing)
        [_navBar hideAnimated:YES completionHandler:nil];
    else
        [_navBar showAnimated:YES completionHandler:nil];
}

#pragma mark - View Dispute List
- (void)viewDisputeList {
    __block NSInteger success = 0;
    if (token != nil && token != NULL) {
        NSURL *url = [NSURL URLWithString:VIEW_DISPUTE_LIST_URL];
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
                disputeList = [dataResponse objectForKey:@"history"];
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

#pragma mark - Dispute Response
-(void)updateResponse:(NSNumber *)hasAgreed :(NSString *)reason {
    __block NSInteger success = 0;
    NSDictionary *driverData = [NSDictionary dictionaryWithObjectsAndKeys:
                                _charterId, @"id",
                                hasAgreed, @"hasAgreed",
                                reason, @"rebukeReason",
                                nil];
    
    NSDictionary *jsonData = [NSDictionary dictionaryWithObjectsAndKeys:
                              driverData, @"data",
                              nil];
    if (token != nil && token != NULL) {
        NSURL *url = [NSURL URLWithString:DISPUTE_RESPONSE_URL];
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
    }
}

@end
