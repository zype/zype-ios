//
//  AppDelegate.m
//  Zype
//
//  Created by ZypeTech on 1/26/15.
//  Copyright (c) 2015 Zype. All rights reserved.
//

#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>

#import "AppDelegate.h"
#import "RESTServiceController.h"
#import "ACSDataManager.h"
#import "ACSPersistenceManager.h"
#import "ACSNotificationsManager.h"
#import "ACStatusManager.h"
#import "HomeViewController.h"
#import "DownloadsViewController.h"
#import "FavoritesViewController.h"
#import "HighlightsViewController.h"
#import "GAI.h"

#import "UIColor+AC.h"

@interface AppDelegate ()

@property (nonatomic) unsigned long tabIndex;

@end

@implementation AppDelegate
@synthesize keychainItem = _keychainItem;

+ (AppDelegate *)appDelegate
{
    return (AppDelegate *)[UIApplication sharedApplication].delegate;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [Fabric with:@[CrashlyticsKit]];
    
    //Ask users to recieve push notifications.
    //You can place this in another part of your app.
    if (![kOneSignalNotificationsKey isEqualToString:@""]){
        self.oneSignal = [[OneSignal alloc] initWithLaunchOptions:launchOptions appId:kOneSignalNotificationsKey handleNotification:nil];
    }
    [self setupGoogleAnalytics];
    [self configureApp];
    [self setDefaultAppearance];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    // Set local notification
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kSettingKey_LiveShowNotification]){
        [ACSNotificationsManager setLocalNotifications];
    }
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.

    // Sync videos
    NSDate *fromDate = [UIUtil startOfWeek:[NSDate date]];
    NSDate *toDate = [UIUtil endOfWeek:[NSDate date]];
    [[RESTServiceController sharedInstance] syncVideosFromDate:fromDate ToDate:toDate InPage:nil WithVideosInDB:nil WithExistingVideos:nil];
    
    [ACSDataManager syncHighlights];
    
    // Register for notification
    [self registerForNotification];
    
    // Sync notifications
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kSettingKey_LiveShowNotification]){
        [[RESTServiceController sharedInstance] syncNotificationsInPage:nil WithNotificationsInDB:nil WithExistingNotifications:nil];
    }
    
    // Check live stream
    [ACSDataManager checkForLiveStream];
    
    if ([ACStatusManager isUserSignedIn] == YES) {
        [ACSDataManager loadUserInfo];
    }
    
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [[ACSPersistenceManager sharedInstance] saveContext];
}

#pragma mark - Init App


- (void)setupGoogleAnalytics{
    
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    [GAI sharedInstance].dispatchInterval = 20;
    if (![kGoogleAnalyticsTracker isEqualToString:@""]){
        [[GAI sharedInstance] trackerWithTrackingId:kGoogleAnalyticsTracker];
    }
    [[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelInfo];
    
}

- (void)configureApp
{
#if TARGET_IPHONE_SIMULATOR
    // where are you?
    CLS_LOG(@"Documents Directory: %@", [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject]);
#endif

    
    // Set background fetch
    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    
    // Set default settings
    if (![[NSUserDefaults standardUserDefaults] objectForKey:kSettingKey_SignInStatus])
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kSettingKey_SignInStatus];
    if (![[NSUserDefaults standardUserDefaults] objectForKey:kSettingKey_AutoDownloadContent])
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kSettingKey_AutoDownloadContent];
    if (![[NSUserDefaults standardUserDefaults] objectForKey:kSettingKey_LiveShowNotification])
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kSettingKey_LiveShowNotification];
    if (![[NSUserDefaults standardUserDefaults] objectForKey:kSettingKey_DownloadWifiOnly])
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kSettingKey_DownloadWifiOnly];
    if (![[NSUserDefaults standardUserDefaults] objectForKey:kSettingKey_DownloadPreferences])
        [[NSUserDefaults standardUserDefaults] setObject:kSettingKey_DownloadAudio forKey:kSettingKey_DownloadPreferences];
    
    // Sync App settings
    [[RESTServiceController sharedInstance] syncAppSetting];
    [[RESTServiceController sharedInstance] syncLiveStreamZObject];
    [[RESTServiceController sharedInstance] syncAppContent];
    
    // Set tab bar delegate
    UITabBarController *tabBarController = (UITabBarController *)self.window.rootViewController;
    tabBarController.delegate = self;
    self.tabIndex = 0;
}

- (KeychainItemWrapper *)keychainItem
{
    if (_keychainItem != nil) {
        return _keychainItem;
    }
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _keychainItem = [[KeychainItemWrapper alloc] initWithIdentifier:@"AppSignIn" accessGroup:nil];
    });
    return _keychainItem;
}

// Restrict rotation of the selected view controllers
- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    BOOL iPad = NO;
    iPad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
    
    if(self.restrictRotation && iPad == NO){
        return UIInterfaceOrientationMaskPortrait;
    }else{
        return UIInterfaceOrientationMaskAll;
    }
}

