//
//  CarsViewController.m
//  SmartPark
//
//  Created by Guannan Zhang on 12-10-8.
//  Copyright (c) 2012年 Guannan Zhang. All rights reserved.
//

#import "CarsViewController.h"
#import "CarData.h"
#import "NewCarViewController.h"
#import "SBJson.h"
#import "SmartParkAppDelegate.h"
#import "UserData.h"
@interface CarsViewController ()

@end

@implementation CarsViewController
@synthesize user_id;
@synthesize cars;
@synthesize defaultCar;
@synthesize lastIndexPath;
@synthesize objectContext;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    
    SmartParkAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    objectContext = [appDelegate managedObjectContext];
    
    [self fetchExistingCars];
    [self fetchUser];
    //NSLog(@"%d", defaultCar.intValue);
    
    [self updateIndex];
    

}

-(void) updateIndex{
    for (int i = 0; i < [cars count]; i++) {
        if ([[cars objectAtIndex:i] car_id].intValue == defaultCar.intValue) {
            lastIndexPath = [NSIndexPath indexPathForRow:i inSection:0];
            break;
        }
    }

}

- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self fetchExistingCars];
    [self fetchUser];
    [self updateIndex];
    [self updateCarStatus];
    [self.tableView reloadData];


}

-(void) updateCarStatus{
    
    NSString* urlStr = [NSString stringWithFormat:@"https://rocky-scrubland-8564.herokuapp.com/query_cars?user_id=%d", user_id.intValue];
    NSLog(@"%@", urlStr);
    NSURL *url = [NSURL URLWithString:urlStr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/json" forHTTPHeaderField:@"content-type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"Smart_Park_App" forHTTPHeaderField:@"User-Agent"];
    
    //NSURLConnection* connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    NSURLResponse* response;
    NSError* error;
    NSData *data = [NSURLConnection sendSynchronousRequest:request
                                         returningResponse:&response
                                                     error:&error];
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
    int responseStatusCode = [httpResponse statusCode];
    NSLog(@"%d", responseStatusCode);
    NSMutableData *xmlData = [[NSMutableData alloc] init];
    [xmlData setData:data];
    NSString *xmlCheck = [[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding];
    //NSLog(@"xmlCheck = %@", xmlCheck);
    SBJsonParser* parser = [[SBJsonParser alloc] init];
    NSArray* myarr = [parser objectWithString:xmlCheck];
    NSLog(@"%@", myarr);
    
    NSMutableArray* ids = [[NSMutableArray alloc]init];
    NSMutableArray* statuss = [[NSMutableArray alloc]init];
    
    for (NSDictionary* dict in myarr) {
        
        [ids addObject: [NSString stringWithFormat:@"%d",[[dict valueForKey:@"id"] intValue] ]];
        [statuss addObject:[dict valueForKey:@"status"]];
    }
    
    
    NSDictionary* carStatus = [NSDictionary dictionaryWithObjects:statuss forKeys:ids];
    //NSLog(@"%@", carStatus);
    for (CarData* car in cars) {
        car.status =[carStatus valueForKey: [NSString stringWithFormat:@"%d", [car.car_id intValue]]];

    }
    
    
    [objectContext save:nil];
    
}


- (void) fetchExistingCars
{
    NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription* entityDescription = [NSEntityDescription
                                              entityForName:@"CarData"
                                              inManagedObjectContext:objectContext];
    [fetchRequest setEntity:entityDescription];
    NSError* error;
    NSArray* fetchedCars = [objectContext executeFetchRequest:fetchRequest error:&error];
    cars = [fetchedCars mutableCopy];
}

-(void) fetchUser{
    
    NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription* entityDescription = [NSEntityDescription
                                              entityForName:@"UserData"
                                              inManagedObjectContext:objectContext];
    [fetchRequest setEntity:entityDescription];
    NSError* error;
    NSArray* fetchedUsers = [objectContext executeFetchRequest:fetchRequest error:&error];
    
    UserData* user = [fetchedUsers objectAtIndex:0];
    user_id = user.user_id;
    defaultCar = user.default_car;
    NSLog(@"%d", defaultCar.intValue);
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    // Return the number of rows in the section.
    return [cars count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    if (cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    
    CarData* car = (CarData*) [cars objectAtIndex:indexPath.row];
    cell.textLabel.text = car.license;
    
    if ([car.status intValue] == 0) {
        cell.detailTextLabel.text = @"Unparked";
    }
    else{
        cell.detailTextLabel.text = @"Parked";
    }
    
    cell.accessoryType = (indexPath.row == lastIndexPath.row)?UITableViewCellAccessoryCheckmark: UITableViewCellAccessoryNone;
    
    return cell;
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        CarData* car = [cars objectAtIndex:indexPath.row];
        if(car.status.intValue == 0 ){
            NSInteger car_id = car.car_id.intValue;
            NSInteger newDefaultCar = [self sendDeleteCarToServer: car_id];
            
            [objectContext deleteObject: car];
            [objectContext save:nil];
            [cars removeObjectAtIndex: indexPath.row];

            if (defaultCar.integerValue != newDefaultCar) {
                defaultCar = [NSNumber numberWithInteger:newDefaultCar];
                [self updateUser:newDefaultCar];
            }
            
            [self updateIndex];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            NSLog(@"%d, %d", defaultCar.integerValue, lastIndexPath.row);
            [tableView reloadData];
        }
        
    }
    if ([cars count] == 0) {
        [self sendNewDefaultCarToServer:[NSString stringWithFormat:@"%d", -1]];
        defaultCar = [NSNumber numberWithInt:-1];
    }

} 
-(void) updateUser: (NSInteger) newDefaultCar{
    
    NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription* entityDescription = [NSEntityDescription
                                              entityForName:@"UserData"
                                              inManagedObjectContext:objectContext];
    [fetchRequest setEntity:entityDescription];
    NSError* error;
    NSArray* fetchedUsers = [objectContext executeFetchRequest:fetchRequest error:&error];
    
    UserData* user = [fetchedUsers objectAtIndex:0];
    user.default_car = [NSNumber numberWithInteger:newDefaultCar];
    [objectContext save:nil];
}

-(NSInteger) sendDeleteCarToServer: (NSInteger)car_id{
    NSString* urlStr  = [NSString stringWithFormat:@"https://rocky-scrubland-8564.herokuapp.com/cars/%d", car_id ];
        
    NSURL *url = [NSURL URLWithString: urlStr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    [request setHTTPMethod:@"DELETE"];
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
    NSArray *myarr = [parser objectWithString:xmlCheck];
    return [[myarr objectAtIndex:0] integerValue];
    
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     DetailViewController *detailViewController = [[DetailViewController alloc] initWithNibName:@"Nib name" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
    
    int newRow = indexPath.row;
    int oldRow = lastIndexPath.row;
    

    if( newRow != oldRow){
        
        CarData* newDefaultCar = [cars objectAtIndex:newRow];
        NSNumber* newDefaultId = newDefaultCar.car_id;
        [self sendNewDefaultCarToServer: [NSString stringWithFormat:@"%d", newDefaultId.intValue]];
        
        
        UITableViewCell* newCell = [tableView cellForRowAtIndexPath:indexPath];
        newCell.accessoryType = UITableViewCellAccessoryCheckmark;
        UITableViewCell* oldCell = [tableView cellForRowAtIndexPath:lastIndexPath];
        oldCell.accessoryType = UITableViewCellAccessoryNone;
        lastIndexPath = indexPath;
        
        defaultCar = [[cars objectAtIndex:newRow] car_id];
        
        NSFetchRequest* request = [[NSFetchRequest alloc] init];
        NSEntityDescription* desc = [NSEntityDescription entityForName:@"UserData" inManagedObjectContext:objectContext];
        [request setEntity:desc];
        NSError* error;
        NSArray* users = [objectContext executeFetchRequest:request error:&error];
        UserData* thisUser = [users objectAtIndex:0];
        thisUser.default_car = defaultCar;
        [objectContext save:nil];
               
    }
    

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


-(void) sendNewDefaultCarToServer: (NSString*) newDefaultId{
    
    NSArray *key = [NSArray arrayWithObjects: @"default_car_id", nil];
    NSArray *object = [NSArray arrayWithObjects: newDefaultId, nil];
    NSDictionary *car = [NSDictionary dictionaryWithObjects:object forKeys:key];
    
    NSArray *keys = [NSArray arrayWithObjects:@"car", @"commit", @"utf8",nil];
    NSArray *objects = [NSArray arrayWithObjects: car, @"Put", @"✓", nil];
    NSDictionary *myData = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
    SBJsonWriter *writer = [[SBJsonWriter alloc] init];
    NSData *myJSONData = [writer dataWithObject:myData];
    
    NSString* urlStr = [NSString stringWithFormat:@"https://rocky-scrubland-8564.herokuapp.com/users/%d", user_id.intValue];
    NSLog(@"%@", urlStr);
    NSURL *url = [NSURL URLWithString:urlStr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    [request setHTTPMethod:@"PUT"];
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
    
//    SBJsonParser* parser = [[SBJsonParser alloc] init];
//    NSDictionary *myarr = [parser objectWithString:xmlCheck];
//    return myarr;

}


@end
