//
//  BaseCollectionViewController.m
//  acumiashow
//
//  Created by ZypeTech on 6/20/15.
//  Copyright (c) 2015 Zype. All rights reserved.
//

#import "BaseViewController.h"
#import "BaseCollectionController.h"
#import "BaseTableController.h"
#import "VideoTableViewCell.h"
#import "ACSEpisodeCollectionViewCell.h"
#import "VideoDetailViewController.h"
#import "ACStatusManager.h"
#import "DownloadStatusCell.h"
#import "DownloadOperationController.h"
#import "Playlist.h"
#import "ACPurchaseManager.h"
#import "RESTServiceController.h"
#import "PlaybackSource.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import "BaseTVLayoutController.h"

@interface BaseViewController ()

@end

@implementation BaseViewController


#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Init controller depending on view type
    
    if (kAppAppleTVLayout) {
        self.episodeController = [[BaseTVLayoutController alloc] initWithTableView:self.tableView];
        [self.collectionView setHidden:YES];
    } else {
        if ([self isRegularSizeClass] == YES) {
            self.episodeController = [[BaseCollectionController alloc] initWithCollectionView:self.collectionView];
            [self.tableView setHidden:YES];
        } else {
            self.episodeController = [[BaseTableController alloc] initWithTableView:self.tableView];
            [self.collectionView setHidden:YES];
        }
    }
    
    self.episodeController.delegate = self;
    self.actionSheetManager = [ACActionSheetManager new];
    self.actionSheetManager.delegate = self;
    
    [self customizeAppearance];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [[DownloadOperationController sharedInstance] setDownloadProgressViewController:self];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [[DownloadOperationController sharedInstance] setDownloadProgressViewController:nil];
}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - Public Methods

- (void)setDownloadStartedForDownloadTask:(NSURLSessionDownloadTask *)downloadTask{
    
    id<DownloadStatusCell> cell = [self cellForDownloadTask:downloadTask];
    
    if (cell == nil) {
        return;
    }
    
    if ([NSThread isMainThread]) {
        [cell setDownloadStarted];
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            [cell setDownloadStarted];
        });
    }
    
}

- (void)setDownloadProgress:(float)progress downloadTask:(NSURLSessionDownloadTask *)downloadTask{
    
    id<DownloadStatusCell> cell = [self cellForDownloadTask:downloadTask];
    
    if (cell == nil) {
        return;
    }
    
    if ([NSThread isMainThread]) {
        [cell setDownloadProgress:progress];
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            [cell setDownloadProgress:progress];
        });
    }
    
}

- (void)setDownloadSavingFileDownloadTask:(NSURLSessionDownloadTask *)downloadTask{
    
    id<DownloadStatusCell> cell = [self cellForDownloadTask:downloadTask];
    
    if (cell == nil) {
        return;
    }
    
    if ([NSThread isMainThread]) {
        [cell setDownloadSavingFile];
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            [cell setDownloadSavingFile];
        });
    }
    
}

- (void)setDownloadFinishedWithMediaType:(NSString *)mediaType downloadTask:(NSURLSessionDownloadTask *)downloadTask{
    
    id<DownloadStatusCell> cell = [self cellForDownloadTask:downloadTask];
    
    if (cell == nil) {
        return;
    }
    
    if ([NSThread isMainThread]) {
        [cell setDownloadFinishedWithMediaType:mediaType];
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            [cell setDownloadFinishedWithMediaType:mediaType];
        });
    }
    
}

- (void)setNoDownloadForDownloadTask:(NSURLSessionDownloadTask *)downloadTask{
    
    id<DownloadStatusCell> cell = [self cellForDownloadTask:downloadTask];
    
    if (cell == nil) {
        return;
    }
    
    if ([NSThread isMainThread]) {
        [cell setNoDownload];
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            [cell setNoDownload];
        });
    }
    
}

