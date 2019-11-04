//
//  TabBarViewController.m
//  
//
//  Created by Andrey Kasatkin on 3/14/17.
//
//

#import "TabBarViewController.h"
#import "RESTServiceController.h"
#import "ACSPersistenceManager.h"
#import "VideoDetailViewController.h"
#import "SVProgressHUD.h"
#import "ACPurchaseManager.h"
#import "ACStatusManager.h"

@interface TabBarViewController ()

@end

@implementation TabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (kDownloadsEnabled) {
        [self addDownloadsViewController];
    }
    
    if (kEPGEnabled) {
        [self addEPGViewController];
    }
    
    if (kLiveItemEnabled) {
        self.delegate = self;
        [self addLiveViewController];
    }
    
    // Do any additional setup after loading the view.
}

- (void)addLiveViewController {
    NSMutableArray *tabViewControllers = [[NSMutableArray alloc] initWithArray:self.viewControllers];
    UIViewController *videoViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"NavigationLiveViewController"];
    
    if (kDownloadsEnabled) {
        [tabViewControllers insertObject:videoViewController atIndex: [self.viewControllers count] - 3];
    } else {
        [tabViewControllers insertObject:videoViewController atIndex: [self.viewControllers count] - 2];
    }
    [self setViewControllers:tabViewControllers];
}

- (void)addDownloadsViewController {
    NSMutableArray *tabViewControllers = [[NSMutableArray alloc] initWithArray:self.viewControllers];
    UIViewController *downloadsViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"NavigationDownloadsViewController"];
    //insert downloads at position before last one
    [tabViewControllers insertObject:downloadsViewController atIndex:[self.viewControllers count] - 1];
    //[tabViewControllers addObject:downloadsViewController];
    [self setViewControllers:tabViewControllers];
}

- (void) addEPGViewController {
    NSMutableArray *tabViewControllers = [[NSMutableArray alloc] initWithArray:self.viewControllers];
    UIViewController *epgViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"NavigationEPGViewController"];
    
    [tabViewControllers insertObject:epgViewController atIndex: 1];
    [self setViewControllers:tabViewControllers];
}

- (void) loadLiveVideo {
    [SVProgressHUD show];
    [[RESTServiceController sharedInstance] loadVideoWithId:kLiveVideoID withCompletionHandler:^(NSData *data, NSError *error) {
        [SVProgressHUD dismiss];
        if (error == nil){
            Video *videoInDB = [ACSPersistenceManager videoWithID: kLiveVideoID];
            NSError *localError = nil;
            NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
            
            if (videoInDB == nil) {
                if (localError == nil){
                    if ([[parsedObject objectForKey:@"response"] count] > 0) {
                        NSDictionary *videoData = [parsedObject objectForKey:@"response"][0];
                        
                        videoInDB = [ACSPersistenceManager newVideo];
                        [ACSPersistenceManager saveVideoInDB:videoInDB WithData:videoData];
                    }
                }
            }
            
            if (videoInDB != nil) {
                self.selectedVideo = videoInDB;
                //check for video for registration
                if ([ACStatusManager isUserSignedIn] == NO && videoInDB.registration_required.intValue == 1){
                    [UIUtil showWatcherIntroViewFromViewController:self];
                    return;
                }
                //check for video with subscription
                if (kNativeSubscriptionEnabled == NO) {
                    if ([ACStatusManager isUserSignedIn] == false && videoInDB.subscription_required.intValue == 1) {
                        [UIUtil showSignInViewFromViewController:self];
                        return;
                    }
                } else {
                    if ([ACStatusManager isUserSignedIn] == false && videoInDB.subscription_required.intValue == 1) {
                        [UIUtil showIntroViewFromViewController:self];
                        return;
                    } else {
                        if ([videoInDB.subscription_required intValue] == 1) {
                            if ([[ACPurchaseManager sharedInstance] isActiveSubscription] == false && [[[NSUserDefaults standardUserDefaults] valueForKey:kOAuthProperty_Subscription] isEqualToNumber:[NSNumber numberWithInt:0]]) {
                                [UIUtil showSubscriptionViewFromViewController:self];
                                return;
                            }
                        }
                    }
                }
                
                [self presentLiveVideo];
            } else {
                UIAlertController * alert = [UIAlertController alertControllerWithTitle:nil message:@"Can't find video" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction * okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
                [alert addAction:okAction];
                [self presentViewController:alert animated:YES completion:nil];
            }
        }
    }];
}

- (void) presentLiveVideo {
    if (self.selectedVideo != nil) {
        UINavigationController *navigationVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"NavigationLiveViewController"];
        VideoDetailViewController *videoVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"videoDetailViewController"];
        NSMutableArray *videos = [[NSMutableArray alloc] init];
        [videos addObject: self.selectedVideo];
        [videoVC setVideos:videos withIndex: 0];
        [videoVC setIsLive:YES];
        
        navigationVC = [navigationVC initWithRootViewController:videoVC];
        [self presentViewController:navigationVC animated:YES completion:nil];
    }
}

#pragma mark - UITabBarControllerDelegate

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    if (kLiveItemEnabled) {
        int objectIndex = kDownloadsEnabled ? (int)[self.viewControllers count] - 4 : (int)[self.viewControllers count] - 3;
        if (viewController == [tabBarController.viewControllers objectAtIndex: objectIndex]) {
            [self loadLiveVideo];
            return NO;
        }
    }
    
    return YES;
}

#pragma mark - SubscriptionPlanDelegate
- (void)subscriptionSignInDone {
    if (kNativeSubscriptionEnabled == NO) {
        [self presentLiveVideo];
    } else {
        if ([[[NSUserDefaults standardUserDefaults] valueForKey:kOAuthProperty_Subscription] intValue] > 0) {
            [self presentLiveVideo];
        } else {
            [UIUtil showSubscriptionViewFromViewController:self];
        }
    }
}

- (void)subscriptionPlanDone {
    [self presentLiveVideo];
}

@end
