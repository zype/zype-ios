//
//  ACDownloadManager.h
//
//  Created by ZypeTech on 5/28/15.
//  Copyright (c) 2015 Zype. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Video;

@interface ACDownloadManager : NSObject

+ (void)autoDownloadLatestVideo;
+ (BOOL)shouldAutoDownload;
+ (BOOL)alreadyDownloadedVideo:(Video *)video;
+ (void)backgroundDownloadVideo:(Video *)video atIndex:(NSIndexPath *)indexPath;
+ (void)stopDownloadingVideo:(Video *)video;
+ (void)deleteDownloadedVideo:(Video *)video;
+ (void)resetDownloads;

//Video Downloads

+ (NSString *)localDownloadPathForRelativePath:(NSString *)relativePath;
+ (NSString *)localPathForDownloadedVideo:(Video *)video;
+ (NSString *)localAudioPathForDownloadForVideo:(Video *)video;
+ (NSString *)relativePathForVideo:(Video *)video downloadURL:(NSURL *)downloadURL;
+ (BOOL)fileDownloadedForVideo:(Video *)video;

+ (BOOL)saveFinishedDownloadForVideo:(Video *)video fileURL:(NSURL *)tempURL downloadTask:(NSURLSessionDownloadTask *)downloadTask;

@end
