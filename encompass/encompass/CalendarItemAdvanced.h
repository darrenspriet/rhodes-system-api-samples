//
//  CalendarItemAdvanced.h
//  encompass
//
//  Created by Encore on 2014-04-27.
//  Copyright (c) 2014 encompass. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CalendarItemAdvanced : NSObject
@property (nonatomic, strong) NSString* date;
@property (nonatomic, strong) NSNumber* section;


@property (nonatomic, strong) NSMutableArray* entries;

-(id) initWithDate:(NSString *)date entries:(NSMutableArray *)entries andSectionIs:(NSNumber*)section;



@end
