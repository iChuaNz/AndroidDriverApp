//
//  DriverApp
//
//  Created by KangJie Lim on 10/11/16.
//  Copyright © 2016 Commute-Solutions. All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController
NSUserDefaults *userPrefs;
NSString *token;
NSString *lang;

BOOL toTrack;
BOOL toShowMsg;
BOOL followsCamera;
int nfcId;
NSString *formObjectValue;


NSString *name;
NSString *lastUpdatedTime;
NSString *numOfPassengers;
NSString *versionNo;

BOOL isBluetoothStatusOk;
BOOL hasBluetoothDeviceStored;
BOOL isNotACardReader;
BOOL usingNFC;
NSString *bluetoothName;

//BOOL isInternalNFCEnabled;
BOOL isExternalNFCEnabled;

int tapCount;

- (void)loadView {
    [super loadView];
    self.navigationItem.hidesBackButton = YES;
    
    UIBarButtonItem *btnToMap = [[UIBarButtonItem alloc] initWithTitle:@"Map" style:UIBarButtonItemStylePlain target:self action:@selector(toMap)];
    [btnToMap setTintColor:[UIColor whiteColor]];
    self.navigationItem.rightBarButtonItem = btnToMap;
    
    self.navigationItem.title = @"Settings";
}

- (void)viewDidLoad {
    [super viewDidLoad];
    userPrefs = [NSUserDefaults standardUserDefaults];
    token = [userPrefs stringForKey:AUTHENTICATION_TOKEN];
    
    lang = [userPrefs objectForKey:LANGUAGE];
    if ([lang isEqualToString:@"CH"]) {
        UIBarButtonItem *btnToMap = [[UIBarButtonItem alloc] initWithTitle:@"追踪器" style:UIBarButtonItemStylePlain target:self action:@selector(toMap)];
        self.navigationItem.rightBarButtonItem = btnToMap;
        
        self.navigationItem.title = @"设置";
    }
    
    name = [[userPrefs stringForKey:USER_ID] uppercaseString];
    lastUpdatedTime = [userPrefs stringForKey:LAST_UPDATED_TIME];
    numOfPassengers = [NSString stringWithFormat:@"%ld",(long)[userPrefs integerForKey:NO_OF_PASSENGERS]];

    if (lastUpdatedTime == nil) {
        lastUpdatedTime = @"";
    }
    
    if (numOfPassengers == nil) {
        numOfPassengers = @"";
    }

    NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
    NSString *appVersion = [info objectForKey:@"CFBundleShortVersionString"];
    versionNo = appVersion;
//    versionNo = @"Staging";

    toTrack = [userPrefs boolForKey:IS_TRACKING];
    toShowMsg = [userPrefs boolForKey:SHOW_MESSAGE];
    followsCamera = [userPrefs boolForKey:FOLLOW_CURRENT_LOCATION];
    nfcId = (int)[userPrefs integerForKey:NFC_SETTINGS];
//    isInternalNFCEnabled = [userPrefs boolForKey:ENABLE_INTERNAL_NFC];
    isExternalNFCEnabled = [userPrefs boolForKey:ENABLE_EXTERNAL_NFC];

    bluetoothName = [userPrefs stringForKey:BLUETOOTH_NAME];
    if (bluetoothName == nil) {
        hasBluetoothDeviceStored = false;
    } else {
        hasBluetoothDeviceStored = true;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [self initializeForm];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    return self;
}
    
- (void)initializeForm {
    XLFormDescriptor *form;
    XLFormSectionDescriptor *section;
    XLFormRowDescriptor *row;

    form = [XLFormDescriptor formDescriptorWithTitle:@"Settings"];

    // First section
    section = [XLFormSectionDescriptor formSection];
    [form addFormSection:section];

    // User Id
    if ([lang isEqualToString:@"EN"]) {
        row = [XLFormRowDescriptor formRowDescriptorWithTag:@"userId" rowType:XLFormRowDescriptorTypeInfo title:@"User ID"];
    } else if ([lang isEqualToString:@"CH"]) {
        row = [XLFormRowDescriptor formRowDescriptorWithTag:@"userId" rowType:XLFormRowDescriptorTypeInfo title:@"用户名"];
    }
    row.value = name;
    [section addFormRow:row];

    // Last Updated Time
    if ([lang isEqualToString:@"EN"]) {
        row = [XLFormRowDescriptor formRowDescriptorWithTag:@"lastUpdatedTime" rowType:XLFormRowDescriptorTypeInfo title:@"Last Updated"];
    } else if ([lang isEqualToString:@"CH"]) {
        row = [XLFormRowDescriptor formRowDescriptorWithTag:@"lastUpdatedTime" rowType:XLFormRowDescriptorTypeInfo title:@"最近更新时间"];
    }
    row.value = lastUpdatedTime;
    [section addFormRow:row];

    // No of Passengers
    if ([lang isEqualToString:@"EN"]) {
        row = [XLFormRowDescriptor formRowDescriptorWithTag:@"noOfPassengers" rowType:XLFormRowDescriptorTypeInfo title:@"Passengers Count"];
    } else if ([lang isEqualToString:@"CH"]) {
        row = [XLFormRowDescriptor formRowDescriptorWithTag:@"noOfPassengers" rowType:XLFormRowDescriptorTypeInfo title:@"乘客数量"];
    }
    row.value = numOfPassengers;
    [section addFormRow:row];

    /*******************/

    // Second Section
    section = [XLFormSectionDescriptor formSection];
    [form addFormSection:section];

    // Tracking
    if ([lang isEqualToString:@"EN"]) {
        row = [XLFormRowDescriptor formRowDescriptorWithTag:@"isTracking" rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"Tracking"];
    } else if ([lang isEqualToString:@"CH"]) {
        row = [XLFormRowDescriptor formRowDescriptorWithTag:@"isTracking" rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"追踪器"];
    }
    
    if (toTrack) {
        row.value = @(YES);
    } else {
        row.value = @(NO);
    }
    [section addFormRow:row];

    // Show Messages
    if ([lang isEqualToString:@"EN"]) {
        row = [XLFormRowDescriptor formRowDescriptorWithTag:@"showMessages" rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"Show Messages"];
    } else if ([lang isEqualToString:@"CH"]) {
        row = [XLFormRowDescriptor formRowDescriptorWithTag:@"showMessages" rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"显示消息"];
    }
    if (toShowMsg) {
        row.value = @(YES);
    } else {
        row.value = @(NO);
    }
    [section addFormRow:row];

    // Follows Driver Location
    if ([lang isEqualToString:@"EN"]) {
        row = [XLFormRowDescriptor formRowDescriptorWithTag:@"followingCamera" rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"Camera Follow Driver"];
    } else if ([lang isEqualToString:@"CH"]) {
        row = [XLFormRowDescriptor formRowDescriptorWithTag:@"followingCamera" rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"相机跟随巴士"];
    }
    if (followsCamera) {
        row.value = @(YES);
    } else {
        row.value = @(NO);
    }
    [section addFormRow:row];

    /*******************/

    // Third Section
    section = [XLFormSectionDescriptor formSection];
    [form addFormSection:section];
    
    // NFC Setting
    if ([lang isEqualToString:@"EN"]) {
        row = [XLFormRowDescriptor formRowDescriptorWithTag:@"nfcSettings" rowType:XLFormRowDescriptorTypeSelectorAlertView title:@"NFC Settings" ];
    } else if ([lang isEqualToString:@"CH"]) {
        row = [XLFormRowDescriptor formRowDescriptorWithTag:@"nfcSettings" rowType:XLFormRowDescriptorTypeSelectorAlertView title:@"NFC 设置" ];
    }
    row.selectorOptions = @[[XLFormOptionsObject formOptionsObjectWithValue:@(0) displayText:@"No NFC"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(1) displayText:@"External NFC"]
                            ];
    if (nfcId == 0) {
        row.value = [XLFormOptionsObject formOptionsObjectWithValue:@(0) displayText:@"No NFC"];
    } else if (nfcId == 1) {
        row.value = [XLFormOptionsObject formOptionsObjectWithValue:@(1) displayText:@"External NFC"];
    }
    
    if (!isExternalNFCEnabled) {
        row.disabled = @(YES);
    }

    [section addFormRow:row];

    // Bluetooth Setting
    if ([lang isEqualToString:@"EN"]) {
        row = [XLFormRowDescriptor formRowDescriptorWithTag:@"bluetoothDevice" rowType:XLFormRowDescriptorTypeSelectorAlertView title:@"BluetoothDevice"];
    } else if ([lang isEqualToString:@"CH"]) {
        row = [XLFormRowDescriptor formRowDescriptorWithTag:@"bluetoothDevice" rowType:XLFormRowDescriptorTypeSelectorAlertView title:@"蓝牙设备"];
    }
    if (hasBluetoothDeviceStored) {
        row.value = [XLFormOptionsObject formOptionsObjectWithValue:@(0) displayText:bluetoothName];
        row.disabled = @(YES);
    } else {
        row.value = [XLFormOptionsObject formOptionsObjectWithValue:@(1) displayText:@"Tap to select"];
        row.disabled = @(NO);
    }
    if (nfcId == 1) {
        [self detectBluetooth];
        row.hidden = @(NO);
    } else {
        row.hidden = @(YES);
    }
    
    [section addFormRow:row];

    if ([lang isEqualToString:@"EN"]) {
        row = [XLFormRowDescriptor formRowDescriptorWithTag:@"disconnectDevice" rowType:XLFormRowDescriptorTypeButton title:@"Disconnect Reader"];
    } else if ([lang isEqualToString:@"CH"]) {
        row = [XLFormRowDescriptor formRowDescriptorWithTag:@"disconnectDevice" rowType:XLFormRowDescriptorTypeButton title:@"断开"];
    }
    
    if (nfcId == 1) {
        row.hidden = @(NO);
        if (hasBluetoothDeviceStored) {
            row.disabled = @(NO);
        } else {
            row.disabled = @(YES);
        }
    } else {
        row.hidden = @(YES);
        row.disabled = @(YES);
    }
    row.action.formSelector = @selector(disconnectReader:);
    [section addFormRow:row];

    /*******************/

    // Fourth Section
    section = [XLFormSectionDescriptor formSection];
    [form addFormSection:section];

    // Version
    if ([lang isEqualToString:@"EN"]) {
        row = [XLFormRowDescriptor formRowDescriptorWithTag:@"version" rowType:XLFormRowDescriptorTypeInfo title:@"Version"];
    } else if ([lang isEqualToString:@"CH"]) {
        row = [XLFormRowDescriptor formRowDescriptorWithTag:@"version" rowType:XLFormRowDescriptorTypeInfo title:@"版"];
    }
    row.value = versionNo;
    [section addFormRow:row];

    self.form = form;
}

- (void)didSelectFormRow:(XLFormRowDescriptor *)formRow {
    [super didSelectFormRow:formRow];
    if ([formRow.tag isEqual:@"version"]) {
        tapCount++;
        if (tapCount == 10) {
            tapCount = 0;
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Warning!" message:@"Do you wish to logout?" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *yesButton =[UIAlertAction actionWithTitle:@"Yes, Log me out" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                [self logout];
                [self performSegueWithIdentifier:@"resetApp" sender:self];
                
//                [userPrefs setValue:nil forKey:IS_FIRST_TIME];
                [userPrefs setValue:nil forKey:AUTHENTICATION_TOKEN];
                [userPrefs setValue:nil forKey:LAST_UPDATED_TIME];
                const BOOL didSave = [userPrefs synchronize];
                if (!didSave) {
                    [self alertStatus:@"Memory Error" :@"Unable to logout!" :0];
                } else {
                    NSLog(@"%@ has logged out.", name);
                }
            }];
            UIAlertAction* noButton = [UIAlertAction actionWithTitle:@"No, thanks" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                //do nothing
            }];

            [alert addAction:yesButton];
            [alert addAction:noButton];

            [self presentViewController:alert animated:YES completion:nil];
        }
    }

    if ([formRow.tag isEqual:@"bluetoothDevice"]) {
        [self startScanningForDevices];
        NSMutableArray *devicesFound = [[NSMutableArray alloc] init];
        for (int i = 0; i < [_peripherals count]; i++) {
            CBPeripheral *peripheral = [_peripherals objectAtIndex:i];
            NSString *peripheralName = [peripheral name];
            if (peripheralName != nil) {
                [devicesFound addObject:peripheralName];
            }
        }
        if ([devicesFound count] > 0) {
            [self.form formRowWithTag:@"bluetoothDevice"].selectorOptions = devicesFound;
        }
        [self reloadFormRow:formRow];
    }
    
    if ([formRow.tag isEqual:@"disconnectDevice"]) {
//        [userPrefs setValue:nil forKey:BLUETOOTH_NAME];
//        [userPrefs setValue:nil forKey:BLUETOOTH_ADDRESS];
//        [userPrefs setInteger:1 forKey:NFC_SETTINGS];
//        const BOOL didSave = [userPrefs synchronize];
//        if (!didSave) {
//            [self alertStatus:@"Memory is full" :@"Unable to save settings!" :0];
//        }
//        [self.form formRowWithTag:@"bluetoothDevice"].value = [XLFormOptionsObject formOptionsObjectWithValue:@(2) displayText:@"Tap to select"];
        [self initializeForm];
    }
}

