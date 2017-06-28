//
//  SettingsViewController.m
//  Zype
//
//  Created by ZypeTech on 2/25/15.
//  Copyright (c) 2015 Zype. All rights reserved.
//

#import <AdSupport/ASIdentifierManager.h>
#import "SettingsViewController.h"
#import "SettingsDetailViewController.h"
#import "AppDelegate.h"
#import "ACSDataManager.h"
#import "ACDownloadManager.h"
#import "ACSTokenManager.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "Timing.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import "ACPurchaseManager.h"
#import "TableSectionDataSource.h"


@interface SettingsViewController ()
@property (strong, nonatomic) UISwitch *switchAutoDownload;
@property (strong, nonatomic) UISwitch *switchNotification;
@property (strong, nonatomic) NSMutableArray *settingsDataSource;

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.screenName = @"Settings";
    [self configureView];
    [self configureSettings];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Restrict rotation
    [AppDelegate appDelegate].restrictRotation = YES;
    
    // Set now playing bar button
    if (!self.navigationItem.rightBarButtonItem || ![[NSUserDefaults standardUserDefaults] boolForKey:kSettingKey_SignInStatus]) {
        UIButton *button = [UIUtil buttonNowPlayingInViewController:self];
        [button addTarget:self action:@selector(showNowPlayingVideoDetail:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    // Set sign-out button
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kSettingKey_SignInStatus]) [self.buttonSignOut setHidden:NO];
    else [self.buttonSignOut setHidden:YES];
    [self customizeAppearance];
}

- (void)configureSettings {
    self.settingsDataSource = [[NSMutableArray alloc] init];
    TableSectionDataSource *termsOfServise = [[TableSectionDataSource alloc] init];
    termsOfServise.title = @"Terms of Service & Privacy";
    termsOfServise.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    termsOfServise.type = TermsOfService;
    [self.settingsDataSource addObject:termsOfServise];
    
    if (kNativeSubscriptionEnabled) {
        TableSectionDataSource *restorePurchase = [[TableSectionDataSource alloc] init];
        restorePurchase.title = @"Restore Purchase";
        restorePurchase.type = RestorePurchase;
        [self.settingsDataSource addObject:restorePurchase];
    }
    
    TableSectionDataSource *version = [[TableSectionDataSource alloc] init];
    version.title = @"Version";
    UILabel *labelVersion = [[UILabel alloc] init];
    NSString *versionText = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    labelVersion.text = versionText;
    if (!kAppColorLight) labelVersion.textColor = [UIColor whiteColor];
    [labelVersion sizeToFit];
    version.accessoryView = labelVersion;
    version.type = Version;
    [self.settingsDataSource addObject:version];
    
    [self.tableView reloadData];
}

- (void)customizeAppearance {
    if (kAppColorLight){
        
    } else {
        self.view.backgroundColor = [UIColor blackColor];
    }
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)showNowPlayingVideoDetail:(id)sender
{
    [UIUtil showNowPlayingFromViewController:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showSettingsDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        [[segue destinationViewController] setPageIndex:indexPath];
    }
}

#pragma mark - Init UI

- (void)setPageIndex:(NSIndexPath *)pageIndex
{
    if (_pageIndex != pageIndex) {
        _pageIndex = pageIndex;
    }
    
    switch (self.pageIndex.row) {
        case 0:
            self.hidesBottomBarWhenPushed = NO;
            break;
        case 2:
            self.hidesBottomBarWhenPushed = YES;
            break;
        case 3:
            self.hidesBottomBarWhenPushed = YES;
            break;
        default:
            break;
    }
}

