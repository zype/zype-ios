//
//  BorderedTextField.m
//
//  Created by ZypeTech on 7/7/15.
//  Copyright (c) 2015 Zype. All rights reserved.
//

#import "BorderedTextField.h"

@implementation BorderedTextField


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self) {
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self) {
        [self setup];
    }
    return self;
}

- (id)init
{
    self = [super init];
    if(self) {
        [self setup];
    }
    return self;
}

- (void)awakeFromNib{
    [super awakeFromNib];
    
    [self setup];
    
}

- (void)setup{
    
    [self setupDefaultAppearance];
    self.clipsToBounds = YES;
    
}

- (void)setupDefaultAppearance{
    
    //self.layer.borderWidth = 0.5f;
   // self.layer.cornerRadius = 4.0f;
    //self.backgroundColor = [UIColor clearColor];
    //[self setBorderColor];
    
    
}

- (void)setBorderColor{
    
  //  self.layer.borderColor = kYellowColor.CGColor;
    self.layer.borderColor = [UIColor lightGrayColor].CGColor;
}

/*
 // overriding TextRect and EditingRect to add spacing
 */
- (CGRect)textRectForBounds:(CGRect)bounds
{
    return CGRectInset(bounds,10,10);
}

- (CGRect)editingRectForBounds:(CGRect)bounds
{
    return CGRectInset(bounds,10,10);
}


@end
