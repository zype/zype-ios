//
//  NSURL+Encoding.m
//
//  Created by ZypeTech on 12/2/15.
//  Copyright © 2015 Zype. All rights reserved.
//

#import "NSURL+Encoding.h"

@implementation NSURL (Encoding)

+(NSURL*) withString:(NSString*) string {
    string = [string stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return [[self alloc] initWithString:string];
}

@end
