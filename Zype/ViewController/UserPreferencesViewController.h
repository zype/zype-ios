//
//  UserPreferencesViewController.h
//
//  Created by Andy Zheng on 5/21/18.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "UserPreferences.h"

@class UserPreferences;

@interface UserPreferencesViewController : UIViewController

@property (strong, nonatomic) UserPreferences *userPreferences;
@property (strong, nonatomic) NSMutableDictionary *preferencesDictionary;

- (void)fetchUserPreferences;

@end
