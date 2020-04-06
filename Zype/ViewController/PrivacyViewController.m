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
    [self setupWkWebView];
    
    NSString *htmlString = [[NSUserDefaults standardUserDefaults] stringForKey:kSettingKey_Terms];
    self.wkWebView.scrollView.bounces = NO;
    [self.wkWebView loadHTMLString:htmlString baseURL:nil];
    
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

-(void)setupWkWebView {
    WKWebViewConfiguration *wkWebConfig = [[WKWebViewConfiguration alloc] init];
    self.wkWebView = [[WKWebView alloc] initWithFrame:self.view.frame configuration:wkWebConfig];
    self.wkWebView.opaque = NO;
    self.wkWebView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.wkWebView];
    
    self.wkWebView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.wkWebView
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeHeight
                                                         multiplier:1
                                                           constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.wkWebView
                                                          attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeWidth
                                                         multiplier:1
                                                           constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.wkWebView
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1
                                                           constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.wkWebView
                                                          attribute:NSLayoutAttributeCenterY
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterY
                                                         multiplier:1
                                                           constant:0]];
}

@end
