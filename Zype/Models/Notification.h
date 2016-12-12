//
//  Notification.h
//  Zype
//
//  Created by ZypeTech on 3/12/15.
//  Copyright (c) 2015 Zype. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Notification : NSManagedObject

@property (nonatomic, retain) NSString * nId;
@property (nonatomic, retain) NSDate * created_at;
@property (nonatomic, retain) NSDate * updated_at;
@property (nonatomic, retain) NSDate * time;
@property (nonatomic, retain) NSDate * scheduled;
@property (nonatomic, retain) NSString * full_description;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * friendly_title;
@property (nonatomic, retain) NSString * status;
@property (nonatomic, retain) NSNumber * active;

@end
