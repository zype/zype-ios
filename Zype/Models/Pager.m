//
//  Pager.m
//  Zype
//
//  Created by Александр on 03.02.2018.
//  Copyright © 2018 Zype. All rights reserved.
//

#import "Pager.h"
#import "ACSPersistenceManager.h"

@implementation Pager

@dynamic zObject_ids;

- (NSArray *)zObjectsFromPager {
    return [ACSPersistenceManager getZObjects];
}


@end
