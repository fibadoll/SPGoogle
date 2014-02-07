//
//  SmartParkSecondViewController.m
//  SmartPark
//
//  Created by Chen Qiu on 9/26/12.
//  Copyright (c) 2012 VLIS. All rights reserved.
//

#import "MapViewController.h"
 
@implementation MapViewController

- (void)setMyParkLocation:(CLLocationCoordinate2D) myloc
{
    myParkLocation = myloc;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Create location manager object
        locationManager = [[CLLocationManager alloc] init];
        // There will be a warning from this line of code; ignore it for now
        [locationManager setDelegate:self];
        // And we want it to be as accurate as possible
        // regardless of how much time/power it takes
        [locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
        
        [locationManager startUpdatingLocation];
        xmlData = [[NSMutableData alloc] init];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    if (myParkLocation.latitude != 0) {
        NSLog(@"Appear my park:%f:%f", myParkLocation.latitude, myParkLocation.longitude);
        
        [self zoomMapAndCenterByCoordinate:myParkLocation];
        [activityIndicator setTag:0];
        SPMapPoint *newPoint = [[SPMapPoint alloc] initWithCoordinate:myParkLocation
                                                                title:@"My Parked Car"];
        [parkView addAnnotation:newPoint];
        [targetLocation setHidden:YES];
    }

}

- (void)viewDidLoad
{
    [parkView setShowsUserLocation:YES];
    [activityIndicator setTag:1];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self searchLocation:[textField text]];
    [textField resignFirstResponder];
    return YES;
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    //NSLog(@"%@", newLocation);
    // How many seconds ago was this new location created?
    NSTimeInterval t = [[newLocation timestamp] timeIntervalSinceNow];
    // CLLocationManagers will return the last found location of the
    // device first, you don't want that data in this case.
    // If this location was made more than 3 minutes ago, ignore it.
    if (t < -180) {
        // This is cached data, you don't want it, keep looking
        return;
    }
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    NSLog(@"Could not find location: %@", error);
}

- (void)searchLocation:(NSString*)name
{
    //NSLog(@"%@", name);
    //Build the string to Query Google Maps.

    NSMutableString *urlString =
        [NSMutableString stringWithFormat:@"http://maps.google.com/maps/geo?q=%@?output=json",name];
    
    //Replace Spaces with a '+' character.
    [urlString setString:[urlString stringByReplacingOccurrencesOfString:@" " withString:@"+"]];
    
    //Create NSURL string from a formate URL string.
    NSURL *url = [NSURL URLWithString:urlString];
    
    //Setup and start an async download.
    //Note that we should test for reachability!.
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    searchConnection = [[NSURLConnection alloc] initWithRequest:request
                                                       delegate:self];
    [activityIndicator startAnimating];
}


- (void)connection:(NSURLConnection*)connection
didReceiveResponse:(NSURLResponse*)response {
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
    int responseStatusCode = [httpResponse statusCode];
    NSLog(@"map view connection status: %d", responseStatusCode);
}

- (void)connection:(NSURLConnection *)connection
    didReceiveData:(NSData *)data
{
    [xmlData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if (connection == searchConnection) {
        //The string received from google's servers
        NSString *jsonString = [[NSString alloc] initWithData:xmlData
                                                     encoding:NSUTF8StringEncoding];
        
        NSLog(@"json:%@", jsonString);
        //JSON Framework magic to obtain a dictionary from the jsonString.
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        NSDictionary *results = [parser objectWithString:jsonString];
        
        //NSLog(@"results: %@", results);
        //Now we need to obtain our coordinates
        NSArray *placemark  = [results objectForKey:@"Placemark"];
        NSArray *coordinates = [[placemark objectAtIndex:0] valueForKeyPath:@"Point.coordinates"];
        
        // Reset the UI
        [targetLocation setText:@""];
        [targetLocation setHidden:NO];
        [activityIndicator stopAnimating];
        [locationManager stopUpdatingLocation];
        if (!coordinates) {
            UIAlertView *cannotFindAlert = [[UIAlertView alloc]
                                            initWithTitle:@"Cannot Find Location"
                                            message:@"Please enter location precisely!"
                                            delegate:nil
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles:nil];
            
            [cannotFindAlert show];
            [locationManager startUpdatingLocation];
            [activityIndicator setTag:1];
            return;
        }
        
        //I put my coordinates in my array.
        double longitude = [[coordinates objectAtIndex:0] doubleValue];
        double latitude = [[coordinates objectAtIndex:1] doubleValue];
        
        NSString *destinationAddress = [[placemark objectAtIndex:0] valueForKey:@"address"];
        //NSLog(@"address: %@",destinationAddress);
        //Debug.
        //NSLog(@"Latitude - Longitude: %f %f", latitude, longitude);
        
        //I zoom my map to the area in question.
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude, longitude);
        SPMapPoint *dp = [[SPMapPoint alloc] initWithCoordinate:coordinate
                                                          title:destinationAddress];
        // Add it to the map view
        [parkView addAnnotation:dp];
        [activityIndicator setTag:0];
        
        // Zoom the region to this location
        [self zoomMapAndCenterByCoordinate:coordinate];
        [xmlData setData:nil];
    } else if (connection == viewStatusConnection) {
        NSLog(@"%@", xmlData);
        //The string received from google's servers
        NSString *jsonString = [[NSString alloc] initWithData:xmlData
                                                     encoding:NSUTF8StringEncoding];
        
        
        jsonString = [jsonString stringByReplacingOccurrencesOfString:@"[]" withString:@""];
        NSLog(@"%@", jsonString);
        //JSON Framework magic to obtain a dictionary from the jsonString.
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        NSArray *results = [parser objectWithString:jsonString];
        NSLog(@"results: %@", results);
        [activityIndicator stopAnimating];
        [xmlData setData:nil];
        
        for (int i = 0; i < [results count]; i++) {
            
            NSDictionary *tmp = [results objectAtIndex:i];
            
            NSLog(@"%@ at %d", tmp, i);
            NSNumber *latitude = [tmp objectForKey:@"latitude"];
            NSNumber *longitude = [tmp objectForKey:@"longitude"];
            NSNumber *status = [tmp objectForKey:@"status"];
            NSString *title;
            // 0:Available 1:Occupied 2:Unavailable
            switch ([status intValue]) {
                case 0:
                    title = @"Available";
                    break;
                case 1:
                    title = @"Occupied";
                    break;
                case 2:
                    title = @"Unavailable";
                    break;
                default:
                    break;
            }
            CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([latitude doubleValue], [longitude doubleValue]);
            SPMapPoint *newPoint = [[SPMapPoint alloc] initWithCoordinate:coordinate
                                                                    title:title];
            [parkView addAnnotation:newPoint];
        }
    }
    
}

