//
//  ECOptionsTableViewController.h
//  encompass
//
//  Created by Darren Spriet on 2014-03-11.
//  Copyright (c) 2014 encompass. All rights reserved.
//
@protocol ECOptionsTableViewControllerDelegate <NSObject>
-(void)changeToCustomized;
-(void)changeToOptimized;
@end


#import <UIKit/UIKit.h>
#import "ECOptionsCell.h"
#import "ECOptionsTableViewController.h"
#import "ECViewController.h"




@interface ECOptionsTableViewController : UITableViewController

@property (nonatomic, strong) NSMutableArray *options;
@property (nonatomic, weak) id <ECOptionsTableViewControllerDelegate> delegate;


@end
