//
//  ActiveCurve.m
//  TailorAsist
//
//  Created by user1 on 14-8-18.
//  Copyright (c) 2014年 user1. All rights reserved.
//

#import "ActiveCurve.h"

double calcAngle(CGPoint* startPt, CGPoint* endPt)
{
    double vx = endPt->x - startPt->x;
    double vy = endPt->y - startPt->y;
    return atan2(vy, vx);
}

double angleDiff(double ang1, double ang2)
{
    double diff = ang1 - ang2;
    while (diff > 2*PI) {
        diff -= 2*PI;
    }
    while (diff < -2.*PI) {
        diff += 2*PI;
    }
    return diff;
}

double calcDist(CGPoint* startPt, CGPoint* endPt)
{
    double vx = endPt->x - startPt->x;
    double vy = endPt->y - startPt->y;
    return sqrt(vx*vx + vy*vy);
}

@interface ActiveCurve ()
@end

@implementation ActiveCurve
- (instancetype)init
{
    self.lineType = LINE;
    self.fixedDist = 0.0;
    self.nextCurve = self.prevCurve = nil;
    self.start = self.end = CGPointMake(0, 0);
    return self;
}

- (id)copy
{
    ActiveCurve *curve = [[ActiveCurve alloc] init];
    curve.lineType = self.lineType;
    curve.start    = self.start;
    curve.end      = self.end;
    curve.top      = self.top;
    curve.fixedDist = self.fixedDist;
    return curve;
}

- (void)drawRuler:(CGContextRef)ctx
{
    float norm = calcDist(&_start, &_end);
    NSString* length = [NSString stringWithFormat:@"%.2f", norm];
    CGSize bs = [length sizeWithAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:12]}];
    if (norm < MIN_CURVE_LENGTH || norm < bs.width) {
        return;
    }
    
    CGPoint normVect = CGPointMake((_end.x - _start.x) / norm, (_end.y - _start.y) / norm);
    CGPoint perpVect;
    if (self.lineType == LINE) {
        perpVect = CGPointMake((_end.y - _start.y)/norm, - (_end.x - _start.x)/norm);
    } else {
        CGPoint mid = CGPointMake((_start.x + _end.x) / 2, (_start.y + _end.y) / 2);
        float perpNorm = calcDist(&mid, &_top);
        perpVect = CGPointMake((mid.x - _top.x)/perpNorm, (mid.y - _top.y)/perpNorm);
    }
    
    CGPoint start1 = CGPointMake(_start.x + 2*TOUCH_POINT_SIZE*perpVect.x, _start.y + 2*TOUCH_POINT_SIZE*perpVect.y);
    CGPoint end1   = CGPointMake(_end.x + 2*TOUCH_POINT_SIZE*perpVect.x, _end.y + 2*TOUCH_POINT_SIZE*perpVect.y);
    CGPoint mid    = CGPointMake((start1.x + end1.x) / 2, (start1.y + end1.y) / 2);
    int reflect = 1;
    // This is to deal with the case: perpVect is not rotate(90) of normVet.
    // So we can get the textOrigion right.
    if (normVect.y * perpVect.x - normVect.x * perpVect.y < 0) {
        reflect = -1;
    }
    CGPoint textOrig = CGPointMake(mid.x - bs.width * normVect.x / 2 + reflect * bs.height * perpVect.x / 2, mid.y - bs.width * normVect.y / 2 + reflect * bs.height * perpVect.y / 2);
    float tilt = calcAngle(&start1, &end1);
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, nil, start1.x, start1.y);
    CGPathAddLineToPoint(path, nil, start1.x + (norm - bs.width)/2*normVect.x, start1.y + (norm - bs.width)/2*normVect.y);
    CGPathMoveToPoint(path, nil, end1.x, end1.y);
    CGPathAddLineToPoint(path, nil, end1.x - (norm - bs.width)/2*normVect.x, end1.y - (norm - bs.width)/2*normVect.y);
    
    CGPathMoveToPoint(path, nil, start1.x - perpVect.x*TOUCH_POINT_SIZE, start1.y - perpVect.y*TOUCH_POINT_SIZE);
    CGPathAddLineToPoint(path, nil, start1.x + perpVect.x*TOUCH_POINT_SIZE, start1.y + perpVect.y*TOUCH_POINT_SIZE);
    
    CGPathMoveToPoint(path, nil, end1.x - perpVect.x*TOUCH_POINT_SIZE, end1.y - perpVect.y*TOUCH_POINT_SIZE);
    CGPathAddLineToPoint(path, nil, end1.x + perpVect.x*TOUCH_POINT_SIZE, end1.y + perpVect.y*TOUCH_POINT_SIZE);
    
    CGContextSaveGState(ctx);
    
    CGFloat dash[] = {2.0, 2.0};
    CGContextSetLineDash(ctx, 0, dash, 2);
    CGContextAddPath(ctx, path);
    CGContextStrokePath(ctx);
    
    CGContextTranslateCTM(ctx, textOrig.x, textOrig.y);
    CGContextRotateCTM(ctx, tilt);
    [length drawAtPoint:CGPointMake(0, 0) withAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:12], NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
    CGContextRestoreGState(ctx);
}

