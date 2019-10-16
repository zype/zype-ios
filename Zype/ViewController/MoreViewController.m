//
//  MoreViewController.m
//  Zype
//
//  Created by ZypeTech on 1/26/15.
//  Copyright (c) 2015 Zype. All rights reserved.
//

#import <AdSupport/ASIdentifierManager.h>
#import "MoreViewController.h"
#import "SettingsViewController.h"
#import "GAI.h"
#import "GAITrackedViewController.h"
#import "Timing.h"
#import "AppDelegate.h"
#import "UIView+UIView_CustomizeTheme.h"
#import "ACSDataManager.h"
#import "ACStatusManager.h"

@interface MoreViewController ()

@end

@implementation MoreViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:nil
                                                                            action:nil];
    
    self.screenName = @"More";
    self.tableView.tableFooterView = [UIView new];
    
    if (!kNativeSubscriptionEnabled) {
        [self.buttonSignIn setHidden: YES];
        self.buttonSignInHeight.constant = 0;
        self.buttonSignInBottom.constant = 0;
    }
    
    [self customizeAppearance];
}

- (void)customizeAppearance {
    [self.buttonSignIn tintCustomizeTheme];
    [self.buttonSignIn round:kViewCornerRounded];
    
    if (kAppColorLight) {
        
    } else {
        [self.navigationController.navigationBar setBarStyle:UIBarStyleBlackOpaque];
        self.view.backgroundColor = [UIColor blackColor];
    }
    
    // self.navigationController.navigationBar.backgroundColor = [UIColor blackColor];
    //
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
    if (![[NSUserDefaults standardUserDefaults] boolForKey:kSettingKey_SignInStatus])
        self.navigationItem.rightBarButtonItem = nil;
    
    // Set subscribe button
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kSettingKey_SignInStatus]) {
        [self.buttonSignIn setTitle: @"Sign Out" forState: UIControlStateNormal];
    } else {
        [self.buttonSignIn setTitle: @"Sign In" forState: UIControlStateNormal];
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
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    
    if ([[segue identifier] isEqualToString:@"showSettings"])
    {
        [[segue destinationViewController] setPageIndex:indexPath];
    }
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 6;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MoreCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    if (kAppColorLight) {
        
    } else {
        cell.textLabel.textColor = [UIColor whiteColor];
    }
    
    cell.textLabel.font = [UIFont fontWithName:kFontSemibold size:15];
    UIView * selectedBackgroundView = [[UIView alloc] init];
    [selectedBackgroundView setBackgroundColor:[UIColor darkGrayColor]];
    [cell setSelectedBackgroundView:selectedBackgroundView];
    
    NSString *bundleName = [[NSBundle mainBundle]
                            objectForInfoDictionaryKey:@"CFBundleName"];
    switch (indexPath.row) {
        case 0: {
            cell.textLabel.text = @"Settings";
            
            //change color for settings button icon
            UIImage *origImage = [UIImage imageNamed:@"IconSettingW"];
            UIImage *tintedImage = [origImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            cell.accessoryView = [[UIImageView alloc] initWithImage:tintedImage];
            [cell.accessoryView setTintColor:[UIColor lightGrayColor]];
        }
            break;
        case 2: {
            cell.textLabel.text = [NSString stringWithFormat:@"%@ on Facebook", bundleName];
            cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IconFacebookBlue"]];
            [cell.accessoryView setContentMode:UIViewContentModeScaleAspectFit];
        }
            break;
        case 3: {
            cell.textLabel.text = [NSString stringWithFormat:@"%@ on Twitter", bundleName];
            cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IconTwitterBlue"]];
        }
            break;
        case 4: {
            cell.textLabel.text = [NSString stringWithFormat:@"%@ on Instagram", bundleName];
            cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IconInstagram"]];
        }
            break;
        case 5: {
            cell.textLabel.text = [NSString stringWithFormat:@"%@ on Web", bundleName];
            // cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IconTwitterBlue"]];
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
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:kAnalyticsScreenNameMore action:kAnalyticsCategoryButtonPressed  label:@"Cell Selected" value:nil] build]];
    
    switch (indexPath.row) {
        case 0:
        {
            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:kAnalyticsScreenNameMore action:kAnalyticsCategoryButtonPressed label:@"Settings Pressed" value:nil] build]];
        }
            break;
        case 2:
        {
            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:kAnalyticsScreenNameMore action:kAnalyticsCategoryButtonPressed label:@"Facebook Loaded" value:nil] build]];
        }
        case 3:
        {
            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:kAnalyticsScreenNameMore action:kAnalyticsCategoryButtonPressed label:@"Twitter Loaded" value:nil] build]];
        }
        case 4:
        {
            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:kAnalyticsScreenNameMore action:kAnalyticsCategoryButtonPressed label:@"Instagram Loaded" value:nil] build]];
        }
        case 5:
        {
            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:kAnalyticsScreenNameMore action:kAnalyticsCategoryButtonPressed label:@"Web Loaded" value:nil] build]];
        }
        default:
            break;
    }
    
    [self performSegueWithIdentifier:@"showSettings" sender:self];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [cell setBackgroundColor:[UIColor clearColor]];
}

- (IBAction)signInTapped:(id)sender {
    
    if ([ACStatusManager isUserSignedIn] == false) {
        [UIUtil showSignInViewFromViewController:self];
    } else {    
        [ACSDataManager logout];
        
        id tracker = [[GAI sharedInstance] defaultTracker];
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:kAnalyticsScreenNameSettings action:kAnalyticsCategoryButtonPressed label:@"Sign Out" value:nil] build]];
        
        [self.buttonSignIn setTitle: @"Sign In" forState: UIControlStateNormal];
    }
}

@end
