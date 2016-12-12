//
//  ACLimitLivestreamManager.h
//  Havoc
//
//  Created by ZypeTech on 9/15/16.
//  Copyright © 2016 Zype. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ACLimitLivestreamManager : NSObject

/*
 public var limit: Int = 0
 public var played: Int = 0
 public var message: String = ""
 public var refreshRate: Int = 0
 public var starts: NSTimeInterval = 0
 public var isSet = false
 */
@property (nonatomic) NSNumber *limit;
@property (nonatomic) NSNumber *played;
@property (nonatomic) NSString *message;
@property (nonatomic) NSTimeInterval starts;
@property (nonatomic, assign) BOOL isSet;


//public methods
- (BOOL)livestreamLimitReached;
- (void)livestreamStarts;
- (void)livestreamStops;

//Singleton
+ (instancetype)sharedInstance;

@end
