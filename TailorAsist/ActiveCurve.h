//
//  ActiveCurve.h
//  TailorAsist
//
//  Created by user1 on 14-8-18.
//  Copyright (c) 2014年 user1. All rights reserved.
//

#import <Foundation/Foundation.h>

#define PI 3.1415926
#define TOUCH_POINT_SIZE 3
enum CurveType {
    LINE,
    CIRCLE,
    BSPLINE,
    UNKNOWN
};

enum ControlPointType {
    NONE,
    START,
    TOP,
    END,
};

double calcAngle(CGPoint* startPt, CGPoint* endPt);
double calcDist(CGPoint* startPt, CGPoint* endPt);
double angleDiff(double ang1, double ang2);

@interface ActiveCurve : NSObject
@property (nonatomic) enum CurveType lineType;
@property (nonatomic) CGPoint start;
@property (nonatomic) CGPoint end;
// The circle is draw clock-wise
@property (nonatomic) CGPoint top;
@property (nonatomic) ActiveCurve* prevCurve;
@property (nonatomic) ActiveCurve* nextCurve;
- (instancetype)init;
- (void)copyCurve:(ActiveCurve*)curve;
- (void)drawCurve:(CGContextRef)ctx color:(CGColorRef)co;
- (enum ControlPointType)hitControlPoint:(CGPoint)pt endPointOnly:(BOOL)endOnly;
- (void)translate:(CGPoint)pt;
@end
