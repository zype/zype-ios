//
//  PagerSectionCell.m
//  Zype
//
//  Created by Александр on 30.01.2018.
//  Copyright © 2018 Zype. All rights reserved.
//

#import "PagerSectionCell.h"
#import "MediaItemCollectionCell.h"
#import "MediaItemView.h"

@interface PagerSectionCell()

@property (nonatomic, strong) NSArray * zObjects;
@property (nonatomic, strong) NSTimer * timer;

@end

@implementation PagerSectionCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.iCarucelView.delegate = self;
    self.iCarucelView.dataSource = self;
    self.iCarucelView.decelerationRate = 0.0f;
    self.zObjects = [[NSArray alloc] init];

    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setPager:(NSArray *)objects {
    self.zObjects = objects;

    [UIView transitionWithView:self.iCarucelView
                      duration:0.35f
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^(void) {
         [self.iCarucelView reloadData];
                    } completion:^(BOOL finished) {
                        if (self.zObjects.count > 1) {
                            [self startTimer];
                            [self.iCarucelView setScrollEnabled:YES];
                        } else {
                            [self.iCarucelView setScrollEnabled:NO];
                            [self.timer invalidate];
                            self.timer = nil;
                        }
                    }];
}

- (NSInteger)numberOfItemsInCarousel:(iCarousel *)carousel {
    return self.zObjects.count;
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSInteger)index reusingView:(MediaItemView *)view {
    if (view == nil) {
        view = [[MediaItemView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, [PagerSectionCell rowHeight])];
    }
    
    ZObject *zObject = self.zObjects[index];
    [view setZObject:zObject];
    
    return view;
}

- (CGFloat)carousel:(iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value {
    switch (option) {
        case iCarouselOptionWrap:
            return YES;
        default:
        return value;
    }
    
    return value;
}

- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index {
    ZObject *zObject = self.zObjects[index];
    if (self.didSelectBlock) self.didSelectBlock(zObject.playlistid);
}

- (void)carouselCurrentItemIndexDidChange:(iCarousel *)carousel {
    [self startTimer];
}

+ (CGFloat)rowHeight {
    return 180;
}

#pragma - mark Timer

- (void)startTimer {
    [self.timer invalidate];
    self.timer = nil;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:7.0f
                                                  target:self
                                                selector:@selector(timerTicked) userInfo:nil
                                                 repeats:NO];
}

- (void)timerTicked {
    [self.iCarucelView scrollByNumberOfItems:1 duration:0.5];
    [self startTimer];
}

@end
