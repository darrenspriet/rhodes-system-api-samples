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
    // Store the dummy addresses in the optimal addresses array
    _addressesOptimal = [[NSMutableArray alloc] initWithObjects:@"Best Buy \n6075 Mavis Road \nMississauga, ON \nL5H 2M9",
                                                @"Future Shop \n2975 Argentia Road \nMississauga, ON \nL6H 2W2",
                                                @"Staples \n2460 Winston Churchill Boulevard \nOakville, ON \nL7M 3T2",
                                                @"Trinbago Barbershop \n2547 Hurontario Street \nMississauga, ON \nL5A 2G4",
                                                @"Rattray Marsh \n600-798 Nautalex Crt \nMississauga, ON \nL5H 1A7",
                                                nil];
    _locationCount = (int)_addressesOptimal.count;
    _addressesCustom = [[NSMutableArray alloc] init];
    // Copy the optimal addresses array into the custom addresses array
    for (NSString *address in _addressesOptimal)
    {
        [_addressesCustom addObject:address];
    }
    _mapItemsOptimal = [[NSMutableArray alloc] init];
    _mapItemsCustom = [[NSMutableArray alloc] init];
    // Need to do this to allow non-sequential inertion during location search
    // because NSMutableArray objects never contain free spaces (except at the end)
    for (int i = 0; i < _locationCount; i++)
    {
        [_mapItemsOptimal addObject:[NSNull null]];
        [_mapItemsCustom addObject:[NSNull null]];
    }
    _locationIndex = 0;
    // We need to call this to set the map region
    [self optimizedRoutePressed:nil];
    // Get the MKMapItems for each address, store them in the array, and
    // generate annotations for each item on the map.
    [self searchLocationsWithQueries:_addressesOptimal];
}