- (id<DownloadStatusCell>)cellForDownloadTask:(NSURLSessionDownloadTask *)downloadTask{
    
    id<DownloadStatusCell> cell;
    
    if (downloadTask != nil && self.episodeController != nil) {
        NSNumber *taskID = [NSNumber numberWithUnsignedInteger:downloadTask.taskIdentifier];
        cell = [self.episodeController cellForDownloadTaskID:taskID];
    }
    
    return cell;
    
}

- (void)trackScreenName:(NSString *)name{
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:name];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    
}

#pragma mark - Private Methods

- (void)checkDownloadVideo:(Video *)video withCompletion:(void(^)(NSArray *sources))complete {
    [[RESTServiceController sharedInstance] getVideoPlayerWithVideo:video downloadInfo:YES withCompletionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        //
        if (error) {
            complete(nil);
        } else {
            NSError *localError = nil;
            NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
            if (localError != nil) {
                complete(nil);
            } else {
                NSArray *sources = [[RESTServiceController sharedInstance] streamPlaybackSourcesFromRootDictionary:parsedObject];
                complete(sources);
            }
        }
    }];
}

#pragma mark - Subclass Overrides

- (void)setNoResultsMessage{
    
    //Subclass Override
    
}

- (void)showEpisodeOptionsActionSheetWithVideo:(Video *)video {
    [SVProgressHUD show];
    [self checkDownloadVideo:video withCompletion:^(NSArray *sources) {
        [SVProgressHUD dismiss];
        [self.actionSheetManager showActionSheetWithVideo:video sources:sources];
    }];
}


#pragma mark - Episode Controller Delegate

- (void)episodeControllerDelegateShowEmptyMessage:(BOOL)show{
    
    [self setNoResultsMessage];
    
    if (show == NO) {
        
        if ([self isRegularSizeClass] == YES && (!kAppAppleTVLayout)) {
            [self.collectionView setHidden:YES];
        } else {
            [self.tableView setHidden:YES];
        }
        
        [self.noResultsLabel setHidden:NO];
        
    } else {
        
        if ([self isRegularSizeClass] == YES && (!kAppAppleTVLayout)) {
            [self.collectionView setHidden:NO];
        } else {
            [self.tableView setHidden:NO];
        }
        
        [self.noResultsLabel setHidden:YES];
        
    }
    
}

- (void)episodeControllerDidSelectItem:(NSObject *)item {
    
    if ([item isKindOfClass:[Video class]]){
        self.selectedVideo = (Video *)item;
        [self videoItemSelected];
        
    } else if ([item isKindOfClass:[Playlist class]]){
        Playlist *playlist = (Playlist *)item;
        if ([playlist.playlist_item_count isEqual:@0]){
            NSLog(@"load another screen of playlists");
            [UIUtil loadPlaylist:playlist fromViewController:self];
        } else {
            NSLog(@"load videos");
            [UIUtil loadVideosFromPlaylist:playlist.pId fromViewController:self];
        }
    }
}

- (void)episodeControllerDidSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([[self.episodeController objectAtIndexPath:indexPath] isKindOfClass:[Video class]]){
        self.selectedVideo = (Video *)[self.episodeController objectAtIndexPath:indexPath];
        [self videoItemSelected];
        
    } else if ([[self.episodeController objectAtIndexPath:indexPath] isKindOfClass:[Playlist class]]){
        Playlist *playlist = [self.episodeController objectAtIndexPath:indexPath];
        if ([playlist.playlist_item_count isEqual:@0]){
            NSLog(@"load another screen of playlists");
            [UIUtil loadPlaylist:playlist fromViewController:self];
        } else {
            NSLog(@"load videos");
            [UIUtil loadVideosFromPlaylist:playlist.pId fromViewController:self];
        }
    }
    /*
     if ([ACStatusManager isUserSignedIn] == YES)
     {
     if ([[[NSUserDefaults standardUserDefaults] valueForKey:kOAuthProperty_Subscription] isEqualToNumber:[NSNumber numberWithInt:0]])
     // 0 = not subscribed
     {
     
     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:kSettingKey_SubscribeTitleMessage message:kSettingKey_SubscribeMessage delegate:self cancelButtonTitle:kSettingKey_SubscribeCancelButtonTitle otherButtonTitles:kSettingKey_SubscribeButtontitle, nil];
     alert.tag = 1;
     [alert show];
     }
     else
     {
     
     self.selectedVideo = (Video *)[self.episodeController objectAtIndexPath:indexPath];
     
     if (self.selectedVideo != nil) {
     [self performSegueWithIdentifier:@"showEpisodeDetail" sender:self];
     }
     
     }
     }
     else
     {
     [UIUtil showSignInViewFromViewController:self];
     }*/
    
}

