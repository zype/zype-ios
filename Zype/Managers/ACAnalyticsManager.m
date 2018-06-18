//
//  ACAnalyticsManager.m
//  Zype
//
//  Created by ZypeTech on 2/12/18.
//  Copyright © 2018 Zype. All rights reserved.
//

#import "ACAnalyticsManager.h"
#import "ACStatusManager.h"

@implementation ACAnalyticsManager


#pragma mark - Singleton

//if beaconUrl is NULL analytics will not start
- (NSString *)beaconFromParsedDictionary:(NSDictionary *)dictionary {
    
    NSDictionary *response = [UIUtil dict:dictionary valueForKey:kAppKey_Response];
    NSDictionary *body = [UIUtil dict:response valueForKey:kAppKey_Body];
    NSDictionary *analytics = [UIUtil dict:body valueForKey:kAppKey_Analytics];
    NSString *beaconUrl = [UIUtil dict:analytics valueForKey:kAppKey_Beacon];
    
    NSDictionary *dimensions = [UIUtil dict:analytics valueForKey:kAppKey_Dimensions];
    self.siteId = [UIUtil dict:dimensions valueForKey:kAppKey_SiteId];
    self.videoId = [UIUtil dict:dimensions valueForKey:kAppKey_VideoId];
    
    //we want to initilize Akamai only once
    if (beaconUrl && !self.initialized){
        [AKAMMediaAnalytics_Av initWithConfigURL:[[NSURL alloc] initWithString:beaconUrl]];
        self.initialized = YES;
    }
    
    return beaconUrl;
    
}

- (void)deinitAkamaiTracking {
    [AKAMMediaAnalytics_Av deinitMASDK];
    self.initialized = NO;
}

- (void) setupAkamaiMediaAnalytics:videoPlayer withVideo:(Video*)video
{
    if ([ACStatusManager isUserSignedIn]){
        [AKAMMediaAnalytics_Av setViewerId:[[NSUserDefaults standardUserDefaults] stringForKey:kSettingKey_ConsumerId]];
    }
    
     NSMutableDictionary *customData = [[NSMutableDictionary alloc]initWithObjectsAndKeys:
                                        self.siteId, @"siteId",
                                        self.videoId, @"videoId",
                                        nil];
    
    if ([ACStatusManager isUserSignedIn]){
        [customData setObject:[[NSUserDefaults standardUserDefaults] stringForKey:kSettingKey_ConsumerId] forKey:@"consumerId"];
    }
    
    if (customData) {
        id key;
        for (key in customData) {
            [AKAMMediaAnalytics_Av setData:key value:[customData objectForKey:key]];
        }
    }
    
    [AKAMMediaAnalytics_Av processWithAVPlayer:videoPlayer];
}

+ (void) playbackCompleted {
    [AKAMMediaAnalytics_Av AVPlayerPlaybackCompleted];
}

+ (ACAnalyticsManager *)sharedInstance {
    
    static ACAnalyticsManager *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[[self class] alloc] init];
    });
    
    return _sharedInstance;
}

@end
