//
//  EPGDateView.m
//  Zype
//
//  Created by Top developer on 5/8/19.
//  Copyright © 2019 Zype. All rights reserved.
//

#import "EPGDateView.h"

@implementation EPGDateView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.backgroundColor = kEPGDateViewColor;
    self.lblDate.textColor = kAppColorLight ? [UIColor blackColor] : [UIColor whiteColor];
    
    [self.viewHeightConstraint setConstant:2];
    self.viewSeperator.backgroundColor = kEPGChannelSeperatorColor;
}

@end
