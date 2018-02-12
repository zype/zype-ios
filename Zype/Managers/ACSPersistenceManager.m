//
//  ACSCoreDataManager.m
//  acumiashow
//
//  Created by ZypeTech on 7/16/15.
//  Copyright (c) 2015 Zype. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <Crashlytics/Crashlytics.h>

#import "ACSPersistenceManager.h"
#import "RESTServiceController.h"
#import "ACSDataManager.h"
#import "ACDownloadManager.h"
#import "ACSPredicates.h"
#import "Notification.h"
#import "Favorite.h"
#import "Video.h"
#import "Guest.h"
#import "Playlist.h"
#import "ZObject.h"
#import "Pager.h"

@interface ACSPersistenceManager ()

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@end

@implementation ACSPersistenceManager


#pragma mark - Videos


+ (NSFetchRequest *)videoFetchRequestWithPredicate:(NSPredicate *)predicate{
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:kEntityVideo inManagedObjectContext:[ACSPersistenceManager sharedInstance].managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];
    return fetchRequest;
    
}


+ (NSFetchRequest *)guestFetchRequestWithPredicate:(NSPredicate *)predicate{
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:kEntityGuest inManagedObjectContext:[ACSPersistenceManager sharedInstance].managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];
    
    // Specify how the fetched objects should be sorted
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
    
    return fetchRequest;
    
}

+ (NSArray *)allVideos{
    
    NSError *LocalError = nil;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:kEntityVideo];
    NSArray *fetchedObjects = [[ACSPersistenceManager sharedInstance].managedObjectContext executeFetchRequest:request error:&LocalError];
    
    return fetchedObjects;
    
}

+ (NSArray *)allHighlights{
    
    NSError *LocalError = nil;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:kEntityVideo];
    request.predicate = [NSPredicate predicateWithFormat:@"isHighlight == %@", [NSNumber numberWithBool:YES]];
    NSArray *fetchedObjects = [[ACSPersistenceManager sharedInstance].managedObjectContext executeFetchRequest:request error:&LocalError];
    return fetchedObjects;
    
}

+ (NSArray *)allFavorites{
    
    NSError *cdError = nil;
    NSManagedObjectContext *context = [ACSPersistenceManager sharedInstance].managedObjectContext;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:kEntityFavorite];
    NSArray *fetchedObjects = [context executeFetchRequest:request error:&cdError];
    
    return fetchedObjects;
    
}

+ (NSArray *)allNotifications{
    
    NSError *LocalError = nil;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:kEntityNotification];
    NSArray *fetchedObjects = [[ACSPersistenceManager sharedInstance].managedObjectContext executeFetchRequest:request error:&LocalError];
    
    return fetchedObjects;
    
}

+ (NSArray *)videosFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate{
    
    NSError *LocalError = nil;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:kEntityVideo];
    request.predicate = [NSPredicate predicateWithFormat:@"published_at >= %@ && published_at <= %@", fromDate, toDate];
    NSArray *fetchedObjects = [[ACSPersistenceManager sharedInstance].managedObjectContext executeFetchRequest:request error:&LocalError];
    
    return fetchedObjects;
    
}

+ (NSArray *)videosWithDownloads{
    
    NSPredicate *predicate = [ACSPredicates fetchDownloadsPredicate];
    NSFetchRequest *fetchRequest = [ACSPersistenceManager videoFetchRequestWithPredicate:predicate];
    NSArray *results = [[ACSPersistenceManager sharedInstance].managedObjectContext executeFetchRequest:fetchRequest error:NULL];
    
    return results;
    
}

+ (NSArray *)downloadableVideosSortedByMostRecent{
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:kEntityVideo];
    request.predicate = [NSPredicate predicateWithFormat:@"duration > %@", @1];
    
    // Results should be in descending order of timeStamp.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:kAppKey_PublishedAt ascending:NO];
    [request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    NSArray *results = [[ACSPersistenceManager sharedInstance].managedObjectContext executeFetchRequest:request error:NULL];
    
    return results;
    
}

#pragma mark - ZObjects

+ (void)populateZObjectsFromDictionary:(NSDictionary *)dictionary {
    
    NSArray *results = [dictionary valueForKey:kAppKey_Response];
    CLS_LOG(@"Playlist Count %lu", (unsigned long)results.count);
    
    for (NSDictionary *zObjectDictionary in results) {
        [ACSPersistenceManager saveZObjectWithDictionary:zObjectDictionary];
    }
    
    if (results.count == 0) {
         [self resetPager];
    }
    
    [[ACSPersistenceManager sharedInstance] saveContext];
}

+ (void)resetZObjectChilds {
    // Check if the playlists exists in Core Data
    NSError *cdError = nil;
    NSManagedObjectContext *context = [ACSPersistenceManager sharedInstance].managedObjectContext;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:kEntityZObject];
//    request.predicate = [NSPredicate predicateWithFormat:@"parent_id = %@", playlistID];
    NSArray *fetchedObjects = [context executeFetchRequest:request error:&cdError];
    
    if (fetchedObjects.count > 0) {
        // If it's been updated, update the guest in Core Data
        CLS_LOG(@"deleting %li playlists", [fetchedObjects count]);
        for (ZObject *zObject in fetchedObjects) {
            [[ACSPersistenceManager sharedInstance].managedObjectContext deleteObject:zObject];
        }
    }
    
}

+ (void)saveZObjectWithDictionary:(NSDictionary *)dictionary {
    
    NSString *zId = [dictionary valueForKey:kAppKey_Id];
    ZObject *zObject = [ACSPersistenceManager zObjectWithID:zId];
    
    //clean up. remove all of the playlist child relationship
    
    if (zObject != nil) {
        
        // If it's been updated, update the guest in Core Data
        NSDate *dateUpdated = [[UIUtil dateFormatter] dateFromString:[dictionary valueForKey:kAppKey_UpdatedAt]];
        if ([zObject.updated_at compare:dateUpdated] != NSOrderedSame) {
            [ACSPersistenceManager updateZObject:zObject withDictionary:dictionary];
            CLS_LOG(@"Updated zobject: %@", zObject.title);
        }
        
    } else {
        // If it's new, insert it into Core Data
        zObject = [ACSPersistenceManager newZObject];
        [ACSPersistenceManager updateZObject:zObject withDictionary:dictionary];
        CLS_LOG(@"Added new playlist: %@", zObject.title);
    }
}

+ (ZObject *)zObjectWithID:(NSString *)zObjectID {
    
    // Check if the playlists exists in Core Data
    NSError *cdError = nil;
    NSManagedObjectContext *context = [ACSPersistenceManager sharedInstance].managedObjectContext;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:kEntityZObject];
    request.predicate = [NSPredicate predicateWithFormat:@"zId = %@", zObjectID];
    NSArray *fetchedObjects = [context executeFetchRequest:request error:&cdError];
    
    ZObject * zObject;
    if (fetchedObjects.count > 0) {
        // If it's been updated, update the guest in Core Data
        zObject = [fetchedObjects objectAtIndex:0];
    }
    
    return zObject;
}

