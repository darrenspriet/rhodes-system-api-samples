//
//  PDTSimpleCalendarViewController.m
//  PDTSimpleCalendar
//
//  Created by Jerome Miglino on 10/7/13.
//  Copyright (c) 2013 Producteev. All rights reserved.
//

#import "PDTSimpleCalendarViewController.h"

#import "PDTSimpleCalendarViewFlowLayout.h"
#import "PDTSimpleCalendarViewCell.h"
#import "PDTSimpleCalendarViewHeader.h"


const CGFloat PDTSimpleCalendarOverlaySize = 14.0f;

static NSString *PDTSimpleCalendarViewCellIdentifier = @"com.producteev.collection.cell.identifier";
static NSString *PDTSimpleCalendarViewHeaderIdentifier = @"com.producteev.collection.header.identifier";


@interface PDTSimpleCalendarViewController () <PDTSimpleCalendarViewCellDelegate>

@property (nonatomic, strong) UILabel *overlayView;
@property (nonatomic, strong) NSDateFormatter *headerDateFormatter; //Will be used to format date in header view and on scroll.

// First and last date of the months based on the public properties first & lastDate
@property (nonatomic, readonly) NSDate *firstDateMonth;
@property (nonatomic, readonly) NSDate *lastDateMonth;

//Number of days per week
@property (nonatomic, assign) NSUInteger daysPerWeek;

@end


@implementation PDTSimpleCalendarViewController

//Explicitly @synthesize the var (it will create the iVar for us automatically as we redefine both getter and setter)
@synthesize firstDate = _firstDate;
@synthesize lastDate = _lastDate;
@synthesize calendar = _calendar;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    //Force the creation of the view with the pre-defined Flow Layout.
    //Still possible to define a custom Flow Layout, if needed by using initWithCollectionViewLayout:
    self = [super init];
    if (self) {
        // Custom initialization
        [self simpleCalendarCommonInit];
    }

    return self;
}

//- (instancetype)initWithCoder:(NSCoder *)coder
//{
//    //Force the creation of the view with the pre-defined Flow Layout.
//    //Still possible to define a custom Flow Layout, if needed by using initWithCollectionViewLayout:
//    self = [super initWithCollectionViewLayout:[[PDTSimpleCalendarViewFlowLayout alloc] init]];
//    if (self) {
//        // Custom initialization
//        [self simpleCalendarCommonInit];
//    }
//    
//    return self;
//}
//
//- (id)initWithCollectionViewLayout:(UICollectionViewLayout *)layout
//{
//    self = [super initWithCollectionViewLayout:layout];
//    if (self) {
//        [self simpleCalendarCommonInit];
//    }
//
//    return self;
//}

- (void)simpleCalendarCommonInit
{
    self.overlayView = [[UILabel alloc] init];
    self.backgroundColor = [UIColor whiteColor];
    self.overlayTextColor = [UIColor blackColor];
    self.daysPerWeek = 7;
}

#pragma mark - Accessors

- (NSDateFormatter *)headerDateFormatter;
{
    if (!_headerDateFormatter) {
        _headerDateFormatter = [[NSDateFormatter alloc] init];
        _headerDateFormatter.calendar = self.calendar;
        _headerDateFormatter.dateFormat = [NSDateFormatter dateFormatFromTemplate:@"yyyy LLLL" options:0 locale:self.calendar.locale];
    }
    return _headerDateFormatter;
}

- (NSCalendar *)calendar
{
    if (!_calendar) {
        [self setCalendar:[NSCalendar currentCalendar]];
    }
    return _calendar;
}

-(void)setCalendar:(NSCalendar*)calendar
{
    _calendar = calendar;
    self.headerDateFormatter.calendar = calendar;
    self.daysPerWeek = [_calendar maximumRangeOfUnit:NSWeekdayCalendarUnit].length;
}

