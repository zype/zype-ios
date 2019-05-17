//
//  EPGViewController.m
//  Zype
//
//  Created by Top developer on 5/7/19.
//  Copyright © 2019 Zype. All rights reserved.
//

#import "EPGViewController.h"
#import "ACSPersistenceManager.h"
#import "RESTServiceController.h"
#import "UIView+UIView_CustomizeTheme.h"
#import "UIViewController+AC.h"
#import "EPGCollectionViewCell.h"
#import "EPGChannelView.h"
#import "EPGDateView.h"
#import "EPGTimeView.h"
#import "GuideModel.h"
#import "UIUtil.h"
#import "SVProgressHUD.h"
#import "VideoDetailViewController.h"

@interface EPGViewController ()
{
    NSTimer *_timer;
    NSDate *_startDate;
    int _loadingCount;
    NSIndexPath* _selectedIndexPath;
    Video* _newVideo;
}
@end

@implementation EPGViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.screenName = @"Guide";
    [self configureView];
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"EPGChannelView" bundle:nil]
          forSupplementaryViewOfKind:@"EPGChannelView" withReuseIdentifier:@"EPGChannelView"];
    [self.collectionView registerClass:[UICollectionReusableView self]
            forSupplementaryViewOfKind:@"ChannelBackground" withReuseIdentifier:@"ChannelBackground"];
    [self.collectionView registerClass:[UICollectionReusableView self]
            forSupplementaryViewOfKind:@"ChannelSeparator" withReuseIdentifier:@"ChannelSeparator"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"EPGTimeView" bundle:nil]
          forSupplementaryViewOfKind:@"EPGTimeView" withReuseIdentifier:@"EPGTimeView"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"EPGDateView" bundle:nil]
          forSupplementaryViewOfKind:@"EPGDateView" withReuseIdentifier:@"EPGDateView"];
    [self.collectionView registerClass:[UICollectionReusableView self]
            forSupplementaryViewOfKind:@"TimeIndicator" withReuseIdentifier:@"TimeIndicator"];
    [self.collectionView registerClass:[UICollectionReusableView self]
            forSupplementaryViewOfKind:@"TimeSeparator" withReuseIdentifier:@"TimeSeparator"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadGuides) name:@"ReloadGuideScreen" object:nil];
    _startDate = [self getStartTime];
    [self loadGuides];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (_timer != NULL) {
        if ([_timer isValid]) {
            [_timer invalidate];
        }
        _timer = nil;
    }
    _timer = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(timeFire) userInfo:nil repeats:YES];
    [_timer fire];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showEpisodeDetail"]) {
        NSMutableArray *videos = [[NSMutableArray alloc] init];
        [videos addObject: _newVideo];
        [(VideoDetailViewController*)[segue destinationViewController] setVideos:videos withIndex: 0];
        
        GuideProgramModel *program = self.guides[_selectedIndexPath.section].programs[_selectedIndexPath.item];
        if (!program.isAiring) {
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"];
            
            ((VideoDetailViewController*)[segue destinationViewController]).startTime = [formatter stringFromDate: program.startTime];
            ((VideoDetailViewController*)[segue destinationViewController]).endTime = [formatter stringFromDate: program.endTime];
        }
    }
}

- (NSDate*) getStartTime {
    NSDate* date = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitDay value:-3 toDate:[NSDate date] options: 0];
    NSCalendar* calendar = [NSCalendar currentCalendar];
    
    return [calendar dateBySettingHour: 0 minute: 0 second: 0 ofDate: date options: 0];
}

- (void) timeFire {
    [self.collectionView reloadData];
}

- (void) loadGuides {
    _loadingCount = 0;
    _startDate = [self getStartTime];
    [self.guides removeAllObjects];
    [self.collectionView reloadData];

    NSDateFormatter* dateFormatterGet = [[NSDateFormatter alloc] init];
    [dateFormatterGet setDateFormat:@"yyyy-MM-dd"];
    NSString* fromDate = [dateFormatterGet stringFromDate: _startDate];
    NSString* toDate = [dateFormatterGet stringFromDate: [[NSCalendar currentCalendar] dateByAddingUnit: NSCalendarUnitDay value: 10 toDate: _startDate options:0]];
    
    [self.loadingIndicator startAnimating];
    [[RESTServiceController sharedInstance] getGuides:^(NSData *data, NSURLResponse *response, NSError *error) {
        self.guides = [[NSMutableArray alloc] init];
        if (error) {
            [self didRefreshData];
        } else {
            NSError *localError = nil;
            NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
            if (localError != nil) {
                [self didRefreshData];
            }
            else {
                for(NSDictionary * guideDic in parsedObject[@"response"]) {
                    [self.guides addObject: [[GuideModel alloc] initWithDictionary:guideDic]];
                }
                
                for(int index=0; index<self.guides.count; index++) {
                    [[RESTServiceController sharedInstance] getGuidePrograms:self.guides[index].gId sort:@"start_time" order:@"asc" greaterThan: fromDate lessThan: toDate completion:^(NSData *data, NSURLResponse *response, NSError *error) {
                        
                        if (error == nil) {
                            NSError *localError = nil;
                            NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
                            if (localError == nil) {
                                self.guides[index].programs = [[NSMutableArray alloc] init];
                                for(NSDictionary * programDic in parsedObject[@"response"]) {
                                    [self.guides[index].programs addObject: [[GuideProgramModel alloc] initWithDictionary:programDic]];
                                }
                            }
                        }
                        self->_loadingCount += 1;
                        if (self->_loadingCount == self.guides.count) {
                            [self didRefreshData];
                        }
                  }];
                }
            }
        }
    }];
}

