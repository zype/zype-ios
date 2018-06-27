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
#import "ACPurchaseManager.h"
#import "UIView+UIView_CustomizeTheme.h"

@interface MediaItemCollectionCell()

@property (strong, nonatomic) IBOutlet UIImageView *coverImageView;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UIView *containerView;
@property (strong, nonatomic) IBOutlet UIImageView *iconLockedView;
@property (strong, nonatomic) IBOutlet UIProgressView *progressView;
@property (strong, nonatomic) IBOutlet UIImageView *placeholderView;
@property (weak, nonatomic) IBOutlet UIView *overlayView;



@end

@implementation MediaItemCollectionCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.titleLabel setHidden:!kAppAppleTVLayoutShowThumbanailTitle];
    [self.overlayView setHidden:!kAppAppleTVLayoutShowThumbanailTitle];
    // Initialization code
}

- (void)setPlaylist:(Playlist *)playlist {
    self.titleLabel.text = playlist.title;
    [self.placeholderView setHidden:kAppAppleTVLayoutShowThumbanailTitle];
    [self.placeholderView setImage:[UIImage imageNamed:@"playlist-placeholder"]];
    [self.coverImageView sd_setImageWithURL:[NSURL URLWithString:playlist.thumbnailUrl] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        if (image) {
            [self.placeholderView setHidden:YES];
            [self.coverImageView setImage:image];
            [self.coverImageView sd_setImageWithURL:[NSURL URLWithString:playlist.thumbnailBigUrl] placeholderImage:image];
        } else {
            [self.placeholderView setHidden:NO];
            [self.coverImageView sd_setImageWithURL:[NSURL URLWithString:playlist.thumbnailBigUrl] placeholderImage:[UIImage imageNamed:@"playlist-placeholder"] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                if (image) {
                    [self.placeholderView setHidden:YES];
                } else {
                    [self.placeholderView setHidden:NO];
                }
            }];
        }
    }];
    [self.iconLockedView setHidden:YES];
}

- (void)setVideo:(Video *)video {
    self.titleLabel.text = video.title;
    [self.placeholderView setImage:[UIImage imageNamed:@"play-placeholder"]];
    [self.placeholderView setHidden:kAppAppleTVLayoutShowThumbanailTitle];
    [self.coverImageView sd_setImageWithURL:[NSURL URLWithString:video.thumbnailUrl] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        if (image) {
            [self.placeholderView setHidden:YES];
            [self.coverImageView setImage:image];
            [self.coverImageView sd_setImageWithURL:[NSURL URLWithString:video.thumbnailBigUrl] placeholderImage:image];
        } else {
            [self.placeholderView setHidden:NO];
            [self.coverImageView sd_setImageWithURL:[NSURL URLWithString:video.thumbnailBigUrl] placeholderImage:image completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                if (image) {
                    [self.placeholderView setHidden:YES];
                } else {
                    [self.placeholderView setHidden:NO];
                }
            }];
        }
    }];
    
    if ([video.subscription_required intValue] == 1) {
        [self.iconLockedView setHidden:NO];
        NSLog(@"%@", [[NSUserDefaults standardUserDefaults] valueForKey:kOAuthProperty_Subscription]);
        if ([ACStatusManager isUserSignedIn] == YES && ![[[NSUserDefaults standardUserDefaults] valueForKey:kOAuthProperty_Subscription] isEqualToNumber:[NSNumber numberWithInt:0]]) {
            self.iconLockedView.image = [[UIImage imageNamed:@"icon-unlock"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            if (kUnlockTransparentEnabled == YES) {
                [self.iconLockedView setTintColor:UIColor.clearColor];
            } else {
                [self.iconLockedView setTintColor:kUnlockColor];
            }
        } else {
            self.iconLockedView.image = [[UIImage imageNamed:@"icon-lock"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            [self.iconLockedView setTintColor:kLockColor];
        }
    } else {
        [self.iconLockedView setHidden:YES];
    }
}

- (void)setZObject:(ZObject *)zObject {
    [self.placeholderView setHidden:NO];
    [self.coverImageView sd_setImageWithURL:[NSURL URLWithString:zObject.thumbnailUrl] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        if (image) {
            [self.placeholderView setHidden:YES];
        }
    }];
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
