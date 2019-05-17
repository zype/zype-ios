//
//  EPGProgramLabel.m
//  Zype
//
//  Created by Top developer on 5/10/19.
//  Copyright © 2019 Zype. All rights reserved.
//

#import "EPGProgramLabel.h"

@implementation EPGProgramLabel

- (void)drawTextInRect:(CGRect)rect {
    UIEdgeInsets insets = UIEdgeInsetsMake(0, 10, 0, 10);
    [super drawTextInRect:UIEdgeInsetsInsetRect(rect, insets)];
}

@end
