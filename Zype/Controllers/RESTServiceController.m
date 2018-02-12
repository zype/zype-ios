//
//  RESTServiceController.m
//  Zype
//
//  Created by ZypeTech on 1/28/15.
//  Copyright (c) 2015 Zype. All rights reserved.
//

#import <Crashlytics/Crashlytics.h>
#import "RESTServiceController.h"
#import "ACDownloadManager.h"
#import "Guest.h"
#import "Favorite.h"
#import "Notification.h"
#import "GAI.h"
#import "GAIFields.h"
#import "NSString+AC.h"
#import "ACSTokenManager.h"
#import "ACSPersistenceManager.h"
#import "ACSDataManager.h"
#import "PlaybackSource.h"
#import "NSURL+Encoding.h"
#import "ACStatusManager.h"
#import "Playlist.h"

@implementation RESTServiceController

#pragma mark - OAuth App

- (void)getTokenWithUsername:(NSString *)username WithPassword:(NSString *)password WithCompletionHandler:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completionHandler{
    
    NSString *encodedPassword = [password URLEncodedString];
    
    // Prepare parameters
    NSDictionary *parameters = @{
                                 kOAuthProperty_Username : username,
                                 kOAuthProperty_Password : encodedPassword,
                                 kOAuthProperty_ClientId : kOAuth_ClientId,
                                 kOAuthProperty_ClientSecret : kOAuth_ClientSecret,
                                 kOAuthProperty_GrantType : kOAuth_GrantType,
                                 };
    NSMutableString *parameterString = [NSMutableString string];
    for (NSString *key in [parameters allKeys]) {
        if ([parameterString length]) {
            [parameterString appendString:@"&"];
        }
        [parameterString appendFormat:@"%@=%@", key, parameters[key]];
    }
    
    // Send request
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:kOAuth_GetToken, KOAuth_GetTokenDomain]]];
    
    CLS_LOG(@"Sample Save Token URL: %@", request.URL);
    
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[parameterString dataUsingEncoding:NSUTF8StringEncoding]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (completionHandler)
        {
            completionHandler(data, response, error);
            //            CLS_LOG(@"LOGIN DATA RESPONSE:%@", data);
        }
    }];
    [task resume];
}

- (void)registerWithUsername:(NSString *)username WithPassword:(NSString *)password WithCompletionHandler:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completionHandler{
    
    NSString *encodedPassword = [password URLEncodedString];
    
    // Prepare parameters
    NSDictionary *parameters = @{
                                 kOAuthProperty_Email : username,
                                 kOAuthProperty_Password : encodedPassword,
                                 };
    NSDictionary *consumer = @{ kOAuthProperty_Consumer : parameters };
    NSError *error = nil;
    NSData *requestData = [NSJSONSerialization dataWithJSONObject:consumer options:0 error:&error];
    
    // Send request
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:KOAuth_RegisterDomain, kAppKey]]];
    
    CLS_LOG(@"Sample Save Token URL: %@", request.URL);
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody: requestData];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (completionHandler)
        {
            completionHandler(data, response, error);
            //            CLS_LOG(@"LOGIN DATA RESPONSE:%@", data);
        }
    }];
    [task resume];
}

- (void)getConsumerInformationWithID:(NSString *)consumerId withCompletionHandler:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completion
{
    
    [ACSTokenManager accessToken:^(NSString *token, NSError *error){
        
        NSString *urlAsString = [NSString stringWithFormat:@"https://api.zype.com/consumers/%@/?access_token=%@", consumerId, token];
        CLS_LOG(@"URL AS STRING TEST ONE MORE TIME W/ ACCESS TOKEN: %@", urlAsString);
        NSURL *url = [NSURL withString:urlAsString];
        
        NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
        NSURLSessionDataTask *dataTask = [session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if (error) {
                CLS_LOG(@"Failed: %@", error);
            } else {
                completion(data, response, error);
                CLS_LOG(@"Success: %@", [NSJSONSerialization JSONObjectWithData:data options:0 error:nil]);
                
                [[NSUserDefaults standardUserDefaults] setValue:[[[NSJSONSerialization JSONObjectWithData:data options:0 error:nil] valueForKey:@"response"] valueForKey:@"subscription_count"] forKey:kOAuthProperty_Subscription];
            }
        }];
        [dataTask resume];
        
    }];
    
}


- (void)saveConsumerIdWithToken:(NSString *)accessToken WithCompletionHandler:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completionHandler
{
    NSString *urlAsString = [NSString stringWithFormat:kOAuth_GetTokenInfo, KOAuth_GetTokenDomain, accessToken];
    
    CLS_LOG(@"URL AS STRING: %@", urlAsString);
    
    NSURL *url = [NSURL withString:urlAsString];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
                                      {
                                          if (completionHandler)
                                          {
                                              completionHandler(data, response, error);
                                              CLS_LOG(@"SAVE CONSUMER ID RESPONSE: %@", [NSJSONSerialization JSONObjectWithData:data options:0 error:nil]);
                                          }
                                      }];
    [dataTask resume];
}

- (void)refreshAccessTokenWithCompletionHandler:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completionHandler
{
    // Prepare parameters
    NSString *refreshToken = [ACSTokenManager refreshToken];
    if (refreshToken == nil) {
        if (completionHandler) {
            completionHandler(nil, nil, nil);
        }
        return;
    }
    
    NSDictionary *parameters = @{
                                 kOAuthProperty_RefreshToken : refreshToken,
                                 kOAuthProperty_ClientId : kOAuth_ClientId,
                                 kOAuthProperty_ClientSecret : kOAuth_ClientSecret,
                                 kOAuthProperty_GrantType : kOAuth_GrantTypeRefresh
                                 };
    NSMutableString *parameterString = [NSMutableString string];
    for (NSString *key in [parameters allKeys]) {
        if ([parameterString length]) {
            [parameterString appendString:@"&"];
        }
        [parameterString appendFormat:@"%@=%@", key, parameters[key]];
    }
    
    // Send request
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:kOAuth_GetToken, KOAuth_GetTokenDomain]]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[parameterString dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if (completionHandler){
            completionHandler(data, response, error);
        }
        
    }];
    
    [task resume];
    
}

#pragma mark - Video App

