//
//  AdRequest.m
//  Zype
//
//  Created by Александр on 23.06.17.
//  Copyright © 2017 Zype. All rights reserved.
//

#import "AdRequest.h"
#import <AVFoundation/AVFoundation.h>

@implementation AdRequest

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        NSTimeInterval playbackTime = [[dict valueForKey:@"offset"] doubleValue] / 1000;
        if (playbackTime == 0) {
            _interval = kCMTimeZero;
        } else {
            _interval = CMTimeMakeWithSeconds(playbackTime, 1000000);
        }
        _tag = [dict objectForKey:@"tag"];
    }
    
    return self;
}

- (NSTimeInterval)offset {
    return CMTimeGetSeconds(self.interval);
}

- (NSValue *)offsetValue {
    return [NSValue valueWithCMTime:_interval];
}

@end
