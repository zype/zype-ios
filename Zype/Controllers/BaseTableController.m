//
//  BaseTableController.m
//  acumiashow
//
//  Created by ZypeTech on 6/28/15.
//  Copyright (c) 2015 Zype. All rights reserved.
//

//#import <SDWebImage/UIImageView+WebCache.h>

#import "BaseTableController.h"
#import "VideoTableViewCell.h"
#import "PlaylistTableViewCell.h"
#import "ACDownloadManager.h"
#import "DownloadOperationController.h"
#import "Playlist.h"
#import "PlaylistCollectionCell.h"

@implementation BaseTableController


- (id<DownloadStatusCell>)cellForDownloadTaskID:(NSNumber *)downloadTaskID{
    
    Video *video = [self videoForDownloadTaskID:downloadTaskID];
    
    if (video != nil && self != nil && self.indexPathController.dataModel != nil && self.tableView != nil) {
        NSIndexPath *indexPath = [self.indexPathController.dataModel indexPathForItem:video];
        
        NSInteger numberOfSections = [self.tableView numberOfSections];
        NSInteger numberOfRows = [self.tableView numberOfRowsInSection:indexPath.section];
        
        //Don't try to dequeue the cell if the indexPath is out of boounds
        if (numberOfSections >= indexPath.section+1 && numberOfRows >= indexPath.row +1) {

            VideoTableViewCell *cell = (VideoTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
            return cell;
        }
        
    }
    
    return nil;
}


#pragma mark - Overrides


- (void)reloadData {
    [self.tableView reloadData];
}


#pragma mark - Lifecycle

- (instancetype)initWithTableView:(UITableView *)tableView{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _tableView = tableView;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.indexPathController.dataModel.numberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    NSUInteger number = [self.indexPathController.dataModel numberOfRowsInSection:section];
    [self.delegate episodeControllerDelegateShowEmptyMessage:number];
    
    return number;
    
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    if ([[self.indexPathController.dataModel itemAtIndexPath:indexPath] isKindOfClass:[Video class]]){
        
        VideoTableViewCell *cell = (VideoTableViewCell *)[tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
        [cell configureCell:[self.indexPathController.dataModel itemAtIndexPath:indexPath] viewController:self];
        return cell;
        
    } else if ([[self.indexPathController.dataModel itemAtIndexPath:indexPath] isKindOfClass:[Playlist class]]){
        
        PlaylistTableViewCell *cell = (PlaylistTableViewCell *)[tableView dequeueReusableCellWithIdentifier:reusePlaylistIdentifier];
        [cell configureCell:[self.indexPathController.dataModel itemAtIndexPath:indexPath]];
        return cell;

    } else {
        return [UITableViewCell new];//app will crash if it reaches this point
    }
    
    
    
   /*  Video *video = [self.indexPathController.dataModel itemAtIndexPath:indexPath];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
       [cell.imageThumbnail sd_setImageWithURL:[NSURL URLWithString:video.thumbnailUrl] placeholderImage:[UIImage imageNamed:@"ImagePlaceholder"]];
        
        cell.textTitle.text = video.title;
        
        if (video.downloadVideoLocalPath){
            [cell.imageCloud setImage:[UIImage imageNamed:@"IconVideoW"]];
        }else if (video.downloadAudioLocalPath){
            [cell.imageCloud setImage:[UIImage imageNamed:@"IconAudioW"]];
        }else{
            [cell.imageCloud setImage:[UIImage imageNamed:@"IconCloud"]];
        }
        
        cell.labelSubtitle.text = [UIUtil subtitleOfVideo:video];
        cell.textLabel.textColor = [UIColor clearColor];
        
    });
    
    // Set download progress
    DownloadInfo *downloadInfo = [[DownloadOperationController sharedInstance] downloadInfoWithTaskId:video.downloadTaskId];
    if (downloadInfo && downloadInfo.isDownloading) {
        
        if (cell != nil) {
            
            if (downloadInfo.totalBytesWritten == 0.0) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [cell setDownloadStarted];
                });
                
            }else {
                
                float progress = (double)downloadInfo.totalBytesWritten / (double)downloadInfo.totalBytesExpectedToWrite;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [cell setDownloadProgress:progress];
                });
                
            }
            
        }
        
    }else if ([UIUtil isYes:video.isDownload]) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (cell != nil) {
                
                if ([UIUtil isYes:video.isPlayed]){
                    
                    [cell setPlayed];
                    
                }else if ([UIUtil isYes:video.isPlaying]){
                    
                    [cell setPlaying];
                    
                }else {
                    
                    [cell setDownloadFinishedWithMediaType:downloadInfo.mediaType];
                    
                }
                
            }
            
        });
        
    }else {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [cell setNoDownload];
        });
        
    }
    
    [cell.buttonAction addTarget:self action:@selector(buttonActionTapped:) forControlEvents:UIControlEventTouchUpInside];
    [cell.contentView setUserInteractionEnabled:YES];
    
    //hide cloud if video can't be downloaded
    if (video.duration.integerValue > 1) {
        cell.imageCloud.hidden = NO;
    }else{
        cell.imageCloud.hidden = YES;
    }
    */
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[self.indexPathController.dataModel itemAtIndexPath:indexPath] isKindOfClass:[Video class]]){
        return 90.0f;
        
    } else if ([[self.indexPathController.dataModel itemAtIndexPath:indexPath] isKindOfClass:[Playlist class]]){
        return 140.0f;
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
    if (self.editingEnabled == YES)
    {
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
            
        }else if (self.episodeControllerMode == ACSEpisodeControllerModeFavorites){
            
            [[RESTServiceController sharedInstance] unfavoriteVideo:video];
            
            id tracker = [[GAI sharedInstance] defaultTracker];
            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:kAnalyticsScreenNameFavorites action:kAnalyticsCategoryButtonPressed label:kAnalyticsActUnFavorited value:nil] build]];
            
        }
                
    }
    
}

#pragma mark - PlaylistCollectionCell

//- (void)onDidSelectItem:(PlaylistCollectionCell *)cell indexPath:(NSIndexPath *)indexPath {
//    NSLog(@"%@", indexPath);
//    NSIndexPath *index = [NSIndexPath indexPathForRow:indexPath.section inSection:indexPath.row];
//    [self.delegate episodeControllerDidSelectItemAtIndexPath:index];
//}

- (void)onDidSelectItem:(PlaylistCollectionCell *)cell item:(NSObject *)item {
    [self.delegate episodeControllerDidSelectItem:item];
}


@end
