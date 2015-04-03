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
    enum ControlPointType _activePoint;
    BOOL _active;
}

- (instancetype)init
{
    _curveArr  = [[NSMutableArray alloc] init];
    _currCurve = [[ActiveCurve alloc] init];
    _trans.x = _trans.y = 0;
    _activePoint = NONE;
    return self;
}

- (void)drawCurveSet:(CGContextRef)ctx color:(CGColorRef)co activeColor:(CGColorRef)aco
{
    for (ActiveCurve* curve in _curveArr) {
        [curve drawCurve:ctx color:co];
    }
    if (_active) {
        ActiveCurve *curve = nil;
        ActiveCurve *next  = nil;
        ActiveCurve *prev  = nil;
        if (_trans.x || _trans.y) {
            curve = [[ActiveCurve alloc] init];
            [curve copyCurve:_currCurve];
            curve.nextCurve = curve.prevCurve = nil;
            if (_activePoint == START ||
                _activePoint == END) {
                [curve movePoint:_trans pointType:_activePoint recursive:FALSE];
                next = _currCurve.nextCurve;
                prev = _currCurve.prevCurve;
            } else {
                [curve translate:_trans];
            }
        } else {
            curve = _currCurve;
        }
        [_currCurve drawCurve:ctx color:co];
        [curve drawCurve:ctx color:aco];
        
        if (next && _activePoint == END) {
            [curve copyCurve:next];
            curve.nextCurve = curve.prevCurve = nil;
            if (next.prevCurve == _currCurve) {
                [curve movePoint:_trans pointType:START recursive:FALSE];
            } else {
                [curve movePoint:_trans pointType:END recursive:FALSE];
            }
            [curve drawCurve:ctx color:aco];
        }
        
        if (prev && _activePoint == START) {
            [curve copyCurve:prev];
            curve.nextCurve = curve.prevCurve = nil;
            if (prev.prevCurve == _currCurve) {
                [curve movePoint:_trans pointType:START recursive:FALSE];
            } else {
                [curve movePoint:_trans pointType:END recursive:FALSE];
            }
            [curve drawCurve:ctx color:aco];
        }
    }
}

- (void)addCurve:(ActiveCurve*)newCurve
{
    [_curveArr addObject:newCurve];
}

- (ActiveCurve*)connectToAnotherCurve:(CGPoint)pt endPointType:(enum ControlPointType*)ptType
{
    ActiveCurve* hitCurve = nil;
    enum ControlPointType endPtType = NONE;
    for (ActiveCurve* curve in _curveArr) {
        if ((endPtType = [curve hitControlPoint:pt endPointOnly:TRUE]) != NONE) {
            if ((endPtType == START && !curve.prevCurve) ||
                (endPtType == END   && !curve.nextCurve)) {
                hitCurve = curve;
                *ptType  = endPtType;
                break;
            }
        }
    }
    return hitCurve;
}

- (ActiveCurve*)findHitCurve:(CGPoint)pt endPointType:(enum ControlPointType*)ptType
{
    ActiveCurve* hitCurve = nil;
    enum ControlPointType endPtType = NONE;
    for (ActiveCurve* curve in _curveArr) {
        if ((endPtType = [curve hitControlPoint:pt endPointOnly:FALSE]) != NONE) {
            hitCurve = curve;
            *ptType  = endPtType;
            break;
        }
    }
    NSLog(@"findHitCurve endPoint:%d\n", endPtType);
    return hitCurve;
}

- (BOOL)hitTest:(CGPoint)pt
{
    if (_active) {
        [_currCurve translate:_trans];
        [self addCurve:_currCurve];
        ActiveCurve* tmpCurve = [[ActiveCurve alloc] init];
        _currCurve = tmpCurve;
        _active = FALSE;
    }
    
    enum ControlPointType ptType = NONE;
    ActiveCurve* hitCurve = [self findHitCurve:pt endPointType:&ptType];
    if (hitCurve) {
        [_curveArr removeObject:hitCurve];
        _currCurve = hitCurve;
        _trans.x = _trans.y = 0;
        _activePoint = ptType;
        _active = TRUE;
    }
    
    return hitCurve != nil;
}

