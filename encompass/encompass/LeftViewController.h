//
//  LeftViewController.h
//  MathMonsters
//
//  Created by Ellen Shapiro on 1/8/13.
//  Copyright (c) 2013 Designated Nerd Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RightViewController.h"


@interface LeftViewController : UIViewController{
       NSMutableArray *_addressesOptimal;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;



@end
