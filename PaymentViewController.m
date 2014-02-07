//
//  PaymentViewController.m
//  SmartPark
//
//  Created by Guannan Zhang on 11/11/12.
//  Copyright (c) 2012 Guannan Zhang. All rights reserved.
//

#import "PaymentViewController.h"
#import "SmartParkAppDelegate.h"
#import "UserData.h"
#import "PaymentData.h"
#import "SBJson.h"
#import "LeavingViewController.h"

@implementation PaymentViewController
@synthesize cardNumberField;
@synthesize cvvField;
@synthesize expireDateField;
@synthesize firstNameField;
@synthesize lastNameField;
@synthesize address1Field;
@synthesize address2Field;
@synthesize cityField;
@synthesize stateField;
@synthesize countryFeild;
@synthesize zipCodeField;
@synthesize payButton;
@synthesize msgLabel;

@synthesize objectContext;
@synthesize payment;
@synthesize carId;
@synthesize spotId;
@synthesize parkingId;
@synthesize parkingTime;
@synthesize fromParking;
@synthesize expireMonth;
@synthesize expireYear;
@synthesize expireDatePicker;
@synthesize statePicker;
@synthesize countryPicker;
@synthesize months;
@synthesize years;
@synthesize states;
@synthesize countries;
@synthesize indicator;
@synthesize responseData;
@synthesize responseCode;

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
        
    months = [NSArray arrayWithObjects:@"01", @"02", @"03", @"04", @"05", @"06", @"07", @"08", @"09", @"10", @"11", @"12", nil];
    years = [NSArray arrayWithObjects:@"2012", @"2013", @"2014", @"2015", @"2016", @"2017", @"2018", @"2019", @"2020", @"2021", @"2022", @"2023", @"2024", @"2025", @"2026", nil];
    countries = [NSArray arrayWithObjects:@"US", nil];
    states = [NSArray arrayWithObjects:@"AL", @"AK", @"AZ", @"AR", @"CA", @"CO", @"CT", @"DE", @"FL", @"GA", @"HI", @"ID", @"IL", @"IN",@"IA", @"KS", @"KY", @"LA", @"ME", @"MD", @"MA", @"MI", @"MN",@"MS", @"MO", @"MT", @"NE", @"NV", @"NH", @"NJ",@"NM", @"NY", @"NC", @"ND", @"OH", @"OK", @"OR", @"PA", @"RI", @"SC", @"SD", @"TN", @"TX", @"UT", @"VT", @"VA", @"WA", @"WV", @"WI", @"WY" , nil];
    expireDateField.inputView = expireDatePicker;
    countryFeild.inputView = countryPicker;
    stateField.inputView = statePicker;
    
    UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    tgr.delegate = self;
    [self.tableView addGestureRecognizer:tgr];
    
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view isKindOfClass:[UITextField class]]) {
        NSLog(@"User tapped on UITextField");
        
        return YES; // do whatever u want here
    }
    
    else if ([touch.view isKindOfClass:[UIButton class]]) {
        NSLog(@"button");
        return NO;
    }

    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated{
    
    SmartParkAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    objectContext = [appDelegate managedObjectContext];
    
    NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription* entityDescription = [NSEntityDescription
                                              entityForName:@"UserData"
                                              inManagedObjectContext:objectContext];
    [fetchRequest setEntity:entityDescription];
    NSError* error;
    NSArray* fetchedUsers = [objectContext executeFetchRequest:fetchRequest error:&error];
    
    UserData* user = [fetchedUsers objectAtIndex:0];
    
    NSNumber* userId = user.user_id;
    NSLog(@"%d, %d, %d", userId.intValue, carId.intValue, spotId.intValue);
    
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
    NSEntityDescription* desc = [NSEntityDescription
                                 entityForName:@"PaymentData"
                                 inManagedObjectContext:objectContext];
    [request setEntity:desc];
    
    NSPredicate *pred = [NSPredicate
                         predicateWithFormat:@"(user_id = %d)", userId.intValue];
    [request setPredicate:pred];
    
    NSArray* fetchedPayments = [objectContext executeFetchRequest:request error:&error];
    NSLog(@"%d", [fetchedPayments count]);
    
    if ([fetchedPayments count] > 0) {
        payment = [fetchedPayments objectAtIndex:0];
        cardNumberField.text = payment.card_number;
        cvvField.text = payment.cvv;
        expireMonth = payment.expire_month.intValue == 0? [NSNumber numberWithInt:1]: payment.expire_month;
        expireYear = payment.expire_year.intValue == 0? [NSNumber numberWithInt:2012]: payment.expire_year;
        expireDateField.text = [NSString stringWithFormat:@"%2d / %d", expireMonth.intValue, expireYear.intValue];
        firstNameField.text = payment.first_name;
        lastNameField.text = payment.last_name;
        address1Field.text = payment.address_1;
        if (payment.address_2 != nil) {
            
            address2Field.text = payment.address_2;
        }
        cityField.text = payment.city;
        stateField.text = payment.state == nil? @"AL": payment.state;
        countryFeild.text = payment.country == nil ? @"US": payment.country;
        zipCodeField.text = payment.zip_code;
    }else {
        payment = (PaymentData*)[NSEntityDescription
                                 insertNewObjectForEntityForName:@"PaymentData"
                                 inManagedObjectContext:objectContext];
        
        payment.user_id = userId;
        cardNumberField.text = @"4993865548768768";
        cvvField.text = @"123";
        expireDateField.text = @"11 / 2017";
        expireMonth = [NSNumber numberWithInt:11];
        expireYear = [NSNumber numberWithInt:2017];
        firstNameField.text = @"Buyer";
        lastNameField.text = @"A";
        address1Field.text = @"1 Main St";
        address2Field.text = @"";
        cityField.text = @"San Jose";
        stateField.text = @"CA";
        countryFeild.text = @"US";
        zipCodeField.text = @"95131";
        
        //for test
        payment.card_number =@"4993865548768768";
        payment.cvv = @"123";
        payment.expire_month = [NSNumber numberWithInt:11];
        payment.expire_year =[NSNumber numberWithInt:2017];
        payment.first_name = @"Buyer";
        payment.last_name = @"A";
        payment.address_1 = @"1 Main St";
        payment.address_2 = @"";
        payment.city = @"San Jose";
        payment.state = @"CA";
        payment.country = @"US";
        payment.zip_code = @"95131";
        [objectContext save:nil];
        //for test
    }
    
    if (fromParking) {
        self.navigationItem.rightBarButtonItem = nil;
        payButton.hidden = NO;
    }
    else {
        //self.navigationItem.rightBarButtonItem
        payButton.hidden = YES;
        
        
    }
    
    NSLog(@"%@", stateField.text);

   
}

