//
//  Timing.h
//  Zype
//
//  Created by ZypeTech on 4/1/15.
//  Copyright (c) 2015 Zype. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GoogleAnalytics/GAI.h>

@interface Timing : NSObject
{
    
}

+ (void)recordTimingForOperationWithCategory:(NSString *)category andStartDate:(NSDate *)startDate andName:(NSString *)name andLabel:(NSString *)label;

// Category --> Load Time
// Interval --> x Seconds
// Name     --> Screen Name
// Label    --> Function Name

@end
