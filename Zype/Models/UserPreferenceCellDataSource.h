//
//  UserPreferenceCellDataSource.h
//
//  Created by Andy Zheng on 5/21/18.
//

#import <Foundation/Foundation.h>
#import "TableSectionDataSource.h"

typedef NS_ENUM(NSUInteger, PreferenceCategory) {
    VideoPlayback = 0,
    preferenceCategoriesCount = 1
};

typedef NS_ENUM(NSUInteger, Preference) {
    Autoplay = 0,
    preferencesCount = 1
};

@interface UserPreferenceCellDataSource : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) UIView *accessoryView;
@property (nonatomic, assign) enum TableSectionDataSourceType type;
@property (nonatomic, assign) PreferenceCategory preferenceCategoryType;
@property (nonatomic, assign) Preference preferenceType;

@end
