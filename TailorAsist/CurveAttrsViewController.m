//
//  CurveAttrsViewController.m
//  TailorAssistor
//
//  Created by user1 on 5/17/15.
//  Copyright (c) 2015 user1. All rights reserved.
//

#import "CurveAttrsViewController.h"
#import "ActiveCurve.h"

@interface CurveAttrsViewController () <UITextFieldDelegate>
@end

@implementation CurveAttrsViewController

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    //[[NSNotificationCenter defaultCenter] postNotificationName:CURVE_ATTRS_CHANGE_NOTIFICATION object:nil];
    return YES;
}

- (void)specifyStart:(CGPoint)start end:(CGPoint)end
{
    _startLabel.text = [NSString stringWithFormat:@"(%.2f, %.2f)", start.x, start.y];
    _endLabel.text   = [NSString stringWithFormat:@"(%.2f, %.2f)", end.x, end.y];
    _lenTextEdit.text = [NSString stringWithFormat:@"%f", calcDist(&start, &end)];
    [self.view setNeedsDisplay];
}

- (void)viewDidLoad {
    [super viewDidLoad];
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
