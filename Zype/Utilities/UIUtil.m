//
//  UIUtil.m
//  Zype
//
//  Created by ZypeTech on 1/27/15.
//  Copyright (c) 2015 Zype. All rights reserved.
//

#import <Crashlytics/Crashlytics.h>
#import <AdSupport/ASIdentifierManager.h>
#import <sys/utsname.h>
#import "UIUtil.h"
#import "ACSPersistenceManager.h"
#import "ViewManager.h"
#import "Guest.h"
#import "VideoDetailViewController.h"
#import "SignInViewController.h"
#import "Video.h"
#import "HomeViewController.h"
#import "VideosViewController.h"
#import "IntroViewController.h"
#import "WatcherIntroViewController.h"
#import "WatcherSignInViewController.h"
#import "SubsciptionViewController.h"
#import "RegisterViewController.h"
#import "SettingsViewController.h"
#import "PrivacyViewController.h"
#import "TabBarViewController.h"
#import "MoreViewController.h"
#import "AppDelegate.h"

@implementation UIUtil

#pragma mark - UI

+ (UIColor *)colorWithHex:(int)rgbValue
{
    return [UIUtil colorWithHex: rgbValue alpha:1.0];
}
+ (UIColor *)colorWithHex:(int)rgbValue alpha:(float)a
{
    return [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:a];
}

// Usage: [UIUtil hexStringWithUicolor:color] returns @"xxxxxx"
+ (NSString *)hexStringWithUicolor:(UIColor*)color
{
    const CGFloat *components = CGColorGetComponents(color.CGColor);
    CGFloat r = components[0];
    CGFloat g = components[1];
    CGFloat b = components[2];
    NSString *hexString=[NSString stringWithFormat:@"%02X%02X%02X", (int)(r * 255), (int)(g * 255), (int)(b * 255)];
    return hexString;
}

+ (void)addActions:(NSArray *)actions IntoContainerView:(UIView *)containerView Width:(float)width Height:(float)height
{
    float y = 0;
    float iconSize = 20;
    float iconMargin = (height - iconSize) / 2;
    float lableMargin = iconSize + (iconMargin * 2);
    
    for (Action *action in actions) {
        UIView *view = action.view;
        UIImageView *image = action.imageView;
        UILabel *label = action.label;
        NSString *title = action.title;
        
        [view setFrame:CGRectMake(0, y, width, height)];
        
        // Add separator
        UIView *separator = [[UIView alloc] init];
        if ([actions indexOfObject:action] == [actions count] - 1) {
            [separator setFrame:CGRectMake(0, y, width, 1)];
            [separator setBackgroundColor:[UIColor blackColor]];
        }
        else {
            [separator setFrame:CGRectMake(0, y + height, width, 1)];
            [separator setBackgroundColor:[UIColor lightGrayColor]];
        }
        
        // Add icon
        [image setFrame:CGRectMake(iconMargin, iconMargin, iconSize, iconSize)];
        [view addSubview:image];
        
        // Add title
        [label setFrame:CGRectMake(lableMargin, 0, width - lableMargin, height)];
        [label setText:title];
        [label setFont:[UIFont fontWithName:kFontRegular size:16]];
        [view addSubview:label];
        
        [containerView addSubview:view];
        [containerView addSubview:separator];
        
        y += height;
    }
}

+ (UIButton *)buttonNowPlayingInViewController:(UIViewController *)viewController
{
    UIButton *button = nil;
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kSettingKey_VideoIdNowPlaying]) {
        button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setBackgroundImage:[UIImage imageNamed:@"IconNowPlaying"] forState:UIControlStateNormal];
        [button sizeToFit];
        UIBarButtonItem *barItem = [[UIBarButtonItem alloc] initWithCustomView:button];
        UIBarButtonItem *negativeSeparator = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        negativeSeparator.width = -8;
        viewController.navigationItem.rightBarButtonItems = @[negativeSeparator, barItem];
    }
    else {
        viewController.navigationItem.rightBarButtonItem = nil;
    }
    
    return button;
}

