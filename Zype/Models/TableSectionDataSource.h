//
//  TableSectionDataSource.h
//  Zype
//
//  Created by Александр on 27.05.17.
//  Copyright © 2017 Zype. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, TableSectionDataSourceType) {
    Play = 1,
    Download = 2,
    Favourite = 3,
    Share = 4
};

@interface TableSectionDataSource : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) UIView *accessoryView;
@property (nonatomic, assign) TableSectionDataSourceType type;

@end