- (void)syncVideosInPage:(NSNumber *)page WithVideosInDB:(NSMutableArray *)videosInDB WithExistingVideos:(NSMutableArray *)existingVideos
{
    // Prepare videos in core data
    if (!videosInDB) {
        NSArray *fetchedObjects = [ACSPersistenceManager allVideos];
        videosInDB = [[NSMutableArray alloc] initWithArray:fetchedObjects];
    }
    
    // Load videos
    if (!page && !existingVideos) {
        page = [NSNumber numberWithInt:1];
        existingVideos = [[NSMutableArray alloc] init];
    }
    NSString *urlAsString = [NSString stringWithFormat:kGetVideos, kApiDomain, kAppKey, page];
    NSURL *url = [NSURL withString:urlAsString];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if (error) {
            CLS_LOG(@"Failed: %@", error);
        } else {
            
            CLS_LOG(@"Success %@", urlAsString);
            NSError *localError = nil;
            NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
            if (localError != nil) {
                CLS_LOG(@"Failed: %@", localError);
            }
            else {
                
                // Check if there's any next pages and continue to sync next one
                NSNumber *pages = (NSNumber *)[UIUtil dict:[UIUtil dict:parsedObject valueForKey:kAppKey_Pagination] valueForKey:kAppKey_Pages];
                NSNumber *nextPage = (NSNumber *)[UIUtil dict:[UIUtil dict:parsedObject valueForKey:kAppKey_Pagination] valueForKey:kAppKey_NextPage];
                if ([UIUtil hasNextPage:nextPage InPages:pages WithData:parsedObject]){
                    [self syncVideosInPage:nextPage WithVideosInDB:videosInDB WithExistingVideos:existingVideos];
                }
                // Check if it's the last page or not, then populate videos
                [ACSPersistenceManager populateVideosFromDict:parsedObject WithVideosInDB:videosInDB WithExistingVideos:existingVideos IsLastPage:[UIUtil isLastPageInPages:pages WithData:parsedObject] addToPlaylist:nil];
                
            }
            
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ResultsFromPlaylistReturned" object:nil];
        
    }];
    
    [dataTask resume];
    
}

- (void)syncVideosFromDate:(NSDate *)fromDate ToDate:(NSDate *)toDate InPage:(NSNumber *)page WithVideosInDB:(NSArray *)videosInDBFiltered WithExistingVideos:(NSArray *)existingVideos
{
    
    if (page == nil) {
        page = @1;
    }
    if (existingVideos == nil) {
        existingVideos = [NSMutableArray new];
    }
    if (!videosInDBFiltered) {
        videosInDBFiltered = [ACSPersistenceManager videosFromDate:fromDate toDate:toDate];
    }
    
    NSString *urlAsString = [NSString stringWithFormat:kGetVideosWithFilter, kApiDomain, kAppKey, [UIUtil stringDateFilterFromDate:fromDate ToDate:toDate], page];
    NSURL *url = [NSURL withString:urlAsString];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if (error) {
            CLS_LOG(@"Failed: %@", error);
        } else {
           CLS_LOG(@"Success %@", urlAsString);
            NSError *localError = nil;
            NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
            if (localError != nil) {
                CLS_LOG(@"Failed: %@", localError);
            }
            else {
                
                // Check if there's any next pages and continue to sync next one
                NSNumber *pages = (NSNumber *)[UIUtil dict:[UIUtil dict:parsedObject valueForKey:kAppKey_Pagination] valueForKey:kAppKey_Pages];
                NSNumber *nextPage = (NSNumber *)[UIUtil dict:[UIUtil dict:parsedObject valueForKey:kAppKey_Pagination] valueForKey:kAppKey_NextPage];
                if ([UIUtil hasNextPage:nextPage InPages:pages WithData:parsedObject]){
                    [self syncVideosFromDate:fromDate ToDate:toDate InPage:nextPage WithVideosInDB:videosInDBFiltered WithExistingVideos:existingVideos];
                }
                // Check if it's the last page or not, then populate videos
                [ACSPersistenceManager populateVideosFromDict:parsedObject WithVideosInDB:videosInDBFiltered WithExistingVideos:existingVideos IsLastPage:[UIUtil isLastPageInPages:pages WithData:parsedObject] addToPlaylist:nil];
                
            }
            
            //auto download latest video after loading results
            [ACDownloadManager autoDownloadLatestVideo];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ResultsByDateReturned" object:nil];
            
        }
        
    }];
    
    [dataTask resume];
    
}

- (void)syncHighlightsInPage:(NSNumber *)page WithVideosInDB:(NSMutableArray *)highlightsInDB WithExistingVideos:(NSMutableArray *)existingVideos
{
    // Prepare highlights in core data
    if (!highlightsInDB) {
        NSArray *fetchedObjects = [ACSPersistenceManager allHighlights];
        highlightsInDB = [[NSMutableArray alloc] initWithArray:fetchedObjects];
    }
    
    // Load highlights
    if (!page && !existingVideos) {
        page = [NSNumber numberWithInt:1];
        existingVideos = [[NSMutableArray alloc] init];
    }
    NSString *urlAsString = [NSString stringWithFormat:kGetHighlights, kApiDomain, kAppKey, page];
    NSURL *url = [NSURL withString:urlAsString];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if (error) {
            CLS_LOG(@"Failed: %@", error);
        } else {
            
           CLS_LOG(@"Success %@", urlAsString);
            NSError *localError = nil;
            NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
            if (localError != nil) {
                CLS_LOG(@"Failed: %@", localError);
            }
            else {
                
                // Check if there's any next pages and continue to sync next one
                NSNumber *pages = (NSNumber *)[UIUtil dict:[UIUtil dict:parsedObject valueForKey:kAppKey_Pagination] valueForKey:kAppKey_Pages];
                NSNumber *nextPage = (NSNumber *)[UIUtil dict:[UIUtil dict:parsedObject valueForKey:kAppKey_Pagination] valueForKey:kAppKey_NextPage];
                if ([UIUtil hasNextPage:nextPage InPages:pages WithData:parsedObject]){
                    [self syncHighlightsInPage:nextPage WithVideosInDB:highlightsInDB WithExistingVideos:existingVideos];
                }
                
                // Check if it's the last page or not, then populate videos
                [ACSPersistenceManager populateVideosFromDict:parsedObject WithVideosInDB:highlightsInDB WithExistingVideos:existingVideos IsLastPage:[UIUtil isLastPageInPages:pages WithData:parsedObject] addToPlaylist:nil];
                
            }
        }
    }];
    
    [dataTask resume];
    
}

