//
//  DriverApp
//
//  Created by KangJie Lim on 8/3/18.
//  Copyright © 2018 Commute-Solutions. All rights reserved.
//

#import "AllContractsViewController.h"

@interface AllContractsViewController ()<UITableViewDataSource, UITableViewDelegate>

@end

@implementation AllContractsViewController
NSUserDefaults *userPrefs;
NSString *token;

NSArray *contractsList;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[[UIView alloc] init]];
    self.navigationItem.title = @"View Contracts";
    
    UIBarButtonItem *btnSideMenu = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(showHideButtonsAction)];
    [btnSideMenu setTintColor:[UIColor whiteColor]];
    self.navigationItem.rightBarButtonItem = btnSideMenu;
    
    userPrefs = [NSUserDefaults standardUserDefaults];
    token = [userPrefs stringForKey:AUTHENTICATION_TOKEN];

    [self getAvailableContracts];
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
                       [self performSegueWithIdentifier:@"toCreateContract" sender:@"subout"];
                   }
               }];
    
    _navBar.showHideOnScroll = NO;
    _navBar.appearingAnimationType = LGPlusButtonsAppearingAnimationTypeCrossDissolveAndPop;
    _navBar.position = LGPlusButtonsViewPositionRightTop;
    
    NSArray *btnImageArray = @[[NSNull new], [UIImage imageNamed:@"createcharter"], [UIImage imageNamed:@"viewcontractjob"]];
    [_navBar setButtonsImages:btnImageArray forState:UIControlStateNormal forOrientation:LGPlusButtonsViewOrientationAll];
    [_navBar setDescriptionsTexts:@[@" ", @"Back to Charters", @"Create New Contract Job"]];
    
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
    return contractsList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"cellReuseIdentifier";
    NSInteger rowCount = indexPath.row;
    ContractTableRow *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
    NSDictionary *aContract = [contractsList objectAtIndex:rowCount];
    
    NSString *startDate = [aContract objectForKey:@"startDate"];
    NSString *pickuptime = [aContract objectForKey:@"pickUpTime"];
    NSString *busType = [aContract objectForKey:@"busSize"];
    NSString *contractCost = [aContract objectForKey:@"contractCost"];
    NSString *contractPickupPoint = [aContract objectForKey:@"pickupPoint1Name"];
    NSString *contractDropoffPoint = [aContract objectForKey:@"dropoffPoint3Name"];
    if ([contractDropoffPoint isEqualToString:@""]) {
        contractDropoffPoint = [aContract objectForKey:@"dropoffPoint2Name"];
        if ([contractDropoffPoint isEqualToString:@""]) {
            contractDropoffPoint = [aContract objectForKey:@"dropoffPoint1Name"];
        }
    }
    NSNumber *numToBool = [aContract objectForKey:@"isOwnCharter"];
    BOOL isOwnContract = [numToBool boolValue];
    
    if  (!isOwnContract) {
        cell.ivIsOwnContractIdentifier.alpha = 0.f;
    } else {
        cell.ivIsOwnContractIdentifier.alpha = 1.f;
    }
    
    cell.lblCost.text = [NSString stringWithFormat:@"$%@ per month", contractCost];
    cell.lblBusType.text = busType;
    cell.lblDate.text = startDate;
    cell.lblTime.text = pickuptime;
    cell.lblPickupName.text = contractPickupPoint;
    cell.lblDropOffName.text = contractDropoffPoint;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger rowCount = indexPath.row;
    if ([contractsList count] != 0) {
        NSDictionary *aContract = [contractsList objectAtIndex:rowCount];
        NSNumber *numToBool = [aContract objectForKey:@"isOwnCharter"];
        BOOL isOwnContract = [numToBool boolValue];
        
        if  (!isOwnContract) {
            _contract = aContract;
            [self performSegueWithIdentifier:@"viewSelectedContract" sender:self];
        } else {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Menu"
                                                                                    message:@"Please select the following options"
                                                                                   preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *aDelete = [UIAlertAction
                                      actionWithTitle:@"Remove Contract"
                                      style:UIAlertActionStyleDefault
                                      handler:^(UIAlertAction * action) {
                                          NSString *contractId = [aContract objectForKey:@"id"];
                                          [self deleteContract:contractId];
                                      }];
            UIAlertAction *aView = [UIAlertAction
                                      actionWithTitle:@"View Contract"
                                      style:UIAlertActionStyleDefault
                                      handler:^(UIAlertAction * action) {
                                          _contract = aContract;
                                          [self performSegueWithIdentifier:@"viewSelectedContract" sender:self];
                                      }];
            UIAlertAction *aCancel = [UIAlertAction
                                      actionWithTitle:@"Cancel"
                                      style:UIAlertActionStyleDefault
                                      handler:^(UIAlertAction * action) {
                                          [self dismissViewControllerAnimated:YES completion:nil];
                                      }];
            [alert addAction:aDelete];
            [alert addAction:aView];
            [alert addAction:aCancel];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }
    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"viewSelectedContract"]) {
        SingleContractViewController *destinationController = (SingleContractViewController *)segue.destinationViewController;
        destinationController.contract = _contract;
    }
}

#pragma mark - navigation bar
- (void)showHideButtonsAction {
    if (_navBar.isShowing)
        [_navBar hideAnimated:YES completionHandler:nil];
    else
        [_navBar showAnimated:YES completionHandler:nil];
}

#pragma mark - Get Available Contracts
- (void)getAvailableContracts {
    __block NSInteger success = 0;
    if (token != nil && token != NULL) {
        NSURL *url = [NSURL URLWithString:VIEW_ALL_CONTRACT_URL];
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
                contractsList = [dataResponse objectForKey:@"contractList"];
                NSLog(@"Number of contracts: %lu", (unsigned long)[contractsList count]);
            }
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

#pragma mark - Delete Contract
- (void)deleteContract: (NSString *)contractId {
    __block NSInteger success = 0;
    NSDictionary *contractIdData = [NSDictionary dictionaryWithObjectsAndKeys:
                               contractId, @"id",
                               nil];
    
    NSDictionary *jsonData = [NSDictionary dictionaryWithObjectsAndKeys:
                              contractIdData, @"data",
                              nil];
    
    NSURL *url = [NSURL URLWithString:DELETE_CONTRACT_URL];
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
                                                  AllContractsViewController *myController = [self.storyboard instantiateViewControllerWithIdentifier:@"allContractViewController"];
                                                  [self.navigationController pushViewController:myController animated:NO];
                                              }];
            [confirmationAlert addAction:aCloseAlertView];
            [self presentViewController:confirmationAlert animated:YES completion:nil];
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
