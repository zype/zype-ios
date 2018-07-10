//
//  PrivacyViewController.m
//  Zype
//
//  Created by TopDeveloper on 7/10/18.
//  Copyright © 2018 Zype. All rights reserved.
//

#import "PrivacyViewController.h"

@interface PrivacyViewController ()

@end

@implementation PrivacyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *htmlString = [[NSUserDefaults standardUserDefaults] stringForKey:kSettingKey_Terms];
    self.webView.scrollView.bounces = NO;
    [self.webView loadHTMLString:htmlString baseURL:nil];
    
    UINavigationItem* navItem = [[UINavigationItem alloc] initWithTitle:@""];
    UIBarButtonItem* backBtn = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(onTapBack:)];
    navItem.rightBarButtonItem = backBtn;
    
    [self.navBar setItems:@[navItem]];
    if (kAppColorLight) {
        self.view.backgroundColor = [UIColor whiteColor];
        [backBtn setTintColor:kLightTintColor];
    } else {
        [self.navBar setBarStyle:UIBarStyleBlackOpaque];
        self.view.backgroundColor = kDarkThemeBackgroundColor;
        [backBtn setTintColor:kDarkTintColor];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)onTapBack:(UIBarButtonItem*)item{
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
