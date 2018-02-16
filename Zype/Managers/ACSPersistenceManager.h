//
//  ACSCoreDataManager.h
//  acumiashow
//
//  Created by ZypeTech on 7/16/15.
//  Copyright (c) 2015 Zype. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Notification, Video, Guest, Favorite, Playlist, PlaylistVideo, Pager;

@interface ACSPersistenceManager : NSObject

+ (NSFetchRequest *)videoFetchRequestWithPredicate:(NSPredicate *)predicate;
+ (NSFetchRequest *)guestFetchRequestWithPredicate:(NSPredicate *)predicate;
+ (NSFetchRequest *)playlistFetchRequestWithPredicate:(NSPredicate *)predicate;

+ (NSArray *)allVideos;
+ (NSArray *)allHighlights;
+ (NSArray *)allFavorites;
+ (NSArray *)allNotifications;

+ (NSArray *)videosFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate;
+ (NSArray *)videosWithDownloads;
+ (NSArray *)downloadableVideosSortedByMostRecent;

+ (Video *)newVideo;
+ (Video *)nowPlayingVideo;
+ (Video *)mostRecentDownloadableVideo;
+ (Video *)videoWithID:(NSString *)videoID;
+ (Video *)videoForDownloadTaskID:(NSNumber *)downloadTaskID;

+ (Pager *)getPager;
+ (Pager *)newPager;
+ (void)resetPager;

+ (void)deleteVideo:(Video *)video;
+ (void)resetVideosWithDownloadTaskID:(NSNumber *)downloadTaskID;
+ (void)resetDownloadStatusOfVideo:(Video *)video;
+ (void)saveVideoInDB:(Video *)video WithData:(NSDictionary *)dictData;
+ (void)populateVideosFromDict:(NSDictionary *)parsedObject WithVideosInDB:(NSArray *)videosInDB WithExistingVideos:(NSArray *)existingVideos IsLastPage:(BOOL)isLastPage addToPlaylist:(NSString*)playlistId;

+ (void)resetZObjectChilds;
+ (void)populateZObjectsFromDictionary:(NSDictionary *)dictionary;
+ (NSArray *)getZObjects;
+ (NSFetchRequest *)presentableObjectsFetchRequestWithPredicate:(NSPredicate *)predicate;

+ (Playlist *)newPlaylist;
+ (Playlist *)playlistWithID:(NSString *)playlistID;
+ (NSArray *)getPlaylistsWithParentID:(NSString *)playlistID;
+ (NSArray *)getVideosWithParentID:(NSString *)playlistID;
+ (void)resetPlaylistChilds:(NSString *)playlistID;
+ (void)populatePlaylistFromDictionary:(NSDictionary *)dictionary;
+ (void)populatePlaylistsFromDictionary:(NSDictionary *)dictionary;



+ (PlaylistVideo *)newPlaylistVideo;
+ (NSArray *)playlistVideosFromPlaylistId:(NSString *)playlistId;

+ (NSArray *)guestsFromSearch:(NSString *)search;
+ (Guest *)newGuest;
+ (Guest *)guestWithID:(NSString *)guestID;
+ (void)populateGuestsFromDictionary:(NSDictionary *)dictionary;

+ (Favorite *)newFavorite;
+ (Favorite *)favoriteWithID:(NSString *)favoriteID;
+ (Favorite *)favoriteForVideo:(Video *)video;
+ (NSArray *)addedFavorites;
+ (NSArray *)removedFavorites;
+ (void)favoriteVideo:(Video *)video;
+ (void)unfavoriteVideo:(Video *)video;
+ (void)deleteFavorite:(Favorite *)favorite;
+ (void)resetFavorites;
+ (void)updateFavorite:(Favorite *)favorite WithData:(NSData *)data;
+ (void)populateVideoInFavoritesFromJSON:(NSData *)data error:(NSError **)error;
+ (void)populateFavoritesFromDict:(NSDictionary *)parsedObject WithFavoritesInDB:(NSMutableArray *)favoritesInDB WithExistingFavorites:(NSMutableArray *)existingFavorites IsLastPage:(BOOL)isLastPage;

+ (void)resetUserSettings;

+ (Notification *)notificationWithID:(NSString *)notificationID;
- (void)removeExpiredNotifications;
- (NSArray *)cancelRemovedNotifications;
- (NSArray *)updatedNotifications;
- (NSArray *)newNotifications;
- (void)setScheduledNotification:(Notification *)notification;
+ (void)populateNotificationsFromDict:(NSDictionary *)parsedObject WithNotificationsInDB:(NSMutableArray *)notificationsInDB WithExistingNotifications:(NSMutableArray *)existingNotifications IsLastPage:(BOOL)isLastPage;

- (void)saveContext;
- (NSManagedObjectContext *)managedObjectContext;
- (NSURL *)applicationDocumentsDirectory;

+ (instancetype)sharedInstance;

@end
