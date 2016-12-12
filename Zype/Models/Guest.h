//
//  Guest.h
//  Zype
//
//  Created by ZypeTech on 2/2/15.
//  Copyright (c) 2015 Zype. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Guest : NSManagedObject

@property (nonatomic, retain) NSString * gId;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * full_description;
@property (nonatomic, retain) NSString * short_description;
@property (nonatomic, retain) NSString * friendly_title;
@property (nonatomic, retain) NSString * facebook;
@property (nonatomic, retain) NSString * youtube;
@property (nonatomic, retain) NSString * twitter;
@property (nonatomic, retain) NSDate * created_at;
@property (nonatomic, retain) NSDate * updated_at;
@property (nonatomic, retain) NSString * short_bio;
@property (nonatomic, retain) NSString * thumbnailUrl;
@property (nonatomic, retain) NSString * thumbnailLocalPath;
@property (nonatomic, retain) NSNumber * active;

@end