- (NSDate *)firstDate
{
    if (!_firstDate) {
        NSDateComponents *components = [self.calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay
                                                        fromDate:[NSDate date]];
        components.day = 1;
        _firstDate = [self.calendar dateFromComponents:components];
    }

    return _firstDate;
}

- (void)setFirstDate:(NSDate *)firstDate
{
    _firstDate = [self clampDate:firstDate toComponents:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay];
}

//TODO: Store the value in the variable to avoid calculation everytime.
- (NSDate *)firstDateMonth
{
    NSDateComponents *components = [self.calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay
                                                    fromDate:self.firstDate];
    components.day = 1;

    return [self.calendar dateFromComponents:components];
}

- (NSDate *)lastDate
{
    if (!_lastDate) {
        NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
        offsetComponents.year = 1;
        offsetComponents.day = -1;
        [self setLastDate:[self.calendar dateByAddingComponents:offsetComponents toDate:self.firstDateMonth options:0]];
    }

    return _lastDate;
}

- (void)setLastDate:(NSDate *)lastDate
{
    _lastDate = [self clampDate:lastDate toComponents:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay];
}

//TODO: Store the value in the variable to avoid calculation everytime.
- (NSDate *)lastDateMonth
{
    NSDateComponents *components = [self.calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:self.lastDate];
    components.month++;
    components.day = 0;

    return [self.calendar dateFromComponents:components];
}

- (void)setSelectedDate:(NSDate *)newSelectedDate
{
    //if newSelectedDate is nil, unselect the current selected cell
    if (!newSelectedDate) {
        [[self cellForItemAtDate:_selectedDate] setSelected:NO];
        _selectedDate = newSelectedDate;

        return;
    }

    //Test if selectedDate between first & last date
    NSDate *startOfDay = [self clampDate:newSelectedDate toComponents:NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit];
    if (([startOfDay compare:self.firstDateMonth] == NSOrderedAscending) || ([startOfDay compare:self.lastDateMonth] == NSOrderedDescending)) {
        //the newSelectedDate is not between first & last date of the calendar, do nothing.
        return;
    }


    [[self cellForItemAtDate:_selectedDate] setSelected:NO];
    [[self cellForItemAtDate:startOfDay] setSelected:YES];

    _selectedDate = startOfDay;

    NSIndexPath *indexPath = [self indexPathForCellAtDate:_selectedDate];
    [self.collectionView reloadItemsAtIndexPaths:@[ indexPath ]];

    //Notify the delegate
    if ([self.delegate respondsToSelector:@selector(simpleCalendarViewController:didSelectDate:)]) {
        [self.delegate simpleCalendarViewController:self didSelectDate:self.selectedDate];
    }
}

//Deprecated, You need to use setSelectedDate: and call scrollToDate:animated: or scrollToSelectedDate:animated:
//TODO: Remove this in next release
- (void)setSelectedDate:(NSDate *)newSelectedDate animated:(BOOL)animated
{
    [self setSelectedDate:newSelectedDate];
    [self scrollToSelectedDate:animated];
}

#pragma mark - Scroll to a specific date

- (void)scrollToSelectedDate:(BOOL)animated
{
    if (_selectedDate) {
        [self scrollToDate:_selectedDate animated:animated];
    }
}

