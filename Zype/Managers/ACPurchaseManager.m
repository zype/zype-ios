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

@interface ACPurchaseManager()

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

- (void)buySubscription:(NSString *)productID success:(void(^)(void))success failure:(void(^)(NSString *))failure {
    [[RMStore defaultStore] addPayment:productID success:^(SKPaymentTransaction *transaction) {
        if (success) {
            success();
        }
        [[RMStore defaultStore].receiptVerificator verifyTransaction:transaction success:^{
        } failure:^(NSError *error) {
        }];
    } failure:^(SKPaymentTransaction *transaction, NSError *error) {
        if (failure) {
            failure(error.localizedDescription);
        }
    }];
}

- (void)restorePurchases:(void(^)(void))success failure:(void(^)(NSString *))failure {
    [[RMStore defaultStore] restoreTransactionsOnSuccess:^(NSArray *transactions) {
        success();
    } failure:^(NSError *error) {
        failure(error.localizedDescription);
    }];
}

@end

