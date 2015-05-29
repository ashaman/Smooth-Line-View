//
// Created by Yaroslav Vorontsov on 29.05.15.
// Copyright (c) 2015 Yaroslav Vorontsov. All rights reserved.
//

#import "SLRectangle.h"


@implementation SLRectangle

- (void)drawInContext:(CGContextRef)context
{
    CGContextSaveGState(context); {
        [self.strokeColor setStroke];
        CGContextSetLineWidth(context, self.strokeWidth);
        CGContextStrokeRect(context, self.boundingBox);
    } CGContextRestoreGState(context);
}

@end