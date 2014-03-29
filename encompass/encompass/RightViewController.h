//
//  RightViewController.h
//  MathMonsters
//
//  Created by Ellen Shapiro on 1/8/13.
//  Copyright (c) 2013 Designated Nerd Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "I3DragBetweenHelper.h"
#import "CalendarItem.h"
#import "DMCollectionViewCell.h"


@interface RightViewController : UIViewController <UISplitViewControllerDelegate, I3DragBetweenDelegate , UITableViewDataSource,  UITableViewDelegate,
UICollectionViewDataSource, UICollectionViewDelegate,
UICollectionViewDelegateFlowLayout>{

    NSMutableArray *_addressesOptimal;
}

@property (nonatomic, strong) UIPopoverController *popover;

@property (weak, nonatomic) IBOutlet UITableView *sourceTable;

@property (weak, nonatomic) IBOutlet UICollectionView *destinationCollection;


@property (nonatomic, strong) I3DragBetweenHelper* helper;

@property (nonatomic, strong) NSArray* tableData;

@property (nonatomic, strong) NSMutableArray* collectionData;

@end
