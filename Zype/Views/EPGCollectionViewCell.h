//
//  EPGCollectionViewCell.h
//  Zype
//
//  Created by Top developer on 5/7/19.
//  Copyright © 2019 Zype. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EPGProgramLabel.h"

NS_ASSUME_NONNULL_BEGIN

@interface EPGCollectionViewCell : UICollectionViewCell

@property (nonatomic) BOOL airing;

@property (weak, nonatomic) IBOutlet EPGProgramLabel *lblTitle;

@end

NS_ASSUME_NONNULL_END
