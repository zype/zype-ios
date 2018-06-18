//
//  UIViewController+AC.m
//
//  Created by ZypeTech on 7/7/15.
//  Copyright (c) 2015 Zype. All rights reserved.
//

#import "UIViewController+AC.h"

@implementation UIViewController (AC)

#pragma mark - Utility

- (BOOL)isRegularSizeClass{
    
    if ([self respondsToSelector:@selector(traitCollection)]) {
        UIUserInterfaceSizeClass horizontalSizeClass = self.traitCollection.horizontalSizeClass;
        UIUserInterfaceSizeClass verticalSizeClass = self.traitCollection.verticalSizeClass;
        if (horizontalSizeClass == UIUserInterfaceSizeClassRegular && verticalSizeClass == UIUserInterfaceSizeClassRegular) {
            
            return YES;
            
        }
    }else if ([[UIDevice currentDevice] respondsToSelector: @selector(userInterfaceIdiom)]){
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad){
            
            return YES;
            
        }
    }
    
    return NO;
    
}

- (void)showBasicAlertWithTitle:(NSString *)title WithMessage:(NSString *)message{
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    
    [alert setTitle:title];
    [alert setMessage:message];
    
    [alert show];
    
}

- (void)customizeAppearance {
    if (kAppColorLight) {
        self.view.backgroundColor = [UIColor whiteColor];
    } else {
        [self.navigationController.navigationBar setBarStyle:UIBarStyleBlackOpaque];
        self.view.backgroundColor = kDarkThemeBackgroundColor;
    }
    
    // self.navigationController.navigationBar.backgroundColor = [UIColor blackColor];
    //  self.view.backgroundColor = [UIColor blackColor];
}

@end
