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
- (void)drawCurveSet:(CGContextRef)ctx color:(CGColorRef)co;
- (void)addCurve:(ActiveCurve*)newCurve;
- (ActiveCurve *)hitTestAndRemove:(CGPoint) pt;
@end
