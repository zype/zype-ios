//
//  TabBarViewController.m
//  
//
//  Created by Andrey Kasatkin on 3/14/17.
//
//

#import "TabBarViewController.h"

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
   
    
    // Do any additional setup after loading the view.
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


@end
