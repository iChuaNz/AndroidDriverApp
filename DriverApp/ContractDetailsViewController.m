//
//  DriverApp
//
//  Created by KangJie Lim on 23/2/18.
//  Copyright © 2018 Commute-Solutions. All rights reserved.
//

#import "ContractDetailsViewController.h"

@interface ContractDetailsViewController ()

@end

@implementation ContractDetailsViewController
NSUserDefaults *userPrefs;
NSString *token;

NSArray *pickerData;
NSString *selectedBusSize;
NSString *additionalInfoString;
NSDate *startDate;
NSDate *endDate;
bool hasERP;
bool includesERP;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Details";
    UIBarButtonItem *btnSideMenu = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(showHideButtonsAction)];
    [btnSideMenu setTintColor:[UIColor whiteColor]];
    self.navigationItem.rightBarButtonItem = btnSideMenu;
    
    userPrefs = [NSUserDefaults standardUserDefaults];
    token = [userPrefs stringForKey:AUTHENTICATION_TOKEN];
    
    NSDate *currentDate = [NSDate date];
    datePicker = [[UIDatePicker alloc] init];
    [datePicker setDatePickerMode:UIDatePickerModeDate];
    [datePicker setMinimumDate:currentDate];
    [_txtStartDate setInputView:datePicker];
    [_txtEndDate setInputView:datePicker];
    
    timePicker = [[UIDatePicker alloc] init];
    [timePicker setDatePickerMode:UIDatePickerModeTime];
    [_txtPickupTime setInputView:timePicker];
    
    pickerView = [[UIPickerView alloc] init];
    pickerData = @[@"11-Seater", @"13-Seater", @"19-Seater", @"23-Seater", @"40-Seater", @"45-Seater", @"49-Seater"];
    [pickerView setDelegate:self];
    [pickerView setDataSource:self];
    [_txtBusSize setInputView:pickerView];
    
    UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    [toolBar setTintColor:[UIColor grayColor]];
    UIBarButtonItem *btnDone = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(setStartDate)];
    UIBarButtonItem *filler = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [toolBar setItems:[NSArray arrayWithObjects:filler, btnDone, nil]];
    [_txtStartDate setInputAccessoryView:toolBar];
    
    UIToolbar *toolBar2 = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    [toolBar2 setTintColor:[UIColor grayColor]];
    UIBarButtonItem *btnDone2 = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(setEndDate)];
    [toolBar2 setItems:[NSArray arrayWithObjects:filler, btnDone2, nil]];
    [_txtEndDate setInputAccessoryView:toolBar2];
    
    UIToolbar *toolBar3 = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    [toolBar3 setTintColor:[UIColor grayColor]];
    UIBarButtonItem *btnDone3 = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(setPickupTime)];
    [toolBar3 setItems:[NSArray arrayWithObjects:filler, btnDone3, nil]];
    [_txtPickupTime setInputAccessoryView:toolBar3];
    
    UIToolbar *toolBar4 = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    [toolBar4 setTintColor:[UIColor grayColor]];
    UIBarButtonItem *btnDone4 = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(setBusSize)];
    [toolBar4 setItems:[NSArray arrayWithObjects:filler, btnDone4, nil]];
    [_txtBusSize setInputAccessoryView:toolBar4];
    
    UIBarButtonItem *btncloseView = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(closeView)];
    UIToolbar *closeViewToolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    [closeViewToolBar setTintColor:[UIColor grayColor]];
    [closeViewToolBar setItems:[NSArray arrayWithObjects:filler, btncloseView, nil]];
    [_txtCostPerMonth setInputAccessoryView:closeViewToolBar];
    [_txtContactNumber setInputAccessoryView:closeViewToolBar];
    
    [_txtAdditionalInfo.layer setCornerRadius:8];
    [_txtAdditionalInfo.layer setBorderColor:[UIColor grayColor].CGColor];
    [_txtAdditionalInfo.layer setBorderWidth:1];
    [_txtAdditionalInfo setUserInteractionEnabled:YES];
    UITapGestureRecognizer *keyboard = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openKeyboard)];
    [_txtAdditionalInfo addGestureRecognizer:keyboard];
    
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    UIButton *btnSubmit = [UIButton buttonWithType:UIButtonTypeCustom];
    btnSubmit.frame = CGRectMake(0, screenHeight - 50, screenWidth, 50);
    [btnSubmit setBackgroundColor:UIColorFromRGB(0xF68B1F)];
    [btnSubmit setTitle:@"Submit" forState:UIControlStateNormal];
    [btnSubmit addTarget:self action:@selector(validateInputs) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:btnSubmit];
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

