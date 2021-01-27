//
//  Timing.m
//  Zype
//
//  Created by ZypeTech on 4/1/15.
//  Copyright (c) 2015 Zype. All rights reserved.
//

#import "Timing.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "ZypeCommon.h"

@implementation Timing

+ (void)recordTimingForOperationWithCategory:(NSString *)category andStartDate:(NSDate *)startDate andName:(NSString *)name andLabel:(NSString *)label
{
    NSDate *endDate = [NSDate date];
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    NSTimeInterval operationTime = [endDate timeIntervalSinceDate:startDate];
    [tracker send:[[GAIDictionaryBuilder createTimingWithCategory:category interval:[NSNumber numberWithInt:operationTime] name:name label:label] build]];
    
    CLS_LOG(@"Timing Operation Category: %@ Operation Time: %F Name: %@ Label: %@", category, operationTime, name, label);
}

@end
