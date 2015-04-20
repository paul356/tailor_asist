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
        CGPoint savedTrans = _trans;
        if (savedTrans.x || savedTrans.y) {
            curve = [[ActiveCurve alloc] init];
            [curve copyCurve:_currCurve];
            curve.nextCurve = curve.prevCurve = nil;
            if (_activePoint == START ||
                _activePoint == END) {
                [curve movePoint:&savedTrans pointType:_activePoint recursive:FALSE];
                next = _currCurve.nextCurve;
                prev = _currCurve.prevCurve;
            } else {
                // TODO: need to handle two neighbour curves
                [curve translate:savedTrans];
            }
        } else {
            curve = _currCurve;
        }

        BOOL currCurveChanged = NO;
        if (savedTrans.x != _trans.x || savedTrans.y != _trans.y) {
            currCurveChanged = YES;
        }
        
        ActiveCurve* nearbyCurve = nil;
        CGPoint savedTrans1 = savedTrans;
        if (next && _activePoint == END) {
            nearbyCurve = [[ActiveCurve alloc] init];
            [nearbyCurve copyCurve:next];
            nearbyCurve.nextCurve = nearbyCurve.prevCurve = nil;
            if (next.prevCurve == _currCurve) {
                [nearbyCurve movePoint:&savedTrans1 pointType:START recursive:FALSE];
            } else {
                [nearbyCurve movePoint:&savedTrans1 pointType:END recursive:FALSE];
            }
        }
        if (prev && _activePoint == START) {
            nearbyCurve = [[ActiveCurve alloc] init];
            [nearbyCurve copyCurve:prev];
            nearbyCurve.nextCurve = nearbyCurve.prevCurve = nil;
            if (prev.prevCurve == _currCurve) {
                [nearbyCurve movePoint:&savedTrans1 pointType:START recursive:FALSE];
            } else {
                [nearbyCurve movePoint:&savedTrans1 pointType:END recursive:FALSE];
            }
        }
        
        BOOL nearbyCurveChanged = NO;
        if (savedTrans1.x != savedTrans.x || savedTrans1.y != savedTrans.y) {
            nearbyCurveChanged = YES;
        }
        
        if (nearbyCurveChanged && currCurveChanged) {
            [curve copyCurve:_currCurve];
            [nearbyCurve copyCurve:_activePoint == START ? prev : next];
        } else if (nearbyCurveChanged && !currCurveChanged) {
            [curve copyCurve:_currCurve];
            [curve movePoint:&savedTrans1 pointType:_activePoint recursive:FALSE];
        }
        [_currCurve drawCurve:ctx color:co];
        [curve drawCurve:ctx color:aco];
        [nearbyCurve drawCurve:ctx color:aco];
    }
}

- (void)addCurve:(ActiveCurve*)newCurve
{
    [_curveArr addObject:newCurve];
}

