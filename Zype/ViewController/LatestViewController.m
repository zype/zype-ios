//
//  HomeCollectionViewController.m
//
//  Created by ZypeTech on 6/21/15.
//  Copyright (c) 2015 Zype. All rights reserved.
//

#import <Crashlytics/Crashlytics.h>
//#import <PINRemoteImage/UIImageView+PINRemoteImage.h>
#import <SDWebImage/UIImageView+WebCache.h>

#import "LatestViewController.h"
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


@interface LatestViewController ()<UIActionSheetDelegate, WKNavigationDelegate, ACActionSheetManagerDelegate>

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

- (void)filterVideosFromDate:(NSDate *)fromDate ToDate:(NSDate *)toDate;

@end


@implementation LatestViewController


#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Restrict rotation
    [AppDelegate appDelegate].restrictRotation = YES;
    
    [self trackScreenName:kAnalyticsScreenNameLatest];
    
    self.episodeController.episodeControllerMode = ACSEpisodeControllerModeLatest;
    
    self.start = [NSDate date];
    
    [self setupInterface];
    
    self.isLiveStreamEmbedded = NO;
    self.isLivePictureLoaded = NO;
    
    [ACSDataManager checkForLiveStream];
    [self getNewData];
    
}

- (void)getNewData {
    // Load playlists
   // [[RESTServiceController sharedInstance] syncPlaylists:nil];
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
    
    [self.episodeController loadVideosFromDate:self.fromDate toDate:self.toDate];
    
    // Set now playing bar button
    if (!self.navigationItem.rightBarButtonItem || [ACStatusManager isUserSignedIn] == NO) {
        
        UIButton *button = [UIUtil buttonNowPlayingInViewController:self];
        [button addTarget:self action:@selector(showNowPlayingVideoDetail:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    
    if ([ACStatusManager isUserSignedIn] == NO){
        self.navigationItem.rightBarButtonItem = nil;
    }
    
    // Set user default did change notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(defaultsChanged:) name:NSUserDefaultsDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(liveStreamUpdated:) name:kNotificationNameLiveStreamUpdated object:nil];
    
    [self setLivePicture];
    [self setupHeader];
    
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
    
    [self initFilter];
    [self initDismissButton];
    [self initDismissSearchButton];
    
    [self.buttonFilterNext setEnabled:NO];
    
}

- (void)initFilter{
    
    // Init date filter with current week
    self.fromDate = [UIUtil startOfWeek:[NSDate date]];
    self.toDate = [UIUtil endOfWeek:[NSDate date]];
    [self showDateFilterWithDate:[UIUtil stringDurationFromDate:self.fromDate ToDate:self.toDate]];
    
    // Add tap gesture in filter
    UITapGestureRecognizer *filterTapped = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                   action:@selector(showDatePicker:)];
    [self.viewDate addGestureRecognizer:filterTapped];
    
    // Init action view
    self.viewDateFilter = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, kFilterViewHeight)];
    [self.viewDateFilter setBackgroundColor:kSystemWhite];
    [self.viewDateFilter setHidden:YES];
    
    // Add today button
    UIButton *buttonToday = [[UIButton alloc] init];
    [buttonToday setTitle:@"Today" forState:UIControlStateNormal];
    [buttonToday setTitleColor:kLinkColor forState:UIControlStateNormal];
    [buttonToday sizeToFit];
    [buttonToday addTarget:self action:@selector(buttonTodayTapped:) forControlEvents:UIControlEventTouchUpInside];
    [buttonToday setFrame:CGRectMake(0, 0, buttonToday.frame.size.width + kFilterButtonMargin, buttonToday.frame.size.height + kFilterButtonMarginTop)];
    [self.viewDateFilter addSubview:buttonToday];
    
    // Add done button
    UIButton *buttonDone = [[UIButton alloc] init];
    [buttonDone setTitle:@"Done" forState:UIControlStateNormal];
    [buttonDone setTitleColor:kLinkColor forState:UIControlStateNormal];
    [buttonDone sizeToFit];
    [buttonDone addTarget:self action:@selector(filterWithDatePicker:) forControlEvents:UIControlEventTouchUpInside];
    [buttonDone setFrame:CGRectMake(self.view.frame.size.width - buttonDone.frame.size.width - kFilterButtonMargin, 0, buttonDone.frame.size.width + kFilterButtonMargin, buttonDone.frame.size.height + kFilterButtonMarginTop)];
    [self.viewDateFilter addSubview:buttonDone];
    
    // Add date picker
    self.pickerDateFilter = [[UIDatePicker alloc] init];
    [self.pickerDateFilter setDatePickerMode:UIDatePickerModeDate];
    [self.pickerDateFilter setFrame:CGRectMake(0, buttonDone.frame.size.height, self.view.frame.size.width, (self.viewDateFilter.frame.size.height - buttonDone.frame.size.height))];
    [self.viewDateFilter addSubview:self.pickerDateFilter];
    
    [self.pickerDateFilter addTarget:self action:@selector(datePickerChanged:) forControlEvents:UIControlEventValueChanged];
    
    [self.episodeController loadVideosFromDate:self.fromDate toDate:self.toDate];
    
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


#pragma mark - Date Filter

- (void)showDateFilterWithDate:(NSString *)stringDate{
    
    self.dateLabel.text = stringDate;
    [self.dateLabel sizeToFit];
    
    
}

- (void)showDatePicker:(id)sender{
    
    [self.pickerDateFilter setDate:self.fromDate];
    [self.pickerDateFilter setMaximumDate:[NSDate date]];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [self showPopoverDatePicker:self.pickerDateFilter];
        return;
    }
    
    // Show date filter view
    [self.viewDateFilter setHidden:NO];
    [self.buttonDismiss setHidden:NO];
    CGRect frame = self.viewDateFilter.frame;
    
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         
                         self.viewDateFilter.frame = CGRectMake(frame.origin.x, frame.origin.y - frame.size.height, frame.size.width, frame.size.height);
                         
                     }
                     completion:nil];
    
}

