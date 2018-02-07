//
//  EpisodeController.m
//  acumiashow
//
//  Created by ZypeTech on 6/28/15.
//  Copyright (c) 2015 Zype. All rights reserved.
//


#import "EpisodeController.h"
#import "ACSPredicates.h"
#import "ACSDataManager.h"
#import "ACSPersistenceManager.h"
#import "SlidingHeaderView.h"
#import "Video.h"
#import "Playlist.h"

@interface EpisodeController ()<SlidingHeaderViewDelegate>

@property (nonatomic, weak) NSFetchRequest *currentFetchRequest;

@property (strong, nonatomic) SlidingHeaderView *slidingHeader;
@property (strong, nonatomic) UIView *slidingHeaderStickyView;
@property (strong, nonatomic) NSLayoutConstraint *slidingHeaderTopLayoutConstraint;

@property (nonatomic, assign) CGFloat maxYOffset;
@property (nonatomic, assign) CGFloat minYOffset;

@end

@implementation EpisodeController


#pragma mark - Public Methods

- (void)loadVideosFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate{
    
    self.fromDate = fromDate;
    self.toDate = toDate;
    
    self.filterPredicate = [ACSPredicates fetchPredicateFromDate:self.fromDate toDate:self.toDate];
    [self performFetch];
    
}

- (void)loadVideosFromPlaylistId:(NSString*)playlistId {
    
    self.playlistId = playlistId;
    
    NSArray<PlaylistVideo *> *playlistVideos = [ACSPersistenceManager playlistVideosFromPlaylistId:playlistId];
    NSMutableArray *filterArray = [[NSMutableArray alloc] init];
   
    for (PlaylistVideo *currentPlaylistVideo in playlistVideos) {
        Video *currentVideo = currentPlaylistVideo.video;
        
        if (![filterArray containsObject:currentVideo]){
            [filterArray addObject:currentVideo];
        }
    }

    self.indexPathController = [[TLIndexPathController alloc] init];
    self.indexPathController.items = filterArray;
    [self reloadData];
}


- (void)loadDownloadedVideos{
    
    self.filterPredicate = [ACSPredicates fetchDownloadsPredicate];
    
    [self performFetch];
    
}

- (void)loadFavoriteVideos{
    
    self.filterPredicate = [ACSPredicates fetchFavoritesPredicate];
    
    [self performFetch];
    
}

- (void)loadHiglightsVideos{
    
    self.filterPredicate = [ACSPredicates fetchHighlightsPredicate];
    
    [self performFetch];
    
}

- (void)loadSearch:(NSString *)search searchMode:(enum ACSSearchMode)mode{
    
    self.filterPredicate = [ACSPredicates predicateWithSearchString:search searchMode:mode];
    [self performFetch];
    
}

- (void)performFetch {
    
    // Fetch data from core data and reload table
    self.indexPathController.fetchRequest = [self fetchRequest];
    self.currentFetchRequest = self.indexPathController.fetchRequest;
    
    NSError *error = nil;
    
    if (![self.indexPathController performFetch:&error]) {
        CLS_LOG(@"Fetched Results Error: %@", error);
    }
    else {
        [self reloadData];
    }
    
}

- (void)loadPlaylists {
    [self performPlaylistFetch];
}

- (void)loadPlaylist:(NSString*)playlistId {
    self.filterPredicate = [ACSPredicates predicateWithParentId:playlistId];
    [self performPlaylistFetch];
}

- (void)loadPresentableObjects:(NSString*)playlistId {
    self.filterPredicate = [ACSPredicates predicatePresentableObjectsWithParentId:playlistId];
    [self performPresentableObjectsFetch];
}

- (void)performPlaylistFetch {
    // Fetch data from core data and reload table
    self.indexPathController.fetchRequest = [self fetchPlaylistRequest];
    self.currentFetchRequest = self.indexPathController.fetchRequest;
    
    NSError *error = nil;
    
    if (![self.indexPathController performFetch:&error]) {
        CLS_LOG(@"Fetched Results Error: %@", error);
    }
    else {
        [self reloadData];
    }
    
}

