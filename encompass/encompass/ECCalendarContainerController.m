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
    //If its the monthly we need to check
    if (self.monthlyViewController)
    {
        //If there is a date we can go to the weekly
        if (self.monthlyViewController.selectedDate)
        {
            return YES;
        }
        //If its the Segue to go to the map we also return YES
        else if([identifier isEqualToString:@"SegueToMapView"])
        {
            return YES;
        }
        //If there is no Selected Date then the weekly is still not shown
        else{
            NSLog(@"No Date Has Been Selected");
            return NO;
        }
    }
    //Otherwise going back from the weekly is fine now, but I am sure we will have to customize this
    else
    {
        return YES;
    }
}

// This method is skipped if the previous one returns NO
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //If the Segue is the Monthly one then we show the monthly controller with the data reloaded
    if ([segue.identifier isEqualToString:@"monthlyCalendarSegue"])
    {
        NSLog(@"montly");
        self.monthlyViewController= segue.destinationViewController;
        self.monthlyViewController.selectedDate = self.selectedDate;
        self.monthlyViewController.collectionData = self.collectionData;
        [self.monthlyViewController.collectionView reloadData];
    }
    //If the Segue is the Weekly one then we show the weekly controller with the data reloaded
    else if ([segue.identifier isEqualToString:@"WeeklyCalendarSegue"])
    {
        // Figure out the dates for the week of the currently selected date
        NSCalendar *gregorian = self.monthlyViewController.calendar;
        
        NSDateComponents *currentComps;
        //If todays date is used then we will use that
        if (self.todaysDate) {
            currentComps =[gregorian components:(NSYearCalendarUnit |
                                                                   NSWeekdayCalendarUnit |
                                                                   NSMonthCalendarUnit |
                                                                   NSWeekOfYearCalendarUnit |
                                                                   NSWeekdayCalendarUnit |
                                                                   NSHourCalendarUnit |
                                                                   NSMinuteCalendarUnit)
                                                         fromDate:self.monthlyViewController.todaysDate];
        }
        else{
            currentComps =[gregorian components:(NSYearCalendarUnit |
                                                                   NSWeekdayCalendarUnit |
                                                                   NSMonthCalendarUnit |
                                                                   NSWeekOfYearCalendarUnit |
                                                                   NSWeekdayCalendarUnit |
                                                                   NSHourCalendarUnit |
                                                                   NSMinuteCalendarUnit)
                                                         fromDate:self.monthlyViewController.selectedDate];
        }
        
      
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


- (IBAction)segmentControlPressed:(UISegmentedControl *)sender
{
    
    //If we go back to the monthview and change the weekly view to hidden
    if (sender.selectedSegmentIndex==0)
    {
        //We need to set the show/hide table to not hidden
        self.showButtonOutlet.hidden = NO;
        //Then preform the segue to show the Calendar
        [self performSegueWithIdentifier:@"monthlyCalendarSegue" sender:self];
        //Hide the Weekly ViewController
        self.weeklyViewContainer.hidden =YES;
        //And we need to remove it from the superview
        [self.weeklyController.view removeFromSuperview];
    }
    else{
        //If there is a selected date we do the same for weekly
        if (self.monthlyViewController.selectedDate)
        {
            //Hide the show/hide table
            self.showButtonOutlet.hidden = YES;
            //Sets the selected date to the monthly selected date
            self.selectedDate = self.monthlyViewController.selectedDate;
            //Sets the data
            self.todaysDate = nil;
            self.collectionData = self.monthlyViewController.collectionData;
            //Performs the segue
            [self performSegueWithIdentifier:@"WeeklyCalendarSegue" sender:self];
            //Sets the weekly not to hidden
            self.weeklyViewContainer.hidden = NO;
            //Removes the monthly view controller from the superview
            [self.monthlyViewController.view removeFromSuperview];
        }
        
        else{
            //Set the selected date to the Current Date?  Might be better
            
            //Hide the show/hide table
            self.showButtonOutlet.hidden = YES;
            //I thought this would be better than an alert, just show them the current date
            self.todaysDate = self.monthlyViewController.todaysDate;
            //Sets the selected date to the monthly selected date
            self.collectionData = self.monthlyViewController.collectionData;
            //Performs the segue
            [self performSegueWithIdentifier:@"WeeklyCalendarSegue" sender:self];
            //Sets the weekly not to hidden
            self.weeklyViewContainer.hidden = NO;
            //Removes the monthly view controller from the superview
            [self.monthlyViewController.view removeFromSuperview];
//            UIAlertView *alert = [[UIAlertView alloc]
//                                  initWithTitle:@"Invalid"
//                                  message:@"No date has been selected"
//                                  delegate:self
//                                  cancelButtonTitle:@"OK"
//                                  otherButtonTitles:nil];
//            [alert show];
        }
    }

}

//This method calls hide view but we need to clean it up
- (IBAction)hideShowTableView:(UIButton *)sender {
    [self.monthlyViewController hideView];
}
@end
