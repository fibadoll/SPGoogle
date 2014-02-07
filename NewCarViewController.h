//
//  NewCarViewController.h
//  SmartPark
//
//  Created by Guannan Zhang on 12-10-10.
//  Copyright (c) 2012年 Guannan Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewCarViewController : UIViewController

@property (strong, nonatomic) IBOutlet UITextField *numberField;

@property (strong, nonatomic) IBOutlet UILabel *msgLabel;

- (IBAction)onDone:(id)sender;
- (NSDictionary*) sendNewCarMessageToServer: (NSString*) license userID: (NSNumber*) user_id;
@end
