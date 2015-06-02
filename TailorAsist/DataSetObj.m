//
//  CurveSetObj.m
//  TailorAssistor
//
//  Created by user1 on 15/3/10.
//  Copyright (c) 2015年 Paul.Pan. All rights reserved.
//

#import "DataSetObj.h"

enum ActiveType {
    EMPTY,
    CURVE,
    POLYGON
};

@interface DataSetObj ()
- (void)drawActivePolygon:(CGContextRef)ctx color:(CGColorRef)co activeColor:(CGColorRef)aco;
- (void)drawActiveCurve:(CGContextRef)ctx color:(CGColorRef)co activeColor:(CGColorRef)aco;
- (void)endActiveCurveTranslation;
@end

@implementation DataSetObj {
    NSMutableArray* _curveArr;
    NSMutableArray* _polygonArr;
    ActiveCurve* _currCurve;
    ActivePolygon* _currPolygon;
    CGPoint _trans;
    enum ControlPointType _activePoint;
    enum ActiveType _activeType;
}

- (instancetype)init
{
    _curveArr  = [[NSMutableArray alloc] init];
    _polygonArr = [[NSMutableArray alloc] init];
    _currCurve = nil;
    _currPolygon = nil;
    _trans.x = _trans.y = 0;
    _activePoint = NONE;
    return self;
}

- (ActiveCurve*)getCurrActiveCurve
{
    if (_activeType == CURVE) {
        return _currCurve;
    }
    if (_activeType == POLYGON) {
        return _currCurve;
    }
    return nil;
}

- (void)drawActiveCurve:(CGContextRef)ctx color:(CGColorRef)co activeColor:(CGColorRef)aco
{
    ActiveCurve *curve = nil;
    ActiveCurve *next  = nil;
    ActiveCurve *nextToDraw = nil;
    ActiveCurve *prev  = nil;
    ActiveCurve *prevToDraw = nil;
    CGPoint savedTrans = _trans;
    if (savedTrans.x || savedTrans.y) {
        if (_activePoint == START) {
            prev = _currCurve.prevCurve;
            if (prev && prev.fixedDist && _currCurve.fixedDist) {
                savedTrans.x = savedTrans.y = 0;
            }
        } else if (_activePoint == END) {
            next = _currCurve.nextCurve;
            if (next && next.fixedDist && _currCurve.fixedDist) {
                savedTrans.x = savedTrans.y = 0;
            }
        } else {
            prev = _currCurve.prevCurve;
            next = _currCurve.nextCurve;
            if (next && next.fixedDist && prev && prev.fixedDist) {
                savedTrans.x = savedTrans.y = 0;
            }
        }
        if (savedTrans.x || savedTrans.y) {
            if (_activePoint == START ||
                _activePoint == END) {
                if (prev && prev.fixedDist) {
                    prevToDraw = [prev copy];
                    if (prevToDraw.prevCurve == _currCurve) {
                        [prevToDraw movePoint:&savedTrans pointType:START recursive:NO];
                    } else {
                        [prevToDraw movePoint:&savedTrans pointType:END recursive:NO];
                    }
                } else if (_currCurve.fixedDist) {
                    curve = [_currCurve copy];
                    [curve movePoint:&savedTrans pointType:_activePoint recursive:NO];
                } else if (next && next.fixedDist) {
                    nextToDraw = [next copy];
                    if (nextToDraw.prevCurve == _currCurve) {
                        [nextToDraw movePoint:&savedTrans pointType:START recursive:NO];
                    } else {
                        [nextToDraw movePoint:&savedTrans pointType:END recursive:NO];
                    }
                }
            } else {
                if (prev && prev.fixedDist) {
                    prevToDraw = [prev copy];
                    if (prevToDraw.prevCurve == _currCurve) {
                        [prevToDraw movePoint:&savedTrans pointType:START recursive:NO];
                    } else {
                        [prevToDraw movePoint:&savedTrans pointType:END recursive:NO];
                    }
                } else if (next && next.fixedDist) {
                    nextToDraw = [next copy];
                    if (nextToDraw.prevCurve == _currCurve) {
                        [nextToDraw movePoint:&savedTrans pointType:START recursive:NO];
                    } else {
                        [nextToDraw movePoint:&savedTrans pointType:END recursive:NO];
                    }
                }
            }
            
            if (!curve) {
                if (_activePoint == CENTER) {
                    curve = [_currCurve copy];
                    [curve translate:savedTrans];
                } else {
                    curve = [_currCurve copy];
                    [curve movePoint:&savedTrans pointType:_activePoint recursive:NO];
                }
            }
        } else {
            curve = _currCurve;
        }
        
        if (next && !nextToDraw) {
            nextToDraw = [next copy];
            if (next.prevCurve == _currCurve) {
                [nextToDraw movePoint:&savedTrans pointType:START recursive:FALSE];
            } else {
                [nextToDraw movePoint:&savedTrans pointType:END recursive:FALSE];
            }
        }
        if (prev && !prevToDraw) {
            prevToDraw = [prev copy];
            if (prev.prevCurve == _currCurve) {
                [prevToDraw movePoint:&savedTrans pointType:START recursive:FALSE];
            } else {
                [prevToDraw movePoint:&savedTrans pointType:END recursive:FALSE];
            }
        }
    } else {
        curve = _currCurve;
    }
    
    [_currCurve drawCurve:ctx color:co];
    [curve drawCurve:ctx color:aco];
    [prevToDraw drawCurve:ctx color:aco];
    [nextToDraw drawCurve:ctx color:aco];
}

