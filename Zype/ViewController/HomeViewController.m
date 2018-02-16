//
//  HomeCollectionViewController.m
//  acumiashow
//
//  Created by ZypeTech on 6/21/15.
//  Copyright (c) 2015 Zype. All rights reserved.
//

#import <Crashlytics/Crashlytics.h>
//#import <PINRemoteImage/UIImageView+PINRemoteImage.h>
#import <SDWebImage/UIImageView+WebCache.h>

#import "HomeViewController.h"
#import "EpisodeControllerDelegate.h"
#import "VideoDetailViewController.h"
#import "SearchResultViewController.h"
#import "BaseCollectionController.h"
#import "AppDelegate.h"
#import "ACSDataManager.h"
#import "ACStatusManager.h"
#import "ACDownloadManager.h"
#import "ACSAlertViewManager.h"
#import "MediaPlayerManager.h"
#import "PlaybackSource.h"
#import "Reachability.h"
#import "Playlist.h"
#import "ACSPersistenceManager.h"//remove this after test

@interface HomeViewController ()<UIActionSheetDelegate, WKNavigationDelegate, ACActionSheetManagerDelegate>

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UIImageView *imagePlaceholder;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIView *viewFilter;
@property (strong, nonatomic) IBOutlet  UIView *viewDate;
@property (weak, nonatomic) IBOutlet UIButton *buttonFilterNext;
@property (weak, nonatomic) IBOutlet UIButton *buttonDismissSearch;
@property (strong, nonatomic) IBOutlet UIButton *playLiveButton;
@property (weak, nonatomic) IBOutlet UIButton *calendarButton;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headerTopLayoutConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *calendarWidthLayoutConstraint;

@property (strong, nonatomic) UIView *viewDateFilter;
@property (strong, nonatomic) UIDatePicker *pickerDateFilter;
@property (strong, nonatomic) UIButton *buttonDismiss;
@property (strong, nonatomic) UIPopoverController *popover;

@property (nonatomic, retain) NSDate *start;
@property (strong, nonatomic) NSDate *fromDate;
@property (strong, nonatomic) NSDate *toDate;

@property (nonatomic) BOOL isLiveStreamEmbedded;
@property (nonatomic) BOOL showingLiveStream;

@end


@implementation HomeViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Restrict rotation
    [AppDelegate appDelegate].restrictRotation = YES;
    
    self.episodeController.episodeControllerMode = ACSEpisodeControllerModeLatest;
    
    self.start = [NSDate date];
    
    [self setupInterface];
    
    self.isLiveStreamEmbedded = NO;
    self.isLivePictureLoaded = NO;
    
    [ACSDataManager checkForLiveStream];
    [self getPlaylistData];
    
    //[self customizeSearchBar];
    
    //[self performSegueWithIdentifier:@"toIntro" sender:nil];
}

- (void) customizeSearchBar {
    //[self.searchBar setBarStyle:UIBarStyleDefault];
    if (kAppColorLight){
        
    } else {
        [self.searchBar setSearchBarStyle:UISearchBarStyleDefault];
    }
    
}

- (void)getPlaylistData {
    // Load playlists
    NSString *currentPlaylistID;
    
    if (self.playlistItem != nil) {
        [self trackScreenName:[NSString stringWithFormat:kAnalyticsScreenNamePlaylist, self.playlistItem.title]];
        self.title = self.playlistItem.title;
        currentPlaylistID = self.playlistItem.pId;
    } else {
        //playlist item is nil, load root
        currentPlaylistID = kRootPlaylistId;
        [self trackScreenName:kAnalyticsScreenNameHome];
    }
    
    [self loadDataWithPlaylistID:currentPlaylistID];
}

