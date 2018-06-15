
//
//  VideoDetailViewController.m
//  Zype
//
//  Created by ZypeTech on 1/30/15.
//  Copyright (c) 2015 Zype. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <Crashlytics/Crashlytics.h>
//#import <PINRemoteImage/UIImageView+PINRemoteImage.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <AdSupport/ASIdentifierManager.h>
#import <sys/utsname.h>

#import "VideoDetailViewController.h"
#import "GuestTableViewCell.h"
#import "TimelineTableViewCell.h"
#import "AppDelegate.h"
#import "ACDownloadManager.h"
#import "ACSPersistenceManager.h"
#import "ACSTokenManager.h"
#import "ACActionSheetManager.h"
#import "ACAdManager.h"
#import "MediaPlayerManager.h"
#import "DownloadOperationController.h"
#import "OptionTableViewCell.h"
#import "CustomizeImageView.h"
#import "ACPurchaseManager.h"
#import "AVPlayerViewController+AVPlayerViewController_Transition.h"
#import "PlayerControlsOverlay.h"

#import "Guest.h"
#import "Timeline.h"
#import "Reachability.h"
#import "Timing.h"
#import "PlaybackSource.h"
#import "TableSectionDataSource.h"

#import "UserPreferences.h"

#import "TLIndexPathController.h"
#import "TLIndexPathItem.h"

#import "UIViewController+AC.h"
#import "NSURLResponse+AK.h"
#import "ACStatusManager.h"
#import "UIUtil.h"

#import "ACAnalyticsManager.h"

// Ad tag for testing
NSString *const kTestAppAdTagUrl =
@"https://pubads.g.doubleclick.net/gampad/ads?sz=640x480&"
@"iu=/124319096/external/single_ad_samples&ciu_szs=300x250&impl=s&gdfp_req=1&env=vp&"
@"output=vast&unviewed_position_start=1&cust_params=deployment%3Ddevsite%26sample_ct%3Dlinear&"
@"correlator=";

static NSString *GuestCellIdentifier = @"GuestCell";
static NSString *kOptionTableViewCell = @"OptionTableViewCell";

@interface VideoDetailViewController ()<ACActionSheetManagerDelegate, TLIndexPathControllerDelegate, OptionTableViewCellDelegate>

@property (strong, nonatomic) TLIndexPathController *indexPathController;
//@property (strong, nonatomic) PlaybackSource *videoPlaybackSource;
//@property (strong, nonatomic) PlaybackSource *audioPlaybackSource;
@property (strong, nonatomic) NSArray *playbackSources;

@property (strong, nonatomic) UIAlertView *alertViewStreaming;
@property (strong, nonatomic) UIAlertView *alertViewDownload;
@property (strong, nonatomic) UILabel *labelPlayAs;
@property (strong, nonatomic) UIProgressView *progressView;

@property (strong, nonatomic) NSTimer *timerPlayback;
@property (strong, nonatomic) NSTimer *timerDownload;

@property (nonatomic) NSInteger selectedTimeline;
@property (nonatomic) BOOL isPlaying;
@property (nonatomic) BOOL isDownloadStarted;
@property (nonatomic) BOOL videoLoaded;
@property (nonatomic, assign) BOOL isReachedEnd;

@property (nonatomic, strong) NSMutableArray *optionsDataSource;

@property (nonatomic, strong) AVPlayerViewController *avPlayerController;
@property (nonatomic, strong) PlayerControlsOverlay *playerControlsView;

@property (nonatomic) id playbackObserver;

@property (nonatomic) NSArray *adsArray;
@property (nonatomic, strong) id playerAdsObserver;
@property (nonatomic, strong) UIView *adsContainerView;

@property (nonatomic, assign) BOOL isReturnFullScreenIfNeeded;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *height;
@property (nonatomic) NSString *beaconStringUrl;

@property (nonatomic, assign) NSInteger currentVideoIndex;
@property (nonatomic, assign) BOOL isPlayerRequestPending;

@property (strong, nonatomic) UIAlertView *alertViewSignInRequired;
@property (strong, nonatomic) UIAlertView *alertViewNsvodRequired;

@end


@implementation VideoDetailViewController

#pragma mark - Lifecycle

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    //notify of complition of the video
    [ACAnalyticsManager playbackCompleted];

    if (self.playerAdsObserver) {
        [self.contentPlayhead.player removeTimeObserver:self.playerAdsObserver];
    }
    if (self.playbackObserver) {
        [self.avPlayer removeTimeObserver:self.playbackObserver];
    }
    
    NSLog(@"Destroying");
    //remove the instance that was created in case of going to a full screen mode and back
    if (self.avPlayerController) {
        if (self.avPlayerController.player){
            //[self.avPlayerController.player pause]; //caused crash in the emulator
            self.avPlayerController.player = nil;
        }
        self.avPlayerController = nil;
    }
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self trackScreenName:kAnalyticsScreenNameVideoDetail];
    
    [self setupAdsLoader];
    [self setupView];
    [self configureView];
    
    
    self.actionSheetManager = [ACActionSheetManager new];
    self.actionSheetManager.delegate = self;
    
    // Restrict rotation
    [AppDelegate appDelegate].restrictRotation = YES;
    self.isReturnFullScreenIfNeeded = NO;
    
    self.indexPathController = [self indexPathController];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayerDidReachedEnd:) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    
    self.isPlayerRequestPending = NO;
    
    if (self.adsContainerView == nil){
        self.adsContainerView = [[UIView alloc] initWithFrame:self.imageThumbnail.frame];
        [self.view addSubview:self.adsContainerView];
    }
    [self setupNotifications];
}

- (void)configureDataSource {
    
    self.optionsDataSource = [[NSMutableArray alloc] init];
    if (kDownloadsEnabled) {
        TableSectionDataSource *playAs = [[TableSectionDataSource alloc] init];
        playAs.title = @"Play as";
        playAs.type = Play;
        self.labelPlayAs = [[UILabel alloc] init];
        NSString *mediaType = (self.isAudio == true) ? @"Audio" : @"Video";
        self.labelPlayAs.text = mediaType;
        self.labelPlayAs.textColor = (kAppColorLight) ? [UIColor darkGrayColor] : [UIColor whiteColor];
        self.labelPlayAs.font = [UIFont fontWithName:kFontSemibold size:14];
        [self.labelPlayAs sizeToFit];
        playAs.accessoryView = self.labelPlayAs;
        [self.optionsDataSource addObject:playAs];
        
        if (self.playbackSources != nil) {
            if (self.playbackSources.count > 0) {
                TableSectionDataSource *downloadItem = [[TableSectionDataSource alloc] init];
                DownloadInfo *downloadInfo = [[DownloadOperationController sharedInstance] downloadInfoWithTaskId:self.video.downloadTaskId];
                downloadItem.type = Download;
                if (downloadInfo.isDownloading) {
                    downloadItem.title = @"Downloading...";
                    [self.progressView setHidden:NO];
                } else {
                    downloadItem.title = @"Download";
                }
                downloadItem.accessoryView = [[CustomizeImageView alloc] initLightImage:[UIImage imageNamed:@"IconDownloadsB"] andDarkImage:[UIImage imageNamed:@"IconDownloadsW"]];
                [self.optionsDataSource addObject:downloadItem];
            }
        }
    }
    
    if ((kFavoritesViaAPI == NO) || ([ACStatusManager isUserSignedIn] == YES)) {
        TableSectionDataSource *favoriteItem = [[TableSectionDataSource alloc] init];
        favoriteItem.type = Favourite;
        if ([UIUtil isYes:self.video.isFavorite]) {
            favoriteItem.title = @"Unfavorite";
            favoriteItem.accessoryView = [[CustomizeImageView alloc] initLightImage:[UIImage imageNamed:@"IconFavoritesBFull"] andDarkImage:[UIImage imageNamed:@"IconFavoritesWFull"]];
        } else {
            favoriteItem.title = @"Favorite";
            favoriteItem.accessoryView = [[CustomizeImageView alloc] initLightImage:[UIImage imageNamed:@"IconFavoritesB"] andDarkImage:[UIImage imageNamed:@"IconFavoritesW"]];
        }
        [self.optionsDataSource addObject:favoriteItem];
    }
    
    if (kShareVideoEnabled) {
        TableSectionDataSource *shareItem = [[TableSectionDataSource alloc] init];
        shareItem.title = @"Share";
        shareItem.type = Share;
        shareItem.accessoryView = [[CustomizeImageView alloc] initLightImage:[UIImage imageNamed:@"IconShareB"] andDarkImage:[UIImage imageNamed:@"IconShareW"]];
        [self.optionsDataSource addObject:shareItem];
    }
    
    if (kSubscribeToWatchAdFree) {
        if (kNativeSubscriptionEnabled == false) {
            TableSectionDataSource *swafItem = [[TableSectionDataSource alloc] init];
            swafItem.title = @"Watch Ad Free";
            swafItem.type = WatchAdFree;
            swafItem.accessoryView = [[CustomizeImageView alloc] initLightImage:[UIImage imageNamed:@"iconSubscribeB"] andDarkImage:[UIImage imageNamed:@"iconSubscribeW"]];
            [self.optionsDataSource addObject:swafItem];
        }
    }
    
    [self.tableViewOptions reloadData];
}

