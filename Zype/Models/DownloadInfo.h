//
//  DownloadInfo.h
//  Zype
//
//  Created by ZypeTech on 2/18/15.
//  Copyright (c) 2015 Zype. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DownloadInfo : NSObject

@property (strong, nonatomic) NSURLSessionDownloadTask *downloadTask;
@property (strong, nonatomic) NSString *mediaType;
@property (nonatomic) unsigned long taskIdentifier;
@property (nonatomic) double totalBytesWritten;
@property (nonatomic) double totalBytesExpectedToWrite;
@property (nonatomic) BOOL isDownloading;

- (id)initWithTask:(NSURLSessionDownloadTask *)downloadTask;
- (void)cancelDownload;

@end