- (void)configureView
{
    self.buttonSignOut.backgroundColor = kClientColor;
    switch (self.pageIndex.row) {
        case 0: {
            self.title = @"Settings";
            [self.webView setHidden:YES];
        }
            break;
        case 2: {
            self.title = @"Facebook";
            [self.webView setHidden:NO];
            [self.webView loadRequest:[[NSURLRequest alloc] initWithURL:[NSURL URLWithString:kACFacebook]]];
        }
            break;
        case 3: {
            self.title = @"Twitter";
            [self.webView setHidden:NO];
            [self.webView loadRequest:[[NSURLRequest alloc] initWithURL:[NSURL URLWithString:kACTwitter]]];
        }
            break;
        case 4: {
            self.title = @"Web";
            [self.webView setHidden:NO];
            [self.webView loadRequest:[[NSURLRequest alloc] initWithURL:[NSURL URLWithString:kACWeb]]];
        }
            break;
            
        case 5: {
            self.title = @"Instagram";
            [self.webView setHidden:NO];
            [self.webView loadRequest:[[NSURLRequest alloc] initWithURL:[NSURL URLWithString:kACInstagram]]];
        }
            break;
            
        default:
            break;
    }
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:nil
                                                                            action:nil];
    self.tableView.tableFooterView = [UIView new];
    self.switchAutoDownload = [[UISwitch alloc] init];
    self.switchNotification = [[UISwitch alloc] init];
    [self.switchAutoDownload addTarget:self action:@selector(switchedAutoDownload:) forControlEvents:UIControlEventValueChanged];
    [self.switchNotification addTarget:self action:@selector(switchedNotification:) forControlEvents:UIControlEventValueChanged];
}

- (void)switchedAutoDownload:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setBool:self.switchAutoDownload.on forKey:kSettingKey_AutoDownloadContent];
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    
    switch (self.switchAutoDownload.on) {
        case YES:
        {
            
            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:kAnalyticsScreenNameSettings action:kAnalyticsActSwitchPressed label:kAnalyticsEventLabelAutoDLOn value:nil] build]];
            
            [ACDownloadManager autoDownloadLatestVideo];
            
        }
            break;
        case NO:
        {
            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:kAnalyticsScreenNameSettings action:kAnalyticsActSwitchPressed label:kAnalyticsEventLabelAutoDLOff value:nil] build]];
        }
        default:
            break;
    }
    
}
- (void)switchedNotification:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setBool:self.switchNotification.on forKey:kSettingKey_LiveShowNotification];
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    
    switch (self.switchNotification.on) {
        case YES:
        {
            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:kAnalyticsScreenNameSettings action:kAnalyticsActSwitchPressed label:kAnalyticsEventLabelPushNoteOn value:nil] build]];
        }
            break;
        case NO:
        {
            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:kAnalyticsScreenNameSettings action:kAnalyticsActSwitchPressed label:kAnalyticsEventLabelPushNoteOff value:nil] build]];
        }
        default:
            break;
    }
}

