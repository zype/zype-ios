//
//  SettingsDetailViewController.h
//  Zype
//
//  Created by ZypeTech on 2/25/15.
//  Copyright (c) 2015 Zype. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GAI.h"
#import "GAITrackedViewController.h"

@interface SettingsDetailViewController : GAITrackedViewController <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) NSIndexPath *pageIndex;

@property (nonatomic, retain) NSDate *start;

@end
