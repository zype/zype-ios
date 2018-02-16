//
//  UIUtil.h
//  Zype
//
//  Created by ZypeTech on 1/27/15.
//  Copyright (c) 2015 Zype. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Action.h"
#import "NSString+Extensions.h"
#import "NSDictionary+Extensions.h"

@class Video, Playlist;

@interface UIUtil : NSObject

+ (UIColor *)colorWithHex:(int)rgbValue;
+ (UIColor *)colorWithHex:(int)rgbValue alpha:(float)a;
+ (void)addActions:(NSArray *)actions IntoContainerView:(UIView *)containerView Width:(float)width Height:(float)height;
+ (UIButton *)buttonNowPlayingInViewController:(UIViewController *)viewController;
+ (void)showNowPlayingFromViewController:(UIViewController *)viewController;
+ (void)showSignInViewFromViewController:(UIViewController *)viewController;
+ (void)showSignUpViewFromViewController:(UIViewController *)viewController;
+ (void)showIntroViewFromViewController:(UIViewController *)viewController;
+ (void)showSubscriptionViewFromViewController:(UIViewController *)viewController;
+ (void)showTermOfServicesFromViewController:(UIViewController *)viewController;
+ (void)loadVideosFromPlaylist:(NSString *)playlistId fromViewController:(UIViewController *)viewController;
+ (void)loadPlaylist:(Playlist *)playlist fromViewController:(UIViewController *)viewController;
+ (NSString *)subtitleOfVideo:(Video *)video;

+ (NSDate *)startOfWeek:(NSDate *)date;
+ (NSDate *)endOfWeek:(NSDate *)date;
+ (NSString *)stringDurationFromDate:(NSDate *)fromDate ToDate:(NSDate *)toDate;
+ (NSString *)stringDateFilterFromDate:(NSDate *)fromDate ToDate:(NSDate *)toDate;
+ (NSDateFormatter *)dateFormatter;
+ (NSString *)timelineWithMilliseconds:(NSNumber *)milliseconds;
+ (double)secondsWithMilliseconds:(NSNumber *)milliseconds;

+ (NSString *)tagsWithKeywords:(NSArray *)keywords;
+ (NSString *)thumbnailUrlFromArray:(NSArray *)array;
+ (NSString *)thumbnailUrlFromImageArray:(NSArray *)array;
+ (NSString *)thumbnailUrlFromImageArray:(NSArray *)array withLayout:(NSString *)layout;
+ (NSString *)stringDownloadProgressWithBytes:(double)totalBytesWritten WithTotalBytes:(double)totalBytesExpectedToWrite;

+ (BOOL)validateUrl:(NSString *)url;
+ (id)dict:(NSDictionary *)dictionary valueForKey:(NSString *)key;
+ (BOOL)isYes:(NSNumber *)number;
+ (BOOL)hasNextPage:(NSNumber *)nextPage InPages:(NSNumber *)pages WithData:(NSDictionary *)parsedObject;
+ (BOOL)isLastPageInPages:(NSNumber *)pages WithData:(NSDictionary *)parsedObject;

@end
