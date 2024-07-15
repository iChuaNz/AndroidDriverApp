//
//  DriverApp
//
//  Created by KangJie Lim on 23/2/18.
//  Copyright © 2018 Commute-Solutions. All rights reserved.
//

#ifndef ContractDetailsViewController_h
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "UserPreferences.h"
#import "Constants.h"
#import "NetworkUtility.h"
#import "LGPlusButtonsView.h"
#import "JDFCurrencyTextField.h"
#define ContractDetailsViewController_h

@interface ContractDetailsViewController : UIViewController <UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate>
{
    UIDatePicker *datePicker;
    UIDatePicker *timePicker;
    UIPickerView *pickerView;
}

@property (weak, nonatomic) IBOutlet UITextField *txtStartDate;
@property (weak, nonatomic) IBOutlet UITextField *txtEndDate;
@property (weak, nonatomic) IBOutlet UITextField *txtPickupTime;
@property (weak, nonatomic) IBOutlet UITextField *txtBusSize;
@property (weak, nonatomic) IBOutlet UITextField *txtContactNumber;
@property (weak, nonatomic) IBOutlet JDFCurrencyTextField *txtCostPerMonth;
@property (weak, nonatomic) IBOutlet UISwitch *swHasERP;
@property (weak, nonatomic) IBOutlet UISwitch *swIncludesERP;
@property (weak, nonatomic) IBOutlet UILabel *txtAdditionalInfo;

@property (strong, nonatomic) LGPlusButtonsView *navBar;
@property (nonatomic, retain) NSString *charterId;
@property (nonatomic, retain) NSDictionary *contract;
@property (nonatomic, retain) NSNumber *previousControllerView;
@property (nonatomic, retain) NSString *identifyingProperty;

#define UIColorFromRGB(rgbValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0x00FF00) >>  8))/255.0 \
blue:((float)((rgbValue & 0x0000FF) >>  0))/255.0 \
alpha:1.0]
@end

#endif /* ContractDetailsViewController_h */
