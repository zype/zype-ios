//
//  BaseTVLayoutController.m
//  Zype
//
//  Created by Александр on 11.12.2017.
//  Copyright © 2017 Zype. All rights reserved.
//

#import "BaseTVLayoutController.h"
#import "VideoTableViewCell.h"
#import "PlaylistTableViewCell.h"
#import "ACDownloadManager.h"
#import "DownloadOperationController.h"
#import "Playlist.h"
#import "PlaylistCollectionCell.h"
#import "ACSPersistenceManager.h"

@implementation BaseTVLayoutController

- (id<DownloadStatusCell>)cellForDownloadTaskID:(NSNumber *)downloadTaskID{
    
//    Video *video = [self videoForDownloadTaskID:downloadTaskID];
//
//    if (video != nil && self != nil && self.indexPathController.dataModel != nil && self.tableView != nil) {
//        NSIndexPath *indexPath = [self.indexPathController.dataModel indexPathForItem:video];
//
//        NSInteger numberOfSections = [self.tableView numberOfSections];
//        NSInteger numberOfRows = [self.tableView numberOfRowsInSection:indexPath.section];
//
//        //Don't try to dequeue the cell if the indexPath is out of boounds
//        if (numberOfSections >= indexPath.section+1 && numberOfRows >= indexPath.row +1) {
//
//            VideoTableViewCell *cell = (VideoTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
//            return cell;
//
//        }
//
//
//    }
    
    return nil;
    
}

- (Video *)videoForDownloadTaskID:(NSNumber *)downloadTaskID {
    NSArray *items = self.indexPathController.items;
    for (Video *video in items) {
        if ([video isKindOfClass:[Video class]]) {
            if ([video.downloadTaskId isEqualToNumber:downloadTaskID] == YES) {
                return video;
            }
        } else if ([video isKindOfClass:[Playlist class]]) {
            Playlist *playlist = (Playlist *)video;
            NSArray<PlaylistVideo *> *playlistVideos = [ACSPersistenceManager playlistVideosFromPlaylistId:playlist.pId];
            for (PlaylistVideo *currentPlaylistVideo in playlistVideos) {
                Video *currentVideo = currentPlaylistVideo.video;
                if ([currentVideo isKindOfClass:[Video class]]) {
                    if ([currentVideo.downloadTaskId isEqualToNumber:downloadTaskID] == YES) {
                        return video;
                    }
                }
            }
        }
    }
    
    return nil;
}


#pragma mark - Overrides


- (void)reloadData {
    [self.tableView reloadData];
}


#pragma mark - Lifecycle

- (instancetype)initWithTableView:(UITableView *)tableView {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _tableView = tableView;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [_tableView registerClass:[VideoTableViewCell class] forCellReuseIdentifier:reuseIdentifier];
    [_tableView registerNib:[UINib nibWithNibName:@"VideoTableViewCell" bundle:nil] forCellReuseIdentifier:reuseIdentifier];
    
    [_tableView registerClass:[PlaylistTableViewCell class] forCellReuseIdentifier:reusePlaylistIdentifier];
    [_tableView registerNib:[UINib nibWithNibName:reusePlaylistCollectionCellIdentifier bundle:nil] forCellReuseIdentifier:reusePlaylistCollectionCellIdentifier];
    [_tableView registerNib:[UINib nibWithNibName:@"PlaylistTableViewCell" bundle:nil] forCellReuseIdentifier:reusePlaylistIdentifier];
    
    self.scrollView = _tableView;
    
    return self;
}


#pragma mark - Option Button Action

- (void)buttonActionTapped:(id)sender{
    
    CGPoint touchPoint = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:touchPoint];
    [self.delegate episodeControllerDelegateButtonActionTappedAtIndexPath:indexPath];
}

#pragma mark - TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.indexPathController.dataModel.numberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSUInteger number = [self.indexPathController.dataModel numberOfRowsInSection:section];
    [self.delegate episodeControllerDelegateShowEmptyMessage:number];
    
    return number;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([[self.indexPathController.dataModel itemAtIndexPath:indexPath] isKindOfClass:[Video class]]){
        
        Video * video = (Video *)[self.indexPathController.dataModel itemAtIndexPath:indexPath];
        NSString * layout;
        Playlist * playlist = [video playlistFromVideo];
        if (playlist) {
            layout = playlist.thumbnail_layout;
        }
        
        VideoTableViewCell *cell = (VideoTableViewCell *)[tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
        [cell configureCell:[self.indexPathController.dataModel itemAtIndexPath:indexPath] viewController:self withLayout:layout];
        cell.backgroundColor = [UIColor clearColor];
        return cell;
        
    } else if ([[self.indexPathController.dataModel itemAtIndexPath:indexPath] isKindOfClass:[Playlist class]]){
        
        PlaylistCollectionCell *cell = (PlaylistCollectionCell *)[tableView dequeueReusableCellWithIdentifier:reusePlaylistCollectionCellIdentifier];
        Playlist *playlist = [self.indexPathController.dataModel itemAtIndexPath:indexPath];
        [cell setDelegate:self];
        [cell configureCell:playlist];
        return cell;

    } else {
        return [UITableViewCell new];//app will crash if it reaches this point
    }
    
}

//- (NSString *)layoutFromVideo:(Video *)video {
//    NSArray * playlists = [video.playlistVideo allObjects];
//    for (PlaylistVideo *pVideo in playlists) {
//        if (pVideo.playlist) {
//            return pVideo.playlist.thumbnail_layout;
//        }
//    }
//
//    return @"landscape";
//}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSObject *dataModel = [self.indexPathController.dataModel itemAtIndexPath:indexPath];
    
    if ([dataModel isKindOfClass:[Video class]]) {
        Video * video = (Video *)dataModel;
        Playlist * playlist = [video playlistFromVideo];
        if (playlist) {
            if ([playlist.thumbnail_layout isEqualToString:@"poster"]) {
                return [PlaylistCollectionCell cellPosterLayoutSize].height + 24;
            }
        }
        
        return 90.0f;
    }
    
    if ([dataModel isKindOfClass:[Playlist class]]) {
        Playlist * playlist = (Playlist *)dataModel;
        if ([playlist.thumbnail_layout isEqualToString:@"poster"]) {
            return [PlaylistCollectionCell rowPosterHeight];
        }
        
        return [PlaylistCollectionCell rowHeight];
    }
    
    return 90.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.delegate episodeControllerDidSelectItemAtIndexPath:indexPath];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];

}

- (UITableViewCellEditingStyle)tableView:(UITableView *)aTableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Detemine if it's in editing mode
    if (self.editingEnabled == YES) {
        return UITableViewCellEditingStyleDelete;
    }
    
    return UITableViewCellEditingStyleNone;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        Video *video = [self.indexPathController.dataModel itemAtIndexPath:indexPath];
        
        if (self.episodeControllerMode == ACSEpisodeControllerModeDownloads) {
            
            [ACDownloadManager deleteDownloadedVideo:video];
            
        } else if (self.episodeControllerMode == ACSEpisodeControllerModeFavorites){
            
            [[RESTServiceController sharedInstance] unfavoriteVideo:video];
            
            id tracker = [[GAI sharedInstance] defaultTracker];
            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:kAnalyticsScreenNameFavorites action:kAnalyticsCategoryButtonPressed label:kAnalyticsActUnFavorited value:nil] build]];
            
        }
        
    }
    
}

#pragma mark - PlaylistCollectionCell

- (void)onDidSelectItem:(PlaylistCollectionCell *)cell item:(NSObject *)item {
    [self.delegate episodeControllerDidSelectItem:item];
}


@end
