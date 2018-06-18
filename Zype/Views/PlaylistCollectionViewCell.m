//
//  ACSEpisodeCollectionViewCell.m
//
//  Created by ZypeTech on 6/20/15.
//  Copyright (c) 2015 Zype. All rights reserved.
//

#import <SDWebImage/UIImageView+WebCache.h>

#import "PlaylistCollectionViewCell.h"
#import "ACDownloadManager.h"
#import "DownloadOperationController.h"

@interface PlaylistCollectionViewCell ()

@property (nonatomic, strong) Video *video;
@property (nonatomic, assign) CGFloat defaultStatusImageWidth;

@end

@implementation PlaylistCollectionViewCell

- (void)setPlaylist:(Playlist *)playlist{
    [self.thumbnailImage sd_setImageWithURL:[NSURL URLWithString:playlist.thumbnailUrl] placeholderImage:[UIImage imageNamed:@"ImagePlaylistPlaceholder"]];
    
    self.titleLabel.text = playlist.title;

    if (self != nil) {
        [self setNeedsLayout];
        [self setNeedsDisplay];
    }
    
}


- (void)setVideo:(Video *)video{
    
  /*  _video = video;
    
    if (video == nil) {
        
        self.thumbnailImage.image = [UIImage imageNamed:@"ImagePlaceholder"];
        self.titleLabel.text = nil;
        self.subtitleLabel.text = nil;
        self.actionButton.enabled = NO;
        
        return;
        
    }
    
    self.actionButton.enabled = YES;
    
    [self.thumbnailImage sd_setImageWithURL:[NSURL URLWithString:video.thumbnailUrl] placeholderImage:[UIImage imageNamed:@"ImagePlaceholder"]];
    self.titleLabel.text = video.title;
    self.titleLabel.textColor = [UIColor whiteColor];
    self.subtitleLabel.text = [UIUtil subtitleOfVideo:video];
    
    if (video.downloadVideoLocalPath){
        
        [self.accessoryImage setImage:[UIImage imageNamed:@"IconVideoW"]];
        
    }else if (video.downloadAudioLocalPath){
        
        [self.accessoryImage setImage:[UIImage imageNamed:@"IconAudioW"]];
        
    }else{
        
        [self.accessoryImage setImage:[UIImage imageNamed:@"IconCloud"]];
        
    }
    
    // Set download progress
    DownloadInfo *downloadInfo = [[DownloadOperationController sharedInstance] downloadInfoWithTaskId:video.downloadTaskId];
    if (downloadInfo && downloadInfo.isDownloading) {
        
        if (self != nil) {
            
            if (downloadInfo.totalBytesWritten == 0.0) {
                
                [self setDownloadStarted];
                
            }else {
                
                float progress = (double)downloadInfo.totalBytesWritten / (double)downloadInfo.totalBytesExpectedToWrite;
                
                [self setDownloadProgress:progress];
                
            }
            
        }
        
    }else if ([ACDownloadManager fileDownloadedForVideo:video] == YES) {
        
        if (self != nil) {
            
            if (video.isPlayed.boolValue == YES){
                
                [self setPlayed];
                
            }else if (video.isPlaying.boolValue == YES){
                
                [self setPlaying];
                
            }else {
                
                [self setDownloadFinishedWithMediaType:downloadInfo.mediaType];
                
            }
            
        }
        
    }else {
        
        [self setNoDownload];
        
    }
    
    //hide cloud if video can't be downloaded
    if (video.duration.integerValue > 1 && video.isHighlight.boolValue == NO) {
        self.accessoryImage.hidden = NO;
    }else{
        self.accessoryImage.hidden = YES;
    }
    */
}


- (void)awakeFromNib {
    // Initialization code
    if (kAppColorLight){
        self.titleLabel.textColor = [UIColor blackColor];
    } else {
        self.titleLabel.textColor = [UIColor whiteColor];
    }
    
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected{
    
    [super setSelected:selected];
    
    // Configure the view for the selected state
    UIView * selectedBackgroundView = [[UIView alloc] init];
    [selectedBackgroundView setBackgroundColor:[UIColor darkGrayColor]];
    [self setSelectedBackgroundView:selectedBackgroundView];
    
}


@end
