//
//  NSString+Extensions.h
//  Zype
//
//  Created by ZypeTech on 3/9/15.
//  Copyright (c) 2015 Zype. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Extensions)

- (BOOL)stringContains:(NSString *)otherString;
- (NSString *)stringByStrippingHTML;

@end
