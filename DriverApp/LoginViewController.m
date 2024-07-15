//
//  DriverApp
//
//  Created by KangJie Lim on 10/11/16.
//  Copyright © 2016 Commute-Solutions. All rights reserved.
//

#import "LoginViewController.h"
@import Firebase;

@interface LoginViewController ()

@end

@implementation LoginViewController
NSUserDefaults *userPrefs;
NSString *deviceToken;
NSString *role;
NSString *lang;

- (void)loadView {
    [super loadView];
    self.navigationItem.hidesBackButton = YES;
    
    userPrefs = [NSUserDefaults standardUserDefaults];
    NSString *authToken = [userPrefs objectForKey:AUTHENTICATION_TOKEN];
    [self phoneModelCheck];
    [userPrefs setObject:nil forKey:PASSENGER_LIST_TODAY];
    const BOOL didSave = [userPrefs synchronize];
    if (!didSave) {
        [self alertStatus:@"Memory is full" :@"Unable to save settings!"];
    }
    
    lang = [userPrefs objectForKey:LANGUAGE];
    if ([lang isEqualToString:@""] || lang == nil) {
        lang = @"EN";
        [userPrefs setValue:@"EN" forKey:LANGUAGE];
        [userPrefs synchronize];
    }

    if (authToken == nil) {
        if ([lang isEqualToString:@"EN"]) {
            self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[[UIView alloc] init]];
            UIBarButtonItem *btnLanguage = [[UIBarButtonItem alloc] initWithTitle:@"Language" style:UIBarButtonItemStylePlain target:self action:@selector(languageSettings)];
            [btnLanguage setTintColor:[UIColor whiteColor]];
            self.navigationItem.rightBarButtonItem = btnLanguage;
        } else if ([lang isEqualToString:@"CH"]) {
            self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[[UIView alloc] init]];
            UIBarButtonItem *btnLanguage = [[UIBarButtonItem alloc] initWithTitle:@"语言" style:UIBarButtonItemStylePlain target:self action:@selector(languageSettings)];
            [btnLanguage setTintColor:[UIColor whiteColor]];
            self.navigationItem.rightBarButtonItem = btnLanguage;
            
            [self.lblGreeting setText:@"感谢您使用BusLink。请使用您的ID登录。"];
            [self.txtUserName setPlaceholder:@"用户名"];
            [self.txtPassword setPlaceholder:@"密码"];
            [self.btnLogin setTitle:@"登录" forState:UIControlStateNormal];
        }
    } else {
        NSString *redirection = [userPrefs objectForKey:REDIRECT_INTENT];
        if (redirection != nil) {
            [userPrefs setObject:nil forKey:REDIRECT_INTENT];
            [userPrefs synchronize];
            if ([redirection isEqualToString:@"1"]) {
                AvailableCharterViewController *myController = [self.storyboard instantiateViewControllerWithIdentifier:@"AvailableCharterViewController"];
                [self.navigationController pushViewController:myController animated:YES];
            } else if  ([redirection isEqualToString:@"2"]) {
                JobsViewController *myController = [self.storyboard instantiateViewControllerWithIdentifier:@"JobsViewController"];
                myController.identifyingProperty = @"subout";
                [self.navigationController pushViewController:myController animated:YES];
            } else if  ([redirection isEqualToString:@"3"]) {
                JobsViewController *myController = [self.storyboard instantiateViewControllerWithIdentifier:@"JobsViewController"];
                myController.identifyingProperty = @"scheduled";
                [self.navigationController pushViewController:myController animated:YES];
            } else if  ([redirection isEqualToString:@"5"]) {
                DisputeController *myController = [self.storyboard instantiateViewControllerWithIdentifier:@"DisputeController"];
                [self.navigationController pushViewController:myController animated:YES];
            } else if  ([redirection isEqualToString:@"6"]) {
                ProfileController *myController = [self.storyboard instantiateViewControllerWithIdentifier:@"profileController"];
                [self.navigationController pushViewController:myController animated:YES];
            } else {
                SingleCharterViewController *myController = [self.storyboard instantiateViewControllerWithIdentifier:@"singleCharterView"];
                myController.charterId = redirection;
                myController.previousControllerView = [NSNumber numberWithInt:0];
                [self.navigationController pushViewController:myController animated:YES];
            }
        } else {
            NSString *lastSeenView = [userPrefs objectForKey:LAST_SAVED_STATE];
            if ([lastSeenView isEqualToString:@"map"]) {
                [self performSegueWithIdentifier:@"login_success" sender:self];
            } else if ([lastSeenView isEqualToString:@"charter"]) {
                [self performSegueWithIdentifier:@"login_success_2" sender:self];
            }
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Login";
    deviceToken = [[FIRInstanceID instanceID] token];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnLogin:(id)sender {
    NSInteger success = 0;
    bool isSuccessful = false;
    @try {
        if ([[self.txtUserName text] isEqualToString:@""] || [[self.txtPassword text] isEqualToString:@""]) {
            [self alertStatus:@"Please enter Email and Password" :@"Log in failed!"];
        } else {
            NSDictionary *jsonData = [NSDictionary dictionaryWithObjectsAndKeys:
                                      [self.txtUserName text], @"username",
                                      [self.txtPassword text], @"password",
                                      deviceToken, @"deviceToken",
                                      nil];
            NSURL *url = [NSURL URLWithString:LOGIN_URL];
            NSError *error = [[NSError alloc] init];
            NSData *postData = [NSJSONSerialization dataWithJSONObject:jsonData options:NSJSONWritingPrettyPrinted error:&error];
            NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
            NSString *jsonString = [[NSString alloc] initWithData:postData encoding:NSUTF8StringEncoding];
            NSLog(@"jsonData as string:\n%@", jsonString);

            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
            [request setURL:url];
            [request setHTTPMethod:@"POST"];
            [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
            [request setHTTPBody:postData];

            NSHTTPURLResponse *response = nil;
            NSData *urlData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
            
            if ([response statusCode] >= 200 && [response statusCode] < 300) {
                NSString *responseData = [[NSString alloc]initWithData:urlData encoding:NSUTF8StringEncoding];
                NSLog(@"Response ==> %@", responseData);

                NSError *error = nil;
                NSDictionary *jsonResponse = [NSJSONSerialization
                                          JSONObjectWithData:urlData
                                          options:NSJSONReadingMutableContainers
                                          error:&error];

                success = [jsonResponse[@"success"] integerValue];
                NSDictionary *dataResponse = [jsonResponse objectForKey:@"data"];
                
                if (success == 1) {
                    isSuccessful = true;
                    NSString *authToken = (NSString *) dataResponse[@"token"];
                    role = (NSString *) dataResponse[@"role"];
                    NSString *userId = [self.txtUserName text];

                    [userPrefs setValue:authToken forKey:AUTHENTICATION_TOKEN];
                    [userPrefs setValue:userId forKey:USER_ID];
                    [userPrefs setValue:role forKey:ROLE];
                    const BOOL didSave = [userPrefs synchronize];
                    NSLog(@"Login SUCCESS");

                    if (!didSave) {
                        [self alertStatus:@"Memory is full" :@"Log in failed!"];
                    } else {
                        NSLog(@"%@ has logged in.", userId);
                    }
                } else {
                    NSString *error_msg = (NSString *) jsonResponse[@"error_message"];
                    if ([lang isEqualToString:@"EN"]) {
                        [self alertStatus:error_msg :@"Sign in Failed!"];
                    } else if ([lang isEqualToString:@"CH"]) {
                        [self alertStatus:@"请检查您的用户名和密码。" :@""];
                    }
                }
            } else {
                [self alertStatus:@"Connection Failed" :@"Sign in Failed!"];
            }
        }
    }
    @catch (NSException * e) {
        NSLog(@"Exception: %@", e);
        [self alertStatus:@"Log in failed" :@"Error!"];
    }

    if (isSuccessful) {
//        [userPrefs setBool:TRUE forKey:IS_FIRST_TIME];
        [userPrefs setBool:TRUE forKey:FOLLOW_CURRENT_LOCATION];
        [userPrefs setBool:FALSE forKey:SHOW_MESSAGE];
        [userPrefs setBool:FALSE forKey:IS_TRACKING];
        const BOOL didSave = [userPrefs synchronize];
        if (!didSave) {
            [self alertStatus:@"Memory is full" :@"Unable to save settings!"];
        } else {
            if ([role isEqualToString:@"omo"]) {
                UIAlertController *alert;
                if ([lang isEqualToString:@"EN"]) {
                    alert = [UIAlertController alertControllerWithTitle:@"Welcome!"
                                                                        message:@"Where would you like to go to today?"
                                                                        preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *toTracker = [UIAlertAction
                                                actionWithTitle:@"Tracker"
                                                style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction * action) {
                                                    [self performSegueWithIdentifier:@"login_success" sender:self];
                                                }];
                    
                    UIAlertAction *toCharteringPage = [UIAlertAction
                                                       actionWithTitle:@"Chartering Page"
                                                       style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * action) {
                                                           [self performSegueWithIdentifier:@"login_success_2" sender:self];
                                                       }];
                    [alert addAction:toTracker];
                    [alert addAction:toCharteringPage];
                } else if ([lang isEqualToString:@"CH"]) {
                    alert = [UIAlertController alertControllerWithTitle:@"你好！"
                                                                        message:@"请选择一种模式"
                                                                        preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *toTracker = [UIAlertAction
                                                actionWithTitle:@"追踪器"
                                                style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction * action) {
                                                    [self performSegueWithIdentifier:@"login_success" sender:self];
                                                }];
                    
                    UIAlertAction *toCharteringPage = [UIAlertAction
                                                       actionWithTitle:@"包车服务"
                                                       style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * action) {
                                                           [self performSegueWithIdentifier:@"login_success_2" sender:self];
                                                       }];
                    [alert addAction:toTracker];
                    [alert addAction:toCharteringPage];
                }
                [self presentViewController:alert animated:YES completion:nil];
            } else if ([role isEqualToString:@"admin"]) {
                [self performSegueWithIdentifier:@"login_success_2" sender:self];
            } else {
                [self performSegueWithIdentifier:@"login_success" sender:self];
            }
        }
    }
}

- (IBAction)toBackground:(id)sender {
    [self.view endEditing:YES];
}

- (IBAction)languageSettings {
    UIAlertController *languageAlert;
    if ([lang isEqualToString:@"EN"]) {
        languageAlert = [UIAlertController alertControllerWithTitle:@"Language Setting"
                                                                    message:@"Please select a language."
                                                                    preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *aEnglish = [UIAlertAction
                                   actionWithTitle:@"English"
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * action) {
                                       [self alertStatus:@"App is already in English." :@"Attention!"];
                                   }];
        
        UIAlertAction *aChinese = [UIAlertAction
                                   actionWithTitle:@"中文"
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * action) {
                                       [userPrefs setValue:@"CH" forKey:LANGUAGE];
                                       [userPrefs synchronize];
                                       UIAlertController *acknowledgementAlert = [UIAlertController alertControllerWithTitle:@"注意"
                                                                                                                     message:@"应用程序现在将关闭。请重新打开应用程序。"
                                                                                                              preferredStyle:UIAlertControllerStyleAlert];
                                       UIAlertAction *aRestart = [UIAlertAction
                                                                  actionWithTitle:@"OK"
                                                                  style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * action) {
                                                                      exit(0);
                                                                  }];
                                       [acknowledgementAlert addAction:aRestart];
                                       [self presentViewController:acknowledgementAlert animated:YES completion:nil];
                                   }];
        [languageAlert addAction:aEnglish];
        [languageAlert addAction:aChinese];
    } else if ([lang isEqualToString:@"CH"]) {
        languageAlert = [UIAlertController alertControllerWithTitle:@"语言设定"
                                                            message:@"请选择一种语言"
                                                     preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *aEnglish = [UIAlertAction
                                   actionWithTitle:@"English"
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * action) {
                                       [userPrefs setValue:@"EN" forKey:LANGUAGE];
                                       [userPrefs synchronize];
                                       UIAlertController *acknowledgementAlert = [UIAlertController alertControllerWithTitle:@"Attention!"
                                                                                                                     message:@"App will now close. Please re-open the app to see the selected language."
                                                                                                              preferredStyle:UIAlertControllerStyleAlert];
                                       UIAlertAction *aRestart = [UIAlertAction
                                                                  actionWithTitle:@"OK"
                                                                  style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * action) {
                                                                      exit(0);
                                                                  }];
                                       [acknowledgementAlert addAction:aRestart];
                                       [self presentViewController:acknowledgementAlert animated:YES completion:nil];
                                   }];
        
        UIAlertAction *aChinese = [UIAlertAction
                                   actionWithTitle:@"中文"
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * action) {
                                       [self alertStatus:@"目前已经在使用中文。" :@"注意"];
                                   }];
        [languageAlert addAction:aEnglish];
        [languageAlert addAction:aChinese];
    }
    [self presentViewController:languageAlert animated:YES completion:nil];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)alertStatus:(NSString *)msg :(NSString *)title {
    UIAlertController *alertView = [UIAlertController alertControllerWithTitle:title
                                                                    message:msg
                                                                    preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *aOK = [UIAlertAction
                            actionWithTitle:@"OK"
                            style:UIAlertActionStyleDefault
                            handler:^(UIAlertAction * action) {
                                [self dismissViewControllerAnimated:YES completion:nil];
                            }];
    
    [alertView addAction:aOK];
    [self presentViewController:alertView animated:YES completion:nil];
}

- (void)phoneModelCheck {
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *phoneModel = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    
    if ([phoneModel isEqualToString:@"iPhone1,1"]) {
        phoneModel = @"1";
    } else if ([phoneModel isEqualToString:@"iPhone1,2"]) {
        phoneModel = @"3G";
    } else if ([phoneModel isEqualToString:@"iPhone2,1"]) {
        phoneModel = @"3GS";
    } else if ([phoneModel isEqualToString:@"iPhone3,1"] || [phoneModel isEqualToString:@"iPhone3,3"]) {
        phoneModel = @"4";
    } else if ([phoneModel isEqualToString:@"iPhone4,1"]) {
        phoneModel = @"4S";
    } else if ([phoneModel isEqualToString:@"iPhone5,1"] || [phoneModel isEqualToString:@"iPhone5,2"]) {
        phoneModel = @"5";
    } else if ([phoneModel isEqualToString:@"iPhone5,3"] || [phoneModel isEqualToString:@"iPhone5,4"]) {
        phoneModel = @"5C";
    } else if ([phoneModel isEqualToString:@"iPhone6,1"] || [phoneModel isEqualToString:@"iPhone6,2"]) {
        phoneModel = @"5S";
    } else if ([phoneModel isEqualToString:@"iPhone8,4"]) {
        phoneModel = @"SE";
    } else if ([phoneModel isEqualToString:@"iPhone7,2"]) {
        phoneModel = @"6";
    } else if ([phoneModel isEqualToString:@"iPhone7,1"]) {
        phoneModel = @"6Plus";
    } else if ([phoneModel isEqualToString:@"iPhone8,1"]) {
        phoneModel = @"6S";
    } else if ([phoneModel isEqualToString:@"iPhone8,2"]) {
        phoneModel = @"6SPlus";
    } else if ([phoneModel isEqualToString:@"iPhone9,1"] || [phoneModel isEqualToString:@"iPhone9,3"]) {
        phoneModel = @"7";
    } else if ([phoneModel isEqualToString:@"iPhone9,2"] || [phoneModel isEqualToString:@"iPhone9,4"]) {
        phoneModel = @"7Plus";
    } else if ([phoneModel isEqualToString:@"iPhone10,1"] || [phoneModel isEqualToString:@"iPhone10,4"]) {
        phoneModel = @"8";
    } else if ([phoneModel isEqualToString:@"iPhone10,2"] || [phoneModel isEqualToString:@"iPhone10,5"]) {
        phoneModel = @"8Plus";
    } else if ([phoneModel isEqualToString:@"iPhone10,3"] || [phoneModel isEqualToString:@"iPhone10,6"]) {
        phoneModel = @"X";
    }
    
    [userPrefs setValue:phoneModel forKey:PHONE_MODEL];
    [userPrefs synchronize];
    NSLog(@"Phone Model: iPhone %@", phoneModel);
}

@end