+ (void)showNowPlayingFromViewController:(UIViewController *)viewController{
    
    // Get video now playing
    Video *videoNowPlaying = [ACSPersistenceManager nowPlayingVideo];
    
    if (videoNowPlaying != nil) {
        
        [self loadVideo:videoNowPlaying fromViewController:viewController];
        
    }

}

+ (void)loadVideo:(Video *)video fromViewController:(UIViewController *)viewController{
    
    VideoDetailViewController *videoDetailViewController = (VideoDetailViewController *)[ViewManager videoDetailViewController];
    
    // Load video now playing
    [videoDetailViewController setDetailItem:video];
    [viewController.navigationController pushViewController:videoDetailViewController animated:YES];
    
}

+ (void)loadVideosFromPlaylist:(NSString *)playlistId fromViewController:(UIViewController *)viewController{
    
    VideosViewController *videosViewController = (VideosViewController *)[ViewManager videosViewController];
    videosViewController.playlistId = playlistId;
    dispatch_async(dispatch_get_main_queue(), ^{
        [viewController.navigationController pushViewController:videosViewController animated:YES];
    });
    
}

+ (void)loadPlaylist:(Playlist *)playlist fromViewController:(UIViewController *)viewController{
    
    HomeViewController *homeViewController = (HomeViewController *)[ViewManager homeViewController];
    
    //set selected playlist
    [homeViewController setPlaylistItem:playlist];
    dispatch_async(dispatch_get_main_queue(), ^{
        [viewController.navigationController pushViewController:homeViewController animated:YES];
    });
    
}

+ (void)showSignInViewFromViewController:(UIViewController *)viewController
{
    SignInViewController *signInViewController = (SignInViewController *)[viewController.storyboard instantiateViewControllerWithIdentifier:@"signInViewController"];
    if ([viewController isKindOfClass:[BaseViewController class]]) {
        signInViewController.planDelegate = ((BaseViewController*)viewController).planDelegate;
    } else if ([viewController isKindOfClass:[TabBarViewController class]]) {
        signInViewController.planDelegate = (TabBarViewController*)viewController;
    } else if ([viewController isKindOfClass:[MoreViewController class]]) {
        signInViewController.planDelegate = (MoreViewController*)viewController;
    }
    [viewController presentViewController:signInViewController animated:YES completion:nil];
}

+ (void)showSignUpViewFromViewController:(UIViewController *)viewController
{
    RegisterViewController *regViewController = (RegisterViewController *)[viewController.storyboard instantiateViewControllerWithIdentifier:@"RegisterViewController"];
    if ([viewController isKindOfClass:[SignInViewController class]]) {
        regViewController.planDelegate = ((SignInViewController*)viewController).planDelegate;
    }
    [viewController presentViewController:regViewController animated:YES completion:nil];
}

+ (void)showIntroViewFromViewController:(UIViewController *)viewController
{
    IntroViewController *introViewController = (IntroViewController *)[viewController.storyboard instantiateViewControllerWithIdentifier:@"IntroViewController"];
    if ([viewController isKindOfClass:[BaseViewController class]]) {
        introViewController.planDelegate = ((BaseViewController*)viewController).planDelegate;
    } else if ([viewController isKindOfClass:[SettingsViewController class]]) {
        introViewController.planDelegate = (SettingsViewController*)viewController;
    } else if ([viewController isKindOfClass:[HomeViewController class]]) {
        introViewController.planDelegate = (HomeViewController*)viewController;
    } else if ([viewController isKindOfClass:[TabBarViewController class]]) {
        introViewController.planDelegate = (TabBarViewController*)viewController;
    }
    [viewController presentViewController:introViewController animated:YES completion:nil];
}

+ (void)showWatcherIntroViewFromViewController:(UIViewController *)viewController
{
    WatcherIntroViewController *watcherIntroViewController = (WatcherIntroViewController *)[viewController.storyboard instantiateViewControllerWithIdentifier:@"WatcherIntroViewController"];
    if ([viewController isKindOfClass:[BaseViewController class]]) {
        watcherIntroViewController.planDelegate = ((BaseViewController*)viewController).planDelegate;
    } else if ([viewController isKindOfClass:[HomeViewController class]]) {
        watcherIntroViewController.planDelegate = (HomeViewController*)viewController;
    } else if ([viewController isKindOfClass:[TabBarViewController class]]) {
        watcherIntroViewController.planDelegate = (TabBarViewController*)viewController;
    }
    [viewController presentViewController:watcherIntroViewController animated:YES completion:nil];
}

