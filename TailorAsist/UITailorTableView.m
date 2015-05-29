//
//  UITailorTableView.m
//  TailorAsist
//
//  Created by user1 on 14-7-28.
//  Copyright (c) 2014年 user1. All rights reserved.
//

#import "UITailorTableView.h"
#import "ActiveCurve.h"
#import "DataSetObj.h"

@interface UITailorTableView ()
@end

@implementation UITailorTableView

- (void)drawRect:(CGRect)rect
{
    //[super drawRect:rect];
    CGContextRef c = UIGraphicsGetCurrentContext();
    
    // Outline the canvas
    CGFloat black[4] = {0.0f, 0.0f, 0.0f, 1.0f};
    CGContextSetFillColor(c, black);
    CGContextBeginPath(c);
    CGPoint pts[4] = {
        {rect.origin.x, rect.origin.y},
        {rect.origin.x + rect.size.width, rect.origin.y},
        {rect.origin.x + rect.size.width, rect.origin.y + rect.size.height},
        {rect.origin.x, rect.origin.y + rect.size.height}};
    CGContextAddLines(c, pts, 4);
    CGContextClosePath(c);
    CGContextFillPath(c);
    
    CGColorRef white = [[UIColor colorWithWhite:1.0 alpha:1.0] CGColor];
    CGColorRef red   = [[UIColor colorWithRed:1.0 green:0 blue:0 alpha:1.0] CGColor];
    [_curveSet drawCurveSet:c color:white activeColor:red];
}

@end
