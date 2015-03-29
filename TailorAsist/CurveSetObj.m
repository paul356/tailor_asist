//
//  CurveSetObj.m
//  TailorAssistor
//
//  Created by user1 on 15/3/10.
//  Copyright (c) 2015年 user1. All rights reserved.
//

#import "CurveSetObj.h"

@implementation CurveSetObj {
    NSMutableArray* _curveArr;
    ActiveCurve* _currCurve;
    CGPoint _trans;
    BOOL _active;
}

- (instancetype)init
{
    _curveArr  = [[NSMutableArray alloc] init];
    _currCurve = [[ActiveCurve alloc] init];
    _trans.x = _trans.y = 0;
    return self;
}

- (void)drawCurveSet:(CGContextRef)ctx color:(CGColorRef)co activeColor:(CGColorRef)aco
{
    for (ActiveCurve* curve in _curveArr) {
        [curve drawCurve:ctx color:co];
    }
    if (_active) {
        ActiveCurve *curve = nil;
        if (_trans.x || _trans.y) {
            curve = [[ActiveCurve alloc] init];
            [curve copyCurve:_currCurve];
            curve.start = CGPointMake(curve.start.x + _trans.x, curve.start.y + _trans.y);
            curve.top   = CGPointMake(curve.top.x + _trans.x, curve.top.y + _trans.y);
            curve.end   = CGPointMake(curve.end.x + _trans.x, curve.end.y + _trans.y);
        } else {
            curve = _currCurve;
        }
        [curve drawCurve:ctx color:aco];
        NSLog(@"Draw translation %f %f\n", _trans.x, _trans.y);
    }
}

- (void)addCurve:(ActiveCurve*)newCurve
{
    [_curveArr addObject:newCurve];
}

- (ActiveCurve *)hitTestAndRemove:(CGPoint)pt
{
    ActiveCurve* hitCurve = nil;
    for (ActiveCurve* curve in _curveArr) {
        if ([curve hitControlPoint:pt]) {
            hitCurve = curve;
            break;
        }
    }
    [_curveArr removeObject:hitCurve];
    return hitCurve;
}

- (BOOL)hitTest:(CGPoint)pt
{
    if (_active) {
        ActiveCurve* tmpCurve = [[ActiveCurve alloc] init];
        [_currCurve translate:_trans];
        [tmpCurve copyCurve:_currCurve];
        [self addCurve:tmpCurve];
        _active = FALSE;
    }
    
    ActiveCurve* hitCurve = [self hitTestAndRemove:pt];
    if (hitCurve) {
        [_currCurve copyCurve:hitCurve];
        _trans.x = _trans.y = 0;
        _active = TRUE;
    }
    
    return hitCurve != nil;
}

- (void)setActiveCurveStartPoint:(CGPoint)pt
{
    _currCurve.start = _currCurve.end = pt;
    if (_currCurve.lineType == CIRCLE) {
        _currCurve.top = _currCurve.start;
    }
    _active = TRUE;
}

- (void)updateActiveCurveEndPoint:(CGPoint)pt
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
}

- (void)setActiveCurveEndPoint:(CGPoint)pt
{
    ActiveCurve* newCurve = [[ActiveCurve alloc] init];
    [newCurve copyCurve:_currCurve];
    [self addCurve:newCurve];
    // Becuase _currCurve value is saved to _curveSet
    // no need to set _modified to TRUE
    NSLog(@"Add curve start=(%f %f), top=(%f, %f), end=(%f, %f)\n", newCurve.start.x, newCurve.start.y, newCurve.top.x, newCurve.top.y, newCurve.end.x, newCurve.end.y);
    _active = FALSE;
}

- (void)updateActiveCurveTranslation:(CGPoint)pt
{
    _trans = pt;
}

- (void)endActiveCurveTranslation
{
    [_currCurve translate:_trans];
    _trans.x = _trans.y = 0;
}

- (void)deselect
{
    if (_active) {
        ActiveCurve* newCurve = [[ActiveCurve alloc] init];
        [newCurve copyCurve:_currCurve];
        [self addCurve:newCurve];
        _active = FALSE;
    }
}

- (void)discardSelectedCurve
{
    _active = FALSE;
}

- (void)setActiveLineType:(enum CurveType)type
{
    _currCurve.lineType = type;
}

@end
