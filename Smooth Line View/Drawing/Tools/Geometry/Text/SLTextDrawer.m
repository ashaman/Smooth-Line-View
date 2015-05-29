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

- (void)drawInContext:(CGContextRef)context
{
    CGContextSaveGState(context); {
        if (self.commitDrawing) {
            NSDictionary *attributes = @{
                    NSFontAttributeName: self.font
            };
            [self.text drawInRect:self.boundingBox withAttributes:attributes];
        } else {
            // Draw the bounding rect
            [self.strokeColor setStroke];
            CGContextSetLineCap(context, kCGLineCapRound);
            CGContextSetLineWidth(context, self.strokeWidth);
            CGContextStrokeRect(context, self.boundingBox);
        }
    } CGContextRestoreGState(context);
}

@end