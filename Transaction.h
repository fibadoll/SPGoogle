//
//  Transaction.h
//  SmartPark
//
//  Created by Guannan Zhang on 12-10-7.
//  Copyright (c) 2012年 Guannan Zhang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Transaction : NSObject

@property (strong, nonatomic) NSString* carPlate;
@property (strong, nonatomic) NSString* parkingLot;
@property (strong, nonatomic) NSString* date;
@property (assign, nonatomic) NSInteger time;
@property (strong, nonatomic) NSNumber* expense;


@end