#pragma mark - TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 0; //hide rows in the first section
        /*if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0f) return 2;
         else return 3;*/
    }
    else if (section == 1) return self.settingsDataSource.count;
    else return 0;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SettingsCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    if (kAppColorLight){
        
    } else {
        cell.textLabel.textColor = [UIColor whiteColor];
    }
    
    cell.textLabel.font = [UIFont fontWithName:kFontSemibold size:15];
    UIView * selectedBackgroundView = [[UIView alloc] init];
    [selectedBackgroundView setBackgroundColor:[UIColor darkGrayColor]];
    [cell setSelectedBackgroundView:selectedBackgroundView];
    
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0: {
                cell.textLabel.text = @"Auto Download Content";
                cell.accessoryView = self.switchAutoDownload;
                BOOL autoDownload = [[NSUserDefaults standardUserDefaults] boolForKey:kSettingKey_AutoDownloadContent];
                self.switchAutoDownload.on = autoDownload;
            }
                break;
            case 1:
                cell.textLabel.text = @"Download Preferences";
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                break;
            case 2: {
                cell.textLabel.text = @"Live Show Notification";
                cell.accessoryView = self.switchNotification;
                self.switchNotification.on = [[NSUserDefaults standardUserDefaults] boolForKey:kSettingKey_LiveShowNotification];
            }
                break;
        }
    }
    else if (indexPath.section == 1) {
        TableSectionDataSource *item = self.settingsDataSource[indexPath.row];
        cell.textLabel.text = item.title;
        cell.accessoryView = item.accessoryView;
        cell.accessoryType = item.accessoryType;
//        switch (indexPath.row) {
//            case 0: {
//                cell.textLabel.text = @"Terms of Service & Privacy";
//                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//            }
//                break;
//            case 1:
//            {
//                cell.textLabel.text = @"Restore Purchases";
//            }
//                break;
//            case 2:
//            {
//                cell.textLabel.text = @"Version";
//                UILabel *labelVersion = [[UILabel alloc] init];
//                NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
//                labelVersion.text = version;
//                if (kAppColorLight){
//                    
//                } else {
//                    labelVersion.textColor = [UIColor whiteColor];
//                }
//                
//                [labelVersion sizeToFit];
//                cell.accessoryView = labelVersion;
//                break;
//                //cell.textLabel.text = @"Powered By Zype";
//            }
//                break;
//                
//        }
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55.0f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    //hide content settings header
    if (section == 0)
        return 0;
    else
        return 0;//kSettingsHeaderHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString *title = @"";
    if (section == 0) title = @"Content Settings";
    else if (section == 1) title = @"About";
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, kSettingsHeaderHeight)];
    headerView.backgroundColor = [UIColor lightGrayColor];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(kSettingsHeaderMargin, 0, self.view.frame.size.width - (kSettingsHeaderMargin * 2), kSettingsHeaderHeight)];
    label.font = [UIFont fontWithName:kFontBold size:16];
    label.textColor = [UIColor whiteColor];
    label.text = title;
    
    [headerView addSubview:label];
    return headerView;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1 && indexPath.row == 2) return nil;
    else return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 0) {
        self.switchAutoDownload.on = !self.switchAutoDownload.on;
        [[NSUserDefaults standardUserDefaults] setBool:self.switchAutoDownload.on forKey:kSettingKey_AutoDownloadContent];
        if (self.switchAutoDownload.on == YES) {
            [ACDownloadManager autoDownloadLatestVideo];
        }
    }
    else if (indexPath.section == 0 && indexPath.row == 2) {
        self.switchNotification.on = !self.switchNotification.on;
        [[NSUserDefaults standardUserDefaults] setBool:self.switchNotification.on forKey:kSettingKey_LiveShowNotification];
    }
    else if (indexPath.section == 1)
    {
        TableSectionDataSource *item = self.settingsDataSource[indexPath.row];
        switch (item.type) {
            case TermsOfService: {
                NSString *htmlString = [[NSUserDefaults standardUserDefaults] stringForKey:kSettingKey_Terms];
                
                UIViewController *viewController = [UIViewController new];
                viewController.view.frame = self.view.bounds;
                
                UIWebView *webview = [UIWebView new];
                webview.frame = viewController.view.bounds;
                
                [viewController.view addSubview:webview];
                
                [webview loadHTMLString:htmlString baseURL:nil];
                [self.navigationController pushViewController:viewController animated:YES];
                
                break;
            }

            case RestorePurchase:
                [self restorePurchases];
                break;
            default:
                break;
        }
        

    } else {
        [self performSegueWithIdentifier:@"showSettingsDetail" sender:self];
    }
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [cell setBackgroundColor:[UIColor clearColor]];
}

- (IBAction)signOutTapped:(id)sender {
    
    [ACSDataManager logout];
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:kAnalyticsScreenNameSettings action:kAnalyticsCategoryButtonPressed label:@"Sign Out" value:nil] build]];
    
    // Go back
    [self.navigationController popToRootViewControllerAnimated:YES];
    
}

- (void)restorePurchases {
    [SVProgressHUD show];
    [[ACPurchaseManager sharedInstance] restorePurchases:^{
        [SVProgressHUD showSuccessWithStatus:@"Success"];
    } failure:^(NSString *errorString) {
        [SVProgressHUD showErrorWithStatus:errorString];
    }];
}



@end
