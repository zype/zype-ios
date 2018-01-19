//
//  MediaPlaybackBaseViewController.m
//  acumiashow
//
//  Created by ZypeTech on 11/5/15.
//  Copyright © 2015 Zype. All rights reserved.
//

#import "MediaPlaybackBaseViewController.h"
#import "AppDelegate.h"
#import "PlaybackSource.h"

@interface MediaPlaybackBaseViewController ()

@end

@implementation MediaPlaybackBaseViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    
    [self setupNotifications];
    
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [self.view setNeedsLayout];
    
}


- (void)playVideoFromSource:(PlaybackSource *)source{
    
    [self showActivityIndicator];
    
    NSURL *url = [NSURL URLWithString:source.urlString];
    
    if ([source.fileType stringContains:@"m3u8"]){
        
        [AppDelegate appDelegate].restrictRotation = NO;
        self.isWebVideo = NO;
        [self performSelectorOnMainThread:@selector(setupPlayer:) withObject:url waitUntilDone:NO];
        //  [self removeWebView];
        
    } else if ([source.fileType stringContains:@"mp4"]) {
        
        [AppDelegate appDelegate].restrictRotation = NO;
        self.isWebVideo = NO;
        [self performSelectorOnMainThread:@selector(setupPlayer:) withObject:url waitUntilDone:NO];
        
    } else if ([source.fileType stringContains:@"hls"]) {
        [AppDelegate appDelegate].restrictRotation = NO;
        
        self.isWebVideo = NO;
        
        [self performSelectorOnMainThread:@selector(setupPlayer:) withObject:url waitUntilDone:NO];
        
        
    } else if ([source.fileType stringContains:kApiKey_PlayerWeb]) {
        
        [AppDelegate appDelegate].restrictRotation = YES;
        
        self.isWebVideo = YES;
        
        [self setupWebPlayerNotification];
        [self setupWebPlayer:url];
        
    }else if ([source.fileType stringContains:@"file"]){
        
        [AppDelegate appDelegate].restrictRotation = NO;
        
        self.isWebVideo = NO;
        
        NSURL *fileURL = [NSURL fileURLWithPath:source.urlString];
        [self performSelectorOnMainThread:@selector(setupPlayer:) withObject:fileURL waitUntilDone:NO];
        //[self removeWebView];
        
    }else if ([source.fileType stringContains:@"m4a"]){
        
        [AppDelegate appDelegate].restrictRotation = NO;
        
        self.isWebVideo = NO;
        
        [self performSelectorOnMainThread:@selector(setupPlayer:) withObject:url waitUntilDone:NO];
        //[self removeWebView];
        
    }
    
}


#pragma mark - Accessors

- (WKWebViewConfiguration *)wkWebConfig{
    
    if (_wkWebConfig == nil) {
        
        NSString *jScript = @"var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);";
        
        WKUserScript *wkUScript = [[WKUserScript alloc] initWithSource:jScript injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
        WKUserContentController *wkUController = [[WKUserContentController alloc] init];
        [wkUController addUserScript:wkUScript];
        
        _wkWebConfig = [[WKWebViewConfiguration alloc] init];
        _wkWebConfig.userContentController = wkUController;
        
    }
    
    return _wkWebConfig;
    
}

#pragma mark - Removing Players

- (void)removePlayer {
    
    if (self.player != nil) {
        
        [self.player stop];
        [self.player.view removeFromSuperview];
        self.player = nil;
        
    }
}


#pragma mark - Activity Indicator

- (void)showActivityIndicator{
    [self.activityIndicator setHidden:NO];
    [self.activityIndicator setColor:[UIColor whiteColor]];
    [self.view bringSubviewToFront:self.activityIndicator];
    [self.activityIndicator startAnimating];
}

- (void)hideActivityIndicator{
    [self.activityIndicator setHidden:YES];
    [self.activityIndicator stopAnimating];
}


#pragma mark - Subclass Overrides

- (void)setupPlayer:(NSURL *)url{
    
    //Subclass Override
    
}

- (void)setupWebPlayer:(NSURL *)url{
    
    //Subclass Override
    
}

#pragma mark - Rotation Setup

- (BOOL)shouldAutorotate{
    
    return YES;
    
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    
    return UIInterfaceOrientationMaskAll;
    
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator{
    
    if (self.isWebVideo == YES || self.isAudio == YES) {
        return;
    }
    
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context){
        
        UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
        
        switch (orientation) {
                
            case UIInterfaceOrientationPortrait: {
                
                [self.player setFullscreen:NO];
                
            }
                break;
                
            case UIInterfaceOrientationPortraitUpsideDown: {
                
                [self.player setFullscreen:NO];
                
            }
                break;
                
            case UIInterfaceOrientationLandscapeLeft: {
                
                [self.player setFullscreen:YES];
                
            }
                break;
                
            case UIInterfaceOrientationLandscapeRight: {
                
                [self.player setFullscreen:YES];
                
            }
                break;
                
            default:
                break;
                
        }
        
    }completion:^(id<UIViewControllerTransitionCoordinatorContext> context){
        
    }];
    
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    
    if (self.isWebVideo == YES || self.isAudio == YES) {
        return;
    }
    
    switch (toInterfaceOrientation) {
            
        case UIInterfaceOrientationLandscapeLeft: {
            
            [self.player setFullscreen:YES];
            
        }
            break;
            
        case UIInterfaceOrientationLandscapeRight: {
            
            [self.player setFullscreen:YES];
            
        }
            break;
            
        default:
            break;
            
    }
    
}


#pragma mark - Player Notifications

- (void)setupNotifications{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayerDidEnterFullscreen) name:MPMoviePlayerDidEnterFullscreenNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayerDidExitFullscreen) name:MPMoviePlayerDidExitFullscreenNotification object:nil];
    
}

- (void)moviePlayerDidEnterFullscreen{
    
    [self.view setNeedsLayout];
    
}

- (void)moviePlayerDidExitFullscreen{
    
    [self forceToPortrait];
    
}



#pragma mark - MoviePlayer Notifications

- (void)setupWebPlayerNotification{
    
}


- (void)webPlayerPlayStart:(NSNotification *)notification {
    
    if (self.isWebVideo == YES) {
        [AppDelegate appDelegate].restrictRotation = NO;
    }
    
}

- (void)webPlayerFullscreenWillExit:(NSNotification *)notification{
    
    if (self.isWebVideo == YES) {
        [AppDelegate appDelegate].restrictRotation = YES;
    }
    
}

- (void)forceToPortrait{
    
    BOOL iPad = NO;
    iPad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
    
    if(iPad == NO){
        [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger: UIInterfaceOrientationPortrait] forKey:@"orientation"];
    }
    
}

@end
