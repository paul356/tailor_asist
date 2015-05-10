//
//  ActivePolygon.m
//  TailorAssistor
//
//  Created by user1 on 15/5/1.
//  Copyright (c) 2015年 user1. All rights reserved.
//

#import "ActivePolygon.h"

@interface ActivePolygon () {
    NSMutableArray* _curves;
}
@end

@implementation ActivePolygon
- (instancetype)init
{
    _curves = [[NSMutableArray alloc] init];
    return self;
}

- (id)copy
{
    ActivePolygon* new = [[ActivePolygon alloc] init];
    for (ActiveCurve* curve in _curves) {
        [new addCurve:[curve copy]];
    }
    
    return new;
}

- (void)drawCurve:(CGContextRef)ctx color:(CGColorRef)co
{
    CGContextSetFillColorWithColor(ctx, co);
    CGContextSetLineWidth(ctx, 1.0);
    
    BOOL firstCurve = YES;
    CGContextBeginPath(ctx);
    for (ActiveCurve* curve in _curves) {
        if (firstCurve) {
            CGContextMoveToPoint(ctx, curve.start.x, curve.start.y);
            firstCurve = NO;
        }
        if (curve.lineType == CIRCLE) {
            CGPoint perp;
            perp.x = (2*curve.top.x - curve.start.x - curve.end.x)/2.0;
            perp.y = (2*curve.top.y - curve.start.y - curve.end.y)/2.0;
            
            double perpNorm2 = perp.x * perp.x + perp.y * perp.y;
            if (perpNorm2 < 0.5) {
                return;
            }
            
            double perpNorm = sqrt(perpNorm2);
            double radius = ((curve.end.x - curve.start.x)*(curve.end.x - curve.start.x) + (curve.end.y - curve.start.y)*(curve.end.y - curve.start.y))/(8*perpNorm) + perpNorm/2.0;
            CGPoint center;
            center.x = curve.top.x - perp.x*radius/perpNorm;
            center.y = curve.top.y - perp.y*radius/perpNorm;
            
            CGPoint start = curve.start;
            CGPoint end   = curve.end;
            GLfloat startAngl = calcAngle(&center, &start);
            GLfloat endAngl   = calcAngle(&center, &end);
            
            CGContextAddArc(ctx, center.x, center.y, radius, startAngl, endAngl, 0);
        } else {
            CGContextAddLineToPoint(ctx, curve.end.x, curve.end.y);
        }
    }
    CGContextFillPath(ctx);
    CGContextStrokePath(ctx);
}

- (void)translate:(CGPoint)pt
{
    for (ActiveCurve* curve in _curves) {
        [curve translate:pt];
    }
}

- (void)addCurve:(ActiveCurve *)curve
{
    [_curves addObject:curve];
}

- (BOOL)pointInsideThisPolygon:(CGPoint)pt
{
    // Algorithm from http://alienryderflex.com/polygon/
    BOOL oddNodes = NO;
    for (ActiveCurve* curve in _curves) {
        if (((curve.start.y < pt.y && curve.end.y >= pt.y) ||
             (curve.end.y   < pt.y && curve.start.y >= pt.y)) &&
            (curve.start.x <=  pt.x || curve.end.x <= pt.x)) {
            if (curve.end.x + (pt.y - curve.end.y)/(curve.start.y - curve.end.y)*(curve.start.x - curve.end.x) < pt.x) {
                oddNodes = !oddNodes;
            }
        }
    }
    return oddNodes;
}

+ (BOOL)isThisCurveInPolygon:(ActiveCurve*)start
{
    ActiveCurve* next = start.nextCurve;
    ActiveCurve* last = start;
    while (next != start && next != nil) {
        last = next;
        if (next.nextCurve != last) {
            next = next.nextCurve;
        } else {
            next = next.prevCurve;
        }
    }
    return next == start;
}
@end
