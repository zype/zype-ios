//
//  LibraryVideo.h
//  Zype
//
//  Created by ZypeTech on 01/10/20.
//  Copyright (c) 2020 Zype. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface LibraryVideo : NSManagedObject

@property (nonatomic, retain) NSString * gId;
@property (nullable, nonatomic, copy) NSString *consumer_id;
@property (nullable, nonatomic, copy) NSString *video_id;
@property (nullable, nonatomic, copy) NSDate *created_at;
@property (nullable, nonatomic, copy) NSDate *updated_at;
@property (nullable, nonatomic, copy) NSString *title;
@property (nullable, nonatomic, copy) NSString *transaction_type;


@end
