//
//  NSMutableArray+LimitedStack.m
//
//  Created by ZypeTech on 7/22/15.
//  Copyright (c) 2015 Zype. All rights reserved.
//

#import "NSMutableArray+LimitedStack.h"

@implementation NSMutableArray (LimitedStack)

- (id)pop
{
    
    id lastObject = [self lastObject];
    if (lastObject != nil){
        [self removeLastObject];
    }
    return lastObject;
    
}

- (void)push:(id)obj
{
    
    [self addObject: obj];
    
    if (self.count > 10) {
        [self pop];
    }
    
}


@end