- (void)showPopoverDatePicker:(UIDatePicker *)datePicker{
    
    //build our custom popover view
    UIViewController* popoverContent = [[UIViewController alloc] init];
    UIView* popoverView = [[UIView alloc] initWithFrame:datePicker.bounds];
    popoverView.backgroundColor = [UIColor whiteColor];
    
    datePicker.frame = CGRectMake(0, 0, datePicker.frame.size.width, datePicker.frame.size.height);
    
    [popoverView addSubview:datePicker];
    popoverContent.view = popoverView;
    
    //resize the popover view shown
    //in the current view to the view's size
    popoverContent.preferredContentSize = datePicker.frame.size;
    
    CGRect popRect = [self.viewDate convertRect:self.calendarButton.frame toView:self.view];
    
    //create a popover controller
    self.popover = [[UIPopoverController alloc] initWithContentViewController:popoverContent];
    [self.popover presentPopoverFromRect:popRect inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    
}

- (void)filterWithDatePicker:(id)sender{
    
    [self dismissView:self.viewDateFilter];
    
}

- (void)filterVideosFromDate:(NSDate *)fromDate ToDate:(NSDate *)toDate{
    
    [self.episodeController scrollToTop];
    self.doneLoadingFromNetwork = NO;
    
    self.fromDate = fromDate;
    self.toDate = toDate;
    
    // Update date string
    [self showDateFilterWithDate:[UIUtil stringDurationFromDate:self.fromDate ToDate:self.toDate]];
    
    // Load videos
    [[RESTServiceController sharedInstance] syncVideosFromDate:self.fromDate ToDate:self.toDate InPage:nil WithVideosInDB:nil WithExistingVideos:nil];
    
    //load the dates in the collection controller
    [self.episodeController loadVideosFromDate:fromDate toDate:toDate];
    
    // If it shows current week, disable next filter button
    if ([[self.fromDate dateByAddingTimeInterval:(kDayInterval * 2)] compare:[UIUtil startOfWeek:[NSDate date]]] == NSOrderedDescending){
        [self.buttonFilterNext setEnabled:NO];
    }else{
        [self.buttonFilterNext setEnabled:YES];
    }
    
}

- (void)buttonTodayTapped:(id)sender{
    
    [self.pickerDateFilter setDate:[NSDate date]];
    [self datePickerChanged:self.pickerDateFilter];
}

- (void)resetFilter{
    
    if ([self.fromDate compare:[UIUtil startOfWeek:[NSDate date]]] != NSOrderedSame) {
        
        self.fromDate = [UIUtil startOfWeek:[NSDate date]];
        self.toDate = [UIUtil endOfWeek:[NSDate date]];
        [self filterVideosFromDate:self.fromDate ToDate:self.toDate];
        
    }
    
}

- (void)datePickerChanged:(id)sender{
    
    NSDate *selectedFromDate = [UIUtil startOfWeek:[self.pickerDateFilter date]];
    if ([selectedFromDate compare:self.fromDate] != NSOrderedSame) {
        
        self.fromDate = selectedFromDate;
        self.toDate = [UIUtil endOfWeek:[self.pickerDateFilter date]];
        [self filterVideosFromDate:self.fromDate ToDate:self.toDate];
        
    }
    
}


#pragma mark - Header Image

- (void)defaultsChanged:(NSNotification *)notification{
    
    if (self.isLivePictureLoaded == NO){
        [self setLivePicture];
    }
    
}

- (void)liveStreamUpdated:(NSNotification *)notification{
    
    self.isLivePictureLoaded = NO;
    
}

- (void)setLivePicture{
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    if ([ACStatusManager isUserSignedIn] == YES){
        
        if ([ACStatusManager isShowLive] == YES){
            
            [self loadLivePictureWithSettingKey:kSettingKey_OnAir];
            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Latest" action:@"Live Stream" label:@"Live Stream Started" value:nil] build]];
            
        }else {
            
            [self loadLivePictureWithSettingKey:kSettingKey_OffAir];
            [self stopLiveStream];
            
        }
        
    }else {
        
        [self loadLivePictureWithSettingKey:kSettingKey_NotSubscribed];
        [self stopLiveStream];
        
    }
    
}

- (void)loadLivePictureWithSettingKey:(NSString *)settingKey{
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:settingKey]) {
        
        NSDictionary *dict = [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:settingKey]];
        NSString *downloadedImagePath = [dict dictValueForKey:kAppKey_DownloadedUrl];
        NSString *localPath = [ACDownloadManager localDownloadPathForRelativePath:downloadedImagePath];
        UIImage *downloadedImage = [UIImage imageWithContentsOfFile:localPath];
        
        if (downloadedImage != nil) {
            
            self.imagePlaceholder.image = downloadedImage;
            self.isLivePictureLoaded = YES;
            
        }else {
            
            NSURL *imageURL = [NSURL URLWithString:[dict dictValueForKey:kAppKey_Url]];
            [self.self.imagePlaceholder sd_setImageWithURL:imageURL placeholderImage:[UIImage imageNamed:@"ImagePlaceholder"]];

           // [self.imagePlaceholder pin_setImageFromURL:imageURL placeholderImage:[UIImage imageNamed:@"ImagePlaceholder"]];
            self.isLivePictureLoaded = YES;
            
        }
        
    }
    
}