+ (void)updateZObject:(ZObject *)zObject withDictionary:(NSDictionary *)dictionary{
    
    // Set values
    for (NSString *key in dictionary) {
        if ([dictionary valueForKey:key] != nil &&
            ![[dictionary valueForKey:key] isKindOfClass:[NSNull class]]) {
            
            if ([key isEqualToString:kAppKey_Id]){
                zObject.zId = [dictionary valueForKey:key];
            } else if ([key isEqualToString:kAppKey_Pictures]) {
                NSArray *array = [dictionary valueForKey:key];
                if ([array count] > 0) {
                    zObject.thumbnailUrl = [array[0] valueForKey:kAppKey_Url];
                }
            } else if ([zObject respondsToSelector:NSSelectorFromString(key)]) {
                if ([key stringContains:kAppKey_At])
                    [zObject setValue:[[UIUtil dateFormatter] dateFromString:[dictionary valueForKey:key]] forKey:key];
                else {
                    //hasKey is a check that prevents the app from crashing if unknown keys comes in
                    BOOL hasKey = [[zObject.entity propertiesByName] objectForKey:key] != nil;
                    if (hasKey)
                        [zObject setValue:[dictionary valueForKey:key] forKey:key];
                }
            }
        }
    }
}

+ (ZObject *)newZObject {
    
    ZObject *zObject = (ZObject *)[NSEntityDescription insertNewObjectForEntityForName:kEntityZObject inManagedObjectContext:[ACSPersistenceManager sharedInstance].managedObjectContext];
    if ([self getPager] == nil) {
        [self newPager];
    }
    return zObject;
}

+ (NSArray *)getZObjects {
    
    // Check if the playlists exists in Core Data
    NSError *cdError = nil;
    NSManagedObjectContext *context = [ACSPersistenceManager sharedInstance].managedObjectContext;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:kEntityZObject];
    request.sortDescriptors = [NSArray arrayWithObjects:[[NSSortDescriptor alloc] initWithKey:kAppKey_Priority ascending:YES], nil];
    NSArray *fetchedObjects = [context executeFetchRequest:request error:&cdError];
    
    return fetchedObjects;
    
}

+ (NSFetchRequest *)presentableObjectsFetchRequestWithPredicate:(NSPredicate *)predicate {
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:kEntityPresentableObject inManagedObjectContext:[ACSPersistenceManager sharedInstance].managedObjectContext];
    fetchRequest.includesSubentities = YES;
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];
    return fetchRequest;
    
}

#pragma mark - Pager

+ (Pager *)newPager {
    
    Pager *pager = (Pager *)[NSEntityDescription insertNewObjectForEntityForName:kEntityPager inManagedObjectContext:[ACSPersistenceManager sharedInstance].managedObjectContext];
    pager.type = @"Pager";
    
    return pager;
    
}

+ (NSArray *)zObjectsFromPager {
    return [self getZObjects];
}

+ (Pager *)getPager {
    
    NSError *cdError = nil;
    NSManagedObjectContext *context = [ACSPersistenceManager sharedInstance].managedObjectContext;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:kEntityPager];
    NSArray *fetchedObjects = [context executeFetchRequest:request error:&cdError];
    
    Pager *pager;
    
    if (fetchedObjects.count > 0) {
        // If it's been updated, update the guest in Core Data
        pager = [fetchedObjects objectAtIndex:0];
        
    }
    
    return pager;
    
}

+ (void)resetPager {
    // Check if the playlists exists in Core Data
    NSError *cdError = nil;
    NSManagedObjectContext *context = [ACSPersistenceManager sharedInstance].managedObjectContext;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:kEntityPager];
    NSArray *fetchedObjects = [context executeFetchRequest:request error:&cdError];
    
    if (fetchedObjects.count > 0) {
        // If it's been updated, update the guest in Core Data
        CLS_LOG(@"deleting %li playlists", [fetchedObjects count]);
        for (Pager *pager in fetchedObjects) {
            [[ACSPersistenceManager sharedInstance].managedObjectContext deleteObject:pager];
        }
    }
    
}

#pragma mark - Playlists

+ (Playlist *)newPlaylist{
    
    Playlist *playlist = (Playlist *)[NSEntityDescription insertNewObjectForEntityForName:kEntityPlaylist inManagedObjectContext:[ACSPersistenceManager sharedInstance].managedObjectContext];
    playlist.type = @"playlist";
    
    return playlist;
    
}

+ (Playlist *)playlistWithID:(NSString *)playlistID{
    
    // Check if the playlists exists in Core Data
    NSError *cdError = nil;
    NSManagedObjectContext *context = [ACSPersistenceManager sharedInstance].managedObjectContext;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:kEntityPlaylist];
    request.predicate = [NSPredicate predicateWithFormat:@"pId = %@", playlistID];
    NSArray *fetchedObjects = [context executeFetchRequest:request error:&cdError];
    
    Playlist *playlist;
    
    if (fetchedObjects.count > 0) {
        // If it's been updated, update the guest in Core Data
        playlist = [fetchedObjects objectAtIndex:0];
        
    }
    
    return playlist;
    
}

+ (NSArray *)getPlaylistsWithParentID:(NSString *)playlistID {
    
    // Check if the playlists exists in Core Data
    NSError *cdError = nil;
    NSManagedObjectContext *context = [ACSPersistenceManager sharedInstance].managedObjectContext;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:kEntityPlaylist];
    request.predicate = [NSPredicate predicateWithFormat:@"parent_id = %@", playlistID];
    NSArray *fetchedObjects = [context executeFetchRequest:request error:&cdError];
    
    return fetchedObjects;
    
    Playlist *playlist;
    
    if (fetchedObjects.count > 0) {
        // If it's been updated, update the guest in Core Data
        playlist = [fetchedObjects objectAtIndex:0];
        
    }
    
    return playlist;
    
}

+ (NSArray *)getVideosWithParentID:(NSString *)playlistID {
    
    // Check if the playlists exists in Core Data
    NSError *cdError = nil;
    NSManagedObjectContext *context = [ACSPersistenceManager sharedInstance].managedObjectContext;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:kEntityVideo];
    request.predicate = [NSPredicate predicateWithFormat:@"parent_id = %@", playlistID];
    NSArray *fetchedObjects = [context executeFetchRequest:request error:&cdError];
    
    return fetchedObjects;
    
    Playlist *playlist;
    
    if (fetchedObjects.count > 0) {
        // If it's been updated, update the guest in Core Data
        playlist = [fetchedObjects objectAtIndex:0];
        
    }
    
    return playlist;
    
}

+ (NSFetchRequest *)playlistFetchRequestWithPredicate:(NSPredicate *)predicate{
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:kEntityPlaylist inManagedObjectContext:[ACSPersistenceManager sharedInstance].managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];
    return fetchRequest;
    
}

