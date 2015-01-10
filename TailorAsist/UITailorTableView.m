//
//  UITailorTableView.m
//  TailorAsist
//
//  Created by user1 on 14-7-28.
//  Copyright (c) 2014年 user1. All rights reserved.
//

#import "UITailorTableView.h"
#import "ActiveCurve.h"

@interface UITailorTableView () {
    ActiveCurve* _currCurve;
    ActiveCurve* _nextCurve;
    bool _nextCurveReady;
}
- (void)switchCurrNextCurve;
@end

@implementation UITailorTableView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _currCurve = [[ActiveCurve alloc] init];
        _nextCurve = [[ActiveCurve alloc] init];
        _nextCurveReady = false;
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    CGContextRef c = UIGraphicsGetCurrentContext();
    
    // Outline the canvas
    CGFloat red[4] = {1.0f, 0.0f, 0.0f, 1.0f};
    CGContextSetStrokeColor(c, red);
    CGContextSetLineWidth(c, 4.0);
    CGContextBeginPath(c);
    CGPoint pts[5] = {
        {rect.origin.x, rect.origin.y},
        {rect.origin.x + rect.size.width, rect.origin.y},
        {rect.origin.x + rect.size.width, rect.origin.y + rect.size.height},
        {rect.origin.x, rect.origin.y + rect.size.height},
        {rect.origin.x, rect.origin.y}};
    CGContextAddLines(c, pts, 5);
    CGContextStrokePath(c);
    
    // Check if need switch
    if (_nextCurveReady) {
        [self switchCurrNextCurve];
    }
    
    [_currCurve drawCurve:c];
}

- (void)addPoint:(CGPoint *)pt
{
    if (_nextCurveReady) {
        [_nextCurve.pts addPointer:pt];
    } else {
        [_currCurve.pts addPointer:pt];
    }
}

- (void)setStartAngle:(double)angl
{
    if (_nextCurveReady) {
        _nextCurve.startAngle = angl;
    } else {
        _currCurve.startAngle = angl;
    }
}

- (void)setLineType:(enum CurveType)type
{
    ActiveCurve* curr = nil;
    if (_nextCurveReady) {
        curr = _nextCurve;
    } else {
        curr = _currCurve;
    }
    if (type == BSPLINE) {
        [curr calcDistArr];
    }
    curr.lineType = type;
}

- (void)setNextCurveReady
{
    _nextCurveReady = true;
}

- (void)switchCurrNextCurve
{
    ActiveCurve* tmp = _currCurve;
    _currCurve = _nextCurve;
    _nextCurve = tmp;
    _nextCurveReady = false;
    [_nextCurve emptyPoints];
    
}
@end
