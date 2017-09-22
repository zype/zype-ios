//
//  AVPlayerViewController+AVPlayerViewController_Transition.m
//  Zype
//
//  Created by Александр on 22.09.17.
//  Copyright © 2017 Zype. All rights reserved.
//

#import "AVPlayerViewController+AVPlayerViewController_Transition.h"

@implementation AVPlayerViewController (AVPlayerViewController_Transition)

- (void)goFullscreen {
    SEL fsSelector = NSSelectorFromString(@"_transitionToFullScreenViewControllerAnimated:completionHandler:");
    if ([self respondsToSelector:fsSelector]) {
        NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[self methodSignatureForSelector:fsSelector]];
        [inv setSelector:fsSelector];
        [inv setTarget:self];
        BOOL animated = YES;
        id completionBlock = nil;
        [inv setArgument:&(animated) atIndex:2];
        [inv setArgument:&(completionBlock) atIndex:3];
        [inv invoke];
    }
}

- (void)exitFullscreen {
    SEL fsSelector = NSSelectorFromString(@"_transitionFromFullScreenViewControllerAnimated:completionHandler:");
    if ([self respondsToSelector:fsSelector]) {
        NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[self methodSignatureForSelector:fsSelector]];
        [inv setSelector:fsSelector];
        [inv setTarget:self];
        BOOL animated = YES;
        id completionBlock = nil;
        [inv setArgument:&(animated) atIndex:2];
        [inv setArgument:&(completionBlock) atIndex:3];
        [inv invoke];
    }
}

@end
