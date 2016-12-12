//
//  DownloadOperationController.h
//  Zype
//
//  Created by ZypeTech on 3/2/15.
//  Copyright (c) 2015 Zype. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseViewController.h"
#import "DownloadInfo.h"

@interface DownloadOperationController : NSObject <NSURLSessionDelegate, NSURLSessionDownloadDelegate>

@property (strong, nonatomic) BaseViewController *viewController;
@property (strong, nonatomic) NSURLSession *session;
@property (strong, nonatomic) NSMutableArray *arrayTasks;
@property (strong, nonatomic) NSDate *start;

- (void)setDownloadProgressViewController:(BaseViewController *)viewController;
- (void)startDownload:(Video *)video WithMediaType:(NSString *)mediaType;
- (DownloadInfo *)downloadInfoWithTaskId:(NSNumber *)taskIdentifier;

//Singleton
+ (instancetype)sharedInstance;

@end
