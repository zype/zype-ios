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
@property (nonatomic, strong) UIImageView *placeholderImageView;


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
        
        self.placeholderImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
        [self addSubview:self.placeholderImageView];
        [self.placeholderImageView setImage:[UIImage imageNamed:@"slider-placeholder"]];
        self.placeholderImageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return self;
}

- (void)setZObject:(ZObject *)zObject {
    [self.placeholderImageView setHidden:NO];
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:zObject.thumbnailUrl] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        if (image) {
            [self.placeholderImageView setHidden:YES];
        }
    }];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.placeholderImageView setCenter:CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2)];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
