//
//  ACSEpisodeCollectionViewCell.m
//  acumiashow
//
//  Created by ZypeTech on 6/20/15.
//  Copyright (c) 2015 Zype. All rights reserved.
//

#import <SDWebImage/UIImageView+WebCache.h>

#import "ACSEpisodeCollectionViewCell.h"
#import "ACDownloadManager.h"
#import "DownloadOperationController.h"
#import "ACStatusManager.h"

@interface ACSEpisodeCollectionViewCell ()

@property (nonatomic, strong) Video *video;
@property (nonatomic, assign) CGFloat defaultStatusImageWidth;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView  *activityIndicator;

@end

@implementation ACSEpisodeCollectionViewCell


- (void)setVideo:(Video *)video{
    
   _video = video;
    
    if (video == nil) {
        
        self.thumbnailImage.image = [UIImage imageNamed:@"ImagePlaceholder"];
        self.titleLabel.text = nil;
        self.subtitleLabel.text = nil;
        self.actionButton.enabled = NO;
        
        return;
        
    }
    
    self.actionButton.enabled = YES;
    
    [self setThumbnail:video];
    //[self.thumbnailImage sd_setImageWithURL:[NSURL URLWithString:video.thumbnailUrl] placeholderImage:[UIImage imageNamed:@"ImagePlaceholder"]];
    self.titleLabel.text = video.title;
    self.subtitleLabel.text = [UIUtil subtitleOfVideo:video];
    
    if ([video.subscription_required intValue] == 1){
        if ([ACStatusManager isUserSignedIn] == YES){
            self.iconLock.image = [UIImage imageNamed:@"iconUnlocked"];
        } else {
            self.iconLock.image = [UIImage imageNamed:@"iconLocked"];
        }
    } else {
        [self.iconLock setHidden:YES];
    }
    
    /*if (video.downloadVideoLocalPath){
        
        [self.accessoryImage setImage:[UIImage imageNamed:@"IconVideoW"]];
        
    }else if (video.downloadAudioLocalPath){
        
        [self.accessoryImage setImage:[UIImage imageNamed:@"IconAudioW"]];
        
    }else{
        
        [self.accessoryImage setImage:[UIImage imageNamed:@"IconCloud"]];
        
    }*/
    self.accessoryImage.hidden = YES;
    
    // Set download progress
    DownloadInfo *downloadInfo = [[DownloadOperationController sharedInstance] downloadInfoWithTaskId:video.downloadTaskId];
    if (downloadInfo && downloadInfo.isDownloading) {
        if (self != nil) {
            if (downloadInfo.totalBytesWritten == 0.0) {
                [self setDownloadStarted];
            } else {
                float progress = (double)downloadInfo.totalBytesWritten / (double)downloadInfo.totalBytesExpectedToWrite;
                [self setDownloadProgress:progress];
            }
        }
    } else if ([ACDownloadManager fileDownloadedForVideo:video] == YES) {
        if (self != nil) {
            if (video.isPlayed.boolValue == YES) {
                [self setPlayed];
            } else if (video.isPlaying.boolValue == YES) {
                [self setPlaying];
            } else {
                [self setDownloadFinishedWithMediaType:downloadInfo.mediaType];
            }
        }
    } else {
        [self setNoDownload];
    }
    
    //hide cloud if video can't be downloaded
    if (video.duration.integerValue > 1 && video.isHighlight.boolValue == NO) {
        self.accessoryImage.hidden = NO;
    }else {
        self.accessoryImage.hidden = YES;
    }
    
    //[self setTest];
}

- (void)setThumbnail:(Video *)video {
    
    //add activity indicator
    self.activityIndicator.color = kClientColor;
    [self.activityIndicator setHidesWhenStopped:YES];
    [self.activityIndicator setHidden:NO];
    [self.activityIndicator startAnimating];
    
    [self.thumbnailImage sd_setImageWithURL:[NSURL URLWithString:video.thumbnailUrl]
                                  completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                      [self.activityIndicator stopAnimating];
                                      [self.activityIndicator setHidden:YES];
                                      //check for error and add default placeholder
                                      if (error) {
                                          [self.thumbnailImage setImage:[UIImage imageNamed:@"ImagePlaceholder"]];
                                          CLS_LOG(@"Video thumbnail couldn't be loaded: %@", error);
                                      }
                                  }];
    
    // [self.thumbnailImage sd_setImageWithURL:[NSURL URLWithString:video.thumbnailUrl] placeholderImage:[UIImage imageNamed:@"ImagePlaceholder"]];
}


