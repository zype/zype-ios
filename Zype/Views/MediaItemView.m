//
//  MediaItemView.m
//  Zype
//
//  Created by Александр on 01.02.2018.
//  Copyright © 2018 Zype. All rights reserved.
//

#import "MediaItemView.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface MediaItemView()

@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation MediaItemView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        [self addSubview:self.imageView];
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.clipsToBounds = YES;
    }
    return self;
}

- (void)setZObject:(ZObject *)zObject {
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:zObject.thumbnailUrl]];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
