//
//  VideoTableViewCell.m
//  Zype
//
//  Created by ZypeTech on 1/29/15.
//  Copyright (c) 2015 Zype. All rights reserved.
//

#import "VideoTableViewCell.h"
#import "Video.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "DownloadOperationController.h"
#import "ACStatusManager.h"

@implementation VideoTableViewCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
    UIView * selectedBackgroundView = [[UIView alloc] init];
    [selectedBackgroundView setBackgroundColor:[UIColor darkGrayColor]];
    [self setSelectedBackgroundView:selectedBackgroundView];
}

- (void)setNoDownload
{
    [self.progressView setHidden:YES];
    [self.labelProgress setHidden:YES];
    [self.labelSubtitle setHidden:NO];
    [self.imagePlay setHidden:YES];
    [self setNeedsDisplay];
}

- (void)setDownloadStarted
{
    [self.progressView setHidden:YES];
    [self.labelProgress setHidden:NO];
    [self.labelSubtitle setHidden:YES];
    [self.imagePlay setHidden:YES];
    self.labelProgress.text = @"Download pending...";
    [self setNeedsDisplay];
}

- (void)setDownloadProgress:(float)progress
{
    
    if (self.progressView.isHidden) {
        [self.progressView setHidden:NO];
        [self.labelProgress setHidden:YES];
        [self.labelSubtitle setHidden:YES];
        [self.imagePlay setHidden:YES];
    }
    self.progressView.progress = progress;
    [self setNeedsDisplay];
    
}

- (void)setDownloadSavingFile{
    
    [self.progressView setHidden:YES];
    [self.labelProgress setHidden:NO];
    [self.labelSubtitle setHidden:YES];
    [self.imagePlay setHidden:YES];
    self.labelProgress.text = @"Saving File...";
    [self setNeedsDisplay];
    
}

- (void)setDownloadFinishedWithMediaType:(NSString *)mediaType
{
    [self.progressView setHidden:YES];
    [self.labelProgress setHidden:YES];
    [self.labelSubtitle setHidden:NO];
    [self.imagePlay setHidden:NO];
    [self.imagePlay setImage:[UIImage imageNamed:@"IconPlayFull"]];
    
    if ([mediaType isEqualToString:kMediaType_Audio])
        [self.imageCloud setImage:[UIImage imageNamed:@"IconAudioW"]];
    else if ([mediaType isEqualToString:kMediaType_Video])
        [self.imageCloud setImage:[UIImage imageNamed:@"IconVideoW"]];
    
    [self setNeedsDisplay];
}

- (void)setPlaying
{
    [self.progressView setHidden:YES];
    [self.labelProgress setHidden:YES];
    [self.labelSubtitle setHidden:NO];
    [self.imagePlay setHidden:NO];
    [self.imagePlay setImage:[UIImage imageNamed:@"IconPlayHalf"]];
    [self setNeedsDisplay];
}

- (void)setPlayed
{
    [self.progressView setHidden:YES];
    [self.labelProgress setHidden:YES];
    [self.labelSubtitle setHidden:NO];
    [self.imagePlay setHidden:YES];
    [self setNeedsDisplay];
}

