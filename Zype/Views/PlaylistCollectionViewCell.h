//
//  PlaylistCollectionViewCell.h
//
//  Created by ZypeTech on 6/20/15.
//  Copyright (c) 2015 Zype. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DownloadStatusCell.h"
#import "Playlist.h"

@interface PlaylistCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *thumbnailImage;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *buttonAction;
@property (weak, nonatomic) IBOutlet UIButton *actionButton;

- (void)setPlaylist:(Playlist *)playlist;

@end
