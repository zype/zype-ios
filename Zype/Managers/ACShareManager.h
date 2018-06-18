//
//  ACShareManager.h
//
//  Created by ZypeTech on 5/29/15.
//  Copyright (c) 2015 Zype. All rights reserved.
//

#import <Foundation/Foundation.h>

@import Social;
@import MessageUI;

@interface ACShareManager : NSObject

+ (SLComposeViewController *)facebookControllerForVideo:(Video *)video;
+ (SLComposeViewController *)twitterControllerForVideo:(Video *)video;
+ (MFMailComposeViewController *)mailControllerForVideo:(Video *)video;
+ (MFMessageComposeViewController *)messageControllerForVideo:(Video *)video;

@end
