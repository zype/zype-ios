//
//  ACAdManager.m
//  Havoc
//
//  Created by ZypeTech on 9/14/16.
//  Copyright © 2016 Zype. All rights reserved.
//

#import "ACAdManager.h"

@implementation ACAdManager

- (NSArray *)adsArrayFromParsedDictionary:(NSDictionary *)dictionary{
    
    NSDictionary *response = [UIUtil dict:dictionary valueForKey:kAppKey_Response];
    NSDictionary *body = [UIUtil dict:response valueForKey:kAppKey_Body];
    NSDictionary *advertising = [UIUtil dict:body valueForKey:kAppKey_Advertising];
    NSArray *schedule = [UIUtil dict:advertising valueForKey:kAppKey_Schedule];
    
    self.adSchedule = schedule;
    
    return schedule;
    
}

#pragma mark - Singleton

+ (ACAdManager *)sharedInstance {
    
    static ACAdManager *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[[self class] alloc] init];
    });
    
    return _sharedInstance;
}

@end
