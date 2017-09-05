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
#import "ACSDataManager.h"

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
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:kOAuthProperty_Subscription] isEqualToNumber:[NSNumber numberWithInt:0]]) {
        return NO;
    } else {
        return YES;
    }
    /*RMAppReceipt *appReceipt = [RMAppReceipt bundleReceipt];
    if (appReceipt) {
        for (NSString *productID in self.subscriptions) {
            BOOL isActive =  [appReceipt containsActiveAutoRenewableSubscriptionOfProductIdentifier:productID forDate:[NSDate date]];
            if (isActive == true) {
                return true;
            }
        }
    }*/
    
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
        
       if (success) {
                    
        }
       /* [[RMStore defaultStore].receiptVerificator verifyTransaction:transaction success:^{
        } failure:^(NSError *error) {
        }];*/
    } failure:^(SKPaymentTransaction *transaction, NSError *error) {
        if (failure) {
            failure(error.localizedDescription);
        }
    }];
}


- (void)verifyWithBifrost:(void(^)())success failure:(void(^)(NSString *))failure {
    // Load the receipt from the app bundle.
    NSURL *receiptURL = [[NSBundle mainBundle] appStoreReceiptURL];
    NSData *receipt = [NSData dataWithContentsOfURL:receiptURL];
    if (!receipt) { /* No local receipt -- handle the error. */ }
    
    // Create the JSON object that describes the request
    NSError *error;
    NSDictionary *requestContents = @{
                                      @"consumer_id" : [[NSUserDefaults standardUserDefaults] stringForKey:kSettingKey_ConsumerId],
                                      @"third_party_id" : @"iosmonthly",
                                      @"device_type" : @"ios",
                                      @"receipt": [receipt base64EncodedStringWithOptions:0],
                                      @"shared_key" : @"ead5fc19c42045cfa783e24d6e5a2325",
                                      @"app_key" : kAppKey
                                      };
    NSData *requestData = [NSJSONSerialization dataWithJSONObject:requestContents
                                                          options:NSJSONWritingPrettyPrinted
                                                            error:&error];
    
    if (requestData) {
        // Create a POST request with the receipt data.
        NSURL *storeURL = [NSURL URLWithString:@"https://bifrost.stg.zype.com/api/v1/subscribe"];
        NSMutableURLRequest *storeRequest = [NSMutableURLRequest requestWithURL:storeURL];
        [storeRequest setValue:@"application/json" forHTTPHeaderField:@"Content-type"];
        [storeRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [storeRequest setHTTPMethod:@"POST"];
        [storeRequest setHTTPBody:requestData];
        
        //Send the Request
        [NSURLConnection sendAsynchronousRequest:storeRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
            
            if (data) {
                //Get the Result of Request
                NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
                if(jsonResponse){
                    int isValid = [[jsonResponse valueForKey:@"is_valid"] intValue];
                    if (isValid == 1)
                        success();
                    
                    int isExpired = [[jsonResponse valueForKey:@"expired"] intValue];
                    if (isExpired == 1)
                        failure(@"Your subscription has expired");
                } else {
                    failure(error.localizedDescription);
                }

            } else {
               failure(@"Can't subscribe at the moment. Try to subscribe on the website"); 
            }
        }];
        
    } else {
        failure(@"Can't subscribe at the moment. Try to subscribe on the website");
    }
}


- (void)restorePurchases:(void(^)())success failure:(void(^)(NSString *))failure {
    [[RMStore defaultStore] restoreTransactionsOnSuccess:^(NSArray *transactions) {
        success();
    } failure:^(NSError *error) {
        failure(error.localizedDescription);
    }];
}

#pragma mark - Transaction Observer

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray<SKPaymentTransaction *> *)transactions {
    for (SKPaymentTransaction *transaction in transactions){
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchasing:
                
                break;
            case SKPaymentTransactionStatePurchased:
            {
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"PurchaseCompletedSuccessflly" object:nil];
                
                [self verifyWithBifrost:^(){
                    NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:kSettingKey_Username];
                    NSString *password = [[NSUserDefaults standardUserDefaults] objectForKey:kSettingKey_Password];
                    
                    [ACSDataManager loginWithUsername:username password:password block:^(BOOL success, NSError *error) {
                        if (success) {
                            
                        } else {
                            
                        }
                    }];
                    
                   // dispatch_async(dispatch_get_main_queue(), ^{
                    
                   // });
                    
                } failure:^(NSString *message){
                    NSLog(@"Transaction can't be completed. %@", message);
                    //put this in the queue and execute later
                }];
                
                break;
            }
            case SKPaymentTransactionStateFailed:
                //display error
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                
                break;
            case SKPaymentTransactionStateDeferred:
                
                break;
            default:
                break;
        }
        NSLog(@"updatedtransactions: state = %ld", (long)transaction.transactionState);
    }
    
}

- (void)paymentQueue:(SKPaymentQueue *)queue removedTransactions:(NSArray<SKPaymentTransaction *> *)transactions {
    for (SKPaymentTransaction *transaction in transactions){
        NSLog(@"removedTransactions: state = %ld", (long)transaction.transactionState);
    }
}

- (BOOL)paymentQueue:(SKPaymentQueue *)queue shouldAddStorePayment:(SKPayment *)payment forProduct:(SKProduct *)product {
    NSLog(@"shouldAddStorePayment");
    return YES;
}

@end