- (void)loadDataWithPlaylistID:(NSString *)playlistID {    
    [[RESTServiceController sharedInstance] syncPlaylistsWithParentId:playlistID withCompletionHandler:^{
        
        if (kAppAppleTVLayout) {
            if ([playlistID  isEqualToString: kRootPlaylistId]) {
                [[RESTServiceController sharedInstance] syncZObject];
            }

            NSArray *playlists = [ACSPersistenceManager getPlaylistsWithParentID:playlistID];
            dispatch_group_t group = dispatch_group_create();
            for (Playlist * playlist in playlists) {
                dispatch_group_enter(group);
                if (playlist.playlist_item_count.integerValue > 0) {
                    [[RESTServiceController sharedInstance] syncVideosFromPlaylist:playlist.pId InPage:nil WithVideosInDB:nil WithExistingVideos:nil withCompletionHandler:^{
                        dispatch_group_leave(group);
                    }];
                } else {
                    [[RESTServiceController sharedInstance] syncPlaylistsWithParentId:playlist.pId withCompletionHandler:^{
                        dispatch_group_leave(group);
                    }];
                }
            }
            dispatch_group_notify(group, dispatch_get_main_queue(), ^{
                //[[RESTServiceController sharedInstance] syncZObject];
                [self loadData];

            });
            NSLog(@"%@", playlists);
        }
    }];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    if (!self.isLiveStreamEmbedded) {
        [[[UIApplication sharedApplication] keyWindow] addSubview:self.viewDateFilter];
    }
    
    // Register notification
    [self setupWebPlayerNotification];
    
    //    [Timing recordTimingForOperationWithCategory:kLoadTime andStartDate:_start andName:self.screenName andLabel:@"View Loaded"];
    
    [self.view bringSubviewToFront:self.buttonDismissSearch];
    [self.activityIndicator stopAnimating];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self loadData];
}

- (void)loadData {
    if (self.playlistItem != nil){
        [self.episodeController loadPlaylist:self.playlistItem.pId];
    } else {
        if (kAppAppleTVLayout) {
            [self.episodeController loadPresentableObjects:kRootPlaylistId];
        } else {
            [self.episodeController loadPlaylist:kRootPlaylistId];
        }
    }
    
    [self setupHeader];
}

- (void)dealloc{
    NSLog(@"dealocating");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

#pragma mark - Layout Configuration

- (void)fillSections {
    
}

//- (void)reloadData {
//    
//    
//    
//}

#pragma mark - Setup

- (void)trackScreen{
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    // manual screen tracking
    [tracker set:kGAIScreenName value:self.title];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    
}

- (void)setupInterface{
    
    // Init UI
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    [self initDismissButton];
    [self initDismissSearchButton];
    
    [self.buttonFilterNext setEnabled:NO];
    
}

- (void)initDismissButton{
    
    self.buttonDismiss = [[UIButton alloc] initWithFrame:self.view.frame];
    [self.buttonDismiss setBackgroundColor:kDismissButtonColor];
    [self.buttonDismiss setHidden:YES];
    [self.buttonDismiss addTarget:self action:@selector(dismissView:) forControlEvents:UIControlEventTouchUpInside];
    
    UITabBarController *tabBarController = (UITabBarController *)[[self parentViewController] parentViewController];
    [tabBarController.view addSubview:self.buttonDismiss];
    
}

- (void)initDismissSearchButton{
    
    [self.buttonDismissSearch setBackgroundColor:kDismissButtonColor];
    [self.buttonDismissSearch addTarget:self action:@selector(dismissKeyboard) forControlEvents:UIControlEventTouchUpInside];
}


#pragma mark - Video Player Notifications

- (void)moviePlayerDidExitFullscreen{
    [super moviePlayerDidExitFullscreen];
    
}

#pragma mark - Navigation Bar

- (void)showNowPlayingVideoDetail:(id)sender{
    
    [UIUtil showNowPlayingFromViewController:self];
    
}

- (void)addStopPlayingButton{
    
    UIBarButtonItem *stopButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(stopPlayingLiveStream)];
    self.navigationItem.rightBarButtonItem = stopButton;
    self.navigationItem.rightBarButtonItem.enabled = YES;
    
}

- (IBAction)showSearchResult:(id)sender {
    [self performSegueWithIdentifier:@"showSearchResult" sender:self];
}


#pragma mark - Header

- (void)setupHeader {
    
    [self.episodeController setupSlidingHeader:self.headerView stickyView:self.viewFilter topLayoutConstraint:self.headerTopLayoutConstraint];
    
}



#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    
    if ([[segue identifier] isEqualToString:@"showEpisodeDetail"]) {
        
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:kAnalyticsScreenNameLatest action:kAnalyticsCategoryButtonPressed label:@"Show Latest Detail" value:nil] build]];
        
        [[segue destinationViewController] setDetailItem:self.selectedVideo];
        
    }else if ([[segue identifier] isEqualToString:@"showSearchResult"]) {
        
//        CLS_LOG(@"====Search String==== %@", self.searchBar.text);
//        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:kAnalyticsScreenNameLatest action:kAnalyticsCategoryButtonPressed label:@"Show Search Result" value:nil] build]];
//        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:kAnalyticsScreenNameLatest action:kAnalyticsActSearchString label:self.searchBar.text value:nil] build]];
//        [[segue destinationViewController] setSearchString:self.searchBar.text];
//        [self.searchBar setText:@""];
        
    }
    
}


