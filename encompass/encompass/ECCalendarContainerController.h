//
//  ECCalendarContainerController.h
//  encompass
//
//  Created by Darren Spriet on 2014-05-01.
//  Copyright (c) 2014 encompass. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PDTSimpleCalendarViewController.h"
#import "MAWeekViewController.h"



@interface ECCalendarContainerController : UIViewController

@property (weak, nonatomic) IBOutlet UIView *weeklyViewContainer;
@property (weak, nonatomic) IBOutlet UIView *monthlyContainer;
- (IBAction)segmentControlPressed:(UISegmentedControl *)sender;

@property (nonatomic) MAWeekViewController *weeklyController;
@property (nonatomic) PDTSimpleCalendarViewController *monthlyViewController;

@property (nonatomic, strong) NSDate *selectedDate;

@property (nonatomic, strong) NSMutableArray* collectionData;

@property (weak, nonatomic) IBOutlet UIButton *showButtonOutlet;
- (IBAction)hideShowTableView:(UIButton *)sender;

@end
