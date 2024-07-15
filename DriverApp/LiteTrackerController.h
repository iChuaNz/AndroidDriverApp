//
//  DriverApp
//
//  Created by KangJie Lim on 26/10/17.
//  Copyright © 2017 Commute-Solutions. All rights reserved.
//

#ifndef LiteTrackerController_h
#import <UIKit/UIKit.h>
#import "Constants.h"
#import "UserPreferences.h"
#import "NetworkUtility.h"
#import <CoreLocation/CoreLocation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "ACSBluetooth.h"
#import "ABDHex.h"
#import "iToast.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#define LiteTrackerController_h

@interface LiteTrackerController : UIViewController <CLLocationManagerDelegate, CBCentralManagerDelegate, ABTBluetoothReaderManagerDelegate, ABTBluetoothReaderDelegate>
@property (weak, nonatomic) IBOutlet UIView *viewNFCResponse;
@property (weak, nonatomic) IBOutlet UILabel *lblAddress;
@property (weak, nonatomic) IBOutlet UILabel *lblTime;
@property (weak, nonatomic) IBOutlet UILabel *lblPassengerCount;

@property (nonatomic) CBCentralManager *bluetoothManager;
@property (nonatomic) CBPeripheral *bluetoothDevice;
@property (nonatomic) ABTBluetoothReaderManager *bluetoothReaderManager;
@property (nonatomic) ABTBluetoothReader *bluetoothReader;
@property (strong) NSOutputStream *outputStream;
@property (strong) AVAudioPlayer *audioPlayer;

@property (nonatomic, retain) NSString *charterId;
@property (nonatomic, retain) NSDictionary *contract;
@property (nonatomic, retain) NSNumber *previousControllerView;
@property (nonatomic, retain) NSString *identifyingProperty;
- (IBAction)btnDriverInput:(id)sender;

#define UIColorFromRGB(rgbValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0x00FF00) >>  8))/255.0 \
blue:((float)((rgbValue & 0x0000FF) >>  0))/255.0 \
alpha:1.0]
@end

#endif /* LiteTrackerController_h */
