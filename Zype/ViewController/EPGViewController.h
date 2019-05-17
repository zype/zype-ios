//
//  EPGViewController.h
//  Zype
//
//  Created by Top developer on 5/7/19.
//  Copyright © 2019 Zype. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GAITrackedViewController.h"
#import "EPGCollectionViewLayout.h"
#import "EPGDateView.h"
#import "GuideModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface EPGViewController : GAITrackedViewController<EPGCollectionViewDelegate, UICollectionViewDataSource>

@property (retain, nonatomic) EPGDateView* dateHeaderView;
@property (retain, nonatomic) NSMutableArray<GuideModel*>* guides;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;

@end

NS_ASSUME_NONNULL_END
