//
//  HomeCollectionViewController.h
//
//  Created by ZypeTech on 6/21/15.
//  Copyright (c) 2015 Zype. All rights reserved.
//

#import "MediaPlaybackBaseViewController.h"

@interface LatestViewController : MediaPlaybackBaseViewController

@property (nonatomic) BOOL isLivePictureLoaded;

- (void)resetFilter;

@end
