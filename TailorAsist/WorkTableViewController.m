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

@interface WorkTableViewController () {
    NSPointerArray* ptsArr;
}
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property UITailorTableView *tableView;
- (void)handlePanGesture:(UIPanGestureRecognizer*) recognizer;
@end

@implementation WorkTableViewController

- (void)handlePanGesture:(UIPanGestureRecognizer*) recognizer
{
    CGPoint pt = [recognizer locationInView:self.tableView];
    CGPoint* savePt = malloc(sizeof(CGPoint));
    CGPoint* viewPt = malloc(sizeof(CGPoint));
    *savePt = pt;
    *viewPt = pt;
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        NSLog(@"curve begin\n");
        [ptsArr setCount:0];
        [ptsArr addPointer:savePt];
        [self.tableView setNextCurveReady];
        [self.tableView addPoint:viewPt];
    } else if (recognizer.state == UIGestureRecognizerStateChanged) {
        [ptsArr replacePointerAtIndex:1 withPointer:savePt];
        [self.tableView addPoint:viewPt];
    } else if (recognizer.state == UIGestureRecognizerStateEnded) {
        NSLog(@"curve end\n");
        [ptsArr addPointer:savePt];
        [self.tableView addPoint:viewPt];
        if ([ptsArr count] >= minLinePointNum) {
            [self.tableView setLineType:BSPLINE];
        }
    }
    [self.tableView setNeedsDisplay];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView = [[UITailorTableView alloc] initWithFrame:self.scrollView.bounds];
    self.tableView.userInteractionEnabled = TRUE;
    [self.scrollView addSubview:self.tableView];
    self.scrollView.contentSize = self.scrollView.bounds.size;
    
	// Do any additional setup after loading the view, typically from a nib.
    UIPanGestureRecognizer* panDetector = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    
    [self.tableView addGestureRecognizer:panDetector];
    
    ptsArr = [NSPointerArray pointerArrayWithOptions:NSPointerFunctionsMallocMemory|NSPointerFunctionsStructPersonality];
    startAngle = INVALID_ANGLE;
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
