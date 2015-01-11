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
    self.startAngle = INVALID_ANGLE;
    self.lineType = UNKNOWN;
    return self;
}

- (void)drawCurve:(CGContextRef)ctx
{
    if (self.lineType == LINE) {
        CGFloat green[4] = {0.0f, 1.0f, 0.0f, 1.0f};
        CGContextSetStrokeColor(ctx, green);
        CGContextBeginPath(ctx);
        //CGContextMoveToPoint(ctx, start->x, start->y);
        //CGContextAddLineToPoint(ctx, end->x, end->y);
        CGContextStrokePath(ctx);
    } else {
        CGFloat white[4] = {1.0f, 1.0f, 1.0f, 1.0f};
        CGContextSetStrokeColor(ctx, white);
        CGContextBeginPath(ctx);
        bool first = true;
        CGPoint* start = NULL;
        CGPoint* elmt  = NULL;
        CGContextStrokePath(ctx);
    }
}

@end
