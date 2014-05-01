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
@synthesize delegate = _delegate;

/* Implementation for the MAWeekViewDataSource protocol */

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
	[self.delegate updateCollectionDataWithCalendarItems:nil];
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:event.title
                                                    message:eventInfo delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
}

- (void)viewDidLoad
{
    _weekView.delegate = self;
    _weekView.dataSource = self;
    // Set the correct week to display (based on received data)
    _weekView.week = ((CalendarItemAdvanced *)[_weekCalendarData firstObject]).date;
    for (CalendarItemAdvanced *item in _weekCalendarData)
    {
        if (item.entries.count > 0)
        {
            MAEvent *event = (MAEvent *)[item.entries objectAtIndex:0];
            event.title = @"Dilip";
        }
    }
}

- (IBAction)back:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
