//
//  EPGDateView.h
//  Zype
//
//  Created by Top developer on 5/8/19.
//  Copyright © 2019 Zype. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface EPGDateView : UICollectionReusableView

@property (weak, nonatomic) IBOutlet UILabel *lblDate;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *viewSeperator;

@end

NS_ASSUME_NONNULL_END
