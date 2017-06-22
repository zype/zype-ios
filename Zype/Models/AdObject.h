//
//  AdRequest.h
//  Zype
//
//  Created by Александр on 23.06.17.
//  Copyright © 2017 Zype. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>

@interface AdObject : NSObject

- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSTimeInterval)offset;
- (NSValue *)offsetValue;

@property (nonatomic, assign) CMTime interval;
@property (nonatomic, strong) NSString *tag;


@end