- (void)scrollToDate:(NSDate *)date animated:(BOOL)animated
{
    @try {
        NSIndexPath *selectedDateIndexPath = [self indexPathForCellAtDate:date];

        if (![[self.collectionView indexPathsForVisibleItems] containsObject:selectedDateIndexPath]) {
            //First, tried to use [self.collectionView layoutAttributesForSupplementaryElementOfKind:UICollectionElementKindSectionHeader atIndexPath:selectedDateIndexPath]; but it causes the header to be redraw multiple times (X each time you use scrollToDate:)
            //TODO: Investigate & eventually file a radar.

            NSIndexPath *sectionIndexPath = [NSIndexPath indexPathForItem:0 inSection:selectedDateIndexPath.section];
            UICollectionViewLayoutAttributes *sectionLayoutAttributes = [self.collectionView layoutAttributesForItemAtIndexPath:sectionIndexPath];
            CGPoint origin = sectionLayoutAttributes.frame.origin;
            origin.x = 0;
            origin.y -= (PDTSimpleCalendarFlowLayoutHeaderHeight + PDTSimpleCalendarFlowLayoutInsetTop + self.collectionView.contentInset.top);
            [self.collectionView setContentOffset:origin animated:animated];
        }
    }
    @catch (NSException *exception) {
        //Exception occured (it should not according to the documentation, but in reality...) let's scroll to the IndexPath then
        NSInteger section = [self sectionForDate:date];
        NSIndexPath *sectionIndexPath = [NSIndexPath indexPathForItem:0 inSection:section];
        [self.collectionView scrollToItemAtIndexPath:sectionIndexPath atScrollPosition:UICollectionViewScrollPositionTop animated:animated];
    }
}

- (void)setOverlayTextColor:(UIColor *)overlayTextColor
{
    _overlayTextColor = overlayTextColor;
    if (self.overlayView) {
        [self.overlayView setTextColor:self.overlayTextColor];
    }
}

#pragma mark - View LifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    //Configure the Collection View
    [self.collectionView registerClass:[PDTSimpleCalendarViewCell class] forCellWithReuseIdentifier:PDTSimpleCalendarViewCellIdentifier];
    [self.collectionView registerClass:[PDTSimpleCalendarViewHeader class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:PDTSimpleCalendarViewHeaderIdentifier];

    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.collectionView setBackgroundColor:self.backgroundColor];
    [self.collectionView setFrame:CGRectMake(300, 100, self.collectionView.frame.size.width-300, self.collectionView.frame.size.height-100)];
//    [self.overlayView setFrame:CGRectMake(0, 0, self.overlayView.frame.size.width-100, self.overlayView.frame.size.height-100)];
//    //Configure the Overlay View
//    [self.overlayView setBackgroundColor:[self.backgroundColor colorWithAlphaComponent:0.90]];
//    [self.overlayView setFont:[UIFont boldSystemFontOfSize:PDTSimpleCalendarOverlaySize]];
//    [self.overlayView setTextColor:self.overlayTextColor];
//    [self.overlayView setAlpha:0.0];
//
//    [self.overlayView setTextAlignment:NSTextAlignmentCenter];
//
//    [self.view addSubview:self.overlayView];
//    [self.overlayView setTranslatesAutoresizingMaskIntoConstraints:NO];
   // NSDictionary *viewsDictionary = @{@"overlayView": self.overlayView};
  //  NSDictionary *metricsDictionary = @{@"overlayViewHeight": @(PDTSimpleCalendarFlowLayoutHeaderHeight)};

//    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[overlayView]|" options:NSLayoutFormatAlignAllTop metrics:nil views:viewsDictionary]];
//    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[overlayView(==overlayViewHeight)]" options:NSLayoutFormatAlignAllTop metrics:metricsDictionary views:viewsDictionary]];
    
    //Update Content of the Overlay View
    NSArray *indexPaths = [self.collectionView indexPathsForVisibleItems];
    //indexPaths is not sorted
    NSArray *sortedIndexPaths = [indexPaths sortedArrayUsingSelector:@selector(compare:)];
    NSIndexPath *firstIndexPath = [sortedIndexPaths firstObject];
    
    isTableViewVisible = YES;
    
    self.monthLabel.text =[self.headerDateFormatter stringFromDate:[self firstOfMonthForSection:firstIndexPath.section]];

    self.sourceTable.delegate = self;
    self.sourceTable.dataSource = self;
    self.tableData = @[
                       @"Staples",
                       @"Future Shop",
                       @"Sobeys",
                       @"No Frills",
                       @"Superstore",
                       @"Kraft",
                       @"Maple Leaf",
                       @"Tim Hortons",
                       @"Panera Bread"
                       ];
    
    self.collectionData = [NSMutableArray arrayWithCapacity:420];
    
    for (int i = 0; i < 420; i++)
    {
        NSMutableArray *entries = [NSMutableArray arrayWithCapacity:4];

        CalendarItemAdvanced *item;
        item = [[CalendarItemAdvanced alloc] initWithDate:nil entries:entries andSectionIs:nil];
        [self.collectionData addObject:item];
    }
    
    /* Configure the helper */
    
    self.helper = [[I3DragBetweenHelper alloc] initWithSuperview:self.view
                                                         srcView:self.sourceTable
                                                         dstView:self.collectionView];
    
    self.helper.delegate = self;
    
    self.helper.isDstRearrangeable = NO;
    self.helper.isSrcRearrangeable = YES;
    self.helper.doesSrcRecieveDst = NO;
    self.helper.doesDstRecieveSrc = YES;
    self.helper.hideDstDraggingCell = NO;
    self.helper.hideSrcDraggingCell = NO;
}

