//
//  PagerSectionCell.h
//  Zype
//
//  Created by Александр on 30.01.2018.
//  Copyright © 2018 Zype. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZObject.h"
#import <iCarousel/iCarousel.h>

typedef void (^DidSelectItemBlock)(ZObject *zobject);

@interface PagerSectionCell : UITableViewCell<iCarouselDataSource, iCarouselDelegate>

@property (strong, nonatomic) IBOutlet iCarousel *iCarucelView;
@property (nonatomic, copy) DidSelectItemBlock didSelectBlock;


+ (CGFloat)rowHeight;

- (void)setPager:(NSArray *)objects;
- (void)timerInvalidate;


@end