- (void)moviePlayerDidReachedEnd:(NSNotification*) notification{
    if([notification.userInfo[MPMoviePlayerPlaybackDidFinishReasonUserInfoKey] integerValue] == MPMovieFinishReasonPlaybackEnded && notification.object == self.player) {
        self.isReachedEnd = YES;
        
        [ACAnalyticsManager playbackCompleted];
    }
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    if (!self.isPlaying){
        [self initPlayer];
    }
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    // if request still being made or autoplay triggered
    if (self.isPlayerRequestPending){
        BOOL requiresUniversalEntitlement = [self videoRequiresUniversalEntitlement:self.video];
        
        if (kNativeSubscriptionEnabled &&
            [self.video.subscription_required intValue] == 1 &&
            [[ACPurchaseManager sharedInstance] isActiveSubscription] == false) {
            [self.playerControlsView setAsPause];
            self.isPlayerRequestPending = NO;
            [self.playerControlsView showSelf];
        } else if (requiresUniversalEntitlement &&
                   [ACStatusManager isUserSignedIn] == false){
            [self.playerControlsView setAsPause];
            self.isPlayerRequestPending = NO;
            [self.playerControlsView showSelf];
        } else {
            self.isPlayerRequestPending = NO;
            self.avPlayer = nil;
            self.avPlayerController = nil;
            [self initPlayer];
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    if (self.isMovingFromParentViewController) {
        
        // Disable timer
        if (self.timerPlayback.isValid)
            [self.timerPlayback invalidate];
        self.timerPlayback = nil;
        [self.timerDownload invalidate];
        self.timerDownload = nil;
        
        [self saveCurrentPlaybackTime];
        
        //Check if we should remove video before stopping the player
        if(self.isReachedEnd && self.video.isDownload.boolValue && [[NSUserDefaults standardUserDefaults] boolForKey:kSettingKey_AutoRemoveWatchedContent]) {
            [ACDownloadManager deleteDownloadedVideo:self.video];
        }
        
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        
        //restrict rotation
        [AppDelegate appDelegate].restrictRotation = YES;
    }
    
    if (self.avPlayer != nil && self.avPlayer.rate > 0.0f) {
        [self.avPlayer pause];
    }
    
    if (self.adsManager != nil) {
        [self.adsManager pause];
    }
}


#pragma mark - Setup

- (void)setupView {
    
    [self.tableViewGuestList registerNib:[UINib nibWithNibName:@"GuestTableViewCell" bundle:nil] forCellReuseIdentifier:GuestCellIdentifier];
    
    self.arrayViews = @[self.viewSummary, self.viewGuestList, self.viewTimeline, self.viewOptions];
    self.tableViewGuestList.tableFooterView = [UIView new];
    self.tableViewTimeline.tableFooterView = [UIView new];
    self.tableViewOptions.tableFooterView = [UIView new];
    [self.tableViewOptions registerNib:[UINib nibWithNibName:kOptionTableViewCell bundle:nil] forCellReuseIdentifier:kOptionTableViewCell];
    self.selectedTimeline = -1;
    self.isPlaying = NO;
    self.isAudio = NO;
    self.isWebVideo = NO;
    self.isDownloadStarted = NO;
    [self.imageThumbnail setHidden:YES];
    [self configureColors];
    
}

- (void)setupPlayerControlsListeners {
    UITapGestureRecognizer *viewPressed = [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(viewPressed:)];
    [self.playerControlsView.view addGestureRecognizer:viewPressed];
    
    
    UITapGestureRecognizer *playPausePressed = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                action:@selector(playPausePressed:)];
    [self.playerControlsView.playPauseIcon addGestureRecognizer:playPausePressed];
    
    
    UITapGestureRecognizer *backIconPressed = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                action:@selector(backIconPressed:)];
    [self.playerControlsView.backIcon addGestureRecognizer:backIconPressed];
    
    
    UITapGestureRecognizer *nextIconPressed = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                action:@selector(nextIconPressed:)];
    [self.playerControlsView.nextIcon addGestureRecognizer:nextIconPressed];
    
    
    UITapGestureRecognizer *fullScreenPressed = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                      action:@selector(fullScreenPressed:)];
    [self.playerControlsView.fullScreenIcon addGestureRecognizer:fullScreenPressed];
    
    
    [self.playerControlsView.progressBar addTarget:self action:@selector(progressBarValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.playerControlsView.progressBar addTarget:self action:@selector(progressBarTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.playerControlsView.progressBar addTarget:self action:@selector(progressBarTouchUpOutside:) forControlEvents:UIControlEventTouchUpOutside];
    
    CMTime interval = CMTimeMakeWithSeconds(0.5, NSEC_PER_SEC);
    self.playbackObserver = [self.avPlayer addPeriodicTimeObserverForInterval:interval
                                              queue:NULL usingBlock:^(CMTime time) {
                                                [self.playerControlsView updateCurrentTime:[NSNumber numberWithDouble:CMTimeGetSeconds(time)]];
                                              }];
}

- (void)configurePlayerControlsState {
    BOOL enableNav;
    if ([self.videos count] > 1) {
        enableNav = YES;
    } else {
        enableNav = NO;
    }
    [self.playerControlsView updateState:NO withCurrentTime:self.video.playTime withDuration:self.video.duration enableUserNavigation:enableNav];
}

- (void)configureColors{
    self.segmenedControl.tintColor = kClientColor;
}

- (void)setDetailItem:(id)newDetailItem {
    
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
    }
    
    self.video = (Video *)_detailItem;
    CLS_LOG(@"AFTER: %@", self.detailItem);
    
}

- (void)setVideos:(NSMutableArray<Video *>*)videos withIndex:(NSIndexPath*)index {
    
    // Get index from clicked item
    self.currentVideoIndex = (int)[index row];
    if (self.currentVideoIndex == nil) { self.currentVideoIndex = 0; }
    
    self.videos = videos;
    
    if (_detailItem != self.videos[self.currentVideoIndex]) {
        _detailItem = self.videos[self.currentVideoIndex];
    }
    
    self.video = (Video *)_detailItem;
    
    CLS_LOG(@"Current Video: %@", self.video);
}

- (void)configureView {
    
    // Update the user interface for the detail item.
    if (self.detailItem) {
        // Set title and thumbnail
        self.title = @"";
        
        [self setThumbnailImage];
        [self hideSectionsForHighlightVideo];
        [self setSummary];
        //[self setGuestList];
        [self setTimeline];
        
        _videoShareTitleString = self.video.title;
        
    }
    
    if (self.playerControlsView){
        [self configurePlayerControlsState];
    }
    
}

- (void)setThumbnailImage{
    
    NSURL *thumbnailURL = [NSURL URLWithString:self.video.thumbnailUrl];
    [self.imageThumbnail sd_setImageWithURL:thumbnailURL completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        self.imageThumbnail.image = image;
    }];
}

- (void)hideSectionsForHighlightVideo{
    
    // Hide segmented control on Highlight page
    if (self.video.isHighlight.boolValue == YES) {
        [self.segmenedControl setHidden:YES];
        [self.segmenedControl addConstraint:[NSLayoutConstraint constraintWithItem:self.segmenedControl attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0]];
    }
    
}

- (void)setSummary{
    
    // Set Summary
    self.webViewSummary.delegate = self;
    NSString *htmlFile;

    if (kAppColorLight){
        htmlFile = [[NSBundle mainBundle] pathForResource:@"VideoSummaryLight" ofType:@"html"];
    } else {
        htmlFile = [[NSBundle mainBundle] pathForResource:@"VideoSummary" ofType:@"html"];
    }
    NSString *htmlString = [NSString stringWithContentsOfFile:htmlFile encoding:NSUTF8StringEncoding error:nil];
    htmlString = [NSString stringWithFormat:htmlString, self.video.title, self.video.short_description, nil/*[UIUtil tagsWithKeywords:self.video.keywords]*/];
    [self.webViewSummary loadHTMLString:htmlString baseURL:nil];
    
}

- (void)setGuestList{
    
    // Set Guest List
    [[RESTServiceController sharedInstance] loadGuests:self.video.vId InPage:nil];
    NSError *error = nil;
    if (![self.indexPathController performFetch:&error]) {
        CLS_LOG(@"Fetched Results Error: %@", error);
    }
    
}

- (void)setTimeline{
    
    // Set Timeline
    self.arrayTimeline = [[NSMutableArray alloc] init];
    for (NSDictionary *dict in self.video.segments) {
        Timeline *timeline = [[Timeline alloc] initWithStart:[dict valueForKey:@"start"]
                                                         End:[dict valueForKey:@"end"]
                                                       Title:[dict valueForKey:@"description"]];
        [self.arrayTimeline addObject:timeline];
    }
    
}


- (BOOL)hidesBottomBarWhenPushed {
    return YES;
}


#pragma mark - Video Player

