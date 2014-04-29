//
//  ECcalenderViewController.m
//  encompass
//
//  Created by Kshitij on 3/9/2014.
//  Copyright (c) 2014 encompass. All rights reserved.
//

#import "ECcalenderViewController.h"

@interface ECcalenderViewController ()

@end

@implementation ECcalenderViewController

@synthesize collectionData = _collectionData;
@synthesize weekCalendarData = _weekCalendarData;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Verify the week data that we have recevied from the month view
    NSLog(@"\n");
    for (CalendarItemAdvanced *item in _weekCalendarData)
    {
        NSLog(@"Date = %@", item.date);
        NSLog(@"Items = \n%@", item.entries);
    }
    NSLog(@"\n");
    
    self.collectionData = [[NSMutableArray alloc]init];
    
    [self loadUpCollectionWithItems];
    
    /* Configure the helper */
    
    self.helper = [[I3DragBetweenHelper alloc] initWithSuperview:self.view
                                                         srcView:self.MyTableView
                                                         dstView:self.collectionView];
    
    self.helper.delegate = self;
    
    self.helper.isDstRearrangeable = YES;
    self.helper.isSrcRearrangeable = NO;
    self.helper.doesSrcRecieveDst = NO;
    self.helper.doesDstRecieveSrc = NO;
    self.helper.hideDstDraggingCell = NO;
    self.helper.hideSrcDraggingCell = YES;
    
}

-(void)loadUpCollectionWithItems{
    for (int i = 1; i < 9; i++)
    {
        WeeklyCalendarItem *item;
        if(i==1){
            item = [[WeeklyCalendarItem alloc] initWithDate:[NSString stringWithFormat:@"%@", @"APR"] entry:@"0"];
            
        }
        else if (i < 9)
        {
            item = [[WeeklyCalendarItem alloc] initWithDate:[NSString stringWithFormat:@"%@", [self returnDayOfTheWeek:i]] entry:@"5"];
            
        }
        [self.collectionData addObject:item];
    }
    for (int k = 0; k< 12; k++) {
        for (int j = 0; j < 8; j++)
        {
            WeeklyCalendarItem *item;
            
            if (j==0) {
                if (k==0) {
                    item = [[WeeklyCalendarItem alloc] initWithDate:[NSString stringWithFormat:@"%d", 12] entry:@"0"];
                    
                }
                else{
                    item = [[WeeklyCalendarItem alloc] initWithDate:[NSString stringWithFormat:@"%d", k] entry:@"0"];
                    
                }
            }
            else{
                NSString *events =@"";
                if ((k==1)&&(j==3)) {
                    events =@"kraft appointment";
                }
                else{
                    
                }
                item = [[WeeklyCalendarItem alloc] initWithDate:@"" entry:events];
            }
            
            [self.collectionData addObject:item];
        }
    }
    
    for (int k = 0; k< 12; k++) {
        for (int j = 0; j < 8; j++)
        {
            WeeklyCalendarItem *item;
            if (j==0) {
                if (k==0) {
                    item = [[WeeklyCalendarItem alloc] initWithDate:[NSString stringWithFormat:@"%@", @"noon"] entry:@"0"];
                    
                }
                else{
                    item = [[WeeklyCalendarItem alloc] initWithDate:[NSString stringWithFormat:@"%d", k] entry:@"0"];
                    
                }
            }
            else{
                item = [[WeeklyCalendarItem alloc] initWithDate:@"" entry:@""];
            }
            
            [self.collectionData addObject:item];
        }
    }

}


#pragma mark - Drag n drop exchange and rearrange delegate methods

-(void) droppedOnDstAtIndexPath:(NSIndexPath*) to fromDstIndexPath:(NSIndexPath*) from{
    
    NSInteger fromIndex = (from.item);
    NSInteger toIndex = (to.item);
    
    WeeklyCalendarItem *item = (WeeklyCalendarItem *)[self.collectionData objectAtIndex:fromIndex];
    NSString * entry = item.entry;
    if (([entry isEqualToString:@""])|| ([entry isEqualToString:@"0"])||([entry isEqualToString:@"5"])){
    }
    else{
        [self.collectionView cellForItemAtIndexPath:from].alpha = 1;
        [self.collectionData exchangeObjectAtIndex:toIndex withObjectAtIndex:fromIndex];
    }
    
}


-(BOOL) isCellAtIndexPathDraggable:(NSIndexPath*) index inContainer:(UIView*) container{
    
    
    NSInteger fromIndex = (index.item);
    
    WeeklyCalendarItem *item = (WeeklyCalendarItem *)[self.collectionData objectAtIndex:fromIndex];
    NSString * entry = item.entry;
    
    if (([entry isEqualToString:@""])|| ([entry isEqualToString:@"0"])||([entry isEqualToString:@"5"])){
        return NO;
    }
    else{
        return YES;
        
    }
    
}

