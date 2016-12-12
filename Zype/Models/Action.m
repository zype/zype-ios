//
//  Action.m
//  Zype
//
//  Created by ZypeTech on 2/19/15.
//  Copyright (c) 2015 Zype. All rights reserved.
//

#import "Action.h"

@implementation Action

- (id)initWithTitle:(NSString *)title
              Label:(UILabel *)label
          ImageView:(UIImageView *)imageView
               View:(UIView *)view
{
    if (self)
    {
        self.title = title;
        self.label = label;
        self.imageView = imageView;
        self.view = view;
    }
    
    return self;
}

@end
