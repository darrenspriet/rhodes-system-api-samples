//
//  ECViewController.m
//  encompass
//
//  Created by Dilip Muthukrishnan on 2014-02-28.
//  Copyright (c) 2014 encompass. All rights reserved.
//

#import "ECViewController.h"

@implementation ECViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _mapView.delegate = self;
    _dateLabel.text = [self getCurrentDateString];
    // Store the dummy addresses in the addresses array
    _addresses = [[NSArray alloc] initWithObjects:@"6075 Mavis Road",
                                                @"2975 Argentia Road",
                                                @"2460 Winston Churchill Blvd.",
                                                nil];
    _mapItems = [[NSMutableArray alloc] initWithCapacity:3];
    _mapItemIndex = 0;
    _optimalRouteView = YES;
    _currentLocationView = NO;
    _customRouteView = NO;
    [self optimizedRoutePressed:nil];
    // Clear all annotations from the map (there shouldn't be any at this point!)
    [_mapView removeAnnotations:[_mapView annotations]];
    // Get the MKMapItems for each address, store them in the array, and
    // generate annotations for each item on the map.
    for (NSString *address in _addresses)
    {
        [self searchLocationsUsingString:address];
    }
}

- (void)searchLocationsUsingString:(NSString *)query
{
    MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc] init];
    request.naturalLanguageQuery = query;
    MKCoordinateRegion searchRegion = MKCoordinateRegionMakeWithDistance (_mapView.region.center, 20000, 20000);
    request.region = searchRegion;
    MKLocalSearch *search = [[MKLocalSearch alloc] initWithRequest:request];
    
    [search startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error)
    {
        if (response.mapItems.count == 0)
        {
            NSLog(@"No Matches");
        }
        // If we are searching for an address
        else if (response.mapItems.count == 1)
        {
            MKMapItem *item = [response.mapItems objectAtIndex:0];
            NSLog(@"name = %@", item.name);
            [_mapItems addObject:item];
            [self generateAnnotationForMapItem:item];
        }
        // If our search yields multiple results
        else
        {
            for (MKMapItem *item in response.mapItems)
            {
                NSLog(@"name = %@", item.name);
                NSLog(@"Phone = %@", item.phoneNumber);
            }
        }
        // Once we have stored all the MKMapItems, determine the optimal route
        // and draw the polylines for this route.
        if (_mapItems.count == 3)
        {
            [self calculateBestRoute];
        }
    }];
}

- (void)generateAnnotationForMapItem:(MKMapItem *)item
{
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    annotation.coordinate = item.placemark.coordinate;
    annotation.title = item.name;
    [_mapView addAnnotation:annotation];
}

// Called recursively to construct the route piecewise.
// NOTE: This is just done in the order in which the locations are stored
// in our _mapItems array.  We still have to work out a proper routing algorithm!
- (void)calculateBestRoute
{
    MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
    request.source = (MKMapItem *)[_mapItems objectAtIndex:_mapItemIndex];
    request.destination = (MKMapItem *)[_mapItems objectAtIndex:_mapItemIndex+1];
    request.requestsAlternateRoutes = NO;
    MKDirections *directions = [[MKDirections alloc] initWithRequest:request];
    [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error)
     {
         if (error)
         {
             // Handle Error
         }
         else
         {
             [self drawPolylineOnMap:response];
             _mapItemIndex++;
             if (_mapItemIndex < 2)
             {
                 [self calculateBestRoute];
             }
             else
             {
                 _mapItemIndex = 0;
             }
         }
     }];
}

// Draws the polyline for the route between two locations
- (void)drawPolylineOnMap:(MKDirectionsResponse *)response
{
    // There should only be one route so this loop should
    // execute only once!
    for (MKRoute *route in response.routes)
    {
        [_mapView addOverlay:route.polyline level:MKOverlayLevelAboveRoads];
    }
}

// If the map is set to the current location, move the location marker
// as the user changes position
- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    if (_currentLocationView)
    {
        _mapView.centerCoordinate = userLocation.location.coordinate;
    }
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id < MKOverlay >)overlay
{
    MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc] initWithOverlay:overlay];
    renderer.strokeColor = [UIColor blueColor];
    renderer.lineWidth = 3.0;
    return renderer;
}

- (NSString *)getCurrentDateString
{
    NSDate *currDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"MM.dd.YYYY"];
    NSString *dateString = [dateFormatter stringFromDate:currDate];
    return dateString;
}

- (IBAction)optimizedRoutePressed:(UIButton *)sender
{
    _currentLocationView = NO;
    _optimalRouteView = YES;
    _customRouteView = NO;
    // Clear all annotations from the map
    [_mapView removeAnnotations:[_mapView annotations]];
    // Set 3359 Mississauga Rd as the default location
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(43.549139,-79.663281);
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance (coordinate, 20000, 20000);
    [_mapView setRegion:region animated:NO];
    // You have to generate the annotations again but only if we already
    // have all the map items (not the case when this method is called from viewDidLoad()
    if (_mapItems.count == 3)
    {
        for (MKMapItem *item in _mapItems)
        {
            [self generateAnnotationForMapItem:item];
        }
        // We need to calculate the route again
        [self calculateBestRoute];
    }
}

// Set the current location as the specified location
- (IBAction)currentLocationPressed:(UIButton *)sender
{
    _currentLocationView = YES;
    _optimalRouteView = NO;
    _customRouteView = NO;
    // Clear all annotations from the map
    [_mapView removeAnnotations:[_mapView annotations]];
    // Display the current location of the user
    MKUserLocation *userLocation = _mapView.userLocation;
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance (userLocation.location.coordinate, 2000, 2000);
    [_mapView setRegion:region animated:NO];
}

@end
