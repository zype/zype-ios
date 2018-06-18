//
//  ACSDataManager.h
//
//  Created by ZypeTech on 7/3/15.
//  Copyright (c) 2015 Zype. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BlockDefinitions.h"

typedef void(^urlBlock)(NSURL *url, NSError *error);

@interface ACSDataManager : NSObject

+ (void)checkForLiveStream;
+ (void)syncHighlights;

+ (void)downloadVideoUrlForVideoId:(NSString *)vId urlBlock:(urlBlock)block;
+ (void)downloadAudioUrlForVideoId:(NSString *)vId urlBlock:(urlBlock)block;

+ (BOOL)audioDownloadExistsForVideo:(Video *)video;
+ (BOOL)videoDownloadExistsForVideo:(Video *)video;

+ (void)loginWithUsername:(NSString *)username password:(NSString *)password  block:(successBlock)successBlock;
+ (void)registerWithUsername:(NSString *)username password:(NSString *)password block:(successBlock)successBlock;
+ (void)loadUserInfo;
+ (void)logout;

//Singleton
+ (instancetype)sharedInstance;

@end
