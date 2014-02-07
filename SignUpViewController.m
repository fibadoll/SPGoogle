//
//  SignUpViewController.m
//  SmartPark
//
//  Created by Guannan Zhang on 10/29/12.
//  Copyright (c) 2012 Guannan Zhang. All rights reserved.
//

#import "SignUpViewController.h"
#import "SBJson.h"
#import "SmartParkAppDelegate.h"
#import "UserData.h"
#import "CarData.h"
@interface SignUpViewController ()

@end

@implementation SignUpViewController

@synthesize nameField;
@synthesize emailField;
@synthesize passwordField;
@synthesize confirmPasswordField;
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
    [self setNameField:nil];
    [self setEmailField:nil];
    [self setPasswordField:nil];
    [self setConfirmPasswordField:nil];
    [self setMsgLabel:nil];
    [super viewDidUnload];
}
- (IBAction)signUp:(id)sender {
    [nameField resignFirstResponder];
    [emailField resignFirstResponder];
    [passwordField resignFirstResponder];
    [confirmPasswordField resignFirstResponder];
    
    NSString* name = nameField.text;
    NSString* email = emailField.text;
    NSString* password = passwordField.text;
    NSString* confirmPassword = confirmPasswordField.text;
    
    if (![password isEqualToString:confirmPassword]) {
        msgLabel.text = @"Inconsistent Passwords.";
        return;
    }
    
    NSArray* arr = [self sendSignUpMessageToServer:name withEmail:email withPassword:password];
    
    NSLog(@"%@", arr);
    
    NSString* returnMsg = [arr objectAtIndex:0];
    NSInteger user_id;
    if( returnMsg.intValue!=0 ){
        user_id = returnMsg.intValue;
        //NSLog(@"new user %d", user_id);
        [self storeInCoreData:arr];
        msgLabel.text = @"";
        [self performSegueWithIdentifier:@"signedUp" sender:sender];
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
        [objectContext deleteObject:user];
    }
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
    NSEntityDescription* desc = [NSEntityDescription entityForName:@"CarData" inManagedObjectContext:objectContext];
    [request setEntity:desc];
    NSArray* cars = [objectContext executeFetchRequest:request error:&error];
    
    for (CarData* car in cars) {
        [objectContext deleteObject:car];
    }
    
    NSNumber* user_id = [NSNumber numberWithInt:[[arr objectAtIndex:0]intValue]];
    NSNumber* default_car = [NSNumber numberWithInt:-1];
    

    UserData* user = (UserData*)[NSEntityDescription
                                 insertNewObjectForEntityForName:@"UserData"
                                 inManagedObjectContext:objectContext];
    
    user.user_id  = user_id;
    user.default_car = default_car;
    [objectContext save: &error];

}

- (NSArray*) sendSignUpMessageToServer: (NSString*)name withEmail: (NSString*)email withPassword: (NSString*)password{
    NSArray *key = [NSArray arrayWithObjects:@"name", @"email", @"password", @"password_confirmation", @"paypal_id", @"default_car_id",nil];
    NSArray *object = [NSArray arrayWithObjects: name, email, password, password, @"", [NSNumber numberWithInt:-1], nil];
    NSDictionary *user = [NSDictionary dictionaryWithObjects:object forKeys:key];
    
    NSArray *keys = [NSArray arrayWithObjects:@"user", @"commit", @"utf8",nil];
    NSArray *objects = [NSArray arrayWithObjects: user, @"Post", @"✓", nil];
    NSDictionary *myData = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
    SBJsonWriter *writer = [[SBJsonWriter alloc] init];
    NSData *myJSONData = [writer dataWithObject:myData];
    
    NSURL *url = [NSURL URLWithString:@"https://rocky-scrubland-8564.herokuapp.com/users/"];
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

-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    if (textField == nameField) {
        [emailField becomeFirstResponder];
    }
    else if(textField == emailField){
        [passwordField becomeFirstResponder];
    }
    else if (textField == passwordField){
        [confirmPasswordField becomeFirstResponder];
    }
    else if (textField == confirmPasswordField){
        [self signUp:self];
    }
    return YES;

}


@end
