//
//  DriverApp
//
//  Created by KangJie Lim on 12/9/17.
//  Copyright © 2017 Commute-Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TableRow : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *lblDate;
@property (weak, nonatomic) IBOutlet UILabel *lblTime;
@property (weak, nonatomic) IBOutlet UILabel *lblCost;
@property (weak, nonatomic) IBOutlet UILabel *lblStartName;
@property (weak, nonatomic) IBOutlet UILabel *lblEndName;
@property (weak, nonatomic) IBOutlet UILabel *lblBusType;
@property (weak, nonatomic) IBOutlet UILabel *lblExpiryDate;
@property (weak, nonatomic) IBOutlet UIImageView *ivIsOwnCharterIdentifier;
@property (weak, nonatomic) IBOutlet UIImageView *ivIsAcceptedIdentifier;
@property (weak, nonatomic) IBOutlet UIImageView *ivIsCompletedIdentifier;

@end
