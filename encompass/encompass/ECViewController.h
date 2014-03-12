//
//  ECViewController.h
//  encompass
//
//  Created by Darren Spriet on 2014-02-26.
//  Copyright (c) 2014 encompass. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@class ECViewController;

@interface ECViewController : UIViewController <MKMapViewDelegate, UITableViewDelegate, UITableViewDataSource>
{
    NSMutableArray *_addressesOptimal;
    NSMutableArray *_mapItemsOptimal;
    NSMutableArray *_addressesCustom;
    NSMutableArray *_mapItemsCustom;
    BOOL _currentLocationView;
    BOOL _optimalRouteView;
    BOOL _customRouteView;
    int _locationIndex;
    int _locationCount;
    int _dateCounter;
    
    NSDateFormatter *timeFormeter;
}
- (IBAction)back:(UIButton *)sender;


@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UILabel *lblDate;
@property (weak, nonatomic) IBOutlet UILabel *lblTime;

- (IBAction)optimizedRoutePressed:(UIButton *)sender;

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
-(IBAction)OpenInMapsPressed:(UIButton *)sender;

@property (weak, nonatomic) IBOutlet UIButton *launchMaps;

@property (weak, nonatomic) IBOutlet UIView *menuView;

- (IBAction)customRoutePressed:(UIButton *)sender;

- (IBAction)MenuItemSelected:(UIButton *)sender;

- (IBAction)menuShow:(UIButton *)sender;
@end
