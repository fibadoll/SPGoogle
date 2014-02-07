//
//  main.m
//  SmartPark
//
//  Created by Chen Qiu on 9/26/12.
//  Copyright (c) 2012 VLIS. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SmartParkAppDelegate.h"

int main(int argc, char *argv[])
{
    int retVal = 0;
    @autoreleasepool {
        NSString *classString = NSStringFromClass([SmartParkAppDelegate class]);
        @try {
            retVal = UIApplicationMain(argc, argv, nil, classString);
        }
        @catch (NSException *exception) {
            NSLog(@"Exception - %@",[exception description]);
            exit(EXIT_FAILURE);
        }
    }
    return retVal;
}
