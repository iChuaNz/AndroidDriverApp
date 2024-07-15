//
//  DriverApp
//
//  Created by KangJie Lim on 26/9/17.
//  Copyright © 2017 Commute-Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DisputeTableRow : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lblDisputeId;
@property (weak, nonatomic) IBOutlet UILabel *lblDisputeAmount;
@property (weak, nonatomic) IBOutlet UILabel *lblDisputeCharterDetails;
@property (weak, nonatomic) IBOutlet UILabel *lblDisputeStatus;
@property (weak, nonatomic) IBOutlet UILabel *lblStatusTitle;

@end
