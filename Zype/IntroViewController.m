//
//  IntroViewController.m
//  Zype
//
//  Created by Александр on 11.04.17.
//  Copyright © 2017 Zype. All rights reserved.
//

#import "IntroViewController.h"
#import <RMStore/RMStore.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import "ACPurchaseManager.h"
#import "ACStatusManager.h"
#import "UIView+UIView_CustomizeTheme.h"

@interface IntroViewController ()

@property (strong, nonatomic) IBOutlet UIButton *loginButton;
@property (strong, nonatomic) IBOutlet UIButton *registerButton;
@property (strong, nonatomic) IBOutlet UIButton *closeButton;

@end

@implementation IntroViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self configureView];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)configureView {
    [self.registerButton tintCustomizeTheme];
    [self.registerButton round:kViewCornerRounded];
    [self.loginButton borderColorCustomizeTheme];
    [self.loginButton round:kViewCornerRounded];
    UIColor *textColor = (kAppColorLight) ? [UIColor blackColor] : [UIColor whiteColor];
    [self.loginButton setTitleColor:textColor forState:UIControlStateNormal];
    NSString *deleteButtonString = (kAppColorLight) ? @"delete-black" : @"delete-white";
    [self.closeButton setImage:[UIImage imageNamed:deleteButtonString] forState:UIControlStateNormal];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    if ([ACStatusManager isUserSignedIn] == true) {
        [self dismissViewControllerAnimated:false completion:nil];
    }
}

#pragma mark - Actions

- (IBAction)restorePurchaseTapped:(id)sender {
    [SVProgressHUD show];
    [[RMStore defaultStore] restoreTransactionsOnSuccess:^(NSArray *transactions) {
        [SVProgressHUD dismiss];
    } failure:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus:error.localizedDescription];
    }];
}

- (IBAction)cancelControllerTapped:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:true completion:nil];
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
