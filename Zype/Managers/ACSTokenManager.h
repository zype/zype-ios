//
//  ACSTokenManager.h
//
//  Created by ZypeTech on 7/2/15.
//  Copyright (c) 2015 Zype. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^successBlock)(BOOL success, NSError *error);
typedef void(^tokenBlock)(NSString *token, NSError *error);

@interface ACSTokenManager : NSObject

+ (void)saveLoginAccessTokenData:(NSData *)data block:(successBlock)block;
+ (void)refreshAccessToken:(successBlock)block;
+ (void)accessToken:(tokenBlock)tokenBlock;
+ (NSString *)refreshToken;
+ (void)resetTokens;

//Singleton
+ (instancetype)sharedInstance;

@end
