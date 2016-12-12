//
//  TimelineTableViewCell.h
//  Zype
//
//  Created by ZypeTech on 2/3/15.
//  Copyright (c) 2015 Zype. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TimelineTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *labelTime;
@property (weak, nonatomic) IBOutlet UILabel *labelDescription;
@property (weak, nonatomic) IBOutlet UIImageView *imagePlayIndicator;

@end
