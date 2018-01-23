//
//  Video.m
//  Zype
//
//  Created by ZypeTech on 1/28/15.
//  Copyright (c) 2015 Zype. All rights reserved.
//

#import "Video.h"
#import "PlaylistVideo.h"


@implementation Video

@dynamic vId;
@dynamic title;
@dynamic country;
@dynamic full_description;
@dynamic short_description;
@dynamic status;
@dynamic thumbnailUrl;
@dynamic thumbnailLocalPath;
@dynamic downloadAudioUrl;
@dynamic downloadAudioLocalPath;
@dynamic downloadVideoUrl;
@dynamic downloadVideoLocalPath;
@dynamic created_at;
@dynamic expire_at;
@dynamic published_at;
@dynamic start_at;
@dynamic updated_at;
@dynamic episode;
@dynamic season;
@dynamic duration;
@dynamic active;
@dynamic featured;
@dynamic mature_content;
@dynamic subscription_required;
@dynamic downloadTaskId;
@dynamic isDownload;
@dynamic isFavorite;
@dynamic isHighlight;
@dynamic isPlaying;
@dynamic isPlayed;
@dynamic on_air;
@dynamic categories;
@dynamic data_sources;
@dynamic zobject_ids;
@dynamic segments;
@dynamic keywords;
@dynamic keywordsString;
@dynamic zobjectString;
@dynamic playTime;

@dynamic playlistVideo;

- (Playlist *)playlistFromVideo {
    NSArray * playlists = [self.playlistVideo allObjects];
    for (PlaylistVideo *pVideo in playlists) {
        if (pVideo.playlist) {
            return pVideo.playlist;
        }
    }
    
    return nil;
}

@end

@implementation categories

+ (Class)transformedValueClass
{
    return [NSArray class];
}

+ (BOOL)allowsReverseTransformation
{
    return YES;
}

- (id)transformedValue:(id)value
{
    return [NSKeyedArchiver archivedDataWithRootObject:value];
}

- (id)reverseTransformedValue:(id)value
{
    return [NSKeyedUnarchiver unarchiveObjectWithData:value];
}

@end

@implementation data_sources

+ (Class)transformedValueClass
{
    return [NSArray class];
}

+ (BOOL)allowsReverseTransformation
{
    return YES;
}

- (id)transformedValue:(id)value
{
    return [NSKeyedArchiver archivedDataWithRootObject:value];
}

- (id)reverseTransformedValue:(id)value
{
    return [NSKeyedUnarchiver unarchiveObjectWithData:value];
}

@end

@implementation zobject_ids

+ (Class)transformedValueClass
{
    return [NSArray class];
}

+ (BOOL)allowsReverseTransformation
{
    return YES;
}

- (id)transformedValue:(id)value
{
    return [NSKeyedArchiver archivedDataWithRootObject:value];
}

- (id)reverseTransformedValue:(id)value
{
    return [NSKeyedUnarchiver unarchiveObjectWithData:value];
}

@end

@implementation segments

+ (Class)transformedValueClass
{
    return [NSArray class];
}

+ (BOOL)allowsReverseTransformation
{
    return YES;
}

- (id)transformedValue:(id)value
{
    return [NSKeyedArchiver archivedDataWithRootObject:value];
}

- (id)reverseTransformedValue:(id)value
{
    return [NSKeyedUnarchiver unarchiveObjectWithData:value];
}

@end

@implementation keywords

+ (Class)transformedValueClass
{
    return [NSArray class];
}

+ (BOOL)allowsReverseTransformation
{
    return YES;
}

- (id)transformedValue:(id)value
{
    return [NSKeyedArchiver archivedDataWithRootObject:value];
}

- (id)reverseTransformedValue:(id)value
{
    return [NSKeyedUnarchiver unarchiveObjectWithData:value];
}

@end