- (void)syncVideosFromPlaylist:(NSString *)playlistId InPage:(NSNumber *)page WithVideosInDB:(NSArray *)videosInDBFiltered WithExistingVideos:(NSArray *)existingVideos
{
    if (page == nil) {
        page = @1;
    }
    if (existingVideos == nil) {
        existingVideos = [NSMutableArray new];
    }
 
    NSString *urlAsString = [NSString stringWithFormat:kGetVideosFromPlaylist, kApiDomain, playlistId, kAppKey, page];
    NSURL *url = [NSURL withString:urlAsString];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if (error) {
            CLS_LOG(@"Failed: %@", error);
        } else {
            CLS_LOG(@"Success %@", urlAsString);
            NSError *localError = nil;
            NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
            if (localError != nil) {
                CLS_LOG(@"Failed: %@", localError);
            }
            else {
                //remove old playlist relationships. may be check for stored videos, once download functionality will be added
                if ([page isEqualToNumber:@1]){
                    Playlist *currentPlaylist = [ACSPersistenceManager playlistWithID:playlistId];
                    for (PlaylistVideo* playlistVideo in [currentPlaylist.playlistVideo allObjects]){
                        [[ACSPersistenceManager sharedInstance].managedObjectContext deleteObject:playlistVideo];
                    }
                }
                
                // Check if there's any next pages and continue to sync next one
                NSNumber *pages = (NSNumber *)[UIUtil dict:[UIUtil dict:parsedObject valueForKey:kAppKey_Pagination] valueForKey:kAppKey_Pages];
                NSNumber *nextPage = (NSNumber *)[UIUtil dict:[UIUtil dict:parsedObject valueForKey:kAppKey_Pagination] valueForKey:kAppKey_NextPage];
                if ([UIUtil hasNextPage:nextPage InPages:pages WithData:parsedObject]){
                    [self syncVideosFromPlaylist:playlistId InPage:nextPage WithVideosInDB:videosInDBFiltered WithExistingVideos:existingVideos];
                }
                // Check if it's the last page or not, then populate videos
                [ACSPersistenceManager populateVideosFromDict:parsedObject WithVideosInDB:videosInDBFiltered WithExistingVideos:existingVideos IsLastPage:[UIUtil isLastPageInPages:pages WithData:parsedObject] addToPlaylist:playlistId];
                
            }
            
           /* //auto download latest video after loading results
            [ACDownloadManager autoDownloadLatestVideo];*/
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ResultsFromPlaylistReturned" object:nil];
            
        }
        
    }];
    
    [dataTask resume];
    
}

- (void)syncVideosFromPlaylist:(NSString *)playlistId InPage:(NSNumber *)page WithVideosInDB:(NSArray *)videosInDBFiltered WithExistingVideos:(NSArray *)existingVideos withCompletionHandler:(void (^)())complete
{
    if (page == nil) {
        page = @1;
    }
    if (existingVideos == nil) {
        existingVideos = [NSMutableArray new];
    }
    
    NSString *urlAsString = [NSString stringWithFormat:kGetVideosFromPlaylist, kApiDomain, playlistId, kAppKey, page];
    NSURL *url = [NSURL withString:urlAsString];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if (error) {
            CLS_LOG(@"Failed: %@", error);
        } else {
            CLS_LOG(@"Success %@", urlAsString);
            NSError *localError = nil;
            NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
            if (localError != nil) {
                CLS_LOG(@"Failed: %@", localError);
            }
            else {
                //remove old playlist relationships. may be check for stored videos, once download functionality will be added
                if ([page isEqualToNumber:@1]){
                    Playlist *currentPlaylist = [ACSPersistenceManager playlistWithID:playlistId];
                    for (PlaylistVideo* playlistVideo in [currentPlaylist.playlistVideo allObjects]){
                        [[ACSPersistenceManager sharedInstance].managedObjectContext deleteObject:playlistVideo];
                    }
                }
                
                // Check if there's any next pages and continue to sync next one
                NSNumber *pages = (NSNumber *)[UIUtil dict:[UIUtil dict:parsedObject valueForKey:kAppKey_Pagination] valueForKey:kAppKey_Pages];
                NSNumber *nextPage = (NSNumber *)[UIUtil dict:[UIUtil dict:parsedObject valueForKey:kAppKey_Pagination] valueForKey:kAppKey_NextPage];
                if ([UIUtil hasNextPage:nextPage InPages:pages WithData:parsedObject]){
                    [self syncVideosFromPlaylist:playlistId InPage:nextPage WithVideosInDB:videosInDBFiltered WithExistingVideos:existingVideos];
                }
                // Check if it's the last page or not, then populate videos
                [ACSPersistenceManager populateVideosFromDict:parsedObject WithVideosInDB:videosInDBFiltered WithExistingVideos:existingVideos IsLastPage:[UIUtil isLastPageInPages:pages WithData:parsedObject] addToPlaylist:playlistId];
                
            }
            
            /* //auto download latest video after loading results
             [ACDownloadManager autoDownloadLatestVideo];*/
            if (complete) complete();
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ResultsFromPlaylistReturned" object:nil];
            
        }
        
    }];
    
    [dataTask resume];
    
}


#pragma mark - Playlist App

- (void)syncPlaylistWithId:(NSString *)playlistId withCompletionHandler:(void (^)(NSString *))errorString {
    NSString *urlAsString = [NSString stringWithFormat:kGetPlaylist, kApiDomain, playlistId ,kAppKey];
    NSURL *url = [NSURL withString:urlAsString];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if (error) {
            CLS_LOG(@"Failed: %@", error);
            if (errorString) errorString(error.localizedDescription);
            return;
        } else {
            
            CLS_LOG(@"Success: %@", urlAsString);
            NSError *localError = nil;
            NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
            if (localError != nil) {
                CLS_LOG(@"Failed: %@", localError);
                if (errorString) errorString(localError.localizedDescription);
                return;
            }
            else {
                //remove old relationship
//                [ACSPersistenceManager resetPlaylistChilds:parentId];
//
                [ACSPersistenceManager populatePlaylistFromDictionary:parsedObject];
                if (errorString) errorString(nil);
                //CLS_LOG(@"parsedObject = %@", parsedObject);
            }
            
        }
        
    }];
    
    [dataTask resume];
}

- (void)syncPlaylistsWithParentId:(NSString *)parentId
{
    NSString *urlAsString = [NSString stringWithFormat:kGetPlaylists, kApiDomain, kAppKey, parentId];
    NSURL *url = [NSURL withString:urlAsString];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if (error) {
            CLS_LOG(@"Failed: %@", error);
        } else {
            
            CLS_LOG(@"Success: %@", urlAsString);
            NSError *localError = nil;
            NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
            if (localError != nil) {
                CLS_LOG(@"Failed: %@", localError);
            }
            else {
                //remove old relationship
                [ACSPersistenceManager resetPlaylistChilds:parentId];
                
                [ACSPersistenceManager populatePlaylistsFromDictionary:parsedObject];
               //CLS_LOG(@"parsedObject = %@", parsedObject);
            }
            
        }
        
    }];
    
    [dataTask resume];
    
}

- (void)syncPlaylistsWithParentId:(NSString *)parentId withCompletionHandler:(void (^)())complete
{
    NSString *urlAsString = [NSString stringWithFormat:kGetPlaylists, kApiDomain, kAppKey, parentId];
    NSURL *url = [NSURL withString:urlAsString];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if (error) {
            CLS_LOG(@"Failed: %@", error);
        } else {
            
            CLS_LOG(@"Success: %@", urlAsString);
            NSError *localError = nil;
            NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
            if (localError != nil) {
                CLS_LOG(@"Failed: %@", localError);
            }
            else {
                //remove old relationship
                [ACSPersistenceManager resetPlaylistChilds:parentId];
                [ACSPersistenceManager populatePlaylistsFromDictionary:parsedObject];
                
            }
            
        }
        
        if (complete) complete();
        
    }];
    
    [dataTask resume];
    
}

#pragma mark - ZObject

