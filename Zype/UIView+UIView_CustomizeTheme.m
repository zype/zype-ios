//
//  UIView+UIView_CustomizeTheme.m
//  Zype
//
//  Created by Александр on 16.05.17.
//  Copyright © 2017 Zype. All rights reserved.
//

#import "UIView+UIView_CustomizeTheme.h"

@implementation UIView (UIView_CustomizeTheme)

- (void)tintCustomizeTheme {
    self.backgroundColor = (kAppColorLight) ? kLightTintColor : kDarkTintColor;
}

- (void)backgroudCustomizeTheme {
    self.backgroundColor = (kAppColorLight) ? kLightLineColor : kDarkLineColor;
}

- (void)borderCustomizeTheme {
    self.layer.borderWidth = 1.0f;
    self.layer.borderColor = (kAppColorLight) ? kLightLineColor.CGColor : kDarkLineColor.CGColor;
}

- (void)borderColorCustomizeTheme {
    self.layer.borderWidth = 1.0f;
    self.layer.borderColor = (kAppColorLight) ? kLightTintColor.CGColor : kDarkTintColor.CGColor;
}

- (void)round:(CGFloat)value {
    self.layer.cornerRadius = value;
}

@end
