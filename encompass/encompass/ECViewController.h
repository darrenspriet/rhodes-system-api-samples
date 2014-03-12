//
//  ECViewController.h
//  encompass
//
//  Created by Darren Spriet on 2014-02-26.
//  Copyright (c) 2014 encompass. All rights reserved.
//
@protocol ECViewControllerDelegate <NSObject>
-(void)changeToCustomized;
-(BOOL)isTableEditible;
-(void)changeToOptimized;
-(NSMutableArray *)changeAddressesOrder;
@end

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "ECTableViewCell.h"
#import "ECOptionsTableViewController.h"

@class ECTableViewCell;

@interface ECViewController : UIViewController <MKMapViewDelegate, UITableViewDataSource, UITableViewDelegate, ECOptionsTableViewControllerDelegate>
{
    NSMutableArray *_addresses;
    NSMutableArray *_mapItems;
    BOOL _currentLocationView;
    BOOL _optimalRouteView;
    BOOL _customRouteView;
    int _mapItemIndex;
    int _dateCounter;
    
}

@property (nonatomic, weak) id <ECViewControllerDelegate> delegate;

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic, retain) IBOutlet ECTableViewCell *tableViewCell;
@property (weak, nonatomic) IBOutlet UIView *menuViewTwo;
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *menuView;
@property (weak, nonatomic) IBOutlet UILabel *lblDate;
@property (weak, nonatomic) IBOutlet UILabel *lblDistance;
@property (weak, nonatomic) IBOutlet UILabel *lblTime;

- (IBAction)OpenInMapsPressed:(UIButton *)sender;
- (IBAction)menuShow:(UIButton *)sender;
- (IBAction)MenuItemSelected:(UIButton *)sender;
- (IBAction)OnDateForward:(UIButton *)sender;
- (IBAction)OnDateBackward:(UIButton *)sender;
- (IBAction)OnTodaysNotesPressed:(UIButton *)sender;
- (IBAction)OnColdCallPressed:(UIButton *)sender;


@end
