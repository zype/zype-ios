//
//  EPGCollectionVIewLayout.m
//  Zype
//
//  Created by Top developer on 5/7/19.
//  Copyright © 2019 Zype. All rights reserved.
//

#import "EPGCollectionViewLayout.h"

static double const kGuideHourWidth = 300.0;
static double const kGuidePadding = 2.0;
static double const kGuideRowHeight = 70.0;
static double const kGuideTimesHeight = 50.0;
static double const kGuideChannelWidth = 100.0;
static double const kGuideIndicatorHeight = 2.0;

@implementation EPGCollectionViewLayout

- (void)prepareLayout {
    if (self.collectionView == NULL) {
        return;
    }
    id<EPGCollectionViewDelegate> delegate = (id<EPGCollectionViewDelegate>)self.collectionView.delegate;
    
    double currentY = kGuidePadding;
    self.frames = [[NSMutableArray alloc] init];
    self.channelHeaderFrames = [[NSMutableArray alloc] init];
    self.timeHeaderFrames = [[NSMutableArray alloc] init];
    
    for (int section = 0; section < self.collectionView.numberOfSections; section++) {
        double currentX = kGuidePadding * 0.5;
        double prevLastX = kGuidePadding * 0.5;
        
        NSMutableArray* sectionFrames = [[NSMutableArray alloc] init];
        NSInteger sectionItems = [self.collectionView numberOfItemsInSection:section];
        for (int item = 0; item < sectionItems; item++) {
            double runtime = [delegate collectionView:self.collectionView collectionViewLayout:self runtimeForProgramAtIndexPath:[NSIndexPath indexPathForItem:item inSection:section]];
            double startX = [delegate collectionView:self.collectionView collectionViewLayout:self startForProgramAtIndexPath:[NSIndexPath indexPathForItem:item inSection:section]];
            
            double width = kGuideHourWidth * runtime / 3600.0;
            currentX = kGuidePadding * 0.5 + kGuideHourWidth * startX / 3600.0;
            
            double cellWidth = width - kGuidePadding;
            if (currentX < prevLastX) {
                currentX = prevLastX;
                double diff = prevLastX - currentX;
                cellWidth = cellWidth - diff;
            }
            
            CGRect rect = CGRectMake(currentX + kGuidePadding * 0.5, currentY, MAX(0, cellWidth), kGuideRowHeight);
            [sectionFrames addObject: [NSValue valueWithCGRect: rect]];
            
            prevLastX = currentX + cellWidth + kGuidePadding;
        }
        
        [self.frames addObject:sectionFrames];
        [self.channelHeaderFrames addObject: [NSValue valueWithCGRect: CGRectMake(0, currentY, kGuideChannelWidth, kGuideRowHeight)]];
        
        if (self.channelHeaderFrames.lastObject != NULL) {
            currentY = CGRectGetMaxY([self.channelHeaderFrames.lastObject CGRectValue]) + kGuidePadding;
        }
    }
    
    if (self.collectionView.numberOfSections > 0) {
        double currentX = kGuidePadding * 0.5;
        while (currentX < self.collectionViewContentSize.width) {
            [self.timeHeaderFrames addObject: [NSValue valueWithCGRect: CGRectMake(currentX, 0, kGuideHourWidth * 0.5, kGuideTimesHeight)]];
            currentX = CGRectGetMaxX([self.timeHeaderFrames.lastObject CGRectValue]);
        }
    }
    
    if (self.channelHeaderFrames.count > 0) {
        double timeInterval = [delegate timeIntervalForTimeIndicatorForCollectionView:self.collectionView collectionViewLayout:self];
        double indicatorWidth = kGuidePadding * 0.5 + (kGuideHourWidth * timeInterval / 3600.0);
        self.timeIndicatorFrame = CGRectMake(0, kGuideTimesHeight, indicatorWidth, kGuideIndicatorHeight);
    }
    
    self.collectionView.contentInset = UIEdgeInsetsMake(kGuideTimesHeight, kGuideChannelWidth + kGuidePadding * 0.5, 0, 0);
}

