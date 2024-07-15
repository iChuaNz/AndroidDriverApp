//
//  DriverApp
//
//  Created by KangJie Lim on 11/11/16.
//  Copyright © 2016 Commute-Solutions. All rights reserved.
//

#ifdef __OBJC__
#import "Constants.h"
#import <Foundation/Foundation.h>
#endif

//
//Production
//
NSString *const LOGIN_URL = @"https://bustracker.azurewebsites.net/api/2/user/login";
NSString *const LOCATION_URL = @"https://bustracker.azurewebsites.net/api/2/locations/gps";
NSString *const JOBS_URL = @"https://bustracker.azurewebsites.net/api/2/Jobs";
NSString *const ATTENDANCE_URL = @"https://bustracker.azurewebsites.net/api/2/Jobs/attendances";
NSString *const LOGOUT_URL = @"https://bustracker.azurewebsites.net/api/2/user/logout";

NSString *const START_TRIP_URL = @"https://bustracker.azurewebsites.net/api/2/Jobs/startTrip";
NSString *const END_TRIP_URL = @"https://bustracker.azurewebsites.net/api/2/Jobs/endTrip";

NSString *const CREATE_CHARTER_URL = @"https://bustracker.azurewebsites.net/api/2/vendor/createcharter";
NSString *const AVAILABLE_CHARTER_URL = @"https://bustracker.azurewebsites.net/api/2/vendor/viewcharters";
NSString *const VIEW_CHARTER_URL = @"https://bustracker.azurewebsites.net/api/2/vendor/ViewCharterDetails";
NSString *const VIEW_SUBOUT_CHARTER_URL = @"https://bustracker.azurewebsites.net/api/2/vendor/viewsuboutcharters";
NSString *const VIEW_SCHEDULED_CHARTER_URL = @"https://bustracker.azurewebsites.net/api/2/vendor/viewacceptedcharters";
NSString *const ACCEPT_CHARTER_URL = @"https://bustracker.azurewebsites.net/api/2/vendor/accept";
NSString *const CANCEL_CHARTER_URL = @"https://bustracker.azurewebsites.net/api/2/vendor/delete";
NSString *const UPDATE_CHARTER_URL = @"https://bustracker.azurewebsites.net/api/2/vendor/charter/updateJob";
NSString *const WITHDRAW_CHARTER_URL  = @"https://bustracker.azurewebsites.net/api/2/vendor/Withdraw";

NSString *const GET_PROFILE_URL = @"https://bustracker.azurewebsites.net/api/2/vendor/profile";
NSString *const GET_ONLINE_USERS_URL = @"https://bustracker.azurewebsites.net/api/2/vendor/OnlineUsers";
NSString *const CASHOUT_URL = @"https://bustracker.azurewebsites.net/api/2/vendor/cashout";
NSString *const EDIT_CREDIT_CARD_URL = @"https://bustracker.azurewebsites.net/api/2/vendor/profile/editCreditCard";
NSString *const TRANSACTION_HISTORY_URL = @"https://bustracker.azurewebsites.net/api/2/vendor/ewallethistory";

NSString *const GET_DRIVER_URL  = @"https://bustracker.azurewebsites.net/api/2/vendor/charter/viewDrivers";
NSString *const UPDATE_DRIVER_URL  = @"https://bustracker.azurewebsites.net/api/2/vendor/charter/updateDriver";
NSString *const UPDATE_POC_URL  = @"https://bustracker.azurewebsites.net/api/2/vendor/charter/updatePOC";

NSString *const NEW_DISPUTE_URL  = @"https://bustracker.azurewebsites.net/api/2/vendor/charter/dispute/new";
NSString *const DISPUTE_RESPONSE_URL  = @"https://bustracker.azurewebsites.net/api/2/vendor/charter/dispute/response";
NSString *const VIEW_DISPUTE_LIST_URL  = @"https://bustracker.azurewebsites.net/api/2/vendor/charter/dispute/history";

NSString *const CREATE_CONTRACT_URL = @"https://bustracker.azurewebsites.net/api/2/vendor/contract/createContract";
NSString *const VIEW_ALL_CONTRACT_URL = @"https://bustracker.azurewebsites.net/api/2/vendor/contract/viewAllContracts";
NSString *const DELETE_CONTRACT_URL = @"https://bustracker.azurewebsites.net/api/2/vendor/contract/deleteContract";
NSString *const CALL_COUNTER_URL = @"https://bustracker.azurewebsites.net/api/2/vendor/contract/callCounter";

