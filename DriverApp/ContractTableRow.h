//
//  DriverApp
//
//  Created by KangJie Lim on 12/3/18.
//  Copyright © 2018 Commute-Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContractTableRow : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *ivIsOwnContractIdentifier;
@property (weak, nonatomic) IBOutlet UILabel *lblDate;
@property (weak, nonatomic) IBOutlet UILabel *lblTime;
@property (weak, nonatomic) IBOutlet UILabel *lblCost;
@property (weak, nonatomic) IBOutlet UILabel *lblBusType;
@property (weak, nonatomic) IBOutlet UILabel *lblPickupName;
@property (weak, nonatomic) IBOutlet UILabel *lblDropOffName;

@end
