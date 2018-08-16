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
    UIColor * titleColor = (kAppColorLight) ? kDarkThemeBackgroundColor : [UIColor whiteColor];
    [self.titleLabel setTextColor:titleColor];
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

- (void)configCell:(SKProduct *)product {
    self.mkProduct = product;
    self.descriptionLabel.text = product.localizedDescription;
    self.titleLabel.text = product.localizedTitle;
    if (@available(iOS 11.2, *)) {
        NSString *strSubType = (product.subscriptionPeriod.unit == SKProductPeriodUnitMonth)?@"/mo":@"/ye";
        self.priceLabel.text = [NSString stringWithFormat:@"$%@%@", product.price, strSubType];
    } else {
        self.priceLabel.text = [NSString stringWithFormat:@"$%@", product.price];
    }
    if (@available(iOS 11.2, *)) {
        if (product.introductoryPrice.paymentMode == SKProductDiscountPaymentModeFreeTrial) {
            [self.trialLabel setHidden:NO];
        } else {
            [self.trialLabel setHidden:YES];
        }
    } else {
        [self.trialLabel setHidden:NO];
    }
//    self.descriptionLabel.text = product[@"description"];
//    self.titleLabel.text = product[@"name"];
//    NSString *strSubType = [product[@"interval"] isEqualToString:@"monthly"]?@"/mo":@"/ye";
//    self.priceLabel.text = [NSString stringWithFormat:@"$%@%@", product[@"amount"], strSubType];
    [self.continueButton setTitle:[NSString stringWithFormat:@"Continue with %@", self.titleLabel.text] forState:UIControlStateNormal];
}

- (IBAction)acceptSubscriptButtonTapped:(id)sender {
    [self.delegate onDidTapSubsciptCell:self product:self.mkProduct];
}


@end

