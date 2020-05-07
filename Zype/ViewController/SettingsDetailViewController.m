//
//  SettingsDetailViewController.m
//  Zype
//
//  Created by ZypeTech on 2/25/15.
//  Copyright (c) 2015 Zype. All rights reserved.
//

#import <AdSupport/ASIdentifierManager.h>
#import "SettingsDetailViewController.h"
#import "Timing.h"
#import "GAIDictionaryBuilder.h"
#import "AppDelegate.h"

@interface SettingsDetailViewController ()
@property (strong, nonatomic) UISwitch *switchDownloadWifiOnly;

@end

@implementation SettingsDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupWkWebView];
    [self configureView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.screenName = @"Settings Detail";
    
    // Restrict rotation
    [AppDelegate appDelegate].restrictRotation = YES;
    
    // Set now playing bar button
    if (!self.navigationItem.rightBarButtonItem || ![[NSUserDefaults standardUserDefaults] boolForKey:kSettingKey_SignInStatus]) {
        UIButton *button = [UIUtil buttonNowPlayingInViewController:self];
        [button addTarget:self action:@selector(showNowPlayingVideoDetail:) forControlEvents:UIControlEventTouchUpInside];
    }
}
- (void)showNowPlayingVideoDetail:(id)sender
{
    [UIUtil showNowPlayingFromViewController:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Init UI

-(void)setupWkWebView {
    WKWebViewConfiguration *wkWebConfig = [[WKWebViewConfiguration alloc] init];
    self.wkWebView = [[WKWebView alloc] initWithFrame:self.tableView.frame configuration:wkWebConfig];
    self.wkWebView.opaque = NO;
    self.wkWebView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.wkWebView];
    
    self.wkWebView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.wkWebView
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.tableView
                                                          attribute:NSLayoutAttributeHeight
                                                         multiplier:1
                                                           constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.wkWebView
                                                          attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.tableView
                                                          attribute:NSLayoutAttributeWidth
                                                         multiplier:1
                                                           constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.wkWebView
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.tableView
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1
                                                           constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.wkWebView
                                                          attribute:NSLayoutAttributeCenterY
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.tableView
                                                          attribute:NSLayoutAttributeCenterY
                                                         multiplier:1
                                                           constant:0]];
}

- (void)setPageIndex:(NSIndexPath *)pageIndex
{
    if (_pageIndex != pageIndex) {
        _pageIndex = pageIndex;
    }
    
    if (self.pageIndex.section == 0 && self.pageIndex.row == 1)
        self.hidesBottomBarWhenPushed = NO;
    else
        self.hidesBottomBarWhenPushed = YES;
}

- (void)configureView
{
    if (self.pageIndex.section == 0 && self.pageIndex.row == 1) {
        self.title = @"Download Preferences";
        [self.wkWebView setHidden:YES];
        [self.tableView setHidden:NO];
    }

    self.tableView.tableFooterView = [UIView new];
    self.switchDownloadWifiOnly = [[UISwitch alloc] init];
    [self.switchDownloadWifiOnly addTarget:self action:@selector(switchedDownloadWifiOnly:) forControlEvents:UIControlEventValueChanged];
}

- (void)switchedDownloadWifiOnly:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setBool:self.switchDownloadWifiOnly.on forKey:kSettingKey_DownloadWifiOnly];
}

#pragma mark - TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SettingsDetailCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.font = [UIFont fontWithName:kFontSemibold size:15];
    UIView * selectedBackgroundView = [[UIView alloc] init];
    [selectedBackgroundView setBackgroundColor:[UIColor darkGrayColor]];
    [cell setSelectedBackgroundView:selectedBackgroundView];
    
    switch (indexPath.row) {
        case 0: {
            cell.textLabel.text = @"Download on Wifi Only";
            cell.accessoryView = self.switchDownloadWifiOnly;
            self.switchDownloadWifiOnly.on = [[NSUserDefaults standardUserDefaults] boolForKey:kSettingKey_DownloadWifiOnly];
        }
            break;
        case 2: {
            cell.textLabel.text = @"Download Audio";
            cell.tintColor = [UIColor whiteColor];
            if ([[[NSUserDefaults standardUserDefaults] stringForKey:kSettingKey_DownloadPreferences] isEqualToString:kSettingKey_DownloadAudio])
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            else
                cell.accessoryType = UITableViewCellAccessoryNone;
        }
            break;
        case 3: {
            cell.textLabel.text = @"Download Video";
            cell.tintColor = [UIColor whiteColor];
            if ([[[NSUserDefaults standardUserDefaults] stringForKey:kSettingKey_DownloadPreferences] isEqualToString:kSettingKey_DownloadVideo])
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            else
                cell.accessoryType = UITableViewCellAccessoryNone;
        }
            break;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55.0f;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 1) return nil;
    else return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    
    switch (indexPath.row) {
        case 0: {
            self.switchDownloadWifiOnly.on = !self.switchDownloadWifiOnly.on;
            
            switch (self.switchDownloadWifiOnly.on) {
                case YES:
                {
                    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:kAnalyticsScreenNameSettingsDetail action:kAnalyticsActSwitchPressed label:kAnalyticsEventLabelWiFiOn value:nil] build]];
                }
                    break;
                case NO:
                {
                    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:kAnalyticsScreenNameSettingsDetail action:kAnalyticsActSwitchPressed label:kAnalyticsEventLabelWiFiOff value:nil] build]];
                }
                default:
                    break;
            }
            
            [[NSUserDefaults standardUserDefaults] setBool:self.switchDownloadWifiOnly.on forKey:kSettingKey_DownloadWifiOnly];
        }
            break;
        case 2: {
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
            cell.accessoryType = UITableViewCellAccessoryNone;
            [[NSUserDefaults standardUserDefaults] setObject:kSettingKey_DownloadAudio forKey:kSettingKey_DownloadPreferences];
            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:kAnalyticsScreenNameSettingsDetail action:kAnalyticsActSwitchPressed label:kAnalyticsEventLabelDLAudio value:nil] build]];
        }
            break;
        case 3: {
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
            cell.accessoryType = UITableViewCellAccessoryNone;
            [[NSUserDefaults standardUserDefaults] setObject:kSettingKey_DownloadVideo forKey:kSettingKey_DownloadPreferences];
            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:kAnalyticsScreenNameSettingsDetail action:kAnalyticsActSwitchPressed label:kAnalyticsEventLabelDLVideo value:nil] build]];
        }
            break;
    }
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [cell setBackgroundColor:[UIColor clearColor]];
}

@end
