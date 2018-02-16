//
//  Video.h
//  Zype
//
//  Created by ZypeTech on 1/28/15.
//  Copyright (c) 2015 Zype. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class PlaylistVideo;
@class Playlist;

@interface Video : NSManagedObject

@property (nonatomic, retain) NSString * vId;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * country;
@property (nonatomic, retain) NSString * full_description;
@property (nonatomic, retain) NSString * short_description;
@property (nonatomic, retain) NSString * status;
@property (nonatomic, retain) NSString * thumbnailUrl;
@property (nonatomic, retain) NSString * thumbnailLocalPath;
@property (nonatomic, retain) NSString * downloadAudioUrl;
@property (nonatomic, retain) NSString * downloadAudioLocalPath;
@property (nonatomic, retain) NSString * downloadVideoUrl;
@property (nonatomic, retain) NSString * downloadVideoLocalPath;
@property (nonatomic, retain) NSDate * created_at;
@property (nonatomic, retain) NSDate * expire_at;
@property (nonatomic, retain) NSDate * published_at;
@property (nonatomic, retain) NSDate * start_at;
@property (nonatomic, retain) NSDate * updated_at;
@property (nonatomic, retain) NSNumber * episode;
@property (nonatomic, retain) NSNumber * season;
@property (nonatomic, retain) NSNumber * duration;
@property (nonatomic, retain) NSNumber * active;
@property (nonatomic, retain) NSNumber * featured;
@property (nonatomic, retain) NSNumber * mature_content;
@property (nonatomic, retain) NSNumber * subscription_required;
@property (nonatomic, retain) NSNumber * downloadTaskId;
@property (nonatomic, retain) NSNumber * isDownload;
@property (nonatomic, retain) NSNumber * isFavorite;
@property (nonatomic, retain) NSNumber * isHighlight;
@property (nonatomic, retain) NSNumber * isPlaying;
@property (nonatomic, retain) NSNumber * isPlayed;
@property (nonatomic, retain) NSNumber * on_air;
@property (nonatomic, retain) id categories;
@property (nonatomic, retain) id data_sources;
@property (nonatomic, retain) id zobject_ids;
@property (nonatomic, retain) id segments;
@property (nonatomic, retain) id keywords;
@property (nonatomic, retain) NSString * keywordsString;
@property (nonatomic, retain) NSString * zobjectString;
@property (nonatomic, retain) NSNumber * playTime;

@property (nonatomic, retain) NSSet *playlistVideo;

- (Playlist *)playlistFromVideo;

@end

@interface categories : NSValueTransformer

@end

@interface data_sources : NSValueTransformer

@end

@interface zobject_ids : NSValueTransformer

@end

@interface segments : NSValueTransformer

@end

@interface keywords : NSValueTransformer

@end

@interface Video (CoreDataGeneratedAccessors)

- (void)addPlaylistVideoObject:(PlaylistVideo *)value;
- (void)removePlaylistVideoObject:(PlaylistVideo *)value;
- (void)addPlaylistVideo:(NSSet<PlaylistVideo *> *)values;
- (void)removePlaylistVideo:(NSSet<PlaylistVideo *> *)values;

@end