-(BOOL) isCellInDstAtIndexPathExchangable:(NSIndexPath*) to withCellAtIndexPath:(NSIndexPath*) from{
    
    /* Stop the last cell from being exchangeable */
    NSInteger fromIndex = (from.item);
    
    WeeklyCalendarItem *item = (WeeklyCalendarItem *)[self.collectionData objectAtIndex:fromIndex];
    NSString * entry = item.entry;
    if (([entry isEqualToString:@""])|| ([entry isEqualToString:@"0"])||([entry isEqualToString:@"5"])){
        return NO;
    }
    else{
        return YES;
        
    }
    
}


-(NSString*)returnDayOfTheWeek :(int)number{
    NSString *stringToReturn = @"";
    switch (number) {
        case 2:
            stringToReturn = @"Monday";
            break;
        case 3:
            stringToReturn = @"Tuesday";
            break;
        case 4:
            stringToReturn = @"Wednesday";
            break;
        case 5:
            stringToReturn = @"Thursday";
            break;
        case 6:
            stringToReturn = @"Friday";
            break;
        case 7:
            stringToReturn = @"Saturday";
            break;
        case 8:
            stringToReturn = @"Sunday";
            break;
            
        default:
            break;
    }
    return stringToReturn;
}


#pragma mark collection view cell paddings
- (UIEdgeInsets)collectionView:(UICollectionView*)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 0, 0, 0); // top, left, bottom, right
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0f;
}

-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 0.0f;
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    WeeklyCalendarItem *item = (WeeklyCalendarItem *)[self.collectionData objectAtIndex:indexPath.item];
    NSString *entry = item.entry;
    
    if ([entry isEqualToString:@"0"]) {
        return CGSizeMake(34.0f, 50.0f);
  
    }
    else{
        return CGSizeMake(123.0f, 50.0f);

    }

}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

//- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
//{
//    return [[sections objectAtIndex:section] count];
//}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.collectionData.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    WeeklyCalendarItem *item = (WeeklyCalendarItem *)[self.collectionData objectAtIndex:indexPath.item];
    NSString *date = item.date;
    NSString *entry = item.entry;
    DMCollectionViewCell *cell;
   
    if ([entry isEqualToString:@"0"]) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"datesCell"
                                                                               forIndexPath:indexPath];
        cell.backgroundColor = [UIColor whiteColor];
        if (cell == nil)
        {
            cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"datesCell"
                                                             forIndexPath:indexPath];
        }
        cell.dateLabel.text = date;
        [cell.entriesLabel setText:@""];
        cell.entriesLabel.numberOfLines = 4;
        cell.entriesLabel.textColor = [UIColor blackColor];
//        [cell.layer setBorderColor:[UIColor grayColor].CGColor];
//        [cell.layer setBorderWidth:.5f];
        
    }
    else if ([entry isEqualToString:@"5"] ) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"DequeueReusableCell"
                                                                               forIndexPath:indexPath];
        cell.backgroundColor = [UIColor whiteColor];
        if (cell == nil)
        {
            cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"DequeueReusableCell"
                                                             forIndexPath:indexPath];
        }
        [cell.entriesLabel setText:@""];
        cell.dateLabel.text = date;
        cell.entriesLabel.numberOfLines = 4;
        cell.entriesLabel.textColor = [UIColor blackColor];
        [cell.layer setBorderColor:[UIColor lightGrayColor].CGColor];
        [cell.layer setBorderWidth:.3f];
        
    }
    else if (![entry isEqualToString:@""] ) {
       cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"DequeueReusableCell"
                                                                               forIndexPath:indexPath];
        cell.backgroundColor = [UIColor yellowColor];
        if (cell == nil)
        {
            cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"DequeueReusableCell"
                                                             forIndexPath:indexPath];
        }
        [cell.dateLabel setText: @""];
        cell.entriesLabel.text = item.entry;
        cell.entriesLabel.numberOfLines = 4;
        cell.entriesLabel.textColor = [UIColor blackColor];
        
        [cell.layer setBorderColor:[UIColor lightGrayColor].CGColor];
        [cell.layer setBorderWidth:.3f];
        
    }
    else{
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"DequeueReusableCell"
                                                                               forIndexPath:indexPath];
        cell.backgroundColor = [UIColor whiteColor];
        if (cell == nil)
        {
            cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"DequeueReusableCell"
                                                             forIndexPath:indexPath];
        }
        [cell.dateLabel setText: @""];

        cell.entriesLabel.text = item.entry;
        cell.entriesLabel.numberOfLines = 4;
        cell.entriesLabel.textColor = [UIColor blackColor];
        
        [cell.layer setBorderColor:[UIColor lightGrayColor].CGColor];
        [cell.layer setBorderWidth:.3f];
    }


    return cell;
}

- (IBAction)back:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

// I implemented didSelectItemAtIndexPath:, but you could use willSelectItemAtIndexPath: depending on what you intend to do. See the docs of these two methods for the differences.
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    // If you need to use the touched cell, you can retrieve it like so
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    
    NSLog(@"touched cell %@ at indexPath %@", cell, indexPath);
}
@end
