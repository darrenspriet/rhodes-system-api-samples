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
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (isCustomized) {
        [tableView setEditing:YES animated:YES];
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleNone;
}

-(void)changeToCustomized{
    isCustomized = YES;
         [self.horizontalTableView setEditing:YES animated:YES];

}
-(void)changeToOptimized{
    isCustomized = NO;
    [self.horizontalTableView setEditing:NO animated:YES];
    self.addresses = [[NSMutableArray alloc] initWithObjects:@"Best Buy \n6075 Mavis Road                      \nMississauga, ON \nL5H 2M9",
                      @"Future Shop \n2975 Argentia Road \nMississauga, ON \nL6H 2W2",
                      @"Staples \n2460 Winston Churchill Boulevard \nOakville, ON \nL7M 3T2",
                      @"Trinbago Barbershop \n2547 Hurontario Street \nMississauga, ON, \nL5A 2G4",
                      @"Best Buy \n2500 Winston Park Dr \nOakville, ON, \nL6H 7E5",
                      nil];
    [self.horizontalTableView reloadData];

}

-(NSMutableArray*)changeAddressesOrder{
    if (isNormalAddress) {
        self.addresses = [[NSMutableArray alloc] initWithObjects:@"Best Buy \n6075 Mavis Road                      \nMississauga, ON \nL5H 2M9",
                      @"Future Shop \n2975 Argentia Road \nMississauga, ON \nL6H 2W2",
                      @"Staples \n2460 Winston Churchill Boulevard \nOakville, ON \nL7M 3T2",
                      @"Trinbago Barbershop \n2547 Hurontario Street \nMississauga, ON, \nL5A 2G4",
                      @"Best Buy \n2500 Winston Park Dr \nOakville, ON, \nL6H 7E5",
                      nil];
        isNormalAddress = NO;
    }
    else{
        self.addresses = [[NSMutableArray alloc] initWithObjects:
                      @"Shoppers Drug Mart\n5033 Hurontario Street \nMississauga, ON, \nL4Z 3X7",
                      @"PetSmart \n5800 McLaughlin Rd \nMississauga, ON \nL5R 4B7",
                      @"Winners \n50 Matheson W \nMississauga, ON, \nL5R 3T2",
                      @"Michaels \n3105 Argentia Rd\nMississauga, ON \nL5N 8E1",
                      @"Walmart \n2959 Argentia Rd \nMississauga, ON \nL5N 0B2",
                      @"Best Buy \n2500 Winston Park Dr \nOakville, ON, \nL6H 7E5",
                      nil];
        isNormalAddress=YES;
    }
    
    [self.horizontalTableView reloadData];
        return self.addresses;
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
