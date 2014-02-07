//
//  SmartParkFirstViewController.m
//  SmartPark
//
//  Created by Chen Qiu on 9/26/12.
//  Copyright (c) 2012 VLIS. All rights reserved.
//

#import "ParkingViewController.h"
#import "LeavingViewController.h"
#import "SBJson.h"
#import "SmartParkAppDelegate.h"
#import "PaymentViewController.h"

@implementation ParkingViewController
@synthesize objectContext;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    xmlData = [[NSMutableData alloc] init];
    spotNumber = [[NSMutableArray alloc] initWithObjects:@"0", @"0", @"0", @"0", nil];
    parkingId = [[NSNumber alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textFieldDidChanged:)
                                                 name:UITextFieldTextDidChangeNotification
                                               object:digit1];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textFieldDidChanged:)
                                                 name:UITextFieldTextDidChangeNotification
                                               object:digit2];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textFieldDidChanged:)
                                                 name:UITextFieldTextDidChangeNotification
                                               object:digit3];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textFieldDidChanged:)
                                                 name:UITextFieldTextDidChangeNotification
                                               object:digit4];
    
    return self;
}


// This method will be called several times as the data arrives
- (void)connection:(NSURLConnection *)conn
    didReceiveData:(NSData *)data
{
    
    [xmlData setData:data];
    NSString *xmlCheck = [[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding];
    //NSLog(@"xmlCheck = %@", xmlCheck);
    
    SBJsonParser* parser = [[SBJsonParser alloc] init];
    // assuming jsonString is your JSON string...
    NSArray *myarr = [parser objectWithString:xmlCheck];
    NSLog(@"park view received data: %@", myarr);
    
}


- (void)textFieldDidChanged:(NSNotification *)notification
{
    UITextField* textField = [notification object];
    if ([textField text].length == 1) {
        if (textField == digit1) {
            [digit2 becomeFirstResponder];
        } else if (textField == digit2) {
            [digit3 becomeFirstResponder];
        } else if (textField == digit3) {
            [digit4 becomeFirstResponder];
        } else if (textField == digit4) {
            [textField resignFirstResponder];
        }
    }
}

- (void)connection:(NSURLConnection*)connection
didReceiveResponse:(NSURLResponse*)response {
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
    int responseStatusCode = [httpResponse statusCode];
    NSLog(@"park view connection status: %d", responseStatusCode);
}

- (IBAction)scan:(id)sender {
    // If our device has a camera, we want to take a picture, otherwise, we
    // just pick from photo library
    if ([ZBarReaderController
         isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        ZBarReaderViewController *reader = [ZBarReaderViewController new];
        reader.readerDelegate = self;

        reader.supportedOrientationsMask = ZBarOrientationMaskAll;

        ZBarImageScanner *scanner = reader.scanner;
        // TODO: (optional) additional reader configuration here
        
        // EXAMPLE: disable rarely used I2/5 to improve performance
        [scanner setSymbology: ZBAR_I25
                       config: ZBAR_CFG_ENABLE
                           to: 0];
        
        // present and release the controller
        [self presentViewController: reader animated: YES completion:nil];
        
    } else {
        ZBarReaderController *reader = [ZBarReaderController new];
        [reader setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        [reader.scanner setSymbology: ZBAR_I25
                              config: ZBAR_CFG_ENABLE
                                  to: 0];
        
        reader.readerDelegate = self;
        [reader showsHelpOnFail];
        [self presentViewController:reader animated:YES completion:nil];
        
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    id<NSFastEnumeration> results = [info objectForKey: ZBarReaderControllerResults];
    NSLog(@"%@",results);
    // Get picked image from info dictionary
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    ZBarSymbol *symbol = nil;
    for(symbol in results)
        // EXAMPLE: just grab the first barcode
        break;

    NSString *data = symbol.data;
    int spotData = [data intValue];
    
    NSString *tmp = [NSString stringWithFormat:@"%d",spotData/1000];
    [digit1 setText:tmp];
    [spotNumber replaceObjectAtIndex:0 withObject:tmp];
    spotData = spotData%1000;
    
    tmp = [NSString stringWithFormat:@"%d",spotData/100];
    [digit2 setText:tmp];
    [spotNumber replaceObjectAtIndex:1 withObject:tmp];
    spotData = spotData%100;
    
    tmp = [NSString stringWithFormat:@"%d",spotData/10];
    [digit3 setText:tmp];
    [spotNumber replaceObjectAtIndex:2 withObject:tmp];
    spotData = spotData%10;
     
    tmp = [NSString stringWithFormat:@"%d",spotData];
    [digit4 setText:tmp];
    [spotNumber replaceObjectAtIndex:3 withObject:tmp];
    
    // Put that image onto the screen in our image view
    [camera setImage:image forState:0];
    
    //setImage:image];
    // Take image picker off the screen -
    // you must call this dismiss method
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)park:(id)sender
{
    // Spot id for "GET"
    int spot = 0;
    for (int i = 0, j = 1000; i <= 3; i++, j /= 10) {
        int s = [[spotNumber objectAtIndex:i] intValue];
        spot += s * j;
    }
    
    NSLog(@"spot number !!!!%d", spot);
    
    NSLog(@"user: %@", user);
    
    spotId = [[NSNumber alloc] initWithInt:spot];
    NSLog(@"spot Id: %@", spotId);
    
    NSString *urlString = [NSString stringWithFormat:@"https://rocky-scrubland-8564.herokuapp.com/query_valid?car_id=%@&parkingspot_id=%@", carId, spotId];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/json" forHTTPHeaderField:@"content-type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"Smart_Park_App" forHTTPHeaderField:@"User-Agent"];
    
    NSURLResponse *response;
    NSError* error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request
                                         returningResponse:&response
                                                     error:&error];
    
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
    int responseStatusCode = [httpResponse statusCode];
    NSLog(@"response status:%d", responseStatusCode);
    
    [xmlData setData:data];
    NSString *xmlCheck = [[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding];
    //NSLog(@"xmlCheck = %@", xmlCheck);
    
    SBJsonParser* parser = [[SBJsonParser alloc] init];
    // assuming jsonString is your JSON string...
    

    switch (responseStatusCode) {
        case 404: {
            NSArray *myarr = [parser objectWithString:xmlCheck];
            UIAlertView *cannotFindAlert = [[UIAlertView alloc]
                                            initWithTitle:@"Spot Unavailable"
                                            message:[myarr objectAtIndex:0]
                                            delegate:nil
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles:nil];
            
            [cannotFindAlert show];
            return;
            break;
        }
        case 500: {
            NSLog(@"There is something wrong with server.");
            break;
        }
        default:{
            NSLog(@"Park!!!!!!!");
            [self performSegueWithIdentifier:@"Park" sender:sender];
            break;
        }
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"AlreadyPark"]) {
        LeavingViewController *viewController = segue.destinationViewController;
        [viewController setParkingId:parkingId];
        [viewController setSpotId:spotId];
        [viewController setCarId:carId];
        [viewController setParkedTime:parkedTime];
    } else {
        PaymentViewController *viewController = segue.destinationViewController;
        [viewController setSpotId:spotId];
        [viewController setCarId:carId];
        [viewController setFromParking:YES];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationItem.hidesBackButton = YES;
    
    SmartParkAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    objectContext = [appDelegate managedObjectContext];
    
    
    NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription* entityDescription = [NSEntityDescription
                                              entityForName:@"UserData"
                                              inManagedObjectContext:objectContext];
    [fetchRequest setEntity:entityDescription];
    NSError* error;
    NSArray* fetchedUsers = [objectContext executeFetchRequest:fetchRequest error:&error];
    
    NSLog(@"%@", fetchedUsers);
    user = [fetchedUsers objectAtIndex:0];
    NSLog(@"user:%@", user);
    
    carId = [user default_car];
    NSLog(@"carId: %@", carId);
    
    
    NSString *urlString = [NSString stringWithFormat:@"https://rocky-scrubland-8564.herokuapp.com/query_car_status?car_id=%@", carId];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/json" forHTTPHeaderField:@"content-type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"Smart_Park_App" forHTTPHeaderField:@"User-Agent"];
    
    NSURLResponse *response;
    error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request
                                         returningResponse:&response
                                                     error:&error];
    
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
    int responseStatusCode = [httpResponse statusCode];
    NSLog(@"%d", responseStatusCode);
    if (responseStatusCode == 200) {
        [xmlData setData:data];
        NSString *xmlCheck = [[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding];
        //NSLog(@"xmlCheck = %@", xmlCheck);
        
        SBJsonParser* parser = [[SBJsonParser alloc] init];
        NSDictionary *myarr = [parser objectWithString:xmlCheck];
        NSLog(@"$%@", myarr);
        parkingId = [myarr objectForKey:@"id"];
        NSLog(@"parkingId%@", parkingId);
        NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
        parkedTime = [dateFormatter dateFromString:[myarr objectForKey:@"starttime"]];
        NSLog(@"starttime%@",parkedTime);
        spotId = [[NSNumber alloc] initWithInt:[[myarr objectForKey:@"parkingspot_id"] intValue]];
        [self performSegueWithIdentifier:@"AlreadyPark" sender:self];
    }

}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == digit1) {
        [spotNumber replaceObjectAtIndex:0 withObject:[textField text]];
        //[digit2 becomeFirstResponder];
    } else if (textField == digit2) {
        [spotNumber replaceObjectAtIndex:1 withObject:[textField text]];
        //[digit3 becomeFirstResponder];
    } else if (textField == digit3) {
        [spotNumber replaceObjectAtIndex:2 withObject:[textField text]];
        //[digit4 becomeFirstResponder];
    } else if (textField == digit4) {
        [spotNumber replaceObjectAtIndex:3 withObject:[textField text]];
        //[textField resignFirstResponder];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    // Validate the number
    
    if (textField == digit1) {
        [digit2 becomeFirstResponder];
    } else if (textField == digit2) {
        [digit3 becomeFirstResponder];
    } else if (textField == digit3) {
        [digit4 becomeFirstResponder];
    } else if (textField == digit4) {
        [textField resignFirstResponder];
    }
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range
                                                                  withString:string];
    if (newString.length <= 1) {
        NSLog(@"Length 1");
        return YES;
    } else {
        return NO;
    }
}

- (IBAction)backgroundTapped:(id)sender
{
    [[self view] endEditing:YES];
}


@end
