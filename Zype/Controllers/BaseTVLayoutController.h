//
//  BaseTVLayoutController.h
//  Zype
//
//  Created by Александр on 11.12.2017.
//  Copyright © 2017 Zype. All rights reserved.
//

#import "EpisodeController.h"
#import "PlaylistCollectionCell.h"

@interface BaseTVLayoutController : EpisodeController<UITableViewDataSource, UITableViewDelegate, PlaylistCollectionCellDelegate>

@property (strong, nonatomic) PlaylistCollectionCell * playlistCellSelected;

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSMutableArray* sectionLabelHeights;

- (instancetype)initWithTableView:(UITableView *)tableView;
- (void) iCarouselTimerInvalidate;

@end
