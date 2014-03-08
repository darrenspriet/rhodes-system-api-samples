//
//  ECMyTableViewCell.m
//  encompass
//
//  Created by Darren Spriet on 2014-03-03.
//  Copyright (c) 2014 encompass. All rights reserved.
//

#import "ECTableViewCell.h"

@implementation ECTableViewCell

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.addresses count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"ActualTableViewCell";
    ECActualTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
    {
        cell = [[ECActualTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"ActualTableViewCell"];
    }
    
    [cell.storeInformation setText : [self.addresses objectAtIndex:indexPath.row] ];
    [cell.storeInformation setFont : [UIFont fontWithName:@"Arial-BoldMT" size:15] ];
    [cell.storeInformation setNumberOfLines : 5];
    [cell.storeInformation sizeToFit];
    [cell setBackgroundView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tablecell.png"]]];
    [cell.storeInformation setTransform:CGAffineTransformMakeRotation(M_PI / 2)];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 200;
}
-(BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return YES;
}
-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}
// Override to prevent indentation of cells in editing mode (in theory)
- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}


- (void)tableView: (UITableView *)tableView moveRowAtIndexPath: (NSIndexPath *)fromIndexPath toIndexPath: (NSIndexPath *)toIndexPath{
    NSLog(@"INDEX PATH IS: %d", [fromIndexPath row]);
    NSString *mover = [self.addresses objectAtIndex:[fromIndexPath row]];
    [self.addresses removeObjectAtIndex:[fromIndexPath row]];
    [self.addresses insertObject:mover atIndex:[toIndexPath row]];
    [tableView setEditing:NO animated:YES];
    
}
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    [tableView setEditing:YES animated:YES];
//}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleNone;
}

-(void)changeToCustomized{

         [self.horizontalTableView setEditing:YES animated:YES];

}
-(void)changeToOptimized{
    [self.horizontalTableView setEditing:NO animated:YES];
}

-(BOOL)isTableEditible{
    if (self.horizontalTableView.editing==YES) {
        return YES;
    }
    else{
        return NO;
    }
}


@end
