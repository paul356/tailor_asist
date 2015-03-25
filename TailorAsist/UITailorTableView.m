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
    ActiveCurve* _currCurve;
    CGPoint _trans;
    BOOL _modified;
    BOOL _selected;
}
@end

@implementation UITailorTableView

- (void)initViewResources:(CurveSetObj*)curveSet
{
    // Initialization code
    _currCurve = [[ActiveCurve alloc] init];
    _modified = FALSE;
    _selected = FALSE;
    _trans.x = _trans.y = 0;
    
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
    [_curveSet drawCurveSet:c color:white];
    
    assert(!(_modified && _selected));
    if (_modified) {
        [_currCurve drawCurve:c color:white];
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
}

- (void)setStartPoint:(CGPoint)pt
{
    _currCurve.start = _currCurve.end = pt;
    if (_currCurve.lineType == CIRCLE) {
        _currCurve.top = _currCurve.start;
    }
    _modified = TRUE;
}

- (void)updateEndPoint:(CGPoint)pt
{
    _currCurve.end = pt;
    if (_currCurve.lineType == CIRCLE) {
        double x = _currCurve.end.x - _currCurve.start.x;
        double y = _currCurve.end.y - _currCurve.start.y;
        double cosv = cos(60.0*PI/180);
        double sinv = sin(60.0*PI/180);
        CGPoint center;
        center.x = cosv*x - sinv*y + _currCurve.start.x;
        center.y = sinv*x + cosv*y + _currCurve.start.y;

        cosv = cos(30.0*PI/180);
        sinv = sin(30.0*PI/180);
        _currCurve.top = CGPointMake(center.x + cosv*(_currCurve.start.x - center.x) - sinv*(_currCurve.start.y - center.y), center.y + sinv*(_currCurve.start.x - center.x) + cosv*(_currCurve.start.y - center.y));
    }
    _modified = TRUE;
}

- (void)setEndPoint:(CGPoint)pt
{
    ActiveCurve* newCurve = [[ActiveCurve alloc] init];
    [newCurve copyCurve:_currCurve];
    [_curveSet addCurve:newCurve];
    // Becuase _currCurve value is saved to _curveSet
    // no need to set _modified to TRUE
    NSLog(@"Add curve start=(%f %f), top=(%f, %f), end=(%f, %f)\n", newCurve.start.x, newCurve.start.y, newCurve.top.x, newCurve.top.y, newCurve.end.x, newCurve.end.y);
}

- (void)updateTranslation:(CGPoint)pt
{
    _trans = pt;
    _selected = TRUE;
}

- (void)endTranslation
{
    [_currCurve translate:_trans];
    _trans.x = _trans.y = 0;
}

- (void)deselect
{
    if (_selected) {
        _selected = FALSE;
        ActiveCurve* newCurve = [[ActiveCurve alloc] init];
        [newCurve copyCurve:_currCurve];
        [_curveSet addCurve:newCurve];
    }
}

- (void)discardSelectedCurve
{
    if (_selected)
        _selected = FALSE;
}

- (BOOL)hitTest:(CGPoint)pt
{
    if (_selected) {
        ActiveCurve* tmpCurve = [[ActiveCurve alloc] init];
        [_currCurve translate:_trans];
        [tmpCurve copyCurve:_currCurve];
        [_curveSet addCurve:tmpCurve];
        _selected = FALSE;
    }
    
    ActiveCurve* hitCurve = [_curveSet hitTestAndRemove:pt];
    if (hitCurve) {
        [_currCurve copyCurve:hitCurve];
        _trans.x = _trans.y = 0;
        _selected = TRUE;
    }
    
    return hitCurve != nil;
}

- (void)setLineType:(enum CurveType)type
{
    _currCurve.lineType = type;
}
@end
