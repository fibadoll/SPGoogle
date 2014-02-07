//
//  UserData.h
//  SmartPark
//
//  Created by Guannan Zhang on 11/14/12.
//  Copyright (c) 2012 Guannan Zhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CarData;

@interface UserData : NSManagedObject

@property (nonatomic, retain) NSNumber * default_car;
@property (nonatomic, retain) NSNumber * parking_id;
@property (nonatomic, retain) NSDate * parking_time;
@property (nonatomic, retain) NSNumber * spot_id;
@property (nonatomic, retain) NSNumber * user_id;
@property (nonatomic, retain) NSSet *own_cars;
@end

@interface UserData (CoreDataGeneratedAccessors)

- (void)addOwn_carsObject:(CarData *)value;
- (void)removeOwn_carsObject:(CarData *)value;
- (void)addOwn_cars:(NSSet *)values;
- (void)removeOwn_cars:(NSSet *)values;

@end
