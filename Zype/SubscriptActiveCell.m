//
//  SubscriptActiveCell.m
//  Zype
//
//  Created by Александр on 16.04.17.
//  Copyright © 2017 Zype. All rights reserved.
//

#import "SubscriptActiveCell.h"

@implementation SubscriptActiveCell

@synthesize backgroundView;

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundView.layer.cornerRadius = 5;
    self.backgroundView.layer.borderColor = [UIColor colorWithRed:0.54 green:0.86 blue:0.96 alpha:1.0].CGColor;
    self.backgroundView.layer.borderWidth = 1;
    
    self.continueButton.layer.cornerRadius = 5;
    
    self.radioView.layer.cornerRadius = self.radioView.frame.size.height / 2;
    self.radioButtonPoint.layer.cornerRadius = self.radioButtonPoint.frame.size.height / 2;
    self.radioView.layer.borderColor = [UIColor colorWithRed:0.54 green:0.86 blue:0.96 alpha:1.0].CGColor;
    self.radioView.layer.borderWidth = 1;
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setSelectedCell:(BOOL)isSelected {
    self.backgroundView.hidden = !isSelected;
    self.radioButtonPoint.hidden = !isSelected;
}

- (void)configureCell:(SKPayment *)payment {
    self.payment = payment;
    self.descriptionLabel.text = payment.productIdentifier;
    [self.continueButton setTitle:[NSString stringWithFormat:@"Continue with %@", self.titleLabel.text] forState:UIControlStateNormal];
}

- (IBAction)acceptSubscriptButtonTapped:(id)sender {
    [self.delegate onDidTapSubsciptCell:self productID:self.payment.productIdentifier];
}


@end