+ (NSFetchRequest *)presentableObjectFetchRequestWithPredicate:(NSPredicate *)predicate{
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:kEntityPresentableObject inManagedObjectContext:[ACSPersistenceManager sharedInstance].managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];
    return fetchRequest;
    
}

+ (void)resetPlaylistChilds:(NSString *)playlistID{
    // Check if the playlists exists in Core Data
    NSError *cdError = nil;
    NSManagedObjectContext *context = [ACSPersistenceManager sharedInstance].managedObjectContext;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:kEntityPlaylist];
    request.predicate = [NSPredicate predicateWithFormat:@"parent_id = %@", playlistID];
    NSArray *fetchedObjects = [context executeFetchRequest:request error:&cdError];
    
    if (fetchedObjects.count > 0) {
        // If it's been updated, update the guest in Core Data
        CLS_LOG(@"deleting %li playlists", [fetchedObjects count]);
        for (Playlist *playlist in fetchedObjects) {
             [[ACSPersistenceManager sharedInstance].managedObjectContext deleteObject:playlist];
        }
    }

}

+ (void)populatePlaylistFromDictionary:(NSDictionary *)dictionary {
    NSDictionary *result = [dictionary valueForKey:kAppKey_Response];
    [ACSPersistenceManager savePlayliststWithDictionary:result];
    [[ACSPersistenceManager sharedInstance] saveContext];
}

+ (void)populatePlaylistsFromDictionary:(NSDictionary *)dictionary{
    
    NSArray *results = [dictionary valueForKey:kAppKey_Response];
    CLS_LOG(@"Playlist Count %lu", (unsigned long)results.count);
    
    for (NSDictionary *playlistDictionary in results) {
        [ACSPersistenceManager savePlayliststWithDictionary:playlistDictionary];
    }
    
    [[ACSPersistenceManager sharedInstance] saveContext];
}

+ (void)savePlayliststWithDictionary:(NSDictionary *)dictionary{
    
    NSString *pId = [dictionary valueForKey:kAppKey_Id];
    Playlist *playlist = [ACSPersistenceManager playlistWithID:pId];
    
    //clean up. remove all of the playlist child relationship
    
    
    if (playlist != nil) {
        
        // If it's been updated, update the guest in Core Data
        NSDate *dateUpdated = [[UIUtil dateFormatter] dateFromString:[dictionary valueForKey:kAppKey_UpdatedAt]];
        if ([playlist.updated_at compare:dateUpdated] != NSOrderedSame) {
            
            [ACSPersistenceManager updatePlaylist:playlist withDictionary:dictionary];
            CLS_LOG(@"Updated playlist: %@", playlist.title);
        }
        
    } else {
        
        // If it's new, insert it into Core Data
        playlist = [ACSPersistenceManager newPlaylist];
        [ACSPersistenceManager updatePlaylist:playlist withDictionary:dictionary];
        CLS_LOG(@"Added new playlist: %@", playlist.title);
    }
}

+ (void)updatePlaylist:(Playlist *)playlist withDictionary:(NSDictionary *)dictionary{
    
    BOOL customThumbnailImageIsLoaded = false;
    
    // Set values
    for (NSString *key in dictionary) {
        if ([dictionary valueForKey:key] != nil &&
            ![[dictionary valueForKey:key] isKindOfClass:[NSNull class]]) {
            
            if ([key isEqualToString:kAppKey_Id]){
                playlist.pId = [dictionary valueForKey:key];
            } else if ([key isEqualToString:kAppKey_Thumbnails]){
                //don't load regular thumbnail if mobile image is added
                if ( ! customThumbnailImageIsLoaded)
                playlist.thumbnailUrl = [UIUtil thumbnailUrlFromArray:[dictionary valueForKey:key]];
            } else if ([key isEqualToString:kAppKey_Images]){
                NSString *layout = dictionary[@"thumbnail_layout"];
                NSString *tempUrl = [UIUtil thumbnailUrlFromImageArray:[dictionary valueForKey:key] withLayout:layout];
                if ( ! [tempUrl isEqualToString:@""]){
                    playlist.thumbnailUrl = tempUrl;
                    customThumbnailImageIsLoaded = true;
                }
            } else if ([playlist respondsToSelector:NSSelectorFromString(key)]) {
                if ([key stringContains:kAppKey_At])
                    [playlist setValue:[[UIUtil dateFormatter] dateFromString:[dictionary valueForKey:key]] forKey:key];
                    
                else{
                    //hasKey is a check that prevents the app from crashing if unknown keys comes in
                    BOOL hasKey = [[playlist.entity propertiesByName] objectForKey:key] != nil;
                    if (hasKey)
                        [playlist setValue:[dictionary valueForKey:key] forKey:key];
                }
            }
        }
    }
    
}


#pragma mark PlaylistVideo


+ (PlaylistVideo *)newPlaylistVideo {
    PlaylistVideo *playlistVideo = (PlaylistVideo *)[NSEntityDescription insertNewObjectForEntityForName:kEntityPlaylistVideo inManagedObjectContext:[ACSPersistenceManager sharedInstance].managedObjectContext];
    
    return playlistVideo;
}



+ (NSArray *)playlistVideosFromPlaylistId:(NSString *)playlistId{
    
    NSError *LocalError = nil;
    NSFetchRequest *requestPlaylistVideo = [NSFetchRequest fetchRequestWithEntityName:kEntityPlaylistVideo];
    requestPlaylistVideo.predicate = [NSPredicate predicateWithFormat:@"playlist.pId == %@", playlistId];
    requestPlaylistVideo.sortDescriptors = [NSArray arrayWithObjects:[[NSSortDescriptor alloc] initWithKey:@"orderingValue" ascending:YES], nil];
    NSArray *playlistsVideos = [[ACSPersistenceManager sharedInstance].managedObjectContext executeFetchRequest:requestPlaylistVideo error:&LocalError];
    
    return playlistsVideos;
    
}

+ (NSArray *)playlistVideosFromParentPlaylistId:(NSString *)playlistId{
    
    NSError *LocalError = nil;
    NSFetchRequest *requestPlaylistVideo = [NSFetchRequest fetchRequestWithEntityName:kEntityPlaylistVideo];
    requestPlaylistVideo.predicate = [NSPredicate predicateWithFormat:@"playlist.pId == %@", playlistId];
    requestPlaylistVideo.sortDescriptors = [NSArray arrayWithObjects:[[NSSortDescriptor alloc] initWithKey:@"parent_id" ascending:YES], nil];
    NSArray *playlistsVideos = [[ACSPersistenceManager sharedInstance].managedObjectContext executeFetchRequest:requestPlaylistVideo error:&LocalError];
    
    return playlistsVideos;
    
}

#pragma mark - Guests

