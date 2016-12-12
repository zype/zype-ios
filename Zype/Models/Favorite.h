//
//  Favorite.h
//  Zype
//
//  Created by ZypeTech on 2/13/15.
//  Copyright (c) 2015 Zype. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Favorite : NSManagedObject

@property (nonatomic, retain) NSString * fId;
@property (nonatomic, retain) NSString * video_id;
@property (nonatomic, retain) NSDate * updated_at;
@property (nonatomic, retain) NSDate * created_at;
@property (nonatomic, retain) NSNumber * isRemoved;

@end
