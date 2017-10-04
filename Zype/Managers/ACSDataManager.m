//
//  ACSDataManager.m
//  acumiashow
//
//  Created by ZypeTech on 7/3/15.
//  Copyright (c) 2015 Zype. All rights reserved.
//

#import <Crashlytics/Crashlytics.h>

#import "ACSDataManager.h"
#import "AppDelegate.h"
#import "RESTServiceController.h"
#import "ACSTokenManager.h"
#import "ACDownloadManager.h"
#import "ACSPersistenceManager.h"
#import "Favorite.h"

@implementation ACSDataManager

+ (void)checkForLiveStream{
    
    [[RESTServiceController sharedInstance] checkLiveStreamWithCompletionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if (error) {
            CLS_LOG(@"Check Live Stream Failed: %@", error);
        } else {
            
            CLS_LOG(@"Check Live Stream Success");
            NSError *localError = nil;
            NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
            if (localError != nil) {
                CLS_LOG(@"Check Live Stream Parse Failed: %@", localError);
            }
            else {
                
                NSArray *liveStreamVideos = [UIUtil dict:parsedObject valueForKey:kAppKey_Response];
                if (liveStreamVideos.count > 0) {
                    
                    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kSettingKey_IsOnAir];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNameLiveStreamUpdated object:nil];
                    
                    NSString *liveID = [UIUtil dict:liveStreamVideos[0] valueForKey:kAppKey_Id];
                    [[NSUserDefaults standardUserDefaults] setObject:liveID forKey:kSettingKey_LiveStreamId];
                    CLS_LOG(@"Live stream on-air");
                    
                }else {
                    
                    if ([[NSUserDefaults standardUserDefaults] boolForKey:kSettingKey_IsOnAir]) {
                        
                        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNameLiveStreamUpdated object:nil];

                        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kSettingKey_IsOnAir];
                        CLS_LOG(@"Live stream off-air");
                        
                    }
                    
                }

            }
        }
        
    }];
    
}

+ (void)syncHighlights{
    
    [[RESTServiceController sharedInstance] syncHighlightsInPage:nil WithVideosInDB:nil WithExistingVideos:nil];
    
}

+ (void)downloadVideoUrlForVideoId:(NSString *)vId urlBlock:(urlBlock)block{
    
    [[RESTServiceController sharedInstance] getDownloadVideoUrlWithVideoId:vId WithCompletionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if (data != nil) {
            
            CLS_LOG(@"Success");
            NSError *localError = nil;
            NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
            
            if (localError != nil) {
                CLS_LOG(@"Failed: %@", localError);
            }else {
                
                NSString *urlString = [[RESTServiceController sharedInstance] videoDownloadUrlFromJSON:parsedObject];
                NSURL *url = [NSURL URLWithString:urlString];
                CLS_LOG(@"%@", urlString);

                if (block) {
                    block(url, nil);
                }
                
            }
            
        }else{
            
            if (error != nil) {
                CLS_LOG(@"Download Audio URL Failed: %@", error);
            }
            
            if (block) {
                block(nil, error);
            }
            
        }
        
    }];
    
}

+ (void)downloadAudioUrlForVideoId:(NSString *)vId urlBlock:(urlBlock)block{
    
    [[RESTServiceController sharedInstance] getDownloadAudioUrlWithVideoId:vId WithCompletionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if (data != nil) {
            
            CLS_LOG(@"Download Audio URL Success");
            NSError *localError = nil;
            NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
            
            if (localError != nil) {
                CLS_LOG(@"Download Audio URL Parse Failed: %@", localError);
            }else {
                
                NSString *urlString = [[RESTServiceController sharedInstance] audioDownloadUrlFromJSON:parsedObject];
                NSURL *url = [NSURL URLWithString:urlString];
                CLS_LOG(@"Download Audio URL: %@", urlString);
                
                if (block) {
                    block(url, nil);
                }
                
            }
            
        }else{
            
            if (error != nil) {
                CLS_LOG(@"Download Audio URL Failed: %@", error);
            }
            
            if (block) {
                block(nil, error);
            }
            
        }
        
    }];

}