+ (NSArray *)guestsFromSearch:(NSString *)search{
    
    NSError *LocalError = nil;
    NSFetchRequest *requestGuest = [NSFetchRequest fetchRequestWithEntityName:kEntityGuest];
    requestGuest.predicate = [NSPredicate predicateWithFormat:@"title CONTAINS[cd] %@", search];
    NSArray *searchedGuests = [[ACSPersistenceManager sharedInstance].managedObjectContext executeFetchRequest:requestGuest error:&LocalError];
    
    return searchedGuests;
    
}

+ (Guest *)newGuest{
    
    Guest *guest = (Guest *)[NSEntityDescription insertNewObjectForEntityForName:kEntityGuest inManagedObjectContext:[ACSPersistenceManager sharedInstance].managedObjectContext];
    
    return guest;
    
}

+ (Guest *)guestWithID:(NSString *)guestID{
    
    // Check if the guest exists in Core Data
    NSError *cdError = nil;
    NSManagedObjectContext *context = [ACSPersistenceManager sharedInstance].managedObjectContext;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:kEntityGuest];
    request.predicate = [NSPredicate predicateWithFormat:@"gId = %@", guestID];
    NSArray *fetchedObjects = [context executeFetchRequest:request error:&cdError];
    
    Guest *guest;
    
    if (fetchedObjects.count > 0) {
        // If it's been updated, update the guest in Core Data
        guest = [fetchedObjects objectAtIndex:0];
        
    }
    
    return guest;
    
}

+ (void)populateGuestsFromDictionary:(NSDictionary *)dictionary{
    
    NSArray *results = [dictionary valueForKey:kAppKey_Response];
    CLS_LOG(@"Guest Count %lu", (unsigned long)results.count);
    
    for (NSDictionary *guestDictionary in results) {
        
        [ACSPersistenceManager saveGuestWithDictionary:guestDictionary];
        
    }
    
    [[ACSPersistenceManager sharedInstance] saveContext];
    
}

+ (void)saveGuestWithDictionary:(NSDictionary *)dictionary{
    
    NSString *gId = [dictionary valueForKey:kAppKey_Id];
    
    Guest *guest = [ACSPersistenceManager guestWithID:gId];
    
    if (guest != nil) {
        
        // If it's been updated, update the guest in Core Data
        NSDate *dateUpdated = [[UIUtil dateFormatter] dateFromString:[dictionary valueForKey:kAppKey_UpdatedAt]];
        if ([guest.updated_at compare:dateUpdated] != NSOrderedSame) {
            
            [ACSPersistenceManager updateGuest:guest withDictionary:dictionary];
            CLS_LOG(@"Updated guest: %@", guest.title);
            
        }
        
    }
    else {
        
        // If it's new, insert it into Core Data
        guest = [ACSPersistenceManager newGuest];
        [ACSPersistenceManager updateGuest:guest withDictionary:dictionary];
        CLS_LOG(@"Added new guest: %@", guest.title);
        
    }
    

    
}

+ (void)updateGuest:(Guest *)guest withDictionary:(NSDictionary *)dictionary{
    
    // Set values
    for (NSString *key in dictionary) {
        if ([dictionary valueForKey:key] != nil &&
            ![[dictionary valueForKey:key] isKindOfClass:[NSNull class]]) {
            
            if ([key isEqualToString:kAppKey_Id])
                guest.gId = [dictionary valueForKey:key];
            else if ([key isEqualToString:kAppKey_Description])
                guest.full_description = [dictionary valueForKey:key];
            else if ([key isEqualToString:kAppKey_Pictures]) {
                NSArray *array = [dictionary valueForKey:key];
                if ([array count] > 0) {
                    guest.thumbnailUrl = [array[0] valueForKey:kAppKey_Url];
                }
            }
            else if ([guest respondsToSelector:NSSelectorFromString(key)]) {
                if ([key stringContains:kAppKey_At])
                    [guest setValue:[[UIUtil dateFormatter] dateFromString:[dictionary valueForKey:key]] forKey:key];
                else
                    [guest setValue:[dictionary valueForKey:key] forKey:key];
            }
        }
    }
    
}


+ (Video *)newVideo{
    
    Video *video = (Video *)[NSEntityDescription insertNewObjectForEntityForName:kEntityVideo inManagedObjectContext:[ACSPersistenceManager sharedInstance].managedObjectContext];
    video.downloadTaskId = @-1;
    
    return video;
    
}

+ (Video *)nowPlayingVideo{
    
    Video *videoNowPlaying = nil;
    NSString *vId = [[NSUserDefaults standardUserDefaults] objectForKey:kSettingKey_VideoIdNowPlaying];
    NSError *cdError = nil;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:kEntityVideo];
    request.predicate = [NSPredicate predicateWithFormat:@"vId = %@", vId];
    NSArray *fetchedObjects = [[ACSPersistenceManager sharedInstance].managedObjectContext executeFetchRequest:request error:&cdError];
    if (fetchedObjects.count > 0) videoNowPlaying = fetchedObjects[0];
    
    return videoNowPlaying;
    
}

+ (Video *)mostRecentDownloadableVideo{
    
    Video *latestVideo;
    
    NSArray *results = [ACSPersistenceManager downloadableVideosSortedByMostRecent];
    if (results.count > 0) {
        latestVideo = [results objectAtIndex:0];
    }
    
    return latestVideo;
    
}

+ (Video *)videoWithID:(NSString *)videoID{
    
    NSError *cdError = nil;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:kEntityVideo];
    request.predicate = [NSPredicate predicateWithFormat:@"vId = %@", videoID];
    NSArray *fetchedObjects = [[ACSPersistenceManager sharedInstance].managedObjectContext executeFetchRequest:request error:&cdError];
    
    Video *video;
    
    if (fetchedObjects.count > 0) {
        
        video = fetchedObjects[0];
        
    }

    return video;
    
}

+ (Video *)videoForDownloadTaskID:(NSNumber *)downloadTaskID{
    
    NSError *Error = nil;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:kEntityVideo];
    request.predicate = [NSPredicate predicateWithFormat:@"downloadTaskId == %@", downloadTaskID];
    NSArray *fetchedResult = [[ACSPersistenceManager sharedInstance].managedObjectContext executeFetchRequest:request error:&Error];
    Video *video;
    
    if (fetchedResult.count > 0) {
        video = fetchedResult[0];
    }
    
    return video;
    
}

+ (void)deleteVideo:(Video *)video{
    
    [[ACSPersistenceManager sharedInstance].managedObjectContext deleteObject:video];
    
}

+ (void)resetVideosWithDownloadTaskID:(NSNumber *)downloadTaskID{
    
    NSError *Error = nil;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:kEntityVideo];
    request.predicate = [NSPredicate predicateWithFormat:@"downloadTaskId == %@", downloadTaskID];
    NSArray *fetchedResult = [[ACSPersistenceManager sharedInstance].managedObjectContext executeFetchRequest:request error:&Error];
    
    if (fetchedResult.count > 0) {
        
        for (Video *video in fetchedResult) {
            video.downloadTaskId = @-1;
        }
        
        [[ACSPersistenceManager sharedInstance] saveContext];
        
    }
    
}