- (void)drawActivePolygon:(CGContextRef)ctx color:(CGColorRef)co activeColor:(CGColorRef)aco
{
    if (_trans.x || _trans.y) {
        if (_currCurve) {
            [self drawActiveCurve:ctx color:co activeColor:aco];
        } else {
            ActivePolygon* tmpPoly = [_currPolygon copy];
            [tmpPoly translate:_trans];
            [tmpPoly drawCurve:ctx color:aco];
        }
    } else {
        [_currPolygon drawCurve:ctx color:aco];
    }
}

- (void)drawCurveSet:(CGContextRef)ctx color:(CGColorRef)co activeColor:(CGColorRef)aco
{
    for (ActiveCurve* curve in _curveArr) {
        [curve drawCurve:ctx color:co];
    }
    for (ActivePolygon* poly in _polygonArr) {
        [poly drawCurve:ctx color:co];
    }

    assert(_activeType != EMPTY || !_currPolygon);
    assert(_activeType != POLYGON || _currPolygon);
    assert(_activeType == POLYGON || !_currPolygon);
    if (_activeType == CURVE)
        [self drawActiveCurve:ctx color:co activeColor:aco];
    else if (_activeType == POLYGON)
        [self drawActivePolygon:ctx color:co activeColor:aco];
}

- (void)addCurve:(ActiveCurve*)newCurve
{
    NSLog(@"Add curve start=(%f %f), top=(%f, %f), end=(%f, %f)\n", newCurve.start.x, newCurve.start.y, newCurve.top.x, newCurve.top.y, newCurve.end.x, newCurve.end.y);
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
    
    if (_activeType == CURVE) {
        endPtType = [_currCurve hitControlPoint:pt endPointOnly:FALSE];
        if (endPtType != NONE) {
            *ptType = endPtType;
            return _currCurve;
        }
    }
    
    for (ActiveCurve* curve in _curveArr) {
        // TODO: Refactor the hit test code
        if ((endPtType = [curve hitTest:pt]) != NONE) {
            hitCurve = curve;
            *ptType  = CENTER;
            break;
        }
    }
    return hitCurve;
}

- (ActivePolygon*)findHitPolygon:(CGPoint)pt
{
    for (ActivePolygon* poly in _polygonArr) {
        if ([poly pointInsideThisPolygon:pt]) {
            return poly;
        }
    }
    return nil;
}

- (BOOL)hitTest:(CGPoint)pt
{
    enum ControlPointType ptType = NONE;
    if (_currPolygon && _currPolygon.curveView) {
        ActiveCurve* hitCurve = [_currPolygon hitInnerCurve:pt endPointType:&ptType];
        if (hitCurve) {
            _currCurve = hitCurve;
            _activePoint = ptType;
            return YES;
        }
    }
    
    ActiveCurve* hitCurve = [self findHitCurve:pt endPointType:&ptType];
    if (hitCurve != _currCurve && _activeType == CURVE) {
        assert(!_trans.x && !_trans.y);
        [self addCurve:_currCurve];
        _trans.x = _trans.y = 0;
        if (!hitCurve) {
            _currCurve = nil;
            _activePoint = NONE;
            _activeType = EMPTY;
        } else {
            [_curveArr removeObject:hitCurve];
            _currCurve = hitCurve;
            _currPolygon = nil;
            _activePoint = ptType;
            _activeType = CURVE;
            return YES;
        }
    } else if (hitCurve == _currCurve && hitCurve) {
        assert(_activeType == CURVE);
        _trans.x = _trans.y = 0;
        _activePoint = ptType;
        return YES;
    } else if (hitCurve) {
        [_curveArr removeObject:hitCurve];
        _currCurve = hitCurve;
        _currPolygon = nil;
        _trans.x = _trans.y = 0;
        _activePoint = ptType;
        _activeType = CURVE;
        return YES;
    }
    
    ActivePolygon* hitPolygon = [self findHitPolygon:pt];
    if (hitPolygon) {
        if (_currPolygon == hitPolygon) {
            _currPolygon.curveView = !_currPolygon.curveView;
            if (!_currPolygon.curveView) {
                _currCurve = nil;
                _activePoint = NONE;
            }
        } else {
            _currPolygon = hitPolygon;
            _currPolygon.curveView = NO;
            _trans.x = _trans.y = 0;
            _currCurve = nil;
            _activePoint = NONE;
            _activeType = POLYGON;
        }
        return YES;
    } else {
        if (_currPolygon) {
            _currPolygon.curveView = NO;
            _currPolygon = nil;
            _currCurve = nil;
            _activePoint = NONE;
            _activeType  = EMPTY;
        }
    }
    
    return NO;
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
    _activeType = CURVE;
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
        _activeType = EMPTY;
        return;
    }
    
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
    if (_currCurve.nextCurve && _currCurve.prevCurve && [ActivePolygon isThisCurveInPolygon:_currCurve]) {
        // If this curve forms a polygon
        [self addPolygon:_currCurve];
    }
    
    _currCurve = nil;
    _activeType = EMPTY;
}

