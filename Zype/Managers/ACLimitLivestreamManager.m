//
//  ACLimitLivestreamManager.m
//  Havoc
//
//  Created by ZypeTech on 9/15/16.
//  Copyright © 2016 Zype. All rights reserved.
//

#import "ACLimitLivestreamManager.h"

@implementation ACLimitLivestreamManager

- (BOOL)livestreamLimitReached {
    if ([self.played intValue] > [self.limit intValue]){
        NSLog(@"played: %@",self.played);
        return YES;
    }
    return NO;
}

- (void)livestreamStarts {
    self.starts = [NSDate date].timeIntervalSince1970;
}

- (void)livestreamStops {
    NSTimeInterval playedForDuration = [NSDate date].timeIntervalSince1970 - self.starts;
    self.played = [NSNumber numberWithInteger: (int)playedForDuration + [self.played intValue]] ;
    
    [[NSUserDefaults standardUserDefaults] setInteger:[self.played integerValue] forKey:kSettingKey_LimitLivestreamTracker];
}

#pragma mark - Singleton

+ (instancetype)sharedInstance {

static ACLimitLivestreamManager *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[[self class] alloc] init];
    });
    
    return _sharedInstance;
}



@end
