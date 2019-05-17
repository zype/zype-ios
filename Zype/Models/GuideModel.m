//
//  GuideModel.m
//  Zype
//
//  Created by Top developer on 5/8/19.
//  Copyright © 2019 Zype. All rights reserved.
//

#import "GuideModel.h"
#import "UIUtil.h"

@implementation GuideModel

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        self.gId = [dict valueForKey: kAppKey_Id];
        if ([dict valueForKey: kAppKey_Name] != [NSNull null]) {
            self.name = [dict valueForKey: kAppKey_Name];
        } else {
            self.name = @"";
        }
        if ([dict valueForKey: kAppKey_CreatedAt] != [NSNull null]) {
            self.created_at = [[UIUtil dateFormatter] dateFromString: [dict valueForKey: kAppKey_CreatedAt]];
        }
        if ([dict valueForKey: kAppKey_UpdatedAt] != [NSNull null]) {
            self.updated_at = [[UIUtil dateFormatter] dateFromString: [dict valueForKey: kAppKey_UpdatedAt]];
        }
        if ([dict valueForKey: @"video_ids"] != [NSNull null]) {
            if ([[dict valueForKey: @"video_ids"] count] > 0) {
                self.videoId = [dict valueForKey: @"video_ids"][0];
            }
        }
    }
    
    return self;
}

@end
