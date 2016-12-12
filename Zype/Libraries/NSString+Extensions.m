//
//  NSString+Extensions.m
//  Zype
//
//  Created by ZypeTech on 3/9/15.
//  Copyright (c) 2015 Zype. All rights reserved.
//

#import "NSString+Extensions.h"

@implementation NSString (Extensions)

- (BOOL)stringContains:(NSString *)otherString
{
    NSRange range = [self rangeOfString:otherString];
    return range.length != 0;
}

- (NSString *)stringByStrippingHTML
{
    NSRange range;
    NSString *string = self;
    while ((range = [string rangeOfString:@"<[^>]+>|&[^;]+;" options:NSRegularExpressionSearch]).location != NSNotFound)
        string = [string stringByReplacingCharactersInRange:range withString:@""];
    return string;
}

@end
