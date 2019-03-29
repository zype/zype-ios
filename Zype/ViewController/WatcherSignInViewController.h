//
//  WatcherSignInViewController.h
//  Zype
//
//  Created by Christian on 26.03.19.
//

#import <UIKit/UIKit.h>
#import "GAI.h"
#import "BorderedTextField.h"
#import "CustomizeThemeTextField.h"
#import "SubscriptionPlanDelegate.h"

@interface WatcherSignInViewController : GAITrackedViewController <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet CustomizeThemeTextField *textFieldEmail;
@property (weak, nonatomic) IBOutlet CustomizeThemeTextField *textFieldPassword;
@property (weak, nonatomic) IBOutlet UIButton *buttonSignIn;

@property (nonatomic, retain) NSDate *start;

@property (weak, nonatomic) id<SubscriptionPlanDelegate> planDelegate;

@end
