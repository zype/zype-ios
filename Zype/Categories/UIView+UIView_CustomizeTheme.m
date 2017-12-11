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
    self.layer.borderColor = kUniversalGray.CGColor;
    //(kAppColorLight) ? kLightLineColor.CGColor : kDarkLineColor.CGColor;
}

- (void)borderColorCustomizeTheme {
    self.layer.borderWidth = 1.0f;
    self.layer.borderColor = (kAppColorLight) ? kLightTintColor.CGColor : kDarkTintColor.CGColor;
}

- (void)round:(CGFloat)value {
    self.layer.cornerRadius = value;
}

- (void)dropShadow {
    self.layer.shadowRadius  = 1.5f;
    self.layer.shadowColor   = [UIColor colorWithRed:176.f/255.f green:199.f/255.f blue:226.f/255.f alpha:1.f].CGColor;
    self.layer.shadowOffset  = CGSizeMake(0.0f, 0.0f);
    self.layer.shadowOpacity = 0.9f;
    self.layer.masksToBounds = NO;
    
    UIEdgeInsets shadowInsets     = UIEdgeInsetsMake(0, 0, -1.5f, 0);
    UIBezierPath *shadowPath      = [UIBezierPath bezierPathWithRect:UIEdgeInsetsInsetRect(self.bounds, shadowInsets)];
    self.layer.shadowPath    = shadowPath.CGPath;
}

@end
