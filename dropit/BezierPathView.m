//
//  BezierPathView.m
//  dropit
//
//  Created by Armour on 4/23/15.
//  Copyright (c) 2015 ZJU. All rights reserved.
//

#import "BezierPathView.h"

@implementation BezierPathView


-(void)setPath:(UIBezierPath *)path {
    _path = path;
    [self setNeedsDisplay];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    [self.path stroke];
}


@end
