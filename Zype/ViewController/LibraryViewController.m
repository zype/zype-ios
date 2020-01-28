//
//  LibraryViewController.m
//  Zype
//
//  Created by ZypeTech on 1/26/15.
//  Copyright (c) 2015 Zype. All rights reserved.
//

#import "LibraryViewController.h"
#import "AppDelegate.h"
#import "ACStatusManager.h"

@implementation LibraryViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self trackScreenName:@"Library"];
    
    // Init UI
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:nil
                                                                            action:nil];
    self.episodeController.editingEnabled = NO;
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    // Load favorites
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kSettingKey_SignInStatus]){
        [[RESTServiceController sharedInstance] syncLibraryAfterRefreshed:NO InPage:nil WithLibraryInDB:nil WithExistingLibrary:nil];
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    // Restrict rotation
    [AppDelegate appDelegate].restrictRotation = YES;
    
    if ([ACStatusManager isUserSignedIn] == NO) {
        self.noResultsLabel.text =  @"Sign in for access to your library of purchased content.";
    } else {
        self.noResultsLabel.text = @"";
        [self.episodeController loadLibraryVideos];
    }
}

- (void)showNowPlayingVideoDetail:(id)sender{
    
    [UIUtil showNowPlayingFromViewController:self];
    
}


#pragma mark - EpisodeControllerDelegate

- (void)setNoResultsMessage {

    if ([ACStatusManager isUserSignedIn] == NO) {
       self.noResultsLabel.text =  @"Sign in for access to your library of purchased content.";
    } else {
        self.noResultsLabel.text = @"It looks like you haven't purchased any content yet. Once purchased, your library of content will appear in this section.";
    }
}


@end
