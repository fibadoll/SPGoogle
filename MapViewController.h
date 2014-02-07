//
//  SmartParkSecondViewController.h
//  SmartPark
//
//  Created by Chen Qiu on 9/26/12.
//  Copyright (c) 2012 VLIS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "SPMapPoint.h"
#import "SBJson.h"

@interface MapViewController : UIViewController <CLLocationManagerDelegate,
                               MKMapViewDelegate, UITextFieldDelegate>
{
    CLLocationManager *locationManager;
    
    MKAnnotationView *available;
    MKAnnotationView *occupied;
    MKAnnotationView *unavailable;
    
    NSURLConnection *searchConnection;
    NSURLConnection *viewStatusConnection;
    
    NSMutableData *xmlData;
    CLLocationCoordinate2D myParkLocation;
    
    IBOutlet MKMapView *parkView;
    IBOutlet UIActivityIndicatorView *activityIndicator;
    IBOutlet UITextField *targetLocation;
}

- (void)setMyParkLocation:(CLLocationCoordinate2D) myloc;
- (void)searchLocation:(NSString*) name;
- (void)zoomMapAndCenterByCoordinate:(CLLocationCoordinate2D) coordinate;
@end
