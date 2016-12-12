//
//  DownloadInfo.m
//  Zype
//
//  Created by ZypeTech on 2/18/15.
//  Copyright (c) 2015 Zype. All rights reserved.
//

#import "DownloadInfo.h"

@implementation DownloadInfo

- (id)initWithTask:(NSURLSessionDownloadTask *)downloadTask
{
    if (self)
    {
        self.downloadTask = downloadTask;
        self.mediaType = @"";
        self.taskIdentifier = downloadTask.taskIdentifier;
        self.totalBytesWritten = 0.0;
        self.totalBytesExpectedToWrite = 0.0;
        self.isDownloading = NO;
    }
    
    return self;
}

- (void)cancelDownload{
    
    self.isDownloading = NO;
    [self.downloadTask cancelByProducingResumeData:^(NSData *resumeData) {
        
        
    }];
    
}

@end
