//
//  SubscriptActiveCell.h
//  Zype
//
//  Created by Александр on 16.04.17.
//  Copyright © 2017 Zype. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RMStore/RMStore.h>

@protocol SubscriptActiveCellDelegate;

@interface SubscriptActiveCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIView *backgroundView;
@property (strong, nonatomic) IBOutlet UIButton *continueButton;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (strong, nonatomic) IBOutlet UILabel *priceLabel;

@property (weak, nonatomic) id <SubscriptActiveCellDelegate> delegate;
@property (strong, nonatomic) SKPayment *payment;
@property (strong, nonatomic) NSDictionary *mkProduct;

- (void)configureCell:(SKPayment*)payment;
- (void)configCell:(NSDictionary *)product;

@end

@protocol SubscriptActiveCellDelegate <NSObject>

- (void)onDidTapSubsciptCell:(SubscriptActiveCell *)cell product:(NSDictionary *)product;

@end