#pragma mark - Subclass Overrides

- (void)setNoResultsMessage{
    
    if (self.doneLoadingFromNetwork == YES) {
        
        self.noResultsLabel.text = NSLocalizedString(@"There are no shows yet this week.  Keep an eye out here or check out the archives.", @"no results message");
        
    }else{
        
        self.noResultsLabel.text = NSLocalizedString(@"Checking for shows...", @"no results message");
        
    }
    
}

#pragma mark - IBActions


- (IBAction)dismissKeyboard {
    
    //[self.searchBar resignFirstResponder];
    [self.buttonDismissSearch setHidden:YES];
    
}

- (void)setupPlayer:(NSURL *)url{
    
    [self removePlayer];
    
    self.player = [[MediaPlayerManager sharedInstance] moviePlayerControllerWithURL:url video:nil image:self.imagePlaceholder.image];
    
    [self.player setMovieSourceType:MPMovieSourceTypeStreaming];
    [self.player.view.layer setBackgroundColor:[UIColor clearColor].CGColor];
    self.player.shouldAutoplay = YES;
    
    [self.headerView addSubview:self.player.view];
    
    self.player.view.translatesAutoresizingMaskIntoConstraints = NO;
    
    if (self.isAudio == YES) {
        [self setupAudioPlayerView];
    }else{
        [self setupVideoPlayerView];
    }
    
    [self setupSharedPlayerView];
    
    [self.activityIndicator stopAnimating];
    
}

- (void)setupAudioPlayerView{
    
    CGRect playerFrame = self.imagePlaceholder.frame;
    [self.player.view setFrame:CGRectMake(playerFrame.origin.x, playerFrame.origin.y + playerFrame.size.height - kPlayerControlHeight, playerFrame.size.width, kPlayerControlHeight)];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.player.view
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.imagePlaceholder
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1
                                                           constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.player.view
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:nil
                                                          attribute:NSLayoutAttributeNotAnAttribute
                                                         multiplier:1
                                                           constant:kPlayerControlHeight]];
    
    [AppDelegate appDelegate].restrictRotation = YES;
    
}

- (void)setupVideoPlayerView{
    
    self.player.view.frame = self.imagePlaceholder.frame;
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.player.view
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.imagePlaceholder
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1
                                                           constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.player.view
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.imagePlaceholder
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1
                                                           constant:0]];
    
    [AppDelegate appDelegate].restrictRotation = NO;
    
}

- (void)setupSharedPlayerView {
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.player.view
                                                          attribute:NSLayoutAttributeTrailing
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.imagePlaceholder
                                                          attribute:NSLayoutAttributeTrailing
                                                         multiplier:1
                                                           constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.player.view
                                                          attribute:NSLayoutAttributeLeading
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.imagePlaceholder
                                                          attribute:NSLayoutAttributeLeading
                                                         multiplier:1
                                                           constant:0]];
    
    [self.view bringSubviewToFront:self.player.view];
    self.player.view.userInteractionEnabled = YES;
    
}




#pragma mark - Web View Player

- (void)setupWebPlayer:(NSURL *)url {
    
    [self embedWebPlayer:url frame:self.imagePlaceholder.frame];
    
}

- (void)embedWebPlayer:(NSURL *)url frame:(CGRect)frame {
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0f) {
        
        [self setupWKWebViewPlayerWithURLString:url frame:frame];
        
    }else{
        
        [self setupUIWebViewPlayerWithURLString:url frame:frame];
        
    }
    
    if(self.player != nil){
        
        [self.player stop];
        self.player.view.hidden = YES;
        
    }
    
    self.isLiveStreamEmbedded = YES;
    
}

- (void)setupWKWebViewPlayerWithURLString:(NSURL *)url frame:(CGRect)frame {
    
    if (self.wkWebViewPlayer == nil || !self.wkWebViewPlayer.superview) {
        
        self.wkWebViewPlayer = [[WKWebView alloc] initWithFrame:frame configuration:self.wkWebConfig];
        self.wkWebViewPlayer.navigationDelegate = self;
        self.wkWebViewPlayer.scrollView.scrollEnabled = NO;
        self.wkWebViewPlayer.opaque = NO;
        self.wkWebViewPlayer.backgroundColor = [UIColor blackColor];
        
        [self.view addSubview:self.wkWebViewPlayer];
        [self setupConstraintsForWebPlayerView:self.wkWebViewPlayer];
        
    }
    
    [self.wkWebViewPlayer setHidden:NO];
    [self showActivityIndicator];
    
    // Load live stream
    [self.wkWebViewPlayer loadRequest:[NSURLRequest requestWithURL:url cachePolicy: NSURLRequestReloadIgnoringCacheData timeoutInterval:1000]];
    
}