- (void)syncZObject {
    NSString * zypeType = @"top_playlists";
    NSString * urlAsString = [NSString stringWithFormat:kZObjectContent, kApiDomain, kAppKey, zypeType];
    NSURL *url = [NSURL withString:urlAsString];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if (error) {
            CLS_LOG(@"Failed: %@", error);
            //if (complete) complete(error.localizedDescription);
        } else {
            
            CLS_LOG(@"Success: %@", urlAsString);
            NSError *localError = nil;
            NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
            if (localError != nil) {
                //if (complete) complete(localError.localizedDescription);
                CLS_LOG(@"Failed: %@", localError);
            }
            else {
                //if (complete) complete(nil);
                //remove old relationship
                [ACSPersistenceManager resetZObjectChilds];
                [ACSPersistenceManager populateZObjectsFromDictionary:parsedObject];
            }
        }
    }];
    
    [dataTask resume];
}

#pragma mark - Download App

- (void)getDownloadVideoUrlWithVideoId:(NSString *)vId WithCompletionHandler:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completionHandler
{
    
    [ACSTokenManager accessToken:^(NSString *token, NSError *error) {
        
        NSString *urlAsString;
        if ([ACStatusManager isUserSignedIn] == YES) {
            urlAsString = [NSString stringWithFormat:kGetDownloadVideoUrl, kApiPlayerDomain, vId, token];
        } else {
            urlAsString = [NSString stringWithFormat:kGetDownloadVideoUrlForGuest, kApiPlayerDomain, vId, kAppKey];
        }
        
        NSURL *url = [NSURL withString:urlAsString];
        
        NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
        NSURLSessionDataTask *dataTask = [session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if (completionHandler) completionHandler(data, response, error);
        }];
        [dataTask resume];
        
    }];
    
    
}

- (void)getDownloadAudioUrlWithVideoId:(NSString *)vId WithCompletionHandler:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completionHandler
{
    
    [ACSTokenManager accessToken:^(NSString *token, NSError *error) {
        
        NSString *urlAsString;
        if ([ACStatusManager isUserSignedIn] == YES) {
            urlAsString = [NSString stringWithFormat:kGetDownloadAudioUrl, kApiPlayerDomain, vId, token];
        } else {
            urlAsString = [NSString stringWithFormat:kGetDownloadAudioUrlForGuest, kApiPlayerDomain, vId, kAppKey];
        }
        NSURL *url = [NSURL withString:urlAsString];
        
        NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
        NSURLSessionDataTask *dataTask = [session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if (completionHandler) completionHandler(data, response, error);
        }];
        [dataTask resume];
        
    }];
    
}

#pragma mark - Player App

- (void)getVideoPlayerWithVideo:(Video *)video downloadInfo:(BOOL)isDownloaded withCompletionHandler:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completionHandler
{
    
    [ACSTokenManager accessToken:^(NSString *token, NSError *error){
        
        NSString *urlAsString = @"";
        
        if ([UIUtil isYes:video.isHighlight]){
            urlAsString = [NSString stringWithFormat:kGetPlayerForHighlight, kApiPlayerDomain, video.vId, kAppKey];
        } else {
            if ([ACStatusManager isUserSignedIn] == YES) {
                urlAsString = [NSString stringWithFormat:kGetPlayer, kApiPlayerDomain, video.vId, token];
            } else {
                urlAsString = [NSString stringWithFormat:kGetPlayerForGuest, kApiPlayerDomain, video.vId, kAppKey];
            }
            
        }
        
        if (isDownloaded) {
            urlAsString = [NSString stringWithFormat:@"%@&download=true", urlAsString];
        }

        NSLog(@"urlAsString: %@", urlAsString);
        NSURL *url = [NSURL withString:urlAsString];
        
        NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
        NSURLSessionDataTask *dataTask = [session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if (completionHandler) completionHandler(data, response, error);
        }];
        [dataTask resume];
        
    }];
    
}

- (void)getAudioPlayerWithVideo:(Video *)video WithCompletionHandler:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completionHandler{
    
    [ACSTokenManager accessToken:^(NSString *token, NSError *error){
        
        NSString *urlAsString;
        if ([ACStatusManager isUserSignedIn] == YES) {
            urlAsString = [NSString stringWithFormat:kGetDownloadAudioUrl, kApiPlayerDomain, video.vId, token];
        } else {
            urlAsString = [NSString stringWithFormat:kGetDownloadAudioUrlForGuest, kApiPlayerDomain, video.vId, kAppKey];
        }
        NSURL *url = [NSURL withString:urlAsString];
        
        NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
        NSURLSessionDataTask *dataTask = [session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if (completionHandler) completionHandler(data, response, error);
        }];
        [dataTask resume];
        
    }];
    
}

- (void)getLiveStreamAudioWithId:(NSString *)vId WithCompletionHandler:(void (^)(NSData *, NSURLResponse *, NSError *, NSString *))completionHandler{
    
    [ACSTokenManager accessToken:^(NSString *token, NSError *error){
        
        NSString *urlAsString;
        if ([ACStatusManager isUserSignedIn] == YES) {
            urlAsString = [NSString stringWithFormat:kGetDownloadAudioUrl, kApiPlayerDomain, vId, token];
        } else {
            urlAsString = [NSString stringWithFormat:kGetDownloadAudioUrlForGuest, kApiPlayerDomain, vId, kAppKey];
        }
        NSURL *url = [NSURL withString:urlAsString];
        
        NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
        NSURLSessionDataTask *dataTask = [session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if (completionHandler) {
                completionHandler(data, response, error, urlAsString);
            }
        }];
        [dataTask resume];
        
    }];
    
}


#pragma mark - Playback Source

- (PlaybackSource *)videoStreamPlaybackSourceFromRootDictionary:(NSDictionary *)dictionary {
    
    NSArray *results = [self filesArrayFromParsedDictionary:dictionary];
    PlaybackSource *playbackSource = [self videoStreamPlaybackSourceFromFilesArray:results];
    
    return playbackSource;
    
}

- (PlaybackSource *)audioStreamPlaybackSourceFromRootDictionary:(NSDictionary *)dictionary {
    
    NSArray *results = [self filesArrayFromParsedDictionary:dictionary];
    PlaybackSource *playbackSource = [self audioStreamPlaybackSourceFromFilesArray:results];
    
    return playbackSource;
    
}

- (NSArray *)streamPlaybackSourcesFromRootDictionary:(NSDictionary *)dictionary {
    NSArray *results = [self filesArrayFromParsedDictionary:dictionary];
    NSArray *sources = [self playbackSourcesFromFilesArray:results];
    NSMutableArray *needSources = [[NSMutableArray alloc] init];
    
    for (PlaybackSource *playbackSource in sources) {
        //go ahead and return if we find an HLS source
        if ([playbackSource.fileType isEqualToString:@"mp4"] || [playbackSource.fileType isEqualToString:@"m4a"]) {
            [needSources addObject:playbackSource];
        }
    }
    
    return needSources;
}

