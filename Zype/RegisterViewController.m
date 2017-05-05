//
//  RegisterViewController.m
//  Zype
//
//  Created by Александр on 11.04.17.
//  Copyright © 2017 Zype. All rights reserved.
//

#import "RegisterViewController.h"
#import "ACSDataManager.h"
#import "SVProgressHUD.h"
#import "ACSTokenManager.h"
#import "ACSAlertViewManager.h"
#import "UIUtil.h"
#import "NSString+AC.h"
#import "ACPurchaseManager.h"

@interface RegisterViewController ()

@property (strong, nonatomic) IBOutlet UIView *containerView;
@property (strong, nonatomic) IBOutlet UITextField *emailField;
@property (strong, nonatomic) IBOutlet UITextField *confirmEmailField;
@property (strong, nonatomic) IBOutlet UITextField *passwordField;
@property (strong, nonatomic) IBOutlet UIButton *createButton;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *fieldViewBottomConstraintY;


@end

@implementation RegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self registerForKeyboardNotifications];
    [self setupConfiguration];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupConfiguration {
    UITapGestureRecognizer * tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    [self.view addGestureRecognizer:tapRecognizer];
    self.createButton.layer.cornerRadius = 5;
}

- (void)viewTapped:(UITapGestureRecognizer *)recognizer {
    [self.emailField resignFirstResponder];
    [self.confirmEmailField resignFirstResponder];
    [self.passwordField resignFirstResponder];
}

- (void)registerForKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    NSNumber *durationValue = info[UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration = durationValue.doubleValue;
    
    NSNumber *curveValue = info[UIKeyboardAnimationCurveUserInfoKey];
    UIViewAnimationCurve animationCurve = curveValue.intValue;
    
    //
    // Create animation.
    
    self.fieldViewBottomConstraintY.constant = kbSize.height;
    
    void (^animations)() = ^() {
        [self.view layoutIfNeeded];
    };
    
    //
    // Begin animation.
    
    [UIView animateWithDuration:animationDuration
                          delay:0.0
                        options:(animationCurve << 16)
                     animations:animations
                     completion:nil];
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    self.fieldViewBottomConstraintY.constant = 80;
    [UIView animateWithDuration:0.2 animations:^{
        [self.view layoutIfNeeded];
    }];
}

#pragma mark - Actions

- (IBAction)createLogin:(id)sender {
    NSString *errorString = [self validateCredentials];
    if (errorString) {
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:nil message:errorString preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction * okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:okAction];
        [self presentViewController:alert animated:true completion:nil];
    } else {
        [self registerWithUsername:self.emailField.text WithPassword:self.passwordField.text];
    }
}

- (IBAction)cancelController:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}

- (void)dismisControllers {
    if (self.presentingViewController.presentingViewController) {
        [self.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
}

- (NSString *)validateCredentials {
    NSString *errorString;
    
    if ([self.emailField.text  isEqual: @""] || [self.confirmEmailField.text  isEqual: @""] || [self.passwordField.text  isEqual: @""]) {
        return @"Не все поля заполнены";
    }
    
    if (![self.emailField.text validateEmail]) {
        return @"Email не корректен";
    }
    
    if (![self.emailField.text isEqualToString:self.confirmEmailField.text]) {
        return @"Email отличаются";
    }
    
    return errorString;
}

#pragma mark - Register

- (void)registerWithUsername:(NSString *)username WithPassword:(NSString *)password {
    [SVProgressHUD show];
    [ACSDataManager registerWithUsername:username password:password block:^(BOOL success, NSError *error) {
        if (success == YES) {
            [ACSDataManager loginWithUsername:username password:password block:^(BOOL success, NSError *error) {
                if (success) {
                    [SVProgressHUD dismiss];
                    if (self != nil) {
                        if ([[ACPurchaseManager sharedInstance] isActiveSubscription]) {
                            [self dismisControllers];
                        } else {
                            [UIUtil showSubscriptionViewFromViewController:self];
                        }
                    }
                } else {
                    [SVProgressHUD showErrorWithStatus:error.localizedDescription];
                }
            }];
        } else {
            [SVProgressHUD dismiss];
            [ACSAlertViewManager showAlertWithTitle:kString_TitleSignInFail WithMessage:kString_MessageSignInFail];
        }
        
    }];
    
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
