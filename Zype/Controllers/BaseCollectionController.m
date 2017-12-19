//
//  BaseCollectionController.m
//  acumiashow
//
//  Created by ZypeTech on 6/20/15.
//  Copyright (c) 2015 Zype. All rights reserved.
//

#import "BaseCollectionController.h"
#import "ACSEpisodeCollectionViewCell.h"
#import "PlaylistCollectionViewCell.h"
#import "Video.h"
#import "Playlist.h"

#define kRowCellCountOrientationLandscape 3
#define kRowCellCountOrientationPortrait 2
#define kImageCellAcpectRatio 0.5625 // 9/16 ratio
#define kPaddingBeetweenCells 10
#define kPlaylistCollectionCellLabelHeight 50

@interface BaseCollectionController ()

@property (strong, nonatomic) NSMutableDictionary *objectChanges;
@property (strong, nonatomic) NSMutableDictionary *sectionChanges;

@end

@implementation BaseCollectionController


- (id<DownloadStatusCell>)cellForDownloadTaskID:(NSNumber *)downloadTaskID{
    
    Video *video = [self videoForDownloadTaskID:downloadTaskID];
    
    if (video != nil && self != nil && self.indexPathController.dataModel != nil && self.collectionView != nil) {
        NSIndexPath *indexPath = [self.indexPathController.dataModel indexPathForItem:video];
        ACSEpisodeCollectionViewCell *cell = (ACSEpisodeCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
        return cell;
    }
    
    return nil;
    
}



- (instancetype)initWithCollectionView:(UICollectionView *)collectionView{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _collectionView = collectionView;
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    
    [_collectionView registerClass:[ACSEpisodeCollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    [_collectionView registerNib:[UINib nibWithNibName:@"ACSEpisodeCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:reuseIdentifier];
    
    [_collectionView registerClass:[PlaylistCollectionViewCell class] forCellWithReuseIdentifier:reusePlaylistIdentifier];
    [_collectionView registerNib:[UINib nibWithNibName:@"PlaylistCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:reusePlaylistIdentifier];
    //[_collectionView setContentInset:UIEdgeInsetsMake(40, 0, 0, 0)];
    
    self.scrollView = _collectionView;
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(orientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];

    return self;
}


#pragma mark - Overrides


- (void)reloadData {
    [self.collectionView reloadData];
}

#pragma mark - Option Button Action

- (void)buttonActionTapped:(id)sender
{
    CGPoint touchPoint = [sender convertPoint:CGPointZero toView:self.collectionView];
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:touchPoint];
    [self.delegate episodeControllerDelegateButtonActionTappedAtIndexPath:indexPath];

}


#pragma mark - <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    return self.indexPathController.dataModel.numberOfSections;
    
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {

    NSUInteger number = [self.indexPathController.dataModel numberOfRowsInSection:section];
    [self.delegate episodeControllerDelegateShowEmptyMessage:number];
    
    return number;
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
     if ([[self.indexPathController.dataModel itemAtIndexPath:indexPath] isKindOfClass:[Video class]]){
         ACSEpisodeCollectionViewCell *cell = (ACSEpisodeCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
         
         Video *video = [self.indexPathController.dataModel itemAtIndexPath:indexPath];
         
         [cell setVideo:video];
         [cell.actionButton addTarget:self action:@selector(buttonActionTapped:) forControlEvents:UIControlEventTouchUpInside];
         
         return cell;
     } else if ([[self.indexPathController.dataModel itemAtIndexPath:indexPath] isKindOfClass:[Playlist class]]){
         PlaylistCollectionViewCell *cell = (PlaylistCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:reusePlaylistIdentifier forIndexPath:indexPath];
         
         Playlist *playlist = [self.indexPathController.dataModel itemAtIndexPath:indexPath];
         
         [cell setPlaylist:playlist];
         return cell;
     } else {
         return [UICollectionViewCell new];//app will crash if it reaches this point
     }
    
}


#pragma mark <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    [self.delegate episodeControllerDidSelectItemAtIndexPath:indexPath];
    [self.collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
}

#pragma mark - <UICollectionViewDelegateFlowLayout>

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    int cellCountInLine = kRowCellCountOrientationPortrait;
    CGFloat screenWidth = collectionView.frame.size.width;
    if (isLandscape) {
        cellCountInLine = kRowCellCountOrientationLandscape;
    }
    
    CGFloat width = screenWidth / cellCountInLine;
    CGFloat height = width * kImageCellAcpectRatio + kPlaylistCollectionCellLabelHeight;
    CGSize size = CGSizeMake(width - kPaddingBeetweenCells - CGFLOAT_MIN, height);
    
    return size;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, kPaddingBeetweenCells * 2, 0, 0);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeMake(collectionView.frame.size.width, kPaddingBeetweenCells * 2);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return CGFLOAT_MIN;
}

// MARK: - Notification Center

- (void)orientationDidChange:(NSNotification*)notification {
    [self reloadData];
}

//- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
//    return 16;
//}
//
//- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
//    return 16;
//}








@end
