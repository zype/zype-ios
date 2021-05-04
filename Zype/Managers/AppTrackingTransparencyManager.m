//
//  AppTrackingTransparencyManager.m
//  Zype
//
//  Created by Anish Kumar on 27/04/21.
//  Copyright © 2021 Zype. All rights reserved.
//

#import "AppTrackingTransparencyManager.h"
#import <AdSupport/ASIdentifierManager.h>
#import <AppTrackingTransparency/AppTrackingTransparency.h>

@implementation AppTrackingTransparencyManager

+ (void)requestIFDA:(void (^)(NSString * idfa))completion {
    if (@available(iOS 14, *)) {
        [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status) {
            if (status == ATTrackingManagerAuthorizationStatusAuthorized) {
                completion([[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString]);
            } else {
                completion(@"");
            }
        }];
    } else {
        if ([[ASIdentifierManager sharedManager] isAdvertisingTrackingEnabled]) {
            completion([[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString]);
        } else {
            completion(@"");
        }
    }
}

@end
