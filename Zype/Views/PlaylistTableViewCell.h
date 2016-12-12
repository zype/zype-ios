//
//  PlaylistTableViewCell.h
//  Zype
//
//  Created by ZypeTech on 1/29/15.
//  Copyright (c) 2015 Zype. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Playlist;

@interface PlaylistTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *textTitle;
@property (weak, nonatomic) IBOutlet UILabel *labelSubtitle;
@property (weak, nonatomic) IBOutlet UIImageView *imageThumbnail;
@property (weak, nonatomic) IBOutlet UIButton *buttonAction;
@property (weak, nonatomic) IBOutlet UILabel *labelProgress;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UIImageView *imageCloud;
@property (weak, nonatomic) IBOutlet UIImageView *imagePlay;

- (void)configureCell:(Playlist*)playlist;
@end
