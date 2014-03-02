//
//  ECViewController.h
//  encompass
//
//  Created by Dilip Muthukrishnan on 2014-02-28.
//  Copyright (c) 2014 encompass. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface ECViewController : UIViewController <MKMapViewDelegate>
{
    NSArray *_addresses;
    NSMutableArray *_mapItems;
    BOOL _currentLocationView;
    BOOL _optimalRouteView;
    BOOL _customRouteView;
    int _mapItemIndex;
}

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;


- (void)searchLocationsUsingString:(NSString *)query;
- (void)generateAnnotationForMapItem:(MKMapItem *)item;
- (void)calculateBestRoute;
- (void)drawPolylineOnMap:(MKDirectionsResponse *)response
- (NSString *)getCurrentDateString;
- (IBAction)optimizedRoutePressed:(UIButton *)sender;
- (IBAction)currentLocationPressed:(UIButton *)sender;

@end
