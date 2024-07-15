//
//  DriverApp
//
//  Created by KangJie Lim on 27/9/17.
//  Copyright © 2017 Commute-Solutions. All rights reserved.
//

#import "ProfileController.h"

@interface ProfileController ()

@end

@implementation ProfileController
static int controllerId = 6;
NSUserDefaults *userPrefs;
NSString *token;
NSString *versionNo;
NSString *username;
NSString *role;

NSString *walletAmount;
NSString *withheldAmount;
NSString *creditCardNumber;
NSString *creditCardExpiry;
NSString *creditCardBrand;
NSString *bankAccountNumber;

UIAlertController *creditCardAlert;
BOOL hasCreditCard;
BOOL isSuccessfulCall;
NSString *cashoutAmount;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[[UIView alloc] init]];
    self.navigationItem.title = @"Profile";
    
    UIBarButtonItem *btnSideMenu = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(showHideButtonsAction)];
    [btnSideMenu setTintColor:[UIColor whiteColor]];
    self.navigationItem.rightBarButtonItem = btnSideMenu;
    
    userPrefs = [NSUserDefaults standardUserDefaults];
    token = [userPrefs stringForKey:AUTHENTICATION_TOKEN];
    role = [userPrefs stringForKey:ROLE];
    username = [[userPrefs stringForKey:USER_ID] uppercaseString];
    [_lblUsername setText:[NSString stringWithFormat:@"You are logged in as %@", username]];
    
//    versionNo = @"Staging";
    NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
    NSString *appVersion = [info objectForKey:@"CFBundleShortVersionString"];
    versionNo = [@"v" stringByAppendingString:appVersion];
    [_lblVersionNo setText:versionNo];
    
    isSuccessfulCall = NO;
    [self getProfileData];
    if (isSuccessfulCall) {
        _lblWalletAmount.text = [@"$" stringByAppendingString:walletAmount];
        _lblWithheldAmount.text = [@"$" stringByAppendingString:withheldAmount];
        
        UIButton *btnWalletOptions = [UIButton buttonWithType:UIButtonTypeCustom];
        btnWalletOptions.frame = CGRectMake(0, 0, _bgWallet.bounds.size.width, _bgWallet.bounds.size.height);
        [btnWalletOptions addTarget:self action:@selector(openWalletOptions) forControlEvents:UIControlEventTouchDown];
        [_bgWallet addSubview:btnWalletOptions];
        
        UIButton *btnTransactionHistory = [UIButton buttonWithType:UIButtonTypeCustom];
        btnTransactionHistory.frame = CGRectMake(0, 0, _bgHistory.bounds.size.width, _bgHistory.bounds.size.height);
        [btnTransactionHistory addTarget:self action:@selector(viewTransactionHistory) forControlEvents:UIControlEventTouchDown];
        [_bgHistory addSubview:btnTransactionHistory];
        
        UIButton *btnCreditCardInfo = [UIButton buttonWithType:UIButtonTypeCustom];
        btnCreditCardInfo.frame = CGRectMake(0, 0, _bgCreditCard.bounds.size.width, _bgCreditCard.bounds.size.height);
        [btnCreditCardInfo addTarget:self action:@selector(viewCreditCardInfo) forControlEvents:UIControlEventTouchDown];
        [_bgCreditCard addSubview:btnCreditCardInfo];
        if ([creditCardNumber isEqualToString:@""]) {
            _lblCreditCardNo.text = @"No Credit Card";
            _lblCreditCardExpiry.text = @"";
            hasCreditCard = NO;
        } else {
            _lblCreditCardNo.text = [@"**** **** **** " stringByAppendingString:creditCardNumber];
            _lblCreditCardExpiry.text = [@"DOE: " stringByAppendingString:creditCardExpiry];
            hasCreditCard = YES;
        }
    }
}

- (void) viewWillAppear:(BOOL)animated {
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
                           [self performSegueWithIdentifier:@"toDispute" sender:self];
                       }
                   }];
        
        _navBar.showHideOnScroll = NO;
        _navBar.appearingAnimationType = LGPlusButtonsAppearingAnimationTypeCrossDissolveAndPop;
        _navBar.position = LGPlusButtonsViewPositionRightTop;
        
        NSArray *btnImageArray = @[[NSNull new], [UIImage imageNamed:@"createcharter"], [UIImage imageNamed:@"availablecharterlist"], [UIImage imageNamed:@"mycharter"], [UIImage imageNamed:@"successfulbids"], [UIImage imageNamed:@"totracker"], [UIImage imageNamed:@"dispute"]];
        [_navBar setButtonsImages:btnImageArray forState:UIControlStateNormal forOrientation:LGPlusButtonsViewOrientationAll];
        [_navBar setDescriptionsTexts:@[@"", @"Add New Charter", @"View Available Charters", @"My Subout Jobs", @"My Scheduled Jobs", @"To Tracker", @"Disputed Charters"]];
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
                           [self performSegueWithIdentifier:@"toDispute" sender:self];
                       }
                   }];
        
        _navBar.showHideOnScroll = NO;
        _navBar.appearingAnimationType = LGPlusButtonsAppearingAnimationTypeCrossDissolveAndPop;
        _navBar.position = LGPlusButtonsViewPositionRightTop;
        
        NSArray *btnImageArray = @[[NSNull new], [UIImage imageNamed:@"createcharter"], [UIImage imageNamed:@"availablecharterlist"], [UIImage imageNamed:@"mycharter"], [UIImage imageNamed:@"successfulbids"], [UIImage imageNamed:@"dispute"]];
        [_navBar setButtonsImages:btnImageArray forState:UIControlStateNormal forOrientation:LGPlusButtonsViewOrientationAll];
        [_navBar setDescriptionsTexts:@[@"", @"Add New Charter", @"View Available Charters", @"My Subout Jobs", @"My Scheduled Jobs", @"Disputed Charters"]];
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString: @"toJobs"]) {
        JobsViewController *destinationController = (JobsViewController *)segue.destinationViewController;
        destinationController.identifyingProperty = sender;
    }
}