- (void)drawCenter:(CGContextRef)ctx color:(CGColorRef)co
{
    CGPoint mid = CGPointMake((self.start.x + self.end.x)/2, (self.start.y + self.end.y)/2);
    CGMutablePathRef path = CGPathCreateMutable();
    int signs1[] = {1, 0, -1, 0};
    int signs2[] = {0, 1, 0, -1};
    CGPoint pts[4];
    float norm = calcDist(&_start, &_end);
    if (norm >= MIN_CURVE_LENGTH) {
        CGPoint normVect = CGPointMake((self.end.x - self.start.x)/norm, (self.end.y - self.start.y)/norm);
        for (int i = 0; i < sizeof(signs1)/sizeof(signs1[0]); i ++) {
            // two sides of rectangle
            CGPoint pt1 = CGPointMake(normVect.x * signs1[i] * TOUCH_POINT_SIZE, normVect.y * signs1[i] * TOUCH_POINT_SIZE);
            CGPoint pt2 = CGPointMake(normVect.y * signs2[i] * TOUCH_POINT_SIZE, - normVect.x * signs2[i] * TOUCH_POINT_SIZE);
            pts[i] = CGPointMake(pt1.x + pt2.x + mid.x, pt1.y + pt2.y + mid.y);
        }
        CGPathAddLines(path, nil, &pts[0], sizeof(pts)/sizeof(pts[0]));
        CGPathCloseSubpath(path);
        CGContextAddPath(ctx, path);
        CGContextStrokePath(ctx);
    }
}

- (void)calcRadius:(double *)radius Center:(CGPoint *)center
{
    CGPoint perp;
    perp.x = (2*self.top.x - self.start.x - self.end.x)/2.0;
    perp.y = (2*self.top.y - self.start.y - self.end.y)/2.0;
    
    double perpNorm2 = perp.x * perp.x + perp.y * perp.y;
    if (perpNorm2 < 0.5) {
        *radius = calcDist(&_start, &_end)/2;
        center->x = (self.start.x + self.start.x)/2;
        center->y = (self.start.y + self.start.y)/2;
        return;
    }
    
    double perpNorm = sqrt(perpNorm2);
    *radius = ((self.end.x - self.start.x)*(self.end.x - self.start.x) + (self.end.y - self.start.y)*(self.end.y - self.start.y))/(8*perpNorm) + perpNorm/2.0;
    center->x = self.top.x - perp.x*(*radius)/perpNorm;
    center->y = self.top.y - perp.y*(*radius)/perpNorm;
}

