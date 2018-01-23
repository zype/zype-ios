//
//  VideoTableViewCell.h
//  Zype
//
//  Created by ZypeTech on 1/29/15.
//  Copyright (c) 2015 Zype. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DownloadStatusCell.h"

@interface VideoTableViewCell : UITableViewCell<DownloadStatusCell>
@property (weak, nonatomic) IBOutlet UILabel *textTitle;
@property (weak, nonatomic) IBOutlet UILabel *labelSubtitle;
@property (weak, nonatomic) IBOutlet UIImageView *imageThumbnail;
@property (weak, nonatomic) IBOutlet UIButton *buttonAction;
@property (weak, nonatomic) IBOutlet UILabel *labelProgress;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UIImageView *imageCloud;
@property (weak, nonatomic) IBOutlet UIImageView *imagePlay;
@property (weak, nonatomic) IBOutlet UIImageView *iconLock;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *widthLayoutConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *posterLayoutConstraint;

- (void)configureCell:(Video*)video viewController:(NSObject*)vc;
- (void)configureCell:(Video*)video viewController:(NSObject*)vc withLayout:(NSString *)layout;

@end
