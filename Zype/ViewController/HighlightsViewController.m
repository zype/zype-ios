//
//  HighlightsViewController.m
//  Zype
//
//  Created by ZypeTech on 1/26/15.
//  Copyright (c) 2015 Zype. All rights reserved.
//

#import "HighlightsViewController.h"
#import "Timing.h"
#import "AppDelegate.h"

@interface HighlightsViewController ()

@end

@implementation HighlightsViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    
    // Init UI
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:nil
                                                                            action:nil];
    [self trackScreenName:@"Highlights"];
    
    self.episodeController.episodeControllerMode = ACSEpisodeControllerModeHighlights;
    [self.episodeController loadHiglightsVideos];
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    // Restrict rotation
    [AppDelegate appDelegate].restrictRotation = YES;
    
    // Set now playing bar button
    if (!self.navigationItem.rightBarButtonItem || ![[NSUserDefaults standardUserDefaults] boolForKey:kSettingKey_SignInStatus]) {
        UIButton *button = [UIUtil buttonNowPlayingInViewController:self];
        [button addTarget:self action:@selector(showNowPlayingVideoDetail:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:kSettingKey_SignInStatus]){
        self.navigationItem.rightBarButtonItem = nil;
    }
    
}

- (void)showNowPlayingVideoDetail:(id)sender{
    
    [UIUtil showNowPlayingFromViewController:self];
    
}

@end
