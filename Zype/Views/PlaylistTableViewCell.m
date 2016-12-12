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
        
        [self.imageThumbnail sd_setImageWithURL:[NSURL URLWithString:playlist.thumbnailUrl] placeholderImage:[UIImage imageNamed:@"ImagePlaylistPlaceholder"]];
        
        self.textTitle.text = playlist.title;
    });
}

@end
