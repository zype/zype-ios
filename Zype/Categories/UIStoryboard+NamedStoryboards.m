//
//  UIStoryboard+NamedStoryboards.m
//
//  Created by ZypeTech on 8/6/15.
//

#import "UIStoryboard+NamedStoryboards.h"

@implementation UIStoryboard (NamedStoryboards)

#pragma mark - Global

+ (instancetype)storyboardWithName:(NSString *)name{
    
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *storyboardName = name ?: [bundle objectForInfoDictionaryKey:@"UIMainStoryboardFile"];
    return [UIStoryboard storyboardWithName:storyboardName bundle:bundle];
    
}

#pragma mark - Storyboards

+ (instancetype)mainStoryboard{
    
    static id _mainStoryboard = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _mainStoryboard = [UIStoryboard storyboardWithName:@"Main"];
    });
    
    return _mainStoryboard;
    
}

@end
