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

- (void)drawCurveSet:(CGContextRef) ctx
{
    for (ActiveCurve* curve in _curveArr) {
        [curve drawCurve:ctx];
    }
}

- (void)addCurve:(ActiveCurve*)newCurve
{
    [_curveArr addObject:newCurve];
}

@end
