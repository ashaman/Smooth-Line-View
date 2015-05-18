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
@property(strong, nonatomic) NSArray *drawingTools;
@property(strong, nonatomic) UIImage *incrementalImage;
@end

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
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self.incrementalImage drawAtPoint:CGPointMake(0, 0)];
    [self.layer renderInContext:context];
    // Drawing all primitives where necessary
    for (id<SLRasterTool> tool in self.drawingTools) {
        [tool drawInContext:context];
    }
    [super drawRect:rect];
}


- (void)updateCanvasWithTools:(NSMutableArray *)tools inRect:(CGRect)drawBox
{
    self.drawingTools = tools;
    UIGraphicsBeginImageContext(drawBox.size);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    self.incrementalImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [self setNeedsDisplayInRect:drawBox];
}

@end