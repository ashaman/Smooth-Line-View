//
// Created by Yaroslav Vorontsov on 29.05.15.
// Copyright (c) 2015 Yaroslav Vorontsov. All rights reserved.
//

#import "SLEllipse.h"
// To suppress compiler's warning
#ifndef FABS
#ifdef __LP64__
#define FABS fabs
#else
#define FABS fabsf
#endif
#endif

@implementation SLEllipse

- (void)drawInContext:(CGContextRef)context
{
    CGContextSaveGState(context); {
        
#if CLEANING_RECT_IN_CONTEXT
        CGRect prevBox = CGRectMake(MIN(self.initialPoint.x, self.previousTouchLocation.x) - self.strokeWidth/2.0,
                                    MIN(self.initialPoint.y, self.previousTouchLocation.y) - self.strokeWidth/2.0,
                                    FABS(self.initialPoint.x - self.previousTouchLocation.x) + self.strokeWidth,
                                    FABS(self.initialPoint.y - self.previousTouchLocation.y) + self.strokeWidth);
        
        
        CGContextClearRect(context, CGRectUnion(prevBox, self.boundingBox));
#endif
        
        [self.strokeColor setStroke];
        CGContextSetLineWidth(context, self.strokeWidth);
        CGContextStrokeEllipseInRect(context, self.boundingBox);
    } CGContextRestoreGState(context);
}

@end