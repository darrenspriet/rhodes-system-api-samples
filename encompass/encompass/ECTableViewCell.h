//
//  ECMyTableViewCell.h
//  encompass
//
//  Created by Darren Spriet on 2014-03-03.
//  Copyright (c) 2014 encompass. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ECActualTableViewCell.h"
#import "ECViewController.h"

@class ECViewController;

@interface ECTableViewCell : UITableViewCell<UITableViewDelegate, UITableViewDataSource, ECViewControllerDelegate>{
    BOOL isNormalAddress;
    BOOL isCustomized;
}


@property (weak, nonatomic) IBOutlet UITableView *horizontalTableView;

@property (nonatomic, retain) NSMutableArray *addresses;
@end