- (void)drawCurve:(CGContextRef)ctx color:(CGColorRef)co selected:(BOOL)select
{
    if (self.lineType == LINE) {
        CGContextSaveGState(ctx);
        
        CGContextSetStrokeColorWithColor(ctx, co);
        CGContextSetLineWidth(ctx, 1.0);
        
        CGContextBeginPath(ctx);
        CGContextMoveToPoint(ctx, self.start.x, self.start.y);
        CGContextAddLineToPoint(ctx, self.end.x, self.end.y);
        CGContextStrokePath(ctx);
        
        if (select) {
            CGContextBeginPath(ctx);
            CGContextAddArc(ctx, self.start.x, self.start.y, TOUCH_POINT_SIZE, 0, 2*PI, 0);
            CGContextClosePath(ctx);
            CGContextStrokePath(ctx);
            
            CGContextBeginPath(ctx);
            CGContextAddArc(ctx, self.end.x, self.end.y, TOUCH_POINT_SIZE, 0, 2*PI, 0);
            CGContextClosePath(ctx);
            CGContextStrokePath(ctx);
            
            //[self drawCenter:ctx color:co];
            [self drawRuler:ctx];
        }
        
        CGContextRestoreGState(ctx);
    } else if (self.lineType == CIRCLE) {
        double radius;
        CGPoint center;
        [self calcRadius:&radius Center:&center];
        
        GLfloat min = calcAngle(&center, &self->_start);
        GLfloat max = calcAngle(&center, &self->_end);
        if (min > max) {
            GLfloat tmp;
            tmp = max;
            max = min;
            min = tmp;
        }
        GLfloat midAng= calcAngle(&center, &self->_top);
        
        CGContextSaveGState(ctx);
        
        CGContextSetStrokeColorWithColor(ctx, co);
        CGContextSetLineWidth(ctx, 1.0);
        
        CGContextBeginPath(ctx);
        if ((midAng < min && midAng < max) ||
            (midAng > min && midAng > max)) {
            CGContextAddArc(ctx, center.x, center.y, radius, max, min, 0);
        } else {
            CGContextAddArc(ctx, center.x, center.y, radius, min, max, 0);
        }
        CGContextStrokePath(ctx);
    
        if (select) {
            CGContextBeginPath(ctx);
            CGContextAddArc(ctx, self.start.x, self.start.y, TOUCH_POINT_SIZE, 0, 2*PI, 0);
            CGContextClosePath(ctx);
            CGContextStrokePath(ctx);
            
            CGContextBeginPath(ctx);
            CGContextAddArc(ctx, self.end.x, self.end.y, TOUCH_POINT_SIZE, 0, 2*PI, 0);
            CGContextClosePath(ctx);
            CGContextStrokePath(ctx);
            
            CGContextBeginPath(ctx);
            CGContextAddArc(ctx, self.top.x, self.top.y, TOUCH_POINT_SIZE, 0, 2*PI, 0);
            CGContextClosePath(ctx);
            CGContextStrokePath(ctx);
            
            CGFloat dash[] = {2.0, 2.0};
            CGContextSetLineDash(ctx, 0, dash, 2);
            
            CGContextBeginPath(ctx);
            CGContextMoveToPoint(ctx, self.start.x, self.start.y);
            CGContextAddLineToPoint(ctx, self.end.x, self.end.y);
            CGContextStrokePath(ctx);
            
            //[self drawCenter:ctx color:co];
            [self drawRuler:ctx];
        }
        
        CGContextRestoreGState(ctx);
    }
}

- (enum ControlPointType)hitControlPoint:(CGPoint)pt endPointOnly:(BOOL)endOnly
{
    if (calcDist(&self->_start, &pt) < TOUCH_POINT_SIZE) {
        return START;
    }
    if (calcDist(&self->_end, &pt) < TOUCH_POINT_SIZE) {
        return END;
    }
    if (self.lineType == CIRCLE && !endOnly) {
        if (calcDist(&self->_top, &pt) < TOUCH_POINT_SIZE) {
            return TOP;
        }
    }
    
    if (!endOnly && [self hitTest:pt]) {
        return CENTER;
    } else {
        return NONE;
    }
}

- (BOOL)hitTest:(CGPoint)pt
{
    if (self.lineType == LINE) {
        float norm2 = (_end.x - _start.x)*(_end.x - _start.x) + (_end.y - _start.y)*(_end.y - _start.y);
        float project = (pt.x - _start.x)*(_end.x - _start.x) + (pt.y - _start.y)*(_end.y - _start.y);
        float ratio = project/norm2;
        if (ratio < 0 || ratio > 1) {
            return NO;
        }
        CGPoint distVect = CGPointMake(pt.x - _start.x - ratio*(_end.x - _start.x), pt.y - _start.y - ratio*(_end.y - _start.y));
        float dist2 = distVect.x * distVect.x + distVect.y * distVect.y;
        if (dist2 <= TOUCH_POINT_SIZE*TOUCH_POINT_SIZE) {
            return YES;
        } else {
            return NO;
        }
    } else if (self.lineType == CIRCLE) {
        double radius;
        CGPoint center;
        [self calcRadius:&radius Center:&center];
        
        GLfloat dist = calcDist(&pt, &center);
        if (dist - radius < -TOUCH_POINT_SIZE ||
            dist - radius > TOUCH_POINT_SIZE) {
            return NO;
        }
        
        // TODO: continue checking if pt is one same side of top
        CGPoint perp = CGPointMake(_end.y - _start.y, - _end.x + _start.x);
        CGPoint mid  = CGPointMake((_start.x + _end.x)/2, (_start.y + _end.y)/2);
        float side = perp.x * (_top.x - mid.x) + perp.y * (_top.y - mid.y);
        float side1 = perp.x * (pt.x - mid.x) + perp.y * (pt.y - mid.y);
        if (side * side1 < 0) {
            return NO;
        }
        
        return YES;
    }
    
    return NO;
}