- (void)viewDidUnload {
    [self setCardNumberField:nil];
    [self setCvvField:nil];
    [self setFirstNameField:nil];
    [self setLastNameField:nil];
    [self setAddress1Field:nil];
    [self setAddress2Field:nil];
    [self setCityField:nil];
    [self setStateField:nil];
    [self setCountryFeild:nil];
    [self setZipCodeField:nil];
    [self setPayButton:nil];


    [self setMsgLabel:nil];
    [self setExpireDatePicker:nil];
    [self setExpireDatePicker:nil];
    [self setIndicator:nil];
    [super viewDidUnload];
}

- (IBAction)done:(id)sender {
    NSLog(@"%@", stateField.text);
    [cardNumberField resignFirstResponder];
    [cvvField resignFirstResponder];
    [expireDateField resignFirstResponder];
    [firstNameField resignFirstResponder];
    [lastNameField resignFirstResponder];
    [address1Field resignFirstResponder];
    [address2Field resignFirstResponder];
    [cityField resignFirstResponder];
    [stateField resignFirstResponder];
    [countryFeild resignFirstResponder];
    [zipCodeField resignFirstResponder];
    
    payment.card_number = cardNumberField.text == nil? @"": cardNumberField.text;
    payment.cvv = cvvField.text==nil?@"": cvvField.text;
    payment.expire_month = expireMonth;
    payment.expire_year =expireYear;
    
    payment.first_name = firstNameField.text==nil?@"": firstNameField.text;
    payment.last_name = lastNameField.text==nil?@"": lastNameField.text;
    payment.address_1 = address1Field.text==nil?@"":address1Field.text;
    payment.address_2 = address2Field.text==nil?@"": address2Field.text;
    payment.city = cityField.text==nil? @"": cityField.text;
    payment.state = stateField.text==nil ?@"": stateField.text;
    payment.country = countryFeild.text==nil ?@"": countryFeild.text;
    payment.zip_code = zipCodeField.text==nil?@"": zipCodeField.text;
    
    [objectContext save:nil];
    
    [self.navigationController popViewControllerAnimated:YES];
    
}


