//
//  LeavingViewController.m
//  SmartPark
//
//  Created by Chen Qiu on 9/30/12.
//  Copyright (c) 2012 VLIS. All rights reserved.
//

#import "ParkingViewController.h"
#import "LeavingViewController.h"
#import "MapViewController.h"
#import "ReceiptViewController.h"
#import "SBJson.h"

#define SECONDS_PER_MINUTE 60
#define SECONDS_PER_HOUR 3600

@implementation LeavingViewController

@synthesize parkedTime;
@synthesize parkingId;
@synthesize carId;
@synthesize spotId;

- (IBAction)leave:(id)sender
{
    [self sendLeaveMessage];
    [self performSegueWithIdentifier:@"Leave" sender:sender];
    [activityIndicator startAnimating];
}

- (void)sendLeaveMessage
{
    
    [activityIndicator setHidden:NO];
    [activityIndicator startAnimating];
    NSString *baseUrl = @"https://rocky-scrubland-8564.herokuapp.com/parkings/";
    NSURL *url = [NSURL URLWithString:[baseUrl stringByAppendingString:[self.parkingId stringValue]]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    [request setHTTPMethod:@"DELETE"];
    [request setValue:@"Smart_Park_App" forHTTPHeaderField:@"User-Agent"];
    
    // Create a connection that will exchange this request for data from the URL
    connection = [[NSURLConnection alloc] initWithRequest:request
                                                       delegate:self];
}

- (void)connection:(NSURLConnection*)connection
didReceiveResponse:(NSURLResponse*)response {
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
    int responseStatusCode = [httpResponse statusCode];
    NSLog(@"map view connection status: %d", responseStatusCode);
    [activityIndicator stopAnimating];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.hidesBackButton = YES;
	// Do any additional setup after loading the view, typically from a nib.
    
    NSString *spotBaseUrl = @"https://rocky-scrubland-8564.herokuapp.com/parkingspots/";
    
    NSLog(@"spotId:%@",spotId);
    NSString *spot = [[self.spotId stringValue] stringByAppendingString:@".json"];
    NSLog(@"spot:%@",spot);
    NSURL *spotUrl = [NSURL URLWithString:[spotBaseUrl stringByAppendingString:spot]];
    
    NSMutableURLRequest *spotReq = [NSMutableURLRequest requestWithURL:spotUrl];
    [spotReq setHTTPMethod:@"GET"];
    [spotReq setValue:@"Smart_Park_App" forHTTPHeaderField:@"User-Agent"];
    
    NSURLResponse* response;
    NSError* error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:spotReq
                          returningResponse:&response
                                      error:&error];
    
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
    int responseStatusCode = [httpResponse statusCode];
    
    NSString *xmlCheck = [[NSString alloc] initWithData:data
                                               encoding:NSUTF8StringEncoding];
    
    SBJsonParser* parser = [[SBJsonParser alloc] init];
    NSDictionary *myarr = [parser objectWithString:xmlCheck];
    
    double latitude = [[myarr objectForKey:@"latitude"] doubleValue];
    double longitude = [[myarr objectForKey:@"longitude"] doubleValue];
    
    myParkLocation = CLLocationCoordinate2DMake(latitude, longitude);
    
    // spot number
    [spotNumber setText:[[myarr objectForKey:@"id"] stringValue]];
    
    // max parking time
    maxParkTime = [[myarr objectForKey:@"maxparktime"] floatValue];
    int hours = maxParkTime / SECONDS_PER_HOUR;
    [maxHoursField setText:[[[NSNumber numberWithInt:hours] stringValue] stringByAppendingString:@" Hours Maximum" ] ];
    
    // count parking time
    NSDate *now = [NSDate date];
    NSTimeInterval time = [now timeIntervalSinceDate:self.parkedTime];
    int parkingTime = (int) time;
    int parkedHour = (int) time / SECONDS_PER_HOUR;
    int parkedMinutes = (int) (time - parkedHour * SECONDS_PER_HOUR) / SECONDS_PER_MINUTE;
    [amountHoursField setText:[[NSNumber numberWithInt: parkedHour] stringValue]];
    [amountMinutesField setText:[[NSNumber numberWithInt: parkedMinutes] stringValue]];
    
    [parkingProgressField setProgress: time / maxParkTime];
    
    // calculate fee due
    priceRate = [[myarr objectForKey:@"pricerate"] intValue];
    timeUnit = [[myarr objectForKey:@"timeunit"] intValue];
    int parkUnit = (int) parkingTime/ timeUnit + 1;
    double price = (double) parkUnit * priceRate / 100;
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [amountFeeField setText:[formatter stringFromNumber:[NSNumber numberWithDouble:price]]];
    
    NSLog(@"activity%@", activityIndicator);
}

- (void)updateView: (id)sender
{
    NSDate *now = [NSDate date];
    NSTimeInterval time = [now timeIntervalSinceDate:self.parkedTime];
    int parkingTime = (int) time;
    int parkedHour = (int) time / SECONDS_PER_HOUR;
    int parkedMinutes = (int) (time - parkedHour * SECONDS_PER_HOUR) / SECONDS_PER_MINUTE;
    [amountHoursField setText:[[NSNumber numberWithInt: parkedHour] stringValue]];
    [amountMinutesField setText:[[NSNumber numberWithInt: parkedMinutes] stringValue]];
    
    [parkingProgressField setProgress: time / maxParkTime];
    // When parking time exceed max parking hour, force to leave
    if (time >= maxParkTime) {
        [self sendLeaveMessage];
        [self performSegueWithIdentifier:@"Leave" sender:sender];
    }
    // calculate fee due
    int parkUnit = (int) parkingTime/ timeUnit + 1;
    NSLog(@"parking unit: %d", parkUnit);
    double price = (double) parkUnit * priceRate / 100;
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [amountFeeField setText:[formatter stringFromNumber:[NSNumber numberWithDouble:price]]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // set up timer
    timer = [NSTimer scheduledTimerWithTimeInterval:30.0
                                             target:self
                                           selector:@selector(updateView:)
                                           userInfo:nil
                                            repeats:YES];
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [timer invalidate];
    timer = nil;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"MyPark"]) {
        MapViewController *viewController = segue.destinationViewController;
        [viewController setMyParkLocation:myParkLocation];
    } else if ([[segue identifier] isEqualToString:@"Leave"]) {
        ReceiptViewController *viewController = segue.destinationViewController;
        [viewController setSpotId:spotId];
        NSDate *now = [NSDate date];
        NSTimeInterval time = [now timeIntervalSinceDate:self.parkedTime];
        [viewController setTotalTime:[NSNumber numberWithDouble:time]];
        int parkUnit = (int) time/ timeUnit + 1;
        double price = (double) parkUnit * priceRate / 100;
        [viewController setTotalFee:[NSNumber numberWithDouble:price]];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