- (void)performPresentableObjectsFetch {
    // Fetch data from core data and reload table
    self.indexPathController = [[TLIndexPathController alloc] initWithFetchRequest:[self fetchPresentableObjects] managedObjectContext:[ACSPersistenceManager sharedInstance].managedObjectContext sectionNameKeyPath:kAppKey_Type identifierKeyPath:nil cacheName:nil];
    self.currentFetchRequest = self.indexPathController.fetchRequest;
    
    NSError *error = nil;

    if (![self.indexPathController performFetch:&error]) {
        CLS_LOG(@"Fetched Results Error: %@", error);
    }
    else {
        [self reloadData];
    }

}

- (id)objectAtIndexPath:(NSIndexPath *)indexPath{
    
    return [self.indexPathController.dataModel itemAtIndexPath:indexPath];
    
}

- (id<DownloadStatusCell>)cellForDownloadTaskID:(NSNumber *)downloadTaskID{
    
    //subclass override
    return nil;
    
}

- (void)setupSlidingHeader:(UIView *)header stickyView:(UIView *)stickyView topLayoutConstraint:(NSLayoutConstraint *)constraint{
    
    self.slidingHeader = (SlidingHeaderView *)header;
    self.slidingHeaderStickyView = stickyView;
    self.slidingHeaderTopLayoutConstraint = constraint;
    
    [self setupScrollview];
    
}


- (Video *)videoForDownloadTaskID:(NSNumber *)downloadTaskID{
    
    NSArray *items = self.indexPathController.items;
    for (Video *video in items) {
        if ([video isKindOfClass:[Video class]]) {
            if ([video.downloadTaskId isEqualToNumber:downloadTaskID] == YES) {
                return video;
            }
        } 
    }
    
    return nil;
    
}


#pragma mark - Subclass Overrides

- (void)reloadData{
    
    //subclass override
    
}

- (void)scrollToTop{
    
    if (self.slidingHeader != nil) {
        
        [self scrollToMaximumHeader];
        
    }
    
}


#pragma mark - Lifecycle

- (instancetype)init{
    
    self = [super init];
    if (self){
         [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(finishedGettingResults) name:@"ResultsFromPlaylistReturned" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(finishedGettingResults) name:@"ResultsByDateReturned" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(finishedGettingSearchResults) name:@"ResultsBySearchReturned" object:nil];
        
    }
    
    return self;
    
}

- (void)dealloc{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

#pragma mark - Index path controller


- (TLIndexPathController *)indexPathController{
    
    if (_indexPathController == nil) {
        _indexPathController = [[TLIndexPathController alloc] initWithFetchRequest:[self fetchRequest] managedObjectContext:[ACSPersistenceManager sharedInstance].managedObjectContext sectionNameKeyPath:nil identifierKeyPath:nil cacheName:nil];
        _indexPathController.delegate = self;
    }
    
    return _indexPathController;
    
}

#pragma mark - TLIndexPathControllerDelegate

- (void)controller:(TLIndexPathController *)controller didUpdateDataModel:(TLIndexPathUpdates *)updates
{
    if (!updates.hasChanges) { return; }
    //only perform batch udpates if view is visible
    
    if (self.currentFetchRequest == self.indexPathController.fetchRequest) {
        [self.delegate episodeControllerPerformUpdates:updates];
    }
    
}


#pragma mark - Network Results

- (void)finishedGettingResults{
    
    if (self != nil) {
        
        self.doneLoadingFromNetwork = YES;
        [self.delegate episodeControllerDelegateDoneLoading];
        
    }
    
}

- (void)finishedGettingSearchResults{
    
    if (self != nil) {
        
        self.doneLoadingFromNetwork = YES;
        [self.delegate episodeControllerDelegateDoneLoading];
        
    }
    
}

#pragma mark - Fetched Results Controller


- (NSFetchRequest *)fetchRequest{
    
    NSFetchRequest *fetchRequest = [ACSPersistenceManager videoFetchRequestWithPredicate:self.filterPredicate];
    
    // Specify how the fetched objects should be sorted
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:kAppKey_PublishedAt ascending:NO];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];

    return fetchRequest;
    
}

- (NSFetchRequest *)fetchPlaylistRequest{
    
    NSFetchRequest *fetchRequest = [ACSPersistenceManager playlistFetchRequestWithPredicate:self.filterPredicate];
    
    // Specify how the fetched objects should be sorted
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:kAppKey_Priority ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
    
    return fetchRequest;
    
}

