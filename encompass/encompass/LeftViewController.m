//
//  LeftViewController.m
//  MathMonsters
//
//  Created by Ellen Shapiro on 1/8/13.
//  Copyright (c) 2013 Designated Nerd Software. All rights reserved.
//

#import "LeftViewController.h"


@interface LeftViewController ()

@end

@implementation LeftViewController

-(id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        //Initialize the array of monsters for display.
       
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _addressesOptimal = [[NSMutableArray alloc] initWithObjects:@"My Home \n3171 victory crescent \nMississauga, ON \nL4T 1L7",
                        @"Future Shop \n2975 Argentia Road \nMississauga, ON \nL6H 2W2",
                        @"Staples \n2460 Winston Churchill Boulevard \nOakville, ON \nL7M 3T2",
                        @"Trinbago Barbershop \n2547 Hurontario Street \nMississauga, ON \nL5A 2G4",
                        @"Rattray Marsh \n600-798 Nautalex Crt \nMississauga, ON \nL5H 1A7",
                        nil];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_addressesOptimal count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    }
   
    cell.textLabel.font = [UIFont fontWithName:@"Arial-BoldMT" size:15];
    cell.textLabel.numberOfLines = 5;
    [cell.textLabel sizeToFit];
    cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tablecell.png"]];
    cell.showsReorderControl = YES;
    [cell.textLabel setText:[_addressesOptimal objectAtIndex:indexPath.row]];
    return cell;
   
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Height of the table cell background image
    return 140;
}



@end