- (void)openWalletOptions {
    if (![bankAccountNumber isEqualToString:@""] && bankAccountNumber != nil) {
        UIAlertController *additionalInfoAlert = [UIAlertController alertControllerWithTitle:@"Wallet Options"
                                                                                     message:@"Please enter an amount to cash out. Amount is in SGD($)."
                                                                              preferredStyle:UIAlertControllerStyleAlert];
        
        [additionalInfoAlert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.tag = 21;
            textField.delegate = self;
            textField.placeholder = @"e.g $1000";
        }];
        
        UIAlertAction *aCashOut = [UIAlertAction
                                  actionWithTitle:[NSString stringWithFormat:@"Bank in to %@", bankAccountNumber]
                                  style:UIAlertActionStyleDefault
                                  handler:^(UIAlertAction * action) {
                                      [self cashOut:cashoutAmount];
                                  }];
        
        UIAlertAction *aCancel = [UIAlertAction
                                  actionWithTitle:@"Cancel"
                                  style:UIAlertActionStyleDefault
                                  handler:^(UIAlertAction * action) {
                                      [self dismissViewControllerAnimated:YES completion:nil];
                                  }];
        [additionalInfoAlert addAction:aCashOut];
        [additionalInfoAlert addAction:aCancel];
        [self presentViewController:additionalInfoAlert animated:YES completion:nil];
    }
}

- (void)viewTransactionHistory {
    [self performSegueWithIdentifier:@"toTransactionHistory" sender:self];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    NSInteger txtId = textField.tag;
    if (txtId == 21) {
        cashoutAmount = [textField.text stringByReplacingCharactersInRange:range withString:string];
    }
    return YES;
}
    
- (void)viewCreditCardInfo {
    NSString *creditCardAlertMessage;
    NSString *creditCardBtnMessage;
    STPPaymentCardTextField *paymentTextField = [[STPPaymentCardTextField alloc] init];
    paymentTextField.delegate = self;
    
    if (hasCreditCard) {
        paymentTextField.frame = CGRectMake(15, 95, [UIScreen mainScreen].bounds.size.width - 80, 50);
        creditCardAlertMessage = @"You may key in a new credit card below:\n\n\n\n";
        creditCardBtnMessage = @"Replace Current Credit Card";
    } else {
        paymentTextField.frame = CGRectMake(15, 70, [UIScreen mainScreen].bounds.size.width - 80, 50);
        creditCardAlertMessage = @"You may add a new credit card below:\n\n\n";
        creditCardBtnMessage = @"Add Credit Card";
    }
    
    creditCardAlert = [UIAlertController alertControllerWithTitle:@"Credit Card Options"
                                                                             message:creditCardAlertMessage
                                                                              preferredStyle:UIAlertControllerStyleAlert];
    [creditCardAlert.view addSubview:paymentTextField];
    
    UIAlertAction *aAddNewCard = [UIAlertAction
                              actionWithTitle:creditCardBtnMessage
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction * action) {
                                  [[STPAPIClient sharedClient] createTokenWithCard:paymentTextField.cardParams completion:^(STPToken *token, NSError *error) {
                                      [self sendCardDetails:token];
                                  }];
                              }];
    [creditCardAlert addAction:aAddNewCard];
    
    if (hasCreditCard) {
        UIAlertAction *aDeleteCard = [UIAlertAction
                                      actionWithTitle:@"Delete Current Credit Card"
                                      style:UIAlertActionStyleDefault
                                      handler:^(UIAlertAction * action) {
                                          [self sendCardDetails:nil];
                                      }];
        [creditCardAlert addAction:aDeleteCard];
    }
    
    UIAlertAction *aCancel = [UIAlertAction
                              actionWithTitle:@"Cancel"
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction * action) {
                                  [self dismissViewControllerAnimated:YES completion:nil];
                              }];
    [creditCardAlert addAction:aCancel];
    
    [self presentViewController: creditCardAlert animated: YES completion:^{ creditCardAlert.view.superview.userInteractionEnabled = YES; [creditCardAlert.view.superview addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(handleEndEditing)]];
    }];
}

-(void)handleEndEditing {
    [creditCardAlert.view endEditing:YES];
}

