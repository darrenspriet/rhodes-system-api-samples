//
//  ECOptionsTableViewController.m
//  encompass
//
//  Created by Darren Spriet on 2014-03-11.
//  Copyright (c) 2014 encompass. All rights reserved.
//

#import "ECOptionsTableViewController.h"

@interface ECOptionsTableViewController ()

@end

@implementation ECOptionsTableViewController

//- (id)initWithStyle:(UITableViewStyle)style
//{
//    self = [super initWithStyle:style];
//    if (self) {
//        // Custom initialization
//    }
//    return self;
//}

- (void)viewDidLoad
{
    [super viewDidLoad];
    

        self.options =  [[NSMutableArray alloc] initWithObjects:
                               @"Use Current Location",
                                @"Custom Location",
                                @"Shortest Route",
                                @"Custom Route",
                                @"Use Toll Roads",
                                @"Show Traffic", nil];



    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.options count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"optionsCell";
    ECOptionsCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if ((indexPath.row==0)||(indexPath.row==2) ){
         cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else{
        cell.accessoryType = UITableViewCellAccessoryNone;

    }
   
    
    if (cell == nil)
    {
        cell = [[ECOptionsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"optionsCell"];
    }
    
    // Configure the cell...
    [cell.optionsLabel setText:[self.options objectAtIndex:indexPath.row]];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger index = [[tableView indexPathsForVisibleRows] indexOfObject:indexPath];
    
    if (index != NSNotFound) {
        UITableViewCell *cell = [[tableView visibleCells] objectAtIndex:index];
        if ([cell accessoryType] == UITableViewCellAccessoryNone) {
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
            if (index==0) {
                

               UITableViewCell *cell = [[tableView visibleCells] objectAtIndex:1];
                [cell setAccessoryType:UITableViewCellAccessoryNone];
            }
            else  if (index==1) {
               
                UITableViewCell *cell = [[tableView visibleCells] objectAtIndex:0];
                [cell setAccessoryType:UITableViewCellAccessoryNone];
            }
            else if (index==2) {
                [self.delegate changeToOptimized];
                UITableViewCell *cell = [[tableView visibleCells] objectAtIndex:3];
                [cell setAccessoryType:UITableViewCellAccessoryNone];
            }
            else  if (index==3) {
                [self.delegate changeToCustomized];

                UITableViewCell *cell = [[tableView visibleCells] objectAtIndex:2];
                [cell setAccessoryType:UITableViewCellAccessoryNone];
            }
        } else {
            if ((index==0)||(index==1) ||(index==2) ||(index==3) ) {

            }
            else{
                [cell setAccessoryType:UITableViewCellAccessoryNone];
            }
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

}

- (void)tableView: (UITableView*)tableView willDisplayCell: (UITableViewCell*)cell forRowAtIndexPath: (NSIndexPath*)indexPath
{
    cell.backgroundColor = cell.contentView.backgroundColor;

}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
