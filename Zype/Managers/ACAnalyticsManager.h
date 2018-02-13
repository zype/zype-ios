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

@property (nonatomic) NSString *videoId;
@property (nonatomic) NSString *siteId;

//Akamai Engagement classes
- (NSString *)beaconFromParsedDictionary:(NSDictionary *)dictionary;

- (void)initAkamaiWithConfigURL:(NSURL *)url;
- (void)deinitAkamaiTracking;
- (void) setupAkamaiMediaAnalytics:videoPlayer withVideo:(Video*)video
;
+ (void) playbackCompleted;

//Singleton
+ (ACAnalyticsManager *)sharedInstance;

@end
