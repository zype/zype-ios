//
//  MediaItemCollectionCell.h
//  Zype
//
//  Created by Александр on 27.11.2017.
//  Copyright © 2017 Zype. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Playlist.h"
#import "Video.h"
#import "ZObject.h"
#import "DownloadStatusCell.h"

@interface MediaItemCollectionCell : UICollectionViewCell<DownloadStatusCell>

- (void)setPlaylist:(Playlist *)playlist;
- (void)setVideo:(Video *)video;
- (void)setZObject:(ZObject *)zObject;

@end
