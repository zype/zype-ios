//
//  EPGChannelView.m
//  Zype
//
//  Created by Top developer on 5/8/19.
//  Copyright © 2019 Zype. All rights reserved.
//

#import "EPGChannelView.h"

@implementation EPGChannelView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.imageView.layer.cornerRadius = 25.0;
    self.imageView.image = [UIImage imageNamed: @"ImagePlaceholder"];
    
    self.lblTitle.textColor = kAppColorLight ? [UIColor blackColor] : [UIColor whiteColor];
    self.backgroundColor = kEPGDateViewColor;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [self.lblTitle setFont: [UIFont systemFontOfSize:20.0 weight:UIFontWeightMedium]];
    } else {
        [self.lblTitle setFont: [UIFont systemFontOfSize:16.0 weight:UIFontWeightMedium]];
    }
}

@end
