//
//  ECViewController.m
//  encompass
//
//  Created by Darren Spriet on 2014-02-26.
//  Copyright (c) 2014 encompass. All rights reserved.
//

#import "ECViewController.h"
#import "CalendarItemAdvanced.h"
#import "MAEvent.h"

@interface ECViewController ()

@end


@implementation ECViewController


@synthesize launchMaps;


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setUpEventsForMapWithDay:self.selectedDate];

    
    _mapView.delegate = self;
    
    NSDate *currentDate = self.selectedDate;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMMM-d"];
    NSString *localDateString = [dateFormatter stringFromDate:currentDate];
    [self.lblDate setText:[NSString stringWithFormat:@"%@", localDateString]];
    
    timeFormeter = [[NSDateFormatter alloc] init];
    [timeFormeter setTimeStyle: NSDateFormatterShortStyle];
    
    [NSTimer scheduledTimerWithTimeInterval:1.0
                                     target:self
                                   selector:@selector(targetMethod:)
                                   userInfo:nil
                                    repeats:YES];
    
    [self adjustMapAndLocationsForNewDate];


}

-(void)setUpEventsForMapWithDay:(NSDate*)day{
    NSLog(@"day is: %@", day);
    _addressesOptimal =[[NSMutableArray alloc]init];
    for (CalendarItemAdvanced *item in self.collectionData)
    {
        if (item.date) {
            
            NSComparisonResult result;
            //has three possible values: NSOrderedSame,NSOrderedDescending, NSOrderedAscending
            
            result = [day compare:item.date];
            if (result==NSOrderedSame)
            {
                NSLog(@"selected date");
                for (MAEvent *event in item.entries) {
                    [_addressesOptimal addObject:event.title];
                }
            }
        }
    }
}

-(void)adjustMapAndLocationsForNewDate
{
    self.lblDistance.text = @"0 Km";
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
    
    //If the addresses are not bigger than 0 then we don't search for any locations
    if ([_addressesOptimal count]>0)
    {
        // Get the MKMapItems for each address, store them in the array, and
        // generate annotations for each item on the map.
        [self searchLocationsWithQueries:_addressesOptimal];
    }
}

-(void)targetMethod:(id)sender
{
    
    NSString *currentTime = [timeFormeter stringFromDate: [NSDate date]];
    self.lblTime.text = currentTime;
}

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
                if (_locationCount>1) {
                    [self calculateBestRoute:_mapItemsOptimal];

                }
            }
        }
    }];
}


-(void)setDateLabel:(NSDate *)date{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    dateFormatter.dateFormat=@"MMMM";
    NSString * monthString = [[dateFormatter stringFromDate:date] capitalizedString];
    dateFormatter.dateFormat=@"d";
    NSString * dayString = [[dateFormatter stringFromDate:date] capitalizedString];
    [self.lblDate setText:[NSString stringWithFormat:@"%@ %@", monthString, dayString]];
    // NSString *localDateString = [dateFormatter stringFromDate:currentDate];
    //[self.lblDate setText:[NSString stringWithFormat:@"%@", localDateString]];
}

- (IBAction)OnDateForward:(UIButton *)sender {
    _dateCounter++;
    NSDate *currentDate = self.selectedDate;
    int daysToAdd = _dateCounter;
    NSDate *date = [currentDate dateByAddingTimeInterval:60*60*24*daysToAdd];
    [self setUpEventsForMapWithDay:date];
    [self adjustMapAndLocationsForNewDate];
    [self.tableView reloadData];
    [self  setDateLabel:date];
}

- (IBAction)OnDateBackward:(UIButton *)sender {
    _dateCounter--;
    NSDate *currentDate = self.selectedDate;
    int daysToAdd = _dateCounter;
    NSDate *date = [currentDate dateByAddingTimeInterval:60*60*24*daysToAdd];
    [self setUpEventsForMapWithDay:date];
    [self adjustMapAndLocationsForNewDate];
    [self.tableView reloadData];
    [self  setDateLabel:date];
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

// This method is called everytime a polyline needs to be drawn
- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id < MKOverlay >)overlay
{
    MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc] initWithOverlay:overlay];
    renderer.strokeColor = [UIColor blueColor];
    renderer.lineWidth = 3.0;
    return renderer;
}


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
        if ([_mapItemsOptimal count]>0) {
            // We need to calculate the route again
            [self calculateBestRoute:_mapItemsOptimal];
        }

    }
}

