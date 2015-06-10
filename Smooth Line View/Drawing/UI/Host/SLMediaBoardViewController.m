//
// Created by Yaroslav Vorontsov on 13.05.15.
// Copyright (c) 2015 Yaroslav Vorontsov. All rights reserved.
//

#import "SLMediaBoardViewController.h"
#import "SLSmoothLineView.h"
#import "SLRasterTool.h"
#import "SLBrush.h"
#import "SLEraser.h"
#import "UIView+Additions.h"
#import "SLTextDrawer.h"
#import "SLLine.h"
#import "SLRectangle.h"
#import "SLEllipse.h"
#import "SLImage.h"
#import "UIBarButtonItem+Additions.h"

@interface SLMediaBoardViewController()
// Contexts and tools
@property (strong, nonatomic) NSMapTable *toolContext;
@property (strong, nonatomic) NSMutableArray *usedTools;
@property (strong, nonatomic) UIColor *strokeColor;
// Views
@property (weak, nonatomic) UIImageView *backgroundImageView;
@property (weak, nonatomic) SLSmoothLineView *canvasView;
// Toolbar buttons
@property (weak, nonatomic) UIBarButtonItem *undoItem;
@property (weak, nonatomic) UIBarButtonItem *redoItem;
// Sizes and drawing modes
@property (assign, nonatomic) CGSize strokeSize;
@property (assign, nonatomic) SLDrawingMode drawingMode;
@property (assign, nonatomic) BOOL undoRedoInvoked;
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
    self.usedTools = [NSMutableArray arrayWithCapacity:100];
    self.drawingMode = SLBrushDrawing;
    self.strokeColor = [UIColor blackColor];
    self.strokeSize = CGSizeMake(10, 10);
}

#pragma mark - View lifecycle

- (void)loadView
{
    self.view = [UIView new];
    self.view.backgroundColor = [UIColor whiteColor];
    // Canvas view for drawing
    SLSmoothLineView *canvasView = [SLSmoothLineView new];
    canvasView.multipleTouchEnabled = YES;
    canvasView.backgroundColor = [UIColor clearColor];
    // Background view for image selection
    UIImageView *backgroundView = [UIImageView new];
    backgroundView.backgroundColor = [UIColor clearColor];
    // Pinning subviews
    [self.view addSubview:backgroundView];
    [backgroundView pinToSuperview];
    [self.view addSubview:canvasView];
    [canvasView pinToSuperview];
    self.backgroundImageView = backgroundView;
    self.canvasView = canvasView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Configuring toolbar items
    // Undo/redo tools
    UIBarButtonItem *undoItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemUndo
                                                                              target:self
                                                                              action:@selector(undoAction)];
    self.undoItem = undoItem;
    UIBarButtonItem *redoItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRedo
                                                                              target:self
                                                                              action:@selector(redoAction)];
    self.redoItem = redoItem;
    // Tools - brush, eraser, text
    UIBarButtonItem *brushItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Brush"]
                                                                  style:UIBarButtonItemStylePlain
                                                                 target:self
                                                                 action:@selector(toolSelected:)];
    brushItem.tag = SLBrushDrawing;
    UIBarButtonItem *eraserItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Eraser"]
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(toolSelected:)];
    eraserItem.tag = SLEraserDrawing;
    UIBarButtonItem *lineItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Line"]
                                                                 style:UIBarButtonItemStylePlain
                                                                target:self
                                                                action:@selector(toolSelected:)];
    lineItem.tag = SLLineDrawing;
    UIBarButtonItem *rectangleItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@""]
                                                                      style:UIBarButtonItemStylePlain
                                                                     target:self
                                                                     action:@selector(toolSelected:)];
    rectangleItem.tag = SLRectangleDrawing;
    UIBarButtonItem *ellipseItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Ellipse"]
                                                                    style:UIBarButtonItemStylePlain
                                                                   target:self
                                                                   action:@selector(toolSelected:)];
    ellipseItem.tag = SLEllipseDrawing;
    UIBarButtonItem *imageItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Image"]
                                                                  style:UIBarButtonItemStylePlain
                                                                 target:self
                                                                 action:@selector(toolSelected:)];
    imageItem.tag = SLImageDrawing;
    // Struts and springs
    self.toolbarItems = @[
            undoItem,
            [UIBarButtonItem flexibleSpace],
            redoItem,
            [UIBarButtonItem flexibleSpace],
            brushItem,
            [UIBarButtonItem flexibleSpace],
            lineItem,
            [UIBarButtonItem flexibleSpace],
            rectangleItem,
            [UIBarButtonItem flexibleSpace],
            ellipseItem,
            [UIBarButtonItem flexibleSpace],
            imageItem,
            [UIBarButtonItem flexibleSpace],
            eraserItem
    ];
    self.navigationController.navigationBarHidden = YES;
    self.navigationController.toolbarHidden = NO;
    // Items config
    [self updateUndoRedoItems];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
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
    // NSLog(@"Tools in context: %tu", self.toolContext.count);
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
    [self updateUndoRedoItems];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
}

#pragma mark - Handling shakes

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (motion == UIEventSubtypeMotionShake) {
        [self undoAction];
    }
}

#pragma mark - Handling all other actions

- (void)undoAction
{
    self.undoRedoInvoked = YES;
    [self.undoManager undo];
    [self updateUndoRedoItems];
}

