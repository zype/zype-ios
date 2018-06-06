//
//  NSMutableArray+LimitedStack.h
//
//  Created by ZypeTech on 7/22/15.
//  Copyright (c) 2015 Zype. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableArray (LimitedStack)

- (id)pop;
- (void)push:(id)obj; //push pops the last object if over 10 objects

@end
