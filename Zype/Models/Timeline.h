//
//  Timeline.h
//  Zype
//
//  Created by ZypeTech on 2/3/15.
//  Copyright (c) 2015 Zype. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Timeline : NSObject

@property (strong, nonatomic) NSNumber *start;
@property (strong, nonatomic) NSNumber *end;
@property (strong, nonatomic) NSString *title;

- (id)initWithStart:(NSNumber *)start
                End:(NSNumber *)end
              Title:(NSString *)title;

@end