+ (void)showWatcherSignInViewFromViewController:(UIViewController *)viewController
{
    WatcherSignInViewController *signInViewController = (WatcherSignInViewController *)[viewController.storyboard instantiateViewControllerWithIdentifier:@"WatcherSignInViewController"];
    if ([viewController isKindOfClass:[BaseViewController class]]) {
        signInViewController.planDelegate = ((BaseViewController*)viewController).planDelegate;
    }
    [viewController presentViewController:signInViewController animated:YES completion:nil];
}

+ (void)showSubscriptionViewFromViewController:(UIViewController *)viewController
{
    SubsciptionViewController *subscriptionViewController = (SubsciptionViewController *)[viewController.storyboard instantiateViewControllerWithIdentifier:@"SubscriptionViewController"];
    if ([viewController isKindOfClass:[VideosViewController class]]) {
        subscriptionViewController.planDelegate = (VideosViewController*)viewController;
    } else if ([viewController isKindOfClass:[TabBarViewController class]]) {
        subscriptionViewController.planDelegate = (TabBarViewController*)viewController;
    }
    [viewController presentViewController:subscriptionViewController animated:YES completion:nil];
}

+ (void)showTermOfServicesFromViewController:(UIViewController *)viewController
{
    PrivacyViewController *privacyViewController = (PrivacyViewController *)[viewController.storyboard instantiateViewControllerWithIdentifier:@"PrivacyViewController"];
    [viewController presentViewController:privacyViewController animated:YES completion:nil];
}

+ (NSString *)subtitleOfVideo:(Video *)video
{
    NSString *result = @"";
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"EEEE, MMM. d"];
    NSString *stringPublished = [formatter stringFromDate:video.published_at];
    NSString *stringEpisode = [NSString stringWithFormat:@"Episode %@", video.episode];
    
    if (kShowPublishedAtDate) {
        if ([video.episode isEqualToNumber:[NSNumber numberWithInt:0]] || [self isYes:video.isHighlight]){
            if (stringPublished.length > 0)
                result = [NSString stringWithFormat:@"%@", stringPublished];
        }
        else {
            if (stringPublished.length > 0)
                result = [NSString stringWithFormat:@"%@ | %@", stringPublished, stringEpisode];
            else
                result = [NSString stringWithFormat:@"%@", stringEpisode];
        }
    } else {
        result = [NSString stringWithFormat:@"%@", stringEpisode];
    }
    
    return result;
}

#pragma mark - Date and time

+ (NSDate *)startOfWeek:(NSDate *)date
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *comps = [calendar components:NSCalendarUnitYearForWeekOfYear |
                               NSCalendarUnitYear |
                               NSCalendarUnitMonth |
                               NSCalendarUnitWeekOfYear |
                               NSCalendarUnitWeekday fromDate:date];
    NSDate *startOfWeek;
    [comps setWeekday:1]; // 1: Sunday
    startOfWeek = [calendar dateFromComponents:comps];
    
    return startOfWeek;
}
+ (NSDate *)endOfWeek:(NSDate *)date
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *comps = [calendar components:NSCalendarUnitYearForWeekOfYear |
                               NSCalendarUnitYear |
                               NSCalendarUnitMonth |
                               NSCalendarUnitWeekOfYear |
                               NSCalendarUnitWeekday fromDate:date];
    NSDate *endOfWeek;
    [comps setWeekday:7]; // 7: Saturday
    endOfWeek = [calendar dateFromComponents:comps];
    
    return endOfWeek;
}

