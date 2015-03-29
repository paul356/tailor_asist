//
//  UITailorTableView.m
//  TailorAsist
//
//  Created by user1 on 14-7-28.
//  Copyright (c) 2014年 user1. All rights reserved.
//

#import "UITailorTableView.h"
#import "ActiveCurve.h"
#import "CurveSetObj.h"

@interface UITailorTableView () {
    CurveSetObj* _curveSet;
}
@end

@implementation UITailorTableView

- (void)initViewResources:(CurveSetObj*)curveSet
{
    _curveSet = curveSet;
}

- (void)setCurveSet:(CurveSetObj *)curveSet
{
    _curveSet = curveSet;
}

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
/*
    assert(!(_modified && _selected));
    if (_modified) {
        [_curveSet drawActiveCurve:c color:white];
        _modified = FALSE;
    }
    if (_selected) {
        ActiveCurve *curve = [[ActiveCurve alloc] init];
        [curve copyCurve:_currCurve];
        curve.start = CGPointMake(curve.start.x + _trans.x, curve.start.y + _trans.y);
        curve.top   = CGPointMake(curve.top.x + _trans.x, curve.top.y + _trans.y);
        curve.end   = CGPointMake(curve.end.x + _trans.x, curve.end.y + _trans.y);
        [curve drawCurve:c color:[[UIColor colorWithWhite:0.5 alpha:0.5] CGColor]];
        NSLog(@"Draw translation %f %f\n", _trans.x, _trans.y);
    }
 */
}

@end
