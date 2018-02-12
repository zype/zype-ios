//
//  ACAnalyticsManager.h
//  Zype
//
//  Created by ZypeTech on 2/12/18.
//  Copyright © 2018 Zype. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AKAMMediaAnalytics_Av.h"

@interface ACAnalyticsManager : NSObject

//Akamai Engagement classes
+ (void)initAkamaiWithConfigURL:(NSURL *)url;
+ (void)deinitAkamaiTracking;
+ (void) setupAkamaiMediaAnalytics:videoPlayer withViewerId:(NSString*)viewerId withCustomData:(NSMutableDictionary*)customData;
+ (void) playbackCompleted;

//Singleton
+ (ACAnalyticsManager *)sharedInstance;

@end