+ (void)resetDownloadStatusOfVideo:(Video *)video{
    
    video.isDownload = @NO;
    video.downloadTaskId = @-1;
    [[ACSPersistenceManager sharedInstance] saveContext];
    
}


+ (void)populateVideosFromDict:(NSDictionary *)parsedObject WithVideosInDB:(NSArray *)videosInDB WithExistingVideos:(NSArray *)existingVideos IsLastPage:(BOOL)isLastPage addToPlaylist:(NSString*)playlistId{
    NSArray *results = [parsedObject valueForKey:kAppKey_Response];
    CLS_LOG(@"Count %lu", (unsigned long)results.count);
    
    NSNumber *currentPage = (NSNumber *)[UIUtil dict:[UIUtil dict:parsedObject valueForKey:kAppKey_Pagination] valueForKey:kAppKey_CurrentPage];
    
    NSNumber *perPage = (NSNumber *)[UIUtil dict:[UIUtil dict:parsedObject valueForKey:kAppKey_Pagination] valueForKey:@"per_page"];
    //calculate ordering index based on which page we are on at the moment
    NSUInteger index = [currentPage integerValue] * [perPage integerValue];
    
    for (NSDictionary *groupDic in results) {
        
        NSString *vId = [groupDic valueForKey:kAppKey_Id];
        Video *videoInDB = [ACSPersistenceManager videoWithID:vId];
        
        /*
        //hack - remove video from another playlist to preserve the order
        if (videoInDB != nil) {
            [ACSPersistenceManager deleteVideo:videoInDB];
            videoInDB = nil;
        }*/
        
        // If it's been updated, update the video in Core Data
        if (videoInDB != nil) {
            
            //add existing video to another Playlist
            if (playlistId){
                
                Playlist *vodPlaylist = [ACSPersistenceManager playlistWithID:playlistId];
                
                BOOL relationshipExists = false;
                
                for (PlaylistVideo* playlistVid in [videoInDB.playlistVideo allObjects]) {
                    if ([playlistVid.playlist isEqual: vodPlaylist]){
                       playlistVid.orderingValue = [NSNumber numberWithUnsignedInteger:index];
                        relationshipExists = true;
                        break;
                    }
                }
                
                if (!relationshipExists){
                    PlaylistVideo *newPlaylistVideo = [ACSPersistenceManager newPlaylistVideo];
                    newPlaylistVideo.playlist = vodPlaylist;
                    newPlaylistVideo.video = videoInDB;
                    newPlaylistVideo.orderingValue = [NSNumber numberWithUnsignedInteger:index];
                }
                
            }
            
            NSDate *dateUpdated = [[UIUtil dateFormatter] dateFromString:[groupDic valueForKey:kAppKey_UpdatedAt]];
            
            if ([videoInDB.updated_at compare:dateUpdated] != NSOrderedSame) {
                
                [ACSPersistenceManager saveVideoInDB:videoInDB WithData:groupDic];
                CLS_LOG(@"Updated video: %@", videoInDB.title);
                
            }
            
            // If it exists, add it in existing videos array to get the removed videos in server
            if (videosInDB && existingVideos) {
                
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"vId = %@", vId];
                NSArray *results = [videosInDB filteredArrayUsingPredicate:predicate];
                
                if (results.count > 0){
                    
                    NSMutableArray *videos = [NSMutableArray arrayWithArray:existingVideos];
                    [videos addObject:results[0]];
                    existingVideos = videos;
                    
                }
                
            }
            
        }else {
            
            // If it's new, insert it into Core Data
            Video *newVideo = [ACSPersistenceManager newVideo];
            [ACSPersistenceManager saveVideoInDB:newVideo WithData:groupDic];
            
            CLS_LOG(@"Added new video: %@", newVideo.title);
            //add new video to Playlist
            if (playlistId){
                Playlist *vodPlaylist = [ACSPersistenceManager playlistWithID:playlistId];
                PlaylistVideo *newPlaylistVideo = [ACSPersistenceManager newPlaylistVideo];
               
                newPlaylistVideo.playlist = vodPlaylist;
                newPlaylistVideo.video = newVideo;
                
                newPlaylistVideo.orderingValue = [NSNumber numberWithUnsignedInteger:index];
            }
           
        }
        
        index++;
    }
    

    // Remove videos that have been removed in server
    if (isLastPage == YES && videosInDB != nil && existingVideos != nil) {
        
        NSMutableArray *videos = [NSMutableArray arrayWithArray:videosInDB];
        [videos removeObjectsInArray:existingVideos];
        NSArray *deletedVideosInDB = [videos copy];
        
        for (Video *video in deletedVideosInDB) {
            
            CLS_LOG(@"Removed video in server: %@", video.title);
            if (video.isDownload.boolValue == YES) {
                
                if ([ACSDataManager audioDownloadExistsForVideo:video] == YES) {
                    
                    NSString *localAudioPath = [ACDownloadManager localAudioPathForDownloadForVideo:video];
                    NSURL *urlAudio = [NSURL URLWithString:localAudioPath];
                    NSFileManager *fileManager = [NSFileManager defaultManager];
                    NSError *error = nil;
                    [fileManager removeItemAtPath:[urlAudio path] error:&error];
                    
                    if (error){
                        CLS_LOG(@"Unable to remove audio file. %@, %@", error, error.userInfo);
                    }else{
                        CLS_LOG(@"Deleted downloaded audio file of video: %@", video.title);
                    }
                    
                }
                
                if ([ACSDataManager videoDownloadExistsForVideo:video] == YES) {
                    
                    NSString *localVideoPath = [ACDownloadManager localPathForDownloadedVideo:video];
                    NSURL *urlVideo = [NSURL URLWithString:localVideoPath];
                    NSFileManager *fileManager = [NSFileManager defaultManager];
                    NSError *error = nil;
                    [fileManager removeItemAtPath:[urlVideo path] error:&error];
                    
                    if (error){
                        CLS_LOG(@"Unable to remove video file. %@, %@", error, error.userInfo);
                    }else{
                        CLS_LOG(@"Deleted downloaded video file of video: %@", video.title);
                    }
                    
                }
                
            }
            
            [ACSPersistenceManager deleteVideo:video];
            
        }
        
    }
    
    [[ACSPersistenceManager sharedInstance] saveContext];
    
}

