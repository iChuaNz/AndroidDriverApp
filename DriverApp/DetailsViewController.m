//
//  DriverApp
//
//  Created by KangJie Lim on 27/2/17.
//  Copyright © 2017 Commute-Solutions. All rights reserved.
//

#import "DetailsViewController.h"

@interface DetailsViewController ()

@end

@implementation DetailsViewController
NSUserDefaults *userPrefs;
NSArray *passengersDataResponse;
NSArray *passengersCanIdListToday;
int totalCountToday;

- (void)viewDidLoad {
    [super viewDidLoad];
    userPrefs = [NSUserDefaults standardUserDefaults];
    NSData *archivedData = [userPrefs objectForKey:PASSENGER_GENERAL_DATA];
    passengersDataResponse = [NSKeyedUnarchiver unarchiveObjectWithData:archivedData];
    
    archivedData = [userPrefs objectForKey:PASSENGER_LIST_TODAY];
    if (archivedData == nil) {
        totalCountToday = 0;
    } else {
        passengersCanIdListToday = [NSKeyedUnarchiver unarchiveObjectWithData:archivedData];
        NSOrderedSet *uniqueList = [[NSOrderedSet alloc] initWithArray:passengersCanIdListToday];
        totalCountToday = (int) [uniqueList count];
    }
    
    [self initializeForm];
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    return self;
}

- (void)initializeForm {
    XLFormDescriptor *form;
    XLFormSectionDescriptor *section;
    XLFormRowDescriptor *row;

    form = [XLFormDescriptor formDescriptorWithTitle:@"Passenger List"];
    section = [XLFormSectionDescriptor formSection];
    [form addFormSection:section];

    int totalPassengerCount = (int)[passengersDataResponse count];

    for (int i = 0; i < [passengersDataResponse count]; i++) {
        NSDictionary *passenger = [passengersDataResponse objectAtIndex:i];
        bool isOnBoard = false;
//        NSString *photoLink = [passenger objectForKey:@"picUrl"];
//        NSData *imageData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: photoLink]];
//        UIImage *photoImage = [UIImage imageWithData: imageData];

//        row = [XLFormRowDescriptor formRowDescriptorWithTag:@"name" rowType:XLFormRowDescriptorTypeImage title:[passenger objectForKey:@"name"]];
//        row.height = 100;
//        row.value = photoImage;
//        [row.cellConfigAtConfigure setObject:[NSNumber valueWithCGRect:CGRectMake(0, 0, 100, 100)] forKey:@"accessoryView.frame"];
//        row.disabled = @YES;
//        [section addFormRow:row];
        
        for (int j = 0; j < totalCountToday; j++) {
            if ([[passenger objectForKey:@"ezlinkCanId"] isEqualToString:[passengersCanIdListToday objectAtIndex:j]]) {
                isOnBoard = true;
            }
        }

        row = [XLFormRowDescriptor formRowDescriptorWithTag:@"name" rowType:XLFormRowDescriptorTypeInfo title:[passenger objectForKey:@"name"]];
        if (isOnBoard) {
            row.value = @"✔";
            [row.cellConfig setObject:[UIColor greenColor] forKey:@"backgroundColor"];
        } else {
            row.value = @"";
        }
        [section addFormRow:row];

//        row = [XLFormRowDescriptor formRowDescriptorWithTag:@"nokName" rowType:XLFormRowDescriptorTypeInfo title:@"Next of Kin"];
//        row.value = [passenger objectForKey:@"nokName"];
//        [section addFormRow:row];
        
//        row = [XLFormRowDescriptor formRowDescriptorWithTag:@"nokContact" rowType:XLFormRowDescriptorTypeInfo title:@"Next of Kin Contact No."];
//        row.value = [passenger objectForKey:@"nokContact"];
//        [section addFormRow:row];
//        
//        row = [XLFormRowDescriptor formRowDescriptorWithTag:@"nokRelationship" rowType:XLFormRowDescriptorTypeInfo title:@"Next of Kin Relationship"];
//        row.value = [passenger objectForKey:@"nokRelationship"];
//        [section addFormRow:row];
    }

    [form addFormSection:section];

    /*******************/

    section = [XLFormSectionDescriptor formSection];
    [form addFormSection:section];
    NSString *totalCount = [NSString stringWithFormat:@"Passengers on Board: %i/%i", totalCountToday, totalPassengerCount];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"totalPassengerList" rowType:XLFormRowDescriptorTypeInfo title:totalCount];
    row.value = @"";
    [section addFormRow:row];

    /*******************/

    self.form = form;
}

- (void)didSelectFormRow:(XLFormRowDescriptor *)formRow {
    [super didSelectFormRow:formRow];
//    if ([formRow.tag isEqual:@"nokContact"]) {
//        NSString *contactNumber = [NSString stringWithFormat:@"tel://%@",formRow.value ];
//        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:contactNumber]];
//    }
}

-(void)formRowDescriptorValueHasChanged:(XLFormRowDescriptor *)formRow oldValue:(id)oldValue newValue:(id)newValue{
    [super formRowDescriptorValueHasChanged:formRow oldValue:oldValue newValue:newValue];
//    XLFormOptionsObject *value = newValue;
//    NSString *formTag = formRow.tag;
//    @try {
//        if ([formTag isEqualToString:@"isTracking"]) {
//            if (toTrack) {
//                toTrack = false;
//            } else {
//                toTrack = true;
//            }
//            [userPrefs setBool:toTrack forKey:IS_TRACKING];
//        } else if ([formTag isEqualToString:@"followingCamera"]) {
//            if (followsCamera) {
//                followsCamera = false;
//            } else {
//                followsCamera = true;
//            }
//            [userPrefs setBool:followsCamera forKey:FOLLOW_CURRENT_LOCATION];
//        } else {
//            if (toShowMsg) {
//                toShowMsg = false;
//            } else {
//                toShowMsg = true;
//            }
//            [userPrefs setBool:toShowMsg forKey:SHOW_MESSAGE];
//        }
//    } @catch (NSException *exception) {
//        //do nothing
//    } @finally {
//        const BOOL didSave = [userPrefs synchronize];
//        if (!didSave) {
//            [self alertStatus:@"Memory is full" :@"Unable to save settings!" :0];
//        }
//    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)alertStatus:(NSString *)msg :(NSString *)title :(int) tag
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:msg
                                                       delegate:self
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil, nil];
    alertView.tag = tag;
    [alertView show];
}

@end
