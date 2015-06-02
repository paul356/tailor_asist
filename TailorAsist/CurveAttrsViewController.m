//
//  CurveAttrsViewController.m
//  TailorAssistor
//
//  Created by user1 on 5/17/15.
//  Copyright (c) 2015 user1. All rights reserved.
//

#import "CurveAttrsViewController.h"

@interface CurveAttrsViewController () <UITextFieldDelegate> {
    ActiveCurve *_curveToShow;
}
@end

@implementation CurveAttrsViewController

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)associateCurve:(ActiveCurve *)curve
{
    _curveToShow = curve;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _startLabel.text = [NSString stringWithFormat:@"(%.2f, %.2f)", _curveToShow.start.x, _curveToShow.start.y];
    _endLabel.text   = [NSString stringWithFormat:@"(%.2f, %.2f)", _curveToShow.end.x, _curveToShow.end.y];
    _lenTextEdit.text = [NSString stringWithFormat:@"%f", [_curveToShow length]];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
