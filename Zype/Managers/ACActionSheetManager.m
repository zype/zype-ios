//
//  ACActionSheetManager.m
//  acumiashow
//
//  Created by ZypeTech on 5/28/15.
//  Copyright (c) 2015 Zype. All rights reserved.
//

#import "ACActionSheetManager.h"
#import "ACStatusManager.h"
#import "ACDownloadManager.h"
#import "ACSAlertViewManager.h"
#import "ACShareManager.h"
#import "DownloadOperationController.h"
#import "Reachability.h"
#import "PlaybackSource.h"
#import "ViewManager.h"

@interface ACActionSheetManager ()<MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate>

@end

@implementation ACActionSheetManager



#pragma mark - UIActionSheetDelegate


- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex == actionSheet.cancelButtonIndex) {
      /*  [[UIView appearance] setTintColor:[UIColor whiteColor]];
        [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                              kSystemWhite, NSForegroundColorAttributeName,
                                                              [UIFont fontWithName:kFontRegular size:18.0], NSFontAttributeName,
                                                              nil]];*/
        return;
    }
    
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];

    if (actionSheet.tag == ACLatestActionSheetTypeShowOptions) {
        
        [self tappedShowOptionButtonWithTitle:buttonTitle];
        
    }else if (actionSheet.tag == ACLatestActionSheetTypeLiveStream){
        
        [self tappedLiveStreamButtonWithTitle:buttonTitle];
        
    }else if (actionSheet.tag == ACLatestActionSheetTypeShare){
        
        [self tappedShareButtonWithTitle:buttonTitle];
        
    }else if (actionSheet.tag == ACLatestActionSheetTypePlayAs){
        
        [self tappedPlayAsButtonWithTitle:buttonTitle];
        
    }
    
}



#pragma mark - UIActionSheet Setup

- (void)showActionSheetWithVideo:(Video *)video sources:(NSArray *)sources{
    
    self.actionVideo = video;
    UIActionSheet *actionSheet = [ACActionSheetManager episodeOptionsActionSheetWithVideo:video sources:sources];
    actionSheet.delegate = self;
    [self delegateShowActionSheet:actionSheet];
    
}

- (void)showLiveStreamActionSheet{
    
    UIActionSheet *actionSheet = [ACActionSheetManager liveStreamActionSheet];
    actionSheet.delegate = self;
    [self delegateShowActionSheet:actionSheet];
    
}

- (void)showShareActionSheetWithVideo:(Video *)video{
    
    self.actionVideo = video;
    UIActionSheet *actionSheet = [ACActionSheetManager shareActionSheet];
    actionSheet.delegate = self;
    [self delegateShowActionSheet:actionSheet];
    
}

- (void)showPlayAsActionSheet{
    
    UIActionSheet *actionSheet = [ACActionSheetManager videoDetailPlayAsActionSheet];
    actionSheet.delegate = self;
    [self delegateShowActionSheet:actionSheet];
    
}

- (void)showDownloadActionSheetWithVideo:(Video *)video withPlaybackSources:(NSArray *)sources {
    
    self.actionVideo = video;
    UIActionSheet *actionSheet = [ACActionSheetManager downloadActionSheetWithVideo:video withPlaybackSources:sources];
    actionSheet.delegate = self;
    [self delegateShowActionSheet:actionSheet];
    
}

#pragma mark - Private Methods


- (void)checkingOnActiveFlags:(void(^)())complete failure:(void(^)())failure {
    
    if (kDownloadsForAllUsersEnabled == NO) {
        if (kNativeSubscriptionEnabled == YES) {
            if (self.actionVideo.subscription_required.integerValue == 1) {
                [self.delegate acActionSheetManagerDelegatePresentViewController:[ViewManager subscriptionViewController]];
                if (failure) failure();
                return;
            }
        }
        
        if ([ACStatusManager isUserSignedIn] == NO) {
            [self.delegate acActionSheetManagerDelegatePresentViewController:[ViewManager signInViewController]];
            if (failure) failure();
            return;
        }
    }
    
    if (kSubscribeToWatchAdFree) {
        if (kNativeSubscriptionEnabled == NO) {
            if ([ACStatusManager isUserSignedIn] == NO) {
                [self.delegate acActionSheetManagerDelegatePresentViewController:[ViewManager signInViewController]];
                if (failure) failure();
                return;
            }
        }
    }
    
    complete();
}