- (PlaybackSource *)videoStreamPlaybackSourceFromFilesArray:(NSArray *)files{
    
    NSArray *sources = [self playbackSourcesFromFilesArray:files];
    
    PlaybackSource *preferredSource;
    
    for (PlaybackSource *playbackSource in sources) {
        
        preferredSource = playbackSource;
        
        //go ahead and return if we find an HLS source
        if ([preferredSource.fileType isEqualToString:@"m3u8"] || [preferredSource.fileType isEqualToString:@"mp4"]) {
            
            return preferredSource;
            
        }
        
    }
    
    return preferredSource;
    
}

- (PlaybackSource *)audioStreamPlaybackSourceFromFilesArray:(NSArray *)files {
    NSArray *sources = [self playbackSourcesFromFilesArray:files];
    PlaybackSource *preferredSource;
    
    for (PlaybackSource *playbackSource in sources) {
        preferredSource = playbackSource;
        if ([preferredSource.fileType isEqualToString:@"m4a"]) {
            return preferredSource;
        }
    }
    
    return preferredSource;
}

- (NSArray *)playbackSourcesFromFilesArray:(NSArray *)files{
    
    NSMutableArray *sources = [NSMutableArray arrayWithCapacity:files.count];
    
    for (NSDictionary *fileDictionary in files) {
        
        PlaybackSource *playbackSource = [PlaybackSource new];
        
        for (NSString *key in fileDictionary) {
            
            if ([key isEqualToString:kAppKey_Url]) {
                playbackSource.urlString = [fileDictionary valueForKey:key];
            }
            
            if ([key isEqualToString:kAppKey_Name]) {
                playbackSource.fileType = fileDictionary[key];
            }
            
        }
        
        [sources addObject:playbackSource];
        
    }
    
    return sources;
    
}


#pragma mark - Data Extraction

- (NSString *)videoPlayerUrlFromJSON:(NSDictionary *)parsedObject
{
    
    NSArray *results = [self filesArrayFromParsedDictionary:parsedObject];
    
    NSString *url = @"";
    for (NSDictionary *groupDic in results) {
        for (NSString *key in groupDic) {
            if ([key isEqualToString:kAppKey_Url]) {
                url = [groupDic valueForKey:key];
            }
        }
    }
    
    return url;
}
- (NSString *)videoPlayerNameFromJSON:(NSDictionary *)parsedObject
{
    NSArray *results = [self filesArrayFromParsedDictionary:parsedObject];
    
    NSString *name = @"";
    for (NSDictionary *groupDic in results) {
        for (NSString *key in groupDic) {
            if ([key isEqualToString:kAppKey_Name]) {
                name = [groupDic valueForKey:key];
            }
        }
    }
    
    return name;
}
- (NSString *)videoDownloadUrlFromJSON:(NSDictionary *)parsedObject
{
    NSArray *results = [self filesArrayFromParsedDictionary:parsedObject];
    
    NSString *url = @"";
    for (NSDictionary *groupDic in results) {
        NSString *type = [groupDic dictValueForKey:kAppKey_Type];
        if ([type isEqualToString:@"mp4"])
            url = [groupDic dictValueForKey:kAppKey_Url];
    }
    
    return url;
}

- (NSString *)audioStreamCaptureUrlFromJSON:(NSDictionary *)parsedObject
{
    NSArray *results = [self filesArrayFromParsedDictionary:parsedObject];
    
    NSString *url = @"";
    for (NSDictionary *groupDic in results){
        
        for (NSString *key in groupDic) {
            if ([key isEqualToString:kAppKey_Url]) {
                url = [groupDic valueForKey:key];
            }
        }
        
    }
    
    return url;
}

- (NSString *)audioStreamUrlFromJSON:(NSDictionary *)parsedObject{
    
    NSArray *results = [self filesArrayFromParsedDictionary:parsedObject];
    
    NSString *url = @"";
    for (NSDictionary *groupDic in results) {
        
        NSString *type = [groupDic dictValueForKey:kAppKey_Name];
        if ([type isEqualToString:@"m3u8"]){
            url = [groupDic dictValueForKey:kAppKey_Url];
        }
        
    }
    
    return url;
    
}

- (NSString *)audioDownloadUrlFromJSON:(NSDictionary *)parsedObject{
    
    NSArray *results = [self filesArrayFromParsedDictionary:parsedObject];
    
    NSString *url = @"";
    for (NSDictionary *groupDic in results) {
        
        NSString *type = [groupDic dictValueForKey:kAppKey_Name];
        if ([type isEqualToString:@"m4a"]){
            url = [groupDic dictValueForKey:kAppKey_Url];
        }
        
    }
    
    return url;
    
}

- (NSArray *)filesArrayFromParsedDictionary:(NSDictionary *)dictionary{
    
    NSDictionary *response = [UIUtil dict:dictionary valueForKey:kAppKey_Response];
    NSDictionary *body = [UIUtil dict:response valueForKey:kAppKey_Body];
    NSArray *files = [UIUtil dict:body valueForKey:kAppKey_Files];
    return files;
    
}

- (NSString *)youTubeIdFromVideo:(id)data
{
    NSString *result = @"";
    
    if ([data count] > 0) {
        NSString *youtubeId = [UIUtil dict:data[0] valueForKey:@"youtube_id"];
        if (![youtubeId isEqualToString:@""] && youtubeId != nil) result = youtubeId;
    }
    
    return result;
}


#pragma mark - Guest App

- (void)loadGuests:(NSString *)videoId InPage:(NSNumber *)page{
    
    if (!page){
        page = [NSNumber numberWithInt:1];
    }
    
    NSString *urlAsString = [NSString stringWithFormat:kGetGuests, kApiDomain, kAppKey, videoId, page];
    NSURL *url = [NSURL withString:urlAsString];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if (error) {
            
            CLS_LOG(@"Failed: %@", error);
            
        } else {
            
            CLS_LOG(@"Success: %@", urlAsString);
            NSError *localError = nil;
            NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
            if (localError != nil) {
                CLS_LOG(@"Guest Parse Failed: %@", localError);
            }
            else {
                
                NSNumber *pages = (NSNumber *)[UIUtil dict:[UIUtil dict:parsedObject valueForKey:kAppKey_Pagination] valueForKey:kAppKey_Pages];
                NSNumber *nextPage = (NSNumber *)[UIUtil dict:[UIUtil dict:parsedObject valueForKey:kAppKey_Pagination] valueForKey:kAppKey_NextPage];
                
                if ([UIUtil hasNextPage:nextPage InPages:pages WithData:parsedObject]){
                    [self loadGuests:videoId InPage:nextPage];
                }
                
                [ACSPersistenceManager populateGuestsFromDictionary:parsedObject];
                
            }
        }
    }];
    
    [dataTask resume];
    
}


#pragma mark - Favorite App

