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
    if (kUniversalTVOD) {
        [self addMyLibraryViewController];
    }
}

- (void)addDownloadsViewController {
    NSMutableArray *tabViewControllers = [[NSMutableArray alloc] initWithArray:self.viewControllers];
    UIViewController *downloadsViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"NavigationDownloadsViewController"];
    //insert downloads at position before last one
    [tabViewControllers insertObject:downloadsViewController atIndex:[self.viewControllers count] - 1];
    //[tabViewControllers addObject:downloadsViewController];
    [self setViewControllers:tabViewControllers];
}

- (void)addMyLibraryViewController {
    NSMutableArray *tabViewControllers = [[NSMutableArray alloc] initWithArray:self.viewControllers];
    UIViewController *myLibraryViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"NavigationMyLibraryViewController"];
    //insert my library in the middle
    [tabViewControllers insertObject:myLibraryViewController atIndex:[self.viewControllers count] - 2];
    [self setViewControllers:tabViewControllers];
}


@end
