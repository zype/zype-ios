//
//  EpisodeControllerDelegate.h
//  acumiashow
//
//  Created by ZypeTech on 6/28/15.
//  Copyright (c) 2015 Zype. All rights reserved.
//

@class TLIndexPathUpdates;

@protocol EpisodeControllerDelegate <NSObject>

- (void)episodeControllerDelegateShowEmptyMessage:(BOOL)show;
- (void)episodeControllerDelegateButtonActionTappedAtIndexPath:(NSIndexPath *)indexPath;
- (void)episodeControllerDidSelectItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)episodeControllerDidSelectItem:(NSObject *)item;
- (void)episodeControllerDelegateDoneLoading;

@optional

- (void)episodeControllerPerformUpdates:(TLIndexPathUpdates *)updates;

@end
