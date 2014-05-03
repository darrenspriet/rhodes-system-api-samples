//
//  ECCalendarContainerController.m
//  encompass
//
//  Created by Darren Spriet on 2014-05-01.
//  Copyright (c) 2014 encompass. All rights reserved.
//

#import "ECCalendarContainerController.h"

@interface ECCalendarContainerController ()

@end

@implementation ECCalendarContainerController

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
    [self setCollectionData:[[NSMutableArray alloc]init] ];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// Don't switch to the week view if no date is selected
- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if (self.monthlyViewController)
    {
        if (self.monthlyViewController.selectedDate) {
            return YES;
        }
        else{
            NSLog(@"SELECTED DATE FALSE");
            [self.weeklyViewContainer setHidden: YES];
            return NO;
        }
    }
    else
    {
        return YES;
    }
}

// This method is skipped if the previous one returns NO
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"monthlyCalendarSegue"]) {
        NSLog(@"montly");
        self.monthlyViewController= segue.destinationViewController;
        self.monthlyViewController.selectedDate = self.selectedDate;
        self.monthlyViewController.collectionData = self.collectionData;
        [self.monthlyViewController.collectionView reloadData];
    }
    if ([segue.identifier isEqualToString:@"WeeklyCalendarSegue"]) {
        NSLog(@"weekly");
        // Figure out the dates for the week of the currently selected date
        NSCalendar *gregorian = self.monthlyViewController.calendar;
        NSDateComponents *currentComps =[gregorian components:(NSYearCalendarUnit |
                                                               NSWeekdayCalendarUnit |
                                                               NSMonthCalendarUnit |
                                                               NSWeekOfYearCalendarUnit |
                                                               NSWeekdayCalendarUnit |
                                                               NSHourCalendarUnit |
                                                               NSMinuteCalendarUnit)
                                                     fromDate:self.monthlyViewController.selectedDate];
        // To store the calendar items for this particular week
        NSMutableArray *weekCalendarData = [NSMutableArray arrayWithCapacity:7];
        // Gather the calendar items for this week only (kind of inefficient!)
        for (int i = 1; i < 8; i++)
        {
            for (CalendarItemAdvanced *item in self.collectionData)
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


    }
}


- (IBAction)segmentControlPressed:(UISegmentedControl *)sender {
    
    //If we go back to the monthview and change the weekly view to hidden
    if (sender.selectedSegmentIndex==0) {
        self.showButtonOutlet.hidden = NO;
        [self performSegueWithIdentifier:@"monthlyCalendarSegue" sender:self];
        self.weeklyViewContainer.hidden =YES;
        [self.weeklyController.view removeFromSuperview];
    }
    else{
        if (self.monthlyViewController.selectedDate) {
            self.showButtonOutlet.hidden = YES;
            self.selectedDate = self.monthlyViewController.selectedDate;
            self.collectionData = self.monthlyViewController.collectionData;
            [self performSegueWithIdentifier:@"WeeklyCalendarSegue" sender:self];
            self.weeklyViewContainer.hidden = NO;
            [self.monthlyViewController.view removeFromSuperview];
        }
        else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid" message:@"No date has been selected" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            sender.selectedSegmentIndex=0;
        }
    }

}
- (IBAction)hideShowTableView:(UIButton *)sender {
    [self.monthlyViewController hideView];
}
@end
