//
//  ACPurchaseManager.h
//  Zype
//
//  Created by Александр on 21.04.17.
//  Copyright © 2017 Zype. All rights reserved.
//

#import <Foundation/Foundation.h>
@import StoreKit;

@interface ACPurchaseManager : NSObject <SKPaymentTransactionObserver>

+ (id)sharedInstance;

@property (nonatomic, strong) NSSet *subscriptions;

- (BOOL)isActiveSubscription;
- (void)requestSubscriptions:(void(^)(NSArray *))success failure:(void(^)(NSString *))failure;
- (void)buySubscription:(NSString *)productID success:(void(^)())success failure:(void(^)(NSString *))failure;
- (void)restorePurchases:(void(^)())success failure:(void(^)(NSString *))failure;
- (void)verifyWithBifrost:(void(^)())success failure:(void(^)(NSString *))failure;
- (void)requestSubscriptions;

@end