// Don't switch to the week view if no date is selected
- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if (!_selectedDate)
    {
        //I moved this stuff to the bottom in the Segmented control
        return NO;
    }
    else
    {
        return YES;
    }
}

// This method is skipped if the previous one returns NO
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Figure out the dates for the week of the currently selected date
    NSCalendar *gregorian = self.calendar;
    NSDateComponents *currentComps =[gregorian components:(NSYearCalendarUnit |
                                                                NSWeekdayCalendarUnit |
                                                                NSMonthCalendarUnit |
                                                                NSWeekOfYearCalendarUnit |
                                                                NSWeekdayCalendarUnit |
                                                                NSHourCalendarUnit |
                                                                NSMinuteCalendarUnit)
                                                      fromDate:_selectedDate];
    // To store the calendar items for this particular week
    NSMutableArray *weekCalendarData = [NSMutableArray arrayWithCapacity:7];
    // Gather the calendar items for this week only (kind of inefficient!)
    for (int i = 1; i < 8; i++)
    {
        for (CalendarItemAdvanced *item in _collectionData)
        {
            // Skip the calendar items for disabled dates (i.e. blank spots)
            if (item.date)
            {
                [currentComps setWeekday:i]; // 1: Sunday, 2: Monday, etc.
                NSDate *dayOfTheWeek = [gregorian dateFromComponents:currentComps];
                if ([item.date compare:dayOfTheWeek] == NSOrderedSame)
                {
                    [weekCalendarData addObject:item];
                    break;
                }
            }
        }
    }
    self.weeklyController = (MAWeekViewController *)segue.destinationViewController;
    self.weeklyController.weekCalendarData = weekCalendarData;
    self.weeklyController.delegate = self;
}


#pragma mark - MAWeekViewController delegate methods

// Receives updated calendar items from week view and subsequently
// updates the collection data for the month calendar
- (void)updateCollectionDataWithCalendarItems:(NSArray *)items
{
    NSLog(@"Month collection data updated!");
}


#pragma mark - Drag n drop exchange and rearrange delegate methods

