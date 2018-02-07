//
//  EpisodeController.h
//  acumiashow
//
//  Created by ZypeTech on 6/28/15.
//  Copyright (c) 2015 Zype. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <Crashlytics/Crashlytics.h>

#import "EpisodeControllerDelegate.h"
#import "ACSPredicates.h"
#import "DownloadStatusCell.h"

#import "TLIndexPathController.h"
#import "TLIndexPathItem.h"

NS_ENUM(NSInteger, ACSEpisodeControllerMode){
    
    ACSEpisodeControllerModeLatest = 0,
    ACSEpisodeControllerModeDownloads,
    ACSEpisodeControllerModeFavorites,
    ACSEpisodeControllerModeHighlights,
    ACSEpisodeControllerModeSearch
    
};


static NSString * const reuseIdentifier = @"EpisodeCell";
static NSString * const reusePlaylistIdentifier = @"PlaylistCell";
static NSString * const reusePlaylistCollectionCellIdentifier = @"PlaylistCollectionCell";

@interface EpisodeController : NSObject<NSFetchedResultsControllerDelegate, UIScrollViewDelegate, TLIndexPathControllerDelegate>

@property (weak, nonatomic) id<EpisodeControllerDelegate> delegate;
@property (strong, nonatomic) NSPredicate *filterPredicate;

@property (assign, nonatomic) enum ACSEpisodeControllerMode episodeControllerMode;

//subclass properties

@property (strong, nonatomic) TLIndexPathController *indexPathController;

@property (strong, nonatomic) UIScrollView *scrollView;

@property (strong, nonatomic) NSDate *fromDate;
@property (strong, nonatomic) NSDate *toDate;

@property (strong, nonatomic) NSString *playlistId;

@property (nonatomic) BOOL doneLoadingFromNetwork;
@property (nonatomic) BOOL editingEnabled;

//public methods
- (void)loadVideosFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate;
- (void)loadVideosFromPlaylistId:(NSString*)playlistId;
- (void)loadDownloadedVideos;
- (void)loadFavoriteVideos;
- (void)loadHiglightsVideos;
- (void)loadSearch:(NSString *)search searchMode:(enum ACSSearchMode)mode;
- (void)loadPlaylists;
- (void)loadPlaylist:(NSString*)playlistId;
- (void)loadPresentableObjects:(NSString*)playlistId;
- (void)loadZObjects;

- (id)objectAtIndexPath:(NSIndexPath *)indexPath;
- (id<DownloadStatusCell>)cellForDownloadTaskID:(NSNumber *)downloadTaskID;

- (void)setupSlidingHeader:(UIView *)header stickyView:(UIView *)stickyView topLayoutConstraint:(NSLayoutConstraint *)constraint;
- (void)scrollToTop;

//subclass methods
- (void)reloadData;
- (NSPredicate *)filterPredicate;
- (Video *)videoForDownloadTaskID:(NSNumber *)downloadTaskID;

@end
