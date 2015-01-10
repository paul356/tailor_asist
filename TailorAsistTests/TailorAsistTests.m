//
//  TailorAsistTests.m
//  TailorAsistTests
//
//  Created by user1 on 14-6-8.
//  Copyright (c) 2014年 user1. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Matrix2D.h"
#import "ActiveCurve.h"

@interface TailorAsistTests : XCTestCase

@end

@implementation TailorAsistTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)subTestExample0
{
    NSPointerArray* pts = [[NSPointerArray alloc] initWithOptions:NSPointerFunctionsStructPersonality|NSPointerFunctionsMallocMemory];
    CGPoint *pt1 = (CGPoint*)malloc(sizeof(CGPoint));
    CGPoint *pt2 = (CGPoint*)
    
    pt1.x = 1; pt1.y = 2;
    pt2.x = 3; pt2.y = 4;
    
    [pts addPointer:&pt1];
    [pts addPointer:&pt2];
    
    for (id pt in pts) {
        CGPoint* tpt = (__bridge CGPoint *)pt;
        NSLog(@"(%f %f)\n", tpt->x, tpt->y);
    }
}

- (void)subTestExample1
{
    Matrix2D* vect = [[Matrix2D alloc] initWithRowNum:3 colNum:1];
    [vect setElement:0 Col:0 Value:1.0];
    [vect setElement:1 Col:0 Value:3.0];
    [vect setElement:2 Col:0 Value:5.0];
    
    Matrix2D* t = [vect multiple:[vect transpose]];
    NSLog(@"param x vect\n");
    [t dumpContent];
    
    Matrix2D* h = [Matrix2D householderMat:vect];
    NSLog(@"householder matrix\n");
    [h dumpContent];
    Matrix2D* e = [h multiple:vect];
    NSLog(@"householder x vect\n");
    [e dumpContent];
    
    Matrix2D* param = [[Matrix2D alloc] initWithRowNum:3 colNum:3];
    Matrix2D* val   = [[Matrix2D alloc] initWithRowNum:3 colNum:1];
    
    double* paramData = (double*)[param.data bytes];
    double* valData   = (double*)[val.data bytes];
    
    paramData[0] = 1.0; paramData[1] = 2.0; paramData[2] = 3.0;
    paramData[3] = 4.0; paramData[4] = 5.0; paramData[5] = 6.0;
    paramData[6] = 5.0; paramData[7] = 6.0; paramData[8] = 8.0;
    
    valData[0] = 7.0; valData[1] = 8.0; valData[2] = 9.0;
    
    Matrix2D* res = [Matrix2D solveLinearRegression:param Value:val];
    [res dumpContent];
    
    NSLog(@"Dump log");
    param = [[Matrix2D alloc] initWithRowNum:8 colNum:3];
    val   = [[Matrix2D alloc] initWithRowNum:8 colNum:1];
    paramData = (double*)[param.data bytes];
    valData   = (double*)[val.data bytes];
    
    paramData[0]=284.000000, paramData[1]=708.000000, paramData[2]=1;
    paramData += 3;
    paramData[0]=248.000000, paramData[1]=624.000000, paramData[2]=1;
    paramData += 3;
    paramData[0]=293.000000, paramData[1]=573.000000, paramData[2]=1;
    paramData += 3;
    paramData[0]=421.000000, paramData[1]=578.000000, paramData[2]=1;
    paramData += 3;
    paramData[0]=469.000000, paramData[1]=656.000000, paramData[2]=1;
    paramData += 3;
    paramData[0]=438.000000, paramData[1]=702.000000, paramData[2]=1;
    paramData += 3;
    paramData[0]=365.000000, paramData[1]=720.000000, paramData[2]=1;
    paramData += 3;
    paramData[0]=311.000000, paramData[1]=718.000000, paramData[2]=1;
    
    valData[0]=-581920.000000;
    valData[1]=-450880.000000;
    valData[2]=-414178.000000;
    valData[3]=-511325.000000;
    valData[4]=-650297.000000;
    valData[5]=-684648.000000;
    valData[6]=-651625.000000;
    valData[7]=-612245.000000;
    
    res = [Matrix2D solveLinearRegression:param Value:val];
    [res dumpContent];
    
    double* resVal = (double*)[res.data bytes];
    double cx1 = -resVal[0]/2.0;
    double cy1 = -resVal[1]/2.0;
    double rad1 = sqrt(cx1*cx1 + cy1*cy1 - resVal[2]);
    
    NSLog(@"Center is (%lf, %lf), radius is %lf\n", cx1, cy1, rad1);
}

- (void)subTestExample2
{
    ActiveCurve* ac = [[ActiveCurve alloc] init];
    
    NSUInteger cnt = 15;
    for (int i = 0; i < cnt; i++) {
        CGPoint* pt = (CGPoint*)malloc(sizeof(CGPoint));
        pt->x = 5 * sin(PI * (double)i / cnt);
        pt->y = 1.0;
        
        [ac.pts addPointer:pt];
        NSLog(@"(%lf %lf) ", pt->x, pt->y);
    }
    NSLog(@"\n*********\n");
    
    [ac calcDistArr];
    ac.lineType = BSPLINE;
/*
    for (int i = 3; i < cnt; i++) {
        CGPoint pt = [ac calcBSplinePoint:i-3 Index:i];
        NSLog(@"(%lf %lf) ", pt.x, pt.y);
    }
 */
    NSLog(@"\n");
}

- (void)testExample
{
    [self subTestExample2];
}

@end