#pragma mark Custom Methods
// Called recursively to obtain all the map items for the given addresses
- (void)searchLocationsWithQueries:(NSArray *)queries
{
    MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc] init];
    request.naturalLanguageQuery = (NSString *)[queries objectAtIndex:_locationIndex];
    MKCoordinateRegion searchRegion = MKCoordinateRegionMakeWithDistance (_mapView.region.center, 20000, 20000);
    request.region = searchRegion;
    MKLocalSearch *search = [[MKLocalSearch alloc] initWithRequest:request];
    // This search will be asynchronous!
    [search startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error)
    {
        // No internet connection, perhaps?
        if (error)
        {
            NSString *message = @"Unable to reach Apple's servers!  Please check your internet connection.";
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Connection Error" message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            _locationIndex = 0;
            // Remove all annotations from the map and clear the map item arrays
            [_mapView removeAnnotations:[_mapView annotations]];
            for (int i = 0; i < _locationCount; i++)
            {
                [_mapItemsOptimal addObject:[NSNull null]];
                [_mapItemsCustom addObject:[NSNull null]];
            }
        }
        else
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
                // This ensures that both optimal and custom arrays are populated simultaenously.
                [_mapItemsOptimal replaceObjectAtIndex:_locationIndex withObject:item];
                [_mapItemsCustom replaceObjectAtIndex:_locationIndex withObject:item];
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
            // Search for another address, if there is one
            _locationIndex++;
            if (_locationIndex < _locationCount)
            {
                [self searchLocationsWithQueries:queries];
            }
            else
            {
                _locationIndex = 0;
                [self calculateBestRoute:_mapItemsOptimal];
            }
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
- (void)calculateBestRoute:(NSArray *)mapItems
{
    MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
    request.source = (MKMapItem *)[mapItems objectAtIndex:_locationIndex];
    request.destination = (MKMapItem *)[mapItems objectAtIndex:_locationIndex+1];
    request.requestsAlternateRoutes = NO;
    MKDirections *directions = [[MKDirections alloc] initWithRequest:request];
    // This search will be asynchronous!
    [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error)
     {
         if (error)
         {
             NSString *message = @"Unable to reach Apple's servers!  Please check your internet connection.";
             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Connection Error" message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
             [alert show];
             _locationIndex = 0;
             // Erase any routes that we may have already found
             [_mapView removeOverlays:[_mapView overlays]];
         }
         else
         {
             [self drawPolylineOnMap:response];
             _locationIndex++;
             if (_locationIndex < _locationCount-1)
             {
                 [self calculateBestRoute:mapItems];
             }
             else
             {
                 _locationIndex = 0;
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

// Set 3359 Mississauga Rd as the default location
- (void)setDefaultMapRegion
{
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(43.549139,-79.663281);
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance (coordinate, 20000, 20000);
    [_mapView setRegion:region animated:NO];
}


#pragma mark Button Methods

- (IBAction)optimizedRoutePressed:(UIButton *)sender
{
    _currentLocationView = NO;
    _optimalRouteView = YES;
    _customRouteView = NO;
    // Allow address listing to not be editable
    [_tableView setEditing:NO animated:YES];
    // Refresh the table view
    [_tableView reloadData];
    // Clear all markers and routes from the map
    [_mapView removeAnnotations:[_mapView annotations]];
    [_mapView removeOverlays:[_mapView overlays]];
    [self setDefaultMapRegion];
    // You have to generate the annotations again but only if we already
    // have all the map items (not the case when this method is called from viewDidLoad())
    if ([self mapItemsDidFinishLoading])
    {
        for (MKMapItem *item in _mapItemsOptimal)
        {
            [self generateAnnotationForMapItem:item];
        }
        // We need to calculate the route again
        [self calculateBestRoute:_mapItemsOptimal];
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
    // Refresh the table view
    [_tableView reloadData];
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
        [MKMapItem openMapsWithItems:_mapItemsOptimal launchOptions:nil];
    }
}

- (IBAction)customRoutePressed:(UIButton *)sender
{
    _currentLocationView = NO;
    _optimalRouteView = NO;
    _customRouteView = YES;
    // Allow address listing to be editable
    [_tableView setEditing:YES animated:YES];
    // Refresh the table view
    [_tableView reloadData];
    // Clear all markers and routes from the map
    [_mapView removeAnnotations:[_mapView annotations]];
    [_mapView removeOverlays:[_mapView overlays]];
    [self setDefaultMapRegion];
    // You have to generate the annotations again but only if we already
    // have all the map items
    if ([self mapItemsDidFinishLoading])
    {
        for (MKMapItem *item in _mapItemsCustom)
        {
            [self generateAnnotationForMapItem:item];
        }
        // We need to calculate the route again
        [self calculateBestRoute:_mapItemsCustom];
    }
}


#pragma mark Convenience Methods

- (NSString *)getCurrentDateString
{
    NSDate *currDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"MM.dd.YYYY"];
    NSString *dateString = [dateFormatter stringFromDate:currDate];
    return dateString;
}

// Custom method for checking that we have fully populated
// the optimal _mapItems array (the custom array was populated at the same
// time so we shouldn't need to check that).
- (BOOL)mapItemsDidFinishLoading
{
    BOOL didFinishLoading = YES;
    for (id item in _mapItemsOptimal)
    {
        if ([item isKindOfClass:[NSNull class]])
        {
            didFinishLoading = NO;
            break;
        }
    }
    return didFinishLoading;
}


#pragma mark MKMapViewDelegate Protocol Methods

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


#pragma mark UITableView Protocol Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _locationCount;
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
    // Use an appropriate data source
    if (_optimalRouteView || _currentLocationView)
    {
        cell.textLabel.text = [_addressesOptimal objectAtIndex:indexPath.row];
    }
    else
    {
        cell.textLabel.text = [_addressesCustom objectAtIndex:indexPath.row];
    }
    cell.textLabel.font = [UIFont fontWithName:@"Arial-BoldMT" size:15];
    cell.textLabel.numberOfLines = 5;
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

// Disables row deletion while in edit mode
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleNone;
}

// Prevents indenting the cells while in edit mode
- (BOOL)tableView:(UITableView *)tableview shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    if (fromIndexPath != toIndexPath)
    {
        // Clear all markers and routes from the map
        [_mapView removeAnnotations:[_mapView annotations]];
        [_mapView removeOverlays:[_mapView overlays]];
        // Update the appropriate _addresses array for the relocated row
        if (_optimalRouteView || _currentLocationView)
        {
            NSString *address = (NSString *)[_addressesOptimal objectAtIndex:fromIndexPath.row];
            [_addressesOptimal removeObjectAtIndex:fromIndexPath.row];
            [_addressesOptimal insertObject:address atIndex:toIndexPath.row];
        }
        else
        {
            NSString *address = (NSString *)[_addressesCustom objectAtIndex:fromIndexPath.row];
            [_addressesCustom removeObjectAtIndex:fromIndexPath.row];
            [_addressesCustom insertObject:address atIndex:toIndexPath.row];
        }
        // Update the appropriate _mapItems array for the relocated row
        if (_optimalRouteView || _currentLocationView)
        {
            MKMapItem *item = (MKMapItem *)[_mapItemsOptimal objectAtIndex:fromIndexPath.row];
            [_mapItemsOptimal removeObjectAtIndex:fromIndexPath.row];
            [_mapItemsOptimal insertObject:item atIndex:toIndexPath.row];
        }
        else
        {
            MKMapItem *item = (MKMapItem *)[_mapItemsCustom objectAtIndex:fromIndexPath.row];
            [_mapItemsCustom removeObjectAtIndex:fromIndexPath.row];
            [_mapItemsCustom insertObject:item atIndex:toIndexPath.row];
        }
        // Clear all markers and routes from the map
        [_mapView removeAnnotations:[_mapView annotations]];
        [_mapView removeOverlays:[_mapView overlays]];
        // You have to generate the annotations again but only if we already
        // have all the map items (not the case when this method is called from viewDidLoad())
        if ([self mapItemsDidFinishLoading])
        {
            for (MKMapItem *item in _mapItemsCustom)
            {
                [self generateAnnotationForMapItem:item];
            }
            // We need to calculate the route again
            [self calculateBestRoute:_mapItemsCustom];
        }
    }
}

@end