- (IBAction)hasERPSwitchPressed:(id)sender {
    if (_swHasERP.on) {
        [_swIncludesERP setEnabled:YES];
        hasERP = YES;
    } else {
        [_swIncludesERP setEnabled:NO];
        [_swIncludesERP setOn:NO animated:YES];
        hasERP = NO;
    }
}

- (IBAction)includesERPSwitchPressed:(id)sender {
    if (_swIncludesERP.on) {
        includesERP = YES;
    } else {
        includesERP = NO;
    }
}

- (void)setStartDate {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd-MMM-YYYY"];
    startDate = datePicker.date;
    [_txtStartDate setText:[NSString stringWithFormat:@"%@", [dateFormatter stringFromDate:datePicker.date]]];
    [_txtStartDate resignFirstResponder];
}

- (void)setEndDate {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd-MMM-YYYY"];
    endDate = datePicker.date;
    [_txtEndDate setText:[NSString stringWithFormat:@"%@", [dateFormatter stringFromDate:datePicker.date]]];
    [_txtEndDate resignFirstResponder];
}

- (void)setPickupTime {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm a"];
    [_txtPickupTime setText:[NSString stringWithFormat:@"%@", [dateFormatter stringFromDate:timePicker.date]]];
    [_txtPickupTime resignFirstResponder];
}

- (void)setBusSize {
    [_txtBusSize setText:selectedBusSize];
    [_txtBusSize resignFirstResponder];
}

- (void)closeView {
    [_txtCostPerMonth resignFirstResponder];
    [_txtContactNumber resignFirstResponder];
}