-(void) droppedOnDstAtIndexPath:(NSIndexPath*) to fromSrcIndexPath:(NSIndexPath*)from
{
    /* Grab the appropriate data */
    NSInteger fromIndex = (from.item);
    NSInteger toIndex = (to.item);
    NSNumber *startingPoint = [NSNumber numberWithInt:0];
    if (to.section!=0) {
        startingPoint = [NSNumber numberWithInt:to.section *35];
    }
    
    NSNumber * numberForLater = [NSNumber numberWithInt:[startingPoint integerValue]+toIndex];
    NSInteger myInt = [numberForLater integerValue];
    
    // Disable drag and drop on invalid calendar cells
    
//    if (toIndex < 5 || toIndex > 36)
//    {
//        return;
//    }
    // Don't allow more than 4 names in a calendar item
    CalendarItemAdvanced *item = [self.collectionData objectAtIndex:myInt];
    if (item.entries.count > 3)
    {
        [[[UIAlertView alloc] initWithTitle:@"Invalid" message:@"Only 4 items per day!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        return;
    }
    NSString *name = [self.tableData objectAtIndex:fromIndex];
    MAEvent *event = [self eventFromString:name forCalendarItem:item];
    
   // item.section = sectionNumber;
    /* Update the data and collections accordingly */
    [item.entries addObject:event];
    
    [self.collectionView reloadData];
}

-(BOOL) droppedOutsideAtPoint:(CGPoint) pointIn fromDstIndexPath:(NSIndexPath*) from
{
    return YES;
}

-(void) droppedOnDstAtIndexPath:(NSIndexPath*) to fromDstIndexPath:(NSIndexPath*) from{
    
    [self.collectionView cellForItemAtIndexPath:from].alpha = 1;
    
    NSInteger fromIndex = (from.item);
    NSInteger toIndex = (to.item);
    
    [self.collectionData exchangeObjectAtIndex:toIndex withObjectAtIndex:fromIndex];
    
}

-(BOOL) isCellAtIndexPathDraggable:(NSIndexPath*) index inContainer:(UIView*) container
{
 //       return YES;
          return (container == self.collectionView) ? NO : YES;
   // }
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


#pragma mark - Rotation Handling

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self.collectionView.collectionViewLayout invalidateLayout];
}


#pragma mark - Collection View Data Source

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    //Each Section is a Month
    return [self.calendar components:NSMonthCalendarUnit fromDate:self.firstDateMonth toDate:self.lastDateMonth options:0].month + 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSDate *firstOfMonth = [self firstOfMonthForSection:section];
    NSRange rangeOfWeeks = [self.calendar rangeOfUnit:NSWeekCalendarUnit inUnit:NSMonthCalendarUnit forDate:firstOfMonth];

    //We need the number of calendar weeks for the full months (it will maybe include previous month and next months cells)
    return (rangeOfWeeks.length * self.daysPerWeek);
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PDTSimpleCalendarViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:PDTSimpleCalendarViewCellIdentifier
               
                                                                                     forIndexPath:indexPath];
    NSNumber *startingPoint = [NSNumber numberWithInt:0];
    if (indexPath.section!=0) {
        startingPoint = [NSNumber numberWithInt:indexPath.section *35];
    }
    
    NSNumber * numberForLater = [NSNumber numberWithInt:[startingPoint integerValue]+indexPath.item];
    NSInteger myInt = [numberForLater integerValue];
    CalendarItemAdvanced *item = (CalendarItemAdvanced *)[self.collectionData objectAtIndex:myInt];

    cell.delegate = self;
    
    NSDate *firstOfMonth = [self firstOfMonthForSection:indexPath.section];
    NSDate *cellDate = [self dateForCellAtIndexPath:indexPath];

    NSDateComponents *cellDateComponents = [self.calendar components:NSDayCalendarUnit|NSMonthCalendarUnit fromDate:cellDate];
    NSDateComponents *firstOfMonthsComponents = [self.calendar components:NSMonthCalendarUnit fromDate:firstOfMonth];

    BOOL isToday = NO;
    BOOL isSelected = NO;
    BOOL isCustomDate = NO;

    if (cellDateComponents.month == firstOfMonthsComponents.month)
    {
        isSelected = ([self isSelectedDate:cellDate] && (indexPath.section == [self sectionForDate:cellDate]));
        isToday = [self isTodayDate:cellDate];
        [cell setDate:cellDate calendar:self.calendar];

        //Ask the delegate if this date should have specific colors.
        if ([self.delegate respondsToSelector:@selector(simpleCalendarViewController:shouldUseCustomColorsForDate:)]) {
            isCustomDate = [self.delegate simpleCalendarViewController:self shouldUseCustomColorsForDate:cellDate];
        }
        // Add the date to the calendar item if it's nil
        if (!item.date)
        {
            item.date = cellDate;
        }

    }
    else
    {
        [cell setDate:nil calendar:nil];
    }

    if (isToday) {
        [cell setIsToday:isToday];
    }

    if (isSelected) {
        [cell setSelected:isSelected];
    }

    //If the current Date is not enabled, or if the delegate explicitely specify custom colors
    if (![self isEnabledDate:cellDate] || isCustomDate) {
        [cell refreshCellColors];
    }

    //We rasterize the cell for performances purposes.
    //The circle background is made using roundedCorner which is a super expensive operation, specially with a lot of items on the screen to display (like we do)
    cell.layer.shouldRasterize = YES;
    cell.layer.rasterizationScale = [UIScreen mainScreen].scale;
    // We need to get the titles from each event in this calendar item
    NSMutableArray *entries = [NSMutableArray arrayWithCapacity:4];
    for (MAEvent *event in item.entries)
    {
        [entries addObject:event.title];
    }
    [cell.informationLabel setText:[entries componentsJoinedByString:@"\n"]];
    [cell.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [cell.layer setBorderWidth:.3f];

    return cell;
}

