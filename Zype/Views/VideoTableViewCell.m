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
    dispatch_async(dispatch_get_main_queue(), ^{
        
        //[self.imageThumbnail sd_setImageWithURL:[NSURL URLWithString:video.thumbnailUrl] placeholderImage:[UIImage imageNamed:@"ImagePlaceholder"]];
        
        [self setThumbnail:video];
        
        self.textTitle.text = video.title;
        
        if (video.downloadVideoLocalPath){
            [self.imageCloud setImage:[UIImage imageNamed:@"IconVideoW"]];
        }else if (video.downloadAudioLocalPath){
            [self.imageCloud setImage:[UIImage imageNamed:@"IconAudioW"]];
        }else{
            [self.imageCloud setImage:[UIImage imageNamed:@"IconCloud"]];
        }
        
        if (![[NSUserDefaults standardUserDefaults] boolForKey:kSettingKey_DownloadsFeature])
            self.imageCloud.hidden = YES;
        
        //change color for action button icon
        UIImage *origImage = [UIImage imageNamed:@"IconAction"];
        UIImage *tintedImage = [origImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [self.buttonAction setImage:tintedImage forState:UIControlStateNormal];
        [self.buttonAction setTintColor:[UIColor lightGrayColor]];
        
        self.labelSubtitle.text = [UIUtil subtitleOfVideo:video];
        self.textLabel.textColor = [UIColor clearColor];
        
        //configure lock icon for videos that requires subscription
        if ([video.subscription_required intValue] == 1){
            if ([ACStatusManager isUserSignedIn] == YES){
                self.iconLock.image = [UIImage imageNamed:@"iconUnlocked"];
            } else {
                self.iconLock.image = [UIImage imageNamed:@"iconLocked"];
            }
        } else {
            [self.iconLock setHidden:YES];
        }
    });
    
    // Set download progress
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
        
    }else if ([UIUtil isYes:video.isDownload]) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (self != nil) {
                
                if ([UIUtil isYes:video.isPlayed]){
                    
                    [self setPlayed];
                    
                }else if ([UIUtil isYes:video.isPlaying]){
                    
                    [self setPlaying];
                    
                }else {
                    
                    [self setDownloadFinishedWithMediaType:downloadInfo.mediaType];
                    
                }
                
            }
            
        });
        
    }else {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setNoDownload];
        });
        
    }
    
    //need to check if this action is working
    //possibly implement protocol
    [self.buttonAction addTarget:vc action:@selector(buttonActionTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView setUserInteractionEnabled:YES];
    
    //hide cloud if video can't be downloaded
    if (video.duration.integerValue > 1) {
        self.imageCloud.hidden = NO;
    }else{
        self.imageCloud.hidden = YES;
    }

}

- (void)setThumbnail:(Video *)video {
    
    //add activity indicator
    __block UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    // activityIndicator.center = self.imageThumbnail.center;
    activityIndicator.center = CGPointMake(self.imageThumbnail.center.x - 20.0, self.center.y - 10.0);
    activityIndicator.color = kBlueColor;
    activityIndicator.hidesWhenStopped = YES;
    [self.imageThumbnail addSubview:activityIndicator];
    [activityIndicator startAnimating];
    
    [self.imageThumbnail sd_setImageWithURL:[NSURL URLWithString:video.thumbnailUrl]
                                  completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                      [activityIndicator removeFromSuperview];
                                      //check for error and add default placeholder
                                      if (error) {
                                          [self.imageThumbnail setImage:[UIImage imageNamed:@"ImagePlaceholder"]];
                                          CLS_LOG(@"Video thumbnail couldn't be loaded: %@", error);
                                      }
                                  }];
}


@end