-(void)formRowDescriptorValueHasChanged:(XLFormRowDescriptor *)formRow oldValue:(id)oldValue newValue:(id)newValue{
    [super formRowDescriptorValueHasChanged:formRow oldValue:oldValue newValue:newValue];
    XLFormOptionsObject *value = newValue;
    NSString *formTag = formRow.tag;
    @try {
        if ([formTag isEqualToString:@"isTracking"]) {
            if (toTrack) {
                toTrack = false;
            } else {
                toTrack = true;
            }
            [userPrefs setBool:toTrack forKey:IS_TRACKING];
        } else if ([formTag isEqualToString:@"followingCamera"]) {
            if (followsCamera) {
                followsCamera = false;
            } else {
                followsCamera = true;
            }
            [userPrefs setBool:followsCamera forKey:FOLLOW_CURRENT_LOCATION];
        } else if ([formTag isEqualToString:@"showMessages"]) {
            if (toShowMsg) {
                toShowMsg = false;
            } else {
                toShowMsg = true;
            }
            [userPrefs setBool:toShowMsg forKey:SHOW_MESSAGE];
        } else if ([formTag isEqualToString:@"nfcSettings"]){
            @try {
                formObjectValue = [value formDisplayText];
            } @catch (NSException *exception) {
                formObjectValue = (NSString *) newValue;
            } @finally {
                if ([formObjectValue isEqualToString: @"No NFC"]) {
                    [userPrefs setInteger:0 forKey:NFC_SETTINGS];
                    [self.form formRowWithTag:@"bluetoothDevice"].hidden = @(YES);
                    [self.form formRowWithTag:@"disconnectDevice"].hidden = @(YES);
                } else if ([formObjectValue isEqualToString: @"External NFC"]) {
                    [self detectBluetooth];
                    if (isBluetoothStatusOk) {
                        [userPrefs setInteger:1 forKey:NFC_SETTINGS];
                        [self.form formRowWithTag:@"bluetoothDevice"].hidden = @(NO);
                        [self.form formRowWithTag:@"disconnectDevice"].hidden = @(NO);
                    } else {
                        [userPrefs setInteger:0 forKey:NFC_SETTINGS];
                        formRow.value = @"No NFC";
                        [self.form formRowWithTag:@"bluetoothDevice"].hidden = @(YES);
                        [self.form formRowWithTag:@"disconnectDevice"].hidden = @(YES);
                    }
                } else if ([formObjectValue isEqualToString: @"Tap to select"]) {
                    [self.form formRowWithTag:@"bluetoothDevice"].disabled = @(NO);
                    [self.form formRowWithTag:@"disconnectDevice"].disabled = @(YES);
                    [self initializeForm];
                }
            }
        } else {
            @try {
                formObjectValue = [value formDisplayText];
            } @catch (NSException *exception) {
                formObjectValue = (NSString *) newValue;
            }
            if ([formObjectValue rangeOfString:@"ACR1255U" options:NSCaseInsensitiveSearch].location != NSNotFound) {
                isNotACardReader = false;
                bluetoothName = formObjectValue;
                [userPrefs setValue:formObjectValue forKey:BLUETOOTH_NAME];
                [self.form formRowWithTag:@"disconnectDevice"].disabled = @(NO);
                [self.form formRowWithTag:@"bluetoothDevice"].disabled = @(YES);
            } else if ([formObjectValue isEqualToString:@"Tap to select"]) {
                [self initializeForm];
            } else {
                isNotACardReader = true;
                if ([lang isEqualToString:@"EN"]) {
                    [self alertStatus:@"This is not a card reader. Please select a card reader from the list" :@"Bluetooth status" :0];
                } else if ([lang isEqualToString:@"CH"]) {
                    [self alertStatus:@"这不是nfc设备。" :@"蓝牙状态" :0];
                }
            }
            [_bluetoothManager stopScan];
        }
    } @catch (NSException *exception) {
        //do nothing
    } @finally {
        const BOOL didSave = [userPrefs synchronize];
        if (!didSave) {
            [self alertStatus:@"Memory is full" :@"Unable to save settings!" :0];
        }
    }
}