+ (void)saveVideoInDB:(Video *)video WithData:(NSDictionary *)dictData{
    
    // Set values
    for (NSString *key in dictData) {
        
        if ([dictData valueForKey:key] != nil && ![[dictData valueForKey:key] isKindOfClass:[NSNull class]]) {
            
            if ([key isEqualToString:kAppKey_Id]){
                video.vId = [dictData valueForKey:key];
            }else if ([key isEqualToString:kAppKey_Description]){
                video.full_description = [dictData valueForKey:key];
            }else if ([key isEqualToString:kAppKey_Thumbnails]){
                video.thumbnailUrl = [UIUtil thumbnailUrlFromArray:[dictData valueForKey:key]];
            }else if ([video respondsToSelector:NSSelectorFromString(key)]) {
                
                if ([key stringContains:kAppKey_At]){
                    [video setValue:[[UIUtil dateFormatter] dateFromString:[dictData valueForKey:key]] forKey:key];
                }
                else if ([key stringContains:kAppKey_Keywords]) {
                    
                    [video setValue:[dictData valueForKey:key] forKey:key];
                    NSString *keywordsString = @"";
                    for (NSString *keyword in [dictData valueForKey:key]) {
                        keywordsString = [keywordsString stringByAppendingString:[NSString stringWithFormat:@"%@, ", keyword]];
                    }
                    video.keywordsString = keywordsString;
                    
                }
                else if ([key stringContains:kAppKey_ZobjectIds]) {
                    
                    [video setValue:[dictData valueForKey:key] forKey:key];
                    NSString *zobjectString = @"";
                    for (NSString *zobject in [dictData valueForKey:key]) {
                        zobjectString = [zobjectString stringByAppendingString:[NSString stringWithFormat:@"%@, ", zobject]];
                    }
                    video.zobjectString = zobjectString;
                    
                }
                else{
                    [video setValue:[dictData valueForKey:key] forKey:key];
                }
                
            }
            
        }
        
    }
    
    // Check highlight videos
    for (NSDictionary *dict in video.categories) {
        
        NSString *category = [dict valueForKey:kAppKey_Title];
        
        if ([category isEqualToString:@"Highlight"]) {
            
            NSArray *statusArray = [dict valueForKey:kAppKey_Value];
            for (NSString *value in statusArray) {
                if ([value isEqualToString:@"true"]) {
                    video.isHighlight = @YES;
                }
            }
            
            break;
            
        }
        
    }

    // Save context
    [[ACSPersistenceManager sharedInstance] saveContext];
    
    
}


#pragma mark - Favorites

+ (Favorite *)newFavorite{
    
    Favorite * favorite = [NSEntityDescription insertNewObjectForEntityForName:kEntityFavorite
                                              inManagedObjectContext:[ACSPersistenceManager sharedInstance].managedObjectContext];
    
    return favorite;
    
}

+ (id)favoriteWithID:(NSString *)favoriteID{
    
    // Check if the favorite exists in Core Data
    NSError *fError = nil;
    NSFetchRequest *requestFavorites = [NSFetchRequest fetchRequestWithEntityName:kEntityFavorite];
    requestFavorites.predicate = [NSPredicate predicateWithFormat:@"fId = %@", favoriteID];
    NSArray *fetchedFavorites = [[ACSPersistenceManager sharedInstance].managedObjectContext executeFetchRequest:requestFavorites error:&fError];
    
    Favorite *favorite;
    
    if (fetchedFavorites.count > 0) {
        // If it exists, add it in existing favorites to get the removed favorite in server
        favorite = fetchedFavorites[0];
    }
    
    return favorite;
    
}

+ (Favorite *)favoriteForVideo:(Video *)video{
    
    // Get fId and set isRemoved as YES
    NSError *cdError = nil;
    NSFetchRequest *favoriteRequest = [NSFetchRequest fetchRequestWithEntityName:kEntityFavorite];
    favoriteRequest.predicate = [NSPredicate predicateWithFormat:@"video_id == %@", video.vId];
    
    Favorite *favorite;

    NSArray *favorites = [[ACSPersistenceManager sharedInstance].managedObjectContext executeFetchRequest:favoriteRequest error:&cdError];
    if (favorites.count > 0) {
        favorite = [favorites objectAtIndex:0];
    }

    return favorite;
    
}

+ (NSArray *)addedFavorites{
    
    NSError *cdError = nil;
    NSManagedObjectContext *context = [ACSPersistenceManager sharedInstance].managedObjectContext;
    
    NSFetchRequest *requestAdded = [NSFetchRequest fetchRequestWithEntityName:kEntityFavorite];
    requestAdded.predicate = [NSPredicate predicateWithFormat:@"fId == %@", @""];
    NSArray *addedFavorites = [context executeFetchRequest:requestAdded error:&cdError];
    
    return addedFavorites;
    
}

+ (NSArray *)removedFavorites{
    
    NSError *cdError = nil;
    NSManagedObjectContext *context = [ACSPersistenceManager sharedInstance].managedObjectContext;
    
    NSFetchRequest *requestRemoved = [NSFetchRequest fetchRequestWithEntityName:kEntityFavorite];
    requestRemoved.predicate = [NSPredicate predicateWithFormat:@"isRemoved == %@", [NSNumber numberWithBool:YES]];
    NSArray *removedFavorites = [context executeFetchRequest:requestRemoved error:&cdError];
    
    return removedFavorites;
    
}

+ (void)favoriteVideo:(Video *)video{

    if (video.isFavorite.boolValue == NO) {
        
        video.isFavorite = @YES;
        CLS_LOG(@"Favorited video: %@", video.title);
        
    }
    
}

+ (void)unfavoriteVideo:(Video *)video{
    
    if (video.isFavorite.boolValue == YES) {
        
        video.isFavorite = @NO;
        CLS_LOG(@"Favorited video: %@", video.title);
        
        NSString *fId = @"";
        Favorite *favorite = [ACSPersistenceManager favoriteForVideo:video];
        
        if (favorite != nil) {
            
            favorite.isRemoved = [NSNumber numberWithBool:YES];
            fId = favorite.fId;
            
        }
        
        [[ACSPersistenceManager sharedInstance] saveContext];
        
    }

}

+ (void)deleteFavorite:(Favorite *)favorite{
    
    Video *video = [ACSPersistenceManager videoWithID:favorite.video_id];
    
    if (video != nil) {
        [ACSPersistenceManager unfavoriteVideo:video];
    }
    
    [[ACSPersistenceManager sharedInstance].managedObjectContext deleteObject:favorite];
    
}

+ (void)resetFavorites{
    
    // Delete favorites
    NSManagedObjectContext *context = [ACSPersistenceManager sharedInstance].managedObjectContext;
    NSError *vError = nil;
    NSFetchRequest *requestVideo = [NSFetchRequest fetchRequestWithEntityName:kEntityVideo];
    requestVideo.predicate = [NSPredicate predicateWithFormat:@"isFavorite == %@", [NSNumber numberWithBool:YES]];
    NSArray *fetchedVideos = [context executeFetchRequest:requestVideo error:&vError];
    for (Video *video in fetchedVideos) {
        video.isFavorite = [NSNumber numberWithBool:NO];
    }
    NSError *fError = nil;
    NSFetchRequest *requestFavorite = [NSFetchRequest fetchRequestWithEntityName:kEntityFavorite];
    NSArray *fetchedFavorites = [context executeFetchRequest:requestFavorite error:&fError];
    for (Favorite *favorite in fetchedFavorites) {
        [context deleteObject:favorite];
    }
    [[ACSPersistenceManager sharedInstance] saveContext];
    
}


