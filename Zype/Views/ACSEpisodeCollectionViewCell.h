//
//  ACSEpisodeCollectionViewCell.h
//  acumiashow
//
//  Created by ZypeTech on 6/20/15.
//  Copyright (c) 2015 Zype. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DownloadStatusCell.h"

@interface ACSEpisodeCollectionViewCell : UICollectionViewCell<DownloadStatusCell>

@property (weak, nonatomic) IBOutlet UIImageView *thumbnailImage;
@property (weak, nonatomic) IBOutlet UIImageView *accessoryImage;
@property (weak, nonatomic) IBOutlet UIImageView *statusImage;
@property (weak, nonatomic) IBOutlet UIButton *actionButton;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *actionLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (strong, nonatomic) IBOutlet UIView *actionCoverView;
@property (strong, nonatomic) IBOutlet UIImageView *iconLock;


@property (weak, nonatomic) IBOutlet NSLayoutConstraint *statusImageWidthConstraint;

- (void)setVideo:(Video *)video;

@end