#pragma mark - UIActionSheet Button Actions

- (void)tappedShowOptionButtonWithTitle:(NSString *)buttonTitle{
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    
    if ([buttonTitle isEqualToString:[ACActionSheetManager titleForShowOptionsActionSheetButtonWithType:ACLatestActionSheetEpisodeOptionsButtonShare]]) {
        
        CLS_LOG(@"share tapped");
        [self showShareActionSheetWithVideo:self.actionVideo];
        
    }else if ([buttonTitle isEqualToString:[ACActionSheetManager titleForShowOptionsActionSheetButtonWithType:ACLatestActionSheetEpisodeOptionsButtonFavorite]]) {
        CLS_LOG(@"favorite tapped");
        
        [[RESTServiceController sharedInstance] favoriteVideo:self.actionVideo];
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Latest" action:@"Favorite" label:@"Video Favorited" value:nil] build]];
        
    }else if ([buttonTitle isEqualToString:[ACActionSheetManager titleForShowOptionsActionSheetButtonWithType:ACLatestActionSheetEpisodeOptionsButtonSubscribeToWatchAdFree]]) {
        CLS_LOG(@"swaf tapped");

        [self checkingOnActiveFlags:^{ } failure:nil];
    
    }else if ([buttonTitle isEqualToString:[ACActionSheetManager titleForShowOptionsActionSheetButtonWithType:ACLatestActionSheetEpisodeOptionsButtonUnFavorite]]) {
        CLS_LOG(@"unfavorite tapped");
        
        [[RESTServiceController sharedInstance] unfavoriteVideo:self.actionVideo];
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Latest" action:@"Favorite" label:@"Video Unfavorited" value:nil] build]];
        
    }else if ([buttonTitle isEqualToString:[ACActionSheetManager titleForShowOptionsActionSheetButtonWithType:ACLatestActionSheetEpisodeOptionsButtonDownloadVideo]]) {
        CLS_LOG(@"download video tapped");
        
//        if (kDownloadsForAllUsersEnabled == NO) {
//            if (kNativeSubscriptionEnabled == YES) {
//                if (self.actionVideo.subscription_required.integerValue == 1) {
//                    [self.delegate acActionSheetManagerDelegatePresentViewController:[ViewManager subscriptionViewController]];
//                    return;
//                }
//            }
//            
//            if ([ACStatusManager isUserSignedIn] == NO) {
//                [self.delegate acActionSheetManagerDelegatePresentViewController:[ViewManager signInViewController]];
//                return;
//            }
//        }
        
        [self checkingOnActiveFlags:^{
            [self downloadVideoTapped];
            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Latest" action:@"Download" label:@"Download Video Tapped" value:nil] build]];
        } failure:nil];
        

        
    }else if ([buttonTitle isEqualToString:[ACActionSheetManager titleForShowOptionsActionSheetButtonWithType:ACLatestActionSheetEpisodeOptionsButtonDownloadAudio]]) {
        CLS_LOG(@"download audio tapped");
        
        [self checkingOnActiveFlags:^{
            [self downloadAudioTapped];
            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Latest" action:@"Download" label:@"Download Audio Tapped" value:nil] build]];
        } failure:nil];
        
        
    }else if ([buttonTitle isEqualToString:[ACActionSheetManager titleForShowOptionsActionSheetButtonWithType:ACLatestActionSheetEpisodeOptionsButtonStopDownload]]) {
        CLS_LOG(@"stop download tapped");
        
        [self stopDownloadTapped];
        
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Latest" action:@"Download" label:@"Stop Download Tapped" value:nil] build]];
        
    }else if ([buttonTitle isEqualToString:[ACActionSheetManager titleForShowOptionsActionSheetButtonWithType:ACLatestActionSheetEpisodeOptionsButtonDeleteDownloadedVideo]]) {
        CLS_LOG(@"delete video tapped");
        
        [ACDownloadManager deleteDownloadedVideo:self.actionVideo];
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Latest" action:@"Download" label:@"Delete Audio Tapped" value:nil] build]];
        
    }else if ([buttonTitle isEqualToString:[ACActionSheetManager titleForShowOptionsActionSheetButtonWithType:ACLatestActionSheetEpisodeOptionsButtonDeleteDownloadedAudio]]) {
        CLS_LOG(@"delete audio tapped");
        
        [ACDownloadManager deleteDownloadedVideo:self.actionVideo];
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Latest" action:@"Download" label:@"Delete Audio Tapped" value:nil] build]];
        
    }
    
}