- (void)validateInputs {
    if (startDate == nil) {
        UIAlertController *errorAlert = [UIAlertController alertControllerWithTitle:@"Error!"
                                                                                 message:@"Please enter the start date."
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *aOk = [UIAlertAction
                              actionWithTitle:@"OK"
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction * action) {
                                  [self dismissViewControllerAnimated:YES completion:nil];
                              }];
        [errorAlert addAction:aOk];
        [self presentViewController:errorAlert animated:YES completion:nil];
    } else if (endDate == nil) {
        UIAlertController *errorAlert = [UIAlertController alertControllerWithTitle:@"Error!"
                                                                            message:@"Please enter the end date."
                                                                     preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *aOk = [UIAlertAction
                              actionWithTitle:@"OK"
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction * action) {
                                  [self dismissViewControllerAnimated:YES completion:nil];
                              }];
        [errorAlert addAction:aOk];
        [self presentViewController:errorAlert animated:YES completion:nil];
    } else if ([_txtPickupTime.text isEqual: @""]) {
        UIAlertController *errorAlert = [UIAlertController alertControllerWithTitle:@"Error!"
                                                                            message:@"Please enter the first pickup time."
                                                                     preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *aOk = [UIAlertAction
                              actionWithTitle:@"OK"
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction * action) {
                                  [self dismissViewControllerAnimated:YES completion:nil];
                              }];
        [errorAlert addAction:aOk];
        [self presentViewController:errorAlert animated:YES completion:nil];
    } else if ([_txtContactNumber.text isEqual: @""]) {
        UIAlertController *errorAlert = [UIAlertController alertControllerWithTitle:@"Error!"
                                                                            message:@"Please enter the your contact number."
                                                                     preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *aOk = [UIAlertAction
                              actionWithTitle:@"OK"
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction * action) {
                                  [self dismissViewControllerAnimated:YES completion:nil];
                              }];
        [errorAlert addAction:aOk];
        [self presentViewController:errorAlert animated:YES completion:nil];
    } else if ([[_txtCostPerMonth decimalValue] doubleValue] < 500) {
        UIAlertController *errorAlert = [UIAlertController alertControllerWithTitle:@"Error!"
                                                                            message:@"Please fill in a reasonable cost. If your contract is less than a month. Please multiply the cost per trip with the number of working days. Thank you."
                                                                     preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *aOk = [UIAlertAction
                              actionWithTitle:@"OK"
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction * action) {
                                  [self dismissViewControllerAnimated:YES completion:nil];
                              }];
        [errorAlert addAction:aOk];
        [self presentViewController:errorAlert animated:YES completion:nil];
    } else if ([_txtBusSize.text isEqual: @""]) {
        UIAlertController *errorAlert = [UIAlertController alertControllerWithTitle:@"Error!"
                                                                            message:@"Please select the bus size you wish to perform this contract."
                                                                     preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *aOk = [UIAlertAction
                              actionWithTitle:@"OK"
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction * action) {
                                  [self dismissViewControllerAnimated:YES completion:nil];
                              }];
        [errorAlert addAction:aOk];
        [self presentViewController:errorAlert animated:YES completion:nil];
//    } else if ([startDate timeIntervalSinceDate:endDate] < 7) {
//        UIAlertController *errorAlert = [UIAlertController alertControllerWithTitle:@"Error!"
//                                                                            message:@"The contract you are trying to list is less than 7 days."
//                                                                     preferredStyle:UIAlertControllerStyleAlert];
//        UIAlertAction *aOk = [UIAlertAction
//                              actionWithTitle:@"OK"
//                              style:UIAlertActionStyleDefault
//                              handler:^(UIAlertAction * action) {
//                                  [self dismissViewControllerAnimated:YES completion:nil];
//                              }];
//        [errorAlert addAction:aOk];
//        [self presentViewController:errorAlert animated:YES completion:nil];
    } else if ([startDate timeIntervalSinceDate:endDate] > 0) {
        UIAlertController *errorAlert = [UIAlertController alertControllerWithTitle:@"Error!"
                                                                            message:@"The end date you have entered is before the start date."
                                                                     preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *aOk = [UIAlertAction
                              actionWithTitle:@"OK"
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction * action) {
                                  [self dismissViewControllerAnimated:YES completion:nil];
                              }];
        [errorAlert addAction:aOk];
        [self presentViewController:errorAlert animated:YES completion:nil];
    } else {
        NSString *message = @"";
        NSString *pickup1String = [userPrefs stringForKey:PICKUP1_STRING];
        NSString *pickup2String = [userPrefs stringForKey:PICKUP2_STRING];
        NSString *pickup3String = [userPrefs stringForKey:PICKUP3_STRING];
        NSString *dropoff1String = [userPrefs stringForKey:DROPOFF1_STRING];
        NSString *dropoff2String = [userPrefs stringForKey:DROPOFF2_STRING];
        NSString *dropoff3String = [userPrefs stringForKey:DROPOFF3_STRING];
        
        //P1 D1
        if (([pickup2String isEqual: @""] || pickup2String == nil) && ([pickup3String isEqual: @""] || pickup3String == nil) && ([dropoff2String isEqual: @""] || dropoff2String == nil) && ([dropoff3String isEqual: @""] || dropoff3String == nil)) {
            message = [NSString stringWithFormat:@"Date: %@ - %@\nFrom: %@\nTo: %@\nTime: %@\nContact No.: %@\nCost: $%f\nBus Required: %@\nAdditional Info:%@",
                       _txtStartDate.text, _txtEndDate.text, pickup1String, dropoff1String, _txtPickupTime.text, _txtContactNumber.text, [[_txtCostPerMonth decimalValue] doubleValue], _txtBusSize.text, additionalInfoString];
        //P1 P2 D1
        } else if ((![pickup2String isEqual: @""] || pickup2String != nil) && ([pickup3String isEqual: @""] || pickup3String == nil) && ([dropoff2String isEqual: @""] || dropoff2String == nil) && ([dropoff3String isEqual: @""] || dropoff3String == nil)) {
            message = [NSString stringWithFormat:@"Date: %@ - %@\nFrom: %@,%@\nTo: %@\nTime: %@\nContact No.: %@\nCost: $%f\nBus Required: %@\nAdditional Info:%@",
                       _txtStartDate.text, _txtEndDate.text, pickup1String, pickup2String, dropoff1String, _txtPickupTime.text, _txtContactNumber.text, [[_txtCostPerMonth decimalValue] doubleValue], _txtBusSize.text, additionalInfoString];
        //P1 P2 P3 D1
        } else if ((![pickup2String isEqual: @""] || pickup2String != nil) && (![pickup3String isEqual: @""] || pickup3String != nil) && ([dropoff2String isEqual: @""] || dropoff2String == nil) && ([dropoff3String isEqual: @""] || dropoff3String == nil)) {
            message = [NSString stringWithFormat:@"Date: %@ - %@\nFrom: %@, %@, %@\nTo: %@\nTime: %@\nContact No.: %@\nCost: $%f\nBus Required: %@\nAdditional Info:%@",
                       _txtStartDate.text, _txtEndDate.text, pickup1String, pickup2String, pickup3String, dropoff1String, _txtPickupTime.text, _txtContactNumber.text, [[_txtCostPerMonth decimalValue] doubleValue], _txtBusSize.text, additionalInfoString];
        //P1 D1 D2
        } else if (([pickup2String isEqual: @""] || pickup2String == nil) && ([pickup3String isEqual: @""] || pickup3String == nil) && (![dropoff2String isEqual: @""] || dropoff2String != nil) && ([dropoff3String isEqual: @""] || dropoff3String == nil)) {
            message = [NSString stringWithFormat:@"Date: %@ - %@\nFrom: %@\nTo: %@, %@\nTime: %@\nContact No.: %@\nCost: $%f\nBus Required: %@\nAdditional Info:%@",
                       _txtStartDate.text, _txtEndDate.text, pickup1String, dropoff1String, dropoff2String, _txtPickupTime.text, _txtContactNumber.text, [[_txtCostPerMonth decimalValue] doubleValue], _txtBusSize.text, additionalInfoString];
        //P1 D1 D2 D3
        } else if (([pickup2String isEqual: @""] || pickup2String == nil) && ([pickup3String isEqual: @""] || pickup3String == nil) && (![dropoff2String isEqual: @""] || dropoff2String != nil) && (![dropoff3String isEqual: @""] || dropoff3String != nil)) {
            message = [NSString stringWithFormat:@"Date: %@ - %@\nFrom: %@\nTo: %@, %@, %@\nTime: %@\nContact No.: %@\nCost: $%f\nBus Required: %@\nAdditional Info:%@",
                       _txtStartDate.text, _txtEndDate.text, pickup1String, dropoff1String, dropoff2String, dropoff3String, _txtPickupTime.text, _txtContactNumber.text, [[_txtCostPerMonth decimalValue] doubleValue], _txtBusSize.text, additionalInfoString];
        //P1 P2 D1 D2
        } else if ((![pickup2String isEqual: @""] || pickup2String != nil) && ([pickup3String isEqual: @""] || pickup3String == nil) && (![dropoff2String isEqual: @""] || dropoff2String != nil) && ([dropoff3String isEqual: @""] || dropoff3String == nil)) {
            message = [NSString stringWithFormat:@"Date: %@ - %@\nFrom: %@, %@\nTo: %@, %@\nTime: %@\nContact No.: %@\nCost: $%f\nBus Required: %@\nAdditional Info:%@",
                       _txtStartDate.text, _txtEndDate.text, pickup1String, pickup2String, dropoff1String, dropoff2String, _txtPickupTime.text, _txtContactNumber.text, [[_txtCostPerMonth decimalValue] doubleValue], _txtBusSize.text, additionalInfoString];
        //P1 P2 D1 D2 D3
        } else if ((![pickup2String isEqual: @""] || pickup2String != nil) && ([pickup3String isEqual: @""] || pickup3String == nil) && (![dropoff2String isEqual: @""] || dropoff2String != nil) && (![dropoff3String isEqual: @""] || dropoff3String != nil)) {
            message = [NSString stringWithFormat:@"Date: %@ - %@\nFrom: %@, %@\nTo: %@, %@, %@\nTime: %@\nContact No.: %@\nCost: $%f\nBus Required: %@\nAdditional Info:%@",
                       _txtStartDate.text, _txtEndDate.text, pickup1String, pickup2String, dropoff1String, dropoff2String, dropoff3String, _txtPickupTime.text, _txtContactNumber.text, [[_txtCostPerMonth decimalValue] doubleValue], _txtBusSize.text, additionalInfoString];
        //P1 P2 P3 D1 D2
        } else if ((![pickup2String isEqual: @""] || pickup2String != nil) && (![pickup3String isEqual: @""] || pickup3String != nil) && (![dropoff2String isEqual: @""] || dropoff2String != nil) && ([dropoff3String isEqual: @""] || dropoff3String == nil)) {
            message = [NSString stringWithFormat:@"Date: %@ - %@\nFrom: %@, %@, %@\nTo: %@, %@\nTime: %@\nContact No.: %@\nCost: $%f\nBus Required: %@\nAdditional Info:%@",
                       _txtStartDate.text, _txtEndDate.text, pickup1String, pickup2String, pickup3String, dropoff1String, dropoff2String, _txtPickupTime.text, _txtContactNumber.text, [[_txtCostPerMonth decimalValue] doubleValue], _txtBusSize.text, additionalInfoString];
        //P1 P2 P3 D1 D2 D3
        } else if ((![pickup2String isEqual: @""] || pickup2String != nil) && (![pickup3String isEqual: @""] || pickup3String != nil) && (![dropoff2String isEqual: @""] || dropoff2String != nil) && (![dropoff3String isEqual: @""] || dropoff3String != nil)) {
            message = [NSString stringWithFormat:@"Date: %@ - %@\nFrom: %@, %@, %@\nTo: %@, %@, %@\nTime: %@\nContact No.: %@\nCost: $%f\nBus Required: %@\nAdditional Info:%@",
                       _txtStartDate.text, _txtEndDate.text, pickup1String, pickup2String, pickup3String, dropoff1String, dropoff2String, dropoff3String, _txtPickupTime.text, _txtContactNumber.text, [[_txtCostPerMonth decimalValue] doubleValue], _txtBusSize.text, _txtAdditionalInfo.text];
        }
        
        UIAlertController *errorAlert = [UIAlertController alertControllerWithTitle:@"Confirmation"
                                                                            message:message
                                                                     preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *aOk = [UIAlertAction
                              actionWithTitle:@"OK"
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction * action) {
                                  [self submitNewContract];
                              }];
        UIAlertAction *aCancel = [UIAlertAction
                              actionWithTitle:@"Cancel"
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction * action) {
                                  [self dismissViewControllerAnimated:YES completion:nil];
                              }];
        [errorAlert addAction:aOk];
        [errorAlert addAction:aCancel];
        [self presentViewController:errorAlert animated:YES completion:nil];
        
    }
}

