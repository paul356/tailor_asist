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
    MOVE
};

@interface WorkTableViewController () {
    CurveSetObj *_curveSet;
    enum ControlState _controlState;
}
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic) UITailorTableView *tableView;
- (void)handlePanGesture:(UIPanGestureRecognizer*) recognizer;
@end
@interface WorkTableViewController() {
}
@end

@implementation WorkTableViewController

- (void)handlePanGesture:(UIPanGestureRecognizer*) recognizer
{
    CGPoint pt = [recognizer locationInView:self.tableView];
    
    if (_controlState == DRAW_LINE ||
        _controlState == DRAW_CIRCLE) {
        if (recognizer.state == UIGestureRecognizerStateBegan) {
            if (_controlState == DRAW_CIRCLE) {
                [self.tableView setLineType:CIRCLE];
            } else if (_controlState == DRAW_LINE) {
                [self.tableView setLineType:LINE];
            }
            [self.tableView setStartPoint:pt];
        } else if (recognizer.state == UIGestureRecognizerStateChanged) {
            [self.tableView updateEndPoint:pt];
        } else if (recognizer.state == UIGestureRecognizerStateEnded) {
            [self.tableView setEndPoint:pt];
        }
        NSLog(@"(%lf, %lf)\n", pt.x, pt.y);
        [self.tableView setNeedsDisplay];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _curveSet = [[CurveSetObj alloc] init];
    _controlState = DRAW_CIRCLE;
    
    self.tableView = [[UITailorTableView alloc] initWithFrame:self.scrollView.bounds curveSetObj:_curveSet];
    self.tableView.userInteractionEnabled = TRUE;
    [self.scrollView addSubview:self.tableView];
    self.scrollView.contentSize = self.scrollView.bounds.size;
    
	// Do any additional setup after loading the view, typically from a nib.
    UIPanGestureRecognizer* panDetector = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    
    [self.tableView addGestureRecognizer:panDetector];
    
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

@end