- (void) didRefreshData {
    _startDate = [self getStartTime];
    [self.loadingIndicator stopAnimating];
    
    [self.guides filterUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(GuideModel* evaluatedObject, NSDictionary *bindings) {
        return evaluatedObject.programs.count > 0;
    }]];
    
    [self focusCurrentTime];
}

- (void) focusCurrentTime {
    BOOL isFindFocus = NO;
    
    if (_selectedIndexPath == nil) {
        for (int section=0; section<self.guides.count; section++) {
            if (self.guides[section].programs != nil && self.guides[section].programs.count > 0) {
                for (int item=0; item<self.guides[section].programs.count; item++) {
                    if ([self.guides[section].programs[item] containsDate: [NSDate date]]) {
                        _selectedIndexPath = [NSIndexPath indexPathForItem:item inSection:section];
                        isFindFocus = true;
                        break;
                    }
                }
            }
            if (isFindFocus) {
                break;
            }
        }
    }
    
    [self.collectionView reloadData];
    if (_selectedIndexPath != nil) {
        [self.collectionView scrollToItemAtIndexPath:_selectedIndexPath atScrollPosition:UICollectionViewScrollPositionLeft animated: true];
    }
}

#pragma mark - Init UI

- (void)configureView
{
    [self customizeAppearance];
    
    self.collectionView.backgroundColor = kAppColorLight ? kLightLineColor : [UIColor clearColor];
    self.loadingIndicator.color = kClientColor;
}

#pragma mark - User Interaction

- (IBAction)showSearchResult:(id)sender {
    [self performSegueWithIdentifier:@"showSearchResult" sender:self];
}

#pragma mark - EPGCollectionViewDelegate

- (double)collectionView:(nonnull UICollectionView *)collectionView collectionViewLayout:(nonnull UICollectionViewLayout *)layout runtimeForProgramAtIndexPath:(nonnull NSIndexPath *)indexPath {
    if (indexPath.section < self.guides.count) {
        if (indexPath.item < self.guides[indexPath.section].programs.count) {
            GuideProgramModel* program = self.guides[indexPath.section].programs[indexPath.item];
            return program.duration;
        }
    }
    return 0;
}

- (double)collectionView:(nonnull UICollectionView *)collectionView collectionViewLayout:(nonnull UICollectionViewLayout *)layout startForProgramAtIndexPath:(nonnull NSIndexPath *)indexPath {
    if (indexPath.section < self.guides.count) {
        if (indexPath.item < self.guides[indexPath.section].programs.count) {
            GuideProgramModel* program = self.guides[indexPath.section].programs[indexPath.item];
            if (program.startTime != nil) {
                return [program.startTime timeIntervalSinceDate: _startDate];
            }
        }
    }
    return 0;
}

- (double)timeIntervalForTimeIndicatorForCollectionView:(nonnull UICollectionView *)collectionView collectionViewLayout:(nonnull UICollectionViewLayout *)layout {
    return (_startDate != nil) ? [[NSDate date] timeIntervalSinceDate: _startDate] : 0;
}

