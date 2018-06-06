//
//  SlidingHeaderView.m
//
//  Created by ZypeTech on 7/7/15.
//  Copyright (c) 2015 Zype. All rights reserved.
//

#import "SlidingHeaderView.h"

@interface SlidingHeaderView ()

@property (nonatomic, assign) CGFloat oldHeight;

@end

@implementation SlidingHeaderView

- (void)layoutSubviews{
    
    //let the delegate know that the view size was initialized
    if (self.oldHeight == 0) {
        [self.delegate slidingHeaderViewFrameChanged];
    }

    self.oldHeight = self.frame.size.height;
    
    [super layoutSubviews];
    
}

@end
