//
//  TabBarViewController.h
//  
//
//  Created by Andrey Kasatkin on 3/14/17.
//
//

#import <UIKit/UIKit.h>
#import "SubscriptionPlanDelegate.h"

@interface TabBarViewController : UITabBarController<UITabBarControllerDelegate, SubscriptionPlanDelegate>

@property (weak, nonatomic) IBOutlet UITabBar *tabBar;

@property (strong, nonatomic) Video *selectedVideo;

@end
