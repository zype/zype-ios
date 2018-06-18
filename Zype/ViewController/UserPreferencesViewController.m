//
//  UserPreferencesViewController.m
//  Zype
//
//  Created by Andy Zheng on 5/21/18.
//  Copyright © 2018 Zype. All rights reserved.
//

#import "UserPreferencesViewController.h"
#import "ACSPersistenceManager.h"
#import "TableSectionDataSource.h"
#import "UserPreferenceCellDataSource.h"

#pragma mark - Interface

@interface UserPreferencesViewController ()
@property (retain, nonatomic) IBOutlet UITableView *userPreferencesTableView;
@property (strong, nonatomic) NSMutableArray *preferencesTableData;

@end

#pragma mark - Implementation

@implementation UserPreferencesViewController

#pragma mark - Override methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.userPreferencesTableView.dataSource = self;
    self.userPreferencesTableView.delegate = self;
    
    [self configureView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self fetchUserPreferences];
    [self setupPreferencesTable];
    
    [self.userPreferencesTableView reloadData];
}

#pragma mark - Setup

- (void)configureView {
    
    if (kAppColorLight) {
        self.userPreferencesTableView.backgroundColor = [UIColor whiteColor];
    } else {
        self.userPreferencesTableView.backgroundColor = [UIColor blackColor];
    }
    
    [self.userPreferencesTableView setTableFooterView:[[UIView alloc] init]];
}

- (void)fetchUserPreferences {
    self.userPreferences = (UserPreferences *)[ACSPersistenceManager getUserPreferences];
}

- (void)setupPreferencesTable {
    self.preferencesTableData = [[NSMutableArray alloc] init];
    
    int prefCatCount = (int)preferenceCategoriesCount;
    
    for (int i = 0; i < prefCatCount; i++) {
        switch ((PreferenceCategory) i) {
            case VideoPlayback: {
                UserPreferenceCellDataSource *videoPlaybackCell = [[UserPreferenceCellDataSource alloc] init];
                videoPlaybackCell.title = @"Video Playback";
                videoPlaybackCell.type = Header;
                videoPlaybackCell.preferenceCategoryType = VideoPlayback;
                [self.preferencesTableData addObject:videoPlaybackCell];
                
                // logic for buttons to push into thing
                if (kAutoplay && (self.userPreferences.autoplay != nil)) {
                    UserPreferenceCellDataSource *autoplayCell = [[UserPreferenceCellDataSource alloc] init];
                    autoplayCell.title = @"Autoplay";
                    autoplayCell.type = Switch;
                    autoplayCell.preferenceType = Autoplay;
                    [self.preferencesTableData addObject:autoplayCell];
                }
                
                break;
            }
                
            default: {
                break;
            }
        }
    }
    
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.preferencesTableData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UserPreferenceCellDataSource *currentCellData = self.preferencesTableData[indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PreferenceCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"PreferenceCell"];
    }
    
    if (kAppColorLight) {
        cell.textLabel.textColor = [UIColor blackColor];
    } else {
        cell.textLabel.textColor = [UIColor whiteColor];
    }
    
    UIView * selectedBackgroundView = [[UIView alloc] init];
    [selectedBackgroundView setBackgroundColor:[UIColor darkGrayColor]];
    [cell setSelectedBackgroundView:selectedBackgroundView];
    
    switch ((TableSectionDataSourceType) currentCellData.type) {
        case Header: {
            cell.textLabel.text = [self preferenceCategoryStringFromEnum:currentCellData.preferenceCategoryType];
            cell.textLabel.font = [UIFont boldSystemFontOfSize:15.0];
            break;
        }
            
        //case Switch: {
        //    UISwitch *prefSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
        //    CGRect frame = prefSwitch.frame;
        //    frame.origin.x = [UIScreen mainScreen].bounds.size.width - 50;
        //    frame.origin.y = 15;
        //    prefSwitch.frame = frame;
        //    prefSwitch.tag = indexPath.row;
        //
        //    cell.textLabel.text = [self preferenceStringFromEnum:currentCellData.preferenceType];
        //    break;
        //}
            
            
        default: { // Switch
            BOOL prefVal = [self getPreferenceValue:currentCellData.preferenceType];
            UISwitch *prefSwitch = [self getUISwitch:prefVal withTag:indexPath.row];
            
            cell.textLabel.text = [self preferenceStringFromEnum:currentCellData.preferenceType];
            [cell.contentView addSubview:prefSwitch];
            
            break;
        }
    }
    
    return cell;
}


