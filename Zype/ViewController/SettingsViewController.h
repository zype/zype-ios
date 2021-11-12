//
//  SettingsViewController.h
//  Zype
//
//  Created by ZypeTech on 2/25/15.
//  Copyright (c) 2015 Zype. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleAnalytics/GAI.h>
#import <GoogleAnalytics/GAIDictionaryBuilder.h>
#import "SubscriptionPlanDelegate.h"

@import WebKit;

@interface SettingsViewController : GAITrackedViewController <UITableViewDataSource, UITableViewDelegate, SubscriptionPlanDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSIndexPath *pageIndex;
@property (weak, nonatomic) IBOutlet UIButton *buttonSignOut;
@property (retain, nonatomic) WKWebView *wkWebView;
@property (nonatomic, retain) NSDate *start;

@end
