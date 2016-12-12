//
//  BaseTableController.h
//  acumiashow
//
//  Created by ZypeTech on 6/28/15.
//  Copyright (c) 2015 Zype. All rights reserved.
//

#import "EpisodeController.h"

@interface BaseTableController : EpisodeController<UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) UITableView *tableView;

- (instancetype)initWithTableView:(UITableView *)tableView;

@end
