//
//  ECViewController.h
//  encompass
//
//  Created by Dilip Muthukrishnan on 2014-02-28.
//  Copyright (c) 2014 encompass. All rights reserved.
//

// TODO:
//  1.  Always plot route from current location.  Only refresh the map view if one of the buttons
//      is pressed or location ordering is changed while in custom route view.
//  2.  Create enum variables for the three different modes.
//  3.  Come up with a better routing algorithm.  This means that locations will have to be reordered
//      appropriately in the optimized route view before drawing the polylines on the map.
//  4.  When in custom route view, change "Locations" label and button color to indicate the current mode
//      and also what actions need to be performed.
//  5.  Pass routing information as well to Apple Maps.
//  6.  Build an option into custom view that can allow/disallow toll routes.
//  7.  Pull addresses from plist file.
//  8.  Create a single "location" object that pairs each address with its map item.
//  9.  Do something when a row is selected!
//  10. Dyamically determine the map view region based on the locations.

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <sqlite3.h>

@interface ECViewController : UIViewController <MKMapViewDelegate, UITableViewDataSource, UITableViewDelegate>
{
    // We want to maintain two copies of each array for optimal
    // and custom routes
    NSMutableArray *_addressesOptimal;
    NSMutableArray *_mapItemsOptimal;
    NSMutableArray *_addressesCustom;
    NSMutableArray *_mapItemsCustom;
    BOOL _currentLocationView;
    BOOL _optimalRouteView;
    BOOL _customRouteView;
    int _locationIndex;
    int _locationCount;
    sqlite3 *databaseHandle;
    BOOL connectedToServer;
}

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (void)populateArraysFromDatabase;
- (void)generateAnnotationForMapItem:(MKMapItem *)item;
- (void)calculateBestRoute:(NSArray *)mapItems;
- (void)drawPolylineOnMap:(MKDirectionsResponse *)response;
- (NSString *)getCurrentDateString;
- (void)setDefaultMapRegion;
- (IBAction)optimizedRoutePressed:(UIButton *)sender;
- (IBAction)currentLocationPressed:(UIButton *)sender;
- (IBAction)openInMapsPressed:(UIButton *)sender;
- (IBAction)customRoutePressed:(UIButton *)sender;

@end
