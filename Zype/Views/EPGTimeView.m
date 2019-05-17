//
//  EPGTimeView.m
//  Zype
//
//  Created by Top developer on 5/8/19.
//  Copyright © 2019 Zype. All rights reserved.
//

#import "EPGTimeView.h"

@implementation EPGTimeView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.lbleTitle.textColor = kAppColorLight ? [UIColor blackColor] : [UIColor whiteColor];
}

@end
