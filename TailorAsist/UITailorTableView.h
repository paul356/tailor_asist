//
//  UITailorTableView.h
//  TailorAsist
//
//  Created by user1 on 14-7-28.
//  Copyright (c) 2014年 user1. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ActiveCurve.h"

@interface UITailorTableView : UIView//UIImageView
- (void)drawRect:(CGRect)rect;
- (void)addPoint:(CGPoint *)pt;
- (void)setNextCurveReady;
- (void)setStartAngle:(double)angl;
- (void)setLineType:(enum CurveType)type;
@end
