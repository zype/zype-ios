//
//  ACAdManager.h
//  Havoc
//
//  Created by ZypeTech on 9/14/16.
//  Copyright © 2016 Zype. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AdRequest.h"

@interface ACAdManager : NSObject

@property (nonatomic) NSArray* adSchedule;

- (NSArray *)adsArrayFromParsedDictionary:(NSDictionary *)dictionary;
- (NSArray *)adRequstsFromArray:(NSArray *)array;

//Singleton
+ (ACAdManager *)sharedInstance;

@end
