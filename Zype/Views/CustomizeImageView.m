//
//  CustomizeImageView.m
//  Zype
//
//  Created by Александр on 11.06.17.
//  Copyright © 2017 Zype. All rights reserved.
//

#import "CustomizeImageView.h"

@implementation CustomizeImageView

- (instancetype)initLightImage:(UIImage *)lImage andDarkImage:(UIImage *)dImage {
    
    if (kAppColorLight) {
        self = [super initWithImage:lImage];
    } else {
        self = [super initWithImage:dImage];
    }
    
    return self;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