- (void)detectBluetooth
{
    _peripherals = [[NSMutableArray alloc] init];
    if(!self.bluetoothManager)
    {
        // Put on main queue so we can call UIAlertView from delegate callbacks.
        self.bluetoothManager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue()];
    }
    
    [self centralManagerDidUpdateState:self.bluetoothManager]; // Show initial state
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    NSString *stateString = nil;
    _bluetoothManager = central;
    switch(_bluetoothManager.state)
    {
        case CBManagerStateResetting:
            NSLog(@"The connection with the system service was momentarily lost, update imminent.");
            isBluetoothStatusOk = true;
            break;
        case CBManagerStateUnsupported:
            stateString = @"The platform doesn't support Bluetooth Low Energy.";
            isBluetoothStatusOk = false;
            break;
        case CBManagerStateUnauthorized:
            stateString = @"The app is not authorized to use Bluetooth Low Energy.";
            isBluetoothStatusOk = false;
            break;
        case CBManagerStatePoweredOff:
            stateString = @"Bluetooth is currently powered off.";
            isBluetoothStatusOk = false;
            break;
        case CBManagerStatePoweredOn:
            isBluetoothStatusOk = true;
            break;
        default:
            NSLog(@"State unknown, update imminent.");
            isBluetoothStatusOk = true;
            break;
    }
    if (stateString != nil) {
        [self alertStatus:stateString :@"Bluetooth status" :0];
    }
}

