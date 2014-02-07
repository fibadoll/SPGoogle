//
//  PaymentViewController.h
//  SmartPark
//
//  Created by Guannan Zhang on 11/11/12.
//  Copyright (c) 2012 Guannan Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PaymentData.h"


@interface PaymentViewController : UITableViewController<UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate, NSURLConnectionDelegate, UIGestureRecognizerDelegate>
@property (strong, nonatomic) IBOutlet UITextField *cardNumberField;
@property (strong, nonatomic) IBOutlet UITextField *cvvField;
@property (strong, nonatomic) IBOutlet UITextField *expireDateField;
@property (strong, nonatomic) IBOutlet UITextField *firstNameField;
@property (strong, nonatomic) IBOutlet UITextField *lastNameField;
@property (strong, nonatomic) IBOutlet UITextField *address1Field;
@property (strong, nonatomic) IBOutlet UITextField *address2Field;
@property (strong, nonatomic) IBOutlet UITextField *cityField;
@property (strong, nonatomic) IBOutlet UITextField *stateField;
@property (strong, nonatomic) IBOutlet UITextField *countryFeild;
@property (strong, nonatomic) IBOutlet UITextField *zipCodeField;
@property (strong, nonatomic) IBOutlet UIButton *payButton;
@property (strong, nonatomic) IBOutlet UILabel *msgLabel;

@property (strong, nonatomic) NSManagedObjectContext* objectContext;
@property (strong, nonatomic) PaymentData* payment;
@property (strong, nonatomic) NSNumber* carId;
@property (strong, nonatomic) NSNumber* spotId;
@property (strong, nonatomic) NSNumber* parkingId;
@property (strong, nonatomic) NSDate* parkingTime;
@property (assign, nonatomic) BOOL fromParking;
@property (strong, nonatomic) NSNumber* expireYear;
@property (strong, nonatomic) NSNumber* expireMonth;
@property (strong, nonatomic) IBOutlet UIPickerView *expireDatePicker;
@property (strong, nonatomic) IBOutlet UIPickerView *statePicker;
@property (strong, nonatomic) IBOutlet UIPickerView *countryPicker;
@property (strong, nonatomic) NSArray* months;
@property (strong, nonatomic) NSArray* years;
@property (strong, nonatomic) NSArray* states;
@property (strong, nonatomic) NSArray* countries;

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
@property (strong, nonatomic) NSData *responseData;
@property (assign, nonatomic) int responseCode;

- (IBAction)done:(id)sender;
- (IBAction)pay:(id)sender;

@end