- (void)tappedLiveStreamButtonWithTitle:(NSString *)buttonTitle{
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    
    if ([buttonTitle isEqualToString:[ACActionSheetManager titleForLiveStreamActionSheetButtonWithType:ACLatestActionSheetLiveStreamButtonWatch]]) {
        
        CLS_LOG(@"watch live stream tapped");
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Latest" action:@"Live" label:@"Facebook" value:nil] build]];
        [self delegateWatchLiveStreamTapped];
        [self delegateWatchLiveStreamWasTapped];
        
    }else if ([buttonTitle isEqualToString:[ACActionSheetManager titleForLiveStreamActionSheetButtonWithType:ACLatestActionSheetLiveStreamButtonListen]]) {
        
        CLS_LOG(@"listen to live stream tapped");
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Latest" action:@"Share" label:@"Twitter" value:nil] build]];
        [self delegateListenLiveStreamTapped];
        
    }
    
    //don't need this pointer any more
    self.actionVideo = nil;
    
}

- (void)tappedShareButtonWithTitle:(NSString *)buttonTitle{
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    
    if ([buttonTitle isEqualToString:[ACActionSheetManager titleForShareActionSheetButtonWithType:ACLatestActionSheetShareButtonFacebook]]) {
        
        CLS_LOG(@"facebook tapped");
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:kAnalyticsScreenNameLatest action:kAnalyticsActShareMenu label:kAnalyticsEventLabelFB value:nil] build]];
        [self facebookTapped];
        
    }else if ([buttonTitle isEqualToString:[ACActionSheetManager titleForShareActionSheetButtonWithType:ACLatestActionSheetShareButtonTwitter]]) {
        
        CLS_LOG(@"twitter tapped");
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:kAnalyticsScreenNameLatest action:kAnalyticsActShareMenu label:kAnalyticsEventLabelTwit value:nil] build]];
        [self twitterTapped];
        
    }else if ([buttonTitle isEqualToString:[ACActionSheetManager titleForShareActionSheetButtonWithType:ACLatestActionSheetShareButtonEmail]]) {
        
        CLS_LOG(@"email tapped");
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:kAnalyticsScreenNameLatest action:kAnalyticsActShareMenu label:kAnalyticsEventLabelEMail value:nil] build]];
        [self emailTapped];
        
    }else if ([buttonTitle isEqualToString:[ACActionSheetManager titleForShareActionSheetButtonWithType:ACLatestActionSheetShareButtonMessage]]) {
        
        CLS_LOG(@"message tapped");
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:kAnalyticsScreenNameLatest action:kAnalyticsActShareMenu label:kAnalyticsEventLabelSMS value:nil] build]];
        [self messageTapped];
        
    }
    
    //don't need this pointer any more
    self.actionVideo = nil;
    
}

- (void)tappedPlayAsButtonWithTitle:(NSString *)buttonTitle{
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    
    if ([buttonTitle isEqualToString:[ACActionSheetManager titleForPlayAsActionSheetButtonWithType:ACActionSheetPlayAsButtonListen]]) {
        
        CLS_LOG(@"play as audio tapped");
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:kAnalyticsScreenNameLatest action:kAnalyticsActShareMenu label:kAnalyticsEventLabelFB value:nil] build]];
        [self playAsAudioTapped];
        
    }else if ([buttonTitle isEqualToString:[ACActionSheetManager titleForPlayAsActionSheetButtonWithType:ACActionSheetPlayAsButtonWatch]]) {
        
        CLS_LOG(@"play as video tapped");
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:kAnalyticsScreenNameLatest action:kAnalyticsActShareMenu label:kAnalyticsEventLabelTwit value:nil] build]];
        [self playAsVideoTapped];
        
    }
    
    //don't need this pointer any more
    self.actionVideo = nil;
    
}


#pragma mark - Downloads


