//
//  PresentableObject.h
//  Zype
//
//  Created by Александр on 03.02.2018.
//  Copyright © 2018 Zype. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface PresentableObject : NSManagedObject

@property (nonatomic, retain) NSString * parent_id;
@property (nonatomic, retain) NSNumber * priority;
@property (nonatomic, retain) NSString * type;

@end
