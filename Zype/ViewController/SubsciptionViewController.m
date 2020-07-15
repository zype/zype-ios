//
//  SubsciptionViewController.m
//  Zype
//
//  Created by Александр on 16.04.17.
//  Copyright © 2017 Zype. All rights reserved.
//

#import "SubsciptionViewController.h"
#import "SubscriptActiveCell.h"
#import <RMStore/RMStore.h>
#import <RMStore/RMAppReceipt.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import "ACPurchaseManager.h"
#import "ACSAlertViewManager.h"
#import "UIViewController+AC.h"
#import "IntroViewController.h"
#import "SignInViewController.h"
#import "RESTServiceController.h"
#import "ACSDataManager.h"

@interface SubsciptionViewController ()<UITableViewDelegate, UITableViewDataSource, SubscriptActiveCellDelegate, WKNavigationDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSSet *subscriptions;
@property (strong, nonatomic) NSArray *products;
@property (strong, nonatomic) NSArray *titles;
@property (assign, nonatomic) NSInteger selectedIndex;
@property (strong, nonatomic) IBOutlet UILabel *navigationTitle;
@property (strong, nonatomic) IBOutlet UIView *separateNavigationView;
@property (weak, nonatomic) IBOutlet UIView *disclaimerWebviewParent;
@property (strong, nonatomic) WKWebView *disclaimerWebview;


@end

@implementation SubsciptionViewController

@synthesize tableView;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configureController];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)configureController {
    [self customizeAppearance];
    
    //weird behavior with UITableViewComponent properties on iPad iOS13.x versions if table component is used as child control inside custom Scrollview. Need to explicitly set hidden No otherwise it's hidden automatically on iPad iOS 13.x.
    [self.tableView setHidden:NO];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"SubscriptActiveCell" bundle:nil] forCellReuseIdentifier:@"SubscriptActiveCell"];
    self.tableView.scrollEnabled = FALSE;
    self.tableView.contentInset = UIEdgeInsetsMake(-36, 0, 0, 0);
    self.selectedIndex = 0;
    self.titles = @[@"Monthly Subscription", @"Yearly Subscription"];
    UIColor * titleColor = (kAppColorLight) ? kDarkThemeBackgroundColor : [UIColor whiteColor];
    self.navigationTitle.textColor = titleColor;
    UIColor * separateColor = (kAppColorLight) ? [UIColor whiteColor] : kDarkThemeBackgroundColor;
    self.separateNavigationView.backgroundColor = separateColor;
    
    [self setupDisclaimer];
    [self requestProducts];
}

- (void)setupDisclaimer {
    // Setup Disclaimers - REQUIRED for IAP subscriptions
    //  - if you want to modify the text, make sure it complies with Apple's Paid Application agreement (needs to state subscription terms, how to manage and how to link to a privacy policy and terms of service)
    self.disclaimerWebviewParent.backgroundColor = [UIColor clearColor];
    WKWebViewConfiguration *wkWebConfig = [[WKWebViewConfiguration alloc] init];
    self.disclaimerWebview =  [[WKWebView alloc] initWithFrame:self.disclaimerWebviewParent.bounds configuration:wkWebConfig];
    self.disclaimerWebview.frame = self.disclaimerWebviewParent.bounds;
    self.disclaimerWebview.opaque = false;
    self.disclaimerWebview.backgroundColor = [UIColor clearColor];
    self.disclaimerWebview.navigationDelegate = self;
    self.disclaimerWebview.scrollView.showsHorizontalScrollIndicator = NO;
    self.disclaimerWebview.scrollView.showsVerticalScrollIndicator = NO;
    [self.disclaimerWebviewParent addSubview:self.disclaimerWebview];
    
    self.disclaimerWebview.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.disclaimerWebviewParent addConstraint:[NSLayoutConstraint constraintWithItem:self.disclaimerWebview
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.disclaimerWebviewParent
                                                          attribute:NSLayoutAttributeHeight
                                                         multiplier:1
                                                           constant:0]];
    
    [self.disclaimerWebviewParent addConstraint:[NSLayoutConstraint constraintWithItem:self.disclaimerWebview
                                                          attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.disclaimerWebviewParent
                                                          attribute:NSLayoutAttributeWidth
                                                         multiplier:1
                                                           constant:0]];
    
    [self.disclaimerWebviewParent addConstraint:[NSLayoutConstraint constraintWithItem:self.disclaimerWebview
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.disclaimerWebviewParent
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1
                                                           constant:0]];
    
    [self.disclaimerWebviewParent addConstraint:[NSLayoutConstraint constraintWithItem:self.disclaimerWebview
                                                          attribute:NSLayoutAttributeCenterY
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.disclaimerWebviewParent
                                                          attribute:NSLayoutAttributeCenterY
                                                         multiplier:1
                                                           constant:0]];
    
    
    NSString *htmlFile;
    
    if (kAppColorLight){
        htmlFile = [[NSBundle mainBundle] pathForResource:@"VideoSummaryLight" ofType:@"html"];
    } else {
        htmlFile = [[NSBundle mainBundle] pathForResource:@"VideoSummary" ofType:@"html"];
    }
    NSString *htmlString = [NSString stringWithContentsOfFile:htmlFile encoding:NSUTF8StringEncoding error:nil];
    
    NSString *privacyLink = [NSString stringWithFormat:@"<a href=\"%@\">Privacy Policy</a>", [[NSUserDefaults standardUserDefaults] stringForKey:kPrivacyPolicyUrl] ];
    NSString *termsLink = [NSString stringWithFormat:@"<a href=\"%@\">Terms of Service</a>", [[NSUserDefaults standardUserDefaults] stringForKey:kTermsOfServiceUrl] ];
    NSString *disclaimerText = [NSString stringWithFormat:kString_SubscriptionDisclaimer, privacyLink, termsLink];
    
    UIColor *brandColor = kClientColor;
    NSString *styledDisclaimer = [NSString stringWithFormat:@"<style type=\"text/css\">a {color: #%@;} body p {font-size: 13px;}</style>%@", [UIUtil hexStringWithUicolor:brandColor], disclaimerText];
    
    NSString *headerString = @"<header><meta name='viewport' content='width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no'></header>";
    htmlString = [NSString stringWithFormat:htmlString, @"", styledDisclaimer, nil];
    htmlString = [headerString stringByAppendingString:htmlString];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.disclaimerWebview loadHTMLString:htmlString baseURL:nil];
    });
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    
    if (navigationAction.navigationType == WKNavigationTypeLinkActivated) {
        NSURLRequest *request = navigationAction.request;
        [[UIApplication sharedApplication] openURL:[request URL]];
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    decisionHandler(WKNavigationActionPolicyAllow);
}

