//
//  ACStatusManager.m
//
//  Created by ZypeTech on 5/28/15.
//  Copyright (c) 2015 Zype. All rights reserved.
//

#import "ACStatusManager.h"

@implementation ACStatusManager

+ (BOOL)isShowLive{
    
    return [[NSUserDefaults standardUserDefaults] boolForKey:kSettingKey_IsOnAir];
    
}

+ (BOOL)isUserSignedIn{
    
    return [[NSUserDefaults standardUserDefaults] boolForKey:kSettingKey_SignInStatus];
    
}

@end
