//
//  SubscriptionPlanDelegate.h
//  Zype
//
//  Created by TopDeveloper on 6/23/18.
//  Copyright © 2018 Zype. All rights reserved.
//

@protocol SubscriptionPlanDelegate <NSObject>

@optional
- (void)subscriptionPlanDone;
- (void)subscriptionSignInDone;

@end
