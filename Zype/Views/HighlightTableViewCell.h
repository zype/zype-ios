//
//  HighlightTableViewCell.h
//  Zype
//
//  Created by ZypeTech on 2/9/15.
//  Copyright (c) 2015 Zype. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HighlightTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UITextView *textTitle;
@property (weak, nonatomic) IBOutlet UILabel *labelSubtitle;
@property (weak, nonatomic) IBOutlet UIImageView *imageThumbnail;
@property (weak, nonatomic) IBOutlet UIButton *buttonAction;

@end
