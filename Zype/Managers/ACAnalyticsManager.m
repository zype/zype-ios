//
//  ACAnalyticsManager.m
//  Zype
//
//  Created by ZypeTech on 2/12/18.
//  Copyright © 2018 Zype. All rights reserved.
//

#import "ACAnalyticsManager.h"

@implementation ACAnalyticsManager


#pragma mark - Singleton

+ (void)initAkamaiWithConfigURL:(NSURL *)url {
     [AKAMMediaAnalytics_Av initWithConfigURL:url];
}

+ (void)deinitAkamaiTracking {
    [AKAMMediaAnalytics_Av deinitMASDK];
}

+ (void) setupAkamaiMediaAnalytics:videoPlayer withViewerId:(NSString*)viewerId withCustomData:(NSMutableDictionary*)customData
{
    if (viewerId) {
        [AKAMMediaAnalytics_Av setViewerId:viewerId];
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
