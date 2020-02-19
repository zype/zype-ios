//
//  AppDelegate.h
//  Zype
//
//  Created by ZypeTech on 1/26/15.
//  Copyright (c) 2015 Zype. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Video.h"
#import "KeychainItemWrapper.h"
#import <OneSignal/OneSignal.h>
#import <AWSCore/AWSCore.h>
#import <AWSPinpoint/AWSPinpoint.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) OneSignal *oneSignal;
@property (strong, nonatomic) AWSPinpoint *pinpoint;
@property (strong, nonatomic) NSString *userAgent;

@property (strong, nonatomic) KeychainItemWrapper *keychainItem;
@property (copy, nonatomic) void (^backgroundSessionCompletionHandler)(void);
@property () BOOL restrictRotation;

+ (AppDelegate *)appDelegate;
- (void) retrieveUserAgent;
@end

