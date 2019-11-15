//
//  MoreViewController.h
//  Zype
//
//  Created by ZypeTech on 1/26/15.
//  Copyright (c) 2015 Zype. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GAIDictionaryBuilder.h"
#import "GAI.h"
#import "SubscriptionPlanDelegate.h"

@interface MoreViewController : GAITrackedViewController <UITableViewDataSource, UITableViewDelegate, SubscriptionPlanDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *buttonSignIn;

@property (nonatomic, retain) NSDate *start;

@end