- (void)syncFavoritesAfterRefreshed:(BOOL)isRefreshed InPage:(NSNumber *)page WithFavoritesInDB:(NSMutableArray *)favoritesInDB WithExistingFavorites:(NSMutableArray *)existingFavorites{
    
    // Prepare favorites in core data
    if (!favoritesInDB) {
        
        NSArray *fetchedObjects = [ACSPersistenceManager allFavorites];
        favoritesInDB = [[NSMutableArray alloc] initWithArray:fetchedObjects];
        
    }
    
    if (!page && !existingFavorites) {
        page = [NSNumber numberWithInt:1];
        existingFavorites = [[NSMutableArray alloc] init];
    }
    
    [ACSTokenManager accessToken:^(NSString *token, NSError *error){
        
        NSString *urlAsString = [NSString stringWithFormat:kGetFavorites, kApiDomain, [[NSUserDefaults standardUserDefaults] stringForKey:kSettingKey_ConsumerId], token, page];
        NSURL *url = [NSURL withString:urlAsString];
        
        NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
        NSURLSessionDataTask *dataTask = [session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if (error) {
                CLS_LOG(@"Failed: %@", error);
            }
            else {
                long statusCode = [((NSHTTPURLResponse *)response) statusCode];
                if (statusCode == 401 && !isRefreshed) {
                    
                    [ACSTokenManager refreshAccessToken:^(BOOL success, NSError *error) {
                        
                        if (success == YES) {
                            [self syncFavoritesAfterRefreshed:YES InPage:page WithFavoritesInDB:favoritesInDB WithExistingFavorites:existingFavorites];
                        } else if (error != nil) {
                            CLS_LOG(@"Access Token Refresh Failed: %@", error);
                        }
                        
                    }];
                    
                }
                else {
                    CLS_LOG(@"Success: %@", urlAsString);
                    NSError *localError = nil;
                    NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
                    if (localError != nil) {
                        CLS_LOG(@"Failed: %@", localError);
                    }
                    else {
                        
                        // Check if there's any next pages and continue to sync next one
                        NSNumber *pages = (NSNumber *)[UIUtil dict:[UIUtil dict:parsedObject valueForKey:kAppKey_Pagination] valueForKey:kAppKey_Pages];
                        NSNumber *nextPage = (NSNumber *)[UIUtil dict:[UIUtil dict:parsedObject valueForKey:kAppKey_Pagination] valueForKey:kAppKey_NextPage];
                        if ([UIUtil hasNextPage:nextPage InPages:pages WithData:parsedObject])
                            [self syncFavoritesAfterRefreshed:isRefreshed InPage:nextPage WithFavoritesInDB:favoritesInDB WithExistingFavorites:existingFavorites];
                        
                        // Check if it's the last page or not, then populate videos
                        [ACSPersistenceManager populateFavoritesFromDict:parsedObject WithFavoritesInDB:favoritesInDB WithExistingFavorites:existingFavorites IsLastPage:[UIUtil isLastPageInPages:pages WithData:parsedObject]];
                        
                        // Sync favorites that have been updated in offline
                        [self syncUpdatedFavoritesInOffline];
                        
                    }
                }
            }
        }];
        [dataTask resume];
        
    }];
    
}

- (void)loadVideoInFavoritesWithId:(NSString *)videoId{
    
    NSString *urlAsString = [NSString stringWithFormat:kGetVideoById, kApiDomain, kAppKey, videoId];
    NSURL *url = [NSURL withString:urlAsString];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            CLS_LOG(@"Failed: %@", error);
        } else {
            CLS_LOG(@"Success: %@", urlAsString);
            NSError *localError = nil;
            [ACSPersistenceManager populateVideoInFavoritesFromJSON:data error:&localError];
        }
    }];
    [dataTask resume];
}

- (void)syncUpdatedFavoritesInOffline{
    
    NSArray *addedFavorites = [ACSPersistenceManager addedFavorites];
    [self addFavorites:addedFavorites];
    
    NSArray *removedFavorites = [ACSPersistenceManager removedFavorites];
    [self removeFavorites:removedFavorites];
    
}

- (void)addFavorites:(NSArray *)favorites{
    
    for (Favorite *favorite in favorites) {
        // Favorite with video_id
        [self addFavorite:favorite];
    }
    
}

- (void)removeFavorites:(NSArray *)favorites{
    
    for (Favorite *favorite in favorites) {
        // Unfavorite with fId
        [self removeFavorite:favorite];
    }
    
}

- (void)addFavorite:(Favorite *)favorite{
    
    [ACSTokenManager accessToken:^(NSString *token, NSError *error){
        
        NSString *urlAsString = [NSString stringWithFormat:kPostFavorite, kApiDomain, [[NSUserDefaults standardUserDefaults] stringForKey:kSettingKey_ConsumerId], token, favorite.video_id];
        NSURL *url = [NSURL withString:urlAsString];
        
        NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
        NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
        [urlRequest setHTTPMethod:@"POST"];
        NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:urlRequest
                                                    completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                        
                                                        long statusCode = [((NSHTTPURLResponse *)response) statusCode];
                                                        if(error == nil && statusCode != 404)
                                                        {
                                                            
                                                            [ACSPersistenceManager updateFavorite:favorite WithData:data];
                                                            
                                                        }
                                                        
                                                    }];
        [dataTask resume];
        
    }];
    
}

- (void)removeFavorite:(Favorite *)favorite{
    
    [ACSPersistenceManager deleteFavorite:favorite];
    
    [ACSTokenManager accessToken:^(NSString *token, NSError *error){
        
        NSString *urlAsString = [NSString stringWithFormat:kDeleteFavorite, kApiDomain, [[NSUserDefaults standardUserDefaults] stringForKey:kSettingKey_ConsumerId], favorite.fId, token];
        NSURL *url = [NSURL withString:urlAsString];
        
        NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
        NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
        [urlRequest setHTTPMethod:@"DELETE"];
        NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:urlRequest
                                                    completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                        long statusCode = [((NSHTTPURLResponse *)response) statusCode];
                                                        if(error == nil && statusCode != 404)
                                                        {
                                                            
                                                        }
                                                    }];
        [dataTask resume];
        
    }];
    
}

- (void)favoriteVideo:(Video *)video{
    
    // Favorite video
    video.isFavorite = [NSNumber numberWithBool:YES];
    CLS_LOG(@"Favorite video: %@", video.title);
    
    // Add a new favorite
    __block Favorite *newFavorite = [ACSPersistenceManager newFavorite];
    newFavorite.fId = @"";
    newFavorite.video_id = video.vId;
    
    if (kFavoritesViaAPI == NO) {
        [[ACSPersistenceManager sharedInstance] saveContext];
    } else {
        [ACSTokenManager accessToken:^(NSString *token, NSError *error){
            
            // Favorite using REST App
            NSString *urlAsString = [NSString stringWithFormat:kPostFavorite, kApiDomain, [[NSUserDefaults standardUserDefaults] stringForKey:kSettingKey_ConsumerId], token, video.vId];
            NSURL *url = [NSURL withString:urlAsString];
            
            NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
            NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
            [urlRequest setHTTPMethod:@"POST"];
            NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:urlRequest
                                                        completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                            long statusCode = [((NSHTTPURLResponse *)response) statusCode];
                                                            if (statusCode == 401) {
                                                                
                                                                CLS_LOG(@"Favorite Video Unauthorized 401: %@", error);
                                                                
                                                            }
                                                            else if (error == nil && statusCode != 404)
                                                            {
                                                                
                                                                [ACSPersistenceManager updateFavorite:newFavorite WithData:data];
                                                                
                                                            }
                                                        }];
            [dataTask resume];
            
        }];
    }
    
}

