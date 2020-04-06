//
//  PrivacyViewController.h
//  Zype
//
//  Created by TopDeveloper on 7/10/18.
//  Copyright © 2018 Zype. All rights reserved.
//

#import <UIKit/UIKit.h>

@import WebKit;

@interface PrivacyViewController : UIViewController

@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;
@property (retain, nonatomic) WKWebView *wkWebView;

@end
