//
//  ViewManager.m
//  TipTalk
//
//  Created by ZypeTech on 8/6/15.
//  Copyright © 2015 TipTalk. All rights reserved.
//

#import "ViewManager.h"
#import "UIStoryboard+NamedStoryboards.h"

@implementation ViewManager

+ (UIViewController *)videoDetailViewController{
    
    UIStoryboard *storyboard = [UIStoryboard mainStoryboard];
    UIViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"videoDetailViewController"];
    return viewController;
    
}

+ (UIViewController *)videosViewController{
    
    UIStoryboard *storyboard = [UIStoryboard mainStoryboard];
    UIViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"videosViewController"];
    return viewController;
    
}

+ (UIViewController *)homeViewController{
    
    UIStoryboard *storyboard = [UIStoryboard mainStoryboard];
    UIViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"homeViewController"];
    return viewController;

}

@end