- (void)switchClicked:(UISwitch *)sender {
    // sender.tag == index of data in self.preferencesTableData
    if (sender.tag != nil) {
        UserPreferenceCellDataSource *prefCellData = self.preferencesTableData[sender.tag];
        [self updateUserPreference:prefCellData.preferenceType withValue:[sender isOn]];
        
    } else {
        
        // Prevent switch
        if ([sender isOn]) {
            [sender setOn:YES animated:NO];
        } else {
            [sender setOn:NO animated:NO];
        }
        
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *selectedCell = [self.userPreferencesTableView cellForRowAtIndexPath:indexPath];
    
    UserPreferenceCellDataSource *prefCellData = self.preferencesTableData[indexPath.row];
    if (prefCellData.type == Switch) {
        // remove switch
        [[selectedCell.contentView viewWithTag:(NSInteger *)indexPath.row] removeFromSuperview];
        
        BOOL *newPrefValue;
        if ([self getPreferenceValue:prefCellData.preferenceType]) {
            newPrefValue = NO;
        } else {
            newPrefValue = YES;
        }
    
        // save
        [self updateUserPreference:prefCellData.preferenceType withValue:newPrefValue];
    
        // update UI
        UISwitch *newSwitch = [self getUISwitch:newPrefValue withTag:indexPath.row];
        [selectedCell.contentView addSubview:newSwitch];
    }
    
    [self.userPreferencesTableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    // remove switches before view disappears
    for (UIView *subview in cell.contentView.subviews) {
        [subview removeFromSuperview];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55.0f;
}
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [cell setBackgroundColor:[UIColor clearColor]];
}

#pragma mark - User Preference Helpers

- (BOOL)getPreferenceValue:(enum Preference)preference {
    switch (preference) {
        case Autoplay: {
            return [self.userPreferences.autoplay boolValue];
            break;
        }
        default: {
            return nil;
            break;
        }
    }
}

- (void)updateUserPreference:(enum Preference)preference withValue:(BOOL)value {
    switch (preference) {
        case Autoplay: {
            self.userPreferences.autoplay = [NSNumber numberWithBool:value];
            break;
        }
            
        default: {
            break;
        }
    }
    
    [[ACSPersistenceManager sharedInstance] saveContext];
}

#pragma mark - UI Helpers

- (UISwitch *)getUISwitch:(BOOL)initialValue withTag:(int)tag {
    UISwitch *prefSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
    CGRect frame = prefSwitch.frame;
    frame.origin.x = [UIScreen mainScreen].bounds.size.width - 75;
    frame.origin.y = 15;
    prefSwitch.frame = frame;
    prefSwitch.tag = tag;
    [prefSwitch addTarget:self action:@selector(switchClicked:) forControlEvents:UIControlEventValueChanged];
    [prefSwitch setOn:initialValue animated:NO];
    
    return prefSwitch;
}


#pragma mark - Enum Helpers

- (NSString *)preferenceCategoryStringFromEnum:(enum PreferenceCategory)preferenceCat {
    switch (preferenceCat) {
        case VideoPlayback: {
            return @"Video Playback";
            break;
        }
        
        default: {
            return @"";
            break;
        }
    }
}

- (NSString *)preferenceStringFromEnum:(enum Preference)preference {
    switch (preference) {
        case Autoplay: {
            return @"Autoplay";
            break;
        }
            
        default: {
            return @"";
            break;
        }
    }
}

@end