- (void)setActiveCurveStartPoint:(CGPoint)pt
{
    enum ControlPointType ptType;
    ActiveCurve* nearbyCurve = [self connectToAnotherCurve:pt endPointType:&ptType];
    if (nearbyCurve) {
        assert(ptType != TOP && ptType != NONE);
        if (ptType == START) {
            pt = nearbyCurve.start;
            nearbyCurve.prevCurve = _currCurve;
        } else if (ptType == END) {
            pt = nearbyCurve.end;
            nearbyCurve.nextCurve = _currCurve;
        }
        _currCurve.prevCurve = nearbyCurve;
    }
    
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
    NSLog(@"Add curve start=(%f %f), top=(%f, %f), end=(%f, %f)\n", _currCurve.start.x, _currCurve.start.y, _currCurve.top.x, _currCurve.top.y, _currCurve.end.x, _currCurve.end.y);
    enum ControlPointType ptType;
    ActiveCurve* nearbyCurve = [self connectToAnotherCurve:pt endPointType:&ptType];
    if (nearbyCurve) {
        assert(ptType != TOP && ptType != NONE);
        if (ptType == START) {
            pt = nearbyCurve.start;
            nearbyCurve.prevCurve = _currCurve;
        } else if (ptType == END) {
            pt = nearbyCurve.end;
            nearbyCurve.nextCurve = _currCurve;
        }
        _currCurve.nextCurve = nearbyCurve;
    }
    [self updateActiveCurveEndPoint:pt];
    
    [self addCurve:_currCurve];
    ActiveCurve* newCurve = [[ActiveCurve alloc] init];
    _currCurve = newCurve;
    // Becuase _currCurve value is saved to _curveSet
    // no need to set _modified to TRUE
    _active = FALSE;
}

- (void)updateActiveCurveTranslation:(CGPoint)pt
{
    _trans = pt;
}

- (void)endActiveCurveTranslation
{
    if (_activePoint == START ||
        _activePoint == END) {
        CGPoint newPt;
        BOOL lonePoint;
        if (_activePoint == START) {
            newPt = CGPointMake(_currCurve.start.x + _trans.x, _currCurve.start.y + _trans.y);
            lonePoint = _currCurve.prevCurve == nil;
        } else {
            newPt = CGPointMake(_currCurve.end.x + _trans.x, _currCurve.end.y + _trans.y);
            lonePoint = _currCurve.nextCurve == nil;
            assert(_activePoint == END);
        }
        
        ActiveCurve* nearbyCurve = nil;
        if (lonePoint) {
            enum ControlPointType ptType = NONE;
            nearbyCurve = [self connectToAnotherCurve:newPt endPointType:&ptType];
            if (nearbyCurve) {
                assert(ptType != NONE && ptType != TOP);
                if (ptType == START) {
                    newPt = nearbyCurve.start;
                    nearbyCurve.prevCurve = _currCurve;
                } else if (ptType == END) {
                    newPt = nearbyCurve.end;
                    nearbyCurve.nextCurve = _currCurve;
                }
                
                if (_activePoint == START) {
                    _trans = CGPointMake(newPt.x - _currCurve.start.x, newPt.y - _currCurve.start.y);
                } else {
                    _trans = CGPointMake(newPt.x - _currCurve.end.x, newPt.y - _currCurve.end.y);
                }
            }
        }
        
        [_currCurve movePoint:_trans pointType:_activePoint recursive:TRUE];
        
        if (nearbyCurve) {
            if (_activePoint == START) {
                _currCurve.prevCurve = nearbyCurve;
            } else {
                assert(_activePoint == END);
                _currCurve.nextCurve = nearbyCurve;
            }
        }
    } else {
        [_currCurve translate:_trans];
    }
    _trans.x = _trans.y = 0;
    _activePoint = NONE;
}

- (void)deselect
{
    if (_active) {
        ActiveCurve* newCurve = [[ActiveCurve alloc] init];
        [self addCurve:_currCurve];
        _currCurve = newCurve;
        _active = FALSE;
    }
}

- (void)discardSelectedCurve
{
    if (_currCurve.prevCurve) {
        if (_currCurve.prevCurve.nextCurve == _currCurve) {
            _currCurve.prevCurve.nextCurve = nil;
        } else {
            _currCurve.prevCurve.prevCurve = nil;
        }
        _currCurve.prevCurve = nil;
    }
    if (_currCurve.nextCurve) {
        if (_currCurve.nextCurve.nextCurve == _currCurve) {
            _currCurve.nextCurve.nextCurve = nil;
        } else {
            _currCurve.nextCurve.prevCurve = nil;
        }
        _currCurve.nextCurve = nil;
    }
    _active = FALSE;
}

- (void)setActiveLineType:(enum CurveType)type
{
    _currCurve.lineType = type;
}

@end
