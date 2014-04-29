//
//  ECcalenderViewController.h
//  encompass
//
//  Created by Kshitij on 3/9/2014.
//  Copyright (c) 2014 encompass. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DMCollectionViewCell.h"
#import "WeeklyCalendarItem.h"
#import "I3DragBetweenHelper.h"
#import "CalendarItemAdvanced.h"


@interface ECcalenderViewController : UIViewController<I3DragBetweenDelegate, UICollectionViewDelegateFlowLayout,UICollectionViewDataSource, UICollectionViewDelegate>
{
    bool isTableViewVisible;
}

- (IBAction)back:(id)sender;

@property (nonatomic, strong) NSMutableArray* collectionData;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (nonatomic, strong) I3DragBetweenHelper* helper;

@property (weak, nonatomic) IBOutlet UIView *theView;

@property (weak, nonatomic) IBOutlet UITableView *MyTableView;

// Raw week data obtained from month calendar (needs to be parsed!)
@property (nonatomic, strong) NSMutableArray *weekCalendarData;


@end
