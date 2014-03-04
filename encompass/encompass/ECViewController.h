//
//  ECViewController.h
//  encompass
//
//  Created by Dilip Muthukrishnan on 2014-02-28.
//  Copyright (c) 2014 encompass. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface ECViewController : UIViewController <MKMapViewDelegate, UITableViewDataSource, UITableViewDelegate>
{
    NSMutableArray *_addresses;
    NSMutableArray *_mapItems;
    BOOL _currentLocationView;
    BOOL _optimalRouteView;
    BOOL _customRouteView;
    int _mapItemIndex;
}

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (void)searchLocationsUsingString:(NSString *)query;
- (void)generateAnnotationForMapItem:(MKMapItem *)item;
- (void)calculateBestRoute;
- (void)drawPolylineOnMap:(MKDirectionsResponse *)response;
- (NSString *)getCurrentDateString;
- (IBAction)optimizedRoutePressed:(UIButton *)sender;
- (IBAction)currentLocationPressed:(UIButton *)sender;
- (IBAction)openInMapsPressed:(UIButton *)sender;
- (IBAction)customRoutePressed:(UIButton *)sender;

@end
