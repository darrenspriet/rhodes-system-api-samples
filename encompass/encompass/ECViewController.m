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
    _addressesOptimal = [[NSMutableArray alloc] init];
    _addressesCustom = [[NSMutableArray alloc] init];
    _mapItemsOptimal = [[NSMutableArray alloc] init];
    _mapItemsCustom = [[NSMutableArray alloc] init];
    // Populate the above arrays using the local database
    [self populateArraysFromDatabase];
    _locationCount = (int)_addressesOptimal.count;
    _locationIndex = 0;
    // We need to call this to set the map region.
    // It will also calculate the route and generate the annotations.
    [self optimizedRoutePressed:nil];
}


#pragma mark Custom Methods

// Connect to the local databse and populate the addresses and map items arrays
- (void)populateArraysFromDatabase
{
    NSString *databasePath = [[NSBundle mainBundle] pathForResource:@"encompass"
                                                             ofType:@"sqlite"];
    if (sqlite3_open([databasePath UTF8String], &databaseHandle) != SQLITE_OK)
    {
        // Hopefully, this never happens!
        NSLog(@"Failed to open database!");
    }
    // Load the data from the Account table
    NSString *queryStatement = [NSString stringWithFormat:@"SELECT * FROM account"];
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(databaseHandle, [queryStatement UTF8String], -1, &statement, NULL) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            // Get the raw field data
            char *nameChars = (char *) sqlite3_column_text(statement, 1);
            NSString *name = [[NSString alloc] initWithUTF8String:nameChars];
            char *addressChars = (char *) sqlite3_column_text(statement, 2);
            NSString *address = [[NSString alloc] initWithUTF8String:addressChars];
            char *cityChars = (char *) sqlite3_column_text(statement, 3);
            NSString *city = [[NSString alloc] initWithUTF8String:cityChars];
            char *provChars = (char *) sqlite3_column_text(statement, 4);
            NSString *prov = [[NSString alloc] initWithUTF8String:provChars];
            char *postalChars = (char *) sqlite3_column_text(statement, 5);
            NSString *postal = [[NSString alloc] initWithUTF8String:postalChars];
            double longitude = sqlite3_column_double(statement, 6);
            double latitude = sqlite3_column_double(statement, 7);
            // Build the full address string and add it to the addresses arrays
            NSString *fullAddress = [NSString stringWithFormat:@"%@\n%@\n%@, %@\n%@",
                                     name, address, city, prov, postal];
            [_addressesOptimal addObject:fullAddress];
            [_addressesCustom addObject:fullAddress];
            // Create the map item object and add it to the map items arrays
            CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude, longitude);
            MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:coordinate
                                                           addressDictionary:nil];
            MKMapItem *item = [[MKMapItem alloc] initWithPlacemark:placemark];
            item.name = address;
            [_mapItemsOptimal addObject:item];
            [_mapItemsCustom addObject:item];
        }
    }
    sqlite3_close(databaseHandle);
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
             NSString *message = error.localizedFailureReason;
             NSString *title = error.localizedDescription;
             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
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
    _mapView.showsUserLocation = NO;
    // You have to generate the annotations and calculate the route again
    for (MKMapItem *item in _mapItemsCustom)
    {
        [self generateAnnotationForMapItem:item];
    }
    [self calculateBestRoute:_mapItemsOptimal];
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
    _mapView.showsUserLocation = YES;
    // Display the current location of the user
    MKUserLocation *userLocation = _mapView.userLocation;
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance (userLocation.location.coordinate, 2000, 2000);
    [_mapView setRegion:region animated:NO];
}

// Launch the native Maps application with all the locations
- (IBAction)openInMapsPressed:(UIButton *)sender
{
    [MKMapItem openMapsWithItems:_mapItemsOptimal launchOptions:nil];
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
    _mapView.showsUserLocation = NO;
    // You have to generate the annotations and calculate the route again
    for (MKMapItem *item in _mapItemsCustom)
    {
        [self generateAnnotationForMapItem:item];
    }
    [self calculateBestRoute:_mapItemsCustom];
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
        // You have to generate the annotations and calculate the route again
        for (MKMapItem *item in _mapItemsCustom)
        {
            [self generateAnnotationForMapItem:item];
        }
        [self calculateBestRoute:_mapItemsCustom];
    }
}

@end
