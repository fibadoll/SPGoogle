//
//  TransactionCell.m
//  SmartPark
//
//  Created by Guannan Zhang on 11/3/12.
//  Copyright (c) 2012 Guannan Zhang. All rights reserved.
//

#import "TransactionCell.h"

@implementation TransactionCell

@synthesize dateLabel;
@synthesize parkingLotLabel;
@synthesize carPlateLabel;
@synthesize timeLabel;
@synthesize expenseLabel;
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}


@end