#pragma mark - UICollectionViewDelegate

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSDate *firstOfMonth = [self firstOfMonthForSection:indexPath.section];
    NSDate *cellDate = [self dateForCellAtIndexPath:indexPath];

    //We don't want to select Dates that are "disabled"
    if (![self isEnabledDate:cellDate]) {
        return NO;
    }

    NSDateComponents *cellDateComponents = [self.calendar components:NSDayCalendarUnit|NSMonthCalendarUnit fromDate:cellDate];
    NSDateComponents *firstOfMonthsComponents = [self.calendar components:NSMonthCalendarUnit fromDate:firstOfMonth];

    return (cellDateComponents.month == firstOfMonthsComponents.month);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedDate = [self dateForCellAtIndexPath:indexPath];
}


- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if (kind == UICollectionElementKindSectionHeader) {
        PDTSimpleCalendarViewHeader *headerView = [self.collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:PDTSimpleCalendarViewHeaderIdentifier forIndexPath:indexPath];

        headerView.titleLabel.text = [self.headerDateFormatter stringFromDate:[self firstOfMonthForSection:indexPath.section]].uppercaseString;

        headerView.layer.shouldRasterize = YES;
        headerView.layer.rasterizationScale = [UIScreen mainScreen].scale;

        return headerView;
    }

    return nil;
}