- (void)redoAction
{
    self.undoRedoInvoked = YES;
    [self.undoManager redo];
    [self updateUndoRedoItems];
}

- (void)toolSelected:(UIBarButtonItem *)sender
{
    self.drawingMode = (SLDrawingMode) sender.tag;
}

#pragma mark - Helper methods

- (void)updateUndoRedoItems
{
    self.undoItem.enabled = self.undoManager.canUndo;
    self.redoItem.enabled = self.undoManager.canRedo;
}

- (void)setDrawingMode:(SLDrawingMode)drawingMode
{
    if (_drawingMode != drawingMode) {
        _drawingMode = drawingMode;
        // Multi-touch is available only for eraser and brush.
        self.canvasView.multipleTouchEnabled = drawingMode <= SLBrushDrawing;
    }
}

// Factory method to create tool based on the selected option
- (id<SLRasterTool>)createToolWithControlPoint:(CGPoint)controlPoint
{
    id<SLRasterTool> rasterTool = nil;
    switch (_drawingMode) {
        case SLEraserDrawing: {
            rasterTool = [[SLEraser alloc] initWithLineWidth:self.strokeSize.width initialPoint:controlPoint];
            break;
        }
        case SLBrushDrawing: {
            rasterTool = [[SLBrush alloc] initWithControlPoint:controlPoint lineWidth:self.strokeSize.width color:self.strokeColor];
            break;
        }
        case SLLineDrawing: {
            rasterTool = [[SLLine alloc] initWithControlPoint:controlPoint lineWidth:self.strokeSize.width strokeColor:self.strokeColor];
            break;
        }
        case SLRectangleDrawing: {
            rasterTool = [[SLRectangle alloc] initWithControlPoint:controlPoint lineWidth:self.strokeSize.width strokeColor:self.strokeColor];
            break;
        }
        case SLEllipseDrawing: {
            rasterTool = [[SLEllipse alloc] initWithControlPoint:controlPoint lineWidth:self.strokeSize.width strokeColor:self.strokeColor];
            break;
        }
        case SLImageDrawing: {
            rasterTool = [[SLImage alloc] initWithControlPoint:controlPoint image:[UIImage imageNamed:@"Brush"]];
            break;
        }
        case SLTextDrawing: {
            rasterTool = [[SLTextDrawer alloc] initWithControlPoint:controlPoint font:[UIFont systemFontOfSize:20]];
        }
        default:
            break;
    }
    return rasterTool;
}

- (void)drawBasedOnTouches:(NSSet *)touches commitDrawing:(BOOL)commitDrawing
{
    CGRect drawBox = CGRectNull;
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:YES];
    id<NSFastEnumeration> allTouches = commitDrawing ? [touches sortedArrayUsingDescriptors:@[sortDescriptor]] : touches;
    NSMutableArray *tools = [NSMutableArray arrayWithCapacity:touches.count];
    for (UITouch *touch in allTouches) {
        id<SLRasterTool> tool = [self.toolContext objectForKey:touch];
        tool.previousTouchLocation = [touch previousLocationInView:self.canvasView];
        tool.touchLocation = [touch locationInView:self.canvasView];
        tool.commitDrawing = commitDrawing;
        drawBox = CGRectUnion(drawBox, [tool boundingBox]);
        [tools addObject:tool];
    }
    if (!(CGRectIsEmpty(drawBox) || CGRectIsNull(drawBox))) {
        if (commitDrawing) {
            [self saveUsedTools:tools];
        }
        [self.canvasView updateCanvasWithTools:tools inRect:drawBox];
    }
}

#pragma mark - Undo/redo management - Command pattern + NSUndoManager

/**
* Some support for future undo/redo. General notes are here:
*   1. http://stackoverflow.com/questions/1907715/how-to-use-nsundomanager-with-a-uiimageview-or-cgcontext
*   CGContexts have no support for undo/redo operations - need to reproduce them using cached images
*/

- (void)saveUsedTools:(NSArray *)tools
{
    NSInvocation *saveInvocation = [self invocationWithTools:tools isUndoCall:NO];
    NSInvocation *popInvocation = [self invocationWithTools:tools isUndoCall:YES];
    [self executeInvocation:saveInvocation withUndoInvocation:popInvocation];
}

- (void)redrawUsingTools:(NSArray *)tools undoDrawing:(BOOL)undoDrawing
{
    if (undoDrawing) {
        [self.usedTools removeObjectsInArray:tools];
    } else {
        [self.usedTools addObjectsFromArray:tools];
    }
    if (self.undoRedoInvoked) {
        self.undoRedoInvoked = NO;
        [self.canvasView clear];
        [self.canvasView updateCanvasWithTools:self.usedTools inRect:self.canvasView.bounds];
    }
}

- (NSInvocation *)invocationWithTools:(NSArray *)tools isUndoCall:(BOOL)isUndoCall
{
    SEL aSel = @selector(redrawUsingTools:undoDrawing:);
    NSMethodSignature *signature = [self methodSignatureForSelector:aSel];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    invocation.target = self;
    invocation.selector = aSel;
    [invocation setArgument:&tools atIndex:2];
    [invocation setArgument:&isUndoCall atIndex:3];
    return invocation;
}

- (void)executeInvocation:(NSInvocation *)invocation
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