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
    SEL ios11Selector = NSSelectorFromString(@"_transitionToFullScreenAnimated:completionHandler:");
    SEL ios10Selector = NSSelectorFromString(@"_transitionToFullScreenViewControllerAnimated:completionHandler:");
    if ([self respondsToSelector:ios10Selector]) {
        [self setSelector:ios10Selector];
    } else if ([self respondsToSelector:ios11Selector]) {
        [self setSelector:ios11Selector];
    }
}

- (void)exitFullscreen {
    SEL ios11Selector = NSSelectorFromString(@"_transitionFromFullScreenAnimated:completionHandler:");
    SEL ios10Selector = NSSelectorFromString(@"_transitionFromFullScreenViewControllerAnimated:completionHandler:");
    if ([self respondsToSelector:ios10Selector]) {
        [self setSelector:ios10Selector];
    } else if ([self respondsToSelector:ios11Selector]) {
        [self setSelector:ios11Selector];
    }
}

- (void)exitFullscreen:(void (^)(void))complete {
    [self exitFullscreen];
    if (complete) {
        complete();
    }
}

- (void)setSelector:(SEL)selector {
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[self methodSignatureForSelector:selector]];
    [inv setSelector:selector];
    [inv setTarget:self];
    BOOL animated = YES;
    id completionBlock = nil;
    [inv setArgument:&(animated) atIndex:2];
    [inv setArgument:&(completionBlock) atIndex:3];
    [inv invoke];
}

@end