- (NSFetchRequest *)fetchPresentableObjects {
    
    NSFetchRequest *fetchRequest = [ACSPersistenceManager presentableObjectsFetchRequestWithPredicate:self.filterPredicate];
    fetchRequest.predicate = self.filterPredicate;
    // Specify how the fetched objects should be sorted
    NSSortDescriptor *sortTypeDescriptor = [[NSSortDescriptor alloc] initWithKey:kAppKey_Type ascending:YES];
    NSSortDescriptor *sortPriorityDescriptor = [[NSSortDescriptor alloc] initWithKey:kAppKey_Priority ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortTypeDescriptor, sortPriorityDescriptor, nil]];
    
    return fetchRequest;
}


- (void)setupScrollview{
    
    self.maxYOffset = self.slidingHeader.frame.size.height;
    self.minYOffset = self.slidingHeaderStickyView.frame.size.height;
    
    UIEdgeInsets contentInset = self.scrollView.contentInset;
    contentInset.top = self.maxYOffset;
    self.scrollView.contentInset = contentInset;
    self.scrollView.scrollIndicatorInsets = contentInset;
    
    self.scrollView.contentOffset = CGPointMake(self.scrollView.contentOffset.x, -CGRectGetHeight(self.slidingHeader.frame));
    
    self.slidingHeaderTopLayoutConstraint.constant = 0;
    [self.slidingHeader setNeedsLayout];
    
    self.slidingHeader.delegate = self;
    
}

- (void)scrollToMinimumHeader{
    
    UIEdgeInsets contentInset = self.scrollView.contentInset;
    contentInset.top = self.minYOffset;
    self.scrollView.contentInset = contentInset;
    self.scrollView.scrollIndicatorInsets = contentInset;
    
    self.scrollView.contentOffset = CGPointMake(self.scrollView.contentOffset.x, -self.minYOffset);
    
    self.slidingHeaderTopLayoutConstraint.constant = -(self.maxYOffset - self.minYOffset);
    [self.slidingHeader setNeedsLayout];
    
}

- (void)scrollToMaximumHeader{
    
    UIEdgeInsets contentInset = self.scrollView.contentInset;
    contentInset.top = self.maxYOffset;
    self.scrollView.contentInset = contentInset;
    self.scrollView.scrollIndicatorInsets = contentInset;
    
    self.scrollView.contentOffset = CGPointMake(self.scrollView.contentOffset.x, -self.maxYOffset);
    
    self.slidingHeaderTopLayoutConstraint.constant = 0;
    [self.slidingHeader setNeedsLayout];
    
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{

    CGFloat currentYOffset = scrollView.contentOffset.y + self.maxYOffset;
    CGFloat headerOffset = currentYOffset;
    
    //If the scrollview content is too short, don't try to make the toolbar sticky
    //It stutters when the scrollview rubberbands
    if ([self isContentTallerThanScrollView:scrollView] == YES) {
        
        if (currentYOffset > self.maxYOffset - self.minYOffset) {
            headerOffset = self.maxYOffset - self.minYOffset;
            
            UIEdgeInsets contentInset = scrollView.contentInset;
            contentInset.top = self.minYOffset;
            scrollView.contentInset = contentInset;
        }else{
            
            UIEdgeInsets contentInset = scrollView.contentInset;
            contentInset.top = self.maxYOffset;
            scrollView.contentInset = contentInset;
            
        }
        
    }

//    NSLog(@"//////////////");
//    NSLog(@"maxYOffset: %f", self.maxYOffset);
//    NSLog(@"minYOffset: %f", self.minYOffset);
//    NSLog(@"currentYOffset: %f", currentYOffset);
//    NSLog(@"headerOffset: %f", headerOffset);
    
    self.slidingHeaderTopLayoutConstraint.constant = -headerOffset;
    [self.slidingHeader setNeedsLayout];
    
}

- (BOOL)isContentTallerThanScrollView:(UIScrollView *)scrollView{
    
    if (scrollView.contentSize.height < scrollView.frame.size.height) {
        return NO;
    }
    
    return YES;
    
}


#pragma mark - SlidingHeaderViewDelegate

- (void)slidingHeaderViewFrameChanged{
    
    self.maxYOffset = self.slidingHeader.frame.size.height;
    self.minYOffset = self.slidingHeaderStickyView.frame.size.height;
    
    [self scrollToTop];
    
}

@end
