//
//  ACSTokenManager.m
//  acumiashow
//
//  Created by ZypeTech on 7/2/15.
//  Copyright (c) 2015 Zype. All rights reserved.
//

#import <Crashlytics/Crashlytics.h>

#import "ACSTokenManager.h"
#import "ACSDataManager.h"
#import "AppDelegate.h"
#import "RESTServiceController.h"
#import <Valet/Valet.h>


#define kValetKeyAccessToken @"kValetKeyAccessToken"
#define kValetKeyRefreshToken @"kValetKeyRefreshToken"
#define kDefaultsKeyExpirationDate @"kDefaultsKeyExpirationDate"

@interface ACSTokenManager ()

@property (nonatomic, strong) VALValet *valet;


@end

@implementation ACSTokenManager


+ (void)saveLoginAccessTokenData:(NSData *)data block:(successBlock)block{
    
    BOOL saved = [ACSTokenManager isAccessTokenSetWithData:data];
    
    if (saved == NO) {
        if (block) {
            block(saved, nil);
            return;
        }
    }
    
    [ACSTokenManager accessToken:^(NSString *token, NSError *error) {
        
        if (token == nil) {
            if (block) {
                block(NO, nil);
                return;
            }
        }
        
       
        [[RESTServiceController sharedInstance] saveConsumerIdWithToken:token WithCompletionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            
            BOOL success;
            
            if (data != nil) {
                
                NSError *localError = nil;
                NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
                
                if (localError != nil) {
                    
                    CLS_LOG(@"saveConsumerIdWithToken parse error: %@", localError);
                    success = NO;
                    
                }else{
                    
                    NSString *consumerId = [UIUtil dict:parsedObject valueForKey:kAppKey_ConsumerId];
                    
                    if (consumerId){
                        
                        [[NSUserDefaults standardUserDefaults] setObject:consumerId forKey:kSettingKey_ConsumerId];
                        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kSettingKey_SignInStatus];
                        
                        [ACSDataManager loadUserInfo];
                        
                        CLS_LOG(@"Consumer ID Check: %@", [[NSUserDefaults standardUserDefaults] objectForKey:kSettingKey_ConsumerId]);
                        if (kFavoritesViaAPI) {
                            [[RESTServiceController sharedInstance] syncFavoritesAfterRefreshed:NO InPage:nil WithFavoritesInDB:nil WithExistingFavorites:nil];
                        }
                        
                        success = YES;
                        
                    }else {
                        
                        success = NO;
                        
                    }
                    
                }
                
            }else {
                
                CLS_LOG(@"saveConsumerIdWithToken Error: %@", error);
                
                success = NO;
                
            }
            
            if (block) {
                block(success, nil);
            }
            
        }];

    }];
    
}


+ (void)setAccessToken:(NSString *)accessToken refreshToken:(NSString *)refreshToken expiration:(NSDate *)expiration{

    [[ACSTokenManager sharedInstance].valet setString:accessToken forKey:kValetKeyAccessToken];
    [[ACSTokenManager sharedInstance].valet setString:refreshToken forKey:kValetKeyRefreshToken];
    [ACSTokenManager setTokenExpiration:expiration];

}

+ (void)refreshAccessToken:(successBlock)block{
    
    [[RESTServiceController sharedInstance] refreshAccessTokenWithCompletionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        BOOL refreshed = [ACSTokenManager isAccessTokenSetWithData:data];
        
        if (block) {
            
            block(refreshed, error);
            
        }
        
    }];
    
}

