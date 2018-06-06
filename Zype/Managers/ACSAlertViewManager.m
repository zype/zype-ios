//
//  ACSAlertViewManager.m
//
//  Created by ZypeTech on 7/9/15.
//  Copyright (c) 2015 Zype. All rights reserved.
//

#import "ACSAlertViewManager.h"

@implementation ACSAlertViewManager

+ (void)showAlertWithTitle:(NSString *)title WithMessage:(NSString *)message{
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
    
}

@end
