//
//  UITailorTableView.m
//  TailorAsist
//
//  Created by user1 on 14-7-28.
//  Copyright (c) 2014年 user1. All rights reserved.
//

#import "UITailorTableView.h"
#import "ActiveCurve.h"
#import "CurveSetObj.h"

@interface UITailorTableView () {
    CurveSetObj* _curveSet;
    ActiveCurve* _currCurve;
    BOOL _modified;
}
@end

@implementation UITailorTableView

- (id)initWithFrame:(CGRect)frame curveSetObj:(CurveSetObj*)curveSet
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _currCurve = [[ActiveCurve alloc] init];
        _modified = FALSE;
        
        _curveSet = curveSet;
    }

    return self;
}

- (void)drawRect:(CGRect)rect
{
    //[super drawRect:rect];
    CGContextRef c = UIGraphicsGetCurrentContext();
    
    // Outline the canvas
    CGFloat black[4] = {0.0f, 0.0f, 0.0f, 1.0f};
    CGContextSetFillColor(c, black);
    CGContextBeginPath(c);
    CGPoint pts[4] = {
        {rect.origin.x, rect.origin.y},
        {rect.origin.x + rect.size.width, rect.origin.y},
        {rect.origin.x + rect.size.width, rect.origin.y + rect.size.height},
        {rect.origin.x, rect.origin.y + rect.size.height}};
    CGContextAddLines(c, pts, 4);
    CGContextClosePath(c);
    CGContextFillPath(c);
    
    [_curveSet drawCurveSet:c];
    
    if (_modified) {
        [_currCurve drawCurve:c];
        _modified = FALSE;
    }
}

- (void)setStartPoint:(CGPoint)pt
{
    _currCurve.startPt = _currCurve.endPt = pt;
    if (_currCurve.lineType == CIRCLE) {
        _currCurve.top = _currCurve.startPt;
    }
    _modified = TRUE;
}

- (void)updateEndPoint:(CGPoint)pt
{
    _currCurve.endPt = pt;
    if (_currCurve.lineType == CIRCLE) {
        double x = _currCurve.endPt.x - _currCurve.startPt.x;
        double y = _currCurve.endPt.y - _currCurve.startPt.y;
        double cosv = cos(60.0*PI/180);
        double sinv = sin(60.0*PI/180);
        CGPoint center;
        center.x = cosv*x - sinv*y + _currCurve.startPt.x;
        center.y = sinv*x + cosv*y + _currCurve.startPt.y;

        cosv = cos(30.0*PI/180);
        sinv = sin(30.0*PI/180);
        _currCurve.top = CGPointMake(center.x + cosv*(_currCurve.startPt.x - center.x) - sinv*(_currCurve.startPt.y - center.y), center.y + sinv*(_currCurve.startPt.x - center.x) + cosv*(_currCurve.startPt.y - center.y));
    }
    _modified = TRUE;
}

- (void)setEndPoint:(CGPoint)pt
{
    ActiveCurve* newCurve = [[ActiveCurve alloc] init];
    [newCurve copyCurve:_currCurve];
    [_curveSet addCurve:newCurve];
    // Becuase _currCurve value is saved to _curveSet
    // no need to set _modified to TRUE
}

- (void)setLineType:(enum CurveType)type
{
    _currCurve.lineType = type;
}
@end
