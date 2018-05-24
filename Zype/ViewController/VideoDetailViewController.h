//
//  VideoDetailViewController.h
//  Zype
//
//  Created by ZypeTech on 1/30/15.
//  Copyright (c) 2015 Zype. All rights reserved.
//

#import "MediaPlaybackBaseViewController.h"

#import <WebKit/WebKit.h>
#import <CoreData/CoreData.h>

@import Social;
@import MessageUI;
@import GoogleInteractiveMediaAds;

@interface VideoDetailViewController : MediaPlaybackBaseViewController <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, IMAAdsLoaderDelegate, IMAAdsManagerDelegate>

@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UIImageView *imageThumbnail;
@property (weak, nonatomic) IBOutlet UIView *viewSummary;
@property (weak, nonatomic) IBOutlet UIView *viewGuestList;
@property (weak, nonatomic) IBOutlet UIView *viewTimeline;
@property (weak, nonatomic) IBOutlet UIView *viewOptions;
@property (strong, nonatomic) NSArray *arrayViews;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmenedControl;
@property (weak, nonatomic) IBOutlet UIWebView *webViewSummary;
@property (weak, nonatomic) IBOutlet UITableView *tableViewGuestList;
@property (weak, nonatomic) IBOutlet UITableView *tableViewTimeline;
@property (weak, nonatomic) IBOutlet UITableView *tableViewOptions;
@property (strong, nonatomic) NSString *videoShareTitleString;
@property (strong, nonatomic) Video *video;
@property (strong, nonatomic) NSMutableArray *arrayTimeline;

@property (strong, nonatomic) NSMutableArray<Video *> *videos;

@property (nonatomic) BOOL isLive;

- (void)setupPlayer:(NSURL *)url;

- (void)setVideos:(NSMutableArray<Video *>*)videos withIndex:(NSIndexPath*)index;

@property (nonatomic, retain) NSDate *start;

// IMA SDK
/// Entry point for the SDK. Used to make ad requests.
@property(nonatomic, strong) IMAAdsLoader *adsLoader;
// Playhead used by the SDK to track content video progress and insert mid-rolls.
@property(nonatomic, strong) IMAAVPlayerContentPlayhead *contentPlayhead;
/// Main point of interaction with the SDK. Created by the SDK as the result of an ad request.
@property(nonatomic, strong) IMAAdsManager *adsManager;

@end
