//
//  FavoritesViewController.m
//  Zype
//
//  Created by ZypeTech on 1/26/15.
//  Copyright (c) 2015 Zype. All rights reserved.
//

#import "FavoritesViewController.h"
#import "AppDelegate.h"

@implementation FavoritesViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self trackScreenName:@"Favorites"];
    
    // Init UI
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:nil
                                                                            action:nil];

    self.episodeController.episodeControllerMode = ACSEpisodeControllerModeFavorites;
    [self.episodeController loadFavoriteVideos];
    self.episodeController.editingEnabled = YES;
    
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    // Load favorites
//    if ([[[NSUserDefaults standardUserDefaults] boolForKey:kSettingKey_SignInStatus]]){
//        [[RESTServiceController sharedInstance] syncFavoritesAfterRefreshed:NO InPage:nil WithFavoritesInDB:nil WithExistingFavorites:nil];
//    }
    if (kFavoritesViaAPI){
        [[RESTServiceController sharedInstance] syncFavoritesAfterRefreshed:NO InPage:nil WithFavoritesInDB:nil WithExistingFavorites:nil];
    }

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
    if (![[NSUserDefaults standardUserDefaults] boolForKey:kSettingKey_SignInStatus])
        self.navigationItem.rightBarButtonItem = nil;
    
}

- (void)showNowPlayingVideoDetail:(id)sender{
    
    [UIUtil showNowPlayingFromViewController:self];
    
}


#pragma mark - EpisodeControllerDelegate

- (void)setNoResultsMessage{
    
    self.noResultsLabel.text = [[NSUserDefaults standardUserDefaults] stringForKey:kSettingKey_NoFavoritesMessage];
    
}


@end
