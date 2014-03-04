//
//  ECViewController.h
//  encompass
//
//  Created by Darren Spriet on 2014-02-26.
//  Copyright (c) 2014 encompass. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "ECTableViewCell.h"
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
@property (nonatomic, retain) IBOutlet ECTableViewCell *tableViewCell;
@property (nonatomic, retain) IBOutlet UITableView *tableView;

@end
