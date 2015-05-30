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
#import "DataSetObj.h"
#import "CurveAttrsViewController.h"

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
    DataSetObj *_dataSet;
    enum ControlState _controlState;
    CGPoint _startPt;
    BOOL _objectSelected;
    BOOL _popoverPresented;
    UIPopoverController* _popoverController;
}
@property (weak, nonatomic) IBOutlet UITailorTableView *tailorView;
- (void)curveAttrsUpdated:(NSNotification*)notify;
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
            [_dataSet discardSelectedCurve];
            [_tailorView setNeedsDisplay];
        }
    } else if ([barButton.title isEqualToString:@"Info"]) {
        ActiveCurve* currCurve = [_dataSet getCurrActiveCurve];
        if (currCurve) {
            // TODO: don't know why popover can't get data right at first
            CGRect rect = CGRectMake(currCurve.start.x, currCurve.start.y, 300, 150);
            CurveAttrsViewController* curveAttrsControl = (CurveAttrsViewController*)_popoverController.contentViewController;
            [curveAttrsControl associateCurve:currCurve];
            [_popoverController presentPopoverFromRect:rect inView:_tailorView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
            _popoverPresented = YES;
        }
    }
}

- (void)curveAttrsUpdated:(NSNotification*)notify
{
    CurveAttrsViewController* cavController = (CurveAttrsViewController*)_popoverController.contentViewController;
    if (notify.object != cavController.lenTextEdit) {
        return;
    }
    /*
    NSRange textRange = [cavController.lenTextEdit.text rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"0123456789."]];
    if (textRange.length != [cavController.lenTextEdit.text length]) {
        return;
    }
     */
    
    float newValue = cavController.lenTextEdit.text.floatValue;
    if (newValue < MIN_CURVE_LENGTH) {
        return;
    }
    ActiveCurve* currCurve = [_dataSet getCurrActiveCurve];
    if (newValue != [currCurve length]) {
        [currCurve setNewLength:newValue];
        [_tailorView setNeedsDisplay];
    }
}

- (void)awakeFromNib
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(curveAttrsUpdated:) name:UITextFieldTextDidEndEditingNotification object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _dataSet = [[DataSetObj alloc] init];
    _tailorView.curveSet = _dataSet;
    _controlState = DRAW_LINE;
    _objectSelected = FALSE;
    _popoverPresented = NO;
	// Do any additional setup after loading the view, typically from a nib.
    UIViewController* contentVc = [self.storyboard instantiateViewControllerWithIdentifier:@"popup window"];
    _popoverController = [[UIPopoverController alloc] initWithContentViewController:contentVc];
    //CGRect rect = CGRectMake(300, 300, 300, 150);
    //[popupView presentPopoverFromRect:rect inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
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
                [_dataSet deselect];
                if (_controlState == DRAW_CIRCLE) {
                    [_dataSet setActiveLineType:CIRCLE];
                } else if (_controlState == DRAW_LINE) {
                    [_dataSet setActiveLineType:LINE];
                }
                [_dataSet setActiveCurveStartPoint:pt];
#warning "Use notification from DataSetObj to TailorTableView instead of blindly call setNeedsDisplay"
                [_tailorView setNeedsDisplay];
                break;
            case SELECT:
                if (_popoverPresented) {
                    _popoverPresented = NO;
                    [_popoverController dismissPopoverAnimated:YES];
                }
                if ([_dataSet hitTest:pt]) {
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
                [_dataSet updateActiveCurveEndPoint:pt];
                [_tailorView setNeedsDisplay];
                break;
            case SELECT:
                if (_objectSelected) {
                    [_dataSet updateShapeTranslation:CGPointMake(pt.x - _startPt.x, pt.y - _startPt.y)];
                    [_tailorView setNeedsDisplay];
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
                [_dataSet setActiveCurveEndPoint:pt];
                [_tailorView setNeedsDisplay];
                break;
            case SELECT:
                if (_objectSelected) {
                    _objectSelected = FALSE;
                    if (pt.x != _startPt.x || pt.y != _startPt.y) {
                        [_dataSet endShapeTranslation];
                        [_tailorView setNeedsDisplay];
                    }
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
