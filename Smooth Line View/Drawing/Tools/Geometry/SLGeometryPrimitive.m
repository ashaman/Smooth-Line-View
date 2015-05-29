//
// Created by Yaroslav Vorontsov on 29.05.15.
// Copyright (c) 2015 Yaroslav Vorontsov. All rights reserved.
//

#import "SLGeometryPrimitive.h"

// To suppress compiler's warning
#ifndef FABS
    #ifdef __LP64__
        #define FABS fabs
    #else
        #define FABS fabsf
    #endif
#endif

@implementation SLGeometryPrimitive
@synthesize touchLocation, previousTouchLocation, commitDrawing;

- (instancetype)initWithControlPoint:(CGPoint)controlPoint
{
    if ((self = [super init])) {
        _initialPoint = controlPoint;
    }
    return self;
}

- (instancetype)initWithControlPoint:(CGPoint)controlPoint
                           lineWidth:(CGFloat)lineWidth
                         strokeColor:(UIColor *)strokeColor
{
    if ((self = [self initWithControlPoint:controlPoint])) {
        self.strokeWidth = lineWidth;
        self.strokeColor = strokeColor;
    }
    return self;
}

- (instancetype)initWithControlPoint:(CGPoint)controlPoint fillColor:(UIColor *)fillColor
{
    if ((self = [self initWithControlPoint:controlPoint])) {
        self.fillColor = fillColor;
    }
    return self;
}

- (CGRect)boundingBox
{
    return CGRectMake(MIN(_initialPoint.x, self.touchLocation.x),
            MIN(_initialPoint.y, self.touchLocation.y),
            FABS(_initialPoint.x - self.touchLocation.x),
            FABS(_initialPoint.y - self.touchLocation.y));
}

- (void)drawInContext:(CGContextRef)context
{
    // Empty implementation which should be overridden in subclasses
    NSAssert(NO, @"Method %s should be overridden in subclasses", __PRETTY_FUNCTION__);
}

@end