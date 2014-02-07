//
//  PaymentData.h
//  SmartPark
//
//  Created by Guannan Zhang on 11/14/12.
//  Copyright (c) 2012 Guannan Zhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface PaymentData : NSManagedObject

@property (nonatomic, retain) NSNumber * user_id;
@property (nonatomic, retain) NSString * card_number;
@property (nonatomic, retain) NSString * cvv;
@property (nonatomic, retain) NSString * first_name;
@property (nonatomic, retain) NSString * last_name;
@property (nonatomic, retain) NSString * address_1;
@property (nonatomic, retain) NSString * address_2;
@property (nonatomic, retain) NSString * city;
@property (nonatomic, retain) NSString * state;
@property (nonatomic, retain) NSString * country;
@property (nonatomic, retain) NSString * zip_code;
@property (nonatomic, retain) NSNumber * expire_year;
@property (nonatomic, retain) NSNumber * expire_month;

@end
