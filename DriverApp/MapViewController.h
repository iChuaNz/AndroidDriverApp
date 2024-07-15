//
//  DriverApp
//
//  Created by KangJie Lim on 11/11/16.
//  Copyright © 2016 Commute-Solutions. All rights reserved.
//

#ifndef MapViewController_h
#import <UIKit/UIKit.h>
#import "Constants.h"
#import "UserPreferences.h"
#import "NetworkUtility.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "ACSBluetooth.h"
#import "ABDHex.h"
#import "CustomIOSAlertView.h"
#import "LGPlusButtonsView.h"
#import "DetailsViewController.h"
#import "SettingsViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#define MapViewController_h

@class CBPeripheral;
@interface MapViewController : UIViewController <CLLocationManagerDelegate, UIGestureRecognizerDelegate, CBCentralManagerDelegate, ABTBluetoothReaderManagerDelegate, ABTBluetoothReaderDelegate>
@property (nonatomic) CBCentralManager *bluetoothManager;
@property (nonatomic) CBPeripheral *bluetoothDevice;
@property (nonatomic) ABTBluetoothReaderManager *bluetoothReaderManager;
@property (nonatomic) ABTBluetoothReader *bluetoothReader;
@property (strong) NSOutputStream *outputStream;
@property (strong) AVAudioPlayer *audioPlayer;
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

#endif /* MapViewController_h */