- (void)openKeyboard {
    UIAlertController *infoAlert = [UIAlertController alertControllerWithTitle:@"Additional Information"
                                                                       message:@"Please enter any addtional information you wish to include in this contract job here."
                                                                preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *aConfirmInfo = [UIAlertAction
                                   actionWithTitle:@"Save Info"
                                   style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                       [_txtAdditionalInfo setText:additionalInfoString];
                                       [_txtAdditionalInfo setTextColor:[UIColor blackColor]];
                                   }];
    UIAlertAction *aCancel = [UIAlertAction
                                        actionWithTitle:@"Cancel"
                                        style:UIAlertActionStyleDefault
                                        handler:^(UIAlertAction * action) {
                                            [self dismissViewControllerAnimated:YES completion:nil];
                                        }];
    
    [infoAlert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        [textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        textField.tag = 29;
        textField.delegate = self;
        textField.text = additionalInfoString;
    }];
    
    [infoAlert addAction:aConfirmInfo];
    [infoAlert addAction:aCancel];
    [self presentViewController:infoAlert animated:YES completion:nil];
}

//- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
//    NSInteger txtId = textField.tag;
//    if (txtId == 29) {
//        additionalInfoString = textField.text;
//    }
//    return YES;
//}

- (void)textFieldDidChange:(UITextField *)textField {
    additionalInfoString = textField.text;
}

