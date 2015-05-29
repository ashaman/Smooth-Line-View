//  The MIT License (MIT)
//
//  Copyright (c) 2013 Levi Nunnink
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of
//  this software and associated documentation files (the "Software"), to deal in
//  the Software without restriction, including without limitation the rights to
//  use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
//  the Software, and to permit persons to whom the Software is furnished to do so,
//  subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
//  FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
//  COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
//  IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
//  CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

//
//  Created by Levi Nunnink (@a_band) http://culturezoo.com
//  Copyright (C) Droplr Inc. All Rights Reserved
//

//
//  Portions of code and significant changes made by Yaroslav Vorontsov
//  Copyright (C) Yaroslav Vorontsov. All Rights Reserved.
//

#import "SLSmoothLineView.h"
#import "SLRasterTool.h"

@interface SLSmoothLineView ()
@property (strong, nonatomic) NSArray *drawingTools;
#if INCREMENTAL_DRAWING
@property (strong, nonatomic) UIImage *incrementalImage;
@property (assign, nonatomic) BOOL clearCanvas;
#else
@property (strong, nonatomic) UIImage *fullImage;
#endif
@end

/**
* This view is backed up by a bitmap cache (UIImage)
* Idea is taken from ACEDrawingView - https://github.com/acerbetti/ACEDrawingView
*
* Initial incremental drawing has some issues inside (already drawn lines become thicker by some reason) - need to
* investigate them. Moreover, bitmap-backed implementation is better for resizable rectangles/lines/ellipses/etc.
*/
@implementation SLSmoothLineView
{
}


/***
* 1. https://developer.apple.com/library/ios/qa/qa1708/_index.html
* Q&A on how to speedup drawing performance
*
* 2. http://stackoverflow.com/questions/9809306/calayer-setneedsdisplayinrect-causes-the-whole-layer-to-be-redrawn
* CALayer drawing performance
*
* 3. http://www.effectiveui.com/blog/2011/12/02/how-to-build-a-simple-painting-app-for-ios/
* Simple painting app backed by in-memory bitmaps
*
* 4. http://stackoverflow.com/questions/11312135/uibezierpath-array-rendering-issue-how-to-use-cglayerref-for-optimization
* How to use CGLayerRef for drawing optimizations (may be a bit deprecated)
*/
- (void)drawRect:(CGRect)rect
{
#if INCREMENTAL_DRAWING
    if (self.clearCanvas) {
        // Clear mode
        [self.backgroundColor set];
        UIRectFill(rect);
        self.clearCanvas = NO;
    } else {
        // Ordinary drawing mode - partial update
        CGContextRef context = UIGraphicsGetCurrentContext();
        [self.incrementalImage drawAtPoint:CGPointMake(0, 0)];
        [self.layer renderInContext:context];
        [self drawWithTools];
    }
#else
    // Ordinary drawing mode - full image
    [self.fullImage drawInRect:self.bounds];
    [self drawWithTools];
#endif
}

- (void)updateCanvasWithTools:(NSMutableArray *)tools
#if INCREMENTAL_DRAWING
                       inRect:(CGRect)drawBox
#else
                       inRect:(CGRect __unused)drawBox
#endif
{
#if INCREMENTAL_DRAWING
    self.drawingTools = tools;
    UIGraphicsBeginImageContext(drawBox.size);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    self.incrementalImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [self setNeedsDisplayInRect:drawBox];
#else
    self.drawingTools = tools;
    [self setNeedsDisplay];
    // Determining if tools are committed.
    // Since they're changed altogether, it's enough to check the 1st value in the array
    if ([self.drawingTools.firstObject commitDrawing]) {
        [self updateBitmapWithInvalidation:NO];
    }
#endif
}

- (void)updateBitmapWithInvalidation:(BOOL)redraw
{
    // Image context
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0.0);
    if (redraw) {
        // Erase the previous image and redraw all lines
        self.fullImage = nil;
    } else {
        // set the draw point
        [self.fullImage drawAtPoint:CGPointZero];
    }
    // apply the tools and store the image
    [self drawWithTools];
    self.fullImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}

- (void)drawWithTools
{
    // Drawing all primitives
    CGContextRef context = UIGraphicsGetCurrentContext();
    for (id<SLRasterTool> tool in self.drawingTools) {
        [tool drawInContext:context];
    }
}

- (void)clear
{
#if INCREMENTAL_DRAWING
    self.clearCanvas = YES;
#else
    self.drawingTools = nil;
    [self updateBitmapWithInvalidation:YES];
#endif
    [self setNeedsDisplay];
}

@end