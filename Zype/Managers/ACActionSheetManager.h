//
//  ACActionSheetManager.h
//
//  Created by ZypeTech on 5/28/15.
//  Copyright (c) 2015 Zype. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Video.h"

NS_ENUM(NSInteger, ACLatestActionSheetType){
    
    ACLatestActionSheetTypeShowOptions = 0,
    ACLatestActionSheetTypeShare,
    ACLatestActionSheetTypeLiveStream,
    ACLatestActionSheetTypePlayAs
    
};

NS_ENUM(NSInteger, ACLatestActionSheetEpisodeOptionsButton){
    
    ACLatestActionSheetEpisodeOptionsButtonCancel = 0,
    ACLatestActionSheetEpisodeOptionsButtonShare,
    ACLatestActionSheetEpisodeOptionsButtonFavorite,
    ACLatestActionSheetEpisodeOptionsButtonUnFavorite,
    ACLatestActionSheetEpisodeOptionsButtonDownloadVideo,
    ACLatestActionSheetEpisodeOptionsButtonDownloadAudio,
    ACLatestActionSheetEpisodeOptionsButtonStopDownload,
    ACLatestActionSheetEpisodeOptionsButtonDeleteDownloadedVideo,
    ACLatestActionSheetEpisodeOptionsButtonDeleteDownloadedAudio,
    ACLatestActionSheetEpisodeOptionsButtonSubscribeToWatchAdFree
    
};

NS_ENUM(NSInteger, ACLatestActionSheetLiveStreamButton){
    
    ACLatestActionSheetLiveStreamButtonCancel = 0,
    ACLatestActionSheetLiveStreamButtonWatch,
    ACLatestActionSheetLiveStreamButtonListen
    
};

NS_ENUM(NSInteger, ACActionSheetPlayAsButton){
    
    ACActionSheetPlayAsButtonCancel = 0,
    ACActionSheetPlayAsButtonWatch,
    ACActionSheetPlayAsButtonListen
    
};

NS_ENUM(NSInteger, ACLatestActionSheetShareButton){
    
    ACLatestActionSheetShareButtonCancel = 0,
    ACLatestActionSheetShareButtonFacebook,
    ACLatestActionSheetShareButtonTwitter,
    ACLatestActionSheetShareButtonEmail,
    ACLatestActionSheetShareButtonMessage
    
};

NS_ENUM(NSInteger, ACDownloadsActionSheetButton){
    
    ACDownloadsActionSheetButtonCancel = 0,
    ACDownloadsActionSheetButtonDelete,
    
};

@protocol ACActionSheetManagerDelegate <NSObject>

- (void)acActionSheetManagerDelegatePresentViewController:(UIViewController *)viewController;
- (void)acActionSheetManagerDelegateShowActionSheet:(UIActionSheet *)actionSheet;
- (void)acActionSheetManagerDelegateDismissModal;

@optional
- (void)acActionSheetManagerDelegateWatchLiveStreamTapped;
- (void)acActionSheetManagerDelegateListenLiveStreamTapped;
- (void)acActionSheetManagerDelegateWatchLiveStreamWasTapped;
- (void)acActionSheetManagerDelegateReloadVideo:(Video *)video;
- (void)acActionSheetManagerDelegatePlayAsAudioTapped;
- (void)acActionSheetManagerDelegatePlayAsVideoTapped;
- (void)acActionSheetManagerDelegateDownloadTapped;

@end

@interface ACActionSheetManager : NSObject<UIActionSheetDelegate>

@property (nonatomic, strong) Video *actionVideo;
@property (nonatomic, weak) id<ACActionSheetManagerDelegate> delegate;

- (void)showActionSheetWithVideo:(Video *)video sources:(NSArray *)sources;
- (void)showLiveStreamActionSheet;
- (void)showPlayAsActionSheet;
- (void)showShareActionSheetWithVideo:(Video *)video;
- (void)showDownloadActionSheetWithVideo:(Video *)video withPlaybackSources:(NSArray *)sources;

@end
