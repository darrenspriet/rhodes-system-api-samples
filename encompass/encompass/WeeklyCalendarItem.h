//
//  WeeklyCalendarItem.h
//  encompass
//
//  Created by Darren Spriet on 2014-04-22.
//  Copyright (c) 2014 encompass. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WeeklyCalendarItem : NSObject

@property (nonatomic, strong) NSString* date;

@property (nonatomic, strong) NSString* entry;

-(id) initWithDate:(NSString *)date entry:(NSString *)entry;

@end
