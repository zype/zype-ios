//
//  ZObject.h
//  Zype
//
//  Created by Александр on 30.01.2018.
//  Copyright © 2018 Zype. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "PresentableObject.h"

@interface ZObject : NSManagedObject

@property (nonatomic, retain) NSString * zId;
@property (nonatomic, retain) NSNumber * active;
@property (nonatomic, retain) NSDate * created_at;
@property (nonatomic, retain) NSDate * updated_at;
@property (nonatomic, retain) NSString * full_description;
@property (nonatomic, retain) NSString * friendly_title;
@property (nonatomic, retain) NSString * playlistid;
@property (nonatomic, retain) NSNumber * priority;
@property (nonatomic, retain) NSString * site_id;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * zobject_type_id;
@property (nonatomic, retain) NSString * zobject_type_title;

@property (nonatomic, retain) NSString * thumbnailUrl;

@property (nonatomic, retain) id keywords;
@property (nonatomic, retain) id pictures;
@property (nonatomic, retain) id video_ids;



@end
