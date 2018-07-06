//
//  SearchResultViewController.m
//  Zype
//
//  Created by ZypeTech on 2/23/15.
//  Copyright (c) 2015 Zype. All rights reserved.
//

#import <SDWebImage/UIImageView+WebCache.h>

#import "SearchResultViewController.h"
#import "SearchResultTableViewCell.h"
#import "VideoDetailViewController.h"
#import "ACDownloadManager.h"
#import "Guest.h"
#import "Timing.h"
#import "AppDelegate.h"

@interface SearchResultViewController ()

@property (nonatomic) long selectedSegment;

@end

@implementation SearchResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.episodeController.episodeControllerMode = ACSEpisodeControllerModeSearch;
        
    [self trackScreenName:@"Search Results"];
    
    [self configureView];
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
    
    // Fetch data and reload table
    [self performSearch];
    
}
- (void)showNowPlayingVideoDetail:(id)sender
{
    [UIUtil showNowPlayingFromViewController:self];
}

- (BOOL)hidesBottomBarWhenPushed
{
    return YES;
}

#pragma mark - Init UI

- (void)initSearchBar
{
    self.searchBar.tintColor = [UIColor darkGrayColor];
    self.searchBar.textColor = [UIColor darkGrayColor];
  //  self.searchBar.layer.borderColor = [UIColor colorWithRed:0.20 green:0.31 blue:0.42 alpha:1.0].CGColor;
    self.searchBar.layer.borderWidth = 0.7;
    self.searchBar.layer.masksToBounds = true;
    NSAttributedString *str = [[NSAttributedString alloc] initWithString:@"Search" attributes:@{ NSForegroundColorAttributeName : [UIColor whiteColor] }];
    self.searchBar.attributedPlaceholder = str;
    
    UIImageView *imgSearch=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 32, 28)]; // Set frame as per space required around icon
    [imgSearch setImage:[UIImage imageNamed:@"search"]];
    
    [imgSearch setContentMode:UIViewContentModeCenter];// Set content mode centre
    
    self.searchBar.leftView=imgSearch;
    self.searchBar.leftViewMode=UITextFieldViewModeAlways;
    
    UIButton *clearButton = [self.searchBar valueForKey:@"_clearButton"];
    [clearButton setImage:[UIImage imageNamed:@"clear"] forState:UIControlStateNormal];
}

- (void)setSearchString:(NSString *)searchString
{
    
    if (_searchString != searchString) {
        _searchString = searchString;
    }
    
}

- (void)configureView{
    
    //[self initSearchBar];
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:nil
                                                                            action:nil];
    self.title = @"Search Result";
    //[self.searchBar setText:self.searchString];
    [self.searchBar becomeFirstResponder];
    [self initDismissSearchButton];
    self.selectedSegment = 0;
    
    self.tableView.tableFooterView = [UIView new];
    
}

#pragma mark - UITextField Delegate Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    self.searchString = self.searchBar.text;
    
    [self dismissKeyboard];
    
    enum ACSSearchMode searchMode;
    
    switch (self.segmentedControl.selectedSegmentIndex) {
            
        case 0:
            searchMode = ACSSearchModeAll;
            break;
            
        /*case 1:
            searchMode = ACSSearchModeGuests;
            break;
            */
        case 1:
            searchMode = ACSSearchModeTags;
            break;
            
        default:
            searchMode = ACSSearchModeAll;
            break;
            
    }
    
    // Search videos using REST API
    if (![self.searchString isEqualToString:@""] && self.searchString.length > 2){
        [[RESTServiceController sharedInstance] searchVideos:self.searchString InPage:nil];
    }
    
    [self.episodeController loadSearch:self.searchString searchMode:searchMode];
    
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    return YES;
}

#pragma mark - Search

- (void)initDismissSearchButton{
    
    [self.buttonDismissSearch addTarget:self action:@selector(dismissKeyboard) forControlEvents:UIControlEventTouchUpInside];
    
}

- (void)dismissKeyboard{
    
    if (![self.searchString isEqualToString:@""])
    {
        CLS_LOG(@"Search String: %@", self.searchString);
        id tracker = [[GAI sharedInstance] defaultTracker];
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:kAnalyticsScreenNameSearchResults action:kAnalyticsActSearchString label:self.searchString value:nil] build]];
    }
    
    [self.searchBar resignFirstResponder];
    [self.buttonDismissSearch setHidden:YES];
    [self performSearch];
    
}

#pragma mark - Search Bar

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
    
    [self.buttonDismissSearch setHidden:NO];
    return YES;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar{
    
    return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    
    [self dismissKeyboard];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    
    self.searchString = self.searchBar.text;
}

- (IBAction)SegmentValueChanged:(UISegmentedControl *)sender {
    
    self.selectedSegment = sender.selectedSegmentIndex;
    [self performSearch];
    
}


#pragma mark - Data Loading

- (void)performSearch{
    
    enum ACSSearchMode searchMode;
    
    switch (self.segmentedControl.selectedSegmentIndex) {
            
        case 0:
            searchMode = ACSSearchModeAll;
            break;
            
      /*  case 1:
            searchMode = ACSSearchModeGuests;
            break;
            */
        case 1:
            searchMode = ACSSearchModeTags;
            break;
            
        default:
            searchMode = ACSSearchModeAll;
            break;
            
    }
    
    // Search videos using REST API
    if (![self.searchString isEqualToString:@""] && self.searchString.length > 2){
        [[RESTServiceController sharedInstance] searchVideos:self.searchString InPage:nil];
    }
    
    if (self.searchString != nil) {
        [self.episodeController loadSearch:self.searchString searchMode:searchMode];
    }
    
}


#pragma mark - Subclass Overrides


- (void)setNoResultsMessage{
    
    if (self.doneLoadingFromNetwork == YES) {
        
        self.noResultsLabel.text = NSLocalizedString(@"No Results. Try another search.", @"no results message");
        
    }else{
        
        self.noResultsLabel.text = NSLocalizedString(@"Please enter search terms in order to begin a new search.", @"search status");
        
    }
    
}


@end
