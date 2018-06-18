//
//  UserPreferences.h
//
//  Created by Andy Zheng on 5/18/18.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface UserPreferences : NSManagedObject

@property (nonatomic, retain) NSNumber *autoplay;

@end
