//
// Created by Yaroslav Vorontsov on 29.05.15.
// Copyright (c) 2015 Yaroslav Vorontsov. All rights reserved.
//

#import "SLRectangle.h"

@implementation SLRectangle

#if CLEANING_RECT_IN_CONTEXT
- (void)drawInContext:(CGContextRef)context inRect:(CGRect)drawRect {
        CGContextSaveGState(context); {
            CGContextClearRect(context, drawRect);

            [self.strokeColor setStroke];
            CGContextSetLineWidth(context, self.strokeWidth);
            CGContextStrokeRect(context, self.boundingBox);
            
        } CGContextRestoreGState(context);
    
}
#endif
- (void)drawInContext:(CGContextRef)context
{
    CGContextSaveGState(context); {
        [self.strokeColor setStroke];
        
        CGContextSetLineWidth(context, self.strokeWidth);
        CGContextStrokeRect(context, self.boundingBox);

    } CGContextRestoreGState(context);
}

@end