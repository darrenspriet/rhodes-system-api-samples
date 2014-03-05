//
//  ECViewController.m
//  encompass
//
//  Created by Darren Spriet on 2014-02-26.
//  Copyright (c) 2014 encompass. All rights reserved.
//

#import "ECViewController.h"

@interface ECViewController ()

@end

@implementation ECViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _mapView.delegate = self;
    // Removing annotations (no annotations at this point!)
    //[_mapView removeAnnotations:[_mapView annotations]];

    // Set HMC as the center of the map with radius 1 km
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(43.590917, -79.647192);
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coordinate, 20000, 20000);
    [_mapView setRegion:region animated:NO];
 
    
    // Set the current location as the default location with radius 1 km
    /*MKUserLocation *userLocation = _mapView.userLocation;
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(userLocation.location.coordinate, 1000, 1000);
    [_mapView setRegion:region animated:NO];*/
    
    // Draw a pin with annotation on the map
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    annotation.coordinate = coordinate;
    annotation.title = @"Hazel McCallion Campus";
    [_mapView addAnnotation:annotation];
    
    // Search for a location
    MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc] init];
    request.naturalLanguageQuery = @"Tim Hortons";
    MKCoordinateRegion searchRegion = MKCoordinateRegionMakeWithDistance(_mapView.region.center, 20000, 20000);
    request.region = searchRegion;
    MKLocalSearch *search = [[MKLocalSearch alloc] initWithRequest:request];
    [search startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error)
    {
        for (MKMapItem *item in response.mapItems)
        {
            NSLog(@"Location name: %@", item.name);
            
            MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
            annotation.coordinate = item.placemark.coordinate;
            annotation.title = item.name;
            [_mapView addAnnotation:annotation];

        }
        
    }];
    NSLog(@"Dilip is great!");
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    // Do something when the user changes the location
}

- (IBAction)launchMapsPressed:(UIButton *)sender
{
    [MKMapItem openMapsWithItems:nil launchOptions:nil];
}

@end
