//
//  Action.h
//  Zype
//
//  Created by ZypeTech on 2/19/15.
//  Copyright (c) 2015 Zype. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Action : NSObject

@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) UILabel *label;
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UIView *view;

- (id)initWithTitle:(NSString *)title
              Label:(UILabel *)label
          ImageView:(UIImageView *)imageView
               View:(UIView *)view;

@end