#pragma mark - IBActions


- (IBAction)dismissKeyboard{
    
    [self.searchBar resignFirstResponder];
    [self.buttonDismissSearch setHidden:YES];
    
}

- (IBAction)FilterPrevTapped:(id)sender {
    
    NSDate *midDate = [self.fromDate dateByAddingTimeInterval:-(kMidWeekInterval)];
    self.fromDate = [UIUtil startOfWeek:midDate];
    self.toDate = [UIUtil endOfWeek:midDate];
    [self filterVideosFromDate:self.fromDate ToDate:self.toDate];
    
}

- (IBAction)FilterNextTapped:(id)sender {
    
    NSDate *midDate = [self.toDate dateByAddingTimeInterval:kMidWeekInterval];
    self.fromDate = [UIUtil startOfWeek:midDate];
    self.toDate = [UIUtil endOfWeek:midDate];
    [self filterVideosFromDate:self.fromDate ToDate:self.toDate];
    
}

- (IBAction)liveStreamTapped:(id)sender {
    
    if ([ACStatusManager isUserSignedIn] && [ACStatusManager isShowLive] == YES){
        
        // 0 = not subscribed
        if ([[[NSUserDefaults standardUserDefaults] valueForKey:kOAuthProperty_Subscription] isEqualToNumber:[NSNumber numberWithInt:0]]){
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:kSettingKey_SubscribeTitleMessage message:kSettingKey_SubscribeMessage delegate:self cancelButtonTitle:kSettingKey_SubscribeCancelButtonTitle otherButtonTitles:kSettingKey_SubscribeButtontitle, nil];
            alert.tag = 1;
            [alert show];
            
        }else{
            
            if (!self.isLiveStreamEmbedded){
                
                [self.actionSheetManager showLiveStreamActionSheet];
                
            }
            
        }
        
    }
    
    if ([ACStatusManager isUserSignedIn] == NO) {
        [UIUtil showSignInViewFromViewController:self];
    }
    
}


#pragma mark - Live Streaming