- (ActiveCurve*)connectToAnotherCurve:(CGPoint)pt endPointType:(enum ControlPointType*)ptType fixedLenCurve:(BOOL)fixedLen
{
    ActiveCurve* hitCurve = nil;
    enum ControlPointType endPtType = NONE;
    for (ActiveCurve* curve in _curveArr) {
        if ((endPtType = [curve hitControlPoint:pt endPointOnly:TRUE]) != NONE) {
            if ((endPtType == START && !curve.prevCurve && (!fixedLen || !curve.fixedDist)) ||
                (endPtType == END   && !curve.nextCurve && (!fixedLen || !curve.fixedDist))) {
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
        
        // TODO: simulate fixed length curve
        CGPoint st = _currCurve.start;
        CGPoint ed = _currCurve.end;
        _currCurve.fixedDist = calcDist(&st, &ed);
        
        _trans.x = _trans.y = 0;
        _activePoint = ptType;
        _active = TRUE;
    }
    
    return hitCurve != nil;
}

- (void)setActiveCurveStartPoint:(CGPoint)pt
{
    enum ControlPointType ptType;
    ActiveCurve* nearbyCurve = [self connectToAnotherCurve:pt endPointType:&ptType fixedLenCurve:NO];
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
    CGPoint st = _currCurve.start;
    if (calcDist(&pt, &st) < MIN_CURVE_LENGTH) {
        if (_currCurve.prevCurve) {
            if (_currCurve.prevCurve.nextCurve == _currCurve) {
                _currCurve.prevCurve.nextCurve = nil;
            } else {
                _currCurve.prevCurve.prevCurve = nil;
            }
        }
        _currCurve.prevCurve = nil;
        _active = FALSE;
        return;
    }
    
    NSLog(@"Add curve start=(%f %f), top=(%f, %f), end=(%f, %f)\n", _currCurve.start.x, _currCurve.start.y, _currCurve.top.x, _currCurve.top.y, _currCurve.end.x, _currCurve.end.y);
    enum ControlPointType ptType;
    ActiveCurve* nearbyCurve = [self connectToAnotherCurve:pt endPointType:&ptType fixedLenCurve:NO];
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
        CGPoint savedTrans = _trans;
        CGPoint newPt;
        BOOL lonePoint;
        
        lonePoint = _activePoint == START ? (_currCurve.prevCurve == nil) : (_currCurve.nextCurve == nil);
        
        // if current curve is fixed
        if (_currCurve.fixedDist || !lonePoint) {
            [_currCurve movePoint:&savedTrans pointType:_activePoint recursive:YES];
        }
        
        if (!lonePoint) {
            _trans.x = _trans.y = 0;
            _activePoint = NONE;
            return;
        }
        
        if (_activePoint == START) {
            newPt = _currCurve.fixedDist ? _currCurve.start : CGPointMake(_currCurve.start.x + savedTrans.x, _currCurve.start.y + savedTrans.y);
        } else {
            newPt = _currCurve.fixedDist ? _currCurve.end : CGPointMake(_currCurve.end.x + savedTrans.x, _currCurve.end.y + savedTrans.y);
            assert(_activePoint == END);
        }
        
        ActiveCurve* nearbyCurve = nil;
        // If it is lone, we allow it to stick to an existing AcitveCurve
        enum ControlPointType ptType = NONE;
        nearbyCurve = [self connectToAnotherCurve:newPt endPointType:&ptType fixedLenCurve:_currCurve.fixedDist];
        if (nearbyCurve) {
            assert(ptType != NONE && ptType != TOP);
            if (_currCurve.fixedDist) {
                CGPoint ptDiff;
                if (ptType == START) {
                    ptDiff = CGPointMake(newPt.x - nearbyCurve.start.x, newPt.y - nearbyCurve.start.y);
                } else {
                    ptDiff = CGPointMake(newPt.x - nearbyCurve.end.x, newPt.y - nearbyCurve.end.y);
                }
                [nearbyCurve movePoint:&ptDiff pointType:ptType recursive:NO];
            } else {
                if (ptType == START) {
                    newPt = nearbyCurve.start;
                } else if (ptType == END) {
                    newPt = nearbyCurve.end;
                }
                
                if (_activePoint == START) {
                    savedTrans = CGPointMake(newPt.x - _currCurve.start.x, newPt.y - _currCurve.start.y);
                } else {
                    savedTrans = CGPointMake(newPt.x - _currCurve.end.x, newPt.y - _currCurve.end.y);
                }
                
                [_currCurve movePoint:&savedTrans pointType:_activePoint recursive:NO];
            }
            if (ptType == START) {
                nearbyCurve.prevCurve = _currCurve;
            } else {
                nearbyCurve.nextCurve = _currCurve;
            }
            
            if (_activePoint == START) {
                _currCurve.prevCurve = nearbyCurve;
            } else {
                _currCurve.nextCurve = nearbyCurve;
            }
        }
    } else {
        [_currCurve translate:_trans];
    }
    
    // reset translation to 0 for next move action
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