- (void)initPlayer{
    
    NSString *localVideoPath = [ACDownloadManager localPathForDownloadedVideo:self.video];
    NSString *localAudioPath = [ACDownloadManager localAudioPathForDownloadForVideo:self.video];
    
    BOOL videoFileExists = [[NSFileManager defaultManager] fileExistsAtPath:localVideoPath];
    BOOL audioFileExists = [[NSFileManager defaultManager] fileExistsAtPath:localAudioPath];
    
    // Init video player
    if (self.video.isDownload.boolValue == YES && ( audioFileExists || videoFileExists)){
        if (videoFileExists == YES) {
            self.isAudio = NO;
        } else if (audioFileExists == YES) {
            self.isAudio = YES;
        }
    }
    
    [self refreshPlayer];
    
}

- (BOOL)isPlayerUrlEmpty {
    AVURLAsset *urlAsset = (AVURLAsset *)self.avPlayer.currentItem.asset;
    
    if ([urlAsset.URL.absoluteString length] > 0) {
        return NO;
    } else {
        return YES;
    }
}

- (void)refreshPlayer{
    
    [self showActivityIndicator];
    [self checkDownloadVideo];

    if (self.isPlayerRequestPending == NO){ // prevent multiple video player requests
        if (self.isAudio) {
            
            NSString *localAudioPath = [ACDownloadManager localAudioPathForDownloadForVideo:self.video];
            BOOL audioFileExists = [[NSFileManager defaultManager] fileExistsAtPath:localAudioPath];
            
            NSURL *url;
            
            if (audioFileExists == YES) {
                url = [NSURL fileURLWithPath:localAudioPath];
                [self setupPlayer:url];
            } else {
                [self playStreamingAudio];
            }
            
        } else {
            
            NSString *localVideoPath = [ACDownloadManager localPathForDownloadedVideo:self.video];
            BOOL videoFileExists = [[NSFileManager defaultManager] fileExistsAtPath:localVideoPath];
            
            NSURL *url;
            
            if (videoFileExists == YES) {
                url = [NSURL fileURLWithPath:localVideoPath];
                [self setupPlayer:url];
            } else {
                [self playStreamingVideo];
            }
            
        }
    }
    
}

- (void)checkDownloadVideo {
    [[RESTServiceController sharedInstance] getVideoPlayerWithVideo:self.video downloadInfo:YES withCompletionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        //
        if (error) {
            CLS_LOG(@"Failed: %@", error);
        } else {
            CLS_LOG(@"Success");
            NSError *localError = nil;
            NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
            
            if (localError != nil) {
                CLS_LOG(@"Failed: %@", localError);
            } else {
                self.playbackSources = [[RESTServiceController sharedInstance] streamPlaybackSourcesFromRootDictionary:parsedObject];
                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                CLS_LOG(@"source: %ld", (long)[httpResponse statusCode]);
            }
        }
        [self configureDataSource];
    }];
}

- (void)playStreamingVideo {
    
    [[RESTServiceController sharedInstance] getVideoPlayerWithVideo:self.video downloadInfo: NO withCompletionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        self.isPlayerRequestPending = NO;
        
        [self hideActivityIndicator];
        
        if (error) {
            CLS_LOG(@"Failed: %@", error);
        } else {
            
            CLS_LOG(@"Success");
            NSError *localError = nil;
            NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
            
            if (localError != nil) {
                CLS_LOG(@"Failed: %@", localError);
            } else {
                PlaybackSource *source = [[RESTServiceController sharedInstance] videoStreamPlaybackSourceFromRootDictionary:parsedObject];
                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                CLS_LOG(@"source: %ld", (long)[httpResponse statusCode]);

                //check for status code family
                if ([response isStatusFamilyError]) {
                    NSMutableString *message = [[NSMutableString alloc] initWithString:@"Something is not right."];
                    if ([[parsedObject valueForKey:@"message"] length] > 0) {
                        message = [[NSMutableString alloc] initWithString:[parsedObject valueForKey:@"message"]];
                    }
                    [self showBasicAlertWithTitle:kString_TitleStreamFail WithMessage:message];
                } else {
                    //check for Ads
                    self.adsArray = [[ACAdManager sharedInstance] adsArrayFromParsedDictionary:parsedObject];
                   
                    //check for beacon analytics
                    self.beaconStringUrl = [[ACAnalyticsManager sharedInstance] beaconFromParsedDictionary:parsedObject];
                  
                   
                    //check if view is visible to avoid playing on background
                    if (self.navigationController.visibleViewController.class) {
                        // viewController is visible
                        if (source != nil && source.urlString != nil) {
                            [self playVideoFromSource:source];
                        }else{
                            [self playStreamingAudio];
                        }
                    }
                }
            }
        }
    }];
}

- (void)playStreamingAudio {
    
    [[RESTServiceController sharedInstance] getAudioPlayerWithVideo:self.video WithCompletionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        [self hideActivityIndicator];
        
        if (error) {
            
            CLS_LOG(@"Failed: %@", error);
            
        } else {
            
            CLS_LOG(@"Success");
            NSError *localError = nil;
            NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
            
            if (localError != nil) {
                
                CLS_LOG(@"Failed: %@", localError);
                
            } else {
                
                PlaybackSource *source = [[RESTServiceController sharedInstance] audioStreamPlaybackSourceFromRootDictionary:parsedObject];
                
                if (source != nil && source.urlString != nil) {
                    
                    self.isAudio = YES;
                    [self playVideoFromSource:source];
                    
                }else{
                    CLS_LOG(@"response: %@", response);
                    self.isAudio = NO;
                    [self showBasicAlertWithTitle:kString_TitleStreamFail WithMessage:kString_MessageNoAudioStream];
                    
                }
                
            }
            
        }
        
    }];
    
}

- (void)changeMediaType{
    
    self.isAudio = !self.isAudio;
    [self refreshPlayer];
    
}

- (void)setupPlayer:(NSURL *)url {
    //[self removePlayer];
    //[self.avPlayer pause];
    //player.replaceCurrentItem(with: AVPlayerItem(url: streamingURL))
    
    if (self.avPlayer == nil) {
        self.avPlayer = [[AVPlayer alloc] initWithPlayerItem:[[AVPlayerItem alloc] initWithURL:url]];
    } else {
        [self.avPlayer replaceCurrentItemWithPlayerItem:[[AVPlayerItem alloc] initWithURL:url]];
    }
    
    self.contentPlayhead = [[IMAAVPlayerContentPlayhead alloc] initWithAVPlayer:self.avPlayer];
    //Create PlayerViewController for player controls
    if (self.avPlayerController == nil) {
        self.avPlayerController = [[AVPlayerViewController alloc] init];
        [self.avPlayerController.view setFrame:self.imageThumbnail.bounds];
        [self.avPlayerController setPlayer:self.avPlayer];
        [self addChildViewController:self.avPlayerController];
        [self.view addSubview:self.avPlayerController.view];
        [self.avPlayerController didMoveToParentViewController:self];
        self.avPlayerController.view.translatesAutoresizingMaskIntoConstraints = NO;
        
        // use custom controls
        self.avPlayerController.showsPlaybackControls = NO;
    }
    
    if (self.playerControlsView == nil) {
        self.playerControlsView = [[PlayerControlsOverlay alloc] initWithFrame:self.imageThumbnail.bounds];
        self.playerControlsView.view.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:self.playerControlsView.view];
        
        [self configurePlayerControlsState];
        [self setupPlayerControlsListeners];
    } else {
        [self configurePlayerControlsState];
    }

    //setup analytics for a player
    if (self.beaconStringUrl)
        [[ACAnalyticsManager sharedInstance] setupAkamaiMediaAnalytics:self.avPlayer withVideo:self.video];
    
    //check if your ringer is off, you won't hear any sound when it's off. To prevent that, we use
    NSError *_error = nil;
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error: &_error];
    
    if (self.isAudio) {
        [self setupAudioPlayerView];
    } else {
        [self setupVideoPlayerView];
    }
    
    //  [self setupSharedPlayerView];
    
    [self loadSavedPlaybackTime];
    
    //timer to update timeline
    self.timerPlayback = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(updatePlaybackTime:) userInfo:nil repeats:YES];
    
    [self setPlayingStatus];
}

- (void)setupAudioPlayerView {
    
    [self setupAudioPlayerBackground];
    
    [self.activityIndicator stopAnimating];
    
    CGRect frame = self.imageThumbnail.frame;
    [self.avPlayerController.view setFrame:CGRectMake(frame.origin.x, frame.origin.y + frame.size.height - kPlayerControlHeight, frame.size.width, kPlayerControlHeight)];
    [self.adsContainerView setFrame:CGRectMake(frame.origin.x, frame.origin.y + frame.size.height - kPlayerControlHeight, frame.size.width, kPlayerControlHeight)];

    self.avPlayerController.view.backgroundColor = [UIColor clearColor];
    
    [AppDelegate appDelegate].restrictRotation = YES;
    
    [self hideActivityIndicator];
    [self.labelPlayAs setText:@"Audio"];
    [self.labelPlayAs sizeToFit];
    
    [self setupConstraints];
    
}

