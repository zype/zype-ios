//
//  NSURLResponse+AK.h
//  Havoc
//
//  Created by ZypeTech on 8/2/16.
//  Copyright © 2016 Zype. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURLResponse (AK)

- (BOOL)isStatusFamilyInformational;
- (BOOL)isStatusFamilySuccessful;
- (BOOL)isStatusFamilyRedirection;
- (BOOL)isStatusFamilyError;
- (BOOL)isStatusFamilyServerError;
- (BOOL)isStatusFamilyOther;

@end
