//
//  SignInViewController.h
//  Zype
//
//  Created by ZypeTech on 3/2/15.
//  Copyright (c) 2015 Zype. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GAI.h"
#import "BorderedTextField.h"

@interface SignInViewController : GAITrackedViewController <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet BorderedTextField *textFieldEmail;
@property (weak, nonatomic) IBOutlet BorderedTextField *textFieldPassword;
@property (weak, nonatomic) IBOutlet UIButton *buttonSignIn;

@property (nonatomic, retain) NSDate *start;

@end
