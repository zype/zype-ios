//
//  NSURLResponse+AK.m
//  Havoc
//
//  Created by ZypeTech on 8/2/16.
//  Copyright © 2016 Zype. All rights reserved.
//

#import "NSURLResponse+AK.h"

@implementation NSURLResponse (AK)

- (BOOL)isStatusFamilyInformational{
    return [self compareStatusCodeWithInt:1];
}

- (BOOL)isStatusFamilySuccessful{
    return [self compareStatusCodeWithInt:2];
}

- (BOOL)isStatusFamilyRedirection{
    return [self compareStatusCodeWithInt:3];
}

- (BOOL)isStatusFamilyError {
    return [self compareStatusCodeWithInt:4];
}

- (BOOL)isStatusFamilyServerError{
    return [self compareStatusCodeWithInt:5];
}

- (BOOL)isStatusFamilyOther{
    return [self compareStatusCodeWithInt:6];
}

- (BOOL)compareStatusCodeWithInt:(int)number {
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) self;
    long statusCode = [httpResponse statusCode];
    if ((statusCode / 100) == number)
        return YES;
    return NO;
}



@end
