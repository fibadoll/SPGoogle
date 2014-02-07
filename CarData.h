//
//  CarData.h
//  SmartPark
//
//  Created by Guannan Zhang on 12-10-12.
//  Copyright (c) 2012年 Guannan Zhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface CarData : NSManagedObject

@property (nonatomic, retain) NSNumber * car_id;
@property (nonatomic, retain) NSString * license;
@property (nonatomic, retain) NSNumber * status;

@end
