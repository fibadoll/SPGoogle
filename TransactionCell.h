//
//  TransactionCell.h
//  SmartPark
//
//  Created by Guannan Zhang on 11/3/12.
//  Copyright (c) 2012 Guannan Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TransactionCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *dateLabel;
@property (strong, nonatomic) IBOutlet UILabel *parkingLotLabel;
@property (strong, nonatomic) IBOutlet UILabel *carPlateLabel;
@property (strong, nonatomic) IBOutlet UILabel *timeLabel;
@property (strong, nonatomic) IBOutlet UILabel *expenseLabel;

@end
