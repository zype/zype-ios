//
//  GuideModel.h
//  Zype
//
//  Created by Top developer on 5/8/19.
//  Copyright © 2019 Zype. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GuideProgramModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface GuideModel : NSObject

@property (nonatomic, retain) NSString * gId;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSDate * updated_at;
@property (nonatomic, retain) NSDate * created_at;
@property (nonatomic, retain) NSString * videoId;

@property (nonatomic, retain) NSMutableArray<GuideProgramModel*>* programs;

- (instancetype)initWithDictionary:(NSDictionary *)dict;

@end

NS_ASSUME_NONNULL_END
