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
    _addresses = [[NSMutableArray alloc] initWithObjects:@"Best Buy \n6075 Mavis Road \nMississauga, ON \nL5H 2M9",
                                                @"Future Shop \n2975 Argentia Road \nMississauga, ON \nL6H 2W2",
                                                @"Staples \n2460 Winston Churchill Boulevard \nOakville, ON \nL7M 3T2",
                                                @"Trinbago Barbershop \n2547 Hurontario Street \nMississauga, ON \nL5A 2G4",
                                                @"Rattray Marsh \n600-798 Nautalex Crt \nMississauga, ON \nL5H 1A7",
                                                nil];
    _mapItems = [[NSMutableArray alloc] initWithCapacity:_addresses.count];
    // Need to do this to allow non-sequential inertion during location search
    // because NSMutableArray objects never contain free spaces (except at the end)
    for (int i = 0; i < _addresses.count; i++)
    {
        [_mapItems addObject:[NSNull null]];
    }
    _mapItemIndex = 0;
    _optimalRouteView = YES;
    _currentLocationView = NO;
    _customRouteView = NO;
    [self optimizedRoutePressed:nil];
    // Clear all markers and routes from the map (there shouldn't be any at this point!)
    [_mapView removeAnnotations:[_mapView annotations]];
    [_mapView removeOverlays:[_mapView overlays]];
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
        // Search yielded no results
        if (response.mapItems.count == 0)
        {
            NSLog(@"No Matches");
        }
        // If we are searching for an address
        else if (response.mapItems.count == 1)
        {
            MKMapItem *item = [response.mapItems objectAtIndex:0];
            // _mapItems should have the same ordering as _addresses
            [_mapItems replaceObjectAtIndex:[_addresses indexOfObject:query] withObject:item];
            [self generateAnnotationForMapItem:item];
        }
        // If our search yields multiple results (this shouldn't happen
        // in this application because we are only searching addresses)
        else
        {
            for (MKMapItem *item in response.mapItems)
            {
                NSLog(@"name = %@", item.name);
            }
        }
        // Once we have obtained all of the map items, we can
        // determine the optimal route and draw the polylines for this route.
        if ([self mapItemsDidFinishLoading])
        {
            for (MKMapItem *item in _mapItems)
            {
                NSLog(@"Location Name = %@", item.name);
            }
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
             if (_mapItemIndex < _addresses.count-1)
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

// This method is called everytime a polyline needs to be drawn
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
    // Allow address listing to not be editable
    [_tableView setEditing:NO animated:YES];
    // Clear all markers and routes from the map
    [_mapView removeAnnotations:[_mapView annotations]];
    [_mapView removeOverlays:[_mapView overlays]];
    // Set 3359 Mississauga Rd as the default location
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(43.549139,-79.663281);
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance (coordinate, 20000, 20000);
    [_mapView setRegion:region animated:NO];
    // You have to generate the annotations again but only if we already
    // have all the map items (not the case when this method is called from viewDidLoad())
    if ([self mapItemsDidFinishLoading])
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
    // Allow address listing to not be editable
    [_tableView setEditing:NO animated:YES];
    // Clear all markers and routes from the map
    [_mapView removeAnnotations:[_mapView annotations]];
    [_mapView removeOverlays:[_mapView overlays]];
    // Display the current location of the user
    MKUserLocation *userLocation = _mapView.userLocation;
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance (userLocation.location.coordinate, 2000, 2000);
    [_mapView setRegion:region animated:NO];
}

// Launch the native Maps application with all the locations
- (IBAction)openInMapsPressed:(UIButton *)sender
{
    if ([self mapItemsDidFinishLoading])
    {
        [MKMapItem openMapsWithItems:_mapItems launchOptions:nil];
    }
}

- (IBAction)customRoutePressed:(UIButton *)sender
{
    _currentLocationView = NO;
    _optimalRouteView = NO;
    _customRouteView = YES;
    // Allow address listing to be editable
    [_tableView setEditing:YES animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _addresses.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Height of the table cell background image
    return 140;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyIdentifier"];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"MyIdentifier"];
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    }
    cell.textLabel.text = [_addresses objectAtIndex:indexPath.row];
    cell.textLabel.font = [UIFont fontWithName:@"Arial-BoldMT" size:15];
    cell.textLabel.numberOfLines = 4;
    [cell.textLabel sizeToFit];
    cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tablecell.png"]];
    cell.showsReorderControl = YES;
    return cell;
}
    
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // What do we want to show if the user selects a location?
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    if (fromIndexPath != toIndexPath)
    {
        // Clear all markers and routes from the map
        [_mapView removeAnnotations:[_mapView annotations]];
        [_mapView removeOverlays:[_mapView overlays]];
        // Update the _addresses array for the relocated row
        NSString *address = (NSString *)[_addresses objectAtIndex:fromIndexPath.row];
        [_addresses removeObjectAtIndex:fromIndexPath.row];
        [_addresses insertObject:address atIndex:toIndexPath.row];
        // Update the _mapItems array for the relocated row
        MKMapItem *item = (MKMapItem *)[_mapItems objectAtIndex:fromIndexPath.row];
        [_mapItems removeObjectAtIndex:fromIndexPath.row];
        [_mapItems insertObject:item atIndex:toIndexPath.row];
        // The optimal route will use this ordering as well (going to change this soon!)
        [self optimizedRoutePressed:nil];
        // This ensures that edit controls have been removed from all visible cells
        [_tableView reloadData];
    }
}

// Custom method for checking that we have fully populated
// the _mapItems array
- (BOOL)mapItemsDidFinishLoading
{
    BOOL didFinishLoading = YES;
    for (id item in _mapItems)
    {
        if ([item isKindOfClass:[NSNull class]])
        {
            didFinishLoading = NO;
            break;
        }
    }
    return didFinishLoading;
}

@end