+ (BOOL)isAccessTokenSetWithData:(NSData *)data{
    BOOL result = NO;
    
    if (data == nil) {
        return result;
    }
    
    NSError *localError = nil;
    NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
    
    if (localError != nil) {
        CLS_LOG(@"Access token parse error: %@", localError);
    }else {
        
        NSString *accessToken = [UIUtil dict:parsedObject valueForKey:kAppKey_AccessToken];
        NSString *refreshToken = [UIUtil dict:parsedObject valueForKey:kAppKey_RefreshToken];
        
        if (accessToken && refreshToken) {
            
            NSNumber *createdAt = [UIUtil dict:parsedObject valueForKey:@"created_at"];
            NSNumber *expiresIn = [UIUtil dict:parsedObject valueForKey:@"expires_in"];
            
#if DEBUG
            //use a very short expiration for testing
            expiresIn = @60; //1 minute
#endif
            
            NSUInteger expirationSeconds = createdAt.unsignedIntegerValue + expiresIn.unsignedIntegerValue;
            NSDate *expirationDate = [NSDate dateWithTimeIntervalSince1970:expirationSeconds]; //GMT
            
            [ACSTokenManager setAccessToken:accessToken refreshToken:refreshToken expiration:expirationDate];
            
            result = YES;
            
        }
        
    }
    
    return result;
}

+ (void)accessToken:(tokenBlock)tokenBlock{
    
    [[ACSTokenManager sharedInstance] migrateTokens];
    
    if ([ACSTokenManager tokenIsExpiring] == YES) {
        
        [ACSTokenManager refreshAccessToken:^(BOOL success, NSError *error) {
            
            if (tokenBlock) {
                NSString *token = [[ACSTokenManager sharedInstance].valet stringForKey:kValetKeyAccessToken];
                tokenBlock(token, nil);
            }
            
        }];
        
    }else{
        
        if (tokenBlock) {
            NSString *token = [[ACSTokenManager sharedInstance].valet stringForKey:kValetKeyAccessToken];
            tokenBlock(token, nil);
        }
        
    }
    
}

+ (NSString *)refreshToken{

    NSString *token = [[ACSTokenManager sharedInstance].valet stringForKey:kValetKeyRefreshToken];
    return token;
    
}

+ (void)resetTokens{
    
    [[ACSTokenManager sharedInstance].valet removeAllObjects];
    
}

+ (BOOL)tokenIsExpiring{
    
    NSDate *currentDate = [NSDate date]; //GMT/UTC
    NSDate *expireDate = [ACSTokenManager tokenExpiration];
    NSTimeInterval interval = [expireDate timeIntervalSince1970] - [currentDate timeIntervalSince1970];
    NSTimeInterval acceptableBuffer = 60 * 60;
    
#if DEBUG
    //use a very short expiration for testing
    acceptableBuffer = 30; //10 seconds
#endif
    
    if (interval < acceptableBuffer) {
        CLS_LOG(@"Access token expiring soon, refreshing");
        return YES;
    }
    
    return NO;
    
}

+ (void)setTokenExpiration:(NSDate *)date{
    
    [[NSUserDefaults standardUserDefaults] setValue:date forKey:kDefaultsKeyExpirationDate];
    
}

+ (NSDate *)tokenExpiration{
    
    return [[NSUserDefaults standardUserDefaults] objectForKey:kDefaultsKeyExpirationDate];
    
}

#pragma mark - Valet

- (VALValet *)valet{
    
    if (_valet != nil) {
        return _valet;
    }

    _valet = [[VALValet alloc] initWithIdentifier:@"AppSignIn" accessibility:VALAccessibilityAfterFirstUnlock];
    return _valet;
    
}

- (void)migrateTokens{
    
    NSString *oldAccessToken = [[AppDelegate appDelegate].keychainItem objectForKey:(__bridge id)(kSecAttrAccount)];
    NSString *oldRefreshToken = [[AppDelegate appDelegate].keychainItem objectForKey:(__bridge id)(kSecValueData)];
    
    if (oldAccessToken == nil || [oldAccessToken isEqualToString:@""] == YES) {
        
        return;
        
    }else{
        
        [[ACSTokenManager sharedInstance].valet setString:oldAccessToken forKey:kValetKeyAccessToken];
        [[ACSTokenManager sharedInstance].valet setString:oldRefreshToken forKey:kValetKeyRefreshToken];
        [[AppDelegate appDelegate].keychainItem resetKeychainItem];
        
    }
    
}


#pragma mark - Singleton

+ (instancetype)sharedInstance {
    
    static ACSTokenManager *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[[self class] alloc] init];
    });
    
    return _sharedInstance;
}



@end
