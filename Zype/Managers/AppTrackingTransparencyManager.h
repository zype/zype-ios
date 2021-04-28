//
//  AppTrackingTransparencyManager.h
//  Zype
//
//  Created by Anish Kumar on 27/04/21.
//  Copyright © 2021 Zype. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AppTrackingTransparencyManager : NSObject

+ (void)requestIFDA:(void (^)(NSString * idfa))completion;

@end

NS_ASSUME_NONNULL_END
