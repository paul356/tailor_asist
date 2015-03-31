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

- (void)movePoint:(CGPoint)pt pointType:(enum ControlPointType)ptType recursive:(BOOL)recur
{
    switch (ptType) {
        case START:
            if (self.lineType == CIRCLE) {
                CGFloat startTopDist = calcDist(&self->_start, &self->_top);
                CGFloat startEndDist = calcDist(&self->_start, &self->_end);
                CGPoint midPt;
                midPt.x = (self.start.x + self.end.x)/2.0;
                midPt.y = (self.start.y + self.end.y)/2.0;
                CGFloat perpNorm = calcDist(&midPt, &self->_top);
                CGFloat cosv = startEndDist/(2.0*startTopDist);
                CGFloat sinv = perpNorm / startTopDist;
                
                self.start = CGPointMake(pt.x + self.start.x, pt.y + self.start.y);
                
                self.top = CGPointMake(cosv*(self.end.x - self.start.x) + sinv*(self.end.y - self.start.y), -sinv*(self.end.x - self.start.x) + cosv*(self.end.y - self.start.y));
                self.top = CGPointMake(self.top.x / startEndDist * startTopDist + self.start.x, self.top.y / startEndDist * startTopDist + self.start.y);
            } else {
                self.start = CGPointMake(pt.x + self.start.x, pt.y + self.start.y);
            }
            
            if (recur) {
                if (self.prevCurve &&
                    self.prevCurve.prevCurve == self) {
                    [self.prevCurve movePoint:pt pointType:START recursive:FALSE];
                } else if (self.prevCurve) {
                    assert(self.prevCurve.nextCurve == self);
                    [self.prevCurve movePoint:pt pointType:END recursive:FALSE];
                }
            }
            break;
        case END:
            if (self.lineType == CIRCLE) {
                CGFloat startTopDist = calcDist(&self->_start, &self->_top);
                CGFloat startEndDist = calcDist(&self->_start, &self->_end);
                CGPoint midPt;
                midPt.x = (self.start.x + self.end.x)/2.0;
                midPt.y = (self.start.y + self.end.y)/2.0;
                CGFloat perpNorm = calcDist(&midPt, &self->_top);
                CGFloat cosv = startEndDist/(2.0*startTopDist);
                CGFloat sinv = perpNorm / startTopDist;
                
                self.end = CGPointMake(pt.x + self.end.x, pt.y + self.end.y);
                
                self.top = CGPointMake(cosv*(self.end.x - self.start.x) + sinv*(self.end.y - self.start.y), -sinv*(self.end.x - self.start.x) + cosv*(self.end.y - self.start.y));
                self.top = CGPointMake(self.top.x / startEndDist * startTopDist + self.start.x, self.top.y / startEndDist * startTopDist + self.start.y);
            } else {
                self.end = CGPointMake(pt.x + self.end.x, pt.y + self.end.y);
            }
            if (recur) {
                if (self.nextCurve &&
                    self.nextCurve.nextCurve == self) {
                    [self.nextCurve movePoint:pt pointType:END recursive:FALSE];
                } else if (self.nextCurve) {
                    assert(self.nextCurve.prevCurve == self);
                    [self.nextCurve movePoint:pt pointType:START recursive:FALSE];
                }
            }
            break;
        case TOP:
            // Need to change it according to math
            self.top   = CGPointMake(pt.x + self.top.x, pt.y + self.top.y);
            break;
        default:
            break;
    }
}

@end
