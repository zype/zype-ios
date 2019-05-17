//
//  EPGCollectionVIewLayout.h
//  Zype
//
//  Created by Top developer on 5/7/19.
//  Copyright © 2019 Zype. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol EPGCollectionViewDelegate;
@interface EPGCollectionViewLayout : UICollectionViewLayout

@property (strong, nonatomic) NSMutableArray *frames;
@property (strong, nonatomic) NSMutableArray *channelHeaderFrames;
@property (strong, nonatomic) NSMutableArray *timeHeaderFrames;
@property (nonatomic) CGRect timeIndicatorFrame;

@end

@protocol EPGCollectionViewDelegate <UICollectionViewDelegate>

- (double)collectionView:(UICollectionView *)collectionView collectionViewLayout:(UICollectionViewLayout*)layout runtimeForProgramAtIndexPath:(NSIndexPath *)indexPath;
- (double)collectionView:(UICollectionView *)collectionView collectionViewLayout:(UICollectionViewLayout*)layout startForProgramAtIndexPath:(NSIndexPath *)indexPath;
- (double)timeIntervalForTimeIndicatorForCollectionView:(UICollectionView *)collectionView collectionViewLayout:(UICollectionViewLayout*)layout;

@end

NS_ASSUME_NONNULL_END
