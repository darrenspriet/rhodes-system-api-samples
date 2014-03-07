//
//  ECViewController.h
//  encompass
//
//  Created by Darren Spriet on 2014-02-26.
//  Copyright (c) 2014 encompass. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface ECViewController : UIViewController <MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
-(IBAction)OpenInMapsPressed:(UIButton *)sender;
- (IBAction)menuShow:(UIButton *)sender;
- (IBAction)MenuItemSelected:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIView *menuView;
@end
