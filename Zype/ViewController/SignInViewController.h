//
//  SignInViewController.h
//  Zype
//
//  Created by ZypeTech on 3/2/15.
//  Copyright (c) 2015 Zype. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleAnalytics/GAI.h>
#import "BorderedTextField.h"
#import "CustomizeThemeTextField.h"
#import "SubscriptionPlanDelegate.h"

@interface SignInViewController : GAITrackedViewController <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet CustomizeThemeTextField *textFieldEmail;
@property (weak, nonatomic) IBOutlet CustomizeThemeTextField *textFieldPassword;
@property (weak, nonatomic) IBOutlet UIButton *buttonSignIn;

@property (nonatomic, retain) NSDate *start;

@property (weak, nonatomic) id<SubscriptionPlanDelegate> planDelegate;

@end
