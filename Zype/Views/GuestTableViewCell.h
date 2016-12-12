//
//  GuestTableViewCell.h
//  Zype
//
//  Created by ZypeTech on 2/3/15.
//  Copyright (c) 2015 Zype. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GuestTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imageThumbnail;
@property (weak, nonatomic) IBOutlet UILabel *labelName;
@property (weak, nonatomic) IBOutlet UITextView *textDescription;
@property (weak, nonatomic) IBOutlet UIButton *buttonFacebook;
@property (weak, nonatomic) IBOutlet UIButton *buttonTwitter;
@property (weak, nonatomic) IBOutlet UIButton *buttonYoutube;

@end