- (void)translate:(CGPoint)pt
{
    self.start = CGPointMake(pt.x + self.start.x, pt.y + self.start.y);
    self.end   = CGPointMake(pt.x + self.end.x, pt.y + self.end.y);
    self.top   = CGPointMake(pt.x + self.top.x, pt.y + self.top.y);
}

- (void)movePoint:(CGPoint*)pt pointType:(enum ControlPointType)ptType recursive:(BOOL)recur
{
    CGPoint newPt = *pt;
    switch (ptType) {
        case START:
            if (self.fixedDist && self.prevCurve && self.prevCurve.fixedDist) {
                pt->x = pt->y = 0;
                break;
            }
            if (recur && self.prevCurve && self.prevCurve.fixedDist) {
                if (self.prevCurve.prevCurve == self) {
                    [self.prevCurve movePoint:&newPt pointType:START recursive:FALSE];
                } else {
                    assert(self.prevCurve.nextCurve == self);
                    [self.prevCurve movePoint:&newPt pointType:END recursive:FALSE];
                }
            } else if (self.fixedDist) {
                CGPoint fakePt;
                fakePt.x = pt->x + self.start.x;
                fakePt.y = pt->y + self.start.y;
                CGFloat fakeLen = calcDist(&fakePt, &self->_end);
                newPt.x = (fakePt.x - self.end.x)*self.fixedDist/fakeLen + self.end.x - self.start.x;
                newPt.y = (fakePt.y - self.end.y)*self.fixedDist/fakeLen + self.end.y - self.start.y;
            }
            if (self.lineType == CIRCLE) {
                CGFloat startTopDist = calcDist(&self->_start, &self->_top);
                CGFloat startEndDist = calcDist(&self->_start, &self->_end);
                CGPoint midPt;
                midPt.x = (self.start.x + self.end.x)/2.0;
                midPt.y = (self.start.y + self.end.y)/2.0;
                CGFloat perpNorm = calcDist(&midPt, &self->_top);
                CGFloat cosv = startEndDist/(2.0*startTopDist);
                CGFloat sinv = perpNorm / startTopDist;
                
                self.start = CGPointMake(newPt.x + self.start.x, newPt.y + self.start.y);
                
                self.top = CGPointMake(cosv*(self.end.x - self.start.x) + sinv*(self.end.y - self.start.y), -sinv*(self.end.x - self.start.x) + cosv*(self.end.y - self.start.y));
                self.top = CGPointMake(self.top.x / startEndDist * startTopDist + self.start.x, self.top.y / startEndDist * startTopDist + self.start.y);
            } else {
                self.start = CGPointMake(newPt.x + self.start.x, newPt.y + self.start.y);
            }
            
            if (recur && self.prevCurve && !self.prevCurve.fixedDist) {
                if (self.prevCurve.prevCurve == self) {
                    [self.prevCurve movePoint:&newPt pointType:START recursive:FALSE];
                } else {
                    assert(self.prevCurve.nextCurve == self);
                    [self.prevCurve movePoint:&newPt pointType:END recursive:FALSE];
                }
            }
            *pt = newPt;
            break;
        case END:
            if (self.fixedDist && self.nextCurve && self.nextCurve.fixedDist) {
                pt->x = pt->x = 0;
                break;
            }
            if (recur && self.nextCurve && self.nextCurve.fixedDist) {
                if (self.nextCurve.nextCurve == self) {
                    [self movePoint:&newPt pointType:END recursive:FALSE];
                } else {
                    assert(self.nextCurve.prevCurve == self);
                    [self movePoint:&newPt pointType:START recursive:FALSE];
                }
            } else if (self.fixedDist) {
                CGPoint fakePt;
                fakePt.x = pt->x + self.end.x;
                fakePt.y = pt->y + self.end.y;
                CGFloat fakeLen = calcDist(&fakePt, &self->_start);
                newPt.x = (fakePt.x - self.start.x)*self.fixedDist/fakeLen + self.start.x - self.end.x;
                newPt.y = (fakePt.y - self.start.y)*self.fixedDist/fakeLen + self.start.y - self.end.y;
            }
            if (self.lineType == CIRCLE) {
                CGFloat startTopDist = calcDist(&self->_start, &self->_top);
                CGFloat startEndDist = calcDist(&self->_start, &self->_end);
                CGPoint midPt;
                midPt.x = (self.start.x + self.end.x)/2.0;
                midPt.y = (self.start.y + self.end.y)/2.0;
                CGFloat perpNorm = calcDist(&midPt, &self->_top);
                CGFloat cosv = startEndDist/(2.0*startTopDist);
                CGFloat sinv = perpNorm / startTopDist;
                
                self.end = CGPointMake(newPt.x + self.end.x, newPt.y + self.end.y);
                
                self.top = CGPointMake(cosv*(self.end.x - self.start.x) + sinv*(self.end.y - self.start.y), -sinv*(self.end.x - self.start.x) + cosv*(self.end.y - self.start.y));
                self.top = CGPointMake(self.top.x / startEndDist * startTopDist + self.start.x, self.top.y / startEndDist * startTopDist + self.start.y);
            } else {
                self.end = CGPointMake(newPt.x + self.end.x, newPt.y + self.end.y);
            }
            if (recur && self.nextCurve && !self.nextCurve.fixedDist) {
                if (self.nextCurve.nextCurve == self) {
                    [self.nextCurve movePoint:&newPt pointType:END recursive:FALSE];
                } else {
                    assert(self.nextCurve.prevCurve == self);
                    [self.nextCurve movePoint:&newPt pointType:START recursive:FALSE];
                }
            }
            *pt = newPt;
            break;
        case CENTER:
        {
            ActiveCurve* prev = self.prevCurve;
            ActiveCurve* next = self.nextCurve;
            if (recur) {
                if (prev && prev.fixedDist && next && next.fixedDist) {
                    pt->x = pt->y = 0;
                    break;
                } else if (prev && prev.fixedDist) {
                    if (prev.prevCurve == self) {
                        [prev movePoint:&newPt pointType:START recursive:NO];
                    } else {
                        [prev movePoint:&newPt pointType:END recursive:NO];
                    }
                } else if (next && next.fixedDist) {
                    if (next.prevCurve == self) {
                        [next movePoint:&newPt pointType:START recursive:NO];
                    } else {
                        [next movePoint:&newPt pointType:END recursive:NO];
                    }
                }
            }
            
            [self translate:newPt];
            
            if (recur) {
                if (prev && !prev.fixedDist) {
                    if (prev.prevCurve == self) {
                        [prev movePoint:&newPt pointType:START recursive:NO];
                    } else {
                        [prev movePoint:&newPt pointType:END recursive:NO];
                    }
                }
                if (next && !next.fixedDist) {
                    if (next.prevCurve == self) {
                        [next movePoint:&newPt pointType:START recursive:NO];
                    } else {
                        [next movePoint:&newPt pointType:END recursive:NO];
                    }
                }
            }
            *pt = newPt;
            break;
        }
        case TOP:
        {
            CGPoint mid = CGPointMake((self.start.x + self.end.x) / 2, (self.start.y + self.end.y) / 2);
            float dist = calcDist(&mid, &_top);
            float shift = pt->x * (self.top.x - mid.x) / dist + pt->y * (self.top.y - mid.y) / dist;
            CGPoint delta = CGPointMake(shift * (self.top.x - mid.x) / dist, shift * (self.top.y - mid.y) / dist);
            CGPoint new = CGPointMake(delta.x + self.top.x, delta.y + self.top.y);
            if (calcDist(&new, &mid) < MIN_CURVE_LENGTH) {
                if (shift > 0) {
                    shift = MIN_CURVE_LENGTH;
                } else {
                    shift = -MIN_CURVE_LENGTH;
                }
                delta = CGPointMake(shift * (self.top.x - mid.x) / dist, shift * (self.top.y - mid.y) / dist);
                new = CGPointMake(delta.x + mid.x, delta.y + mid.y);
            }
            self.top = new;
            
            break;
        }
        default:
            break;
    }
}

- (float)length
{
    return calcDist(&_start, &_end);
}

- (void)setNewLength:(float)nlen
{
    // Because two neighbors are fixed. We can't resize this curve
    if (self.prevCurve && self.prevCurve.fixedDist &&
        self.nextCurve && self.nextCurve.fixedDist) {
        return;
    }
    
    CGPoint delta;
    float olen = [self length];
    float dx = self.end.x - self.start.x;
    float dy = self.end.y - self.start.y;
    delta.x = (nlen - olen) * dx / olen;
    delta.y = (nlen - olen) * dy / olen;
    
    if (self.prevCurve && self.prevCurve.fixedDist) {
        [self movePoint:&delta pointType:END recursive:YES];
    } else {
        delta.x = -delta.x;
        delta.y = -delta.y;
        [self movePoint:&delta pointType:START recursive:YES];
    }
}

@end