//
//Staging
//
//NSString *const LOGIN_URL = @"https://bustrackerstaging.azurewebsites.net/api/2/user/login";
//NSString *const LOCATION_URL = @"https://bustrackerstaging.azurewebsites.net/api/2/locations/gps";
//NSString *const JOBS_URL = @"https://bustrackerstaging.azurewebsites.net/api/2/Jobs";
//NSString *const ATTENDANCE_URL = @"https://bustrackerstaging.azurewebsites.net/api/2/Jobs/attendances";
//NSString *const LOGOUT_URL = @"https://bustrackerstaging.azurewebsites.net/api/2/user/logout";
//
//NSString *const START_TRIP_URL = @"https://bustrackerstaging.azurewebsites.net/api/2/Jobs/startTrip";
//NSString *const END_TRIP_URL = @"https://bustrackerstaging.azurewebsites.net/api/2/Jobs/endTrip";
//
//NSString *const CREATE_CHARTER_URL = @"https://bustrackerstaging.azurewebsites.net/api/2/vendor/createcharter";
//NSString *const AVAILABLE_CHARTER_URL = @"https://bustrackerstaging.azurewebsites.net/api/2/vendor/viewcharters";
//NSString *const VIEW_CHARTER_URL = @"https://bustrackerstaging.azurewebsites.net/api/2/vendor/ViewCharterDetails";
//NSString *const VIEW_SUBOUT_CHARTER_URL = @"https://bustrackerstaging.azurewebsites.net/api/2/vendor/viewsuboutcharters";
//NSString *const VIEW_SCHEDULED_CHARTER_URL = @"https://bustrackerstaging.azurewebsites.net/api/2/vendor/viewacceptedcharters";
//NSString *const ACCEPT_CHARTER_URL = @"https://bustrackerstaging.azurewebsites.net/api/2/vendor/accept";
//NSString *const CANCEL_CHARTER_URL = @"https://bustrackerstaging.azurewebsites.net/api/2/vendor/delete";
//NSString *const UPDATE_CHARTER_URL = @"https://bustrackerstaging.azurewebsites.net/api/2/vendor/charter/updateJob";
//NSString *const WITHDRAW_CHARTER_URL  = @"https://bustrackerstaging.azurewebsites.net/api/2/vendor/Withdraw";
//
//NSString *const GET_PROFILE_URL = @"https://bustrackerstaging.azurewebsites.net/api/2/vendor/profile";
//NSString *const GET_ONLINE_USERS_URL = @"https://bustrackerstaging.azurewebsites.net/api/2/vendor/OnlineUsers";
//NSString *const CASHOUT_URL = @"https://bustrackerstaging.azurewebsites.net/api/2/vendor/cashout";
//NSString *const EDIT_CREDIT_CARD_URL = @"https://bustrackerstaging.azurewebsites.net/api/2/vendor/profile/editCreditCard";
//NSString *const TRANSACTION_HISTORY_URL = @"https://bustrackerstaging.azurewebsites.net/api/2/vendor/ewallethistory";
//
//NSString *const GET_DRIVER_URL  = @"https://bustrackerstaging.azurewebsites.net/api/2/vendor/charter/viewDrivers";
//NSString *const UPDATE_DRIVER_URL  = @"https://bustrackerstaging.azurewebsites.net/api/2/vendor/charter/updateDriver";
//NSString *const UPDATE_POC_URL  = @"https://bustrackerstaging.azurewebsites.net/api/2/vendor/charter/updatePOC";
//
//NSString *const NEW_DISPUTE_URL  = @"https://bustrackerstaging.azurewebsites.net/api/2/vendor/charter/dispute/new";
//NSString *const DISPUTE_RESPONSE_URL  = @"https://bustrackerstaging.azurewebsites.net/api/2/vendor/charter/dispute/response";
//NSString *const VIEW_DISPUTE_LIST_URL  = @"https://bustrackerstaging.azurewebsites.net/api/2/vendor/charter/dispute/history";
//
//NSString *const CREATE_CONTRACT_URL = @"https://bustrackerstaging.azurewebsites.net/api/2/vendor/contract/createContract";
//NSString *const VIEW_ALL_CONTRACT_URL = @"https://bustrackerstaging.azurewebsites.net/api/2/vendor/contract/viewAllContracts";
//NSString *const DELETE_CONTRACT_URL = @"https://bustrackerstaging.azurewebsites.net/api/2/vendor/contract/deleteContract";
//NSString *const CALL_COUNTER_URL = @"https://bustrackerstaging.azurewebsites.net/api/2/vendor/contract/callCounter";

//
//Misc
//
NSString *const STRIPE_DEBUG_KEY = @"pk_test_Aat1gkieiiDil66wuS5frx8d";
NSString *const STRIPE_LIVE_KEY = @"pk_live_8mffjVj4nCOGPSkuiPp06VQH";

NSString *const MASTER_KEY = @"41 43 52 31 32 35 35 55 2D 4A 31 20 41 75 74 68";
NSString *const APDU1 = @"00a40000024000";
NSString *const APDU2 = @"903203000000";