- (void)updateShapeTranslation:(CGPoint)pt
{
    _trans = pt;
}

- (void)endShapeTranslation
{
    if (!_trans.x && !_trans.y) {
        return;
    }
    
    if (_activeType == CURVE || (_activeType == POLYGON && _currCurve)) {
        [self endActiveCurveTranslation];
    } else {
        [_currPolygon translate:_trans];
    }
    _trans.x = _trans.y = 0;
}

- (void)endActiveCurveTranslation
{
    BOOL connectToNeighbor = NO;
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
            goto out;
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
            
            connectToNeighbor = YES;
        } else {
            [_currCurve movePoint:&savedTrans pointType:_activePoint recursive:NO];
        }
    } else if (_activePoint == CENTER) {
        CGPoint savedTrans = _trans;
        ActiveCurve* prev = _currCurve.prevCurve;
        ActiveCurve* next = _currCurve.nextCurve;
        BOOL prevOrNextFixed = NO;
        if (prev && prev.fixedDist &&
            next && next.fixedDist) {
            savedTrans.x = savedTrans.y = 0;
            goto out;
        } else if ((prev && prev.fixedDist) ||
                   (next && next.fixedDist) ||
                   (next && prev)) {
            [_currCurve movePoint:&savedTrans pointType:_activePoint recursive:YES];
            prevOrNextFixed = (prev && prev.fixedDist) || (next && next.fixedDist);
        }
        
        if (next && prev) {
            goto out;
        }
        
        ActiveCurve *startNearby = nil;
        enum ControlPointType startPtType = NONE;
        ActiveCurve *endNearby   = nil;
        enum ControlPointType endPtType = NONE;
        CGPoint startGuess = CGPointMake(savedTrans.x + _currCurve.start.x, savedTrans.y + _currCurve.start.y);
        if (!prev) {
            startNearby = [self connectToAnotherCurve:startGuess
                                         endPointType:&startPtType
                                        fixedLenCurve:prevOrNextFixed];
        }
        CGPoint endGuess = CGPointMake(savedTrans.x + _currCurve.end.x, savedTrans.y + _currCurve.end.y);
        if (!next) {
            endNearby = [self connectToAnotherCurve:endGuess
                                       endPointType:&endPtType
                                      fixedLenCurve:prevOrNextFixed];
        }
        
        if (prevOrNextFixed) {
            if (startNearby) {
                CGPoint ptDiff;
                if (startPtType == START) {
                    ptDiff = CGPointMake(startGuess.x - startNearby.start.x, startGuess.y - startNearby.start.y);
                } else {
                    ptDiff = CGPointMake(startGuess.x - startNearby.end.x, startGuess.y - startNearby.end.y);
                }
                [startNearby movePoint:&ptDiff pointType:startPtType recursive:NO];
            }
            if (endNearby) {
                CGPoint ptDiff;
                if (endPtType == START) {
                    ptDiff = CGPointMake(endGuess.x - endNearby.start.x, endGuess.y - endNearby.start.y);
                } else {
                    ptDiff = CGPointMake(endGuess.x - endNearby.end.x, endGuess.y - endNearby.end.y);
                }
                [endNearby movePoint:&ptDiff pointType:endPtType recursive:NO];
            }
        } else {
            // Treat startNearby having higher prority than endNearby
            // This is for the ease of coding
            if (startNearby) {
                startGuess = startPtType == START ? startNearby.start : startNearby.end;
                savedTrans.x = startGuess.x - _currCurve.start.x;
                savedTrans.y = startGuess.y - _currCurve.start.y;
            }
            if (endNearby && !startNearby) {
                endGuess = endPtType == START ? endNearby.start : endNearby.end;
                savedTrans.x = endGuess.x - _currCurve.end.x;
                savedTrans.y = endGuess.y - _currCurve.end.y;
            } else if (endNearby && startNearby && !startNearby.fixedDist && endNearby.fixedDist) {
                endGuess = endPtType == START ? endNearby.start : endNearby.end;
                savedTrans.x = endGuess.x - _currCurve.end.x;
                savedTrans.y = endGuess.y - _currCurve.end.y;
                
                startGuess = CGPointMake(_currCurve.start.x + savedTrans.x, _currCurve.start.y + savedTrans.y);
                CGPoint ptDiff;
                if (startPtType == START) {
                    ptDiff = CGPointMake(startGuess.x - startNearby.start.x, startGuess.y - startNearby.start.y);
                } else {
                    ptDiff = CGPointMake(startGuess.x - startNearby.end.x, startGuess.y - startNearby.end.y);
                }
                [startNearby movePoint:&ptDiff pointType:startPtType recursive:NO];
            } else if (endNearby && !endNearby.fixedDist) {
                // startNearby is not nil in this case
                endGuess = CGPointMake(_currCurve.end.x + savedTrans.x, _currCurve.end.y + savedTrans.y);
                CGPoint ptDiff;
                if (endPtType == START) {
                    ptDiff = CGPointMake(endGuess.x - endNearby.start.x, endGuess.y - endNearby.start.y);
                } else {
                    ptDiff = CGPointMake(endGuess.x - endNearby.end.x, endGuess.y - endNearby.end.y);
                }
                [endNearby movePoint:&ptDiff pointType:endPtType recursive:NO];
            } else {
                endNearby = nil;
            }
            
            [_currCurve translate:savedTrans];
            [next movePoint:&savedTrans pointType:(next.prevCurve==_currCurve)?START:END recursive:NO];
            [prev movePoint:&savedTrans pointType:(prev.prevCurve==_currCurve)?START:END recursive:NO];
        }
        
        if (startNearby) {
            if (startPtType == START) {
                startNearby.prevCurve = _currCurve;
            } else {
                startNearby.nextCurve = _currCurve;
            }
            _currCurve.prevCurve = startNearby;
        }
        if (endNearby) {
            if (endPtType == START) {
                endNearby.prevCurve = _currCurve;
            } else {
                endNearby.nextCurve = _currCurve;
            }
            _currCurve.nextCurve = endNearby;
        }
        
        if (startNearby || endNearby) {
            connectToNeighbor = YES;
        }
    } else if (_activePoint == TOP) {
        [_currCurve movePoint:&_trans pointType:_activePoint recursive:NO];
    }
    
    if (connectToNeighbor && _currCurve.nextCurve && _currCurve.prevCurve && [ActivePolygon isThisCurveInPolygon:_currCurve]) {
        [self addPolygon:_currCurve];
        _currCurve = nil;
        _activePoint = NONE;
        _currPolygon = [_polygonArr lastObject];
        _activeType = POLYGON;
    }

    out:
    // reset translation to 0 for next move action
    _trans.x = _trans.y = 0;
}

