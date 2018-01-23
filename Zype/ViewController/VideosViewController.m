//
//  HomeCollectionViewController.m
//  acumiashow
//
//  Created by ZypeTech on 6/21/15.
//  Copyright (c) 2015 Zype. All rights reserved.
//

#import <Crashlytics/Crashlytics.h>
#import <SDWebImage/UIImageView+WebCache.h>

#import "VideosViewController.h"
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

#import "ACSPersistenceManager.h"


@interface VideosViewController ()<UIActionSheetDelegate, WKNavigationDelegate, ACActionSheetManagerDelegate>


@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
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


@implementation VideosViewController


#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Restrict rotation
    [AppDelegate appDelegate].restrictRotation = YES;
    
    [self trackScreenName:kAnalyticsScreenNameLatest];
    
    self.episodeController.episodeControllerMode = ACSEpisodeControllerModeLatest;
    
    self.start = [NSDate date];
    
    [self setupInterface];
    
    [self getNewData];
    Playlist *currentPlaylist = [ACSPersistenceManager playlistWithID:self.playlistId];
    if (currentPlaylist != nil){
        self.title = currentPlaylist.title;
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadVideos) name:@"ResultsFromPlaylistReturned" object:nil];
    
    //[self customizeSearchBar];
}

- (void) customizeSearchBar {
    //[self.searchBar setBarStyle:UIBarStyleDefault];
    if (kAppColorLight){
        
    } else {
        [self.searchBar setSearchBarStyle:UISearchBarStyleDefault];
    }
    
}

- (void)getNewData {
    if (self.playlistId != nil) {
        [[RESTServiceController sharedInstance] syncVideosFromPlaylist:self.playlistId InPage:@1 WithVideosInDB:nil WithExistingVideos:nil];
    }
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    
    [self.view bringSubviewToFront:self.buttonDismissSearch];
    //[self.activityIndicator stopAnimating];
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    //[self loadVideos];
    
    [self setupHeader];
    
}

- (void)loadVideos{
    [self.episodeController loadVideosFromPlaylistId:self.playlistId];
}

- (void)dealloc{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}


#pragma mark - Setup

- (void)trackScreen{
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    // manual screen tracking
    [tracker set:kGAIScreenName value:@"Latest"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    
}

- (void)setupInterface{
    
    // Init UI
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    UIBarButtonItem * searchButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"IconSearch"] style:UIBarButtonItemStylePlain target:self action:@selector(searchTapped)];
    self.navigationItem.rightBarButtonItem = searchButton;
    
    [self initDismissButton];
    [self initDismissSearchButton];
    
    [self.buttonFilterNext setEnabled:NO];
    
}

- (void)searchTapped {
    [self performSegueWithIdentifier:@"showSearchResult" sender:nil];
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
    // [super moviePlayerDidExitFullscreen];
    
    [self setupHeader];
    
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


#pragma mark - Header

- (void)setupHeader{
    
    [self.episodeController setupSlidingHeader:self.headerView stickyView:self.viewFilter topLayoutConstraint:self.headerTopLayoutConstraint];
    
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    
    if ([[segue identifier] isEqualToString:@"showEpisodeDetail"]) {
        
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:kAnalyticsScreenNameLatest action:kAnalyticsCategoryButtonPressed label:@"Show Latest Detail" value:nil] build]];
        
        [[segue destinationViewController] setDetailItem:self.selectedVideo];
        
    }else if ([[segue identifier] isEqualToString:@"showSearchResult"]) {
        
        CLS_LOG(@"====Search String==== %@", self.searchBar.text);
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:kAnalyticsScreenNameLatest action:kAnalyticsCategoryButtonPressed label:@"Show Search Result" value:nil] build]];
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:kAnalyticsScreenNameLatest action:kAnalyticsActSearchString label:self.searchBar.text value:nil] build]];
        [[segue destinationViewController] setSearchString:self.searchBar.text];
        [self.searchBar setText:@""];
        
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


- (IBAction)dismissKeyboard{
    
    [self.searchBar resignFirstResponder];
    [self.buttonDismissSearch setHidden:YES];
    
}





#pragma mark - Web View Player

- (void)setupWebPlayer:(NSURL *)url{
    
}

- (void)embedWebPlayer:(NSURL *)url frame:(CGRect)frame{
    
    
}

- (void)setupWKWebViewPlayerWithURLString:(NSURL *)url frame:(CGRect)frame{
    
}

- (void)setupUIWebViewPlayerWithURLString:(NSURL *)url frame:(CGRect)frame{
    
}

- (void)setupConstraintsForWebPlayerView:(UIView *)view{
    
    
    
}




#pragma mark - Stopping Stream

- (void)stopLiveStream{
    
    
}


#pragma mark - Search

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
    
    [self.buttonDismissSearch setHidden:NO];
    return YES;
    
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar{
    
    return YES;
    
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    
    [self dismissKeyboard];
    
    // if ([ACStatusManager isUserSignedIn] == YES) {
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Latest" action:@"Search" label:@"Show Search Results" value:nil] build]];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Latest" action:@"Search String" label:self.searchBar.text value:nil] build]];
    [self performSegueWithIdentifier:@"showSearchResult" sender:self];
    
    /*  }else {
     
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


#pragma mark - ACActionSheetManagerDelegate

- (void)acActionSheetManagerDelegateWatchLiveStreamWasTapped{
    
    self.showingLiveStream = YES;
    
}

- (void)acActionSheetManagerDelegateReloadVideo:(Video *)video{
    
    //TODO: just reload the appropriate cell
    [self.episodeController reloadData];
    
}

- (void)acActionSheetManagerDelegateListenLiveStreamTapped{
    
    
    
}

- (void)acActionSheetManagerDelegateWatchLiveStreamTapped{
    
    
    
}


@end
