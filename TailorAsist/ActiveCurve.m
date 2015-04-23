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

- (void)copyCurve:(ActiveCurve*)curve
{
    self.lineType = curve.lineType;
    self.start    = curve.start;
    self.end      = curve.end;
    self.top      = curve.top;
    self.fixedDist = curve.fixedDist;
}

- (void)drawCurve:(CGContextRef)ctx color:(CGColorRef)co
{
    if (self.lineType == LINE) {
        CGContextSaveGState(ctx);

        CGContextSetStrokeColorWithColor(ctx, co);
        CGContextSetLineWidth(ctx, 1.0);
                
        CGContextBeginPath(ctx);
        CGContextMoveToPoint(ctx, self.start.x, self.start.y);
        CGContextAddLineToPoint(ctx, self.end.x, self.end.y);
        CGContextStrokePath(ctx);
        
        CGContextBeginPath(ctx);
        CGContextAddArc(ctx, self.start.x, self.start.y, TOUCH_POINT_SIZE, 0, 2*PI, 0);
        CGContextClosePath(ctx);
        CGContextStrokePath(ctx);
        
        CGContextBeginPath(ctx);
        CGContextAddArc(ctx, self.end.x, self.end.y, TOUCH_POINT_SIZE, 0, 2*PI, 0);
        CGContextClosePath(ctx);
        CGContextStrokePath(ctx);
        
        CGContextRestoreGState(ctx);
    } else if (self.lineType == CIRCLE) {
        
        CGPoint perp;
        perp.x = (2*self.top.x - self.start.x - self.end.x)/2.0;
        perp.y = (2*self.top.y - self.start.y - self.end.y)/2.0;
        
        double perpNorm2 = perp.x * perp.x + perp.y * perp.y;
        if (perpNorm2 < 0.5) {
            return;
        }
        
        double perpNorm = sqrt(perpNorm2);
        double radius = ((self.end.x - self.start.x)*(self.end.x - self.start.x) + (self.end.y - self.start.y)*(self.end.y - self.start.y))/(8*perpNorm) + perpNorm/2.0;
        CGPoint center;
        center.x = self.top.x - perp.x*radius/perpNorm;
        center.y = self.top.y - perp.y*radius/perpNorm;
        
        GLfloat start = calcAngle(&center, &self->_start);
        GLfloat end   = calcAngle(&center, &self->_end);
        
        CGContextSaveGState(ctx);
        
        CGContextSetStrokeColorWithColor(ctx, co);
        CGContextSetLineWidth(ctx, 1.0);
        
        CGContextBeginPath(ctx);
        CGContextAddArc(ctx, center.x, center.y, radius, start, end, 0);
        CGContextStrokePath(ctx);
        
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
    if (self.lineType == CIRCLE &&
        !endOnly &&
        calcDist(&self->_top, &pt) < TOUCH_POINT_SIZE) {
        return TOP;
    }
    return NONE;
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
        case TOP:
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
        default:
            break;
    }
}

@end