- (void)downloadVideoTapped {
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kSettingKey_DownloadWifiOnly] &&
        [[Reachability reachabilityForLocalWiFi] currentReachabilityStatus] != ReachableViaWiFi){
        
        [ACSAlertViewManager showAlertWithTitle:kString_TitleDownloadFail WithMessage:kString_MessageDownloadFail];
        
    }else{
        
        [[DownloadOperationController sharedInstance] startDownload:self.actionVideo WithMediaType:kMediaType_Video];
        [self delegateDownloadTapped];
        
    }
    
}

- (void)downloadAudioTapped {
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kSettingKey_DownloadWifiOnly] &&
        [[Reachability reachabilityForLocalWiFi] currentReachabilityStatus] != ReachableViaWiFi){
        
        [ACSAlertViewManager showAlertWithTitle:kString_TitleDownloadFail WithMessage:kString_MessageDownloadFail];
        
    }else{
        
        [[DownloadOperationController sharedInstance] startDownload:self.actionVideo WithMediaType:kMediaType_Audio];
        [self delegateDownloadTapped];
        
    }
    
}

- (void)stopDownloadTapped{
    
    [ACDownloadManager stopDownloadingVideo:self.actionVideo];
    [self delegateReloadVideo:self.actionVideo];
    
}




#pragma mark - Sharing

- (void)facebookTapped{
    
    SLComposeViewController *facebookController = [ACShareManager facebookControllerForVideo:self.actionVideo];
    [self delegatePresentViewController:facebookController];
    
}

- (void)twitterTapped{
    
    SLComposeViewController *twitterController = [ACShareManager twitterControllerForVideo:self.actionVideo];
    [self delegatePresentViewController:twitterController];
    
}

- (void)emailTapped{
    
    MFMailComposeViewController *mailController = [ACShareManager mailControllerForVideo:self.actionVideo];
    
    if (mailController != nil) {
        //TODO: setup dedicated delegate for this
        mailController.mailComposeDelegate = self;
        [self delegatePresentViewController:mailController];
    }
    
}

- (void)messageTapped{
    
    MFMessageComposeViewController *messageController = [ACShareManager messageControllerForVideo:self.actionVideo];
    
    if (messageController != nil) {
        //TODO: setup dedicated delegate for this
        messageController.messageComposeDelegate = self;
        [self delegatePresentViewController:messageController];
    }
    
}

#pragma mark - Video Detail Play As

- (void)playAsAudioTapped{
    
    [self delegatePlayAsAudioTapped];
    
}

- (void)playAsVideoTapped{
    
    [self delegatePlayAsVideoTapped];
    
}

#pragma mark - Class Methods

//- (void)checkDownloadVideo {
//    [[RESTServiceController sharedInstance] getVideoPlayerWithVideo:self.video downloadInfo:YES withCompletionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
//        //
//        if (error) {
//            CLS_LOG(@"Failed: %@", error);
//        } else {
//            CLS_LOG(@"Success");
//            NSError *localError = nil;
//            NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
//            
//            if (localError != nil) {
//                CLS_LOG(@"Failed: %@", localError);
//            } else {
//                self.playbackSources = [[RESTServiceController sharedInstance] streamPlaybackSourcesFromRootDictionary:parsedObject];
//                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
//                CLS_LOG(@"source: %ld", (long)[httpResponse statusCode]);
//            }
//        }
//    }];
//}

