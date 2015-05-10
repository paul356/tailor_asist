//
//  ActiveCurve.h
//  TailorAsist
//
//  Created by user1 on 14-8-18.
//  Copyright (c) 2014年 user1. All rights reserved.
//

#import <Foundation/Foundation.h>

#define PI 3.1415926
#define TOUCH_POINT_SIZE 6
#define MIN_CURVE_LENGTH 2
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

@protocol DrawableShape <NSObject>
- (void)drawCurve:(CGContextRef)ctx color:(CGColorRef)co;
- (void)translate:(CGPoint)pt;
@end

@interface ActiveCurve : NSObject<DrawableShape>
@property (nonatomic) enum CurveType lineType;
@property (nonatomic) CGPoint start;
@property (nonatomic) CGPoint end;
@property (nonatomic) CGFloat fixedDist;
// The circle is draw clock-wise
@property (nonatomic) CGPoint top;
@property (nonatomic) ActiveCurve* prevCurve;
@property (nonatomic) ActiveCurve* nextCurve;
- (instancetype)init;
- (id)copy;
- (void)drawCurve:(CGContextRef)ctx color:(CGColorRef)co;
- (enum ControlPointType)hitControlPoint:(CGPoint)pt endPointOnly:(BOOL)endOnly;
- (void)translate:(CGPoint)pt;
- (void)movePoint:(CGPoint*)pt pointType:(enum ControlPointType)ptType recursive:(BOOL)recur;
@end