+ (void)populateFavoritesFromDict:(NSDictionary *)parsedObject WithFavoritesInDB:(NSMutableArray *)favoritesInDB WithExistingFavorites:(NSMutableArray *)existingFavorites IsLastPage:(BOOL)isLastPage{
    
    NSArray *results = [parsedObject valueForKey:kAppKey_Response];
    CLS_LOG(@"Count %lu", (unsigned long)results.count);
    NSManagedObjectContext *context = [ACSPersistenceManager sharedInstance].managedObjectContext;
    
    // Add favorite and video using REST API
    for (NSDictionary *groupDic in results) {
        NSString *fId = [groupDic valueForKey:kAppKey_Id];
        NSString *videoIdInFavorite = [groupDic valueForKey:kAppKey_VideoId];
        
        // Check if the favorite exists in Core Data
        Favorite *favoriteInDB = [ACSPersistenceManager favoriteWithID:fId];
        if (favoriteInDB != nil) {
            
            // If it exists, add it in existing favorites to get the removed favorite in server
            [existingFavorites addObject:favoriteInDB];
            
        }
        else {
            
            // If it's new, insert it into Core Data
            Favorite *newFavorite = (Favorite *)[NSEntityDescription insertNewObjectForEntityForName:kEntityFavorite inManagedObjectContext:context];
            
            [ACSPersistenceManager saveFavoriteInDB:newFavorite WithData:groupDic];
            CLS_LOG(@"Added new favorite: %@", newFavorite.video_id);
            
        }
        
        // Check if the video exists in Core Data
        Video *localVideo = [ACSPersistenceManager videoWithID:videoIdInFavorite];
        if (localVideo != nil) {
            
            [ACSPersistenceManager favoriteVideo:localVideo];
            
        }
        else {
            // Load a new favorite video
            [[RESTServiceController sharedInstance] loadVideoInFavoritesWithId:videoIdInFavorite];
        }
        
    }
    
    [[ACSPersistenceManager sharedInstance] saveContext];
    
    // Remove favorites that have been removed in server
    if (isLastPage && favoritesInDB && existingFavorites) {
        [favoritesInDB removeObjectsInArray:existingFavorites];
        for (Favorite *favorite in favoritesInDB) {
            
            // Delete favorite in Core Data
            [ACSPersistenceManager deleteFavorite:favorite];
            
        }
        
        [[ACSPersistenceManager sharedInstance] saveContext];
        
    }
    
}


+ (void)populateVideoInFavoritesFromJSON:(NSData *)data error:(NSError **)error{
    
    NSError *localError = nil;
    NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
    if (localError != nil) {
        *error = localError;
        return;
    }
    
    NSArray *results = [parsedObject valueForKey:kAppKey_Response];
    CLS_LOG(@"Count %lu", (unsigned long)results.count);
    
    for (NSDictionary *groupDic in results) {
        
        Video *newVideo = [ACSPersistenceManager newVideo];
        newVideo.isFavorite = [NSNumber numberWithBool:YES];
        [ACSPersistenceManager saveVideoInDB:newVideo WithData:groupDic];
        CLS_LOG(@"Added new favorite video: %@", newVideo.title);
        
    }
    
}


+ (void)updateFavorite:(Favorite *)favorite WithData:(NSData *)data{
    
    NSError *localError = nil;
    NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
    if (localError != nil) {
        return;
    }
    
    [ACSPersistenceManager saveFavoriteInDB:favorite WithData:[UIUtil dict:parsedObject valueForKey:kAppKey_Response]];
    
}

+ (void)saveFavoriteInDB:(Favorite *)favorite WithData:(NSDictionary *)dictData{
    
    // Set values
    for (NSString *key in dictData) {
        if ([dictData valueForKey:key] != nil && ![[dictData valueForKey:key] isKindOfClass:[NSNull class]]) {
            
            if ([key isEqualToString:kAppKey_Id]){
                
                favorite.fId = [dictData valueForKey:key];
                
            }else if ([favorite respondsToSelector:NSSelectorFromString(key)]) {
                
                if ([key stringContains:kAppKey_At]){
                    [favorite setValue:[[UIUtil dateFormatter] dateFromString:[dictData valueForKey:key]] forKey:key];
                }else{
                    [favorite setValue:[dictData valueForKey:key] forKey:key];
                }
                
            }
        }
    }
    
    // Save context
    [[ACSPersistenceManager sharedInstance] saveContext];
    
}



#pragma mark - User Defaults

+ (void)resetUserSettings{
    
    // Reset settings
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:kSettingKey_ConsumerId];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:kSettingKey_VideoIdNowPlaying];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kSettingKey_SignInStatus];
    
}


#pragma mark - Notifications

+ (Notification *)notificationWithID:(NSString *)notificationID{
    
    // Check if the notification exists in Core Data
    NSError *cdError = nil;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:kEntityNotification];
    request.predicate = [NSPredicate predicateWithFormat:@"nId = %@", notificationID];
    NSArray *fetchedObjects = [[ACSPersistenceManager sharedInstance].managedObjectContext executeFetchRequest:request error:&cdError];
    
    Notification *notification;
    
    if (fetchedObjects.count > 0) {
        // If it's been updated, update the notification in Core Data
        notification = [fetchedObjects objectAtIndex:0];
        
    }
    
    return notification;
    
}

- (void)removeExpiredNotifications{
    
    NSManagedObjectContext *context = self.managedObjectContext;
    NSError *error = nil;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:kEntityNotification];
    request.predicate = [NSPredicate predicateWithFormat:@"time < %@", [NSDate date]];
    NSArray *expiredNotifications = [context executeFetchRequest:request error:&error];
    
    for (Notification *notification in expiredNotifications) {
        [context deleteObject:notification];
    }
    
}

- (NSArray *)cancelRemovedNotifications{
    
    NSManagedObjectContext *context = self.managedObjectContext;
    NSError *error = nil;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:kEntityNotification];
    request.predicate = [NSPredicate predicateWithFormat:@"status == %@", kNotificationStatus_Removed];
    
    // Prepare candidates to cancel
    NSArray *removedNotifications = [context executeFetchRequest:request error:&error];
    NSArray *scheduledNotifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
    NSMutableArray *candidatesToCancel = [[NSMutableArray alloc] init];
    for (Notification *removedNotification in removedNotifications) {
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"fireDate == %@", removedNotification.time];
        NSArray *results = [scheduledNotifications filteredArrayUsingPredicate:predicate];
        if (results.count > 0) [candidatesToCancel addObject:results[0]];
        
    }
    // Remove notifications from core data
    for (Notification *removedNotification in removedNotifications) {
        
        [context deleteObject:removedNotification];
        CLS_LOG(@"Removed notification: %@", removedNotification.time);
        
    }
    
    return [candidatesToCancel copy];
    
}