//Annotation for Map Point
- (MKAnnotationView *)mapView:(MKMapView *)mapView
            viewForAnnotation:(id < MKAnnotation >)annotation
{
    if ([[annotation title] isEqualToString:@"Current Location"]) {
        return nil;
    } else if ([[annotation title] isEqualToString:@"Available"]) {
        //NSLog(@"a%f : %f", [annotation coordinate].latitude, [annotation coordinate].longitude);
        available = [[MKAnnotationView alloc] initWithAnnotation:annotation
                                                 reuseIdentifier:@"available"];
        [available setImage:[UIImage imageWithContentsOfFile:
                             [[NSBundle mainBundle] pathForResource:@"available"
                                                             ofType:@"png"]]];
        return available;
    } else if ([[annotation title] isEqualToString:@"Occupied"]) {
        occupied = [[MKAnnotationView alloc] initWithAnnotation:nil
                                                reuseIdentifier:@"occupied"];
        [occupied setImage:[UIImage imageWithContentsOfFile:
                            [[NSBundle mainBundle] pathForResource:@"occupied"
                                                            ofType:@"png"]]];
        return occupied;
    } else if ([[annotation title] isEqualToString:@"Unavailable"]) {
        //NSLog(@"un%f : %f", [annotation coordinate].latitude, [annotation coordinate].longitude);

        unavailable = [[MKAnnotationView alloc] initWithAnnotation:nil
                                                   reuseIdentifier:@"unavailable"];
        [unavailable setImage:[UIImage imageWithContentsOfFile:
                               [[NSBundle mainBundle] pathForResource:@"unavailable"
                                                               ofType:@"png"]]];
        return unavailable;
    } else {
        //NSLog(@"local%f : %f", [annotation coordinate].latitude, [annotation coordinate].longitude);

        //NSLog(@"label: %@", [annotation title] );
        return nil;
    }
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    CLLocationCoordinate2D center = [mapView centerCoordinate];
    
    NSMutableString *urlString =
    [NSMutableString stringWithFormat:@"https://rocky-scrubland-8564.herokuapp.com/query_parkingspots?latitude=%f&longitude=%f", center.latitude, center.longitude];
    
    //Create NSURL string from a formate URL string.
    NSURL *url = [NSURL URLWithString:urlString];
    
    //Setup and start an async download.
    //Note that we should test for reachability!.
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    viewStatusConnection = [[NSURLConnection alloc] initWithRequest:request
                                                           delegate:self];
    [activityIndicator startAnimating];
}

- (void)mapView:(MKMapView *)mapView
didUpdateUserLocation:(MKUserLocation *)userLocation {
    //tag 0: Search Target Location
    //tag 1: Update current location
    if ([activityIndicator tag]) {
        [self zoomMapAndCenterByCoordinate:[userLocation coordinate]];
    }
}


- (void)zoomMapAndCenterByCoordinate:(CLLocationCoordinate2D) coordinate
{
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coordinate, 100, 100);
    
    //Move the map and zoom
    [parkView setRegion:region animated:YES];
}


@end
