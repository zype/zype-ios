//
//  PlaylistVideo.h
//  Havoc
//
//  Created by ZypeTech on 11/22/16.
//  Copyright © 2016 Zype. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface PlaylistVideo : NSManagedObject

@property (nonatomic, retain) NSNumber * orderingValue;

@property (nonatomic, retain) Video *video;

@property (nonatomic, retain) Playlist *playlist;

@end