+ (UIActionSheet *)episodeOptionsActionSheetWithVideo:(Video *)video sources:(NSArray *)sources {
    
    DownloadInfo *downloadInfo = [[DownloadOperationController sharedInstance] downloadInfoWithTaskId:video.downloadTaskId];
    BOOL isDownloadAudio = NO;
    BOOL isDownloadVideo = NO;
    if (sources != nil) {
        if (sources.count > 0) {
            for (PlaybackSource *sourse in sources) {
                if ([sourse.fileType isEqualToString:@"mp4"]) {
                    isDownloadVideo = YES;
                } else if ([sourse.fileType isEqualToString:@"m4a"]) {
                    isDownloadAudio = YES;
                }
            }
        }
    }
    
    NSString *cancelButtonTitle = NSLocalizedString(@"Cancel", @"action button title");
    
    //iOS7 iPad interprets cancel button incorrectly
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        cancelButtonTitle = nil;
    }
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:video.title delegate:nil cancelButtonTitle:cancelButtonTitle destructiveButtonTitle:nil otherButtonTitles:nil];
    
    //add stop downloading button if in progress
    if (downloadInfo.isDownloading) {
        
        [actionSheet addButtonWithTitle:[self titleForShowOptionsActionSheetButtonWithType:ACLatestActionSheetEpisodeOptionsButtonStopDownload]];
        
    }
    
    if (video.downloadAudioLocalPath) {
        [actionSheet addButtonWithTitle:[self titleForShowOptionsActionSheetButtonWithType:ACLatestActionSheetEpisodeOptionsButtonDeleteDownloadedAudio]];
    }
    if (video.downloadVideoLocalPath) {
        [actionSheet addButtonWithTitle:[self titleForShowOptionsActionSheetButtonWithType:ACLatestActionSheetEpisodeOptionsButtonDeleteDownloadedVideo]];
    }
    
    //disable download video
    //if duration is 0, the video is live/not-downloadable
    if (kDownloadsEnabled){
        if (video.duration.integerValue > 1 && video.isHighlight.boolValue == NO) {
            
            if (downloadInfo.isDownloading == NO) {
                if (video.downloadAudioLocalPath == nil && isDownloadAudio == YES) {
                    [actionSheet addButtonWithTitle:[self titleForShowOptionsActionSheetButtonWithType:ACLatestActionSheetEpisodeOptionsButtonDownloadAudio]];
                }
                if (video.downloadVideoLocalPath == nil && isDownloadVideo == YES) {
                    [actionSheet addButtonWithTitle:[self titleForShowOptionsActionSheetButtonWithType:ACLatestActionSheetEpisodeOptionsButtonDownloadVideo]];
                    
                }
            }
            
        } else if (video.duration.integerValue == 0 && video.isHighlight.boolValue == NO){
            
            actionSheet.title = @"This episode will be available for download roughly one hour after the broadcast ends.";
            
        }
    }
    
    //add favorite or unfavorite button
    if (!kFavoritesViaAPI || [ACStatusManager isUserSignedIn]) {
        NSString *title = (video.isFavorite.boolValue) ? [self titleForShowOptionsActionSheetButtonWithType:ACLatestActionSheetEpisodeOptionsButtonUnFavorite] : [self titleForShowOptionsActionSheetButtonWithType:ACLatestActionSheetEpisodeOptionsButtonFavorite];
        [actionSheet addButtonWithTitle:title];
    }
    
    //add share button
    if (kShareVideoEnabled) {
            [actionSheet addButtonWithTitle:[self titleForShowOptionsActionSheetButtonWithType:ACLatestActionSheetEpisodeOptionsButtonShare]];
    }
    
    if (kNativeSubscriptionEnabled == NO) {
        if (kSubscribeToWatchAdFree) {
            if ([ACStatusManager isUserSignedIn] == false) {
                [actionSheet addButtonWithTitle:[self titleForShowOptionsActionSheetButtonWithType: ACLatestActionSheetEpisodeOptionsButtonSubscribeToWatchAdFree]];
            }
        }
    }
    
    actionSheet.tag = ACLatestActionSheetTypeShowOptions;
    
    return actionSheet;
    
}