#pragma mark - navigation bar
- (void)showHideButtonsAction {
    if (_navBar.isShowing)
        [_navBar hideAnimated:YES completionHandler:nil];
    else
        [_navBar showAnimated:YES completionHandler:nil];
}

#pragma mark - submit contract
- (void)submitNewContract {
    __block NSInteger success = 0;
    NSString *pickupPointName1 = [userPrefs stringForKey:PICKUP1_STRING];
    NSString *pickupPointName2 = [userPrefs stringForKey:PICKUP2_STRING];
    if (pickupPointName2 == nil) {
        pickupPointName2 = @"";
    }
    NSString *pickupPointName3 = [userPrefs stringForKey:PICKUP3_STRING];
    if (pickupPointName3 == nil) {
        pickupPointName3 = @"";
    }
    NSString *dropoffPointName1 = [userPrefs stringForKey:DROPOFF1_STRING];
    NSString *dropoffPointName2 = [userPrefs stringForKey:DROPOFF2_STRING];
    if (dropoffPointName2 == nil) {
        dropoffPointName2 = @"";
    }
    NSString *dropoffPointName3 = [userPrefs stringForKey:DROPOFF3_STRING];
    if (dropoffPointName3 == nil) {
        dropoffPointName3 = @"";
    }
    
    float pickup1Lat = [userPrefs doubleForKey:PICKUP1_LAT];
    float pickup2Lat = [userPrefs doubleForKey:PICKUP2_LAT];
    float pickup3Lat = [userPrefs doubleForKey:PICKUP3_LAT];
    
    float pickup1Lng = [userPrefs doubleForKey:PICKUP1_LNG];
    float pickup2Lng = [userPrefs doubleForKey:PICKUP2_LNG];
    float pickup3Lng = [userPrefs doubleForKey:PICKUP3_LNG];
    
    float dropoff1Lat = [userPrefs doubleForKey:DROPOFF1_LAT];
    float dropoff2Lat = [userPrefs doubleForKey:DROPOFF2_LAT];
    float dropoff3Lat = [userPrefs doubleForKey:DROPOFF3_LAT];
    
    float dropoff1Lng = [userPrefs doubleForKey:DROPOFF1_LNG];
    float dropoff2Lng = [userPrefs doubleForKey:DROPOFF2_LNG];
    float dropoff3Lng = [userPrefs doubleForKey:DROPOFF3_LNG];
    
    if (additionalInfoString == nil) {
        additionalInfoString = @"";
    }
    
    NSDictionary *contractData = [NSDictionary dictionaryWithObjectsAndKeys:
                                  pickupPointName1, @"pickupPoint1Name",
                                  pickupPointName2, @"pickupPoint2Name",
                                  pickupPointName3, @"pickupPoint3Name",
                                  dropoffPointName1, @"dropoffPoint1Name",
                                  dropoffPointName2, @"dropoffPoint2Name",
                                  dropoffPointName3, @"dropoffPoint3Name",
                                  @(pickup1Lat), @"pickupPoint1Lat",
                                  @(pickup2Lat), @"pickupPoint2Lat",
                                  @(pickup3Lat), @"pickupPoint3Lat",
                                  @(pickup1Lng), @"pickupPoint1Lng",
                                  @(pickup2Lng), @"pickupPoint2Lng",
                                  @(pickup3Lng), @"pickupPoint3Lng",
                                  @(dropoff1Lat), @"dropoffPoint1Lat",
                                  @(dropoff2Lat), @"dropoffPoint2Lat",
                                  @(dropoff3Lat), @"dropoffPoint3Lat",
                                  @(dropoff1Lng), @"dropoffPoint1Lng",
                                  @(dropoff2Lng), @"dropoffPoint2Lng",
                                  @(dropoff3Lng), @"dropoffPoint3Lng",
                                  @(hasERP), @"hasERP",
                                  @(includesERP), @"includesERP",
                                  selectedBusSize, @"busSize",
                                  additionalInfoString, @"additionalInfo",
                                  @([[_txtCostPerMonth decimalValue] doubleValue]), @"contractCost",
                                  _txtContactNumber.text, @"contactNo",
                                  _txtPickupTime.text, @"pickUpTime",
                                  _txtStartDate.text, @"startDate",
                                  _txtEndDate.text, @"endDate",
                                 nil];
    
    NSDictionary *jsonData = [NSDictionary dictionaryWithObjectsAndKeys:
                              contractData, @"data",
                              nil];
    
    NSURL *url = [NSURL URLWithString:CREATE_CONTRACT_URL];
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
            
            NSDictionary *dataResponse = [jsonResponse objectForKey:@"data"];
            NSString *message = [dataResponse objectForKey:@"message"];
            UIAlertController *confirmationAlert = [UIAlertController alertControllerWithTitle:@"Message"
                                                                                       message:message
                                                                                preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *aCloseAlertView = [UIAlertAction
                                              actionWithTitle:@"OK"
                                              style:UIAlertActionStyleDefault
                                              handler:^(UIAlertAction * action) {
                                                  [self performSegueWithIdentifier:@"toPickupPoint" sender:self];
                                              }];
            [confirmationAlert addAction:aCloseAlertView];
            [self presentViewController:confirmationAlert animated:YES completion:nil];
        } else {
            UIAlertController *cannotProceedAlert = [UIAlertController alertControllerWithTitle:@"Error!"
                                                                                        message:@"Unable to submit to server. You can try again later or you may contact your operations team."
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return pickerData.count;
}

- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return pickerData[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    selectedBusSize = [pickerData objectAtIndex:row];
}

@end
