//
//  RightViewController.m
//  MathMonsters
//
//  Created by Ellen Shapiro on 1/8/13.
//  Copyright (c) 2013 Designated Nerd Software. All rights reserved.
//

#import "RightViewController.h"
#import "LeftViewController.h"

@implementation RightViewController

#pragma mark - View Lifecycle
//- (void)viewDidLoad
//{
//    [super viewDidLoad];
//    
//    _addressesOptimal = [[NSMutableArray alloc] initWithObjects:@"My Home \n3171 victory crescent \nMississauga, ON \nL4T 1L7",
//                         @"Future Shop \n2975 Argentia Road \nMississauga, ON \nL6H 2W2",
//                         @"Staples \n2460 Winston Churchill Boulevard \nOakville, ON \nL7M 3T2",
//                         @"Trinbago Barbershop \n2547 Hurontario Street \nMississauga, ON \nL5A 2G4",
//                         @"Rattray Marsh \n600-798 Nautalex Crt \nMississauga, ON \nL5H 1A7",
//                         nil];
//
//    self.sourceTable.delegate = self;
//   self.sourceTable.dataSource = self;
//    self.destinationCollection.delegate = self;
//    self.destinationCollection.dataSource = self;
//
//}
//
//-(void)viewWillAppear:(BOOL)animated
//{
//    [super viewWillAppear:animated];
//    
//    //Update the UI to reflect the monster set on initial load.
//    [self refreshUI];
//}
//
//- (void)didReceiveMemoryWarning
//{
//    [super didReceiveMemoryWarning];
//    
//    // Dispose of any resources that can be recreated, in this case the IBOutlets.
//
//}
//
//
//#pragma mark - Table view data source
//
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//    return 1;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//    return [_addressesOptimal count];
//}
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
//    if (cell == nil)
//    {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
//        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
//    }
//    
//    cell.textLabel.font = [UIFont fontWithName:@"Arial-BoldMT" size:15];
//    cell.textLabel.numberOfLines = 5;
//    [cell.textLabel sizeToFit];
//    cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tablecell.png"]];
//    cell.showsReorderControl = YES;
//    [cell.textLabel setText:[_addressesOptimal objectAtIndex:indexPath.row]];
//    return cell;
//    
//}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    // Height of the table cell background image
//    return 140;
//}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.sourceTable.delegate = self;
    self.sourceTable.dataSource = self;
    self.destinationCollection.delegate = self;
    self.destinationCollection.dataSource = self;
    self.tableData = @[
                       @"Dilip",
                       @"Kshitij",
                       @"Chandar",
                       @"Darren",
                       @"Boris",
                       @"George",
                       @"Abraham",
                       @"Jessica",
                       @"Rekha"
                       ];
    
    self.collectionData = [NSMutableArray arrayWithCapacity:36];
    
    for (int i = 0; i < 42; i++)
    {
        NSMutableArray *entries = [[NSMutableArray alloc] initWithObjects:nil];
        CalendarItem *item;
        if (i < 5 || i > 36)
        {
            item = [[CalendarItem alloc] initWithDate:@"0" entries:entries];
        }
        else
        {
            NSString *date = [NSString stringWithFormat:@"%i", i-5];
            item = [[CalendarItem alloc] initWithDate:date entries:entries];
        }
        [self.collectionData addObject:item];
    }
    
    /* Configure the helper */
    
    self.helper = [[I3DragBetweenHelper alloc] initWithSuperview:self.view
                                                         srcView:self.sourceTable
                                                         dstView:self.destinationCollection];
    
    self.helper.delegate = self;
    
    self.helper.isSrcRearrangeable = NO;
    self.helper.doesSrcRecieveDst = NO;
    self.helper.hideSrcDraggingCell = NO;
    
    self.helper.isDstRearrangeable = NO;
    self.helper.doesDstRecieveSrc = YES;
    self.helper.doesSrcRecieveDst = NO;
    self.helper.hideDstDraggingCell = YES;
}


