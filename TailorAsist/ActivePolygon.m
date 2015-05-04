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
        CGContextAddLineToPoint(ctx, curve.end.x, curve.end.y);
    }
    CGContextClosePath(ctx);
    CGContextFillPath(ctx);
}

- (void)translate:(CGPoint)pt
{
    
}

- (void)addCurve:(ActiveCurve *)curve
{
    [_curves addObject:curve];
}

+ (BOOL)isThisCurveInPolygon:(ActiveCurve*)start
{
    return YES;
}
@end
