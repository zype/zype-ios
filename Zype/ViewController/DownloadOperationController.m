//
//  DownloadOperationController.m
//  Zype
//
//  Created by ZypeTech on 3/2/15.
//  Copyright (c) 2015 Zype. All rights reserved.
//

#import <Crashlytics/Crashlytics.h>
#import "DownloadOperationController.h"
#import "ACDownloadManager.h"
#import "ACSDataManager.h"
#import "ACSPersistenceManager.h"
#import "ACSAlertViewManager.h"
#import "ACSEpisodeCollectionViewCell.h"
#import "Timing.h"
#import "AppDelegate.h"

@implementation DownloadOperationController

- (instancetype)init{
    
    self = [super init];
    if (self){
        
        [self setSession:[self backgroundSession]];
        [self setArrayTasks:[NSMutableArray array]];
        _start = [NSDate date];
        
    }
    
    return self;
    
}

- (void)setDownloadProgressViewController:(BaseViewController *)viewController{
    
    [self setViewController:viewController];
    
}

- (NSURLSession *)backgroundSession{
    
    static NSURLSession *session = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        // Session Configuration
        NSURLSessionConfiguration *sessionConfiguration;
        
        sessionConfiguration =[NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:kBackgroundSession];
        
        // Initialize Session
        session = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:self delegateQueue:nil];
        
    });
    
    return session;
    
}

- (void)startDownload:(Video *)video WithMediaType:(NSString *)mediaType{
    
    if (!mediaType){
        
        if ([[[NSUserDefaults standardUserDefaults] stringForKey:kSettingKey_DownloadPreferences] isEqualToString:kSettingKey_DownloadAudio]){
            mediaType = kMediaType_Audio;
        }else if ([[[NSUserDefaults standardUserDefaults] stringForKey:kSettingKey_DownloadPreferences] isEqualToString:kSettingKey_DownloadVideo]){
            mediaType = kMediaType_Video;
        }
        
    }
    
    if ([mediaType isEqualToString:kMediaType_Video]){
        
        [ACSDataManager downloadVideoUrlForVideoId:video.vId urlBlock:^(NSURL *url, NSError *error) {
           
            if ([url.absoluteString isEqualToString:@""] == NO) {
                
                video.downloadVideoUrl = url.absoluteString;
                [[ACSPersistenceManager sharedInstance] saveContext];
                
                [self download:video WithMediaType:mediaType AtUrl:url.absoluteString];
                
            }else{
                [ACSAlertViewManager showAlertWithTitle:kString_TitleDownloadFail WithMessage:kString_MessageNoDownloadFile];
            }
            
        }];

        
    }else if ([mediaType isEqualToString:kMediaType_Audio]){
        
        [ACSDataManager downloadAudioUrlForVideoId:video.vId urlBlock:^(NSURL *url, NSError *error) {
            
            if ([url.absoluteString isEqualToString:@""] == NO) {
                
                video.downloadAudioUrl = url.absoluteString;
                [[ACSPersistenceManager sharedInstance] saveContext];
                
                [self download:video WithMediaType:mediaType AtUrl:url.absoluteString];
                
            }else{
                [ACSAlertViewManager showAlertWithTitle:kString_TitleDownloadFail WithMessage:kString_MessageNoDownloadFile];
            }
            
        }];

    }
    
}

