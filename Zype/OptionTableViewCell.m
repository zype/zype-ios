//
//  OptionTableViewCell.m
//  Zype
//
//  Created by Александр on 27.05.17.
//  Copyright © 2017 Zype. All rights reserved.
//

#import "OptionTableViewCell.h"
#import "DownloadOperationController.h"

@interface OptionTableViewCell ()

@property (nonatomic, strong) UIView *selectedBackgroundView;

@end

@implementation OptionTableViewCell

@synthesize selectedBackgroundView;

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.selectedBackgroundView = [[UIView alloc] init];
    [self.selectedBackgroundView setBackgroundColor:[UIColor lightGrayColor]];
    [self setSelectedBackgroundView:self.selectedBackgroundView];
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellTapped:)];
    [self addGestureRecognizer:tapRecognizer];
    // Initialization code
}

- (void)cellTapped:(UITapGestureRecognizer *)recognizer {
    switch (self.optionDataItem.type) {
        case Play:
            [self.delegate onDidPlayTapped:self];
            break;
        case Download:
            [self.delegate onDidDownloadTapped:self];
            break;
        case Favourite:
            [self.delegate onDidFavoriteTapped:self];
            break;
        case Share:
            [self.delegate onDidShareTapped:self];
            break;

        default:
            break;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.selectedBackgroundView setFrame:self.frame];
}

- (void)configureCell:(TableSectionDataSource *)dataSource {
    self.optionDataItem = dataSource;
    self.titleLabel.text = dataSource.title;
    self.accessoryView = dataSource.accessoryView;
}

- (void)setProgress:(DownloadInfo *)info {
    [self.progressView setHidden:!info.isDownloading];
    if (info.isDownloading) {
        self.titleLabel.text = @"Downloading...";
    } else {
        self.titleLabel.text = @"Download";
    }

}

@end
