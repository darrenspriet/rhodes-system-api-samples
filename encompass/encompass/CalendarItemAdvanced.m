//
//  CalendarItemAdvanced.m
//  encompass
//
//  Created by Encore on 2014-04-27.
//  Copyright (c) 2014 encompass. All rights reserved.
//

#import "CalendarItemAdvanced.h"

@implementation CalendarItemAdvanced

-(id) initWithDate:(NSString *)date entries:(NSMutableArray *)entries andSectionIs:(NSNumber*)section
{
    if (self = [super init])
    {
        self.date = date;
        self.entries = entries;
        self.section = section;
    }
    return self;
}

@end
