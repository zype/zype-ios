//
//  ACPurchaseManager.m
//  Zype
//
//  Created by Александр on 21.04.17.
//  Copyright © 2017 Zype. All rights reserved.
//

#import "ACPurchaseManager.h"
#import <RMStore/RMStore.h>
#import <RMStore/RMAppReceipt.h>
#import <RMStoreAppReceiptVerificator.h>
//#import <RMStoreKeychainPersistence.h>

@interface ACPurchaseManager() {
    RMStoreAppReceiptVerificator * _verificator;
}

@end

@implementation ACPurchaseManager

+ (id)sharedInstance {
    static ACPurchaseManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (id)init {
    if (self = [super init]) {
        self.subscriptions = [NSSet setWithObjects: kMonthlySubscription,
                              kYearlySubscription, nil];
    }
    return self;
}

- (void)configure {
    _verificator = [[RMStoreAppReceiptVerificator alloc] init];
    [RMStore defaultStore].receiptVerificator = _verificator;
}

- (BOOL)isActiveSubscription {
    RMAppReceipt *appReceipt = [RMAppReceipt bundleReceipt];
    if (appReceipt) {
        for (NSString *productID in self.subscriptions) {
            BOOL isActive =  [appReceipt containsActiveAutoRenewableSubscriptionOfProductIdentifier:productID forDate:[NSDate date]];
            if (isActive == true) {
                return true;
            }
        }

    }
    
    return false;
}

- (void)requestSubscriptions:(void(^)(NSArray *))success failure:(void(^)(NSString *))failure {
    [[RMStore defaultStore] requestProducts:self.subscriptions success:^(NSArray *products, NSArray *invalidProductIdentifiers) {
        if (products != nil) {
            success(products);
        } else {
            failure(@"Not products");
        }
    } failure:^(NSError *error) {
        failure(error.localizedDescription);
    }];
}

- (void)requestSubscriptions {
    [[RMStore defaultStore] requestProducts:self.subscriptions];
}

- (void)buySubscription:(NSString *)productID success:(void(^)())success failure:(void(^)(NSString *))failure {
    [[RMStore defaultStore] addPayment:productID success:^(SKPaymentTransaction *transaction) {
        
        if ([RMStore defaultStore].receiptVerificator != nil) {
            [[RMStore defaultStore].receiptVerificator verifyTransaction:transaction success:^{
                if (success) {
                    success();
                }
            } failure:^(NSError *error) {
                if (failure) {
                    failure(error.localizedDescription);
                }
            }];
        } else {
            if (success) {
                success();
            }
        }

    } failure:^(SKPaymentTransaction *transaction, NSError *error) {
        if (failure) {
            failure(error.localizedDescription);
        }
    }];
}

- (void)restorePurchases:(void(^)())success failure:(void(^)(NSString *))failure {
    [[RMStore defaultStore] restoreTransactionsOnSuccess:^(NSArray *transactions) {
        success();
    } failure:^(NSError *error) {
        failure(error.localizedDescription);
    }];
}

@end
