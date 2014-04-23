//
//  WeeklyCalendarItem.m
//  encompass
//
//  Created by Darren Spriet on 2014-04-22.
//  Copyright (c) 2014 encompass. All rights reserved.
//

#import "WeeklyCalendarItem.h"

@implementation WeeklyCalendarItem


-(id) initWithDate:(NSString *)date entry:(NSString *)entry
{
    if (self = [super init])
    {
        self.date = date;
        self.entry = entry;
    }
    return self;
}
@end
