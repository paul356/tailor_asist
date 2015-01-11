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
}
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property UITailorTableView *tableView;
- (void)handlePanGesture:(UIPanGestureRecognizer*) recognizer;
@end

@implementation WorkTableViewController

- (void)handlePanGesture:(UIPanGestureRecognizer*) recognizer
{
    CGPoint pt = [recognizer locationInView:self.tableView];
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        CGPoint* savePt = (CGPoint*)malloc(sizeof(CGPoint));
        *savePt = pt;
        [self.tableView setNextCurveReady];
        [self.tableView setStartPoint:savePt];
    } else if (recognizer.state == UIGestureRecognizerStateChanged ||
               recognizer.state == UIGestureRecognizerStateEnded) {
        CGPoint* savePt = (CGPoint*)malloc(sizeof(CGPoint));
        *savePt = pt;
        [self.tableView updateEndPoint:savePt];
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