- (void)setupAudioPlayerBackground {
    
    [self.imageThumbnail setHidden:NO];
    NSURL *thumbnailURL = [NSURL URLWithString:self.video.thumbnailUrl];
    [self.imageThumbnail sd_setImageWithURL:thumbnailURL placeholderImage:[UIImage imageNamed:@"ImagePlaceholder"] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        self.imageThumbnail.image = image;
    }];
    [self.view bringSubviewToFront:self.imageThumbnail];
    [self.view bringSubviewToFront:self.avPlayerController.view];
    [self.view bringSubviewToFront:self.adsContainerView];
    [self.view bringSubviewToFront:self.activityIndicator];
    [self.view bringSubviewToFront:self.playerControlsView.view];
}

- (void)setupVideoPlayerView {
    
    //[self.avPlayerController.view setFrame:self.imageThumbnail.frame];
    //[self.adsContainerView setFrame:self.imageThumbnail.frame];
    [self setupConstraints];
    [self hideActivityIndicator];
    [AppDelegate appDelegate].restrictRotation = NO;
    [self.labelPlayAs setText:@"Video"];
    [self.labelPlayAs sizeToFit];
    
}

- (void)setupPlayerBackground {
    [self setupAudioPlayerBackground];
    CGRect frame = self.imageThumbnail.frame;
    [self.avPlayerController.view setFrame:CGRectMake(frame.origin.x, frame.origin.y + frame.size.height - kPlayerControlHeight, frame.size.width, kPlayerControlHeight)];
    [self.adsContainerView setFrame:CGRectMake(frame.origin.x, frame.origin.y + frame.size.height - kPlayerControlHeight, frame.size.width, kPlayerControlHeight)];
    self.avPlayerController.view.backgroundColor = [UIColor clearColor];
    [self setupConstraints];
    
    [self.avPlayerController.view setHidden:NO];
    
    
}

- (void)setupConstraints {
    self.adsContainerView.translatesAutoresizingMaskIntoConstraints = NO;
    
    // AVPlayerController
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.avPlayerController.view
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.imageThumbnail
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1
                                                           constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.avPlayerController.view
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.imageThumbnail
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1
                                                           constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.avPlayerController.view
                                                          attribute:NSLayoutAttributeLeft
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.imageThumbnail
                                                          attribute:NSLayoutAttributeLeft
                                                         multiplier:1
                                                           constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.avPlayerController.view
                                                          attribute:NSLayoutAttributeRight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.imageThumbnail
                                                          attribute:NSLayoutAttributeRight
                                                         multiplier:1
                                                           constant:0]];

    // Player Controls View
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.playerControlsView.view
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.imageThumbnail
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1
                                                           constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.playerControlsView.view
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.imageThumbnail
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1
                                                           constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.playerControlsView.view
                                                          attribute:NSLayoutAttributeLeft
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.imageThumbnail
                                                          attribute:NSLayoutAttributeLeft
                                                         multiplier:1
                                                           constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.playerControlsView.view
                                                          attribute:NSLayoutAttributeRight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.imageThumbnail
                                                          attribute:NSLayoutAttributeRight
                                                         multiplier:1
                                                           constant:0]];
    
    // Ads View
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.adsContainerView
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.imageThumbnail
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1
                                                           constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.adsContainerView
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.imageThumbnail
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1
                                                           constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.adsContainerView
                                                          attribute:NSLayoutAttributeLeading
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.imageThumbnail
                                                          attribute:NSLayoutAttributeLeading
                                                         multiplier:1
                                                           constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.adsContainerView
                                                          attribute:NSLayoutAttributeTrailing
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.imageThumbnail
                                                          attribute:NSLayoutAttributeTrailing
                                                         multiplier:1
                                                           constant:0]];
    [self.view layoutIfNeeded];
}

- (void)setupSharedPlayerView {
    
//    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.player.view
//                                                          attribute:NSLayoutAttributeTrailing
//                                                          relatedBy:NSLayoutRelationEqual
//                                                             toItem:self.imageThumbnail
//                                                          attribute:NSLayoutAttributeTrailing
//                                                         multiplier:1
//                                                           constant:0]];
//    
//    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.player.view
//                                                          attribute:NSLayoutAttributeLeading
//                                                          relatedBy:NSLayoutRelationEqual
//                                                             toItem:self.imageThumbnail
//                                                          attribute:NSLayoutAttributeLeading
//                                                         multiplier:1
//                                                           constant:0]];
//    
//    [self.view bringSubviewToFront:self.player.view];
//    self.player.view.userInteractionEnabled = YES;
    
}

#pragma mark - Status

- (void)setPlayingStatus{
    
    if (self.video.isPlayed.boolValue == NO && self.video.isPlaying.boolValue == NO) {
        
        self.video.isPlaying = @YES;
        [[ACSPersistenceManager sharedInstance] saveContext];
        
    }
    
    self.isPlaying = YES;
    
    if (self.isPlaying == YES) {
        
        id tracker = [[GAI sharedInstance] defaultTracker];
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:kAnalyticsScreenNameVideoDetail action:@"Video Played" label:self.video.title value:nil] build]];
        
    }
    
}

- (BOOL)isFullScreen {
    int screenWidth = (int)(round(self.view.frame.size.width));
    int avPlayerWidth = (int)(round(self.avPlayerController.videoBounds.size.width));
    return (screenWidth == avPlayerWidth);
}

#pragma mark - Place Saving

- (void)saveCurrentPlaybackTime{
    
    if (self.video == nil) {
        return;
    }
    
    Video *video = self.video;
    NSNumber *time = [NSNumber numberWithDouble:CMTimeGetSeconds([self.avPlayer.currentItem currentTime])];
    
    if (video != nil) {
        video.playTime = time;
        [[ACSPersistenceManager sharedInstance] saveContext];
    }
    
}

- (void)loadSavedPlaybackTime{
    
    CMTime time = CMTimeMakeWithSeconds([self.video.playTime doubleValue], 1);

    [self.avPlayer seekToTime:time];//HLS video cut to 10 seconds per segment. Your chapter start postion should fit the value which is multipes of 10. As the segment starts with I frame, on this way, you can get quick seek time and accurate time.
    
    //pre-roll only for now only for non logged in users
    if ([ACStatusManager isUserSignedIn] == NO && self.adsArray.count > 0) {
        if ([self isPlayerUrlEmpty] == NO) {
            [self requestAds];
        }
        
    } else {
        [self.avPlayer play];
        
        [self.playerControlsView setAsPlay];
        [self.playerControlsView showSelf];
    }
}

- (NSUInteger)nextIndex {
    int newIndex = (int)self.currentVideoIndex + 1;
    if (newIndex < [self.videos count]){
        return (NSUInteger)newIndex;
    } else {
        return 0;
    }
}

- (NSUInteger)prevIndex {
    int newIndex = (int)self.currentVideoIndex - 1;
    if (newIndex >= 0){
        return (NSUInteger)newIndex;
    } else {
        return (NSUInteger)[self.videos count] - 1;
    }
}

- (void)loadVideo:(NSUInteger)newIndex {
    UserPreferences *userPrefs = [ACSPersistenceManager getUserPreferences];
    
    // Autoplay
    if (kAutoplay && [userPrefs.autoplay boolValue] && [self.videos count] > 0 && self.isPlayerRequestPending == NO){
        [self saveCurrentPlaybackTime]; // save current video time first

        self.currentVideoIndex = newIndex;
        
        _detailItem = [self.videos objectAtIndex:(self.currentVideoIndex)];
        self.video = (Video *)_detailItem; // next video
        
        [self configureView];
        [self configurePlayerControlsState];
        
        BOOL requiresUniversalEntitlement = [self videoRequiresUniversalEntitlement:self.video];
        
        if (kNativeSubscriptionEnabled &&
            [self.video.subscription_required intValue] == 1 &&
            [[ACPurchaseManager sharedInstance] isActiveSubscription] == false) {
            
            if ([self isFullScreen]) [self.avPlayerController exitFullscreen];
            
            [self setThumbnailImage];
            self.avPlayerController = nil;
            [self setupPlayer:[NSURL URLWithString:@""]];
            [self setupPlayerBackground];
            
            self.isPlayerRequestPending = YES;
            [self showNsvodRequiredAlert];
            
        } else if (requiresUniversalEntitlement &&
                   [ACStatusManager isUserSignedIn] == false){
            
            if ([self isFullScreen]) [self.avPlayerController exitFullscreen];
            
            [self setThumbnailImage];
            self.avPlayerController = nil;
            [self setupPlayer:[NSURL URLWithString:@""]];
            [self setupPlayerBackground];
            
            self.isPlayerRequestPending = YES;
            [self showSignInRequiredAlert];
            
        } else {
            [self refreshPlayer];
            self.isPlayerRequestPending = YES;
        }
    }
}

#pragma mark - Video Entitlement Checks

// only checks supported universal entitlement
- (BOOL)videoRequiresUniversalEntitlement:(Video *)video {
    if (video.subscription_required.intValue == 1){
        return YES;
    }
    return NO;
}

// only checks supported native entitlement
- (BOOL)videoRequiresNativeEntitlement:(Video *)video {
    if (video.subscription_required.intValue == 1){
        return YES;
    }
    return NO;
}

#pragma mark - Timeline

