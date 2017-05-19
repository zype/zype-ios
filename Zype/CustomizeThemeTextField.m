//
//  CustomizeThemeTextField.m
//  Zype
//
//  Created by Александр on 16.05.17.
//  Copyright © 2017 Zype. All rights reserved.
//

#import "CustomizeThemeTextField.h"

@implementation CustomizeThemeTextField


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self) {
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self) {
        [self setup];
    }
    return self;
}

- (id)init
{
    self = [super init];
    if(self) {
        [self setup];
    }
    return self;
}

- (void)awakeFromNib{
    [super awakeFromNib];
    
    [self setup];
    
}

- (void)setup{
    
    [self setupDefaultAppearance];
    self.clipsToBounds = YES;
    
}

- (void)setupDefaultAppearance {
    self.textColor = (kAppColorLight) ? kDarkThemeBackgroundColor : [UIColor whiteColor];
}

- (void)setAttributePlaceholder:(NSString *)string {
    UIColor *color = (kAppColorLight) ? kLightLineColor : kDarkLineColor;
    NSAttributedString *placeholder = [[NSAttributedString alloc] initWithString:string attributes:@{NSForegroundColorAttributeName: color}];
    self.attributedPlaceholder = placeholder;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
