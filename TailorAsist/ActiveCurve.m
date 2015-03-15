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
    return self;
}

- (void)copyCurve:(ActiveCurve*)curve
{
    self.lineType   = curve.lineType;
    self.startPt    = curve.startPt;
    self.endPt      = curve.endPt;
    self.top        = curve.top;
}

- (void)drawCurve:(CGContextRef)ctx
{
    CGFloat white[4] = {1.0f, 1.0f, 1.0f, 1.0f};
    CGFloat red[4] = {1.0f, 0.0f, 0.0f, 1.0f};
    if (self.lineType == LINE) {

        CGContextSetStrokeColor(ctx, white);
        CGContextSetLineWidth(ctx, 1.0);
                
        CGContextBeginPath(ctx);
        CGContextMoveToPoint(ctx, self.startPt.x, self.startPt.y);
        CGContextAddLineToPoint(ctx, self.endPt.x, self.endPt.y);
        CGContextStrokePath(ctx);
        
        CGContextBeginPath(ctx);
        CGContextAddArc(ctx, self.startPt.x, self.startPt.y, 3, 0, 2*PI, 0);
        CGContextClosePath(ctx);
        CGContextStrokePath(ctx);
        
        CGContextBeginPath(ctx);
        CGContextAddArc(ctx, self.endPt.x, self.endPt.y, 3, 0, 2*PI, 0);
        CGContextClosePath(ctx);
        CGContextStrokePath(ctx);

    } else if (self.lineType == CIRCLE) {
        
        CGPoint perp;
        perp.x = (2*self.top.x - self.startPt.x - self.endPt.x)/2.0;
        perp.y = (2*self.top.y - self.startPt.y - self.endPt.y)/2.0;
        
        double perpNorm2 = perp.x * perp.x + perp.y * perp.y;
        if (perpNorm2 < 0.5) {
            return;
        }
        
        double perpNorm = sqrt(perpNorm2);
        double radius = ((self.endPt.x - self.startPt.x)*(self.endPt.x - self.startPt.x) + (self.endPt.y - self.startPt.y)*(self.endPt.y - self.startPt.y))/(8*perpNorm) + perpNorm/2.0;
        CGPoint center;
        center.x = self.top.x - perp.x*radius/perpNorm;
        center.y = self.top.y - perp.y*radius/perpNorm;
        
        GLfloat start = calcAngle(&center, &self->_startPt);
        GLfloat end   = calcAngle(&center, &self->_endPt);
        
        CGContextSaveGState(ctx);
        
        CGContextSetStrokeColor(ctx, white);
        CGContextSetLineWidth(ctx, 1.0);
        
        CGContextBeginPath(ctx);
        CGContextAddArc(ctx, center.x, center.y, radius, start, end, 0);
        CGContextStrokePath(ctx);
        
        CGContextBeginPath(ctx);
        CGContextAddArc(ctx, self.startPt.x, self.startPt.y, 3, 0, 2*PI, 0);
        CGContextClosePath(ctx);
        CGContextStrokePath(ctx);
        
        CGContextBeginPath(ctx);
        CGContextAddArc(ctx, self.endPt.x, self.endPt.y, 3, 0, 2*PI, 0);
        CGContextClosePath(ctx);
        CGContextStrokePath(ctx);
        
        CGContextBeginPath(ctx);
        CGContextAddArc(ctx, self.top.x, self.top.y, 3, 0, 2*PI, 0);
        CGContextClosePath(ctx);
        CGContextStrokePath(ctx);
        
        CGFloat dash[] = {2.0, 2.0};
        CGContextSetLineDash(ctx, 0, dash, 2);
        CGContextSetStrokeColor(ctx, white);
        
        CGContextBeginPath(ctx);
        CGContextMoveToPoint(ctx, self.startPt.x, self.startPt.y);
        CGContextAddLineToPoint(ctx, self.endPt.x, self.endPt.y);
        CGContextStrokePath(ctx);

        CGContextRestoreGState(ctx);
    }
}

@end
