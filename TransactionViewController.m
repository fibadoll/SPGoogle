//
//  TransactionViewController.m
//  SmartPark
//
//  Created by Guannan Zhang on 11/3/12.
//  Copyright (c) 2012 Guannan Zhang. All rights reserved.
//

#import "TransactionViewController.h"
#import "Transaction.h"
#import "TransactionCell.h"
#import "SmartParkAppDelegate.h"
#import "UserData.h"
#import "SBJson.h"

@interface TransactionViewController ()

@end

@implementation TransactionViewController

@synthesize transactions;
@synthesize userID;
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
    SmartParkAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    objectContext = [appDelegate managedObjectContext];
    
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription* entityDescription = [NSEntityDescription
                                              entityForName:@"UserData"
                                              inManagedObjectContext:objectContext];
    [fetchRequest setEntity:entityDescription];
    NSError* error;
    NSArray* fetchedUsers = [objectContext executeFetchRequest:fetchRequest error:&error];
    
    UserData* user = [fetchedUsers objectAtIndex:0];
    transactions = [self fetchTransactionsFromServer: user.user_id.intValue];
    
    [self.tableView reloadData];
    
}

- (NSArray*) fetchTransactionsFromServer:(NSInteger) user_id{
    NSString* urlStr = [NSString stringWithFormat:@"https://rocky-scrubland-8564.herokuapp.com/query_transaction?user_id=%d", user_id];
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
    
    NSMutableArray* ret = [[NSMutableArray alloc]init];
    for (NSDictionary* transMap in myarr) {
        Transaction* t = [[Transaction alloc] init];
        t.carPlate = [transMap valueForKey:@"license"];
        t.parkingLot = [transMap valueForKey:@"address"];
        NSDate* date = [NSDate dateWithTimeIntervalSince1970:[[transMap valueForKey:@"park_time"] integerValue]];
        NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd"];
        NSString* dateStr = [formatter stringFromDate:date];
        t.date = dateStr;
        t.time = ([[transMap valueForKey:@"leave_time"] intValue ]- [[transMap valueForKey:@"park_time"] intValue])/60;
        t.expense =[ NSNumber numberWithDouble:[[transMap valueForKey:@"cost"] doubleValue]/100];
        
        [ret addObject:t];
    }
    
    
    
    return ret;
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
    return [transactions count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"transactionCell";
        TransactionCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    // Configure the cell...
    NSInteger row = indexPath.row;
    
    Transaction* t = [transactions objectAtIndex:row];
    cell.carPlateLabel.text = [NSString stringWithFormat:@"%@", t.carPlate];
    cell.parkingLotLabel.text = t.parkingLot;
    cell.dateLabel.text = t.date;
    cell.timeLabel.text = [NSString stringWithFormat:@"%d Minutes", t.time];
    cell.expenseLabel.text = [NSString stringWithFormat:@"$%.2f", t.expense.doubleValue];
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
