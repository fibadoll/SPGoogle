//
//  TransactionViewController.h
//  SmartPark
//
//  Created by Guannan Zhang on 11/3/12.
//  Copyright (c) 2012 Guannan Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TransactionViewController : UITableViewController
@property (nonatomic, strong) NSArray* transactions;
@property (nonatomic, assign) NSInteger userID;
@property (nonatomic, strong) NSManagedObjectContext* objectContext;

@end
