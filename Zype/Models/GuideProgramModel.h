//
//  GuideProgramModel.h
//  Zype
//
//  Created by Top developer on 5/8/19.
//  Copyright © 2019 Zype. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GuideProgramModel : NSObject

@property (nonatomic, retain) NSString * pId;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * pDescription;
@property (nonatomic, retain) NSDate * startTime;
@property (nonatomic, retain) NSDate * endTime;
@property (nonatomic, retain) NSDate * startTimeOffset;
@property (nonatomic, retain) NSDate * endTimeOffset;
@property (nonatomic) int duration;
@property (nonatomic, retain) NSDate * updated_at;
@property (nonatomic, retain) NSDate * created_at;

- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (BOOL) isAiring;
- (BOOL) containsDate:(NSDate*) date;
@end

NS_ASSUME_NONNULL_END