+ (UIActionSheet *)downloadActionSheetWithVideo:(Video *)video withPlaybackSources:(NSArray *)sources {
    
    DownloadInfo *downloadInfo = [[DownloadOperationController sharedInstance] downloadInfoWithTaskId:video.downloadTaskId];
    
    NSString *cancelButtonTitle = NSLocalizedString(@"Cancel", @"action button title");
    
    //iOS7 iPad interprets cancel button incorrectly
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        cancelButtonTitle = nil;
    }
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:nil cancelButtonTitle:cancelButtonTitle destructiveButtonTitle:nil otherButtonTitles:nil];
    
    //add stop downloading button if in progress
    if (downloadInfo.isDownloading) {
        
        [actionSheet addButtonWithTitle:[self titleForShowOptionsActionSheetButtonWithType:ACLatestActionSheetEpisodeOptionsButtonStopDownload]];
        
    }
    
    if (video.downloadAudioLocalPath) {
        [actionSheet addButtonWithTitle:[self titleForShowOptionsActionSheetButtonWithType:ACLatestActionSheetEpisodeOptionsButtonDeleteDownloadedAudio]];
    }
    if (video.downloadVideoLocalPath) {
        [actionSheet addButtonWithTitle:[self titleForShowOptionsActionSheetButtonWithType:ACLatestActionSheetEpisodeOptionsButtonDeleteDownloadedVideo]];
    }
    
    //if duration is 0, the video is live/not-downloadable
    if (video.duration.integerValue > 1 && video.isHighlight.boolValue == NO) {
        
        if (downloadInfo.isDownloading == NO) {
            
            PlaybackSource *videoSource;
            PlaybackSource *audioSource;
            for (PlaybackSource *source in sources) {
                if ([source.fileType isEqualToString:@"mp4"]) {
                    videoSource = source;
                }
                if ([source.fileType isEqualToString:@"m4a"]) {
                    audioSource = source;
                }
            }
            
            if (video.downloadAudioLocalPath == nil && audioSource != nil) {
                [actionSheet addButtonWithTitle:[self titleForShowOptionsActionSheetButtonWithType:ACLatestActionSheetEpisodeOptionsButtonDownloadAudio]];
            }
            if (video.downloadVideoLocalPath == nil && videoSource != nil) {
                [actionSheet addButtonWithTitle:[self titleForShowOptionsActionSheetButtonWithType:ACLatestActionSheetEpisodeOptionsButtonDownloadVideo]];
                
            }
        }
        
    }
    
    actionSheet.tag = ACLatestActionSheetTypeShowOptions;
    
    return actionSheet;
    
}

+ (UIActionSheet *)videoDetailPlayAsActionSheet{
    
    NSString *cancelButtonTitle = NSLocalizedString(@"Cancel", @"action button title");
    
    //iOS7 iPad interprets cancel button incorrectly
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        cancelButtonTitle = nil;
    }
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:nil cancelButtonTitle:cancelButtonTitle destructiveButtonTitle:nil otherButtonTitles:nil];
    
    [actionSheet addButtonWithTitle:[self titleForPlayAsActionSheetButtonWithType:ACActionSheetPlayAsButtonListen]];
    [actionSheet addButtonWithTitle:[self titleForPlayAsActionSheetButtonWithType:ACActionSheetPlayAsButtonWatch]];
    
    actionSheet.tag = ACLatestActionSheetTypePlayAs;
    
    return actionSheet;
    
}

+ (UIActionSheet *)liveStreamActionSheet{
    
    NSString *title = NSLocalizedString(@"Live Show", @"action sheet title");
    NSString *cancelButtonTitle = NSLocalizedString(@"Cancel", @"action button title");
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        cancelButtonTitle = nil;
    }
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:title delegate:nil cancelButtonTitle:cancelButtonTitle destructiveButtonTitle:nil otherButtonTitles:nil];
    
    [actionSheet addButtonWithTitle:[self titleForLiveStreamActionSheetButtonWithType:ACLatestActionSheetLiveStreamButtonWatch]];
    [actionSheet addButtonWithTitle:[self titleForLiveStreamActionSheetButtonWithType:ACLatestActionSheetLiveStreamButtonListen]];
    

    actionSheet.tag = ACLatestActionSheetTypeLiveStream;
    
    return actionSheet;
    
}

+ (UIActionSheet *)shareActionSheet{
    
    NSString *title = NSLocalizedString(@"Share", @"action sheet title");
    NSString *cancelButtonTitle = NSLocalizedString(@"Cancel", @"action button title");
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        cancelButtonTitle = nil;
    }
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:title delegate:nil cancelButtonTitle:cancelButtonTitle destructiveButtonTitle:nil otherButtonTitles:nil];
    
    [actionSheet addButtonWithTitle:[self titleForShareActionSheetButtonWithType:ACLatestActionSheetShareButtonFacebook]];
    [actionSheet addButtonWithTitle:[self titleForShareActionSheetButtonWithType:ACLatestActionSheetShareButtonTwitter]];
    [actionSheet addButtonWithTitle:[self titleForShareActionSheetButtonWithType:ACLatestActionSheetShareButtonEmail]];
    [actionSheet addButtonWithTitle:[self titleForShareActionSheetButtonWithType:ACLatestActionSheetShareButtonMessage]];
    
    actionSheet.tag = ACLatestActionSheetTypeShare;
    
    return actionSheet;
    
}

