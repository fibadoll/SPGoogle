//
//  NewCarViewController.m
//  SmartPark
//
//  Created by Guannan Zhang on 12-10-10.
//  Copyright (c) 2012 Guannan Zhang. All rights reserved.
//

#import "NewCarViewController.h"
#import "CarData.h"
#import "SBJson.h"
#import "SmartParkAppDelegate.h"
#import "UserData.h"
@interface NewCarViewController ()

@end

@implementation NewCarViewController

@synthesize numberField;
@synthesize msgLabel;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onDone:(id)sender {
    [numberField resignFirstResponder];
    SmartParkAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext*  objectContext = [appDelegate managedObjectContext];

    NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription* entityDescription = [NSEntityDescription
                                              entityForName:@"UserData"
                                              inManagedObjectContext:objectContext];
    [fetchRequest setEntity:entityDescription];
    NSError* error;
    NSArray* fetchedUsers = [objectContext executeFetchRequest:fetchRequest error:&error];

    UserData* user = [fetchedUsers objectAtIndex:0];
    
    
    NSString* number = numberField.text;
    NSDictionary* arr = [self sendNewCarMessageToServer:number userID: user.user_id];
    if (arr != nil) {
        NSLog(@"%@", arr);
        NSNumber* car_id = [arr objectForKey:@"id"];
        NSNumber* status = [arr objectForKey:@"status"];
        
        
        CarData* newCar = (CarData*)[NSEntityDescription
                                     insertNewObjectForEntityForName:@"CarData"
                                     inManagedObjectContext:objectContext];
        
        
        newCar.car_id = car_id;
        newCar.license = number;
        newCar.status = status;
        NSLog(@"%d", car_id.intValue);
        if (user.default_car.intValue == -1) {
            user.default_car = newCar.car_id;
        }

        if ([objectContext save:&error])
        {
            NSLog(@"add car success");
            
        }
        
              
        [self.navigationController popViewControllerAnimated: YES];
    }
   

}

- (NSDictionary*) sendNewCarMessageToServer: (NSString*) license userID: (NSNumber*) user_id{
    
    NSArray *key = [NSArray arrayWithObjects:@"license", @"user_id",nil];
    NSArray *object = [NSArray arrayWithObjects: license, user_id, nil];
    NSDictionary *car = [NSDictionary dictionaryWithObjects:object forKeys:key];
    
    NSArray *keys = [NSArray arrayWithObjects:@"car", @"commit", @"utf8",nil];
    NSArray *objects = [NSArray arrayWithObjects: car, @"Post", @"✓", nil];
    NSDictionary *myData = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
    SBJsonWriter *writer = [[SBJsonWriter alloc] init];
    NSData *myJSONData = [writer dataWithObject:myData];
    
    NSURL *url = [NSURL URLWithString:@"https://rocky-scrubland-8564.herokuapp.com/cars/"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:myJSONData];
    [request setValue:@"application/json" forHTTPHeaderField:@"content-type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"Smart_Park_App" forHTTPHeaderField:@"User-Agent"];
    
    NSURLResponse *response;
    NSError *error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request
                                         returningResponse:&response
                                                     error:&error];
    
    
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
    int responseStatusCode = [httpResponse statusCode];
    NSLog(@"%d", responseStatusCode);
    
    NSMutableData *xmlData = [[NSMutableData alloc] init];
    [xmlData setData:data];
    NSString *xmlCheck = [[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding];
    
    SBJsonParser* parser = [[SBJsonParser alloc] init];
    // assuming jsonString is your JSON string...
    
    if (responseStatusCode == 404) {
        NSArray* errors = [parser objectWithString:xmlCheck];
        msgLabel.text = [errors objectAtIndex:0];
        
        return nil;
        
    }
    else{
        NSDictionary *myarr = [parser objectWithString:xmlCheck];
        return myarr;
    }
    
}
- (void)viewDidUnload {
    [self setMsgLabel:nil];
    [super viewDidUnload];
}
@end
