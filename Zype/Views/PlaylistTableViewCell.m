//
//  PlaylistTableViewCell.m
//  Zype
//
//  Created by ZypeTech on 1/29/15.
//  Copyright (c) 2015 Zype. All rights reserved.
//

#import "PlaylistTableViewCell.h"
#import "Playlist.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "DownloadOperationController.h"

@implementation PlaylistTableViewCell

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

- (void)configureCell:(Playlist*)playlist{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (kAppColorLight) {
            self.contentView.backgroundColor = [UIColor whiteColor];
        } else {
            self.contentView.backgroundColor = [UIColor blackColor];
        }
        
        //add activity indicator
        __block UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        activityIndicator.center = self.imageThumbnail.center;
        activityIndicator.color = kClientColor;
        activityIndicator.hidesWhenStopped = YES;
        [self.imageThumbnail addSubview:activityIndicator];
        [activityIndicator startAnimating];
        
        [self.imageThumbnail sd_setImageWithURL:[NSURL URLWithString:playlist.thumbnailUrl]
                                      completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                          [activityIndicator removeFromSuperview];
                                          //check for error and add default placeholder
                                          if (error) {
                                              [self.imageThumbnail setImage:[UIImage imageNamed:@"ImagePlaylistPlaceholder"]];
                                              CLS_LOG(@"Placeholder thumbnail couldn't be loaded: %@", error);
                                          }
                                      }];
        
        // [self.imageThumbnail sd_setImageWithURL:[NSURL URLWithString:playlist.thumbnailUrl] placeholderImage:[UIImage imageNamed:@"ImagePlaylistPlaceholder"]];
        
        if (kHidePlaylistTitles){
            self.textTitle.text = @"";
        } else {
            self.textTitle.text = playlist.title;
        }
    });
}

@end