#pragma mark - UICollectionViewFlowLayoutDelegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat itemWidth = floorf(CGRectGetWidth(self.collectionView.bounds) / self.daysPerWeek);

    return CGSizeMake(itemWidth - .5f, itemWidth - .5f);
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    //We only display the overlay view if there is a vertical velocity
    if ( fabsf(velocity.y) > 0.0f) {
        if (self.overlayView.alpha < 1.0) {
            [UIView animateWithDuration:0.25 animations:^{
                [self.overlayView setAlpha:1.0];
            }];
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    NSTimeInterval delay = (decelerate) ? 1.5 : 0.0;
    [self performSelector:@selector(hideOverlayView) withObject:nil afterDelay:delay];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //Update Content of the Overlay View
    NSArray *indexPaths = [self.collectionView indexPathsForVisibleItems];
    //indexPaths is not sorted
    NSArray *sortedIndexPaths = [indexPaths sortedArrayUsingSelector:@selector(compare:)];
    NSIndexPath *firstIndexPath = [sortedIndexPaths firstObject];
    self.monthLabel.text =[self.headerDateFormatter stringFromDate:[self firstOfMonthForSection:firstIndexPath.section]];
    self.overlayView.text = [self.headerDateFormatter stringFromDate:[self firstOfMonthForSection:firstIndexPath.section]];
}

- (void)hideOverlayView
{
    [UIView animateWithDuration:0.25 animations:^{
        [self.overlayView setAlpha:0.0];
    }];
}

#pragma mark -
#pragma mark - Calendar calculations

- (NSDate *)clampDate:(NSDate *)date toComponents:(NSUInteger)unitFlags
{
    NSDateComponents *components = [self.calendar components:unitFlags fromDate:date];
    return [self.calendar dateFromComponents:components];
}

- (BOOL)isTodayDate:(NSDate *)date
{
    return [self clampAndCompareDate:date withReferenceDate:[NSDate date]];
}

- (BOOL)isSelectedDate:(NSDate *)date
{
    if (!self.selectedDate) {
        return NO;
    }
    return [self clampAndCompareDate:date withReferenceDate:self.selectedDate];
}

- (BOOL)isEnabledDate:(NSDate *)date
{
    NSDate *clampedDate = [self clampDate:date toComponents:(NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit)];
    if (([clampedDate compare:self.firstDate] == NSOrderedAscending) || ([clampedDate compare:self.lastDate] == NSOrderedDescending)) {
        return NO;
    }

    return YES;
}

- (BOOL)clampAndCompareDate:(NSDate *)date withReferenceDate:(NSDate *)referenceDate
{
    NSDate *refDate = [self clampDate:referenceDate toComponents:(NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit)];
    NSDate *clampedDate = [self clampDate:date toComponents:(NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit)];

    return [refDate isEqualToDate:clampedDate];
}

#pragma mark - Collection View / Calendar Methods

- (NSDate *)firstOfMonthForSection:(NSInteger)section
{
    NSDateComponents *offset = [NSDateComponents new];
    offset.month = section;

    return [self.calendar dateByAddingComponents:offset toDate:self.firstDateMonth options:0];
}

- (NSInteger)sectionForDate:(NSDate *)date
{
    return [self.calendar components:NSMonthCalendarUnit fromDate:self.firstDateMonth toDate:date options:0].month;
}


- (NSDate *)dateForCellAtIndexPath:(NSIndexPath *)indexPath
{
    NSDate *firstOfMonth = [self firstOfMonthForSection:indexPath.section];
    NSInteger ordinalityOfFirstDay = [self.calendar ordinalityOfUnit:NSDayCalendarUnit inUnit:NSWeekCalendarUnit forDate:firstOfMonth];
    NSDateComponents *dateComponents = [NSDateComponents new];
    dateComponents.day = (1 - ordinalityOfFirstDay) + indexPath.item;

    return [self.calendar dateByAddingComponents:dateComponents toDate:firstOfMonth options:0];
}


- (NSIndexPath *)indexPathForCellAtDate:(NSDate *)date
{
    if (!date) {
        return nil;
    }

    NSInteger section = [self sectionForDate:date];

    NSDate *firstOfMonth = [self firstOfMonthForSection:section];
    NSInteger ordinalityOfFirstDay = [self.calendar ordinalityOfUnit:NSDayCalendarUnit inUnit:NSWeekCalendarUnit forDate:firstOfMonth];


    NSDateComponents *dateComponents = [self.calendar components:NSDayCalendarUnit fromDate:date];
    NSDateComponents *firstOfMonthComponents = [self.calendar components:NSDayCalendarUnit fromDate:firstOfMonth];
    NSInteger item = (dateComponents.day - firstOfMonthComponents.day) - (1 - ordinalityOfFirstDay);

    return [NSIndexPath indexPathForItem:item inSection:section];
}

- (PDTSimpleCalendarViewCell *)cellForItemAtDate:(NSDate *)date
{
    return (PDTSimpleCalendarViewCell *)[self.collectionView cellForItemAtIndexPath:[self indexPathForCellAtDate:date]];
}


#pragma mark PDTSimpleCalendarViewCellDelegate

- (BOOL)simpleCalendarViewCell:(PDTSimpleCalendarViewCell *)cell shouldUseCustomColorsForDate:(NSDate *)date
{
    //If the date is not enabled (aka outside the first/lastDate) return YES
    if (![self isEnabledDate:date]) {
        return YES;
    }

    //Otherwise we ask the delegate
    if ([self.delegate respondsToSelector:@selector(simpleCalendarViewController:shouldUseCustomColorsForDate:)]) {
        return [self.delegate simpleCalendarViewController:self shouldUseCustomColorsForDate:date];
    }
    return NO;
}

- (UIColor *)simpleCalendarViewCell:(PDTSimpleCalendarViewCell *)cell circleColorForDate:(NSDate *)date
{
    if (![self isEnabledDate:date]) {
        return cell.circleDefaultColor;
    }

    if ([self.delegate respondsToSelector:@selector(simpleCalendarViewController:circleColorForDate:)]) {
        return [self.delegate simpleCalendarViewController:self circleColorForDate:date];
    }
    return nil;
}

- (UIColor *)simpleCalendarViewCell:(PDTSimpleCalendarViewCell *)cell textColorForDate:(NSDate *)date
{
    if (![self isEnabledDate:date]) {
        return cell.textDisabledColor;
    }

    if ([self.delegate respondsToSelector:@selector(simpleCalendarViewController:textColorForDate:)]) {
        return [self.delegate simpleCalendarViewController:self textColorForDate:date];
    }
    return nil;
}


#pragma mark - Slide the table view left or right to hide/unhide it

-(IBAction)hideView:(id)sender
{
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:.5];
    [UIView setAnimationDelay:0];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    
    if (self.sourceTable.frame.origin.x == 115)
    {
        isTableViewVisible = NO;
        self.sourceTable.frame = CGRectMake(115-290, 211, 290, 556);
        self.locationsTitleBar.frame = CGRectMake(115-290, 109, 290, 101);
        self.locationsLabel.frame = CGRectMake(115-290, 168, 100, 21);
        self.monthLabel.frame = CGRectMake(456, 81, 162, 19);
        self.weekImage.frame = CGRectMake(115, 109, 909, 34);
        self.collectionView.frame = CGRectMake(115, 146, 909, 621);
    }
    else
    {
        isTableViewVisible = YES;
        self.sourceTable.frame = CGRectMake(115, 211, 290, 556);
        self.locationsLabel.frame = CGRectMake(115, 168, 100, 21);
        self.locationsTitleBar.frame = CGRectMake(115, 109, 290, 101);
        self.monthLabel.frame = CGRectMake(633, 134, 162, 19);
        self.weekImage.frame = CGRectMake(405, 202, 619, 34);
        self.collectionView.frame = CGRectMake(405, 237, 619, 531);
    }
    
    [UIView commitAnimations];
    [self.collectionView reloadData];
}