- (void)loadLiveStreamWithId:(NSString *)vId{
    
    [[RESTServiceController sharedInstance] getLiveStreamWithId:vId WithCompletionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if (error) {
            CLS_LOG(@"Failed: %@", error);
        } else {
            
            CLS_LOG(@"Success");
            NSError *localError = nil;
            NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
            if (localError != nil) {
                CLS_LOG(@"Failed: %@", localError);
            }else {
                
                PlaybackSource *source = [[RESTServiceController sharedInstance] videoStreamPlaybackSourceFromRootDictionary:parsedObject];
                
                if (source != nil && source.urlString != nil) {
                    
                    self.isAudio = NO;
                    [self playVideoFromSource:source];
                    
                }else{
                    
                    //Show test stream if in debug mode
#ifdef DEBUG
                    source = [PlaybackSource new];
                    source.urlString = @"https://devimages.apple.com.edgekey.net/iphone/samples/bipbop/bipbopall.m3u8";
                    source.fileType = @"m3u8";
                    [self playVideoFromSource:source];
                    
#else
                    [self showBasicAlertWithTitle:kString_TitleStreamFail WithMessage:kString_MessageNoVideoStream];
                    
#endif
                    
                    
                }
                
            }
            
        }
        
    }];
    
}

- (void)loadLiveAudioStreamWithId:(NSString *)vId{
    
    [[RESTServiceController sharedInstance] getLiveStreamAudioWithId:vId WithCompletionHandler:^(NSData *data, NSURLResponse *response, NSError *error, NSString *urlString) {
        
        if (error) {
            
            CLS_LOG(@"Failed to get live audio stream: %@", error);
            
        }else{
            
            CLS_LOG(@"Success! %@", [NSJSONSerialization JSONObjectWithData:data options:0 error:nil]);
            NSError *localError = nil;
            NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
            
            if (localError != nil) {
                
                CLS_LOG(@"Failed: %@", localError);
                
            }else{
                
                PlaybackSource *source = [[RESTServiceController sharedInstance] videoStreamPlaybackSourceFromRootDictionary:parsedObject];
                
                if (source != nil && source.urlString != nil) {
                    
                    self.isAudio = YES;
                    [self playVideoFromSource:source];
                    
                }else{
                    
                    [self showBasicAlertWithTitle:kString_TitleStreamFail WithMessage:kString_MessageNoVideoStream];
                    
                }
                
            }
        }
        
    }];
    
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

- (void)setupSharedPlayerView{
    
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

- (void)setupWebPlayer:(NSURL *)url{
    
    [self embedWebPlayer:url frame:self.imagePlaceholder.frame];
    
}

- (void)embedWebPlayer:(NSURL *)url frame:(CGRect)frame{
    
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

- (void)setupWKWebViewPlayerWithURLString:(NSURL *)url frame:(CGRect)frame{
    
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

- (void)setupUIWebViewPlayerWithURLString:(NSURL *)url frame:(CGRect)frame{
    
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

- (void)setupConstraintsForWebPlayerView:(UIView *)view{
    
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

- (void)stopLiveStream{
    
    [self removeWebView];
    self.isLiveStreamEmbedded = NO;
    self.showingLiveStream = NO;
    
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
    
    if ([ACStatusManager isUserSignedIn] == YES) {
        
        id tracker = [[GAI sharedInstance] defaultTracker];
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Latest" action:@"Search" label:@"Show Search Results" value:nil] build]];
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Latest" action:@"Search String" label:self.searchBar.text value:nil] build]];
        [self performSegueWithIdentifier:@"showSearchResult" sender:self];
        
    }else {
        
        [self.searchBar setText:@""];
        [UIUtil showSignInViewFromViewController:self];
        
    }
    
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


#pragma mark - ACActionSheetManagerDelegate

- (void)acActionSheetManagerDelegateWatchLiveStreamWasTapped{
    
    self.showingLiveStream = YES;
    
}

- (void)acActionSheetManagerDelegateReloadVideo:(Video *)video{
    
    //TODO: just reload the appropriate cell
    [self.episodeController reloadData];
    
}

- (void)acActionSheetManagerDelegateListenLiveStreamTapped{
    
    [self loadLiveAudioStreamWithId:[[NSUserDefaults standardUserDefaults] stringForKey:kSettingKey_LiveStreamId]];
    [self addStopPlayingButton];
    
}

- (void)acActionSheetManagerDelegateWatchLiveStreamTapped{
    
    [self loadLiveStreamWithId:[[NSUserDefaults standardUserDefaults] stringForKey:kSettingKey_LiveStreamId]];
    [self addStopPlayingButton];
    
}


@end