+ (BOOL)audioDownloadExistsForVideo:(Video *)video{
    
    NSString *localAudioPath = [ACDownloadManager localAudioPathForDownloadForVideo:video];
    BOOL audioFileExists = [[NSFileManager defaultManager] fileExistsAtPath:localAudioPath];
    return audioFileExists;
    
}

+ (BOOL)videoDownloadExistsForVideo:(Video *)video{
    
    NSString *localVideoPath = [ACDownloadManager localPathForDownloadedVideo:video];
    BOOL videoFileExists = [[NSFileManager defaultManager] fileExistsAtPath:localVideoPath];
    return videoFileExists;

}


#pragma mark - Accounts

+ (void)loginWithUsername:(NSString *)username password:(NSString *)password block:(successBlock)successBlock{
    
    __block NSString *blockUsername = username;
    
    [[RESTServiceController sharedInstance] getTokenWithUsername:blockUsername WithPassword:password WithCompletionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if (data != nil) {
            
            NSError *localError = nil;
            NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
            
            if (parsedObject != nil){
                
                CLS_LOG(@"Login Parsed Object: %@", parsedObject);
                
                //allow notification sent directly to user
//                [[AppDelegate appDelegate].oneSignal setSubscription:true];
                
                [ACSTokenManager saveLoginAccessTokenData:data block:^(BOOL success, NSError *error) {
                    
                    if (successBlock) {
                        successBlock(success, error);
                    }
                    
                }];
                
            }else if (parsedObject != nil && parsedObject[@"error"] != nil) {
                
                CLS_LOG(@"sign in json error: %@", parsedObject[@"error"]);
                
                if (successBlock) {
                    successBlock(NO, localError);
                }
                
            }
            
        }else {
            
            if (successBlock) {
                successBlock(NO, error);
            }

        }
        
    }];
    
}

+ (void)registerWithUsername:(NSString *)username password:(NSString *)password block:(successBlock)successBlock{
    
    __block NSString *blockUsername = username;
    
    [[RESTServiceController sharedInstance] registerWithUsername:blockUsername WithPassword:password WithCompletionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if (data != nil) {
            
            NSError *localError = nil;
            NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
            
            if (parsedObject != nil){
                
//                CLS_LOG(@"Login Parsed Object: %@", parsedObject);
//                
//                //allow notification sent directly to user
//                //                [[AppDelegate appDelegate].oneSignal setSubscription:true];
//                
//                [ACSTokenManager saveLoginAccessTokenData:data block:^(BOOL success, NSError *error) {
//                    
//                    if (successBlock) {
//                        successBlock(success, error);
//                    }
//                    
//                }];
                
                if (successBlock) {
                    successBlock(YES, nil);
                }
                
            }else if (parsedObject != nil && parsedObject[@"error"] != nil) {
                
                CLS_LOG(@"sign in json error: %@", parsedObject[@"error"]);
                
                if (successBlock) {
                    successBlock(NO, localError);
                }
                
            }
            
        }else {
            
            if (successBlock) {
                successBlock(NO, error);
            }
            
        }
        
    }];
    
}

+ (void)loadUserInfo{
    
    [[RESTServiceController sharedInstance] getConsumerInformationWithID:[[NSUserDefaults standardUserDefaults] objectForKey:kSettingKey_ConsumerId] withCompletionHandler:^(NSData *data, NSURLResponse *response, NSError *error){
         
         if (!error)
         {
             CLS_LOG(@"getConsumerInformationWithID No Error");
         }
         else
         {
             CLS_LOG(@"getConsumerInformationWithID Error: %@", [error localizedDescription]);
         }
         
     }];
    
}

+ (void)logout{
    
    // Remove tokens
    [ACSTokenManager resetTokens];
    if (kFavoritesViaAPI) {
        [ACSPersistenceManager resetFavorites];
    }
    [ACSPersistenceManager resetUserSettings];
    [ACDownloadManager resetDownloads];
//    [[AppDelegate appDelegate].oneSignal setSubscription:false];
    
}


#pragma mark - Singleton

+ (instancetype)sharedInstance {
    
    static ACSDataManager *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[[self class] alloc] init];
    });
    
    return _sharedInstance;
}


@end
