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




@end