- (int)currentTimelineIndex {
    int currentTimeline = 0;
    for (Timeline *timeline in self.arrayTimeline) {
        double time = (double)self.avPlayer.currentTime.value * 1000.0f;
        if (time >= timeline.start.doubleValue) {
            currentTimeline = (int)[self.arrayTimeline indexOfObject:timeline];
        }
    }
    return currentTimeline;
}

- (void)updatePlaybackTime:(NSTimer*)theTimer {
    
    int currentTimeline = [self currentTimelineIndex];
    
    // Update timeline cell
    if (currentTimeline > self.selectedTimeline) {
        self.selectedTimeline = currentTimeline;
        [self.tableViewTimeline reloadData];
        TimelineTableViewCell *cell = (TimelineTableViewCell *)[self.tableViewTimeline cellForRowAtIndexPath:[NSIndexPath indexPathForRow:currentTimeline inSection:0]];
        cell.labelTime.textColor = kYellowColor;
        cell.labelDescription.textColor = kYellowColor;
        cell.imagePlayIndicator.hidden = NO;
    }
    
    //    CLS_LOG(@"currentTimeline: %d", currentTimeline);
}



#pragma mark - MoviePlayer Notifications

- (void)setupNotifications{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayBackDidFinish:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.avPlayer.currentItem];
    
    /*
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayBackDidFinish:) name:MPMoviePlayerPlaybackDidFinishNotification object:self.player];
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePreloadDidFinish:) name:MPMediaPlaybackIsPreparedToPlayDidChangeNotification object:nil];
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieTimedMetadataUpdated:) name:MPMoviePlayerTimedMetadataUpdatedNotification object:nil];
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieFullscreenWillExit:) name:MPMoviePlayerWillExitFullscreenNotification object:nil];
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieLoadStateDidChange:) name:MPMoviePlayerLoadStateDidChangeNotification object:nil];*/
    
}

- (void)moviePlayBackDidFinish:(NSNotification *)notification{
    if ((int)CMTimeGetSeconds(self.avPlayer.currentItem.currentTime) >=  (int)CMTimeGetSeconds(self.avPlayer.currentItem.duration) && !self.isPlayerRequestPending ){
        //reset to beginning
        [self.avPlayer pause];
        self.video.playTime = [NSNumber numberWithInt:0];

        [self.avPlayer seekToTime:CMTimeMakeWithSeconds(0, 1)
                completionHandler:^(BOOL finished) {
                    NSLog(@"moviePlayBackDidFinish");
                    // Set played
                    if (self.video.isDownload.boolValue == YES && self.video.isPlayed.boolValue == NO) {
                        self.video.isPlayed = @YES;
                    }
                    
                    [[ACSPersistenceManager sharedInstance] saveContext];
                    
                    [self loadVideo:[self nextIndex]];
                }
        ];
    }
}

- (void)moviePreloadDidFinish:(NSNotification *)notification {
    [self.activityIndicator stopAnimating];
}


- (void)movieTimedMetadataUpdated:(NSNotification *)notification {
    //
}

- (void)movieFullscreenWillExit:(NSNotification *)notification {
    
    if ([self isRegularSizeClass] == NO) {
        [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger: UIInterfaceOrientationPortrait] forKey:@"orientation"];
    }
    
}

- (void)movieLoadStateDidChange:(NSNotification *)notification {
    
    MPMoviePlayerController *player = notification.object;
    MPMovieLoadState loadState = player.loadState;
    
    /* Enough data has been buffered for playback to continue uninterrupted. */
    if (loadState == MPMovieLoadStatePlaythroughOK || loadState == MPMovieLoadStatePlayable){
        
        //should be called only once , so using self.videoLoaded - only for  first time  movie loaded , if required. This function wil be called multiple times after stalled
        if(!self.videoLoaded){
            
            self.player.currentPlaybackTime = [self.video.playTime doubleValue];
            self.videoLoaded = YES;
            
        }
        
    }
    
    [[MediaPlayerManager sharedInstance] setNowPlayingInfo];
    
}


#pragma mark - Download Progress

- (void)showDownloadProgress:(id)sender{
    
    DownloadInfo *downloadInfo = [[DownloadOperationController sharedInstance] downloadInfoWithTaskId:self.video.downloadTaskId];
    double totalBytesWritten = downloadInfo.totalBytesWritten;
    double totalBytesExpectedToWrite = downloadInfo.totalBytesExpectedToWrite;
    
    if (downloadInfo.isDownloading){
        self.isDownloadStarted = YES;
    }
    
    // Set download started
    if (self.isDownloadStarted) {
        
//        UITableViewCell *cell = [self.tableViewOptions cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
//        cell.textLabel.text = @"Downloading...";
//        [self.progressView setHidden:NO];
        [self.tableViewOptions reloadData];
        
    }
    
    // Set download progress
    if (totalBytesWritten != 0 && totalBytesExpectedToWrite != 0) {
        self.progressView.progress = totalBytesWritten / totalBytesExpectedToWrite;
    } else {
        self.progressView.progress = 0;
    }
    
    // Set download finished
    if (self.isDownloadStarted && !downloadInfo.isDownloading) {
        [self clearDownloadProgress];
    }
    
}

- (void)clearDownloadProgress{
    
    [self.timerDownload invalidate];
    self.timerDownload = nil;
    [self.tableViewOptions reloadData];
//    UITableViewCell *cell = [self.tableViewOptions cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
//    cell.textLabel.text = @"Download";
//    cell.textLabel.textColor = [UIColor whiteColor];
//    [self.progressView setHidden:YES];
    
}


#pragma mark - IBActions

- (IBAction)SegmentValueChanged:(UISegmentedControl *)sender {
    
    for (UIView *view in self.arrayViews) {
        
        [view setHidden:YES];
        
    }
    
    if (sender.selectedSegmentIndex == 0){
        
        [self.viewSummary setHidden:NO];
        
        /* }else if (sender.selectedSegmentIndex == 1){
         
         [self.viewGuestList setHidden:NO];
         
         }else if (sender.selectedSegmentIndex == 2){
         
         [self.viewTimeline setHidden:NO];
         */
    }else if (sender.selectedSegmentIndex == 1){
        
        [self.viewOptions setHidden:NO];
        
    }
    
}

// Player Controls View
- (void)viewPressed:(id)sender {
    [self.playerControlsView updateIsCasting:self.avPlayer.externalPlaybackActive];
    [self.playerControlsView viewPressed:sender];
}
- (void)playPausePressed:(id)sender {
    [self.playerControlsView playPausePressed:sender];
    
    BOOL requiresUniversalEntitlement = [self videoRequiresUniversalEntitlement:self.video];
    
    if (kNativeSubscriptionEnabled &&
        [self.video.subscription_required intValue] == 1 &&
        [[ACPurchaseManager sharedInstance] isActiveSubscription] == false) {

        [self showNsvodRequiredAlert];
        
    } else if (requiresUniversalEntitlement &&
               [ACStatusManager isUserSignedIn] == false){
        [self showSignInRequiredAlert];
        
    } else {
        if ((self.avPlayer.rate != 0) && (self.avPlayer.error == nil)) {
            [self.avPlayer pause];
        } else {
            [self.avPlayer play];
        }
    }
    
}
- (void)backIconPressed:(id)sender {
    [self.playerControlsView backIconPressed:sender];

    // save
    [self.avPlayer pause];
    [self saveCurrentPlaybackTime];
    
    [self loadVideo:[self prevIndex]];
}
- (void)nextIconPressed:(id)sender {
    [self.playerControlsView nextIconPressed:sender];

    // save
    [self.avPlayer pause];
    [self saveCurrentPlaybackTime];
    
    [self loadVideo:[self nextIndex]];
}
- (void)fullScreenPressed:(id)sender {
    [self.playerControlsView fullScreenPressed:sender];
    
    UIInterfaceOrientation orientation = [[UIDevice currentDevice] orientation];
    
    if (orientation != UIInterfaceOrientationPortrait && orientation != UIInterfaceOrientationPortraitUpsideDown) {
        [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger: UIInterfaceOrientationPortrait] forKey:@"orientation"];
    } else {
        [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger: UIInterfaceOrientationLandscapeRight] forKey:@"orientation"];
    }
}

- (void)progressBarValueChanged:(id)sender {
    [self.playerControlsView progressBarValueChanged:sender];
}

- (void)progressBarTouchUpInside:(id)sender {
    CMTime time = CMTimeMakeWithSeconds(self.playerControlsView.progressBar.value, 1);
    [self.avPlayer seekToTime:time];
    [self.playerControlsView progressBarTouchUpInside:sender];
}
- (void)progressBarTouchUpOutside:(id)sender {
    CMTime time = CMTimeMakeWithSeconds(self.playerControlsView.progressBar.value, 1);
    [self.avPlayer seekToTime:time];
    [self.playerControlsView progressBarTouchUpOutside:sender];
}


#pragma mark - Button Actions

- (void)buttonFacebookTapped:(id)sender{
    
    CGPoint touchPoint = [sender convertPoint:CGPointZero toView:self.tableViewGuestList];
    NSIndexPath *indexPath = [self.tableViewGuestList indexPathForRowAtPoint:touchPoint];
    Guest *selectedGuest = [self.indexPathController.dataModel itemAtIndexPath:indexPath];
    CLS_LOG(@"facebook: %@", selectedGuest.facebook);
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:selectedGuest.facebook]];
    
}

