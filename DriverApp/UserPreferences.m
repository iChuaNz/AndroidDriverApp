//
//  DriverApp
//
//  Created by KangJie Lim on 11/11/16.
//  Copyright © 2016 Commute-Solutions. All rights reserved.
//

#ifdef __OBJC__
#import "UserPreferences.h"
#import <Foundation/Foundation.h>
#endif

//Authentication
NSString *const AUTHENTICATION_TOKEN = @"authenticationToken";
NSString *const USER_ID = @"userId";
NSString *const ROLE = @"role";

//Data
NSString *const PASSENGER_GENERAL_DATA = @"passengerGeneralData";
NSString *const NO_OF_PASSENGERS = @"noOfPassengers";
NSString *const LAST_UPDATED_TIME = @"lastUpdatedTime";
NSString *const NFC_SETTINGS = @"nfcSettings";
NSString *const SHOW_MESSAGE = @"showMessage";

//Bluetooth
NSString *const BLUETOOTH_NAME = @"bluetoothName";
NSString *const BLUETOOTH_ADDRESS = @"bluetoothAddress";

//Map
NSString *const IS_TRACKING = @"isTracking";
NSString *const FOLLOW_CURRENT_LOCATION = @"followCurrentLocation";
NSString *const JOBARRAY = @"jobArray";
NSString *const SERVICE_NAME = @"serviceName";

//Job
NSString *const ENABLE_INTERNAL_NFC = @"enableInternalNfc";
NSString *const ENABLE_EXTERNAL_NFC = @"enableExternalNfc";
NSString *const PASSENGER_LIST_TODAY = @"passengerListToday";

//Contract
NSString *const PICKUP1_STRING = @"pickup1String";
NSString *const PICKUP1_LAT = @"pickup1Lat";
NSString *const PICKUP1_LNG = @"pickup1Lng";
NSString *const PICKUP2_STRING = @"pickup2String";
NSString *const PICKUP2_LAT = @"pickup2Lat";
NSString *const PICKUP2_LNG = @"pickup2Lng";
NSString *const PICKUP3_STRING = @"pickup3String";
NSString *const PICKUP3_LAT = @"pickup3Lat";
NSString *const PICKUP3_LNG = @"pickup3Lng";
NSString *const DROPOFF1_STRING = @"dropoff1String";
NSString *const DROPOFF1_LAT = @"dropoff1Lat";
NSString *const DROPOFF1_LNG = @"dropoff1Lng";
NSString *const DROPOFF2_STRING = @"dropoff2String";
NSString *const DROPOFF2_LAT = @"dropoff2Lat";
NSString *const DROPOFF2_LNG = @"dropoff2Lng";
NSString *const DROPOFF3_STRING = @"dropoff3String";
NSString *const DROPOFF3_LAT = @"dropoff3Lat";
NSString *const DROPOFF3_LNG = @"dropoff3Lng";

//Misc
NSString *const LAST_SAVED_STATE = @"lastSavedState";
NSString *const REDIRECT_INTENT = @"redirectIntent";
NSString *const LANGUAGE = @"language";
NSString *const PHONE_MODEL = @"phoneModel";