- (CGSize)collectionViewContentSize {
    double maxX = 0.0, maxY = 0.0;
    
    for (NSMutableArray* sectionFrames in self.frames) {
        if (sectionFrames.lastObject == NULL) {
            continue;
        }
        maxX = MAX(maxX, CGRectGetMaxX([sectionFrames.lastObject CGRectValue]));
        maxY = MAX(maxY, CGRectGetMaxY([sectionFrames.lastObject CGRectValue]));
    }
    
    return CGSizeMake(maxX + kGuidePadding * 2, maxY + kGuidePadding * 2);
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath {
    if (self.collectionView == NULL) {
        return NULL;
    }
    
    UICollectionViewLayoutAttributes* attributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:elementKind withIndexPath:indexPath];

    if ([elementKind isEqual: @"EPGChannelView"]) {
        CGRect frame = [self.channelHeaderFrames[indexPath.section] CGRectValue];
        frame.origin.x = self.collectionView.contentOffset.x;
        attributes.frame = frame;
        attributes.zIndex = 3;
    } else if ([elementKind isEqual: @"ChannelSeparator"]) {
        attributes.frame = CGRectMake(self.collectionView.contentOffset.x + kGuideChannelWidth,
                                      self.collectionView.contentOffset.y,
                                      kGuidePadding,
                                      self.collectionView.frame.size.height);
        attributes.zIndex = 9;
    } else if ([elementKind isEqual: @"EPGDateView"]) {
        CGRect frame = CGRectMake(0, 0, kGuideChannelWidth, kGuideTimesHeight);
        frame.origin.x = self.collectionView.contentOffset.x;
        frame.origin.y = self.collectionView.contentOffset.y;
        attributes.zIndex = 8;
        attributes.frame = frame;
    } else if ([elementKind isEqual: @"EPGTimeView"]) {
        CGRect frame = [self.timeHeaderFrames[indexPath.item] CGRectValue];
        frame.origin.y = self.collectionView.contentOffset.y;
        attributes.zIndex = 5;
        attributes.frame = frame;
    } else if ([elementKind isEqual: @"TimeSeparator"]) {
        CGRect frame = CGRectMake(0,
                                  self.collectionView.contentOffset.y + (kGuideTimesHeight - kGuideIndicatorHeight),
                                  self.timeHeaderFrames.count * kGuideHourWidth,
                                  kGuideIndicatorHeight);
        frame.origin.y = self.collectionView.contentOffset.y + (kGuideTimesHeight - kGuideIndicatorHeight);
        attributes.frame = frame;
        attributes.zIndex = 6;
    } else if ([elementKind isEqual: @"TimeIndicator"]) {
        CGRect frame = self.timeIndicatorFrame;
        frame.origin.y = self.collectionView.contentOffset.y + (kGuideTimesHeight - kGuideIndicatorHeight);
        attributes.frame = frame;
        attributes.zIndex = 7;
    } else if ([elementKind isEqual: @"ChannelBackground"]) {
        if (indexPath.item == 0) {
            attributes.frame = CGRectMake(self.collectionView.contentOffset.x, self.collectionView.contentOffset.y + kGuideTimesHeight, kGuideChannelWidth, self.collectionView.frame.size.height - kGuideTimesHeight);
            attributes.zIndex = 2;
        }
        else {
            attributes.frame = CGRectMake(self.collectionView.contentOffset.x, self.collectionView.contentOffset.y, self.collectionView.frame.size.width, kGuideTimesHeight);
            attributes.zIndex = 4;
        }
    }
    
    return attributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewLayoutAttributes* attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    attributes.frame = [self.frames[indexPath.section][indexPath.item] CGRectValue];
    attributes.alpha = 1.0;
    attributes.zIndex = 1;
    return attributes;
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    if (self.collectionView == NULL) {
        return NULL;
    }
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    if (self.collectionView.numberOfSections > 0) {
        [array addObject: [self layoutAttributesForSupplementaryViewOfKind:@"EPGDateView" atIndexPath: [NSIndexPath indexPathForItem:0 inSection:0]]];
        [array addObject: [self layoutAttributesForSupplementaryViewOfKind:@"ChannelSeparator" atIndexPath: [NSIndexPath indexPathForItem:0 inSection:0]]];
        [array addObject: [self layoutAttributesForSupplementaryViewOfKind:@"TimeSeparator" atIndexPath: [NSIndexPath indexPathForItem:0 inSection:0]]];
        [array addObject: [self layoutAttributesForSupplementaryViewOfKind:@"TimeIndicator" atIndexPath: [NSIndexPath indexPathForItem:0 inSection:0]]];
        [array addObject: [self layoutAttributesForSupplementaryViewOfKind:@"ChannelBackground" atIndexPath: [NSIndexPath indexPathForItem:0 inSection:0]]];
        [array addObject: [self layoutAttributesForSupplementaryViewOfKind:@"ChannelBackground" atIndexPath: [NSIndexPath indexPathForItem:1 inSection:0]]];
    }
    
    for (int i=0; i<self.timeHeaderFrames.count; i++) {
        [array addObject: [self layoutAttributesForSupplementaryViewOfKind: @"EPGTimeView" atIndexPath: [NSIndexPath indexPathForItem:i inSection:0]]];
    }
    
    for (int section = 0; section < self.collectionView.numberOfSections; section++) {
        [array addObject: [self layoutAttributesForSupplementaryViewOfKind:@"EPGChannelView" atIndexPath:[NSIndexPath indexPathForItem:0 inSection:section]]];
        
        for (int item = 0; item < [self.collectionView numberOfItemsInSection:section]; item++) {
            UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:item inSection:section]];
            if (attributes == NULL) {
                continue;
            }
            
            if ( !CGRectIsEmpty(attributes.frame) && CGRectIntersectsRect(rect, attributes.frame) ) {
                [array addObject:attributes];
            }
        }
    }
    return array;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return YES;
}

@end
