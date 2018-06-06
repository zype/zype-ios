//
//  SlidingHeaderView.h
//
//  Created by ZypeTech on 7/7/15.
//  Copyright (c) 2015 Zype. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SlidingHeaderViewDelegate <NSObject>

- (void)slidingHeaderViewFrameChanged;

@end

@interface SlidingHeaderView : UIView

@property (nonatomic, weak) id<SlidingHeaderViewDelegate>delegate;

@end
