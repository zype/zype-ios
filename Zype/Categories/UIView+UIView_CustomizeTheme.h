//
//  UIView+UIView_CustomizeTheme.h
//  Zype
//
//  Created by Александр on 16.05.17.
//  Copyright © 2017 Zype. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (UIView_CustomizeTheme)

- (void)tintCustomizeTheme;
- (void)backgroudCustomizeTheme;
- (void)borderCustomizeTheme;
- (void)borderColorCustomizeTheme;

- (void)round:(CGFloat)value;
- (void)dropShadow;

@end
