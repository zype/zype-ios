//
//  EPGCollectionViewCell.m
//  Zype
//
//  Created by Top developer on 5/7/19.
//  Copyright © 2019 Zype. All rights reserved.
//

#import "EPGCollectionViewCell.h"

@implementation EPGCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
    backgroundView.layer.shadowColor = [UIColor colorWithWhite:0 alpha:0.2].CGColor;
    backgroundView.layer.shadowOffset = CGSizeMake(0, 10);
    backgroundView.layer.shadowRadius = 10;
    backgroundView.layer.shadowOpacity = 0.5;
    backgroundView.layer.cornerRadius = 0;
    backgroundView.backgroundColor = kEPGCellColor;
    backgroundView.alpha = 1.0;
    self.backgroundView = backgroundView;
}

@end