#pragma mark - Title Matchers

+ (NSString *)titleForShowOptionsActionSheetButtonWithType:(NSInteger)type{
    
    switch (type) {
        case ACLatestActionSheetEpisodeOptionsButtonShare:
            return NSLocalizedString(@"Share", @"action button title");
            break;
            
        case ACLatestActionSheetEpisodeOptionsButtonFavorite:
            return NSLocalizedString(@"Favorite", @"action button title");
            break;
            
        case ACLatestActionSheetEpisodeOptionsButtonUnFavorite:
            return NSLocalizedString(@"Unfavorite", @"action button title");
            break;
            
        case ACLatestActionSheetEpisodeOptionsButtonDownloadVideo:
            return NSLocalizedString(@"Download Video", @"action button title");
            break;
            
        case ACLatestActionSheetEpisodeOptionsButtonDownloadAudio:
            return NSLocalizedString(@"Download Audio", @"action button title");
            break;
            
        case ACLatestActionSheetEpisodeOptionsButtonStopDownload:
            return NSLocalizedString(@"Stop Downloading", @"action button title");
            break;
            
        case ACLatestActionSheetEpisodeOptionsButtonDeleteDownloadedVideo:
            return NSLocalizedString(@"Delete Downloaded Video", @"action button title");
            break;
            
        case ACLatestActionSheetEpisodeOptionsButtonDeleteDownloadedAudio:
            return NSLocalizedString(@"Delete Downloaded Audio", @"action button title");
            break;
            
        case ACLatestActionSheetEpisodeOptionsButtonSubscribeToWatchAdFree:
            return NSLocalizedString(@"Watch Ad Free", @"action button title");
            break;
            
        default:
            break;
    }
    
    return nil;
    
}

+ (NSString *)titleForShareActionSheetButtonWithType:(NSInteger)type{
    
    switch (type) {
        case ACLatestActionSheetShareButtonFacebook:
            return NSLocalizedString(@"Facebook", @"action button title");
            break;
            
        case ACLatestActionSheetShareButtonTwitter:
            return NSLocalizedString(@"Twitter", @"action button title");
            break;
            
        case ACLatestActionSheetShareButtonEmail:
            return NSLocalizedString(@"Email", @"action button title");
            break;
            
        case ACLatestActionSheetShareButtonMessage:
            return NSLocalizedString(@"Message", @"action button title");
            break;
            
        default:
            break;
    }
    
    return nil;
    
}

+ (NSString *)titleForLiveStreamActionSheetButtonWithType:(NSInteger)type{
    
    switch (type) {
        case ACLatestActionSheetLiveStreamButtonWatch:
            return NSLocalizedString(@"Watch Live", @"action button title");
            break;
            
        case ACLatestActionSheetLiveStreamButtonListen:
            return NSLocalizedString(@"Listen Live", @"action button title");
            break;
            
        default:
            break;
    }
    
    return nil;
    
}

+ (NSString *)titleForPlayAsActionSheetButtonWithType:(NSInteger)type{
    
    switch (type) {
        case ACActionSheetPlayAsButtonWatch:
            return NSLocalizedString(@"Play as Video", @"action button title");
            break;
            
        case ACActionSheetPlayAsButtonListen:
            return NSLocalizedString(@"Play as Audio", @"action button title");
            break;
            
        default:
            break;
    }
    
    return nil;
    
}

#pragma mark - Delegate Calls

- (void)delegatePresentViewController:(UIViewController *)viewController{
    
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(acActionSheetManagerDelegatePresentViewController:)]) {
       /* [[UIView appearance] setTintColor:[UIColor colorWithRed:0.145 green:0.157 blue:0.173 alpha:1]];
        [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                              [UIColor colorWithRed:0.145 green:0.157 blue:0.173 alpha:1], NSForegroundColorAttributeName,
                                                              [UIFont fontWithName:kFontRegular size:18.0], NSFontAttributeName,
                                                              nil]];*/
        [self.delegate acActionSheetManagerDelegatePresentViewController:viewController];
       /* [[UIView appearance] setTintColor:[UIColor whiteColor]];
        [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                              kSystemWhite, NSForegroundColorAttributeName,
                                                              [UIFont fontWithName:kFontRegular size:18.0], NSFontAttributeName,
                                                              nil]];*/

    }
    
}

