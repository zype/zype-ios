//
//  ACDownloadManager.m
//
//  Created by ZypeTech on 5/28/15.
//  Copyright (c) 2015 Zype. All rights reserved.
//

#import <SDWebImage/UIImageView+WebCache.h>
#import <Crashlytics/Crashlytics.h>

#import "ACDownloadManager.h"
#import "ACSDataManager.h"
#import "ACSPersistenceManager.h"
#import "DownloadOperationController.h"
#import "BaseViewController.h"
#import "Video.h"
#import "Reachability.h"
#import "NSMutableArray+LimitedStack.h"

@implementation ACDownloadManager


+ (void)autoDownloadLatestVideo{
      
    Video *latestVideo = [ACSPersistenceManager mostRecentDownloadableVideo];
    
    if (latestVideo == nil) {
        return;
    }
    
    if ([ACDownloadManager shouldAutoDownload] == YES && [ACDownloadManager alreadyAutoDownloadedVideo:latestVideo] == NO)
    {
        
        CLS_LOG(@"Auto download video in background");
        [ACDownloadManager backgroundDownloadVideo:latestVideo atIndex:nil];
        [ACDownloadManager trackAutoDownload:latestVideo];
        
    }

}

+ (BOOL)shouldAutoDownload
{
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kSettingKey_SignInStatus] &&                          //is user signed in
        [[NSUserDefaults standardUserDefaults] boolForKey:kSettingKey_AutoDownloadContent])                     //is auto download on
    {
        
        if ([[NSUserDefaults standardUserDefaults] boolForKey:kSettingKey_DownloadWifiOnly] == YES &&           //is download wifi only
            [[Reachability reachabilityForLocalWiFi] currentReachabilityStatus] == ReachableViaWiFi)           //network is reachable via wifi
        {
            
            return YES;
            
        }else if ([[NSUserDefaults standardUserDefaults] boolForKey:kSettingKey_DownloadWifiOnly ] == NO &&     //is download wifi only off
                  [[Reachability reachabilityForLocalWiFi] currentReachabilityStatus] != NotReachable){        //network is reachable
            
            return YES;
            
        }
        
    }
    
    return NO;
    
}

+ (BOOL)alreadyDownloadedVideo:(Video *)video{
    
    DownloadInfo *downloadInfo = [[DownloadOperationController sharedInstance] downloadInfoWithTaskId:video.downloadTaskId];
    
    if ([ACDownloadManager fileDownloadedForVideo:video] == YES || downloadInfo.isDownloading == YES){
        
        return YES;
        
    }
    
    return NO;
    
}

+ (BOOL)fileDownloadedForVideo:(Video *)video{
    
    NSString *localVideoPath = [ACDownloadManager localPathForDownloadedVideo:video];
    NSString *localAudioPath = [ACDownloadManager localAudioPathForDownloadForVideo:video];
    
    BOOL videoFileExists = [[NSFileManager defaultManager] fileExistsAtPath:localVideoPath];
    BOOL audioFileExists = [[NSFileManager defaultManager] fileExistsAtPath:localAudioPath];
    
    if (videoFileExists || audioFileExists) {
        return YES;
    }
    
    return NO;
    
}

+ (void)backgroundDownloadVideo:(Video *)video atIndex:(NSIndexPath *)indexPath{
    
    //check for existing or in-progress download and duration value before starting new download
    if ([ACDownloadManager alreadyDownloadedVideo:video] == NO && video.duration.integerValue > 1) {
        
        [[DownloadOperationController sharedInstance] startDownload:video WithMediaType:nil];
        
    }
    
}

+ (void)stopDownloadingVideo:(Video *)video{
    
    DownloadInfo *downloadInfo = [[DownloadOperationController sharedInstance] downloadInfoWithTaskId:video.downloadTaskId];
    [downloadInfo cancelDownload];

}