- (void)buttonTwitterTapped:(id)sender{
    
    CGPoint touchPoint = [sender convertPoint:CGPointZero toView:self.tableViewGuestList];
    NSIndexPath *indexPath = [self.tableViewGuestList indexPathForRowAtPoint:touchPoint];
    Guest *selectedGuest = [self.indexPathController.dataModel itemAtIndexPath:indexPath];
    CLS_LOG(@"twitter: %@", selectedGuest.twitter);
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:selectedGuest.twitter]];
    
}

- (void)buttonYoutubeTapped:(id)sender{
    
    CGPoint touchPoint = [sender convertPoint:CGPointZero toView:self.tableViewGuestList];
    NSIndexPath *indexPath = [self.tableViewGuestList indexPathForRowAtPoint:touchPoint];
    Guest *selectedGuest = [self.indexPathController.dataModel itemAtIndexPath:indexPath];
    CLS_LOG(@"youtube: %@", selectedGuest.youtube);
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:selectedGuest.youtube]];
    
}

- (void)changeFavorite:(OptionTableViewCell *)cell{
    
    TableSectionDataSource *favoriteSource = cell.optionDataItem;
    
    if (![UIUtil isYes:self.video.isFavorite]) {
        // Favorite
        [[RESTServiceController sharedInstance] favoriteVideo:self.video];
        favoriteSource.title = @"Unfavorite";
        favoriteSource.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IconFavoritesWFull"]];
    } else {
        // Unfavorite
        [[RESTServiceController sharedInstance] unfavoriteVideo:self.video];
        favoriteSource.title = @"Favorite";
        favoriteSource.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IconFavoritesW"]];
    }
    [self.tableViewOptions reloadData];
}

#pragma mark - Rotation Setup



- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator{
    
    if (self.isWebVideo == YES || self.isAudio == YES) {
        return;
    }
    
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context){
        
        UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
        
        switch (orientation) {
                
            case UIInterfaceOrientationLandscapeLeft: {
                //[self.player setFullscreen:YES]ж
            }
                break;
                
            case UIInterfaceOrientationLandscapeRight: {
                //[self.player setFullscreen:YES];
            }
                break;
                
            default:
                break;
                
        }
        
    } completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        
    }];
    
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}

#pragma mark IMA SDK Setup

- (void)setupAdsLoader {
    if (self.adsLoader == nil){
        self.adsLoader = [[IMAAdsLoader alloc] initWithSettings:nil];
    }
    self.adsLoader.delegate = self;
}

- (void)requestAds {
    
    __block IMAAdDisplayContainer *adDisplayContainer =
    [[IMAAdDisplayContainer alloc] initWithAdContainer:self.adsContainerView companionSlots:nil];
    
    __block NSMutableDictionary *adsDictionary = [[NSMutableDictionary alloc] init];
    __block NSMutableArray *adsTags = [[NSMutableArray alloc] init];

    
    BOOL isPrerollUsed = NO;
    NSMutableArray *adOffsets = [[NSMutableArray alloc] init];
    NSArray *requests = [[ACAdManager sharedInstance] adRequstsFromArray:self.adsArray];
    
    BOOL isRequestPending = self.isPlayerRequestPending;
    
    for (AdObject *adObject in requests) {
        
        NSString *newTag = [self replaceAdMacros:adObject.tag];
        
        // only listen for ads at or after video start point
        if ([NSNumber numberWithDouble:adObject.offset] >= self.video.playTime){
            if (adObject.offset == 0) {
                isPrerollUsed = YES;
                IMAAdsRequest *request = [[IMAAdsRequest alloc] initWithAdTagUrl:newTag
                                                              adDisplayContainer:adDisplayContainer
                                                                 contentPlayhead:self.contentPlayhead
                                                                     userContext:nil];
                
                if (!isRequestPending) [self.adsLoader requestAdsWithRequest:request];
            } else {
                
                [adOffsets addObject:adObject.offsetValue];
                [adsDictionary setObject:newTag forKey:[NSString stringWithFormat:@"%d", (int)adObject.offset]];
                [adsTags addObject:newTag];
            }
        }
    }
    
    
    if (adOffsets.count > 0) {
        __weak typeof(self) weakSelf = self;
        
        self.playerAdsObserver = [self.contentPlayhead.player addBoundaryTimeObserverForTimes:adOffsets queue:NULL usingBlock:^{

            if (adsTags.count > 0) {
                NSString *tag = adsTags.firstObject;
                [adsTags removeObjectAtIndex:0];
                IMAAdsRequest *request = [[IMAAdsRequest alloc] initWithAdTagUrl:tag
                                                              adDisplayContainer:adDisplayContainer
                                                                 contentPlayhead:weakSelf.contentPlayhead
                                                                     userContext:nil];
                if (!isRequestPending) [weakSelf.adsLoader requestAdsWithRequest:request];
            }
        }];
    }

    if (!isPrerollUsed) {
        [self.avPlayer play];
        
        [self.playerControlsView setAsPlay];
        [self.playerControlsView showSelf];
    }

}

- (NSMutableString*)replaceAdMacros:(NSString *)string {
    
    NSMutableString *tag = [NSMutableString stringWithString: string];
    
    NSUUID *realUuid = [[UIDevice currentDevice] identifierForVendor];
    unsigned char uuidBytes[16];
    [realUuid getUUIDBytes:uuidBytes];
    NSString *uuid = [NSString stringWithFormat: @"%@", realUuid];
    
    NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
    NSString *bundleName = [NSString stringWithFormat:@"%@", [info objectForKey:@"CFBundleDisplayName"]];
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    
    NSString *idfa = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    NSString *appId = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
    
    [tag replaceOccurrencesOfString:@"[uuid]"
                         withString: uuid
                            options:NSLiteralSearch
                              range:NSMakeRange(0, tag.length)];
    
    [tag replaceOccurrencesOfString:@"[app_name]"
                         withString: bundleName
                            options:NSLiteralSearch
                              range:NSMakeRange(0, tag.length)];
    
    [tag replaceOccurrencesOfString:@"[app_bundle]"
                         withString: bundleIdentifier
                            options:NSLiteralSearch
                              range:NSMakeRange(0, tag.length)];
    
    [tag replaceOccurrencesOfString:@"[app_domain]"
                         withString: bundleIdentifier
                            options:NSLiteralSearch
                              range:NSMakeRange(0, tag.length)];
    
    [tag replaceOccurrencesOfString:@"[device_type]"
                         withString: @"7"
                            options:NSLiteralSearch
                              range:NSMakeRange(0, tag.length)];
    
    [tag replaceOccurrencesOfString:@"[device_make]"
                         withString: @"Apple"
                            options:NSLiteralSearch
                              range:NSMakeRange(0, tag.length)];
    
    [tag replaceOccurrencesOfString:@"[device_model]"
                         withString: machineName()
                            options:NSLiteralSearch
                              range:NSMakeRange(0, tag.length)];
    
    [tag replaceOccurrencesOfString:@"[device_ifa]"
                         withString: idfa
                            options:NSLiteralSearch
                              range:NSMakeRange(0, tag.length)];
    
    [tag replaceOccurrencesOfString:@"[vpi]"
                         withString: @"mp4"
                            options:NSLiteralSearch
                              range:NSMakeRange(0, tag.length)];
    
    [tag replaceOccurrencesOfString:@"[app_id]"
                         withString: appId
                            options:NSLiteralSearch
                              range:NSMakeRange(0, tag.length)];
    
    [tag replaceOccurrencesOfString:@"[device_ua]"
                         withString: @"zype_ios"
                            options:NSLiteralSearch
                              range:NSMakeRange(0, tag.length)];
    
    [tag replaceOccurrencesOfString:@"[ip_address]"
                         withString: @"168.0.0.1"
                            options:NSLiteralSearch
                              range:NSMakeRange(0, tag.length)];
    
    [tag replaceOccurrencesOfString:@" "
                         withString: @"-"
                            options:NSLiteralSearch
                              range:NSMakeRange(0, tag.length)];
    
    return tag;
}

NSString* machineName() {
    struct utsname systemInfo;
    uname(&systemInfo);
    
    return [NSString stringWithCString:systemInfo.machine
                              encoding:NSUTF8StringEncoding];
}

- (void)contentDidFinishPlaying:(NSNotification *)notification {
    // Make sure we don't call contentComplete as a result of an ad completing.
    if (notification.object == self.avPlayer.currentItem) {
        [self.adsLoader contentComplete];
    }
}

#pragma mark AdsLoader Delegates

- (void)adsLoader:(IMAAdsLoader *)loader adsLoadedWithData:(IMAAdsLoadedData *)adsLoadedData {
    // Grab the instance of the IMAAdsManager and set ourselves as the delegate.
    self.adsManager = adsLoadedData.adsManager;
    self.adsManager.delegate = self;
    // Create ads rendering settings to tell the SDK to use the in-app browser.
    IMAAdsRenderingSettings *adsRenderingSettings = [[IMAAdsRenderingSettings alloc] init];
    adsRenderingSettings.webOpenerPresentingController = self;
    // Initialize the ads manager.
    [self.adsManager initializeWithAdsRenderingSettings:adsRenderingSettings];
}