+ (NSString *)stringDurationFromDate:(NSDate *)fromDate ToDate:(NSDate *)toDate
{
    NSString *from = @"";
    NSString *to = @"";
    
    NSCalendar* calendar = [NSCalendar currentCalendar];
    unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay;
    NSDateComponents* compStart = [calendar components:unitFlags fromDate:fromDate];
    NSDateComponents* compEnd = [calendar components:unitFlags fromDate:toDate];
    
    //Feb 2, 2013 - Dec 17, 2014
    //MMM d, yyyy - MMM d, yyyy
    if ([compStart year] != [compEnd year]) {
        NSDateFormatter *format = [[NSDateFormatter alloc] init];
        [format setDateFormat:@"MMM d, yyyy"];
        from = [format stringFromDate:fromDate];
        to = [format stringFromDate:toDate];
    }
    //Nov 8 - Dec 17, 2014
    //MMM d - MMM d, yyyy
    else if ([compStart month] != [compEnd month]) {
        NSDateFormatter *formatStart = [[NSDateFormatter alloc] init];
        NSDateFormatter *formatEnd = [[NSDateFormatter alloc] init];
        [formatStart setDateFormat:@"MMM d"];
        [formatEnd setDateFormat:@"MMM d, yyyy"];
        from = [formatStart stringFromDate:fromDate];
        to = [formatEnd stringFromDate:toDate];
    }
    //December 13 - 17, 2014
    //MMMM d - d, yyyy
    else {
        NSDateFormatter *formatStart = [[NSDateFormatter alloc] init];
        NSDateFormatter *formatEnd = [[NSDateFormatter alloc] init];
        [formatStart setDateFormat:@"MMMM d"];
        [formatEnd setDateFormat:@"d, yyyy"];
        from = [formatStart stringFromDate:fromDate];
        to = [formatEnd stringFromDate:toDate];
    }
    
    return [NSString stringWithFormat:@"%@ - %@", from, to];
}

+ (NSString *)stringDateFilterFromDate:(NSDate *)fromDate ToDate:(NSDate *)toDate
{
    //&published_at.gte=2015-01-10&published_at.lte=2015-01-21
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyy-MM-dd"];
    NSString *stringFrom = [format stringFromDate:fromDate];
    NSString *stringTo = [format stringFromDate:toDate];
    
    return [NSString stringWithFormat:@"&published_at.gte=%@&published_at.lte=%@", stringFrom, stringTo];
}

+ (NSDateFormatter *)dateFormatter
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZZZ"];
    
    return formatter;
}

+ (NSString *)timelineWithMilliseconds:(NSNumber *)milliseconds
{
    int seconds = milliseconds.floatValue / 1000;
    int minutes = seconds / 60;
    seconds %= 60;
    int hours = minutes / 60;
    minutes %= 60;
    
    return [NSString stringWithFormat:@"%02d:%02d:%02d", hours, minutes, seconds];
}
+ (double)secondsWithMilliseconds:(NSNumber *)milliseconds
{
    if (milliseconds)
        return (milliseconds.doubleValue / 1000);
    else
        return 0;
}

#pragma mark - Generation

+ (NSString *)tagsWithKeywords:(NSArray *)keywords
{
    NSString *tags = @"";
    
    for (NSString *item in keywords) {
        tags = [tags stringByAppendingString:[NSString stringWithFormat:@"<label>%@</label>", item]];
    }
    
    return tags;
}

+ (NSString *)thumbnailUrlFromArray:(NSArray *)array
{
    NSString *url = @"";
    float width = 0;
    
    for (NSDictionary *dict in array) {
        if (width > 0) {
            if (width > [[dict valueForKey:kAppKey_Width] floatValue]) {
                width = [[dict valueForKey:kAppKey_Width] floatValue];
                url = [dict valueForKey:kAppKey_Url];
            }
        } else {
            if (width < [[dict valueForKey:kAppKey_Width] floatValue]) {
                width = [[dict valueForKey:kAppKey_Width] floatValue];
                url = [dict valueForKey:kAppKey_Url];
            }
        }
    }
  
    return url;
}

+ (NSString *)thumbnailBigUrlFromArray:(NSArray *)array
{
    NSString *url = @"";
    float width = 0;
    
    for (NSDictionary *dict in array) {
        if (width < [[dict valueForKey:kAppKey_Width] floatValue]) {
            width = [[dict valueForKey:kAppKey_Width] floatValue];
            url = [dict valueForKey:kAppKey_Url];
        }
    }
    
    return url;
}

/*
 * Look for an image that is called mobile and load it instead of default template
 */
