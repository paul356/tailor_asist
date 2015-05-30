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
    _curveView = NO;
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
    if (self.curveView) {
        for (ActiveCurve* curve in _curves) {
            [curve drawCurve:ctx color:co];
        }
    } else {
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
                CGPoint top   = curve.top;
                GLfloat minAngl = calcAngle(&center, &start);
                GLfloat maxAngl = calcAngle(&center, &end);
                GLfloat topAngl = calcAngle(&center, &top);
                if (minAngl > maxAngl) {
                    GLfloat tmp = minAngl;
                    minAngl = maxAngl;
                    maxAngl = tmp;
                }
                
                if ((topAngl < minAngl && topAngl < maxAngl) ||
                    (topAngl > minAngl && topAngl > maxAngl)) {
                    CGContextAddArc(ctx, center.x, center.y, radius, maxAngl, minAngl, 0);
                } else {
                    CGContextAddArc(ctx, center.x, center.y, radius, minAngl, maxAngl, 0);
                }
            } else {
                CGContextAddLineToPoint(ctx, curve.end.x, curve.end.y);
            }
        }
        CGContextFillPath(ctx);
        CGContextStrokePath(ctx);
    }
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

- (ActiveCurve*)hitInnerCurve:(CGPoint)pt endPointType:(enum ControlPointType*)ptType
{
    for (ActiveCurve* curve in _curves) {
        enum ControlPointType ptype = [curve hitControlPoint:pt endPointOnly:NO];
        if (ptype != NONE) {
            *ptType = ptype;
            return curve;
        }
    }
    return nil;
}

+ (BOOL)isThisCurveInPolygon:(ActiveCurve*)start
{
    ActiveCurve* next = start.nextCurve;
    ActiveCurve* last = start;
    while (next != start && next != nil) {
        if (next.nextCurve != last) {
            last = next;
            next = next.nextCurve;
        } else {
            last = next;
            next = next.prevCurve;
        }
    }
    return next == start;
}
@end