- (void)logout {
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
}

/* Bluetooth Device Scanning - START*/
- (void) startScanningForDevices {
    [_bluetoothManager scanForPeripheralsWithServices:nil options:[NSDictionary dictionaryWithObjectsAndKeys:@NO, CBCentralManagerScanOptionAllowDuplicatesKey, nil]];
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    if (![_peripherals containsObject:peripheral]){
        [_peripherals addObject:peripheral];
    }
}

- (void)disconnectReader: (XLFormRowDescriptor *)sender {
    [userPrefs setValue:nil forKey:BLUETOOTH_NAME];
    [userPrefs setValue:nil forKey:BLUETOOTH_ADDRESS];
    [userPrefs setInteger:1 forKey:NFC_SETTINGS];
    const BOOL didSave = [userPrefs synchronize];
    if (!didSave) {
        [self alertStatus:@"Memory is full" :@"Unable to save settings!" :0];
    }
    [self.form formRowWithTag:@"bluetoothDevice"].value = [XLFormOptionsObject formOptionsObjectWithValue:@(2) displayText:@"Tap to select"];
}

/* Bluetooth Device Scanning - END*/

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)toMap {
    if (isNotACardReader) {
        if ([lang isEqualToString:@"EN"]) {
            [self alertStatus:@"This is not a card reader. Please select a card reader from the list" :@"Bluetooth status" :0];
        } else if ([lang isEqualToString:@"CH"]) {
            [self alertStatus:@"这不是nfc设备。" :@"蓝牙状态" :0];
        }
    } else {
        NSData *archivedDevice = [userPrefs objectForKey:BLUETOOTH_ADDRESS];
        if (archivedDevice == nil) {
            for (int i = 0; i < [_peripherals count]; i++) {
                CBPeripheral *peripheral = [_peripherals objectAtIndex:i];
                NSString *peripheralName = [peripheral name];
                if ([peripheralName isEqualToString:bluetoothName]) {
                    NSUUID *deviceAddress = [peripheral identifier];
                    archivedDevice = [NSKeyedArchiver archivedDataWithRootObject:deviceAddress];
                    [userPrefs setObject:archivedDevice forKey:BLUETOOTH_ADDRESS];
                    const BOOL didSave = [userPrefs synchronize];
                    if (!didSave) {
                        [self alertStatus:@"Memory is full" :@"Unable to save settings!" :0];
                    } else {
                        NSLog(@"Device stored!");
                    }
                    break;
                }
            }
        }
        [self performSegueWithIdentifier:@"goToMap" sender:self];
    }
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
