/*
 * Copyright (c) 2010-2012 Matias Muhonen <mmu@iki.fi>
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. The name of the author may not be used to endorse or promote products
 *    derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 * OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 * IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
 * NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
 * THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "MAWeekViewController.h"
#import "MAWeekView.h"
#import "MAEvent.h"
#import "MAEventKitDataSource.h"

// Uncomment the following line to use the built in calendar as a source for events:
//#define USE_EVENTKIT_DATA_SOURCE 1

@interface MAWeekViewController(PrivateMethods)

@property (readonly) MAEvent *event;
@property (readonly) MAEventKitDataSource *eventKitDataSource;

@end


@implementation MAWeekViewController

@synthesize weekCalendarData = _weekCalendarData;




#pragma mark - MAWeekViewDataSource methods

#ifdef USE_EVENTKIT_DATA_SOURCE

- (NSArray *)weekView:(MAWeekView *)weekView eventsForDate:(NSDate *)startDate
{
    return [self.eventKitDataSource weekView:weekView eventsForDate:startDate];
}

#else

// This method gets called when the week calendar comes into view for each day
// of the current week so this allows us to retrieve the events from the month view
- (NSArray *)weekView:(MAWeekView *)weekView eventsForDate:(NSDate *)startDate
{
    CalendarItemAdvanced *calendarItem = nil;
    // Find a calendar item in our data that matches this date
    for (CalendarItemAdvanced *item in _weekCalendarData)
    {
        if ([item.date compare:startDate] == NSOrderedSame)
        {
            calendarItem = item;
            break;
        }
    }
    return calendarItem.entries;
}

#endif


// Creates an empty event
- (MAEvent *)event
{
	static int counter;
	NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
	[dict setObject:[NSString stringWithFormat:@"number %i", counter++] forKey:@"test"];
	MAEvent *event = [[MAEvent alloc] init];
	event.backgroundColor = [UIColor brownColor];
	event.textColor = [UIColor whiteColor];
	event.allDay = NO;
    event.userInfo = dict;
	return event;
}

- (MAEventKitDataSource *)eventKitDataSource
{
    if (!_eventKitDataSource)
    {
        _eventKitDataSource = [[MAEventKitDataSource alloc] init];
    }
    return _eventKitDataSource;
}

#pragma mark - MAWeekViewDelegate methods

- (void)weekView:(MAWeekView *)weekView eventTapped:(MAEvent *)event andView:(UIView *)view
{
    self.theView = view;
    _eventToEdit = event;
	UIAlertView *alert1 = [[UIAlertView alloc] initWithTitle:event.title
                                                    message:@"Manage event!"
                                                   delegate:self cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Edit", @"Delete", nil];
    _alertView = alert1;
    [_alertView show];
    
    

}

- (void)weekView:(MAWeekView *)weekView eventDragged:(MAEvent *)event
{
    // Snap event to one hour intervals (just for visualization, we can change this later)
    NSDateComponents *startComponents = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:event.start];
    startComponents.second = 0;
    NSDateComponents *endComponents = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:event.end];
    endComponents.second = 0;
    event.start = [event.start dateByAddingTimeInterval:-startComponents.minute * 60];
    event.end = [event.end dateByAddingTimeInterval:-startComponents.minute * 60];
    // We need to rebuild the week's calendar data because the day component
    // may have changed (i.e. if they moved an event to another day)
    NSMutableArray *events = [NSMutableArray arrayWithCapacity:30];
    // First, we begin by gathering all the events into one array
    for (CalendarItemAdvanced *item in _weekCalendarData)
    {
        for (MAEvent *event in item.entries)
        {
            [events addObject:event];
        }
        [item.entries removeAllObjects];
    }
    // Sort the events by their start dates (this will ensure that
    // monthly view preserves event sequencing for a given day, assuming
    // of course that the "for in" loop iterates in the correct order!)
    NSSortDescriptor* sortByDate = [NSSortDescriptor sortDescriptorWithKey:@"start"
                                                                 ascending:YES];
    [events sortUsingDescriptors:[NSArray arrayWithObject:sortByDate]];
    // Next, we loop through the events and determine which calendar
    //item they should belong to
    NSDateComponents *dayComponent;
    NSDate *eventDateOnly; // ignore time components
    NSDate *itemDateOnly; // ignore time components
    for (MAEvent *event in events)
    {
        for (CalendarItemAdvanced *item in _weekCalendarData)
        {
            dayComponent = [CURRENT_CALENDAR components:NSDayCalendarUnit
                                             fromDate:item.date];
            itemDateOnly = [CURRENT_CALENDAR dateFromComponents:dayComponent];
            dayComponent = [CURRENT_CALENDAR components:NSDayCalendarUnit
                                             fromDate:event.start];
            eventDateOnly = [CURRENT_CALENDAR dateFromComponents:dayComponent];
            // Now, it is safe to compare the two!  So, if this event has the
            // same date as this item, then add it to its entries
            if ([itemDateOnly compare:eventDateOnly] == NSOrderedSame)
            {
                [item.entries addObject:event];
            }
        }
    }
    
    [weekView reloadData];
    startComponents = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:event.start];
	NSString *eventInfo = [NSString stringWithFormat:@"Event dragged to %02li:%02li. Userinfo: %@", (long)[startComponents hour], (long)[startComponents minute], [event.userInfo objectForKey:@"test"]];
    
//	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:event.title
//                                                    message:eventInfo delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//	[alert show];
}

- (void)viewDidLoad
{
    _weekView.delegate = self;
    _weekView.dataSource = self;
    // Set the correct week to display (based on received data)
    _weekView.week = ((CalendarItemAdvanced *)[_weekCalendarData firstObject]).date;
}


- (IBAction)back:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - UIAlertViewDelegate methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{

    if(alertView == _alertView)
    {
        //Main alert with different options
        if (buttonIndex == 2)
        {
            
            // Locate the weekday item that contains this event
            CalendarItemAdvanced *itemWithEvent;
            for (CalendarItemAdvanced *item in _weekCalendarData)
            {
                for (MAEvent *event in item.entries)
                {
                    // Found the item!
                    if (event == _eventToEdit)
                    {
                        itemWithEvent = item;
                    }
                }
            }
            // Remove the event
            [itemWithEvent.entries removeObject:_eventToEdit];
            // Refresh the view
            [_weekView reloadData];
            
        }
        else if(buttonIndex==1)
        {
            // Locate the weekday item that contains this event
            CalendarItemAdvanced *itemWithEvent;
            for (CalendarItemAdvanced *item in _weekCalendarData)
            {
                for (MAEvent *event in item.entries)
                {
                    // Found the item!
                    if (event == _eventToEdit)
                    {
                        itemWithEvent = item;
                        
                        NSString *startDate, *endDate, *longString;
                        
                        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                        [dateFormatter setDateStyle:NSDateFormatterLongStyle];
                        startDate = [dateFormatter stringFromDate:event.start];
                        
                        NSDateFormatter *dateFormatter1 = [[NSDateFormatter alloc] init];
                        [dateFormatter setDateStyle:NSDateFormatterLongStyle];
                        endDate = [dateFormatter1 stringFromDate:event.end];
                        
                        longString = [startDate stringByAppendingString:endDate];
                        
                        
                        UIAlertView *alert2 = [[UIAlertView alloc] initWithTitle:event.title
                                                                         message:longString
                                                                        delegate:self cancelButtonTitle:@"Cancel"
                                                               otherButtonTitles:@"Edit Start", @"Edit End", nil];
                        [alert2 show];

                    }
                }
            }
        }
    }
    else
    {//alertComment
        if (buttonIndex == 0)
        {

            NSLog(@"Cancel");
        }
        else if (buttonIndex == 1)
        {
            IQActionSheetPickerView *picker = [[IQActionSheetPickerView alloc] initWithTitle:@"Edit Start Time" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil, nil];
            [picker setActionSheetPickerStyle:IQActionSheetPickerStyleDatePicker];
            picker.tag = 1;
            picker.eventDate = _eventToEdit.start;
            [picker showInView:self.view];
        }
        else if (buttonIndex == 2)
        {
            IQActionSheetPickerView *picker = [[IQActionSheetPickerView alloc] initWithTitle:@"Edit End Time" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil, nil];
            [picker setActionSheetPickerStyle:IQActionSheetPickerStyleDatePicker];
            picker.tag = 2;
            picker.eventDate = _eventToEdit.end;
            [picker showInView:self.view];
        }
    }
    self.theView.backgroundColor = [UIColor colorWithHue:.55 saturation:.8 brightness:1.0 alpha:.5];

}

-(void)actionSheetPickerView:(IQActionSheetPickerView *)pickerView didSelectTitles:(NSArray *)titles
{
    NSComparisonResult result;
    if (pickerView.tag == 1)
    {
        // Compare the new start date with the current end date
        result = [pickerView.date compare:_eventToEdit.end];
        if (result == NSOrderedSame || result == NSOrderedDescending)
        {
            NSLog(@"Invalid start time!");
            return;
        }
        _eventToEdit.start = pickerView.date;
    }
    else if (pickerView.tag == 2)
    {
        // Compare the new start date with the current end date
        result = [pickerView.date compare:_eventToEdit.start];
        if (result == NSOrderedSame || result == NSOrderedAscending)
        {
            NSLog(@"Invalid end time!");
            return;
        }
        _eventToEdit.end = pickerView.date;
    }
    NSLog(@"Date picker = %@", pickerView.date);
    [_weekView reloadData];
}


@end
