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
    [self.coverImageView sd_setImageWithURL:[NSURL URLWithString:playlist.thumbnailUrl] placeholderImage:nil];
}

- (void)setVideo:(Video *)video {
    self.titleLabel.text = video.title;
    [self.coverImageView sd_setImageWithURL:[NSURL URLWithString:video.thumbnailUrl]];
    
    if ([video.subscription_required intValue] == 1) {
        [self.iconLockedView setHidden:NO];
        if ([ACStatusManager isUserSignedIn] == YES) {
            self.iconLockedView.image = [UIImage imageNamed:@"icon-unlock"];
        } else {
            self.iconLockedView.image = [UIImage imageNamed:@"icon-lock"];
        }
    }
}

- (void)setZObject:(ZObject *)zObject {
    [self.coverImageView sd_setImageWithURL:[NSURL URLWithString:zObject.thumbnailUrl]];

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