+ (NSString *)thumbnailUrlFromImageArray:(NSArray *)array
{
    NSString *url = @"";
    
    for (NSDictionary *dict in array) {
        // only select "mobile" image if device is not iPad
        if ([[dict valueForKey:kAppKey_Title] isEqualToString:@"mobile"] && UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
            url = [dict valueForKey:kAppKey_Url];
        }
    }
    
    return url;
}

+ (NSString *)thumbnailUrlFromImageArray:(NSArray *)array withLayout:(NSString *)layout
{
    NSString *url = @"";
    
    for (NSDictionary *dict in array) {
        // only select "mobile" image if device is not iPad
        if ([[dict valueForKey:kAppKey_Layout] isEqualToString:layout] && [[dict valueForKey:kAppKey_Title] isEqualToString:@"mobile"] && UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
            url = [dict valueForKey:kAppKey_Url];
        }

    }
    
    return url;
}

+ (NSString *)stringDownloadProgressWithBytes:(double)totalBytesWritten WithTotalBytes:(double)totalBytesExpectedToWrite
{
    NSString *result = @"";
    
    double progress = (double)totalBytesWritten / (double)totalBytesExpectedToWrite;
    if (totalBytesExpectedToWrite > 1024 * 1024) {
        result = [NSString stringWithFormat:@"%.1fMB / %.1fMB %.1f%% downloaded",
                  totalBytesWritten / (1024 * 1024), totalBytesExpectedToWrite / (1024 * 1024), progress * 100];
    }
    else if (totalBytesExpectedToWrite > 1024) {
        result = [NSString stringWithFormat:@"%.1fKB / %.1fKB %.1f%% downloaded",
                  totalBytesWritten / 1024, totalBytesExpectedToWrite / 1024, progress * 100];
    }
    else {
        result = [NSString stringWithFormat:@"%.1fB / %.1fB %.1f%% downloaded",
                  totalBytesWritten, totalBytesExpectedToWrite, progress * 100];
    }
    
    return result;
}

#pragma mark - Validation

+ (BOOL)validateUrl:(NSString *)url
{
    return ([url isEqualToString:@""] || (![url stringContains:@"https://"] && ![url stringContains:@"http://"]));
}

+ (id)dict:(NSDictionary *)dictionary valueForKey:(NSString *)key
{
    if ([dictionary isKindOfClass:[NSDictionary class]] && dictionary != nil && [dictionary objectForKey:key] != nil) {
        return [dictionary valueForKey:key];
    }
    
    return nil;
}

+ (BOOL)isYes:(NSNumber *)number
{
    return [number isEqualToNumber:[NSNumber numberWithBool:YES]] ? YES : NO ;
}

+ (BOOL)hasNextPage:(NSNumber *)nextPage InPages:(NSNumber *)pages WithData:(NSDictionary *)parsedObject
{
    BOOL hasNextPage = NO;
    
    if ([pages isKindOfClass:[NSNumber class]] && ![pages isEqualToNumber:[NSNumber numberWithInt:0]]) {
        if ([nextPage isKindOfClass:[NSNumber class]] && [pages doubleValue] >= [nextPage doubleValue])
            hasNextPage = YES;
    }
    
    return hasNextPage;
}

+ (BOOL)isLastPageInPages:(NSNumber *)pages WithData:(NSDictionary *)parsedObject
{
    BOOL isLastPage = NO;
    
    NSNumber *currentPage = (NSNumber *)[UIUtil dict:[UIUtil dict:parsedObject valueForKey:kAppKey_Pagination] valueForKey:kAppKey_CurrentPage];
    if ([pages isKindOfClass:[NSNumber class]] && [currentPage isKindOfClass:[NSNumber class]] && [pages doubleValue] == [currentPage doubleValue])
        isLastPage = YES;
    
    return isLastPage;
}

NSString* machineName() {
    struct utsname systemInfo;
    uname(&systemInfo);
    
    return [NSString stringWithCString:systemInfo.machine
                              encoding:NSUTF8StringEncoding];
}