#pragma mark - Convenience methods

- (MAEvent *)eventFromString:(NSString *)title forCalendarItem:(CalendarItemAdvanced *)item
{
    NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:item.date];
    
	MAEvent *event = [[MAEvent alloc] init];
	event.backgroundColor = [UIColor brownColor];
	event.textColor = [UIColor whiteColor];
	event.allDay = NO;
    event.title = title;
    [components setHour:4*item.entries.count+1];
    [components setMinute:0];
    [components setSecond:0];
    event.start = [CURRENT_CALENDAR dateFromComponents:components];
    [components setHour:4*item.entries.count+3];
    event.end = [CURRENT_CALENDAR dateFromComponents:components];
    
	return event;
}



- (IBAction)segmentControlPressed:(UISegmentedControl *)sender {
    
    //If we go back to the monthview and change the weekly view to hidden
    if (sender.selectedSegmentIndex==0) {
        [self.weeklyController.view removeFromSuperview];
        self.weeklyViewContainer.hidden = YES;
    }
    else{
        //If the selected date is nil then we just alert and keep the segment
        if (!_selectedDate)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid" message:@"No date has been selected" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            [sender setSelectedSegmentIndex:0];
        }
        //Else if the weekly has not been shown call the
        else{
            [self performSegueWithIdentifier:@"weeklyContainer" sender:self];
            [self.weeklyViewContainer setHidden :NO];
        }
    }
}
@end
