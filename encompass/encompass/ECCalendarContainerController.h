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

//These are used to for the different views and the show and hide button
@property (weak, nonatomic) IBOutlet UIView *weeklyViewContainer;
@property (weak, nonatomic) IBOutlet UIView *monthlyContainer;
@property (weak, nonatomic) IBOutlet UIButton *showButtonOutlet;

//The Two types of Libararys or Frameworks we are using
@property (nonatomic) MAWeekViewController *weeklyController;
@property (nonatomic) PDTSimpleCalendarViewController *monthlyViewController;

//The Data and the Selected Date
@property (nonatomic, strong) NSDate *selectedDate;
@property (nonatomic, strong) NSMutableArray* collectionData;
@property (nonatomic, strong) NSDate *todaysDate;

//The two Buttons on the Screen so we can see the different views
- (IBAction)hideShowTableView:(UIButton *)sender;
- (IBAction)segmentControlPressed:(UISegmentedControl *)sender;

@end