- (void)awakeFromNib {
    // Initialization code
    self.defaultStatusImageWidth = self.statusImage.frame.size.width;
    self.actionCoverView.layer.cornerRadius = 4;
    [self hideStatusImage:YES];
    [super awakeFromNib];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    //self.activityIndicator.center = self.thumbnailImage.center;
}

- (void)setSelected:(BOOL)selected{
    
    [super setSelected:selected];
    
    // Configure the view for the selected state
    UIView * selectedBackgroundView = [[UIView alloc] init];
    [selectedBackgroundView setBackgroundColor:[UIColor darkGrayColor]];
    [self setSelectedBackgroundView:selectedBackgroundView];
    
}

#pragma mark - Downloading

- (void)setNoDownload {
    [self.progressView setHidden:YES];
    [self.actionCoverView setHidden:YES];
    [self.subtitleLabel setHidden:NO];
    [self hideStatusImage:YES];
    [self setNeedsDisplay];
    
}

- (void)setDownloadStarted {
    [self.progressView setHidden:YES];
    [self.actionCoverView setHidden:NO];
    [self.subtitleLabel setHidden:YES];
    [self hideStatusImage:YES];
    self.actionLabel.text = @"Download pending...";
    [self setNeedsDisplay];
    
}

- (void)setTest {
    [self.progressView setHidden:NO];
    [self.actionCoverView setHidden:NO];
    [self.subtitleLabel setHidden:NO];
    [self hideStatusImage:NO];
    self.actionLabel.text = @"Download pending...";
    self.titleLabel.text = @"errtgg dfg dfg rtert retret rter rterter retert";
    self.subtitleLabel.text = @"Cerb drk.xf.n [jde d gbntht";
    [self setNeedsDisplay];
    
}

- (void)setDownloadProgress:(float)progress{
    
    //double checking that this is the right cell
    //fixes an issue where collection cells show progress for the wrong video
    DownloadInfo *downloadInfo = [[DownloadOperationController sharedInstance] downloadInfoWithTaskId:self.video.downloadTaskId];
    if (downloadInfo == nil || downloadInfo.isDownloading == NO) {
        [self setNoDownload];
        return;
    }

    if (self.progressView.isHidden) {
        [self.progressView setHidden:NO];
        [self.actionCoverView setHidden:YES];
        [self.subtitleLabel setHidden:YES];
        [self hideStatusImage:YES];
    }

    self.progressView.progress = progress;
    [self setNeedsDisplay];
    
}

- (void)setDownloadSavingFile{
    
    [self.progressView setHidden:YES];
    [self.actionCoverView setHidden:NO];
    [self.subtitleLabel setHidden:YES];
    [self hideStatusImage:YES];
    
    self.actionLabel.text = @"Saving File...";
    [self setNeedsDisplay];
    
}

- (void)setDownloadFinishedWithMediaType:(NSString *)mediaType{
    
    [self.progressView setHidden:YES];
    [self.actionCoverView setHidden:YES];
    [self.subtitleLabel setHidden:NO];
    
    [self hideStatusImage:NO];
    [self.statusImage setImage:[UIImage imageNamed:@"IconPlayFull"]];
    
    if ([mediaType isEqualToString:kMediaType_Audio]){
        [self.accessoryImage setImage:[UIImage imageNamed:@"IconAudioW"]];
    }else if ([mediaType isEqualToString:kMediaType_Video]){
        [self.accessoryImage setImage:[UIImage imageNamed:@"IconVideoW"]];
    }
    
    [self setNeedsDisplay];
    
}

#pragma mark - Playing

- (void)setPlaying{
    
    [self.progressView setHidden:YES];
    [self.actionCoverView setHidden:YES];
    [self.subtitleLabel setHidden:NO];
    
    [self hideStatusImage:NO];
    [self.statusImage setImage:[UIImage imageNamed:@"IconPlayHalf"]];
    [self setNeedsDisplay];
    
}

- (void)setPlayed{
    
    [self.progressView setHidden:YES];
    [self.actionCoverView setHidden:YES];
    [self.subtitleLabel setHidden:NO];
    [self hideStatusImage:YES];
    [self setNeedsDisplay];
    
}


#pragma mark - Layout

- (void)hideStatusImage:(BOOL)hide{
    
    self.statusImage.hidden = hide;
    if (hide == YES) {
        self.statusImageWidthConstraint.constant = 0;
    } else {
        self.statusImageWidthConstraint.constant = self.defaultStatusImageWidth;
    }
    
    if (self != nil) {
        [self setNeedsLayout];
        [self setNeedsDisplay];
    }
    
}

@end