- (void)delegateShowActionSheet:(UIActionSheet *)actionSheet{
    
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(acActionSheetManagerDelegateShowActionSheet:)]) {
      /*  [[UIView appearance] setTintColor:[UIColor colorWithRed:0.145 green:0.157 blue:0.173 alpha:1]];
        [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                              [UIColor colorWithRed:0.145 green:0.157 blue:0.173 alpha:1], NSForegroundColorAttributeName,
                                                              [UIFont fontWithName:kFontRegular size:18.0], NSFontAttributeName,
                                                              nil]];*/
        [self.delegate acActionSheetManagerDelegateShowActionSheet:actionSheet];
    }
    
}

- (void)delegateDismissModal{
    
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(acActionSheetManagerDelegateDismissModal)]) {
      /*  [[UIView appearance] setTintColor:[UIColor whiteColor]];
        [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                              kSystemWhite, NSForegroundColorAttributeName,
                                                              [UIFont fontWithName:kFontRegular size:18.0], NSFontAttributeName,
                                                              nil]];*/
        [self.delegate acActionSheetManagerDelegateDismissModal];
    }
    
}

- (void)didPresentActionSheet:(UIActionSheet *)actionSheet
{
//    [[UIView appearance] setTintColor:[UIColor whiteColor]];
//    [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
//                                                          kSystemWhite, NSForegroundColorAttributeName,
//                                                          [UIFont fontWithName:kFontRegular size:18.0], NSFontAttributeName,
//                                                          nil]];
}

//optional

- (void)delegateWatchLiveStreamTapped{
    
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(acActionSheetManagerDelegateWatchLiveStreamTapped)]) {
        [self.delegate acActionSheetManagerDelegateWatchLiveStreamTapped];
    }
    
}

- (void)delegateListenLiveStreamTapped{
    
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(acActionSheetManagerDelegateListenLiveStreamTapped)]) {
        [self.delegate acActionSheetManagerDelegateListenLiveStreamTapped];
    }
    
}

- (void)delegateWatchLiveStreamWasTapped{
    
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(acActionSheetManagerDelegateWatchLiveStreamWasTapped)]) {
        [self.delegate acActionSheetManagerDelegateWatchLiveStreamWasTapped];
    }
    
}

- (void)delegateReloadVideo:(Video *)video{
    
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(acActionSheetManagerDelegateReloadVideo:)]) {
        [self.delegate acActionSheetManagerDelegateReloadVideo:video];
    }
    
}

- (void)delegatePlayAsAudioTapped{
    
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(acActionSheetManagerDelegatePlayAsAudioTapped)]) {
        [self.delegate acActionSheetManagerDelegatePlayAsAudioTapped];
    }
    
}

- (void)delegatePlayAsVideoTapped{
    
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(acActionSheetManagerDelegatePlayAsVideoTapped)]) {
        [self.delegate acActionSheetManagerDelegatePlayAsVideoTapped];
    }
    
}

- (void)delegateDownloadTapped{
    
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(acActionSheetManagerDelegateDownloadTapped)]) {
        [self.delegate acActionSheetManagerDelegateDownloadTapped];
    }
    
}


#pragma mark - MFMailComposerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result) {
        case MFMailComposeResultCancelled:
            break;
        case MFMailComposeResultSaved:
            break;
        case MFMailComposeResultSent:
            break;
        case MFMailComposeResultFailed: {
            if (error) {
                //
            }
        }
            break;
        default:
            break;
    }
    
    [self delegateDismissModal];
    
}

#pragma mark - MFMessageComposerDelegate

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    switch (result) {
        case MessageComposeResultCancelled:
            break;
        case MessageComposeResultFailed:
        {
            UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:kString_TitleShareFail message:kString_MessageSmsFail delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [warningAlert show];
            break;
        }
        case MessageComposeResultSent:
            break;
        default:
            break;
    }
    
    [self delegateDismissModal];
    
}



@end