- (void)unfavoriteVideo:(Video *)video{
    
    __block Favorite *favorite = [ACSPersistenceManager favoriteForVideo:video];
    
    [ACSPersistenceManager deleteFavorite:favorite];
    
    [ACSTokenManager accessToken:^(NSString *token, NSError *error){
        
        // Unfavorite using REST App
        NSString *urlAsString = [NSString stringWithFormat:kDeleteFavorite, kApiDomain, [[NSUserDefaults standardUserDefaults] stringForKey:kSettingKey_ConsumerId], favorite.fId, token];
        NSURL *url = [NSURL withString:urlAsString];
        
        NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
        NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
        [urlRequest setHTTPMethod:@"DELETE"];
        NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:urlRequest
                                                    completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                        
                                                        CLS_LOG(@"Unfavorite Video Error: %@", error);
                                                        
                                                    }];
        [dataTask resume];
        
    }];
    
}


#pragma mark - Search App

- (void)searchVideos:(NSString *)searchString InPage:(NSNumber *)page{
    
    // Search videos
    if (!page) page = [NSNumber numberWithInt:1];
    NSString *urlAsString = [NSString stringWithFormat:kGetSearchedVideos, kApiDomain, kAppKey, searchString, page];
    NSURL *url = [NSURL withString:urlAsString];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            CLS_LOG(@"Failed: %@", error);
        } else {
            CLS_LOG(@"Success: %@", urlAsString);
            NSError *localError = nil;
            NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
            if (localError != nil) {
                CLS_LOG(@"Failed: %@", localError);
            }
            else {
                // Check if there's any next pages and continue to sync next one
                NSNumber *pages = (NSNumber *)[UIUtil dict:[UIUtil dict:parsedObject valueForKey:kAppKey_Pagination] valueForKey:kAppKey_Pages];
                NSNumber *nextPage = (NSNumber *)[UIUtil dict:[UIUtil dict:parsedObject valueForKey:kAppKey_Pagination] valueForKey:kAppKey_NextPage];
                if ([UIUtil hasNextPage:nextPage InPages:pages WithData:parsedObject]){
                    [self searchVideos:searchString InPage:nextPage];
                }
                [ACSPersistenceManager populateVideosFromDict:parsedObject WithVideosInDB:nil WithExistingVideos:nil IsLastPage:NO addToPlaylist:nil];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"ResultsBySearchReturned" object:nil];
                
            }
        }
    }];
    
    [dataTask resume];
    
}

#pragma mark - App Settings App

- (void)syncAppSetting{
    
    // Get app setting
    NSString *urlAsString = [NSString stringWithFormat:kGetAppSetting, kApiDomain, kAppKey];
    NSURL *url = [NSURL withString:urlAsString];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if (error) {
            
            CLS_LOG(@"Failed: %@", error);
            
        } else {
            
            CLS_LOG(@"Success: %@", urlAsString);
            NSError *localError = nil;
            NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
            if (localError != nil) {
                CLS_LOG(@"Failed: %@", localError);
            }
            else {
                
                NSArray *results = [parsedObject valueForKey:kAppKey_Response];
                if (results.count > 0) {
                    
                    NSDictionary *settingDic = results[0];
                    NSString *subscribeUrl = [settingDic dictValueForKey:kAppKey_SubscribeUrl];
                    NSString *helpUrl = [settingDic dictValueForKey:kAppKey_HelpUrl];
                    NSString *noDownloadsMessage = [settingDic dictValueForKey:kAppKey_NoDownloadsMessage];
                    NSString *noFavoritesMessage = [settingDic dictValueForKey:kAppKey_NoFavoritesMessage];
                    NSString *shareSubject = [settingDic dictValueForKey:kAppKey_ShareSubject];
                    NSString *shareMessage = [settingDic dictValueForKey:kAppKey_ShareMessage];
                    if (subscribeUrl)
                        [[NSUserDefaults standardUserDefaults] setObject:subscribeUrl forKey:kSettingKey_SubscribeUrl];
                    if (helpUrl)
                        [[NSUserDefaults standardUserDefaults] setObject:helpUrl forKey:kSettingKey_HelpUrl];
                    if (noDownloadsMessage)
                        [[NSUserDefaults standardUserDefaults] setObject:noDownloadsMessage forKey:kSettingKey_NoDownloadsMessage];
                    if (noFavoritesMessage)
                        [[NSUserDefaults standardUserDefaults] setObject:noFavoritesMessage forKey:kSettingKey_NoFavoritesMessage];
                    if (shareSubject)
                        [[NSUserDefaults standardUserDefaults] setObject:shareSubject forKey:kSettingKey_ShareSubject];
                    if (shareMessage)
                        [[NSUserDefaults standardUserDefaults] setObject:shareMessage forKey:kSettingKey_ShareMessage];
                    
                    // Sync live pictures
                    [self syncLivePicturesWithArray:[settingDic dictValueForKey:kAppKey_Pictures]];
                    
                    //Svetlit Additional settings
                     [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:kSettingKey_DownloadsFeature];
                }
                
            }
            
        }
        
    }];
    
    [dataTask resume];
    
}

- (void)syncAppContent{
    
    // Get app content
    NSString *urlAsString = [NSString stringWithFormat:kGetAppContent, kApiDomain, kAppKey];
    NSURL *url = [NSURL withString:urlAsString];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if (error) {
            CLS_LOG(@"Failed: %@", error);
        } else {
            
            CLS_LOG(@"Success: %@", urlAsString);
            NSError *localError = nil;
            NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
            if (localError != nil) {
                CLS_LOG(@"Failed: %@", localError);
            }
            else {
                
                NSArray *results = [parsedObject valueForKey:kAppKey_Response];
                for (NSDictionary *contentDic in results) {
                    
                    NSString *title = [contentDic dictValueForKey:kAppKey_Title];
                    NSString *content = [contentDic dictValueForKey:kAppKey_Description];
                    if (title && content && [title isEqualToString:kSettingKey_Terms]){
                        [[NSUserDefaults standardUserDefaults] setObject:content forKey:kSettingKey_Terms];
                    }
                    else if (title && content && [title isEqualToString:kSettingKey_PrivacyPolicy]){
                        [[NSUserDefaults standardUserDefaults] setObject:content forKey:kSettingKey_PrivacyPolicy];
                    }
                    
                }
                
            }
            
        }
        
    }];
    
    [dataTask resume];
    
}

