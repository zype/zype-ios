//
//  SubscriptActiveCell.m
//  Zype
//
//  Created by Александр on 16.04.17.
//  Copyright © 2017 Zype. All rights reserved.
//

#import "SubscriptActiveCell.h"
#import "UIView+UIView_CustomizeTheme.h"

@implementation SubscriptActiveCell

@synthesize backgroundView;

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    [self.continueButton tintCustomizeTheme];
    [self.continueButton round:kViewCornerRounded];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

//- (void)setSelectedCell:(BOOL)isSelected {
//    self.backgroundView.hidden = !isSelected;
//    self.radioButtonPoint.hidden = !isSelected;
//}

- (void)configureCell:(SKPayment *)payment {
    self.payment = payment;
    self.descriptionLabel.text = @"Description text explaining what opting into this subsciption plan actually. entails. If we have a description here at all, client should be able to edit this.";
    [self.continueButton setTitle:[NSString stringWithFormat:@"Continue with %@", self.titleLabel.text] forState:UIControlStateNormal];
}

- (IBAction)acceptSubscriptButtonTapped:(id)sender {
    [self.delegate onDidTapSubsciptCell:self productID:self.payment.productIdentifier];
}


@end
