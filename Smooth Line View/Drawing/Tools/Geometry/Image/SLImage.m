//
// Created by Yaroslav Vorontsov on 29.05.15.
// Copyright (c) 2015 Yaroslav Vorontsov. All rights reserved.
//

#import "SLImage.h"


@implementation SLImage
{

}

- (instancetype)initWithControlPoint:(CGPoint)point image:(UIImage *)image
{
    if ((self = [super initWithControlPoint:point])) {
        _image = image;
        self.strokeWidth = 1.0f;
        self.strokeColor = [UIColor redColor];
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
            [self.image drawInRect:self.boundingBox];
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