- (void)adsLoader:(IMAAdsLoader *)loader failedWithErrorData:(IMAAdLoadingErrorData *)adErrorData {
    // Something went wrong loading ads. Log the error and play the content.
    NSLog(@"Error loading ads: %@", adErrorData.adError.message);
    [self.adsContainerView setHidden:YES];
    [self.avPlayerController.view setHidden:NO];
    [self.playerControlsView.view setHidden:NO];
    [self.avPlayer play];
    [self.playerControlsView setAsPlay];
    [self.playerControlsView showSelf];
}

#pragma mark AdsManager Delegates

- (void)adsManager:(IMAAdsManager *)adsManager didReceiveAdEvent:(IMAAdEvent *)event {
    // When the SDK notified us that ads have been loaded, play them.
    NSLog(@"%ld", (long)event.type);
    if (event.type == kIMAAdEvent_LOADED) {
        if ([self isFullScreen] == YES) {
            [self.avPlayerController exitFullscreen:^{
                self.isReturnFullScreenIfNeeded = YES;
                [self.avPlayerController updateFocusIfNeeded];
                [adsManager start];
            }];
        } else {
            [adsManager start];
        }
    } else if (event.type == kIMAAdEvent_STARTED){
        NSLog(@"subviews %ld", (long)self.avPlayerController.view.subviews);

    } else if (event.type == kIMAAdEvent_ALL_ADS_COMPLETED) {
        self.adsManager = nil;
    } else if (event.type == kIMAAdEvent_COMPLETE) {
        if (self.isReturnFullScreenIfNeeded == YES) {
            [self.avPlayerController goFullscreen];
            self.isReturnFullScreenIfNeeded = NO;
        }
    }
}

- (void)adsManager:(IMAAdsManager *)adsManager didReceiveAdError:(IMAAdError *)error {
    // Something went wrong with the ads manager after ads were loaded. Log the error and play the
    // content.
    NSLog(@"AdsManager error: %@", error.message);
    [self.adsContainerView setHidden:YES];
    [self.avPlayerController.view setHidden:NO];
    [self.playerControlsView.view setHidden:NO];
    [self.avPlayer play];
    [self.playerControlsView setAsPlay];
    [self.playerControlsView showSelf];
}

- (void)adsManagerDidRequestContentPause:(IMAAdsManager *)adsManager {
    // The SDK is going to play ads, so pause the content.
    [self.adsContainerView setHidden:NO];
    [self.avPlayerController.view setHidden:YES];
    [self.playerControlsView.view setHidden:YES];
    [self.avPlayer pause];
}

- (void)adsManagerDidRequestContentResume:(IMAAdsManager *)adsManager {
    // The SDK is done playing ads (at least for now), so resume the content.
    [self.adsContainerView setHidden:YES];
    [self.avPlayerController.view setHidden:NO];
    [self.playerControlsView.view setHidden:NO];
    [self.avPlayer play];
    [self.playerControlsView setAsPlay];
    [self.playerControlsView showSelf];
}


#pragma mark - AlertViews

- (void)showDownloadAlertWithTitle:(NSString *)title WithMessage:(NSString *)message{
    
    if (!self.alertViewDownload) {
        self.alertViewDownload = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"Settings" otherButtonTitles:@"OK", nil];
    } else {
        [self.alertViewDownload setTitle:title];
        [self.alertViewDownload setMessage:message];
    }
    
    [self.alertViewDownload show];
    self.alertViewDownload.tag = 999;
    
}

- (void)showSignInRequiredAlert {
    
    if (!self.alertViewSignInRequired){
        self.alertViewSignInRequired = [[UIAlertView alloc] initWithTitle:@"Sign In Required"
                                                                  message:@"You do not have access to this video. Please sign in with your account to watch this video."
                                                                 delegate:self
                                                        cancelButtonTitle:@"Cancel"
                                                        otherButtonTitles:@"Sign In", nil];
    }
    self.alertViewSignInRequired.tag = 997;
    
    [self.alertViewSignInRequired show];
}

