//
//  GuideProgramModel.m
//  Zype
//
//  Created by Top developer on 5/8/19.
//  Copyright © 2019 Zype. All rights reserved.
//

#import "GuideProgramModel.h"

@implementation GuideProgramModel

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        self.pId = [dict valueForKey: kAppKey_Id];
        if ([dict valueForKey: kAppKey_Title] != [NSNull null]) {
            self.title = [dict valueForKey: kAppKey_Title];
        } else {
            self.title = @"";
        }
        if ([dict valueForKey: kAppKey_Description] != [NSNull null]) {
            self.pDescription = [dict valueForKey: kAppKey_Description];
        } else {
            self.pDescription = @"";
        }
        self.duration = [[dict valueForKey: @"duration"] intValue];
        if ([dict valueForKey: @"start_time"] != [NSNull null]) {
            self.startTime = [[UIUtil dateFormatter] dateFromString: [dict valueForKey: @"start_time"]];
            self.startTime = [[NSCalendar currentCalendar] dateByAddingUnit: NSCalendarUnitSecond value: -[[NSTimeZone localTimeZone] secondsFromGMT] toDate:self.startTime options:0];
        }
        if ([dict valueForKey: @"end_time"] != [NSNull null]) {
            self.endTime = [[UIUtil dateFormatter] dateFromString: [dict valueForKey: @"end_time"]];
            self.endTime = [[NSCalendar currentCalendar] dateByAddingUnit: NSCalendarUnitSecond value: -[[NSTimeZone localTimeZone] secondsFromGMT] toDate:self.endTime options:0];
        }
        if ([dict valueForKey: @"start_time_with_offset"] != [NSNull null]) {
            self.startTimeOffset = [[UIUtil dateFormatter] dateFromString: [dict valueForKey: @"start_time_with_offset"]];
            self.startTimeOffset = [[NSCalendar currentCalendar] dateByAddingUnit: NSCalendarUnitSecond value: -[[NSTimeZone localTimeZone] secondsFromGMT] toDate:self.startTimeOffset options:0];
        }
        if ([dict valueForKey: @"end_time_with_offset"] != [NSNull null]) {
            self.endTimeOffset = [[UIUtil dateFormatter] dateFromString: [dict valueForKey: @"end_time_with_offset"]];
            self.endTimeOffset = [[NSCalendar currentCalendar] dateByAddingUnit: NSCalendarUnitSecond value: -[[NSTimeZone localTimeZone] secondsFromGMT] toDate:self.endTimeOffset options:0];
        }
        if ([dict valueForKey: kAppKey_CreatedAt] != [NSNull null]) {
            self.created_at = [[UIUtil dateFormatter] dateFromString: [dict valueForKey: kAppKey_CreatedAt]];
        }
        if ([dict valueForKey: kAppKey_UpdatedAt] != [NSNull null]) {
            self.updated_at = [[UIUtil dateFormatter] dateFromString: [dict valueForKey: kAppKey_UpdatedAt]];
        }
    }
    
    return self;
}

- (BOOL) isAiring {
    return [self containsDate:[NSDate date]];
}

- (BOOL) containsDate:(NSDate*) date {
    if (self.startTimeOffset == nil || self.endTimeOffset == nil) {
        return NO;
    }
    return self.startTimeOffset == date || ([self.startTimeOffset earlierDate:date] == self.startTimeOffset && [self.endTimeOffset laterDate:date] == self.endTimeOffset && self.endTimeOffset != date);
}
@end
