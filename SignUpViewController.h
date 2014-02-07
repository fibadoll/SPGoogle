//
//  SignUpViewController.h
//  SmartPark
//
//  Created by Guannan Zhang on 10/29/12.
//  Copyright (c) 2012 Guannan Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SignUpViewController : UITableViewController<UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UITextField *nameField;
@property (strong, nonatomic) IBOutlet UITextField *emailField;
@property (strong, nonatomic) IBOutlet UITextField *passwordField;
@property (strong, nonatomic) IBOutlet UITextField *confirmPasswordField;
@property (strong, nonatomic) IBOutlet UILabel *msgLabel;

- (IBAction)signUp:(id)sender;
@end
