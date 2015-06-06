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
@property (nonatomic) BOOL curveView;

- (void)drawCurve:(CGContextRef)ctx color:(CGColorRef)co selected:(BOOL)select;
- (void)translate:(CGPoint)pt;

- (instancetype)init;
- (id)copy;
- (void)addCurve:(ActiveCurve*)curve;
- (BOOL)pointInsideThisPolygon:(CGPoint)pt;
- (ActiveCurve*)hitInnerCurve:(CGPoint)pt endPointType:(enum ControlPointType*)ptType;

+ (BOOL)isThisCurveInPolygon:(ActiveCurve*)start;
@end
