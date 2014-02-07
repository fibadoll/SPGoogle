//
//  ReceiptViewController.m
//  SmartPark
//
//  Created by Chen Qiu on 11/11/12.
//  Copyright (c) 2012 VLIS. All rights reserved.
//

#import "ReceiptViewController.h"
#define SECONDS_PER_MINUTE 60
#define SECONDS_PER_HOUR 3600

@implementation ReceiptViewController
@synthesize totalFee;
@synthesize spotId;
@synthesize totalTime;

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationItem.hidesBackButton = YES;
    NSLog(@"spot:%@", [self spotId]);
    [spot setText:[NSString stringWithFormat:@"%@",self.spotId]];
    
    double parkTime = [self.totalTime doubleValue];
    int parkedHour = (int) parkTime / SECONDS_PER_HOUR;
    int parkedMinutes = (int) (parkTime - parkedHour * SECONDS_PER_HOUR) / SECONDS_PER_MINUTE;
    [time setText:[NSString stringWithFormat:@"%.2d:%.2d", parkedHour,parkedMinutes]];
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [fee setText:[formatter stringFromNumber:self.totalFee]];
}

- (IBAction)done:(id)sender
{
    [activityIndicator startAnimating];
    [self performSegueWithIdentifier:@"Done" sender:sender];
}

@end