- (IBAction)calendarSelected:(UIButton *)sender {
        [self dismissViewControllerAnimated:YES completion:nil];
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


// Set 3359 Mississauga Rd as the default location
- (void)setDefaultMapRegion
{
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(43.549139,-79.663281);
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance (coordinate, 20000, 20000);
    [_mapView setRegion:region animated:NO];
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    // Do something when the user changes the location
}

-(IBAction)OpenInMapsPressed:(UIButton *)sender
{
    [MKMapItem openMapsWithItems:nil launchOptions:nil];
}


- (IBAction)menuShow:(UIButton *)sender {
    if (sender.tag == 0) {
        sender.tag = 1;
        self.menuView.hidden = NO;
        [sender setTitle:@"Options                 ▲" forState:UIControlStateNormal];
    } else {
        sender.tag = 0;
        self.menuView.hidden = YES;
        [sender setTitle:@"Options                 ▼" forState:UIControlStateNormal];
    }
}

- (IBAction)MenuItemSelected:(UIButton *)sender {
    switch (sender.tag) {
        case 1:
            if (sender.selected==YES) {
                sender.selected = NO;
                UIView *ViewTag = (UIView*)[self.view viewWithTag:7];
                ViewTag.backgroundColor = [UIColor whiteColor];
            }else{
                sender.selected=YES;
                UIButton *ButtonTag = (UIButton*)[self.view viewWithTag:2];
                ButtonTag.selected=NO;
                UIView *NumTag = (UIView*)[self.view viewWithTag:8];
                NumTag.backgroundColor = [UIColor whiteColor];
                UIView *ViewTag = (UIView*)[self.view viewWithTag:7];
                ViewTag.backgroundColor = [UIColor greenColor];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"All Notes" message:@"Call 1 - Take papers from last visit \nCall 2 - Bring sample for client" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
                
            }
            break;
        case 2:
            if (sender.selected==YES) {
                sender.selected = NO;
                UIView *ViewTag = (UIView*)[self.view viewWithTag:8];
                ViewTag.backgroundColor = [UIColor whiteColor];
            }else{
                sender.selected=YES;
                UIButton *ButtonTag = (UIButton*)[self.view viewWithTag:1];
                ButtonTag.selected=NO;
                UIView *NumTag = (UIView*)[self.view viewWithTag:7];
                NumTag.backgroundColor = [UIColor whiteColor];
                UIView *ViewTag = (UIView*)[self.view viewWithTag:8];
                ViewTag.backgroundColor = [UIColor greenColor];
            }
            
            break;
        case 3:
            
            if (sender.selected==YES) {
                sender.selected = NO;
                UIView *ViewTag = (UIView*)[self.view viewWithTag:9];
                ViewTag.backgroundColor = [UIColor whiteColor];
            }else{
                sender.selected=YES;
                UIButton *ButtonTag = (UIButton*)[self.view viewWithTag:4];
                ButtonTag.selected=NO;
                UIView *NumTag = (UIView*)[self.view viewWithTag:10];
                NumTag.backgroundColor = [UIColor whiteColor];
                UIView *ViewTag = (UIView*)[self.view viewWithTag:9];
                ViewTag.backgroundColor = [UIColor greenColor];
            }
            
            
            break;
        case 4:
            if (sender.selected==YES) {
                sender.selected = NO;
                UIView *ViewTag = (UIView*)[self.view viewWithTag:10];
                ViewTag.backgroundColor = [UIColor whiteColor];
            }else{
                sender.selected=YES;
                UIButton *ButtonTag = (UIButton*)[self.view viewWithTag:3];
                ButtonTag.selected=NO;
                UIView *NumTag = (UIView*)[self.view viewWithTag:9];
                NumTag.backgroundColor = [UIColor whiteColor];
                UIView *ViewTag = (UIView*)[self.view viewWithTag:10];
                ViewTag.backgroundColor = [UIColor greenColor];
            }
            
            break;
        case 5:
            if (sender.selected==YES) {
                sender.selected = NO;
                UIView *ViewTag = (UIView*)[self.view viewWithTag:11];
                ViewTag.backgroundColor = [UIColor whiteColor];
            }else{
                sender.selected=YES;
                UIView *ViewTag = (UIView*)[self.view viewWithTag:11];
                ViewTag.backgroundColor = [UIColor greenColor];
            }
            break;
        case 6:
            if (sender.selected==YES) {
                sender.selected = NO;
                UIView *ViewTag = (UIView*)[self.view viewWithTag:12];
                ViewTag.backgroundColor = [UIColor whiteColor];
            }else{
                sender.selected=YES;
                UIView *ViewTag = (UIView*)[self.view viewWithTag:12];
                ViewTag.backgroundColor = [UIColor greenColor];
            }
            break;
            
        default:
            break;
    }
}

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

- (void)generateAnnotationForMapItem:(MKMapItem *)item
{
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    annotation.coordinate = item.placemark.coordinate;
    annotation.title = item.name;
    [_mapView addAnnotation:annotation];
}


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
            // Increment the total distance label
            int distance = [self.lblDistance.text intValue];
            distance += (int)([(MKRoute *)[response.routes firstObject] distance]/1000);
            self.lblDistance.text = [NSString stringWithFormat:@"%d Km", distance];
            NSLog(@"Distance of this route = %d", (int)[(MKRoute *)[response.routes firstObject] distance]/1000);
            NSLog(@"Time of this route = %d", (int)[(MKRoute *)[response.routes firstObject] expectedTravelTime]/60);
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




- (IBAction)back:(UIButton *)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
