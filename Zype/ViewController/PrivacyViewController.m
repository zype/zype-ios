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
    self.view.backgroundColor = [UIColor whiteColor];
    
    NSString *htmlString = [[NSUserDefaults standardUserDefaults] stringForKey:kSettingKey_Terms];
    self.wkWebView.scrollView.bounces = NO;
    NSString *headerString = @"<header><meta name='viewport' content='width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no'></header>";
    [self.wkWebView loadHTMLString:[headerString stringByAppendingString:htmlString] baseURL:nil];

    
    UINavigationItem* navItem = [[UINavigationItem alloc] initWithTitle:@""];
    UIBarButtonItem* backBtn = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(onTapBack:)];
    navItem.rightBarButtonItem = backBtn;
    [self.navBar setItems:@[navItem]];
    
    [[UINavigationBar appearance] setTranslucent:NO];
    if (kAppColorLight) {
        self.view.backgroundColor = [UIColor whiteColor];
        [[UINavigationBar appearance] setBarTintColor:[UIColor whiteColor]];
        [backBtn setTintColor:kClientColor];
    } else {
        [[UINavigationBar appearance] setBarTintColor:kDarkThemeBackgroundColor];
        self.view.backgroundColor = kDarkThemeBackgroundColor;
        [backBtn setTintColor:kClientColor];
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
    [self setupConstraints];
}

-(void)setupConstraints {
    
    self.wkWebView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.wkWebView
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeHeight
                                                         multiplier:1
                                                           constant:-(self.navBar.frame.size.height+10)]];
    
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
                                                           constant:self.navBar.frame.size.height+16]];

}

@end
