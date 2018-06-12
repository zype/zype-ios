//
//  MediaPlayerManager.h
//
//  Created by ZypeTech on 11/5/15.
//  Copyright © 2015 Zype. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MPMediaPlayback.h>

@import MediaPlayer;

@class Video;

@interface MediaPlayerManager : NSObject

@property (strong, nonatomic) MPMoviePlayerController *moviePlayerController;

- (MPMoviePlayerController *)moviePlayerControllerWithURL:(NSURL *)url video:(Video *)video image:(UIImage *)image;
- (void)setNowPlayingInfo;

//Singleton
+ (MediaPlayerManager *)sharedInstance;

@end
