//
//  DriverApp
//
//  Created by KangJie Lim on 29/9/17.
//  Copyright © 2017 Commute-Solutions. All rights reserved.
//

#import "TransactionHistoryController.h"

@interface TransactionHistoryController ()<UITableViewDataSource, UITableViewDelegate>

@end

@implementation TransactionHistoryController
NSUserDefaults *userPrefs;
NSString *token;
NSString *role;

NSArray *transactionHistory;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[[UIView alloc] init]];
    self.navigationItem.title = @"Transaction History";
    
    UIBarButtonItem *btnBack= [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(toProfile)];
    [btnBack setTintColor:[UIColor whiteColor]];
    self.navigationItem.leftBarButtonItem = btnBack;
    
    userPrefs = [NSUserDefaults standardUserDefaults];
    token = [userPrefs stringForKey:AUTHENTICATION_TOKEN];
    role = [userPrefs stringForKey:ROLE];
    
    [self viewTransactionHistory];
}

- (void)toProfile {
    [self performSegueWithIdentifier:@"toProfile" sender:self];
}

#pragma mark - UITableView DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return transactionHistory.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"cellReuseIdentifier3";
    NSInteger rowCount = indexPath.row;
    DisputeTableRow *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
    cell.lblStatusTitle.text = @"Transaction";
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    NSDictionary *aTransaction = [transactionHistory objectAtIndex:rowCount];
    
    NSString *accessCode = [aTransaction objectForKey:@"id"];
    NSString *charterDetails = [aTransaction objectForKey:@"details"];
    NSString *transactionCost = [aTransaction objectForKey:@"amount"];
    NSString *transactionMethod = [aTransaction objectForKey:@"method"];
    NSNumber *numToBool = [aTransaction objectForKey:@"isWithdraw"];
    BOOL isWithdraw = [numToBool boolValue];
    
    cell.lblDisputeId.text = accessCode;
    cell.lblDisputeAmount.text = [NSString stringWithFormat:@"$%@", transactionCost];
    if ([charterDetails isEqualToString:@""] || charterDetails == nil) {
        cell.lblDisputeCharterDetails.text = @"Refund";
    } else {
        cell.lblDisputeCharterDetails.text = charterDetails;
        [cell.lblDisputeCharterDetails sizeToFit];
    }
    
    if (isWithdraw && [transactionMethod isEqualToString:@"eWallet"]) {
        cell.lblDisputeStatus.text = @"Deducted from wallet";
    } else if (isWithdraw && [transactionMethod isEqualToString:@"creditCard"]) {
        cell.lblDisputeStatus.text = @"Deducted from Credit Card";
    } else if (!isWithdraw && [transactionMethod isEqualToString:@"eWallet"]) {
        cell.lblDisputeStatus.text = @"Added to wallet";
    } else {
        cell.lblDisputeStatus.text = @"Refunded back to Credit Card";
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    NSInteger rowCount = indexPath.row;
    //do nothing
}

#pragma mark - Get Transaction History
- (void)viewTransactionHistory {
    __block NSInteger success = 0;
    if (token != nil && token != NULL) {
        NSURL *url = [NSURL URLWithString:TRANSACTION_HISTORY_URL];
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
                transactionHistory = [dataResponse objectForKey:@"history"];
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
                                          [userPrefs setValue:nil forKey:AUTHENTICATION_TOKEN];
                                          [userPrefs setValue:nil forKey:LAST_UPDATED_TIME];
                                          [userPrefs synchronize];
                                          [self performSegueWithIdentifier:@"reset2" sender:self];
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


@end
