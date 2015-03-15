//
//  UITailorTableView.h
//  TailorAsist
//
//  Created by user1 on 14-7-28.
//  Copyright (c) 2014年 user1. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ActiveCurve.h"
#import "CurveSetObj.h"

@interface UITailorTableView : UIView//UIImageView
- (id)initWithFrame:(CGRect)frame curveSetObj:(CurveSetObj*)curveSet;
- (void)drawRect:(CGRect)rect;
- (void)setStartPoint:(CGPoint)pt;
- (void)updateEndPoint:(CGPoint)pt;
- (void)setEndPoint:(CGPoint)pt; // End point won't change
- (void)setLineType:(enum CurveType)type;
@end
