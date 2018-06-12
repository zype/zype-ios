//
//  HomeCollectionViewController.h
//
//  Created by ZypeTech on 6/21/15.
//  Copyright (c) 2015 Zype. All rights reserved.
//

#import "MediaPlaybackBaseViewController.h"

@class Playlist;

@interface HomeViewController : MediaPlaybackBaseViewController

@property (nonatomic) Playlist *playlistItem;
@property (nonatomic) BOOL isLivePictureLoaded;

@end