- (void)showNsvodRequiredAlert {
    
    if (!self.alertViewNsvodRequired){
        self.alertViewNsvodRequired = [[UIAlertView alloc] initWithTitle:@"Requires Subscription"
                                                                  message:@"You do not have access to this video. Please subscribe to watch this video."
                                                                 delegate:self
                                                        cancelButtonTitle:@"Cancel"
                                                        otherButtonTitles:@"Subscribe", nil];
    }
    self.alertViewNsvodRequired.tag = 996;
    
    [self.alertViewNsvodRequired show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (self != nil) {
        
        if (alertView.tag == 999 && buttonIndex == 0){
            
            [self.tabBarController setSelectedIndex:4];
            
        }
        
        if (alertView.tag == 998 && buttonIndex == 0){
            [self.navigationController popViewControllerAnimated:YES];
        }
        
        if (alertView.tag == 997 && buttonIndex == 1){ // clicked sign in
            // transition to sign in view
            
            if (self.isFullScreen){
                [self.avPlayerController exitFullscreen];
            }
            
            [UIUtil showSignInViewFromViewController:self];
        } else if (alertView.tag == 997 && buttonIndex == 0){
            [self configurePlayerControlsState];
            self.isPlayerRequestPending = NO;
            [self.playerControlsView showSelf];
        }
        
        if (alertView.tag == 996 && buttonIndex == 1){ // clicked nsvod subscribe
            
            if (self.isFullScreen){
                [self.avPlayerController exitFullscreen];
            }
            
            // transition to native sub view
            [UIUtil showSubscriptionViewFromViewController:self];
        } else if (alertView.tag == 996 && buttonIndex == 0){
            [self configurePlayerControlsState];
            self.isPlayerRequestPending = NO;
            [self.playerControlsView showSelf];
        }
        
    }
    
}


#pragma mark - TLIndexPathController

- (TLIndexPathController *)indexPathController{
    
    if (_indexPathController == nil) {
        
        _indexPathController = [[TLIndexPathController alloc] initWithFetchRequest:[self fetchRequest] managedObjectContext:[ACSPersistenceManager sharedInstance].managedObjectContext sectionNameKeyPath:nil identifierKeyPath:nil cacheName:nil];
        _indexPathController.delegate = self;
        
    }
    
    return _indexPathController;
    
}


#pragma mark - TLIndexPathControllerDelegate

- (void)controller:(TLIndexPathController *)controller didUpdateDataModel:(TLIndexPathUpdates *)updates{
    
    [updates performBatchUpdatesOnTableView:self.tableViewGuestList withRowAnimation:UITableViewRowAnimationNone];
    
}


#pragma mark - Fetched Request

- (NSFetchRequest *)fetchRequest{
    
    NSPredicate *predicate = [self fetchPredicate];
    NSFetchRequest *fetchRequest = [ACSPersistenceManager guestFetchRequestWithPredicate:predicate];
    
    return fetchRequest;
    
}

- (NSPredicate *)fetchPredicate{
    
    NSPredicate *predicate = [NSPredicate predicateWithValue:NO];
    
    // Specify criteria for filtering which objects to fetch
    if ([self.video.zobject_ids count] > 0) {
        NSString *predicateFormat = @"gId == %@";
        for (int i = 0; i < [self.video.zobject_ids count] - 1; ++i) {
            predicateFormat = [predicateFormat stringByAppendingString:@" OR gId == %@"];
        }
        predicate = [NSPredicate predicateWithFormat:predicateFormat argumentArray:self.video.zobject_ids];
    }
    
    return predicate;
    
}


#pragma mark - TableView Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (tableView == self.tableViewGuestList) {
        return [self.indexPathController.dataModel numberOfRowsInSection:section];
    } else if (tableView == self.tableViewTimeline){
        return [self.arrayTimeline count];
    } else if (tableView == self.tableViewOptions){
        return [self.optionsDataSource count];
    }
     
    return 0;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (tableView == self.tableViewGuestList) {
        
        GuestTableViewCell *cell = (GuestTableViewCell *)[tableView dequeueReusableCellWithIdentifier:GuestCellIdentifier];
        
        Guest *guest = [self.indexPathController.dataModel itemAtIndexPath:indexPath];
        cell.labelName.text = guest.title;
        cell.textDescription.text = [guest.full_description stringByStrippingHTML];
        
        NSURL *thumbnailURL = [NSURL URLWithString:guest.thumbnailUrl];
        //[cell.imageThumbnail pin_setImageFromURL:thumbnailURL placeholderImage:[UIImage imageNamed:@"ImagePerson"]];
        [self.imageThumbnail sd_setImageWithURL:thumbnailURL placeholderImage:[UIImage imageNamed:@"ImagePerson"]];
        
        [cell.buttonFacebook addTarget:self action:@selector(buttonFacebookTapped:) forControlEvents:UIControlEventTouchUpInside];
        [cell.buttonTwitter addTarget:self action:@selector(buttonTwitterTapped:) forControlEvents:UIControlEventTouchUpInside];
        [cell.buttonYoutube addTarget:self action:@selector(buttonYoutubeTapped:) forControlEvents:UIControlEventTouchUpInside];
        
        if ([UIUtil validateUrl:guest.facebook]){
            cell.buttonFacebook.hidden = YES;
        }
        if ([UIUtil validateUrl:guest.twitter]){
            cell.buttonTwitter.hidden = YES;
        }
        if ([UIUtil validateUrl:guest.youtube]){
            cell.buttonYoutube.hidden = YES;
        }
        
        return cell;
        
    } else if (tableView == self.tableViewTimeline) {
        
        static NSString *CellIdentifier = @"TimelineCell";
        TimelineTableViewCell *cell = (TimelineTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        int currentTimeline = [self currentTimelineIndex];
        Timeline *timeline = [self.arrayTimeline objectAtIndex:indexPath.row];
        cell.labelTime.text = [UIUtil timelineWithMilliseconds:timeline.start];
        cell.labelDescription.text = timeline.title;
        
        if (currentTimeline == indexPath.row) {
            cell.labelTime.textColor = kYellowColor;
            cell.labelDescription.textColor = kYellowColor;
            cell.imagePlayIndicator.hidden = NO;
        } else {
            cell.labelTime.textColor = [UIColor darkGrayColor];
            cell.labelDescription.textColor = [UIColor darkGrayColor];
            cell.imagePlayIndicator.hidden = YES;
        }
        
        return cell;
        
    } else if (tableView == self.tableViewOptions) {
        
        OptionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kOptionTableViewCell];
        TableSectionDataSource *optionItem = self.optionsDataSource[indexPath.row];
        [cell configureCell:optionItem];
        if (optionItem.type == Download) {
            self.progressView = cell.progressView;
            DownloadInfo *downloadInfo = [[DownloadOperationController sharedInstance] downloadInfoWithTaskId:self.video.downloadTaskId];
            [cell setProgress:downloadInfo];
        }
        [cell setDelegate:self];
        
        return cell;
        
//        if (kDownloadsEnabled){
//            switch (indexPath.row) {
//                    
//                case 0: {
//                    
//                    cell.textLabel.text = @"Play as";
//                    self.labelPlayAs = [[UILabel alloc] init];
//                    self.labelPlayAs.text = @"Video";
//                    self.labelPlayAs.textColor = [UIColor whiteColor];
//                    self.labelPlayAs.font = [UIFont fontWithName:kFontSemibold size:14];
//                    [self.labelPlayAs sizeToFit];
//                    cell.accessoryView = self.labelPlayAs;
//                    
//                }
//                    break;
//                    
//                case 1: {
//                    
//                    // Add progress view
//                    float width = self.view.frame.size.width - kProgressViewMarginLeft - (kProgressViewMarginRight * 2);
//                    self.progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(kProgressViewMarginLeft, kProgressViewMarginRight, width, kProgressViewHeight)];
//                    [self.progressView setTintColor:kSystemBlue];
//                    [self.progressView setHidden:YES];
//                    [cell addSubview:self.progressView];
//                    
//                    DownloadInfo *downloadInfo = [[DownloadOperationController sharedInstance] downloadInfoWithTaskId:self.video.downloadTaskId];
//                    if (downloadInfo.isDownloading) {
//                        
//                        cell.textLabel.text = @"Downloading...";
//                        //cell.textLabel.textColor = [UIColor whiteColor];
//                        [self.progressView setHidden:NO];
//                        self.timerDownload = [NSTimer scheduledTimerWithTimeInterval:1.0f
//                                                                              target:self
//                                                                            selector:@selector(showDownloadProgress:)
//                                                                            userInfo:nil
//                                                                             repeats:YES];
//                        
//                    } else {
//                        cell.textLabel.text = @"Download";
//                    }
//                    
//                    cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IconDownloadsW"]];
//                    
//                }
//                    break;
//                    
//                case 2: {
//                    
//                    if ([UIUtil isYes:self.video.isFavorite]) {
//                        
//                        cell.textLabel.text = @"Unfavorite";
//                        cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IconFavoritesWFull"]];
//                        
//                    } else {
//                        
//                        cell.textLabel.text = @"Favorite";
//                        cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IconFavoritesW"]];
//                        
//                    }
//                    
//                }
//                    break;
//                    
//                case 3: {
//                    
//                    cell.textLabel.text = @"Share";
//                    cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IconShareW"]];
//                    
//                }
//                    break;
//                    
//            }
//        } else {
//            
//            switch (indexPath.row) {
//                    
//                case 0: {
//                    
//                    if ([UIUtil isYes:self.video.isFavorite]) {
//                        
//                        cell.textLabel.text = @"Unfavorite";
//                        cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IconFavoritesWFull"]];
//                        
//                    } else {
//                        
//                        cell.textLabel.text = @"Favorite";
//                        cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IconFavoritesW"]];
//                        
//                    }
//                    
//                }
//                    break;
//                    
//                case 1: {
//                    
//                    cell.textLabel.text = @"Share";
//                    cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IconShareW"]];
//                    
//                }
//                    break;
//                    
//            }
//        }
//        
//        return cell;
//        
    }else {
        
        static NSString *CellIdentifier = @"Cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        return cell;
        
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (tableView == self.tableViewGuestList){
        return 110.0f;
    }else{
        return 50.0f;
    }
    
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (tableView == self.tableViewTimeline) {
        
        // Seek video
        Timeline *timeline = [self.arrayTimeline objectAtIndex:indexPath.row];
        [self.player setCurrentPlaybackTime:[UIUtil secondsWithMilliseconds:timeline.start]];
        [self.player play];
        [self.playerControlsView setAsPlay];
        [self.playerControlsView showSelf];
        
        // Update timeline cell
        self.selectedTimeline = (int)indexPath.row;
        [self.tableViewTimeline reloadData];
        TimelineTableViewCell *cell = (TimelineTableViewCell *)[self.tableViewTimeline cellForRowAtIndexPath:indexPath];
        cell.labelTime.textColor = kYellowColor;
        cell.labelDescription.textColor = kYellowColor;
        cell.imagePlayIndicator.hidden = NO;
    }
    
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [cell setBackgroundColor:[UIColor clearColor]];
}


#pragma mark - UIWebView delegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        
        [[UIApplication sharedApplication] openURL:[request URL]];
        return NO;
        
    }
    
    return YES;
    
}

#pragma mark - OptionTableViewCellDelegate

- (void)onDidPlayTapped:(OptionTableViewCell *)cell {
    [self.actionSheetManager showPlayAsActionSheet];
}

- (void)onDidDownloadTapped:(OptionTableViewCell *)cell {
    if (kDownloadsForAllUsersEnabled == NO) {
        if (kNativeSubscriptionEnabled == NO) {
            if ([ACStatusManager isUserSignedIn] == false) {
                [UIUtil showSignInViewFromViewController:self];
                return;
            }
        } else {
            if ([ACStatusManager isUserSignedIn] == false && self.selectedVideo.subscription_required.intValue == 1) {
                [UIUtil showIntroViewFromViewController:self];
                return;
            } else {
                if ([self.video.subscription_required intValue] == 1 && [[ACPurchaseManager sharedInstance] isActiveSubscription] == false) {
                    [UIUtil showSubscriptionViewFromViewController:self];
                    return;
                }
            }
        }
    }
    
    [self.actionSheetManager showDownloadActionSheetWithVideo:self.video withPlaybackSources:self.playbackSources];
}

- (void)onDidFavoriteTapped:(OptionTableViewCell *)cell {
    [self changeFavorite:cell];
}

- (void)onDidShareTapped:(OptionTableViewCell *)cell {
    [self.actionSheetManager showShareActionSheetWithVideo:self.video];
}

- (void)onDidWatchAdFreeTapped:(OptionTableViewCell *)cell {
    if (kNativeSubscriptionEnabled == NO) {
        if (kSubscribeToWatchAdFree) {
            if ([ACStatusManager isUserSignedIn] == false) {
                [UIUtil showSignInViewFromViewController:self];
                return;
            }
        }
    }
}

#pragma mark - ACActionSheetManagerDelegate

- (void)acActionSheetManagerDelegatePlayAsAudioTapped{
    
    if (!self.isAudio) {
        
        [self changeMediaType];
        
    }
    
}

- (void)acActionSheetManagerDelegatePlayAsVideoTapped {
    
    if (self.isAudio) {
        [self changeMediaType];
    }
    
}

- (void)acActionSheetManagerDelegateDownloadTapped {
    self.isDownloadStarted = NO;
    self.timerDownload = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(showDownloadProgress:) userInfo:nil repeats:YES];
}

- (void)acActionSheetManagerDelegateReloadVideo:(Video *)video{
    
    [self clearDownloadProgress];
    
}

- (void)acActionSheetManagerDelegatePresentViewController:(UIViewController *)viewController {
    
    [self presentViewController:viewController animated:YES completion:^{ }];
    
}

- (void)acActionSheetManagerDelegateShowActionSheet:(UIActionSheet *)actionSheet {
    
    [actionSheet showInView:self.view];
    
}

- (void)acActionSheetManagerDelegateDismissModal {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}


@end
