//
//  PlaylistCollectionCell.h
//  Zype
//
//  Created by Александр on 27.11.2017.
//  Copyright © 2017 Zype. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Playlist.h"
#import "Video.h"

@protocol PlaylistCollectionCellDelegate;
@interface PlaylistCollectionCell : UITableViewCell

@property (nonatomic, weak) id <PlaylistCollectionCellDelegate> delegate;

- (void)configureCell:(Playlist *)playlist;

//+ (CGSize)cellSize;
+ (CGSize)cellPosterLayoutSize;
+ (CGSize)cellLanscapeLayoutSize;
+ (CGFloat)rowHeight;
+ (CGFloat)rowPosterHeight;

@end

@protocol PlaylistCollectionCellDelegate <NSObject>

- (void)onDidSelectItem:(PlaylistCollectionCell *)cell item:(NSObject *)item;

@end