- (void)videoItemSelected{
    if (self.selectedVideo != nil) {
        
        //check for Live
        if ([self.selectedVideo.on_air intValue] == 1){
            //logic for livestream can be inserted here
        }
        
        //check for video with subscription
        if (kNativeSubscriptionEnabled == NO) {
            if ([ACStatusManager isUserSignedIn] == false && self.selectedVideo.subscription_required.intValue == 1) {
                [UIUtil showSignInViewFromViewController:self];
                return;
            }
        } else {
            if ([ACStatusManager isUserSignedIn] == false && self.selectedVideo.subscription_required.intValue == 1) {
                [UIUtil showIntroViewFromViewController:self];
                return;
            } else {
                if ([self.selectedVideo.subscription_required intValue] == 1 && [[ACPurchaseManager sharedInstance] isActiveSubscription] == false) {
                    [UIUtil showSubscriptionViewFromViewController:self];
                    return;
                }
            }
        }
        
//        if ([ACStatusManager isUserSignedIn] == NO && [self.selectedVideo.subscription_required intValue] == 1){
//            //[UIUtil showSignInViewFromViewController:self];
//            [UIUtil showIntroViewFromViewController:self];
//            return;
//        }
        //no more checks for now
        [self performSegueWithIdentifier:@"showEpisodeDetail" sender:self];
        
        
        
    }
}


- (void)episodeControllerDelegateDoneLoading{
    
    self.doneLoadingFromNetwork = YES;
    [self setNoResultsMessage];
    
}




- (void)episodeControllerDelegateButtonActionTappedAtIndexPath:(NSIndexPath *)indexPath{
    
    //if ([ACStatusManager isUserSignedIn] == YES) {
    
    self.indexPathInAction = indexPath;
    
    Video *selectedVideo = [self.episodeController objectAtIndexPath:indexPath];
    self.actionVideo = selectedVideo;
    CLS_LOG(@"selected video: %@", selectedVideo.title);
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:kAnalyticsCategoryVideoPlayed action:@"Video Selected" label:selectedVideo.title value:nil] build]];
    
    //show options action sheet for selected video
    [self showEpisodeOptionsActionSheetWithVideo:selectedVideo];
    
    /* }
     else {
     [UIUtil showSignInViewFromViewController:self];
     }*/
    
}

- (void)episodeControllerPerformUpdates:(TLIndexPathUpdates *)updates{
    
    if (!updates.hasChanges) {
        return;
    }
    
    if (self.collectionView.superview != nil) {
        [self.collectionView reloadData];
    } else if (self.tableView.superview != nil){
        [self.tableView reloadData];
    }
    
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    
    if ([[segue identifier] isEqualToString:@"showEpisodeDetail"]) {
        
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:kAnalyticsScreenNameLatest action:kAnalyticsCategoryButtonPressed label:@"Show Latest Detail" value:nil] build]];
        
        [[segue destinationViewController] setDetailItem:self.selectedVideo];
        
    }
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"%@", touches);
}


#pragma mark - ACActionSheetManagerDelegate

- (void)acActionSheetManagerDelegatePresentViewController:(UIViewController *)viewController{
    
    [self presentViewController:viewController animated:YES completion:^{
        
        
    }];
    
}

- (void)acActionSheetManagerDelegateShowActionSheet:(UIActionSheet *)actionSheet{
    
    [actionSheet showInView:self.view];
    
}

- (void)acActionSheetManagerDelegateDismissModal{
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

@end