-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    if (textField == cardNumberField) {
        [cvvField becomeFirstResponder];
    }
    else if (cvvField == textField){
        [expireDateField becomeFirstResponder];
    }
    else if (textField == expireDateField){
        [firstNameField becomeFirstResponder];
    }
    else if (textField == firstNameField){
        [lastNameField becomeFirstResponder];
    }
    else if (lastNameField == textField){
        [address1Field becomeFirstResponder];
    }
    else if (address1Field == textField){
        [address2Field becomeFirstResponder];
    }
    else if (textField == address2Field){
        [cityField becomeFirstResponder];
    }
    else if (textField == cityField){
        [stateField becomeFirstResponder];
    }
    else if (textField == stateField){
        [countryFeild becomeFirstResponder];
    }
    else if (countryFeild == textField){
        [zipCodeField becomeFirstResponder];
    }
    else if (zipCodeField == textField){
        [self done:self];
    }
    return YES;
}

- (IBAction)pay:(id)sender {
    
    [indicator setHidden:NO];
    [indicator startAnimating];
    NSLog(@"%@", indicator);
    
    NSArray *key = [NSArray arrayWithObjects:@"car_id", @"parkingspot_id",nil];
    NSArray *object = [NSArray arrayWithObjects: carId, spotId, nil];
    NSDictionary *parking = [NSDictionary dictionaryWithObjects:object forKeys:key];
    NSLog(@"parking:%@",parking);
    
    
    NSArray *keys = [NSArray arrayWithObjects:@"parking", @"first_name", @"last_name", @"address1", @"address2", @"city", @"state", @"country", @"zip", @"card_number", @"card_verification", @"month", @"year", @"commit", @"utf8",nil];
    NSArray *objects;
  
    objects= [NSArray arrayWithObjects: parking, firstNameField.text, lastNameField.text, address1Field.text, address2Field.text, cityField.text, stateField.text, countryFeild.text, zipCodeField.text, cardNumberField.text, cardNumberField.text, expireMonth, expireYear, @"Post", @"✓", nil];
    NSLog(@"key:%@\nobject:%@", keys, objects);

    NSDictionary *myData = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
    SBJsonWriter *writer = [[SBJsonWriter alloc] init];
    NSLog(@"%@",writer);
    NSData *myJSONData = [writer dataWithObject:myData];
    NSLog(@"my data:%@", myData);
    
    NSURL *url = [NSURL URLWithString:@"https://rocky-scrubland-8564.herokuapp.com/parkings/"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:myJSONData];
    [request setValue:@"application/json" forHTTPHeaderField:@"content-type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"Smart_Park_App" forHTTPHeaderField:@"User-Agent"];
    
    NSURLConnection *asyncConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    //[responseData setLength:0];
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
    responseCode = [httpResponse statusCode];
    NSLog(@"%d", responseCode);
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    //NSLog(@"received Data: %@", data);
    responseData = [data copy];
    //NSLog(@"responseData: %@", responseData);
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // Once this method is invoked, "responseData" contains the complete result
    [indicator stopAnimating];
    NSMutableData *xmlData = [[NSMutableData alloc] init];
    [xmlData setData:responseData];
    //NSLog(@"xmlData: %@", xmlData);
    NSString *xmlCheck = [[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding];
    NSLog(@"xmlCheck: %@", xmlCheck);
    
    //SBJsonParser* parser = [[SBJsonParser alloc] init];
    // assuming jsonString is your JSON string...
    //NSArray* myarr = [parser objectWithString:xmlCheck];
    
    SBJsonParser* parser = [[SBJsonParser alloc] init];
    // assuming jsonString is your JSON string...
   
    if (responseCode == 200) {
        NSDictionary *myarr = [parser objectWithString:xmlCheck];
        NSLog(@"%@", myarr);
        
        parkingId = [myarr objectForKey:@"id"];
        
        NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
        parkingTime = [dateFormatter dateFromString:[myarr objectForKey:@"starttime"]];
        NSLog(@"park at: %@", [myarr objectForKey:@"starttime"]);
        NSLog(@"parking Time: %@", parkingTime);
        NSLog(@"%@", myarr);
        
        [self performSegueWithIdentifier:@"paymentSuccess" sender:self];
    }
    else if (responseCode == 404){
        NSArray* myarr = [parser objectWithString:xmlCheck];
        msgLabel.text = [myarr objectAtIndex:0];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    LeavingViewController *viewController = segue.destinationViewController;
    [viewController setParkingId:parkingId];
    [viewController setSpotId:spotId];
    [viewController setCarId:carId];
    [viewController setParkedTime:parkingTime];
}

-(NSInteger) numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    if (pickerView == expireDatePicker) {
        return 2;
    }
    else{
        return 1;
    }
}

- (NSInteger) pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    if (pickerView == expireDatePicker) {
        if (component == 0) {
            return [months count];
        }
        else if (component == 1){
            return [years count];
        }
    }
    else if (pickerView == countryPicker){
        return [countries count];
    }
    else if (pickerView == statePicker){
        return [states count];
    }
    return 0;
}

-(NSString*) pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    if (pickerView == expireDatePicker) {
        if (component == 0) {
            return [months objectAtIndex:row];
        }
        else if ( component == 1){
            return [years objectAtIndex:row];
        }
    }
    else if (pickerView == countryPicker){
        return [countries objectAtIndex:row];
    }
    else if (pickerView == statePicker){
        return [states objectAtIndex:row];
    }
    return nil;
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    if (pickerView == expireDatePicker) {
        NSInteger monthRow = [pickerView selectedRowInComponent:0];
        NSInteger yearRow = [pickerView selectedRowInComponent:1];
        
        expireMonth = [NSNumber numberWithInt:[[months objectAtIndex:monthRow] intValue]];
        expireYear = [NSNumber numberWithInt:[[years objectAtIndex:yearRow] intValue]];
        
        expireDateField.text = [NSString stringWithFormat:@"%2d / %d", expireMonth.intValue, expireYear.intValue];
    }
    else if (pickerView == countryPicker){
        countryFeild.text = [countries objectAtIndex:row];
    }
    else if (pickerView == statePicker){
        stateField.text = [states objectAtIndex:row];
    }
    
}

