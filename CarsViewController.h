//
//  CarsViewController.h
//  SmartPark
//
//  Created by Guannan Zhang on 12-10-8.
//  Copyright (c) 2012年 Guannan Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CarsViewController : UITableViewController
@property (strong, nonatomic) NSNumber* user_id;
@property (strong, nonatomic) NSMutableArray* cars;
@property (strong, nonatomic) NSNumber* defaultCar;
@property (strong, nonatomic) NSIndexPath *lastIndexPath;

@property (nonatomic, strong) NSManagedObjectContext* objectContext;

@end
