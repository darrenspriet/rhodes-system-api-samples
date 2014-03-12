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
    
    [self.mapView setDelegate:self];
    
    _addresses = [[NSMutableArray alloc] initWithObjects:@"Best Buy \n6075 Mavis Road                      \nMississauga, ON \nL5H 2M9",
                  @"Future Shop \n2975 Argentia Road \nMississauga, ON \nL6H 2W2",
                  @"Staples \n2460 Winston Churchill Boulevard \nOakville, ON \nL7M 3T2",
                  @"Trinbago Barbershop \n2547 Hurontario Street \nMississauga, ON, \nL5A 2G4",
                  @"Best Buy \n2500 Winston Park Dr \nOakville, ON, \nL6H 7E5",
                  nil];
    
    _mapItems = [[NSMutableArray alloc] initWithCapacity:4];
    _mapItemIndex = 0;
    
    [self optimizedRoutePressed:nil];
    
    for (NSString *address in _addresses)
    {
        [self searchLocationsUsingString:address];
    }
    
    self.tableViewCell = [[ECTableViewCell alloc]init];
    
    UIButton *ButtonTag = (UIButton*)[self.view viewWithTag:1];
    ButtonTag.selected=YES;
    NSDate *date = [[NSDate alloc]init];
    _dateCounter = 0;
    [self  setDateLabel:date];
}

-(void)setDateLabel:(NSDate *)date{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init]; // here we create NSDateFormatter object for change the Format of
    dateFormatter.dateFormat=@"MMMM";
    NSString * monthString = [[dateFormatter stringFromDate:date] capitalizedString];
    dateFormatter.dateFormat=@"d";
    NSString * dayString = [[dateFormatter stringFromDate:date] capitalizedString];
    [self.lblDate setText:[NSString stringWithFormat:@"%@ %@", monthString, dayString]];
}

-(BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return NO;
}

- (void)searchLocationsUsingString:(NSString *)query
{
    MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc] init];
    request.naturalLanguageQuery = query;
    MKCoordinateRegion searchRegion = MKCoordinateRegionMakeWithDistance (self.mapView.region.center, 20000, 20000);
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
         // If our search yields multiple results (this shouldn't happen
         // in this application because we are only searching addresses)
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
         if (_mapItems.count == _addresses.count)
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
    [self.mapView addAnnotation:annotation];
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
        [self.mapView addOverlay:route.polyline level:MKOverlayLevelAboveRoads];
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
    // Clear all annotations from the map
    [_mapView removeAnnotations:[_mapView annotations]];
    // Set 3359 Mississauga Rd as the default location
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(43.573434,-79.702564);
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance (coordinate, 20000, 20000);
    [self.mapView setRegion:region animated:NO];
    // You have to generate the annotations again but only if we already
    // have all the map items (not the case when this method is called from viewDidLoad()
    if (_mapItems.count == _addresses.count)
    {
        for (MKMapItem *item in _mapItems)
        {
            [self generateAnnotationForMapItem:item];
        }
        // We need to calculate the route again
        [self calculateBestRoute];
    }
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}\

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Height of the table cell background image
    return 140;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MyCell";
    
    ECTableViewCell *cell = (ECTableViewCell*)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"MyCell"];
	}
    [cell setBackgroundColor:[UIColor clearColor]];
    //Rotates the table that is in the cell so now the table is going horizontal
    CGAffineTransform rotateTable = CGAffineTransformMakeRotation(-M_PI_2);
    [cell.horizontalTableView setTransform:rotateTable];
    [cell.horizontalTableView setFrame: CGRectMake(0, 0, cell.horizontalTableView.frame.size.width, cell.horizontalTableView.frame.size.height)];
    
    [cell setAddresses: [NSMutableArray arrayWithArray:_addresses]];
    [cell.horizontalTableView setAllowsSelection:YES];
    [cell.selectedBackgroundView setBackgroundColor:[UIColor clearColor]];
    [self setDelegate:cell];
    return cell;
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)OpenInMapsPressed:(UIButton *)sender {
    [MKMapItem openMapsWithItems:_mapItems launchOptions:nil];

}


