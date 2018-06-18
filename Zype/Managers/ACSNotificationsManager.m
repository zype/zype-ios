//
//  ACSNotificationsManager.m
//
//  Created by ZypeTech on 8/9/15.
//  Copyright (c) 2015 Zype. All rights reserved.
//

#import "ACSNotificationsManager.h"
#import "ACSPersistenceManager.h"
#import "Notification.h"

@implementation ACSNotificationsManager


#pragma mark - Local Notifications

+ (void)setLocalNotifications{
    
    // Remove expired notification from Core Data
    [ACSNotificationsManager removeExpiredNotifications];
    
    // Cancel notifications which are removed in server
    [ACSNotificationsManager cancelRemovedNotifications];
    
    // Update notificaitons which are updated in server
    [ACSNotificationsManager updateNotifications];
    
    // Schedule new notifications
    [ACSNotificationsManager scheduleNewNotifications];
    
    // Save in core data
    [[ACSPersistenceManager sharedInstance] saveContext];
    
}


+ (void)removeExpiredNotifications{
    
    [[ACSPersistenceManager sharedInstance] removeExpiredNotifications];
    
}

+ (void)cancelRemovedNotifications{

    NSArray *candidatesToCancel = [[ACSPersistenceManager sharedInstance] cancelRemovedNotifications];
    
    // Cancel notifications
    for (UILocalNotification *localNotification in candidatesToCancel) {
        
        [[UIApplication sharedApplication] cancelLocalNotification:localNotification];
        
    }
 
}

+ (void)updateNotifications{
    
    NSArray *updatedNotifications = [[ACSPersistenceManager sharedInstance] updatedNotifications];
    NSArray *scheduledLocalNotifications = [[UIApplication sharedApplication] scheduledLocalNotifications];

    NSArray *localNotificationResults;
    
    for (Notification *updatedNotification in updatedNotifications) {

        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"fireDate == %@", updatedNotification.scheduled];
        localNotificationResults = [scheduledLocalNotifications filteredArrayUsingPredicate:predicate];
        
    }
    
    // Cancel notifications
    for (UILocalNotification *localNotification in localNotificationResults) {
        
        [[UIApplication sharedApplication] cancelLocalNotification:localNotification];
        
    }

    // Reschedule the canceled notifications with updated time
    for (Notification *notification in updatedNotifications) {
        
        UILocalNotification *localNotification = [ACSNotificationsManager localNotificationFromNotification:notification];
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
        
        [[ACSPersistenceManager sharedInstance] setScheduledNotification:notification];
        
    }
    
}

+ (void)scheduleNewNotifications{
    
    NSInteger amount = [ACSNotificationsManager localNotificationSlotsAvailable];

    NSArray *notifications = [[ACSPersistenceManager sharedInstance] newNotifications];
    for (Notification *notification in notifications) {
        
        UILocalNotification *localNotification = [ACSNotificationsManager localNotificationFromNotification:notification];
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
        
        [[ACSPersistenceManager sharedInstance] setScheduledNotification:notification];
        
        if (amount <= 0) {
            break;
        }
        
    }
    
}

+ (UILocalNotification *)localNotificationFromNotification:(Notification *)notification{
    
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    localNotification.fireDate = notification.time;
    localNotification.alertBody = notification.full_description;
    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    
    return localNotification;
    
}

+ (NSInteger)localNotificationSlotsAvailable{
    
    // Get the amount of notifications can be scheduled
    NSArray *scheduledNotifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
    NSInteger amount = 64 - (int)scheduledNotifications.count;
    
    return amount;
    
}


@end
