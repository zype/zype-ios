//
//  SearchResultViewController.h
//  Zype
//
//  Created by ZypeTech on 2/23/15.
//  Copyright (c) 2015 Zype. All rights reserved.
//

#import "BaseViewController.h"

@interface SearchResultViewController : BaseViewController <UITextFieldDelegate>

@property (strong, nonatomic) NSString *searchString;
@property (weak, nonatomic) IBOutlet UITextField *searchBar;
@property (weak, nonatomic) IBOutlet UIButton *buttonDismissSearch;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;

@end
