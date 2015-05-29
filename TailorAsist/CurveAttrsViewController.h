//
//  CurveAttrsViewController.h
//  TailorAssistor
//
//  Created by user1 on 5/17/15.
//  Copyright (c) 2015 user1. All rights reserved.
//

#import <UIKit/UIKit.h>

#define CURVE_ATTRS_CHANGE_NOTIFICATION @"CURVE_ATTRS_CHANGE_NOTIFICATION"

@interface CurveAttrsViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *startLabel;
@property (weak, nonatomic) IBOutlet UITextField *lenTextEdit;
@property (weak, nonatomic) IBOutlet UILabel *endLabel;
- (void)specifyStart:(CGPoint)start end:(CGPoint)end;
@end
