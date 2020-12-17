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
#import "SubscriptionPlanDelegate.h"

@import WebKit;

@interface BaseViewController : UIViewController<EpisodeControllerDelegate, ACActionSheetManagerDelegate, SubscriptionPlanDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UILabel *noResultsLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;
@property (weak, nonatomic) IBOutlet UILabel *NoResultsLabelTitle;

@property (strong, nonatomic) EpisodeController *episodeController;
@property (nonatomic, strong) ACActionSheetManager *actionSheetManager;
@property (weak, nonatomic) id<SubscriptionPlanDelegate> planDelegate;

@property (strong, nonatomic) Video *actionVideo;
@property (strong, nonatomic) Video *selectedVideo;
@property (strong, nonatomic) NSIndexPath *indexPathInAction;

- (void)setDownloadStartedForDownloadTask:(NSURLSessionDownloadTask *)downloadTask;
- (void)setDownloadProgress:(float)progress downloadTask:(NSURLSessionDownloadTask *)downloadTask;
- (void)setDownloadSavingFileDownloadTask:(NSURLSessionDownloadTask *)downloadTask;
- (void)setDownloadFinishedWithMediaType:(NSString *)mediaType downloadTask:(NSURLSessionDownloadTask *)downloadTask;
- (void)setNoDownloadForDownloadTask:(NSURLSessionDownloadTask *)downloadTask;
- (void)trackScreenName:(NSString *)name;

- (void)setNoResultsMessage;

@end