#pragma mark - Subscription plan

- (void)getSubscriptionPlan {
    [SVProgressHUD show];
    [[RESTServiceController sharedInstance] getSubscriptionPlan:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (data != nil) {
            NSError *localError = nil;
            NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
            if (parsedObject != nil){
              
                self.products = [[NSMutableArray alloc] init];
                CLS_LOG(@"SubscriptionPlan Parsed Object: %@", parsedObject);
                //_products = parsedObject[@"response"];
                for(NSDictionary * plan in parsedObject[@"response"]) {
                    if ([kZypeSubscriptionIds containsObject:plan[@"_id"]]) {
                        self.products = [self.products arrayByAddingObject:plan];
                    }
                }
                
                [self.tableView reloadData];
                [SVProgressHUD dismiss];
            }else if (parsedObject != nil && parsedObject[@"error"] != nil) {
                
                CLS_LOG(@"SubscriptionPlan json error: %@", parsedObject[@"error"]);
                [SVProgressHUD dismiss];
                
            }
            
        }
    }];
}

#pragma mark - in app purchases

- (void)requestProducts {
    dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD show];
    });
    [[ACPurchaseManager sharedInstance] requestSubscriptions:^(NSArray *products) {
        [SVProgressHUD dismiss];
        self.products = products;
        [self.tableView reloadData];
    } failure:^(NSString *errorString) {
        [SVProgressHUD showErrorWithStatus:errorString];
    }];
}

- (void)buySubscription:(SKProduct *)product {
    [SVProgressHUD showWithStatus:@"Purchasing..."];
    [[ACPurchaseManager sharedInstance] buySubscription:product.productIdentifier success:^(){
        NSLog(@"Success");
        
        NSData*appReceipt = [NSData dataWithContentsOfURL:[[NSBundle mainBundle] appStoreReceiptURL]];
        NSDictionary *dictionary = [[NSUserDefaults standardUserDefaults] objectForKey:kSettingKey_Subscriptions];
        [[RESTServiceController sharedInstance] createMarketplace:appReceipt planId:dictionary[product.productIdentifier] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if (error) {
                [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            } else {
                [SVProgressHUD dismiss];
                
                // Update local user info. Should have subscription
                [ACSDataManager loadUserInfo];
                
                UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Thank you for creating an account!"
                                                                               message:@"You can now enjoy watching video content."
                                                                        preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleDefault
                                                                      handler:^(UIAlertAction * action) {
                                                                          [self dismisControllers];
                                                                          if ( self.planDelegate != nil ) {
                                                                              [self.planDelegate subscriptionPlanDone];
                                                                          }
                                                                      }];
                
                [alert addAction:defaultAction];
                [self presentViewController:alert animated:YES completion:nil];
            }
        }];
        
    } failure:^(NSString *errorString) {
        [SVProgressHUD dismiss];
        [ACSAlertViewManager showAlertWithTitle:nil WithMessage:errorString];
    }];
}

#pragma mark - SubscriptActiveCellDelegate

- (void)onDidTapSubsciptCell:(SubscriptActiveCell *)cell product:(SKProduct *)product {
    [self buySubscription:product];
}

#pragma mark - UITableViewDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *subscriptActiveCell = @"SubscriptActiveCell";
    
    SubscriptActiveCell *cell = [self.tableView dequeueReusableCellWithIdentifier:subscriptActiveCell forIndexPath:indexPath];

    SKProduct *product = self.products[indexPath.row];
    [cell setDelegate: self];
    [cell configCell:product];
    
    //[cell setSelectedCell:(self.selectedIndex == indexPath.row)];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedIndex = indexPath.row;
    [self.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.products.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    return self.tableView.frame.size.height / self.products.count;
//}

#pragma mark - Actions

- (IBAction)cancelController:(id)sender {
    [self dismisControllers];
    //[self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}


- (void)dismisControllers {
    if ([self.presentingViewController.presentingViewController isKindOfClass:[IntroViewController class]]) {
        [self.presentingViewController.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    } else if ([self.presentingViewController.presentingViewController isKindOfClass:[SignInViewController class]]) {
        [self.presentingViewController.presentingViewController.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
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

