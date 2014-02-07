//
//  ReceiptViewController.h
//  SmartPark
//
//  Created by Chen Qiu on 11/11/12.
//  Copyright (c) 2012 VLIS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReceiptViewController : UIViewController
{
    IBOutlet UILabel *fee;
    IBOutlet UILabel *time;
    IBOutlet UILabel *spot;
    IBOutlet UIActivityIndicatorView *activityIndicator;
}

@property (strong, nonatomic) NSNumber *totalFee;
@property (strong, nonatomic) NSNumber *totalTime;
@property (strong, nonatomic) NSNumber *spotId;

- (IBAction)done:(id)sender;

@end