#pragma mark - Background Fetch

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    // Sync videos
    NSDate *fromDate = [UIUtil startOfWeek:[NSDate date]];
    NSDate *toDate = [UIUtil endOfWeek:[NSDate date]];
    
    //TODO: Implement data manager class that returns a block so we can send the completionhandler the correct results
    [[RESTServiceController sharedInstance] syncVideosFromDate:fromDate ToDate:toDate InPage:nil WithVideosInDB:nil WithExistingVideos:nil];
    
    completionHandler(UIBackgroundFetchResultNewData);
    CLS_LOG(@"Fetch completed");
}

- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)())completionHandler {
    [self setBackgroundSessionCompletionHandler:completionHandler];
}


#pragma mark - Local notifications

- (void)registerForNotification
{
    UIUserNotificationType types = UIUserNotificationTypeSound | UIUserNotificationTypeBadge | UIUserNotificationTypeAlert;
    UIUserNotificationSettings *notificationSettings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings];
}
#ifdef __IPHONE_8_0
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    if (notificationSettings.types == UIUserNotificationTypeNone)
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kSettingKey_LiveShowNotification];
    else
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kSettingKey_LiveShowNotification];
}
#endif

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)tokenData
{
    
    
    
}


#pragma mark - Tab Bar Delegate

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    if (self.tabIndex == tabBarController.selectedIndex) {
        UITabBarController *tabBarController = (UITabBarController *)self.window.rootViewController;
        
        if (tabBarController.selectedIndex == 0) {
            UINavigationController *navigationController = (UINavigationController *)[[tabBarController viewControllers] objectAtIndex:0];
            HomeViewController *latestViewController = (HomeViewController *)[[navigationController viewControllers] objectAtIndex:0];
          //  [latestViewController resetFilter];
            latestViewController.tableView.contentOffset = CGPointMake(0, 0 - latestViewController.tableView.contentInset.top);
        }
      /*  else if (tabBarController.selectedIndex == 1) {
            UINavigationController *navigationController = (UINavigationController *)[[tabBarController viewControllers] objectAtIndex:1];
            DownloadsViewController *downloadsViewController = (DownloadsViewController *)[[navigationController viewControllers] objectAtIndex:0];
            downloadsViewController.tableView.contentOffset = CGPointMake(0, 0 - downloadsViewController.tableView.contentInset.top);
        }*/
        else if (tabBarController.selectedIndex == 1) {
            UINavigationController *navigationController = (UINavigationController *)[[tabBarController viewControllers] objectAtIndex:1];
            FavoritesViewController *favoritesViewController = (FavoritesViewController *)[[navigationController viewControllers] objectAtIndex:0];
            favoritesViewController.tableView.contentOffset = CGPointMake(0, 0 - favoritesViewController.tableView.contentInset.top);
        }
//        else if (tabBarController.selectedIndex == 3) {
//            UINavigationController *navigationController = (UINavigationController *)[[tabBarController viewControllers] objectAtIndex:3];
//            HighlightsViewController *highlightsViewController = (HighlightsViewController *)[[navigationController viewControllers] objectAtIndex:0];
//            highlightsViewController.tableView.contentOffset = CGPointMake(0, 0 - highlightsViewController.tableView.contentInset.top);
//        }
    }
    
    self.tabIndex = tabBarController.selectedIndex;
}

#pragma mark - Appearance

- (void)setDefaultAppearance{
    
    //set tint color of all views so UIActionView will have the correct color
    //[[UIView appearance] setTintColor:[UIColor ACMainTintColor]];
    
    //reset the deselected tab bar item color due to bug when setting UIView tint color
    [[UIView appearanceWhenContainedIn:[UITabBar class], nil] setTintColor:[UIColor darkGrayColor]];//color for inactive item
    [UITabBar appearance].tintColor = [UIColor ZypeMainTintColor];//color for active item
    
    // Set custom appearance
   /* [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                          kSystemWhite, NSForegroundColorAttributeName,
                                                          [UIFont fontWithName:kFontRegular size:18.0], NSFontAttributeName,
                                                          nil]];
    
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                       [UIColor grayColor], NSForegroundColorAttributeName,
                                                       [UIFont fontWithName:kFontSemibold size:12.0], NSFontAttributeName,
                                                       nil] forState:UIControlStateNormal];
    
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                       kSystemWhite, NSForegroundColorAttributeName,
                                                       [UIFont fontWithName:kFontSemibold size:12.0], NSFontAttributeName,
                                                       nil] forState:UIControlStateSelected];*/
    
//    [[UINavigationBar appearance] setBackgroundImage:[[UIImage alloc] init]
//                                      forBarPosition:UIBarPositionAny
//                                          barMetrics:UIBarMetricsDefault];
    
//    [[UINavigationBar appearance] setShadowImage:[[UIImage alloc] init]];
//    [[UINavigationBar appearance] setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    
    //status bar can be configured here or disabled here and configured in info.plist
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    
}

@end