- (IBAction)menuShow:(UIButton *)sender {
    if (sender.tag == 0) {
        sender.tag = 1;
        self.menuViewTwo.hidden = NO;
        [sender setTitle:@"Options                 ▲" forState:UIControlStateNormal];
    } else {
        sender.tag = 0;
        self.menuViewTwo.hidden = YES;
        [sender setTitle:@"Options                 ▼" forState:UIControlStateNormal];
    }
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if ([segue.identifier isEqualToString:@"containerSegue"]){
        [(ECOptionsTableViewController*)segue.destinationViewController setDelegate:self];
    }
}
-(void)changeToCustomized{
    [self.delegate changeToCustomized];
}
-(void)changeToOptimized{
    [self.delegate changeToOptimized];
}

- (IBAction)MenuItemSelected:(UIButton *)sender {
    if (sender.tag<5) {
        if (sender.selected==YES) {
            sender.selected=NO;
        }
    }
    
    switch (sender.tag) {
        case 1:
            if (sender.selected==NO) {
                sender.selected=YES;
                UIButton *ButtonTag = (UIButton*)[self.view viewWithTag:2];
              //  NSLog(@"this is the button %@", ButtonTag);
               [ButtonTag setSelected:NO];
                UIView *NumTag = (UIView*)[self.view viewWithTag:8];
                NumTag.backgroundColor = [UIColor whiteColor];
                UIView *ViewTag = (UIView*)[self.view viewWithTag:7];
                ViewTag.backgroundColor = [UIColor greenColor];
            }

            break;
        case 2:
            if (sender.selected==NO) {
               // UIButton *button = sender;
                sender.selected=YES;
                UIButton *ButtonTag = (UIButton*)[self.view viewWithTag:1];
               // NSLog(@"this is the button %@", ButtonTag);
                [ButtonTag setSelected:NO];
                UIView *NumTag = (UIView*)[self.view viewWithTag:7];
                NumTag.backgroundColor = [UIColor whiteColor];
                UIView *ViewTag = (UIView*)[self.view viewWithTag:8];
                ViewTag.backgroundColor = [UIColor greenColor];
            }

            break;
        case 3:

            if (sender.selected==NO){
                if ([self.delegate isTableEditible]) {
                    [self.delegate changeToOptimized];
                }
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
            if (sender.selected==NO){
                [self.delegate changeToCustomized];
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

- (IBAction)OnDateForward:(UIButton *)sender {
    _dateCounter++;
    [self ForBothChangesOfDates];
}

- (IBAction)OnDateBackward:(UIButton *)sender {
    _dateCounter--;
    [self ForBothChangesOfDates];
}

-(void)ForBothChangesOfDates{
    NSDate *now = [NSDate date];
    int daysToAdd = _dateCounter;
    NSDate *date = [now dateByAddingTimeInterval:60*60*24*daysToAdd];
    [self  setDateLabel:date];
    [_mapView removeOverlays:_mapView.overlays];
    
    NSArray *existingpoints = _mapView.annotations;
    
    if ([existingpoints count])
        [_mapView removeAnnotations:existingpoints];
    
    _addresses = [self.delegate changeAddressesOrder];
    _mapItemIndex = 0;
    NSLog(@"address lenght %d", [_addresses count]);
    if ([_addresses count]!=5) {
        [self.lblTime setText: @"1hr 35min"];
        [self.lblDistance setText: @"100km"];
        _mapItems = [[NSMutableArray alloc] initWithCapacity:5];
        
    }
    else{
        [self.lblTime setText: @"2hr 10min"];
        [self.lblDistance setText: @"65 km"];
        _mapItems = [[NSMutableArray alloc] initWithCapacity:4];
        
    }
    
    for (NSString *address in _addresses)
    {
        [self searchLocationsUsingString:address];
    }
}

- (IBAction)OnTodaysNotesPressed:(UIButton *)sender {
    
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Encompass" message:@"Your Notes For the Day " delegate:Nil cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    [alert show];
}

- (IBAction)OnColdCallPressed:(UIButton *)sender {
    
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Encompass" message:@"Your Cold Call Starting Point " delegate:Nil cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    [alert show];
}
@end
