//
//  Timeline.m
//  Zype
//
//  Created by ZypeTech on 2/3/15.
//  Copyright (c) 2015 Zype. All rights reserved.
//

#import "Timeline.h"

@implementation Timeline

- (id)initWithStart:(NSNumber *)start
                End:(NSNumber *)end
              Title:(NSString *)title
{
    if (self)
    {
        self.start = start;
        self.end = end;
        self.title = title;
    }
    
    return self;
}

@end
