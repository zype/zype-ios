//
//  PlaylistCollectionCell.m
//  Zype
//
//  Created by Александр on 27.11.2017.
//  Copyright © 2017 Zype. All rights reserved.
//

#import "PlaylistCollectionCell.h"
#import "MediaItemCollectionCell.h"
#import "ACSPersistenceManager.h"
#import "ACSPredicates.h"
#import <TLIndexPathController.h>

@interface PlaylistCollectionCell() <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) NSArray *items;

@end


@implementation PlaylistCollectionCell

- (void)awakeFromNib {
    [super awakeFromNib];
     
    [self.collectionView registerNib:[UINib nibWithNibName:@"MediaItemCollectionCell" bundle:nil] forCellWithReuseIdentifier:@"MediaItemCollectionCell"];
    [self.collectionView setDelegate:self];
    [self.collectionView setDataSource:self];
    self.items = @[];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)configureCell:(Playlist *)playlist {
    self.titleLabel.text = playlist.title;

    if (playlist.playlist_item_count.integerValue > 0) {
        NSArray<PlaylistVideo *> *playlistVideos = [ACSPersistenceManager playlistVideosFromPlaylistId:playlist.pId];
        NSMutableArray *filterArray = [[NSMutableArray alloc] init];
        
        for (PlaylistVideo *currentPlaylistVideo in playlistVideos) {
            Video *currentVideo = currentPlaylistVideo.video;
            
            if (![filterArray containsObject:currentVideo]){
                [filterArray addObject:currentVideo];
            }
        }

        self.items = filterArray;
    } else {
        NSArray<Playlist *> *playlistVideos = [ACSPersistenceManager getPlaylistsWithParentID:playlist.pId];
        self.items = playlistVideos;
    }

    [self.collectionView reloadData];
}

#pragma mark - CollectionView

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.items.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(150, 80);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 12;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 12;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self.delegate onDidSelectItem:self item:self.items[indexPath.row]];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MediaItemCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MediaItemCollectionCell" forIndexPath:indexPath];
    if ([self.items[indexPath.row] isKindOfClass:[Playlist class]]) {
        Playlist *playlist = self.items[indexPath.row];
        [cell setPlaylist:playlist];
    } else if ([self.items[indexPath.row] isKindOfClass:[Video class]]) {
        Video *video = self.items[indexPath.row];
        [cell setVideo:video];
    }
    return cell;
}

@end
