//
// Created by Yaroslav Vorontsov on 29.05.15.
// Copyright (c) 2015 Yaroslav Vorontsov. All rights reserved.
//

#import "SLEllipse.h"

@implementation SLEllipse

- (void)drawInContext:(CGContextRef)context
{
    CGContextSaveGState(context); {

        [self.strokeColor setStroke];
        CGContextSetLineWidth(context, self.strokeWidth);
        CGContextStrokeEllipseInRect(context, self.boundingBox);
    } CGContextRestoreGState(context);
}

#if CLEANING_RECT_IN_CONTEXT
- (void)drawInContext:(CGContextRef)context inRect:(CGRect)drawRect {
    CGContextSaveGState(context); {
        CGContextClearRect(context, drawRect);
        
        [self.strokeColor setStroke];
        CGContextSetLineWidth(context, self.strokeWidth);
        CGContextStrokeEllipseInRect(context, self.boundingBox);
        
    } CGContextRestoreGState(context);
    
}
#endif

@end