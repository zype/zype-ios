//
//  MediaItemCollectionCell.m
//  Zype
//
//  Created by Александр on 27.11.2017.
//  Copyright © 2017 Zype. All rights reserved.
//

#import "MediaItemCollectionCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "DownloadOperationController.h"
#import "ACStatusManager.h"
#import "UIView+UIView_CustomizeTheme.h"

@interface MediaItemCollectionCell()

@property (strong, nonatomic) IBOutlet UIImageView *coverImageView;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UIView *containerView;
@property (strong, nonatomic) IBOutlet UIImageView *iconLockedView;
@property (strong, nonatomic) IBOutlet UIProgressView *progressView;


@end

@implementation MediaItemCollectionCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.titleLabel setHidden:!kAppAppleTVLayoutShowThumbanailTitle];
    // Initialization code
}

- (void)setPlaylist:(Playlist *)playlist {
    self.titleLabel.text = playlist.title;
    //[self.coverImageView sd_setImageWithURL:[NSURL URLWithString:playlist.thumbnailUrl]];
    [self.coverImageView sd_setImageWithURL:[NSURL URLWithString:playlist.thumbnailUrl] placeholderImage:self.coverImageView.image];
}

- (void)setVideo:(Video *)video {
    self.titleLabel.text = video.title;
    //[self.coverImageView sd_setImageWithURL:[NSURL URLWithString:video.thumbnailUrl]];
    [self.coverImageView sd_setImageWithURL:[NSURL URLWithString:video.thumbnailUrl] placeholderImage:self.coverImageView.image];
    
    if ([video.subscription_required intValue] == 1) {
        [self.iconLockedView setHidden:NO];
        if ([ACStatusManager isUserSignedIn] == YES) {
            self.iconLockedView.image = [UIImage imageNamed:@"icon-unlock"];
        } else {
            self.iconLockedView.image = [UIImage imageNamed:@"icon-lock"];
        }
    }
    
//    DownloadInfo *downloadInfo = [[DownloadOperationController sharedInstance] downloadInfoWithTaskId:video.downloadTaskId];
//    if (downloadInfo && downloadInfo.isDownloading) {
//
//        if (self != nil) {
//
//            if (downloadInfo.totalBytesWritten == 0.0) {
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [self setDownloadStarted];
//                });
//
//            } else {
//
//                float progress = (double)downloadInfo.totalBytesWritten / (double)downloadInfo.totalBytesExpectedToWrite;
//
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [self setDownloadProgress:progress];
//                });
//
//            }
//
//        }
//
//    } else if ([UIUtil isYes:video.isDownload]) {
//
//        dispatch_async(dispatch_get_main_queue(), ^{
//
//            if (self != nil) {
//                if ([UIUtil isYes:video.isPlayed]) {
//                    [self setPlayed];
//                } else if ([UIUtil isYes:video.isPlaying]) {
//                    [self setPlaying];
//                } else {
//                    [self setDownloadFinishedWithMediaType:downloadInfo.mediaType];
//                }
//            }
//        });
//
//    } else {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self setNoDownload];
//        });
//    }
}

- (void)setNoDownload {
    [self.progressView setHidden:YES];
    [self setNeedsDisplay];
}

- (void)setDownloadStarted {
    [self.progressView setHidden:YES];
    [self setNeedsDisplay];
}

- (void)setDownloadProgress:(float)progress {
    if (self.progressView.isHidden) {
        [self.progressView setHidden:NO];
    }
    self.progressView.progress = progress;
    [self setNeedsDisplay];
}

- (void)setDownloadSavingFile {
    [self.progressView setHidden:YES];
    [self setNeedsDisplay];
}

- (void)setDownloadFinishedWithMediaType:(NSString *)mediaType {
    [self.progressView setHidden:YES];
    [self setNeedsDisplay];
}

- (void)setPlaying {
    [self.progressView setHidden:YES];
    [self setNeedsDisplay];
}

- (void)setPlayed {
    [self.progressView setHidden:YES];
    [self setNeedsDisplay];
}

@end