- (void)syncLivePicturesWithArray:(NSArray *)arrayLivePictures{
    
    if (arrayLivePictures) {
        
        for (NSDictionary *dictPicture in arrayLivePictures) {
            
            NSString *title = [dictPicture dictValueForKey:kAppKey_Title];
            NSString *url = [dictPicture dictValueForKey:kAppKey_Url];
            NSDate *updated = [[UIUtil dateFormatter] dateFromString:[dictPicture dictValueForKey:kAppKey_UpdatedAt]];
            
            if ([title isEqualToString:kSettingKey_NotSubscribed]){
                [self saveLivePictureSettingWithUrl:url WithDate:updated WithSettingKey:kSettingKey_NotSubscribed];
            }
            else if ([title isEqualToString:kSettingKey_OnAir]){
                [self saveLivePictureSettingWithUrl:url WithDate:updated WithSettingKey:kSettingKey_OnAir];
            }
            else if ([title isEqualToString:kSettingKey_OffAir]){
                [self saveLivePictureSettingWithUrl:url WithDate:updated WithSettingKey:kSettingKey_OffAir];
            }
            
        }
        
    }
    
}

- (void)saveLivePictureSettingWithUrl:(NSString *)url WithDate:(NSDate *)updated WithSettingKey:(NSString *)settingKey{
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:settingKey]) {
        
        NSDictionary *dict = [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:settingKey]];
        if ([(NSDate *)[dict dictValueForKey:kAppKey_UpdatedAt] compare:updated] != NSOrderedSame){
            [self saveLivePictureWithUrl:url WithDate:updated WithSettingKey:settingKey];
        }
        
    }
    else{
        [self saveLivePictureWithUrl:url WithDate:updated WithSettingKey:settingKey];
    }
    
}

- (void)saveLivePictureWithUrl:(NSString *)url WithDate:(NSDate *)updated WithSettingKey:(NSString *)settingKey{
    
    if (url == nil) {
        return;
    }
    if (updated == nil) {
        updated = [NSDate date];
    }
    
    NSData *dictData = [NSKeyedArchiver archivedDataWithRootObject:@{ kAppKey_Url : url, kAppKey_UpdatedAt : updated, kAppKey_DownloadedUrl : @"" }];
    [[NSUserDefaults standardUserDefaults] setObject:dictData forKey:settingKey];
    
    __block NSString *blockURL = url;
    __block NSDate *blockUpdated = updated;
    
    // Download pictures into the app
    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        if (data) {
            
            NSString *fileName = [[NSURL URLWithString:url] lastPathComponent];
            NSString *uniqueFileName = [NSString stringWithFormat:@"%@_%@", settingKey, fileName];
            NSString *localPath = [ACDownloadManager localDownloadPathForRelativePath:uniqueFileName];
            
            if ([data writeToFile:localPath atomically:YES]){
                
                NSData *dictData = [NSKeyedArchiver archivedDataWithRootObject:@{ kAppKey_Url : blockURL, kAppKey_UpdatedAt : blockUpdated, kAppKey_DownloadedUrl : uniqueFileName }];
                [[NSUserDefaults standardUserDefaults] setObject:dictData forKey:settingKey];
                
            }
            
        }
        
    }];
    
}

#pragma mark - Live Stream App

- (void)checkLiveStreamWithCompletionHandler:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completionHandler{
    
    NSString *urlAsString = [NSString stringWithFormat:kGetLiveStream, kApiDomain, kAppKey];
    NSURL *url = [NSURL withString:urlAsString];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (completionHandler) completionHandler(data, response, error);
    }];
    
    [dataTask resume];
    
}

- (void)getLiveStreamWithId:(NSString *)vId WithCompletionHandler:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completionHandler{
    
    NSString *urlAsString = [NSString stringWithFormat:kGetLiveStreamPlayer, kApiPlayerDomain, vId, kAppKey];
    NSURL *url = [NSURL withString:urlAsString];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (completionHandler) completionHandler(data, response, error);
    }];
    
    [dataTask resume];
    
}

#pragma mark - Notification App

- (void)syncNotificationsInPage:(NSNumber *)page WithNotificationsInDB:(NSMutableArray *)notificationsInDB WithExistingNotifications:(NSMutableArray *)existingNotifications{
    
    // Prepare notifications in core data
    if (!notificationsInDB) {
        NSArray *fetchedObjects = [ACSPersistenceManager allNotifications];
        notificationsInDB = [[NSMutableArray alloc] initWithArray:fetchedObjects];
    }
    
    // Load notifications
    if (!page && !existingNotifications) {
        page = [NSNumber numberWithInt:1];
        existingNotifications = [[NSMutableArray alloc] init];
    }
    NSString *urlAsString = [NSString stringWithFormat:kGetNotifications, kApiDomain, kAppKey, page];
    NSURL *url = [NSURL withString:urlAsString];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if (error) {
            
            CLS_LOG(@"Failed: %@", error);
            
        } else {
            
            CLS_LOG(@"Success: %@", urlAsString);
            NSError *localError = nil;
            NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
            if (localError != nil) {
                CLS_LOG(@"Failed: %@", localError);
            }
            else {
                
                // Check if there's any next pages and continue to sync next one
                NSNumber *pages = (NSNumber *)[UIUtil dict:[UIUtil dict:parsedObject valueForKey:kAppKey_Pagination] valueForKey:kAppKey_Pages];
                NSNumber *nextPage = (NSNumber *)[UIUtil dict:[UIUtil dict:parsedObject valueForKey:kAppKey_Pagination] valueForKey:kAppKey_NextPage];
                
                if ([UIUtil hasNextPage:nextPage InPages:pages WithData:parsedObject]){
                    [self syncNotificationsInPage:nextPage WithNotificationsInDB:notificationsInDB WithExistingNotifications:existingNotifications];
                }
                
                // Check if it's the last page or not, then populate videos
                [ACSPersistenceManager populateNotificationsFromDict:parsedObject WithNotificationsInDB:notificationsInDB WithExistingNotifications:existingNotifications IsLastPage:[UIUtil isLastPageInPages:pages WithData:parsedObject]];
                
            }
        }
        
    }];
    
    [dataTask resume];
    
}


#pragma mark - NSURLSession Delegate

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler{
    
    // Disable SSL certificate validation
    if([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]){
        
        if([challenge.protectionSpace.host isEqualToString:kApiDomain] ||
           [challenge.protectionSpace.host isEqualToString:kApiPlayerDomain] ||
           [challenge.protectionSpace.host isEqualToString:KOAuth_GetTokenDomain]){
            
            NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
            completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
            
        }
        
    }
    
}


#pragma mark - Singleton

+ (instancetype)sharedInstance {
    
    static RESTServiceController *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[[self class] alloc] init];
    });
    
    return _sharedInstance;
    
}

@end
