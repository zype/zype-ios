//
//  MediaPlayerManager.m
//
//  Created by ZypeTech on 11/5/15.
//  Copyright © 2015 Zype. All rights reserved.
//

#import <Crashlytics/Crashlytics.h>

#import "MediaPlayerManager.h"
#import "AppDelegate.h"
#import "Video.h"

@import AVFoundation;


@interface MediaPlayerManager ()

@property (nonatomic) Video *video;
@property (nonatomic) UIImage *image;

@end


@implementation MediaPlayerManager


- (MPMoviePlayerController *)moviePlayerControllerWithURL:(NSURL *)url video:(Video *)video image:(UIImage *)image{
    
    self.video = video;
    self.image = image;
    
    [self setAudioSession];
    
    self.moviePlayerController = [[MPMoviePlayerController alloc] initWithContentURL:url];
    [self.moviePlayerController prepareToPlay];
    [self.moviePlayerController setControlStyle:MPMovieControlStyleEmbedded];
    [self.moviePlayerController setFullscreen:NO];
    
    [self respondToRemoteControlEvents];
    [self setupNotifications];

    return self.moviePlayerController;
    
}

- (void)setNowPlayingInfo{
    
    MPNowPlayingInfoCenter* info = [MPNowPlayingInfoCenter defaultCenter];
    
    NSDictionary *videoInfo = [self nowPlayingInfo];
    
    info.nowPlayingInfo = videoInfo;
    
}


#pragma mark - Lifecycle

- (void)dealloc{
    
    [self stopRespondingToRemoteControlEvents];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}


#pragma mark - Audio Session

- (void)setAudioSession{
    
    // set audio session for background music
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    
    NSError *setCategoryError = nil;
    BOOL success = [audioSession setCategory:AVAudioSessionCategoryPlayback error:&setCategoryError];
    if (success) {
        
        NSError *activationError = nil;
        success = [audioSession setActive:YES error:&activationError];
        if (!success) {
            
            CLS_LOG(@"No AudioSession available!");
            CLS_LOG(@"%@", [activationError localizedDescription]);
            
        }
        
    }
    
}

#pragma mark - Notifications


- (void)setupNotifications{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayerDidEnterFullscreen) name:MPMoviePlayerDidEnterFullscreenNotification object:nil];
    
}


- (void)moviePlayerDidEnterFullscreen{
    
    [AppDelegate appDelegate].restrictRotation = NO;
    
}


#pragma mark - Remote Control Events

- (void)respondToRemoteControlEvents {
    
    MPRemoteCommandCenter *remoteCommandCenter = [MPRemoteCommandCenter sharedCommandCenter];
    [remoteCommandCenter playCommand].enabled = YES;
    [remoteCommandCenter pauseCommand].enabled = YES;
    [remoteCommandCenter previousTrackCommand].enabled = YES;
    [[remoteCommandCenter playCommand] addTarget:self action:@selector(pauseMovie)];
    [[remoteCommandCenter pauseCommand] addTarget:self action:@selector(pauseMovie)];
    [[remoteCommandCenter previousTrackCommand] addTarget:self action:@selector(goToBeginning)];
    [remoteCommandCenter nextTrackCommand].enabled = NO;
    
}

- (void)stopRespondingToRemoteControlEvents {
    
    MPRemoteCommandCenter *remoteCommandCenter = [MPRemoteCommandCenter sharedCommandCenter];
    [[remoteCommandCenter playCommand] removeTarget:self];
    [[remoteCommandCenter pauseCommand] removeTarget:self];
    [[remoteCommandCenter previousTrackCommand] removeTarget:self];
    
}

- (void)pauseMovie{
    
    if (self.moviePlayerController) {
        
        if (self.moviePlayerController.playbackState == MPMoviePlaybackStatePaused || self.moviePlayerController.playbackState == MPMoviePlaybackStateStopped){
            
            [self.moviePlayerController play];
            
        }else if(self.moviePlayerController.playbackState == MPMoviePlaybackStatePlaying){
            
            [self.moviePlayerController pause];
            
        }
        
        [self setNowPlayingInfo];
        
    }
    
}

- (void)goToBeginning{
    
    [self.moviePlayerController setCurrentPlaybackTime:0];
    [self setNowPlayingInfo];
    
}

- (NSDictionary *)nowPlayingInfo{
    
    NSMutableDictionary* newInfo = [NSMutableDictionary dictionary];
    
    NSString *title = @"Live Stream";
    NSNumber *duration = @0;
    
    if (self.video) {
        
        title = self.video.title;
        duration = self.video.duration;
        
    }
    
    [newInfo setValue:title forKey:MPMediaItemPropertyTitle];
    [newInfo setValue:duration forKey:MPMediaItemPropertyPlaybackDuration];
    
    if (self.image != nil) {
        MPMediaItemArtwork *artwork = [[MPMediaItemArtwork alloc] initWithImage:[self.image copy]];
        [newInfo setValue:artwork forKey:MPMediaItemPropertyArtwork];
    }
    
    [newInfo setValue:[NSNumber numberWithDouble:self.moviePlayerController.currentPlaybackTime] forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime];
    [newInfo setValue:[NSNumber numberWithDouble:self.moviePlayerController.currentPlaybackRate] forKey:MPNowPlayingInfoPropertyPlaybackRate];
    
    return [newInfo copy];
    
}


#pragma mark - Singleton

+ (MediaPlayerManager *)sharedInstance {
    
    static MediaPlayerManager *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[[self class] alloc] init];
    });
    
    return _sharedInstance;
}


@end
