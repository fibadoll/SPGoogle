//
//  SmartParkFirstViewController.h
//  SmartPark
//
//  Created by Chen Qiu on 9/26/12.
//  Copyright (c) 2012 VLIS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserData.h"
#import "ZBarSDK/Headers/ZBarSDK/ZBarSDK.h"

@interface ParkingViewController : UIViewController <UITextFieldDelegate, ZBarReaderDelegate,UINavigationControllerDelegate>
{
    NSMutableData *xmlData;
    
    NSNumber *spotId;
    NSNumber *carId;
    NSDate *parkedTime;
    NSNumber *parkingId;
    NSMutableArray *spotNumber;
    UserData *user;
    
    ZBarSymbol *barResults;
    
    //Automatically move to next textfield
    IBOutlet UITextField *digit1;
    IBOutlet UITextField *digit2;
    IBOutlet UITextField *digit3;
    IBOutlet UITextField *digit4;
    IBOutlet UIButton *camera;
}
@property (nonatomic, strong) NSManagedObjectContext* objectContext;

- (IBAction)scan:(id)sender;
- (IBAction)park:(id)sender;
- (IBAction)backgroundTapped:(id)sender;
- (void)textFieldDidChanged:(NSNotification *)notification;


@end
