//
//  OptionTableViewCell.h
//  Zype
//
//  Created by Александр on 27.05.17.
//  Copyright © 2017 Zype. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TableSectionDataSource.h"

@protocol OptionTableViewCellDelegate;
@interface OptionTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UIProgressView *progressView;
@property (nonatomic, weak) id <OptionTableViewCellDelegate> delegate;

- (void)configureCell:(TableSectionDataSource *)dataSource;

@end

@protocol OptionTableViewCellDelegate <NSObject>

- (void)onDidPlayTapped:(OptionTableViewCell *)cell;
- (void)onDidDownloadTapped:(OptionTableViewCell *)cell;
- (void)onDidFavoriteTapped:(OptionTableViewCell *)cell;
- (void)onDidShareTapped:(OptionTableViewCell *)cell;

@end
