//
//  DownloadsViewController.m
//  Zype
//
//  Created by ZypeTech on 1/26/15.
//  Copyright (c) 2015 Zype. All rights reserved.
//

#import "DownloadsViewController.h"
#import "ACDownloadManager.h"
#import "ACSPersistenceManager.h"
#import "AppDelegate.h"

@interface DownloadsViewController ()

@property (nonatomic, assign) BOOL cleanedUpDownloads;

@end

@implementation DownloadsViewController


#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self trackScreenName:@"Downloads"];
    
    // Init UI
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:nil
                                                                            action:nil];

    self.episodeController.episodeControllerMode = ACSEpisodeControllerModeDownloads;
    [self.episodeController loadDownloadedVideos];
    self.episodeController.editingEnabled = YES;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Restrict rotation
    [AppDelegate appDelegate].restrictRotation = YES;
    
    // Set now playing bar button
    if (!self.navigationItem.rightBarButtonItem || ![[NSUserDefaults standardUserDefaults] boolForKey:kSettingKey_SignInStatus]) {
        UIButton *button = [UIUtil buttonNowPlayingInViewController:self];
        [button addTarget:self action:@selector(showNowPlayingVideoDetail:) forControlEvents:UIControlEventTouchUpInside];
    }
    if (![[NSUserDefaults standardUserDefaults] boolForKey:kSettingKey_SignInStatus])
        self.navigationItem.rightBarButtonItem = nil;
}


- (void)showNowPlayingVideoDetail:(id)sender
{
    [UIUtil showNowPlayingFromViewController:self];
}


#pragma mark - Subclass Overrides

- (void)setNoResultsMessage{

    //self.noResultsLabel.text = [[NSUserDefaults standardUserDefaults] stringForKey:kSettingKey_NoDownloadsMessage];
    self.noResultsLabel.text = @"It looks like you haven't downloaded any videos yet. \n\nYou can download videos in order to watch them offline by clicking on the Download icon for any individual video.";

}

#pragma mark - EpisodeControllerDelegate

- (void)episodeControllerPerformUpdates:(TLIndexPathUpdates *)updates{
    [super episodeControllerPerformUpdates:updates];

    if (self.cleanedUpDownloads == NO) {
        //make sure all downloads have valid files
        [self cleanupDownloads];
    }

}

#pragma mark - Download Cleanup

- (void)cleanupDownloads{
    
    BOOL shouldReload = NO;
    
    for (Video *video in self.episodeController.indexPathController.dataModel.items) {
        
        if ([ACDownloadManager fileDownloadedForVideo:video] == NO) {
            video.isDownload = @NO;
            shouldReload = YES;
        }
        
    }
    
    if (shouldReload == YES) {
        [[ACSPersistenceManager sharedInstance] saveContext];
        [self.episodeController reloadData];
    }
    
    self.cleanedUpDownloads = YES;
    
}


@end
