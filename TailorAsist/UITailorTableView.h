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
- (void)initViewResources:(CurveSetObj*)curveSet;
- (void)setCurveSet:(CurveSetObj*)curveSet;
- (void)drawRect:(CGRect)rect;
@end
