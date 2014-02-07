//
//  LeavingViewController.h
//  SmartPark
//
//  Created by Chen Qiu on 9/30/12.
//  Copyright (c) 2012 VLIS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
@interface LeavingViewController : UIViewController <UITextFieldDelegate>
{
    NSDate *parkedTime;
    float maxParkTime;
    int priceRate;
    int timeUnit;
    NSTimer *timer;
    CLLocationCoordinate2D myParkLocation;
    NSURLConnection* connection;
    
    IBOutlet UIActivityIndicatorView *activityIndicator;
    IBOutlet UILabel *spotNumber;
    IBOutlet UILabel *maxHoursField;
    IBOutlet UILabel *amountHoursField;
    IBOutlet UILabel *amountMinutesField;
    IBOutlet UILabel *amountFeeField;
    IBOutlet UIProgressView *parkingProgressField;
}

- (IBAction)leave:(id)sender;

@property (strong, nonatomic) NSDate* parkedTime;
@property (strong, nonatomic) NSNumber* parkingId;
@property (strong, nonatomic) NSNumber* spotId;
@property (strong, nonatomic) NSNumber* carId;

- (void)updateView: (id)sender;
- (void)sendLeaveMessage;
@end
