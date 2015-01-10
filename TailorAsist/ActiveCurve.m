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
- (CGPoint)calcBSplinePoint:(double)tparam Index:(NSUInteger)idx;
@end

@implementation ActiveCurve
- (instancetype)init
{
    self.pts = [NSPointerArray pointerArrayWithOptions:NSPointerFunctionsMallocMemory|NSPointerFunctionsStructPersonality];
    self.startAngle = INVALID_ANGLE;
    self.lineType = UNKNOWN;
    self.distArr = NULL;
    return self;
}

- (void)emptyPoints
{
    [self.pts setCount:0];
    self.startAngle = INVALID_ANGLE;
    self.lineType  = UNKNOWN;
    if (self.distArr) {
        free(self.distArr);
        self.distArr = nil;
    }
}

- (void)calcDistArr
{
    NSUInteger cnt = [self.pts count];
    self.distArr = (double *)malloc((cnt+4)*sizeof(double));
    self.distArr[0] = self.distArr[1] = self.distArr[2] = 0;
    for (int i = 0; i < cnt-2; i ++) {
        self.distArr[3+i] = i;
    }
    self.distArr[cnt+1] = self.distArr[cnt+2] = self.distArr[cnt+3] = self.distArr[cnt];
}

- (CGPoint)calcBSplinePoint:(double)tparam Index:(NSUInteger)idx
{
    CGPoint* relatedPts[4];
    relatedPts[0] = [self.pts pointerAtIndex:idx];
    relatedPts[1] = [self.pts pointerAtIndex:idx-1];
    relatedPts[2] = [self.pts pointerAtIndex:idx-2];
    relatedPts[3] = [self.pts pointerAtIndex:idx-3];
    
    CGPoint interPts[3];
    for (int i = 0; i < 3; i ++) {
        double k = (tparam - self.distArr[idx-i]) / (self.distArr[idx+3-i] - self.distArr[idx-i]);
        interPts[i].x = k * relatedPts[i]->x + (1 - k) * relatedPts[i+1]->x;
        interPts[i].y = k * relatedPts[i]->y + (1 - k) * relatedPts[i+1]->y;
    }
    
    for (int i = 0; i < 2; i++) {
        double k = (tparam - self.distArr[idx-i]) / (self.distArr[idx+2-i] - self.distArr[idx-i]);
        interPts[i].x = k * interPts[i].x + (1 - k) * interPts[i+1].x;
        interPts[i].y = k * interPts[i].y + (1 - k) * interPts[i+1].y;
    }
    
    double k = (tparam - self.distArr[idx]) / (self.distArr[idx+1] - self.distArr[idx]);
    interPts[0].x = k * interPts[0].x + (1 - k) * interPts[1].x;
    interPts[0].y = k * interPts[0].y + (1 - k) * interPts[1].y;
    
    return interPts[0];
}

- (void)drawCurve:(CGContextRef)ctx
{
    if (self.lineType == LINE) {
        if ([self.pts count] > 2) {
            NSUInteger cnt = [self.pts count];
            CGPoint* end = [self.pts pointerAtIndex:cnt-1];
            CGPoint* second = [self.pts pointerAtIndex:1];
            *second = *end;
            [self.pts setCount:2];
        }
        CGFloat green[4] = {0.0f, 1.0f, 0.0f, 1.0f};
        CGContextSetStrokeColor(ctx, green);
        CGContextBeginPath(ctx);
        CGPoint* start = [self.pts pointerAtIndex:0];
        CGPoint* end   = [self.pts pointerAtIndex:1];
        CGContextMoveToPoint(ctx, start->x, start->y);
        CGContextAddLineToPoint(ctx, end->x, end->y);
        CGContextStrokePath(ctx);
    } else if (self.lineType == BSPLINE) {
        NSUInteger cnt = [self.pts count];
        CGPoint* start = [self.pts pointerAtIndex:0];
        CGFloat green[4] = {0.0f, 1.0f, 0.0f, 1.0f};
        CGContextSetStrokeColor(ctx, green);
        CGContextBeginPath(ctx);
        CGContextMoveToPoint(ctx, start->x, start->y);
        for (int i = 3; i < cnt; i ++) {
            for (int j = 0; j < 10; j ++) {
                CGPoint pt = [self calcBSplinePoint:i-3+j*0.1 Index:i];
                CGContextAddLineToPoint(ctx, pt.x, pt.y);
            }
        }
        CGPoint pt = [self calcBSplinePoint:cnt-3 Index:cnt-1];
        CGContextAddLineToPoint(ctx, pt.x, pt.y);
        CGContextStrokePath(ctx);
    } else {
        CGFloat white[4] = {1.0f, 1.0f, 1.0f, 1.0f};
        CGContextSetStrokeColor(ctx, white);
        CGContextBeginPath(ctx);
        bool first = true;
        CGPoint* start = NULL;
        CGPoint* elmt  = NULL;
        for (id pt in self.pts) {
            elmt = (__bridge struct CGPoint *)pt;
            if (first) {
                CGContextMoveToPoint(ctx, elmt->x, elmt->y);
                start = elmt;
                first = false;
            } else {
                CGContextAddLineToPoint(ctx, elmt->x, elmt->y);
            }
        }
        CGContextStrokePath(ctx);
    }
}

@end
