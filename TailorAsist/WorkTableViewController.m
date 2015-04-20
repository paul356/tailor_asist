//
//  ViewController.m
//  TailorAsist
//
//  Created by user1 on 14-6-8.
//  Copyright (c) 2014年 user1. All rights reserved.
//

#import "WorkTableViewController.h"
#import "UITailorTableView.h"
#import "ActiveCurve.h"
#import "CurveSetObj.h"
#import "Matrix2D.h"

const NSUInteger minLinePointNum = 16;
// Should be not smaller than minLinePointNum
const NSUInteger minCirclePointNum = 8;
const double     ANGLE_DEVIATION = 0.17;

NSInteger sortDouble(id num1, id num2, void *context)
{
    double v1 = [num1 doubleValue];
    double v2 = [num2 doubleValue];
    if (v1 < v2)
        return NSOrderedAscending;
    else if (v1 > v2)
        return NSOrderedDescending;
    else
        return NSOrderedSame;
}

enum ControlState {
    SELECT,
    DRAW_LINE,
    DRAW_CIRCLE,
};

@interface WorkTableViewController () {
    CurveSetObj *_curveSet;
    enum ControlState _controlState;
    CGPoint _startPt;
    BOOL _objectSelected;
}
@property (weak, nonatomic) IBOutlet UITailorTableView *tailorView;
@end

@implementation WorkTableViewController
- (IBAction)setControlState:(id)sender {
    UIBarButtonItem* barButton = (UIBarButtonItem*)sender;
    if ([barButton.title isEqualToString:@"Cursor"]) {
        _controlState = SELECT;
    } else if ([barButton.title isEqualToString:@"Line"]) {
        _controlState = DRAW_LINE;
    } else if ([barButton.title isEqualToString:@"Circle"]) {
        _controlState = DRAW_CIRCLE;
    } else if ([barButton.title isEqualToString:@"Delete"]) {
        if (_controlState == SELECT) {
            [_curveSet discardSelectedCurve];
            [_tailorView setNeedsDisplay];
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _curveSet = [[CurveSetObj alloc] init];
    _controlState = DRAW_LINE;
    _objectSelected = FALSE;
    
    [_tailorView initViewResources:_curveSet];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (touches.count == 1) {
        CGPoint pt = [touches.anyObject locationInView:_tailorView];
        switch (_controlState) {
            case DRAW_LINE:
            case DRAW_CIRCLE:
                [_curveSet deselect];
                if (_controlState == DRAW_CIRCLE) {
                    [_curveSet setActiveLineType:CIRCLE];
                } else if (_controlState == DRAW_LINE) {
                    [_curveSet setActiveLineType:LINE];
                }
                [_curveSet setActiveCurveStartPoint:pt];
                [_tailorView setNeedsDisplay];
                break;
            case SELECT:
                if ([_curveSet hitTest:pt]) {
                    _objectSelected = TRUE;
                    _startPt = pt;
                }
                [_tailorView setNeedsDisplay];
                break;
            default:
                break;
        }
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (touches.count == 1) {
        CGPoint pt = [touches.anyObject locationInView:_tailorView];
        switch (_controlState) {
            case DRAW_CIRCLE:
            case DRAW_LINE:
                [_curveSet updateActiveCurveEndPoint:pt];
                [_tailorView setNeedsDisplay];
                break;
            case SELECT:
                if (_objectSelected) {
                    [_curveSet updateActiveCurveTranslation:CGPointMake(pt.x - _startPt.x, pt.y - _startPt.y)];
                    [_tailorView setNeedsDisplay];
                    NSLog(@"Translate to %f %f\n", pt.x - _startPt.x, pt.y - _startPt.y);
                }
                break;
            default:
                break;
        }
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (touches.count == 1) {
        CGPoint pt = [touches.anyObject locationInView:_tailorView];
        switch (_controlState) {
            case DRAW_LINE:
            case DRAW_CIRCLE:
                [_curveSet setActiveCurveEndPoint:pt];
                [_tailorView setNeedsDisplay];
                break;
            case SELECT:
                if (_objectSelected) {
                    [_curveSet endActiveCurveTranslation];
                    _objectSelected = FALSE;
                    [_tailorView setNeedsDisplay];
                }
                break;
            default:
                break;
        }
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"Touch cancelled\n");
}

@end