#pragma mark - Drag n drop exchange and rearrange delegate methods

-(void) droppedOnDstAtIndexPath:(NSIndexPath*) to fromSrcIndexPath:(NSIndexPath*)from
{
    /* Grab the appropriate data */
    NSInteger fromIndex = (from.item);
    NSInteger toIndex = (to.item);
    // Disable drag and drop on invalid calendar cells
    if (toIndex < 5 || toIndex > 36)
    {
        return;
    }
    // Don't allow more than 4 names in a calendar item
    CalendarItem *item = [self.collectionData objectAtIndex:toIndex];
    if (item.entries.count > 3)
    {
        [[[UIAlertView alloc] initWithTitle:@"Invalid" message:@"Only 4 items per day!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        return;
    }
    
    NSString *name = [self.tableData objectAtIndex:fromIndex];
    
    /* Update the data and collections accordingly */
    [item.entries addObject:name];
    
    [self.destinationCollection reloadData];
}

-(BOOL) droppedOutsideAtPoint:(CGPoint) pointIn fromDstIndexPath:(NSIndexPath*) from
{
    return YES;
}

-(BOOL) isCellAtIndexPathDraggable:(NSIndexPath*) index inContainer:(UIView*) container
{
    return (container == self.destinationCollection) ? NO : YES;
}


#pragma mark - Collection view delegate and datasource implementations

-(NSInteger) collectionView:(UICollectionView*) collectionView numberOfItemsInSection:(NSInteger) section
{
    return self.collectionData.count;
}

-(UICollectionViewCell*) collectionView:(UICollectionView*)collectionView cellForItemAtIndexPath:(NSIndexPath*) indexPath{
    
    DMCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"DequeueReusableCell"
                                                                           forIndexPath:indexPath];
    CalendarItem *item = (CalendarItem *)[self.collectionData objectAtIndex:indexPath.item];
    NSString *date = item.date;
    if ([date isEqualToString:@"0"])
    {
        cell.backgroundColor = [UIColor lightGrayColor];
        cell.dateLabel.text = @"";
        cell.entriesLabel.text = @"";
    }
    else
    {
        cell.dateLabel.text = date;
        cell.entriesLabel.text = [item.entries componentsJoinedByString:@"\n"];
        cell.entriesLabel.numberOfLines = 4;
        cell.dateLabel.textColor = [UIColor blueColor];
        cell.entriesLabel.textColor = [UIColor blackColor];
        cell.backgroundColor = [UIColor whiteColor];
    }
    
    return cell;
}

#pragma mark - Collection View FlowLayout delegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(88.0, 88.0);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0.0f;
}


#pragma mark - Table view delegate and datasource implementations


-(NSInteger) tableView:(UITableView*) tableView numberOfRowsInSection:(NSInteger) section{
    
    return self.tableData.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Height of the table cell background image
    return 140;
}


-(UITableViewCell*) tableView:(UITableView*) tableView cellForRowAtIndexPath:(NSIndexPath*) indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyIdentifier"];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"MyIdentifier"];
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    }
    NSInteger row = indexPath.row;
    
    cell.textLabel.text = [self.tableData objectAtIndex:row];
    cell.textLabel.font = [UIFont fontWithName:@"Arial-BoldMT" size:15];
    cell.textLabel.numberOfLines = 5;
    [cell.textLabel sizeToFit];
    cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tablecell.png"]];
    cell.showsReorderControl = YES;
    
    return cell;
}






#pragma mark - New Methods
-(void)refreshUI
{
}



#pragma mark - UISplitViewDelegate methods
-(void)splitViewController:(UISplitViewController *)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)pc
{
    //Grab a reference to the popover
    self.popover = pc;
    
}

-(void)splitViewController:(UISplitViewController *)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    
    //Nil out the pointer to the popover.
    _popover = nil;
}

-(BOOL)splitViewController:(UISplitViewController *)svc shouldHideViewController:(UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation
{
    return YES;
}


@end
