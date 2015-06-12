//
// Created with JetBrains AppCode.
// User: yvorontsov
// Date: 06.06.12
// Time: 20:12
// Copyright:
//

// Code partially taken from ACEDrawingView
/*
 * ACEDrawingView: https://github.com/acerbetti/ACEDrawingView
 *
 * Copyright (c) 2013 Stefano Acerbetti
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 */

#import "SLTextDrawer.h"

#ifndef FABS
    #ifdef __LP64__
        #define FABS fabs
    #else
        #define FABS fabsf
    #endif
#endif


@implementation SLTextDrawer
@synthesize previousTouchLocation, touchLocation, commitDrawing;

- (instancetype)initWithControlPoint:(CGPoint)controlPoint font:(UIFont *)font
{
    if ((self = [super initWithControlPoint:controlPoint])) {
        self.strokeWidth = 1.0f;
        self.font = font;
        self.strokeColor = [UIColor blackColor];
        self.text = @"Just for test and fun :)";
    }
    return self;
}
#if CLEANING_RECT_IN_CONTEXT
- (void)drawInContext:(CGContextRef)context inRect:(CGRect)drawRect {
    [self drawInContext:context];
}
#endif

- (void)drawInContext:(CGContextRef)context
{
    CGContextSaveGState(context); {
        if (self.commitDrawing) {
            NSDictionary *attributes = @{
                    NSFontAttributeName: self.font
            };
            NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:self.text attributes:attributes];
            [attributedString drawInRect:self.boundingBox];
            // Alternative way is listed below
        } else {
            // Draw the bounding rect
            [self.strokeColor setStroke];
            CGContextSetLineCap(context, kCGLineCapRound);
            CGContextSetLineWidth(context, self.strokeWidth);
            CGContextStrokeRect(context, self.boundingBox);
        }
    } CGContextRestoreGState(context);
}

/*
- (void)draw
{
    // draw the text
    // Flip the context coordinates, in iOS only.
    CGContextTranslateCTM(context, 0, viewBounds.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);

    // Set the text matrix.
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);

    // Create a path which bounds the area where you will be drawing text.
    // The path need not be rectangular.
    CGMutablePathRef path = CGPathCreateMutable();

    // In this simple example, initialize a rectangular path.
    CGRect bounds = CGRectMake(viewBounds.origin.x, -viewBounds.origin.y, viewBounds.size.width, viewBounds.size.height);
    CGPathAddRect(path, NULL, bounds );

    // Create the framesetter with the attributed string.
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)self.attributedText);

    // Create a frame.
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);

    // Draw the specified frame in the given context.
    CTFrameDraw(frame, context);

    // Release the objects we used.
    CFRelease(frame);
    CFRelease(framesetter);
    CFRelease(path);
}
 */

@end