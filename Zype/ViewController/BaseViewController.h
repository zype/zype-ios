//
//  BaseCollectionViewController.h
//
//  Created by ZypeTech on 6/20/15.
//  Copyright (c) 2015 Zype. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "GAITrackedViewController.h"
#import "GAIFields.h"
#import "RESTServiceController.h"
#import "BaseCollectionController.h"
#import "BaseTableController.h"
#import "ACActionSheetManager.h"
#import "UIViewController+AC.h"

@import WebKit;

@interface BaseViewController : UIViewController<EpisodeControllerDelegate, ACActionSheetManagerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UILabel *noResultsLabel;

@property (strong, nonatomic) EpisodeController *episodeController;
@property (nonatomic, strong) ACActionSheetManager *actionSheetManager;

@property (strong, nonatomic) Video *actionVideo;
@property (strong, nonatomic) Video *selectedVideo;
@property (strong, nonatomic) NSIndexPath *indexPathInAction;
@property (nonatomic) BOOL doneLoadingFromNetwork;

- (void)setDownloadStartedForDownloadTask:(NSURLSessionDownloadTask *)downloadTask;
- (void)setDownloadProgress:(float)progress downloadTask:(NSURLSessionDownloadTask *)downloadTask;
- (void)setDownloadSavingFileDownloadTask:(NSURLSessionDownloadTask *)downloadTask;
- (void)setDownloadFinishedWithMediaType:(NSString *)mediaType downloadTask:(NSURLSessionDownloadTask *)downloadTask;
- (void)setNoDownloadForDownloadTask:(NSURLSessionDownloadTask *)downloadTask;
- (void)trackScreenName:(NSString *)name;

- (void)setNoResultsMessage;

@end
