//
// Created by Yaroslav Vorontsov on 29.05.15.
// Copyright (c) 2015 Yaroslav Vorontsov. All rights reserved.
//

#import "SLLine.h"


@implementation SLLine
{

}

#if CLEANING_RECT_IN_CONTEXT
- (void)drawInContext:(CGContextRef)context inRect:(CGRect)drawRect {
    [self drawInContext:context];
}
#endif

- (void)drawInContext:(CGContextRef)context
{
    CGContextSaveGState(context); {
        // Line properties
        [self.strokeColor setStroke];
        CGContextSetLineCap(context, kCGLineCapRound);
        CGContextSetLineWidth(context, self.strokeWidth);
        // Drawing itself
        CGContextMoveToPoint(context, self.initialPoint.x, self.initialPoint.y);
        CGContextAddLineToPoint(context, self.touchLocation.x, self.touchLocation.y);
        CGContextStrokePath(context);
    } CGContextRestoreGState(context);
}

@end