#pragma mark - navigation bar
- (void)showHideButtonsAction {
    if (_navBar.isShowing) {
        [_navBar hideAnimated:YES completionHandler:nil];
    } else {
        [_navBar showAnimated:YES completionHandler:nil];
    }
}

#pragma mark - Get Profile Data
- (void)getProfileData {
    __block NSInteger success = 0;
    if (token != nil && token != NULL) {
        NSURL *url = [NSURL URLWithString:GET_PROFILE_URL];
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
                isSuccessfulCall = YES;
                walletAmount = [dataResponse objectForKey:@"eWallet"];
                withheldAmount = [dataResponse objectForKey:@"withheld"];
                creditCardNumber = [dataResponse objectForKey:@"creditCardLast4"];
                creditCardExpiry = [dataResponse objectForKey:@"creditCardExpiry"];
                creditCardBrand = [dataResponse objectForKey:@"brand"];
                bankAccountNumber = [dataResponse objectForKey:@"bankAccount"];
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
                                          [self performSegueWithIdentifier:@"resetApp2" sender:self];
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

#pragma mark - Cash Out
- (void)cashOut:(NSString *)amt {
    __block NSInteger success = 0;
    NSDictionary *cashoutData = [NSDictionary dictionaryWithObjectsAndKeys:
                                amt, @"cost",
                                nil];
    
    NSDictionary *jsonData = [NSDictionary dictionaryWithObjectsAndKeys:
                              cashoutData, @"data",
                              nil];
    
    if (token != nil && token != NULL) {
        NSURL *url = [NSURL URLWithString:CASHOUT_URL];
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
                                                                                            message:@"Please log in again."
                                                                                     preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *aReturn = [UIAlertAction
                                          actionWithTitle:@"OK"
                                          style:UIAlertActionStyleDefault
                                          handler:^(UIAlertAction * action) {
                                              [self performSegueWithIdentifier:@"resetApp2" sender:self];
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
                                          [self performSegueWithIdentifier:@"resetApp2" sender:self];
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
                                          [self performSegueWithIdentifier:@"resetApp2" sender:self];
                                      }];
            [cannotProceedAlert addAction:aReturn];
            [self presentViewController:cannotProceedAlert animated:YES completion:nil];
        }
    }
}

- (void)sendCardDetails:(STPToken *)stripeToken {
    __block NSInteger success = 0;
    NSDictionary *jsonData = [[NSDictionary alloc] init];
    
    if (stripeToken != nil) {
        NSString *tokenString = [stripeToken tokenId];
        NSDictionary *ccData = [NSDictionary dictionaryWithObjectsAndKeys:
                                     tokenString, @"stripeToken",
                                     @NO, @"isDelete",
                                     nil];
        jsonData = [NSDictionary dictionaryWithObjectsAndKeys:
                                  ccData, @"data",
                                  nil];
    } else {
        NSDictionary *ccData = [NSDictionary dictionaryWithObjectsAndKeys:
                                @"", @"stripeToken",
                                @YES, @"isDelete",
                                nil];
        
        jsonData = [NSDictionary dictionaryWithObjectsAndKeys:
                    ccData, @"data",
                    nil];
    }
    
    if (token != nil && token != NULL) {
        NSURL *url = [NSURL URLWithString:EDIT_CREDIT_CARD_URL];
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
                                                      ProfileController *myController = [self.storyboard instantiateViewControllerWithIdentifier:@"profileController"];
                                                      [self.navigationController pushViewController:myController animated:YES];
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
                                          [self performSegueWithIdentifier:@"resetApp2" sender:self];
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

#pragma mark - Logout
- (void)logout {
    UIAlertController *logoutAlert = [UIAlertController alertControllerWithTitle:@"Warning!"
                                                                   message:@"Do you wish to logout?"
                                                                preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *btnYes = [UIAlertAction
                              actionWithTitle:@"Yes, Log me out"
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction * action) {
                                  NSURL *url = [NSURL URLWithString:LOGOUT_URL];
                                  NSError *error = [[NSError alloc] init];
                                  NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
                                  [request setURL:url];
                                  [request setHTTPMethod:@"GET"];
                                  [request setValue:token forHTTPHeaderField:@"token"];
                                  [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
                                  
                                  NSHTTPURLResponse *response = nil;
                                  [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
                                  NSLog(@"Response code: %ld", (long)[response statusCode]);
                                  [userPrefs setValue:nil forKey:AUTHENTICATION_TOKEN];
                                  [userPrefs setValue:nil forKey:LAST_UPDATED_TIME];
                                  [userPrefs synchronize];
                                  [self performSegueWithIdentifier:@"resetApp2" sender:self];
                              }];
    
    UIAlertAction *btnNo = [UIAlertAction
                              actionWithTitle:@"No, thanks"
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction * action) {
                                  [self dismissViewControllerAnimated:YES completion:nil];
                              }];
    
    [logoutAlert addAction:btnYes];
    [logoutAlert addAction:btnNo];
    
    [self presentViewController:logoutAlert animated:YES completion:nil];
}

- (IBAction)btnLogout2:(id)sender {
    [self logout];
}

@end
