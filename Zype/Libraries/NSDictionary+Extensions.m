//
//  NSDictionary+Extensions.m
//  Zype
//
//  Created by ZypeTech on 3/11/15.
//  Copyright (c) 2015 Zype. All rights reserved.
//

#import "NSDictionary+Extensions.h"

@implementation NSDictionary (Extensions)

- (id)dictValueForKey:(NSString *)key
{
    if ([self isKindOfClass:[NSDictionary class]] && self != nil && [self objectForKey:key] != nil) {
        return [self valueForKey:key];
    }
    
    return nil;
}

@end