- (void)download:(Video *)video WithMediaType:(NSString *)mediaType AtUrl:(NSString *)url{
    
    // Schedule Download Task
    NSURLSessionDownloadTask *downloadTask = [self.session downloadTaskWithURL:[NSURL URLWithString:url]];
    NSNumber *taskID = [NSNumber numberWithUnsignedLong:downloadTask.taskIdentifier];
    
    //in case videos have old task ids associated, we clear them out when starting a new download
    [ACSPersistenceManager resetVideosWithDownloadTaskID:taskID];
    
    // Save taskIdentifier in core data
    video.downloadTaskId = taskID;
    [[ACSPersistenceManager sharedInstance] saveContext];
    
    // Add task in array
    DownloadInfo *downloadInfo = [[DownloadInfo alloc] initWithTask:downloadTask];
    downloadInfo.isDownloading = YES;
    downloadInfo.mediaType = mediaType;
    [self.arrayTasks addObject:downloadInfo];
    
    // Start download
    [downloadTask resume];
    
    if (self.viewController != nil) {
        [self.viewController setDownloadStartedForDownloadTask:downloadTask];
    }

    
    NSString *stringTaskIds = @"";
    
    for (DownloadInfo *downloadInfo in self.arrayTasks) {
        stringTaskIds = [stringTaskIds stringByAppendingString:[NSString stringWithFormat:@"%lu, ", downloadInfo.taskIdentifier]];
    }
    
    CLS_LOG(@"Current Task IDs: %@", stringTaskIds);
    
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes{
    
    
    
    CLS_LOG(@"%s", __PRETTY_FUNCTION__);
    
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite{
    
    // Save progress in download info
    if (totalBytesWritten > 0 && totalBytesExpectedToWrite >= totalBytesWritten) {
        
        DownloadInfo *downloadInfo = [self downloadInfoWithTaskId:[NSNumber numberWithUnsignedLong:downloadTask.taskIdentifier]];
        downloadInfo.totalBytesWritten = totalBytesWritten;
        downloadInfo.totalBytesExpectedToWrite = totalBytesExpectedToWrite;
        float progress = (double)totalBytesWritten / (double)totalBytesExpectedToWrite;
        
        if (self.viewController != nil) {
            [self.viewController setDownloadProgress:progress downloadTask:downloadTask];
        }

    }
    
}


- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location{
    
    // Save progress in download info
    DownloadInfo *downloadInfo = [self downloadInfoWithTaskId:[NSNumber numberWithUnsignedLong:downloadTask.taskIdentifier]];
    downloadInfo.isDownloading = NO;
    [self.arrayTasks removeObject:downloadInfo];
    CLS_LOG(@"Removed Task ID: %lu", downloadInfo.taskIdentifier);

    // Update video object
    __block Video *downloadedVideo = [self videoForDownloadTask:downloadTask];
    
    //we should check for an error because the task can fail and still call this method.
    if (downloadTask.error != nil){
        
        CLS_LOG(@"downloadtask failed with error: %@", downloadTask.error.localizedDescription);
        [ACSAlertViewManager showAlertWithTitle:@"Problem Saving File" WithMessage:downloadTask.error.localizedDescription];
        [ACSPersistenceManager resetDownloadStatusOfVideo:downloadedVideo];
        [self viewResetDownloadTask:downloadTask];
        return;
        
    }
    
    if (self.viewController != nil) {
        [self.viewController setDownloadSavingFileDownloadTask:downloadTask];
    }
    
    if ([ACDownloadManager saveFinishedDownloadForVideo:downloadedVideo fileURL:location downloadTask:downloadTask] == YES) {

        NSURL *originalRequestURL = [[downloadTask originalRequest] URL];
        NSString *savedFilePath = [ACDownloadManager relativePathForVideo:downloadedVideo downloadURL:originalRequestURL];
        
        if ([downloadInfo.mediaType isEqualToString:kMediaType_Audio]){
            
            downloadedVideo.downloadAudioLocalPath = savedFilePath;
            if (self.viewController != nil) {
                [self.viewController setDownloadFinishedWithMediaType:kMediaType_Audio downloadTask:downloadTask];
            }
            
        }else if ([downloadInfo.mediaType isEqualToString:kMediaType_Video]){
            
            downloadedVideo.downloadVideoLocalPath = savedFilePath;
            if (self.viewController != nil) {
                [self.viewController setDownloadFinishedWithMediaType:kMediaType_Video downloadTask:downloadTask];
            }
            
        }
        
        downloadedVideo.isDownload = @YES;
        downloadedVideo.downloadTaskId = @-1;
        [[ACSPersistenceManager sharedInstance] saveContext];
        

    }else{
        
        [ACSPersistenceManager resetDownloadStatusOfVideo:downloadedVideo];
        [self viewResetDownloadTask:downloadTask];
        [ACSAlertViewManager showAlertWithTitle:@"Problem Saving File" WithMessage:@"There was a problem saving the file.  There may not be room on your device."];
        
    }
    
    // Invoke Background Completion Handler
    [self invokeBackgroundSessionCompletionHandler];
    
}

- (void)viewResetDownloadTask:(NSURLSessionDownloadTask *)downloadTask{
    
    if (self.viewController != nil) {
        [self.viewController setNoDownloadForDownloadTask:downloadTask];
    }
    
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
    
    if (error)
        CLS_LOG(@"Downloading failed! %@", error.description);
    else
    {
        CLS_LOG(@"Downloading finished");
//        [Timing recordTimingForOperationWithCategory:kLoadTime andStartDate:_start andName:@"Download Operation" andLabel:@"Download Finished"];
    }
    
}

- (Video *)videoForDownloadTask:(NSURLSessionDownloadTask *)downloadTask{
    
    Video *video = [ACSPersistenceManager videoForDownloadTaskID:[NSNumber numberWithUnsignedInteger: downloadTask.taskIdentifier]];
    return video;
    
}

- (DownloadInfo *)downloadInfoWithTaskId:(NSNumber *)taskIdentifier{
    
    if (taskIdentifier.integerValue < 0) {
        return nil;
    }
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"taskIdentifier==%@", taskIdentifier];
    NSArray *results = [self.arrayTasks filteredArrayUsingPredicate:predicate];
    
    if (results.count > 0) {
        
        DownloadInfo *downloadInfo = results[0];
        return downloadInfo;
        
    }else{
        return nil;
    }
    
}

- (void)invokeBackgroundSessionCompletionHandler{
    
    [self.session getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
        
        NSUInteger count = [dataTasks count] + [uploadTasks count] + [downloadTasks count];
        
        if (!count){
            
            void (^backgroundSessionCompletionHandler)() = [AppDelegate appDelegate].backgroundSessionCompletionHandler;
            
            if (backgroundSessionCompletionHandler) {
                
                // Make nil the backgroundTransferCompletionHandler
                [[AppDelegate appDelegate] setBackgroundSessionCompletionHandler:nil];
                [self.arrayTasks removeAllObjects];
                
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    // Call the completion handler to tell the system that there are no other background transfers
                    backgroundSessionCompletionHandler();
                }];
                
            }
            
        }
        
    }];
    
}


#pragma mark - Singleton

+ (instancetype)sharedInstance {
    
    static DownloadOperationController *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[[self class] alloc] init];
    });
    
    return _sharedInstance;
    
}


@end
