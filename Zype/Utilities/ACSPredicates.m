//
//  ACSPredicates.m
//  acumiashow
//
//  Created by ZypeTech on 6/30/15.
//  Copyright (c) 2015 Zype. All rights reserved.
//

#import "ACSPredicates.h"
#import "ACSPersistenceManager.h"
#import "Guest.h"
#import "Playlist.h"
#import "Video.h"

@implementation ACSPredicates


+ (NSPredicate *)fetchPredicateFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate{
    
    // Specify criteria for filtering which objects to fetch
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"published_at >= %@ && published_at <= %@ && isHighlight == %@ && duration != 0",
                              fromDate, toDate, [NSNumber numberWithBool:NO]];
    
    return predicate;
    
}

+ (NSPredicate *)fetchPredicateActive{
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"active == %@", [NSNumber numberWithBool:YES]];
    
    return predicate;
    
}

+ (NSPredicate *)fetchPredicateFromPlaylist:(NSString*)playlistId{
    NSArray<PlaylistVideo *> *playlistVideos = [ACSPersistenceManager playlistVideosFromPlaylistId:playlistId];
    NSMutableArray *filterArray = [[NSMutableArray alloc] init];
    for (PlaylistVideo *currentPlaylistVideo in playlistVideos) {
        Video *currentVideo = currentPlaylistVideo.video;
        
        [filterArray addObject:currentVideo.vId];
    }
    
   NSPredicate *predicate = [NSPredicate predicateWithFormat:@"vId IN %@", filterArray];
  // NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ANY playlists == %@", playlist];

    return predicate;
    
}


+ (NSPredicate *)fetchDownloadsPredicate{
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isDownload == %@", [NSNumber numberWithBool:YES]];
    
    return predicate;
    
}

+ (NSPredicate *)fetchFavoritesPredicate{
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isFavorite == %@", [NSNumber numberWithBool:YES]];
    
    return predicate;
    
}

+ (NSPredicate *)fetchHighlightsPredicate{
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isHighlight == %@", [NSNumber numberWithBool:YES]];
    
    return predicate;
    
}


+ (NSPredicate *)predicateWithParentId:(NSString *)parentId{
    
    //exact match, case insensitive
    NSString *search = [NSString stringWithFormat:@"parent_id ==[c] '%@'", parentId];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:search];
    return predicate;
    
}

+ (NSCompoundPredicate *)predicatePresentableObjectsWithParentId:(NSString *)parentId {
    
    //exact match, case insensitive
    NSString *playlistString = [NSString stringWithFormat:@"parent_id == [c] '%@'", parentId];
    NSString *pagerString = [NSString stringWithFormat:@"type == [c] '%@'", @"Pager"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:playlistString];
    NSPredicate *predicatePager = [NSPredicate predicateWithFormat:pagerString];
    NSCompoundPredicate *compoundPredicate = [[NSCompoundPredicate alloc] initWithType:NSOrPredicateType subpredicates:@[predicate, predicatePager]];
    return compoundPredicate;
    
}


+ (NSPredicate *)predicateMatchingDownloadURL:(NSURL *)url{
    
    //exact match, case insensitive
    NSString *search = [NSString stringWithFormat:@"downloadAudioUrl ==[c] '%@' OR downloadVideoUrl ==[c] '%@'", url, url];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:search];
    
    return predicate;
    
}

+ (NSPredicate *)predicateWithSearchString:(NSString *)searchString searchMode:(enum ACSSearchMode)mode{
    
    NSPredicate *predicate = nil;
    
    if (mode == ACSSearchModeTags) {
        
        predicate = [NSPredicate predicateWithFormat:@"keywordsString CONTAINS[cd] %@ && duration != 0", searchString];
        
    }else {
        

        NSArray *searchedGuests = [ACSPersistenceManager guestsFromSearch:searchString];
        
        // Prepare predicateFormat and arrayArgument
        NSMutableArray *arrayArgument = [[NSMutableArray alloc] init];
        NSString *predicateFormat = @"";
        if (searchedGuests.count > 0) {
            
            predicateFormat = @"zobjectString CONTAINS[cd] %@ && duration != 0";
            [arrayArgument addObject:((Guest *)searchedGuests[0]).gId];
            
            if (searchedGuests.count > 1) {
                
                for (int i = 1; i < [searchedGuests count]; ++i) {
                    
                    predicateFormat = [predicateFormat stringByAppendingString:@" OR zobjectString CONTAINS[cd] %@ && duration != 0"];
                    [arrayArgument addObject:((Guest *)[searchedGuests objectAtIndex:i]).gId];
                    
                }
                
            }
            
        }
        
        if (mode == ACSSearchModeGuests) {
            
            if (searchedGuests.count > 0){
                predicate = [NSPredicate predicateWithFormat:predicateFormat argumentArray:arrayArgument];
            }else{
                predicate = [NSPredicate predicateWithValue:NO];
            }
            
        }
        else {
            
            // Predicate for all
            if ([predicateFormat isEqualToString:@""]){
                predicateFormat = @"keywordsString CONTAINS[cd] %@ OR title CONTAINS[cd] %@ && duration != 0";
            }else{
                predicateFormat = [predicateFormat stringByAppendingString:@" OR keywordsString CONTAINS[cd] %@ OR title CONTAINS[cd] %@ && duration != 0"];
            }
            
            [arrayArgument addObject:searchString];
            [arrayArgument addObject:searchString];
            predicate = [NSPredicate predicateWithFormat:predicateFormat argumentArray:arrayArgument];
            
        }
        
    }
    
    return predicate;
}


@end
