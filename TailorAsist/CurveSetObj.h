//
//  CurveSetObj.h
//  TailorAssistor
//
//  Created by user1 on 15/3/10.
//  Copyright (c) 2015年 user1. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ActiveCurve.h"

@interface CurveSetObj : NSObject
- (instancetype)init;
- (void)setActiveCurveStartPoint:(CGPoint)pt;
- (void)updateActiveCurveEndPoint:(CGPoint)pt;
- (void)setActiveCurveEndPoint:(CGPoint)pt; // End point won't change
- (void)setActiveLineType:(enum CurveType)type;

- (void)updateActiveCurveTranslation:(CGPoint)pt;
- (void)endActiveCurveTranslation;

- (void)drawCurveSet:(CGContextRef)ctx color:(CGColorRef)co activeColor:(CGColorRef)aco;
- (void)addCurve:(ActiveCurve*)newCurve;

- (BOOL)hitTest:(CGPoint)pt;
- (void)deselect;
- (void)discardSelectedCurve;
@end
