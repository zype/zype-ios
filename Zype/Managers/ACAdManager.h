//
//  ACAdManager.h
//  Havoc
//
//  Created by ZypeTech on 9/14/16.
//  Copyright © 2016 Zype. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ACAdManager : NSObject

@property (nonatomic) NSArray* adSchedule;

- (NSArray *)adsArrayFromParsedDictionary:(NSDictionary *)dictionary;

//Singleton
+ (ACAdManager *)sharedInstance;

@end
