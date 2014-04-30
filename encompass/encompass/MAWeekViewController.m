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
#import "CalendarItemAdvanced.h"

// Uncomment the following line to use the built in calendar as a source for events:
//#define USE_EVENTKIT_DATA_SOURCE 1

#define DATE_COMPONENTS (NSYearCalendarUnit| NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekCalendarUnit |  NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit | NSWeekdayCalendarUnit | NSWeekdayOrdinalCalendarUnit)
#define CURRENT_CALENDAR [NSCalendar currentCalendar]

@interface MAWeekViewController(PrivateMethods)
@property (readonly) MAEvent *event;
@property (readonly) MAEventKitDataSource *eventKitDataSource;
@end

@implementation MAWeekViewController

@synthesize weekCalendarData = _weekCalendarData;

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

/* Implementation for the MAWeekViewDataSource protocol */

#ifdef USE_EVENTKIT_DATA_SOURCE

- (NSArray *)weekView:(MAWeekView *)weekView eventsForDate:(NSDate *)startDate {
    return [self.eventKitDataSource weekView:weekView eventsForDate:startDate];
}

#else

// This method gets called when the week calendar comes into view for each day
// of the current week so this allows us to parse our data from the month view
// and create events for each of those days.
- (NSArray *)weekView:(MAWeekView *)weekView eventsForDate:(NSDate *)startDate
{
    // An array that holds all events for this date
	NSMutableArray *arr;
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
    // If there are events available for this date
    if (calendarItem)
    {
        NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:startDate];
        arr = [NSMutableArray arrayWithCapacity:calendarItem.entries.count];
        // Iterate through the calendar item's entries and create events
        for (int i = 0; i < calendarItem.entries.count; i++)
        {
            MAEvent *event = self.event;
            event.title = [calendarItem.entries objectAtIndex:i];
            [components setHour:4*i+1];
            [components setMinute:0];
            [components setSecond:0];
            event.start = [CURRENT_CALENDAR dateFromComponents:components];
            [components setHour:4*i+3];
            event.end = [CURRENT_CALENDAR dateFromComponents:components];
            [arr addObject:event];
        }
    }
	return arr;
}

#endif

// Creates an empty event
- (MAEvent *)event {
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

- (MAEventKitDataSource *)eventKitDataSource {
    if (!_eventKitDataSource) {
        _eventKitDataSource = [[MAEventKitDataSource alloc] init];
    }
    return _eventKitDataSource;
}

/* Implementation for the MAWeekViewDelegate protocol */

- (void)weekView:(MAWeekView *)weekView eventTapped:(MAEvent *)event
{
	NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:event.start];
	NSString *eventInfo = [NSString stringWithFormat:@"Event tapped: %02li:%02li. Userinfo: %@", (long)[components hour], (long)[components minute], [event.userInfo objectForKey:@"test"]];
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:event.title
													 message:eventInfo delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
}

- (void)weekView:(MAWeekView *)weekView eventDragged:(MAEvent *)event
{
	NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:event.start];
	NSString *eventInfo = [NSString stringWithFormat:@"Event dragged to %02li:%02li. Userinfo: %@", (long)[components hour], (long)[components minute], [event.userInfo objectForKey:@"test"]];
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:event.title
                                                    message:eventInfo delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
}

- (void)viewDidLoad
{
    _weekView.delegate = self;
    _weekView.dataSource = self;
    // Verify the week data that we have recevied from the month view
    NSLog(@"\n");
    for (CalendarItemAdvanced *item in _weekCalendarData)
    {
        NSLog(@"Date = %@", item.date);
        NSLog(@"Items = \n%@", item.entries);
    }
    NSLog(@"\n");
    // Set the correct week to display (based on received data)
    _weekView.week = ((CalendarItemAdvanced *)[_weekCalendarData firstObject]).date;
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

- (IBAction)back:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