#pragma mark - UICollectionViewDataSource

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *view = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:kind forIndexPath:indexPath];
    if ([kind isEqual: @"ChannelBackground"]) {
        if (indexPath.item != 0) {
            view.backgroundColor = kEPGTimeViewColor;
        } else {
            view.backgroundColor = kEPGChannelBackColor;
        }
    } else if ([kind isEqual: @"EPGChannelView"]) {
        EPGChannelView* headerView = (EPGChannelView*)view;
        
        GuideModel* guide = self.guides[indexPath.section];
        if (guide.name != nil && ![guide.name isEqual: @""]) {
            [headerView.imageView setHidden: YES];
            [headerView.lblTitle setHidden: NO];
            headerView.lblTitle.text = guide.name;
        } else {
            [headerView.imageView setHidden: NO];
            [headerView.lblTitle setHidden: YES];
            headerView.imageView.image = [UIImage imageNamed: @"LaunchImage"];
        }
    } else if ([kind isEqual: @"ChannelSeparator"]) {
        view.backgroundColor = kEPGChannelSeperatorColor;
    } else if ([kind isEqual: @"EPGDateView"]) {
        self.dateHeaderView = (EPGDateView*)view;
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MMMM, d"];
        self.dateHeaderView.lblDate.text = [dateFormatter stringFromDate:[NSDate date]];
    }
    else if ([kind isEqual: @"EPGTimeView"]) {
        EPGTimeView* timeView = (EPGTimeView*)view;
        NSDate *date = [_startDate dateByAddingTimeInterval: 1800 * indexPath.item];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.timeStyle = NSDateFormatterShortStyle;
        timeView.lbleTitle.text = [dateFormatter stringFromDate: date];
    }
    else if ([kind isEqual: @"TimeSeparator"]) {
        view.backgroundColor = [UIColor lightGrayColor];
    }
    else if ([kind isEqual: @"TimeIndicator"]) {
        view.backgroundColor = [UIColor blueColor];
    }
    return view;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    if (self.guides == nil) {
        return 0;
    }
    return self.guides.count;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (self.guides == nil || self.guides[section].programs == nil) {
        return 0;
    }
    
    return self.guides[section].programs.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    EPGCollectionViewCell *cell = (EPGCollectionViewCell*)[collectionView dequeueReusableCellWithReuseIdentifier:@"EPGCollectionViewCell" forIndexPath:indexPath];
    
    GuideProgramModel* program = self.guides[indexPath.section].programs[indexPath.item];
    cell.lblTitle.text = program.title;
    cell.airing = [program isAiring];
    
    cell.lblTitle.textColor = cell.airing ? [UIColor whiteColor] : [UIColor grayColor];
    cell.backgroundView.backgroundColor = cell.airing ? kEPGAiringColor : kEPGCellColor;
    
    if (_selectedIndexPath == indexPath) {
        cell.lblTitle.textColor = [UIColor whiteColor];
        cell.backgroundView.backgroundColor = kEPGHighlightColor;
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    if ([cell isKindOfClass: EPGCollectionViewCell.class]) {
        if (_selectedIndexPath != nil) {
            if (_selectedIndexPath == indexPath && self.guides[indexPath.section].videoId != nil) {
                if ([self.guides[indexPath.section].programs[indexPath.item].startTimeOffset compare: [NSDate date]] == NSOrderedDescending) {
                    [self showBasicAlertWithTitle:@"Error" WithMessage:@"We're sorry, that program is not available yet"];
                    return;
                }
                [SVProgressHUD show];
                [[RESTServiceController sharedInstance] loadVideoWithId:self.guides[indexPath.section].videoId withCompletionHandler:^(NSData *data, NSError *error) {
                    [SVProgressHUD dismiss];
                    if (error == nil){
                        Video *videoInDB = [ACSPersistenceManager videoWithID: self.guides[indexPath.section].videoId];
                        NSError *localError = nil;
                        NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
                        
                        if (videoInDB != nil) {
                            self->_newVideo = videoInDB;
                            [self performSegueWithIdentifier:@"showEpisodeDetail" sender:self];
                        } else {
                            if (localError == nil){
                                if ([[parsedObject objectForKey:@"response"] count] > 0) {
                                    NSDictionary *videoData = [parsedObject objectForKey:@"response"][0];
                                    
                                    Video *newVideo = [ACSPersistenceManager newVideo];
                                    [ACSPersistenceManager saveVideoInDB:newVideo WithData:videoData];
                                    self->_newVideo = newVideo;
                                    [self performSegueWithIdentifier:@"showEpisodeDetail" sender:self];
                                }
                            }
                        }
                    }
                }];
            } else {
                EPGCollectionViewCell* prevCell = (EPGCollectionViewCell*)[collectionView cellForItemAtIndexPath:_selectedIndexPath];
                prevCell.lblTitle.textColor = prevCell.airing ? [UIColor whiteColor] : [UIColor grayColor];
                prevCell.backgroundView.backgroundColor = prevCell.airing ? kEPGAiringColor : kEPGCellColor;
            }
        }
        
        EPGCollectionViewCell* epgCell = (EPGCollectionViewCell*)cell;
        epgCell.lblTitle.textColor = [UIColor whiteColor];
        epgCell.backgroundView.backgroundColor = kEPGHighlightColor;
        _selectedIndexPath = indexPath;
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MMMM, d"];
        self.dateHeaderView.lblDate.text = [dateFormatter stringFromDate:self.guides[indexPath.section].programs[indexPath.item].startTimeOffset];
    }
}

@end
