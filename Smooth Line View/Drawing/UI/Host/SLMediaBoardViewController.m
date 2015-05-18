//
// Created by Yaroslav Vorontsov on 13.05.15.
// Copyright (c) 2015 Yaroslav Vorontsov. All rights reserved.
//

#import "SLMediaBoardViewController.h"
#import "SLSmoothLineView.h"
#import "SLRasterTool.h"
#import "SLBrush.h"
#import "SLEraser.h"

@interface SLMediaBoardViewController()
@property (nonatomic, readonly) SLSmoothLineView *canvasView;
@property (assign, nonatomic) SLDrawingMode drawingMode;
@property (strong, nonatomic) NSMapTable *toolContext;

@property (strong, nonatomic) UIColor *strokeColor;
@property (assign, nonatomic) CGSize strokeSize;
@end

@implementation SLMediaBoardViewController
{

}

#pragma mark - Initialization and memory management

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder
{
    if ((self = [super initWithCoder:coder])) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    self.toolContext = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsWeakMemory valueOptions:NSPointerFunctionsStrongMemory];
    self.drawingMode = SLLineDrawing;
    self.strokeColor = [UIColor blackColor];
    self.strokeSize = CGSizeMake(10, 10);
}

#pragma mark - View lifecycle

- (void)loadView
{
    self.view = [[SLSmoothLineView alloc] init];
    self.view.backgroundColor = [UIColor whiteColor];
    self.view.multipleTouchEnabled = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSLog(@"Media view is prepared for use");
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

#pragma mark - Handling touches

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    // Saving first touch positions and tools for future usage
    for (UITouch *touch in touches) {
        CGPoint point = [touch locationInView:self.canvasView];
        [self.toolContext setObject:[self createToolWithControlPoint:point] forKey:touch];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self drawBasedOnTouches:touches commitDrawing:NO];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self drawBasedOnTouches:touches commitDrawing:YES];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
}

#pragma mark - Handling shakes

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (motion == UIEventSubtypeMotionShake) {
        [self.undoManager undo];
    }
}

#pragma mark - Helper methods

- (id<SLRasterTool>)createToolWithControlPoint:(CGPoint)controlPoint
{
    id<SLRasterTool> rasterTool = nil;
    switch (_drawingMode)
    {
        case SLLineDrawing:
        {
            rasterTool = [[SLBrush alloc] initWithControlPoint:controlPoint lineWidth:self.strokeSize.width color:self.strokeColor];
            break;
        }
        case SLErasing:
        {
            rasterTool = [[SLEraser alloc] initWithLineWidth:self.strokeSize.width initialPoint:controlPoint];
            break;
        }
        default:
            break;
    }
    return rasterTool;
}

- (SLSmoothLineView *)canvasView
{
    return (SLSmoothLineView *) self.view;
}

- (void)drawBasedOnTouches:(NSSet *)touches commitDrawing:(BOOL)commitDrawing
{
    CGRect drawBox = CGRectNull;
    NSMutableArray *tools = [NSMutableArray arrayWithCapacity:touches.count];
    for (UITouch *touch in touches) {
        id<SLRasterTool> tool = [self.toolContext objectForKey:touch];
        tool.previousTouchLocation = [touch previousLocationInView:self.canvasView];
        tool.touchLocation = [touch locationInView:self.canvasView];
        tool.commitDrawing = YES;
        drawBox = CGRectUnion(drawBox, [tool boundingBox]);
        [tools addObject:tool];
    }
    if (!(CGRectIsEmpty(drawBox) || CGRectIsNull(drawBox))) {
        [self.canvasView updateCanvasWithTools:tools inRect:drawBox];
    }
}

#pragma mark - Undo/redo management - Command pattern + NSUndoManager

/**
* Some support for future undo/redo. General notes are here:
*   1. http://stackoverflow.com/questions/1907715/how-to-use-nsundomanager-with-a-uiimageview-or-cgcontext
*   CGContexts have no support for undo/redo operations - need to reproduce them using cached images
*
*
*/
- (void)drawUsingTool:(id<SLRasterTool>)tool
{
    // Retrieve a new NSInvocation for drawing and set new arguments for the draw command
//    NSInvocation *drawInvocation = [self drawInvocationWithTool:tool];
//    NSInvocation *eraseInvocation = [self undrawInvocationWithTool:tool];
    // Execute the draw command with the erase command
//    [self executeInvocation:drawInvocation withUndoInvocation:eraseInvocation];
}

- (void) executeInvocation:(NSInvocation *)invocation
        withUndoInvocation:(NSInvocation *)undoInvocation
{
    [invocation retainArguments];
    [undoInvocation retainArguments];
    [[self.undoManager prepareWithInvocationTarget:self] revertInvocation:undoInvocation
                                                       withRedoInvocation:invocation];
    [invocation invoke];
}

- (void)revertInvocation:(NSInvocation *)invocation
      withRedoInvocation:(NSInvocation *)redoInvocation
{
    [[self.undoManager prepareWithInvocationTarget:self] executeInvocation:redoInvocation
                                                        withUndoInvocation:invocation];
    [invocation invoke];
}

@end