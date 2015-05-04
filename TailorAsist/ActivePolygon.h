//
//  ActivePolygon.h
//  TailorAssistor
//
//  Created by user1 on 15/5/1.
//  Copyright (c) 2015年 user1. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ActiveCurve.h"

@interface ActivePolygon : NSObject <DrawableShape>
- (void)drawCurve:(CGContextRef)ctx color:(CGColorRef)co;
- (void)translate:(CGPoint)pt;

- (instancetype)init;
- (void)addCurve:(ActiveCurve*)curve;

+ (BOOL)isThisCurveInPolygon:(ActiveCurve*)start;
@end
