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

@interface SubsciptionViewController ()<UITableViewDelegate, UITableViewDataSource, SubscriptActiveCellDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSSet *subscriptions;
@property (strong, nonatomic) NSArray *products;
@property (strong, nonatomic) NSArray *titles;
@property (assign, nonatomic) NSInteger selectedIndex;

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
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"SubscriptActiveCell" bundle:nil] forCellReuseIdentifier:@"SubscriptActiveCell"];
    self.tableView.scrollEnabled = FALSE;
    self.tableView.contentInset = UIEdgeInsetsMake(-36, 0, 0, 0);
    self.selectedIndex = 0;
    self.titles = @[@"Monthly Subscription", @"Yearly Subscription"];
    
    [self requestProducts];
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

- (void)buySubscription:(NSString *)productID {
    [SVProgressHUD showWithStatus:@"Purchasing..."];
    [[ACPurchaseManager sharedInstance] buySubscription:productID success:^{
        NSLog(@"Success");
        [SVProgressHUD dismiss];
        [self dismisControllers];
    } failure:^(NSString *errorString) {
        [SVProgressHUD dismiss];
        [ACSAlertViewManager showAlertWithTitle:nil WithMessage:errorString];
    }];
}

#pragma mark - SubscriptActiveCellDelegate

- (void)onDidTapSubsciptCell:(SubscriptActiveCell *)cell productID:(NSString *)productID {
    [self buySubscription:productID];
}

#pragma mark - UITableViewDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *subscriptActiveCell = @"SubscriptActiveCell";
    
    SubscriptActiveCell *cell = [self.tableView dequeueReusableCellWithIdentifier:subscriptActiveCell forIndexPath:indexPath];
    SKPayment *payment = self.products[indexPath.row];
    NSString *title = self.titles[indexPath.row];
    [cell setDelegate: self];
    [cell configureCell:payment];
    cell.titleLabel.text = title;
    [cell setSelectedCell:(self.selectedIndex == indexPath.row)];
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.tableView.frame.size.height / 2;
}

#pragma mark - Actions

- (IBAction)cancelController:(id)sender {
    [self dismisControllers];
    //[self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}


- (void)dismisControllers {
    if (self.presentingViewController.presentingViewController.presentingViewController) {
        [self.presentingViewController.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
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