NSString* systemUserAgent() {
    NSString* sysUserAgent = [[AppDelegate appDelegate] userAgent];
    if (!sysUserAgent) {
        // This is most likely not happen, stil added safer side handling to retrieve agent info again if it's nil, user agent is 100% populated during app launch, verified.
        // Becaue of the async nature of WKWebView API we can not wait as this flow is already being executed in main thread context, otherwise deadlock. Also WKWebView can not be used inside bg threads.
        [[AppDelegate appDelegate] retrieveUserAgent];
        return NULL;
    }
    return sysUserAgent;
}

NSString* userAgent() {
    NSString *machine = machineName();
    NSString *appName = [NSString stringWithFormat:@"%@", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"]];
    NSString *sysAgent = systemUserAgent();
    NSMutableString *sysUA = sysAgent ? [NSMutableString stringWithString: sysAgent] : NULL;
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    if (machine && appName && sysUA && version) {
        [sysUA replaceOccurrencesOfString:@"(iPhone;"
                               withString: [NSString stringWithFormat:@"(%@;", machine]
                                  options:NSLiteralSearch
                                    range:NSMakeRange(0, sysUA.length)];
        [sysUA appendString:[NSString stringWithFormat:@" %@/%@", appName, version]];
        return sysUA;
    }
    
    return @"zype_ios";
}

+ (NSMutableString*)replaceDeviceParameters:(NSString *)string {
    
    NSMutableString *tag = [NSMutableString stringWithString: string];
    
    NSUUID *realUuid = [[UIDevice currentDevice] identifierForVendor];
    unsigned char uuidBytes[16];
    [realUuid getUUIDBytes:uuidBytes];
    NSString *uuid = [NSString stringWithFormat: @"%@", realUuid];
    
    NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
    NSString *bundleName = [NSString stringWithFormat:@"%@", [info objectForKey:@"CFBundleDisplayName"]];
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    
    NSString *idfa = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    NSString *appId = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
    
    [tag replaceOccurrencesOfString:@"[uuid]"
                         withString: uuid
                            options:NSLiteralSearch
                              range:NSMakeRange(0, tag.length)];
    
    [tag replaceOccurrencesOfString:@"[app_name]"
                         withString: bundleName
                            options:NSLiteralSearch
                              range:NSMakeRange(0, tag.length)];
    
    [tag replaceOccurrencesOfString:@"[app_bundle]"
                         withString: bundleIdentifier
                            options:NSLiteralSearch
                              range:NSMakeRange(0, tag.length)];
    
    [tag replaceOccurrencesOfString:@"[app_domain]"
                         withString: bundleIdentifier
                            options:NSLiteralSearch
                              range:NSMakeRange(0, tag.length)];
    
    [tag replaceOccurrencesOfString:@"[device_type]"
                         withString: @"7"
                            options:NSLiteralSearch
                              range:NSMakeRange(0, tag.length)];
    
    [tag replaceOccurrencesOfString:@"[device_make]"
                         withString: @"Apple"
                            options:NSLiteralSearch
                              range:NSMakeRange(0, tag.length)];
    
    [tag replaceOccurrencesOfString:@"[device_model]"
                         withString: machineName()
                            options:NSLiteralSearch
                              range:NSMakeRange(0, tag.length)];
    
    [tag replaceOccurrencesOfString:@"[device_ifa]"
                         withString: idfa
                            options:NSLiteralSearch
                              range:NSMakeRange(0, tag.length)];
    
    [tag replaceOccurrencesOfString:@"[vpi]"
                         withString: @"mp4"
                            options:NSLiteralSearch
                              range:NSMakeRange(0, tag.length)];
    
    [tag replaceOccurrencesOfString:@"[app_id]"
                         withString: appId
                            options:NSLiteralSearch
                              range:NSMakeRange(0, tag.length)];
    
    [tag replaceOccurrencesOfString:@"[device_ua]"
                         withString: userAgent()
                            options:NSLiteralSearch
                              range:NSMakeRange(0, tag.length)];
    
    [tag replaceOccurrencesOfString:@"[ip_address]"
                         withString: @"168.0.0.1"
                            options:NSLiteralSearch
                              range:NSMakeRange(0, tag.length)];
    
    [tag replaceOccurrencesOfString:@" "
                         withString: @"-"
                            options:NSLiteralSearch
                              range:NSMakeRange(0, tag.length)];
    
    return tag;
}



@end