- (void)configureCell:(Video*)video viewController:(NSObject*)vc {
    
    UIImage *origImage = [UIImage imageNamed:@"IconAction"];
    UIImage *tintedImage = [origImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIImage * cloudImage;
    if (video.downloadVideoLocalPath) {
        cloudImage = [UIImage imageNamed:@"IconVideoW"];
    } else if (video.downloadAudioLocalPath) {
        cloudImage = [UIImage imageNamed:@"IconAudioW"];
    } else {
        cloudImage = [UIImage imageNamed:@"IconCloud"];
    }
    
    UIImage * lockImage;
    if ([ACStatusManager isUserSignedIn] == YES) {
        lockImage = [UIImage imageNamed:@"iconUnlocked"];
    } else {
        lockImage = [UIImage imageNamed:@"iconLocked"];
    }
    
    BOOL downloadFeature = kDownloadsEnabled;
    
    [self.imageThumbnail sd_setImageWithURL:[NSURL URLWithString:video.thumbnailUrl] placeholderImage:[UIImage imageNamed:@"ImagePlaceholder"]];
    [self setThumbnail:video];

    BOOL iconLockHidden = !([video.subscription_required intValue] == 1);
    NSString *subtitleVideo = [UIUtil subtitleOfVideo:video];
    
    if (kAppColorLight) {
        
    } else {
        self.contentView.backgroundColor = [UIColor blackColor];
        [self.textTitle setTextColor:[UIColor whiteColor]];
        [self.labelSubtitle setTextColor:[UIColor lightGrayColor]];
    }
    
    if (kAppAppleTVLayout) {
        self.contentView.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
//    dispatch_async(dispatch_get_main_queue(), ^{

        self.textTitle.text = video.title;
        [self.imageCloud setImage:cloudImage];
        self.imageCloud.hidden = !downloadFeature;

        //change color for action button icon
        [self.buttonAction setImage:tintedImage forState:UIControlStateNormal];
        [self.buttonAction setTintColor:[UIColor lightGrayColor]];

        self.labelSubtitle.text = subtitleVideo;
        self.textLabel.textColor = [UIColor clearColor];

        //configure lock icon for videos that requires subscription
        self.iconLock.image = lockImage;
        [self.iconLock setHidden:iconLockHidden];

//    });

    // Set download progress
    if (kDownloadsEnabled){
        DownloadInfo *downloadInfo = [[DownloadOperationController sharedInstance] downloadInfoWithTaskId:video.downloadTaskId];
        if (downloadInfo && downloadInfo.isDownloading) {
            
            if (self != nil) {
                
                if (downloadInfo.totalBytesWritten == 0.0) {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self setDownloadStarted];
                    });
                    
                }else {
                    
                    float progress = (double)downloadInfo.totalBytesWritten / (double)downloadInfo.totalBytesExpectedToWrite;
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self setDownloadProgress:progress];
                    });
                    
                }
                
            }
            
        } else if ([UIUtil isYes:video.isDownload]) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if (self != nil) {
                    
                    if ([UIUtil isYes:video.isPlayed]) {
                        [self setPlayed];
                    } else if ([UIUtil isYes:video.isPlaying]) {
                        [self setPlaying];
                    } else {
                        [self setDownloadFinishedWithMediaType:downloadInfo.mediaType];
                    }
                }
            });
            
        } else {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self setNoDownload];
            });
            
        }
    }
    //need to check if this action is working
    //possibly implement protocol
    [self.buttonAction addTarget:vc action:@selector(buttonActionTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView setUserInteractionEnabled:YES];

    //hide cloud if video can't be downloaded
   /* if (video.duration.integerValue > 1) {
        self.imageCloud.hidden = NO;
    } else {
        self.imageCloud.hidden = YES;
    }*/
    

}

- (void)configureCell:(Video *)video viewController:(NSObject *)vc withLayout:(NSString *)layout {
    if ([layout isEqualToString:@"poster"]) {
        self.widthLayoutConstraint.constant = [PlaylistCollectionCell cellPosterLayoutSize].width;
    } else {
        self.widthLayoutConstraint.constant = [PlaylistCollectionCell cellLanscapeLayoutSize].width;
    }
    [self configureCell:video viewController:vc];
    [self layoutIfNeeded];
}

- (void)setThumbnail:(Video *)video {
    
    //add activity indicator
    self.activityIndicator.color = kClientColor;
    [self.activityIndicator setHidesWhenStopped:YES];
    [self.activityIndicator setHidden:NO];
    [self.activityIndicator startAnimating];
    
    [self.imageThumbnail sd_setImageWithURL:[NSURL URLWithString:video.thumbnailUrl]
                                  completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                      [self.activityIndicator stopAnimating];
                                      [self.activityIndicator setHidden:YES];
                                      //check for error and add default placeholder
                                      if (error) {
                                          [self.imageThumbnail setImage:[UIImage imageNamed:@"ImagePlaceholder"]];
                                          CLS_LOG(@"Video thumbnail couldn't be loaded: %@", error);
                                      }
                                  }];
}


@end
