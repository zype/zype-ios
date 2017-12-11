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

@property (strong, nonatomic) UITableView *tableView;

- (instancetype)initWithTableView:(UITableView *)tableView;

@end
