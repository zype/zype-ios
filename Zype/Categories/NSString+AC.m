//
//  UIString+AC.m
//
//  Created by ZypeTech on 6/23/15.
//  Copyright (c) 2015 Zype. All rights reserved.
//

#import "NSString+AC.h"

@implementation NSString (AC)

- (NSString *)URLEncodedString {
    
    NSMutableString * output = [NSMutableString string];
    const unsigned char * source = (const unsigned char *)[self UTF8String];
    NSUInteger sourceLen = strlen((const char *)source);
    
    for (int i = 0; i < sourceLen; ++i) {
        
        const unsigned char thisChar = source[i];
        
        if (thisChar == ' '){
            
            [output appendString:@"+"];
            
        } else if (thisChar == '.' || thisChar == '-' || thisChar == '_' || thisChar == '~' ||
                   (thisChar >= 'a' && thisChar <= 'z') ||
                   (thisChar >= 'A' && thisChar <= 'Z') ||
                   (thisChar >= '0' && thisChar <= '9')) {
            
            [output appendFormat:@"%c", thisChar];
            
        } else {
            
            [output appendFormat:@"%%%02X", thisChar];
            
        }
        
    }
    return output;
    
}

- (BOOL)validateEmail {
    BOOL stricterFilter = YES;
    NSString *stricterFilterString = @"^[A-Z0-9a-z\\._+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}$";
    NSString *laxString = @"^.+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*$";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:self];
}

@end
