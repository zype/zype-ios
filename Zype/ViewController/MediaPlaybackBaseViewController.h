//
//  MediaPlaybackBaseViewController.h
//
//  Created by ZypeTech on 11/5/15.
//  Copyright © 2015 Zype. All rights reserved.
//

#import "BaseViewController.h"

@import MediaPlayer;
@import AVFoundation;

@class PlaybackSource;


@interface MediaPlaybackBaseViewController : BaseViewController<UIWebViewDelegate, WKNavigationDelegate>


@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (nonatomic, strong) AVPlayer *avPlayer;
@property (nonatomic) MPMoviePlayerController *player;
@property (nonatomic) WKWebView *wkWebViewPlayer;
@property (nonatomic) UIWebView *webViewPlayer;

@property (nonatomic) WKWebViewConfiguration *wkWebConfig;

@property (nonatomic) BOOL isAudio;
@property (nonatomic) BOOL isWebVideo;


- (void)playVideoFromSource:(PlaybackSource *)source;
- (void)removePlayer;
- (void)removeWebView;
- (void)showActivityIndicator;
- (void)hideActivityIndicator;
- (void)setupWebPlayerNotification;

- (void)moviePlayerDidExitFullscreen;

//Subclass Overrides
- (void)setupPlayer:(NSURL *)url;
- (void)setupWebPlayer:(NSURL *)url;

@end