- (void)setupUIWebViewPlayerWithURLString:(NSURL *)url frame:(CGRect)frame {
    
    if (self.webViewPlayer == nil || !self.webViewPlayer.superview) {
        
        self.webViewPlayer = [[UIWebView alloc] initWithFrame:frame];
        self.webViewPlayer.delegate = self;
        self.webViewPlayer.scrollView.scrollEnabled = NO;
        self.webViewPlayer.opaque = NO;
        self.webViewPlayer.backgroundColor = [UIColor blackColor];
        self.webViewPlayer.scalesPageToFit = YES;
        [self.webViewPlayer setHidden:NO];
        
        [self.view addSubview:self.webViewPlayer];
        [self setupConstraintsForWebPlayerView:self.webViewPlayer];
        
    }
    
    // Start activity indicator and disable animations to fix loading issue
    [self showActivityIndicator];
    [UIView setAnimationsEnabled:NO];
    
    // Load live stream
    [self.webViewPlayer loadRequest:[NSURLRequest requestWithURL:url cachePolicy: NSURLRequestReloadIgnoringCacheData timeoutInterval:1000]];
    
}

- (void)setupConstraintsForWebPlayerView:(UIView *)view {
    
    view.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.imagePlaceholder
                                                          attribute:NSLayoutAttributeHeight
                                                         multiplier:1
                                                           constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                          attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.imagePlaceholder
                                                          attribute:NSLayoutAttributeWidth
                                                         multiplier:1
                                                           constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.imagePlaceholder
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1
                                                           constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                          attribute:NSLayoutAttributeCenterY
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.imagePlaceholder
                                                          attribute:NSLayoutAttributeCenterY
                                                         multiplier:1
                                                           constant:0]];
    
}




#pragma mark - Stopping Stream

- (void)stopLiveStream {
    
    [self removeWebView];
    self.isLiveStreamEmbedded = NO;
    self.showingLiveStream = NO;
    
}


#pragma mark - Search

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    
    [self.buttonDismissSearch setHidden:NO];
    return YES;
    
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
    
    return YES;
    
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    
    [self dismissKeyboard];
    
    //if ([ACStatusManager isUserSignedIn] == YES) {
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Latest" action:@"Search" label:@"Show Search Results" value:nil] build]];
    //[tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Latest" action:@"Search String" label:self.searchBar.text value:nil] build]];
    [self performSegueWithIdentifier:@"showSearchResult" sender:self];
    
    /* }else {
     
     [self.searchBar setText:@""];
     [UIUtil showSignInViewFromViewController:self];
     
     }*/
    
}


#pragma mark - Search/Date Dismissal

- (void)dismissView:(id)sender{
    
    __block UIView *view = nil;
    
    if (!self.viewDateFilter.isHidden) view = self.viewDateFilter;
    
    float currentY = ([[UIApplication sharedApplication] keyWindow].frame.size.height - view.frame.size.height);
    
    if (view.frame.origin.y == currentY) {
        
        CGRect frame = view.frame;
        [UIView animateWithDuration:0.3
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             view.frame = CGRectMake(frame.origin.x, frame.origin.y + frame.size.height, frame.size.width, frame.size.height);
                         }
                         completion:^(BOOL finished) {
                             
                             [view setHidden:YES];
                             [self.buttonDismiss setHidden:YES];
                             
                         }];
        
    }
    
}


#pragma mark - Actions

- (void)stopPlayingLiveStream{
    
    [self removePlayer];
    [self stopLiveStream];
    self.imagePlaceholder.hidden = NO;
    self.navigationItem.rightBarButtonItem = nil;
    
}


#pragma mark - Alert view

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex == 0){
        
        if (self != nil) {
            [self.tabBarController setSelectedIndex:4];
        }
        
    }
    
    if (alertView.tag == 1){
        
        if (!buttonIndex == [alertView cancelButtonIndex])
        {
            
            NSString *subscribeUrl = [[NSUserDefaults standardUserDefaults] stringForKey:kSettingKey_SubscribeUrl];
            if (subscribeUrl) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:subscribeUrl]];
            }
            
        }
        
    }
    
}





@end
