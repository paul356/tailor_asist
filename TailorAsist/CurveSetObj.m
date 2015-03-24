//
//  CurveSetObj.m
//  TailorAssistor
//
//  Created by user1 on 15/3/10.
//  Copyright (c) 2015年 user1. All rights reserved.
//

#import "CurveSetObj.h"

@implementation CurveSetObj {
    NSMutableArray* _curveArr;
}

- (instancetype)init
{
    _curveArr = [[NSMutableArray alloc] init];
    return self;
}

- (void)drawCurveSet:(CGContextRef)ctx color:(CGColorRef)co
{
    for (ActiveCurve* curve in _curveArr) {
        [curve drawCurve:ctx color:co];
    }
}

- (void)addCurve:(ActiveCurve*)newCurve
{
    [_curveArr addObject:newCurve];
}

- (ActiveCurve *)hitTestAndRemove:(CGPoint)pt
{
    ActiveCurve* hitCurve = nil;
    for (ActiveCurve* curve in _curveArr) {
        if ([curve hitControlPoint:pt]) {
            hitCurve = curve;
            break;
        }
    }
    [_curveArr removeObject:hitCurve];
    return hitCurve;
}

@end
