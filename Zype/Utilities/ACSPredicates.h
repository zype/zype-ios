//
//  ACSPredicates.h
//  acumiashow
//
//  Created by ZypeTech on 6/30/15.
//  Copyright (c) 2015 Zype. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ENUM(NSInteger, ACSSearchMode){
    
    ACSSearchModeAll = 0,
    ACSSearchModeGuests,
    ACSSearchModeTags
    
};


@interface ACSPredicates : NSObject

+ (NSPredicate *)fetchPredicateFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate;
+ (NSPredicate *)fetchPredicateActive;
+ (NSPredicate *)fetchPredicateFromPlaylist:(NSString*)playlistId;
+ (NSPredicate *)fetchDownloadsPredicate;
+ (NSPredicate *)fetchFavoritesPredicate;
+ (NSPredicate *)fetchHighlightsPredicate;
+ (NSPredicate *)predicateMatchingDownloadURL:(NSURL *)url;
+ (NSPredicate *)predicateWithSearchString:(NSString *)searchString searchMode:(enum ACSSearchMode)mode;
+ (NSPredicate *)predicateWithParentId:(NSString *)parentId;
+ (NSCompoundPredicate *)predicatePresentableObjectsWithParentId:(NSString *)parentId;

@end