+ (void)deleteDownloadedVideo:(Video *)video
{
    
    NSString *localVideoPath = [ACDownloadManager localPathForDownloadedVideo:video];
    NSString *localAudioPath = [ACDownloadManager localAudioPathForDownloadForVideo:video];
    
    BOOL videoFileExists = [[NSFileManager defaultManager] fileExistsAtPath:localVideoPath];
    BOOL audioFileExists = [[NSFileManager defaultManager] fileExistsAtPath:localAudioPath];
    
    if (audioFileExists) {
        
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
    
    if (videoFileExists) {
        
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
    
    video.downloadAudioLocalPath = nil;
    video.downloadVideoLocalPath = nil;
    video.isDownload = [NSNumber numberWithBool:NO];
    video.isPlaying = [NSNumber numberWithBool:NO];
    video.isPlayed = [NSNumber numberWithBool:NO];
    [[ACSPersistenceManager sharedInstance] saveContext];
    
}

+ (void)resetDownloads{
    
    [self cancelDownloadsInProgress];
    [self deleteExistingDownloads];
    
}

+ (void)cancelDownloadsInProgress{
    
    NSArray *downloadInfos = [DownloadOperationController sharedInstance].arrayTasks;
    BaseViewController *viewController = [DownloadOperationController sharedInstance].viewController;
    
    for (DownloadInfo *info in downloadInfos) {
        
        if (viewController != nil) {
            [viewController setNoDownloadForDownloadTask:info.downloadTask];
        }
        
        [info cancelDownload];
        
    }
    
}

+ (void)deleteExistingDownloads{
    
    NSArray *downloadedVideos = [ACDownloadManager videosWithDownloads];
    
    if (downloadedVideos != nil) {
        for (Video *video in downloadedVideos) {
            [ACDownloadManager deleteDownloadedVideo:video];
        }
    }
    
}

+ (NSArray *)videosWithDownloads{
    

    NSArray *results = [ACSPersistenceManager videosWithDownloads];
    return results;
    
}


#define APPLICATION_DATA_DIRECTORY @"ApplicationData"
+ (NSString *)cachesDirectoryPath
// Returns the path to the caches directory.  This is a class method because it's
// used by +applicationStartup.
{
    NSString *      result;
    NSArray *       paths;
    
    result = nil;
    paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    if ( (paths != nil) && ([paths count] != 0) ) {
        assert([[paths objectAtIndex:0] isKindOfClass:[NSString class]]);
        result = [paths objectAtIndex:0];
    }
    result = [result stringByAppendingPathComponent:APPLICATION_DATA_DIRECTORY];
    if (![[NSFileManager defaultManager] fileExistsAtPath:result]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:result withIntermediateDirectories:YES attributes:nil error:NULL];
    }
    
    return result;
}


#pragma mark - Video Downloads


+ (NSString *)localPathForDownloadedVideo:(Video *)video{
    
    NSString *savePath = [ACDownloadManager localDownloadPathForRelativePath:video.downloadVideoLocalPath];
    
    return savePath;
    
}

+ (NSString *)localAudioPathForDownloadForVideo:(Video *)video{
    
    NSString *savePath = [ACDownloadManager localDownloadPathForRelativePath:video.downloadAudioLocalPath];
    
    return savePath;
    
}

+ (NSString *)localDownloadPathForRelativePath:(NSString *)relativePath{
    
    NSString *savePath = [NSString stringWithFormat:@"%@/%@",[ACDownloadManager downloadsDirectoryPath], relativePath];
    
    return savePath;
    
}

+ (BOOL)saveFinishedDownloadForVideo:(Video *)video fileURL:(NSURL *)tempURL downloadTask:(NSURLSessionDownloadTask *)downloadTask{
    
    NSURL *originalRequestURL = [[downloadTask originalRequest] URL];
    NSString *relativePath = [ACDownloadManager relativePathForVideo:video downloadURL:originalRequestURL];
    NSString *localDownloadPath = [ACDownloadManager localDownloadPathForRelativePath:relativePath];
    
    CLS_LOG(@"Got Download Path");
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSURL *destinationURL = [NSURL fileURLWithPath:localDownloadPath];
    NSError *errorCopy;
    
    // For the purposes of testing, remove any esisting file at the destination.
    [fileManager removeItemAtURL:destinationURL error:NULL];
    BOOL success = [fileManager copyItemAtURL:tempURL toURL:destinationURL error:&errorCopy];
    
    if (success)
    {
        
        [ACDownloadManager addSkipBackupAttributeToItemAtPath:localDownloadPath];
        return YES;
    }
    else
    {

        CLS_LOG(@"Error during the copy: %@", [errorCopy localizedDescription]);
        
        return NO;
    }
    
}


+ (BOOL)addSkipBackupAttributeToItemAtPath:(NSString *) filePathString
{
    NSURL* URL= [NSURL fileURLWithPath: filePathString];
    assert([[NSFileManager defaultManager] fileExistsAtPath: [URL path]]);
    
    NSError *error = nil;
    BOOL success = [URL setResourceValue: [NSNumber numberWithBool: YES]
                                  forKey: NSURLIsExcludedFromBackupKey error: &error];
    if(!success){
        NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
    }
    return success;
}


+ (NSString *)relativePathForVideo:(Video *)video downloadURL:(NSURL *)downloadURL{
    
    NSString *initName = [NSString stringWithFormat:@"%@", [downloadURL lastPathComponent]];
    NSString *relativePath = [NSString stringWithFormat:@"%@_%@", video.vId, initName];
    
    return relativePath;
}

#define APPLICATION_DOWNLOADS_DIRECTORY @"Downloads"
+ (NSString *)downloadsDirectoryPath
// Returns the path to the caches directory.  This is a class method because it's
// used by +applicationStartup.
{
    NSString *      result;
    NSArray *       paths;
    
    result = nil;
    paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    if ( (paths != nil) && ([paths count] != 0) ) {
        assert([[paths objectAtIndex:0] isKindOfClass:[NSString class]]);
        result = [paths objectAtIndex:0];
    }
    result = [result stringByAppendingPathComponent:APPLICATION_DOWNLOADS_DIRECTORY];
    if (![[NSFileManager defaultManager] fileExistsAtPath:result]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:result withIntermediateDirectories:YES attributes:nil error:NULL];
    }
    
    return result;
}


#pragma mark - Auto Download Tracking

static NSString *kDefaultsKeyPreviousDownloads = @"PreviousAutoDownloads";

+ (void)trackAutoDownload:(Video *)video{
    
    CLS_LOG(@"Track auto download");
    
    NSArray *previousDownloads = [ACDownloadManager previousDownloads];
    
    //only want to track a limited number of previous auto-downloads for performance
    NSMutableArray *stack = [[NSMutableArray alloc] initWithArray:previousDownloads];
    [stack push:video.vId];
    previousDownloads = stack;
    
    [[NSUserDefaults standardUserDefaults] setObject:previousDownloads forKey:kDefaultsKeyPreviousDownloads];
    
}

+ (BOOL)alreadyAutoDownloadedVideo:(Video *)video{
    
    NSArray *previousDownloads = [ACDownloadManager previousDownloads];
    
    for (NSString *videoID in previousDownloads) {
        
        if ([videoID isEqualToString:video.vId] == YES) {
            return YES;
        }
        
    }
    
    return NO;
    
}

+ (NSArray *)previousDownloads{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *previousDownloads = [defaults objectForKey:kDefaultsKeyPreviousDownloads];
    
    if (previousDownloads == nil) {
        previousDownloads = @[];
    }
    
    return previousDownloads;
    
}

@end
