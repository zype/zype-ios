//
//  Pager.h
//  Zype
//
//  Created by Александр on 03.02.2018.
//  Copyright © 2018 Zype. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "PresentableObject.h"

@interface Pager : PresentableObject

@property (nonatomic, retain) id zObject_ids;

- (NSArray *)zObjectsFromPager;

@end