- (NSArray *)updatedNotifications{
    
    NSManagedObjectContext *context = self.managedObjectContext;
    NSError *error = nil;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:kEntityNotification];
    request.predicate = [NSPredicate predicateWithFormat:@"status == %@", kNotificationStatus_Updated];
    
    // Prepare array of notifications to be cancelled
    NSArray *updatedNotifications = [context executeFetchRequest:request error:&error];
    
    return updatedNotifications;
    
}

- (NSArray *)newNotifications{
    
    NSManagedObjectContext *context = self.managedObjectContext;
    NSError *error = nil;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:kEntityNotification];
    request.predicate = [NSPredicate predicateWithFormat:@"status == %@", kNotificationStatus_New];
    request.sortDescriptors = [NSArray arrayWithObjects:[[NSSortDescriptor alloc] initWithKey:kAppKey_Time ascending:YES], nil];
    
    NSArray *notifications = [context executeFetchRequest:request error:&error];
    
    return notifications;
    
}

- (void)setScheduledNotification:(Notification *)notification{
    
    notification.scheduled = notification.time;
    notification.status = kNotificationStatus_Scheduled;
    CLS_LOG(@"Scheduled notification: %@", notification.time);
    
}

+ (void)populateNotificationsFromDict:(NSDictionary *)parsedObject WithNotificationsInDB:(NSMutableArray *)notificationsInDB WithExistingNotifications:(NSMutableArray *)existingNotifications IsLastPage:(BOOL)isLastPage{
    
    NSArray *results = [parsedObject valueForKey:kAppKey_Response];
    CLS_LOG(@"Count %lu", (unsigned long)results.count);
    NSManagedObjectContext *context = [ACSPersistenceManager sharedInstance].managedObjectContext;
    
    for (NSDictionary *groupDic in results) {
        NSString *nId = [groupDic valueForKey:kAppKey_Id];
        
        // Check if the notification exists in Core Data
        
        Notification *notificationInDB = [ACSPersistenceManager notificationWithID:nId];
        
        if (notificationInDB != nil) {
            
            // If it's been updated, update the notification in Core Data
            NSDate *dateUpdated = [[UIUtil dateFormatter] dateFromString:[groupDic valueForKey:kAppKey_UpdatedAt]];
            if ([notificationInDB.updated_at compare:dateUpdated] != NSOrderedSame) {
                
                notificationInDB.status = kNotificationStatus_Updated;
                [ACSPersistenceManager saveNotificationInDB:notificationInDB WithData:groupDic];
                
                CLS_LOG(@"Updated video: %@", notificationInDB.title);
                
            }
            
            // If it exists, add it in existing notification array to get the removed notifications in server
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"nId = %@", nId];
            NSArray *results = [notificationsInDB filteredArrayUsingPredicate:predicate];
            if (results.count > 0) [existingNotifications addObject:results[0]];
            
        }
        else {
            
            // If it's new and future event, insert it into Core Data
            NSDate *time = [[UIUtil dateFormatter] dateFromString:[groupDic valueForKey:kAppKey_Time]];
            if ([time compare:[NSDate date]] == NSOrderedDescending) {
                
                Notification *newNotification = (Notification *)[NSEntityDescription insertNewObjectForEntityForName:kEntityNotification inManagedObjectContext:context];
                newNotification.status = kNotificationStatus_New;
                [ACSPersistenceManager saveNotificationInDB:newNotification WithData:groupDic];
                
                CLS_LOG(@"Added new notification: %@", newNotification.title);
                
            }
            
        }
    }
    
    // Remove notifications that have been removed in server
    if (isLastPage && notificationsInDB && existingNotifications) {
        
        [notificationsInDB removeObjectsInArray:existingNotifications];
        for (Notification *notification in notificationsInDB) {
            
            CLS_LOG(@"Removed notification in server: %@", notification.title);
            
            notification.status = kNotificationStatus_Removed;
            
        }
        
        [[ACSPersistenceManager sharedInstance] saveContext];
        
    }
    
}

+ (void)saveNotificationInDB:(Notification *)notification WithData:(NSDictionary *)dictData{
    
    // Set values
    for (NSString *key in dictData) {
        
        if ([dictData valueForKey:key] != nil && ![[dictData valueForKey:key] isKindOfClass:[NSNull class]]) {
            
            if ([key isEqualToString:kAppKey_Id]){
                
                notification.nId = [dictData valueForKey:key];
                
            }
            else if ([key isEqualToString:kAppKey_Description]){
                
                notification.full_description = [dictData valueForKey:key];
                
            }
            else if ([notification respondsToSelector:NSSelectorFromString(key)]) {
                
                if ([key stringContains:kAppKey_At]){
                    [notification setValue:[[UIUtil dateFormatter] dateFromString:[dictData valueForKey:key]] forKey:key];
                }
                else if ([key isEqualToString:kAppKey_Time]){
                    [notification setValue:[[UIUtil dateFormatter] dateFromString:[dictData valueForKey:key]] forKey:key];
                }
                else{
                    [notification setValue:[dictData valueForKey:key] forKey:key];
                }
                
            }
        }
    }
    
    // Save context
    [[ACSPersistenceManager sharedInstance] saveContext];
    
}


#pragma mark - Core Data stack

- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    
}

- (NSManagedObjectModel *)managedObjectModel {
    
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"ZypeDB" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
    
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"ZypeDB.sqlite"];
    NSError *error = nil;

    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:@{NSMigratePersistentStoresAutomaticallyOption:@YES} error:&error]) {
        
        //recreate database if Data Model has changed
        //Note:this will remove all Core Data that has been saved on device
        [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil];
        CLS_LOG(@"Deleted old database");
        
        //TODO: also need to remove any downloaded videos
        
        if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
            CLS_LOG(@"2nd unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
        
    }
    
    return _persistentStoreCoordinator;
    
}


- (NSManagedObjectContext *)managedObjectContext {
    
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
    
}


#pragma mark - Core Data Saving support

- (void)saveContext {
    
    if ([NSThread isMainThread]) {
        
        [self saveContextFromMainThread];
        
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self saveContextFromMainThread];
            
        });
    }
    
}

- (void)saveContextFromMainThread{
    
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            
            //TODO: Replace this implementation with code to handle the error appropriately.
            CLS_LOG(@"Unresolved error %@, %@", error, [error userInfo]);
#if TARGET_IPHONE_SIMULATOR
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            abort();
#endif
            
        }
    }
    
}


#pragma mark - Singleton

+ (instancetype)sharedInstance {
    
    static ACSPersistenceManager *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[[self class] alloc] init];
    });
    
    return _sharedInstance;
}




@end
