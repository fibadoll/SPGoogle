//
//  SignInViewController.m
//  SmartPark
//
//  Created by Guannan Zhang on 10/29/12.
//  Copyright (c) 2012 Guannan Zhang. All rights reserved.
//

#import "SignInViewController.h"
#import "SBJson.h"
#import "ParkingViewController.h"
#import "UserData.h"
#import "SmartParkAppDelegate.h"
#import "CarData.h"

@interface SignInViewController ()

@end

@implementation SignInViewController
@synthesize emailField;
@synthesize passwordField;
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

- (void)viewDidUnload {
    [self setEmailField:nil];
    [self setPasswordField:nil];
    [self setMsgLabel:nil];
    [super viewDidUnload];
}

- (IBAction)signIn:(id)sender {
    [emailField resignFirstResponder];
    [passwordField resignFirstResponder];
    
    //for test

    //[self performSegueWithIdentifier:@"signedIn" sender:sender];

    

    
    NSString* email = emailField.text;
    NSString* password = passwordField.text;
    NSArray* arr = [self sendSignInMessageToServer:email withPassword:password];
    
    NSLog(@"%@", arr);
    
    NSString* returnMsg = [arr objectAtIndex:0];
    //NSLog(@"%@",returnMsg);
    NSInteger user_id;
    if( returnMsg.intValue != 0 ){
        user_id = returnMsg.intValue;
        
        
        [self storeInCoreData: arr];
        
        msgLabel.text = @"";
        [self performSegueWithIdentifier:@"signedIn" sender:sender];
    }
    else{
        msgLabel.text = returnMsg;
    }

}

-(void) storeInCoreData: (NSArray*) arr{
    SmartParkAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *objectContext = [appDelegate managedObjectContext];
    
    
    NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription* entityDescription = [NSEntityDescription
                                              entityForName:@"UserData"
                                              inManagedObjectContext:objectContext];
    [fetchRequest setEntity:entityDescription];
    NSError* error;
    NSArray* fetchedUsers = [objectContext executeFetchRequest:fetchRequest error:&error];
    
    for (UserData* user in fetchedUsers) {
        [objectContext deleteObject: user];
    }
    
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
    NSEntityDescription* desc = [NSEntityDescription entityForName:@"CarData" inManagedObjectContext:objectContext];
    [request setEntity:desc];
    NSArray* cars = [objectContext executeFetchRequest:request error:&error];
   
    for (CarData* car in cars) {
        [objectContext deleteObject:car];
    }
    
    [objectContext save:nil];
    
    NSNumber* user_id = [NSNumber numberWithInt:[[arr objectAtIndex:0]intValue]];
    NSNumber* default_car = [NSNumber numberWithInt:[[arr objectAtIndex:1] intValue]];
    NSInteger numOfCars = [arr count]-2;
    
    UserData* user = (UserData*)[NSEntityDescription
                                 insertNewObjectForEntityForName:@"UserData"
                                 inManagedObjectContext:objectContext];
    
    user.user_id  = user_id;
    user.default_car = default_car;
    
    if (numOfCars > 0) {

        for (int i = 2; i < [arr count]; i++) {
            NSDictionary* carMap = [arr objectAtIndex:i];
            CarData* car = (CarData*) [NSEntityDescription insertNewObjectForEntityForName:@"CarData" inManagedObjectContext:objectContext];
            car.car_id = [NSNumber numberWithInt: [[carMap valueForKey:@"id"] intValue]];
            car.license = [carMap valueForKey:@"license"];
            car.status = [NSNumber numberWithBool:[[carMap valueForKey:@"status"] boolValue]];
            
            [user addOwn_carsObject:car];
            
        }
    }

    [objectContext save: &error];

    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if(textField == emailField){
        [passwordField becomeFirstResponder];
    }
    else if(textField == passwordField){
        [self signIn:self];
    }
    return YES;
}


-(NSArray*) sendSignInMessageToServer: (NSString*) email withPassword: (NSString*) password{
    
    NSArray *key = [NSArray arrayWithObjects:@"email", @"password",nil];
    NSArray *object = [NSArray arrayWithObjects: email, password, nil];
    NSDictionary *user = [NSDictionary dictionaryWithObjects:object forKeys:key];
    
    NSArray *keys = [NSArray arrayWithObjects:@"user", @"commit", @"utf8",nil];
    NSArray *objects = [NSArray arrayWithObjects: user, @"Post", @"✓", nil];
    NSDictionary *myData = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
    SBJsonWriter *writer = [[SBJsonWriter alloc] init];
    NSData *myJSONData = [writer dataWithObject:myData];
    
    NSURL *url = [NSURL URLWithString:@"https://rocky-scrubland-8564.herokuapp.com/user_signin/"];
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
    NSLog(@"xmlCheck = %@", xmlCheck);
    
    SBJsonParser* parser = [[SBJsonParser alloc] init];
    // assuming jsonString is your JSON string...
    NSArray* myarr = [parser objectWithString:xmlCheck];
    return myarr;
}


@end