- (void)addPolygon:(ActiveCurve*)start
{
    ActiveCurve *iter = start;
    ActiveCurve *last = start.prevCurve;
    ActivePolygon* newPolygon = [[ActivePolygon new] init];
    do {
        if (iter.nextCurve == last && iter.prevCurve != last) {
            // align the sequence of preCurve and nextCurve in the nextCurve
            iter.nextCurve = iter.prevCurve;
            iter.prevCurve = last;
            CGPoint tmp = iter.start;
            iter.start = iter.end;
            iter.end   = tmp;
        }
        
        [newPolygon addCurve:iter];
        [_curveArr removeObject:iter];
        
        last = iter;
        iter = iter.nextCurve;
    } while (iter != start);
    
    [_polygonArr addObject:newPolygon];
}

- (void)deselect
{
    if (_activeType == CURVE) {
        [self addCurve:_currCurve];
        _currCurve = nil;
        _activeType = EMPTY;
    } else if (_activeType == POLYGON) {
        _currPolygon = nil;
        _currCurve = nil;
        _activePoint = NONE;
        _activeType = EMPTY;
    }
}

- (void)discardSelectedCurve
{
    if (_activeType == CURVE) {
        assert(!_currPolygon);
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
        _currCurve = nil;
        _activePoint = NONE;
    } else {
        assert(_activeType == POLYGON && _currPolygon);
        [_polygonArr removeObject:_currPolygon];
        _currPolygon = nil;
        _currCurve = nil;
        _activePoint = NONE;
    }
    _activeType = EMPTY;
}

- (void)setActiveLineType:(enum CurveType)type
{
    if (!_currCurve) {
        _currCurve = [[ActiveCurve alloc] init];
    }
    _currCurve.lineType = type;
}

@end