-(BOOL) textFieldShouldBeginEditing:(UITextField *)textField{
    if (textField == expireDateField) {
        NSLog(@"%d, %d", expireMonth.integerValue, expireYear.integerValue);
        [expireDatePicker selectRow:(expireMonth.integerValue - 1) inComponent:0 animated:YES];
        [expireDatePicker selectRow:(expireYear.integerValue - 2012) inComponent:1 animated:YES];
    }
    else if (textField == countryFeild){
        [countryPicker selectRow:0 inComponent:0 animated:YES];
    }
    else if (textField == stateField){
        NSInteger index = [states indexOfObject:stateField.text];
        [statePicker selectRow:index inComponent:0 animated:YES];
    }
    return YES;
}
- (BOOL) textFieldShouldEndEditing:(UITextField *)textField{
    if (textField == countryFeild) {
        countryFeild.text = [countries objectAtIndex:[countryPicker selectedRowInComponent:0]];
    }
    else if(textField == stateField){
        stateField.text = [states objectAtIndex:[statePicker selectedRowInComponent:0]];
    }
    return YES;
}



- (void)viewTapped:(UITapGestureRecognizer *)tgr
{
    NSLog(@"view tapped");
    [cardNumberField resignFirstResponder];
    [cvvField resignFirstResponder];
    [expireDateField resignFirstResponder];
    [firstNameField resignFirstResponder];
    [lastNameField resignFirstResponder];
    [address1Field resignFirstResponder];
    [address2Field resignFirstResponder];
    [cityField resignFirstResponder];
    [stateField resignFirstResponder];
    [countryFeild resignFirstResponder];
    [zipCodeField resignFirstResponder];
    
}

@end
