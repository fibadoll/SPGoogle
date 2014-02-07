//
//  SPMapPoint.m
//  SmartPark
//
//  Created by Chen Qiu on 10/25/12.
//  Copyright (c) 2012 VLIS. All rights reserved.
//

#import "SPMapPoint.h"

@implementation SPMapPoint
@synthesize coordinate, title;

- (id)initWithCoordinate:(CLLocationCoordinate2D)c title:(NSString *)t
{
    self = [super init];
    if (self) {
        coordinate = c;
        [self setTitle:t];
    }
    return self;
}

- (id)init
{
    return [self initWithCoordinate:CLLocationCoordinate2DMake(43.07, -89.32)
                              title:@"Hometown"];
}
@end
