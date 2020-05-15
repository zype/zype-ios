//
//  ForgotPasswordViewController.m
//  Zype
//
//  Created by TopDeveloper on 7/10/18.
//  Copyright © 2018 Zype. All rights reserved.
//

#import "ForgotPasswordViewController.h"
#import "CustomizeThemeTextField.h"
#import "UIView+UIView_CustomizeTheme.h"
#import "RegisterViewController.h"
#import "NSString+AC.h"
#import "SVProgressHUD.h"
#import "ACSDataManager.h"
#import "ACSAlertViewManager.h"

@interface ForgotPasswordViewController ()
@property (weak, nonatomic) IBOutlet UIView *viewContainer;
@property (weak, nonatomic) IBOutlet UIButton *btnClose;
@property (weak, nonatomic) IBOutlet UIButton *btnResetPassword;
@property (weak, nonatomic) IBOutlet CustomizeThemeTextField *txtEmail;
@property (weak, nonatomic) IBOutlet UIButton *btnSignup;
@property (weak, nonatomic) IBOutlet UIImageView *arrowImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIView *credentialContainerView;

@property (weak, nonatomic) IBOutlet UIView *successContainerView;
@property (weak, nonatomic) IBOutlet UIButton *btnCloseAndReturn;
@property (weak, nonatomic) IBOutlet UILabel *thanksLabel;

@end

@implementation ForgotPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupConfiguration];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupConfiguration {
    [self.btnResetPassword tintCustomizeTheme];
    [self customizeAppearance];
    [self.btnResetPassword round:kViewCornerRounded];
    [self.credentialContainerView round:kViewCornerRounded];
    [self.credentialContainerView borderCustomizeTheme];
    [self.txtEmail setAttributePlaceholder:@"Email"];
    UIColor * titleColor = (kAppColorLight) ? kDarkThemeBackgroundColor : [UIColor whiteColor];
    self.titleLabel.textColor = titleColor;
    
    UIColor * signUpColor = (kAppColorLight) ? kLightTintColor : kDarkTintColor;
    NSDictionary * signUpAttributes = @{NSForegroundColorAttributeName: signUpColor,
                                        NSFontAttributeName: [UIFont systemFontOfSize:12.0f weight:UIFontWeightMedium]};
    NSMutableAttributedString * attrstringFirstPart = [[NSMutableAttributedString alloc] initWithString:@"Don't have an account? " attributes:@{NSForegroundColorAttributeName: kUniversalGray}];
    NSAttributedString * signinText = [[NSAttributedString alloc] initWithString:@"Sign up" attributes:signUpAttributes];
    [attrstringFirstPart appendAttributedString:signinText];
    [self.btnSignup setAttributedTitle:attrstringFirstPart forState:UIControlStateNormal];
    
    NSString *arrowImageString = (kAppColorLight) ? @"arrow-light" : @"arrow-black";
    [self.arrowImageView setImage:[[UIImage imageNamed:arrowImageString] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    self.arrowImageView.tintColor = kClientColor;

    UITapGestureRecognizer * tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    [self.view addGestureRecognizer:tapRecognizer];
    
    // setting for success container view
    if (kAppColorLight) {
        self.successContainerView.backgroundColor = [UIColor whiteColor];
    } else {
        self.successContainerView.backgroundColor = kDarkThemeBackgroundColor;
    }
    [self.btnCloseAndReturn tintCustomizeTheme];
    [self.btnCloseAndReturn round:kViewCornerRounded];
    self.thanksLabel.textColor = titleColor;
    
    [self.successContainerView setHidden:YES];
}

- (void)viewTapped:(UITapGestureRecognizer *)recognizer {
    [self.txtEmail resignFirstResponder];
}

- (NSString *)validateCredentials {
    NSString *errorString;
    
    if ([self.txtEmail.text  isEqual: @""]) {
        return @"Please fill out the missing fields and try again.";
    }
    
    if (![self.txtEmail.text validateEmail]) {
        return @"Please enter a valid email address and try again.";
    }
    
    return errorString;
}

#pragma mark - Reset Password

- (void)resetPasswordWithUsername:(NSString *)username {
    [self.txtEmail resignFirstResponder];
    
    [SVProgressHUD show];
    [ACSDataManager resetPasswordWithUsername:username WithCompletionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (data != nil) {
            
            NSError *localError = nil;
            NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
            
            if (parsedObject != nil){
                if (parsedObject[@"message"] != nil) {
                    [ACSAlertViewManager showAlertWithTitle:kString_TitleResetPasswordFail WithMessage:parsedObject[@"message"]];
                } else {
                    [self.successContainerView setHidden:NO];
                }
            }
        }
        [SVProgressHUD dismiss];
    }];
    
}

#pragma mark - actions of Controls

- (IBAction)clickedClose:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}

- (IBAction)clickedResetPassword:(id)sender {
    NSString *errorString = [self validateCredentials];
    if (errorString) {
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:nil message:errorString preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction * okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:okAction];
        [self presentViewController:alert animated:true completion:nil];
    } else {
        [self resetPasswordWithUsername:self.txtEmail.text];
    }
}

- (IBAction)clickedSignup:(id)sender {
    if ([self.presentingViewController isKindOfClass:[RegisterViewController class]]) {
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    } else {
        [UIUtil showSignUpViewFromViewController:self];
    }
}

- (IBAction)clickedCloseAndReturn:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}

@end
