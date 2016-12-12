//
//  DownloadTableViewCell.m
//  Zype
//
//  Created by ZypeTech on 2/16/15.
//  Copyright (c) 2015 Zype. All rights reserved.
//

#import "DownloadTableViewCell.h"

@implementation DownloadTableViewCell

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

@end
