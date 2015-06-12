//
//  EraserContext.m
//  Smooth Line View
//
//  Created by Yaroslav Vorontsov on 06.06.12.
//  Copyright (c) 2012 Yaroslav Vorontsov. All rights reserved.
//

#import "SLEraser.h"

@implementation SLEraser
{
    CGPoint _initialPoint;
    CGPoint _previousLocation;
    CGPoint _newLocation;
    CGFloat _lineWidth;
    CGMutablePathRef _path;
    CGMutablePathRef _fullPath;
}
@synthesize previousTouchLocation = _previousLocation, touchLocation = _newLocation;
@synthesize commitDrawing;

#pragma mark - Initialization and memory management

- (instancetype)initWithLineWidth:(CGFloat)lineWidth initialPoint:(CGPoint)point
{
    if ((self = [super init])) {
        _lineWidth = lineWidth;
        _fullPath = CGPathCreateMutable();
    }
    return self;
}

- (void)dealloc
{
    if (_path)
        CGPathRelease(_path);
    CGPathRelease(_fullPath);
}

#pragma mark - Helpers

- (CGPathRef)path
{
    if (!_path) {
        _path = CGPathCreateMutable();
        CGPathMoveToPoint(_path, NULL, _previousLocation.x, _previousLocation.y);
        CGPathAddLineToPoint(_path, NULL, _newLocation.x, _newLocation.y);
        CGPathAddPath(_fullPath, NULL, _path);
    }
    return _path;
}

#pragma mark - Protocol implementation

- (CGRect)boundingBox
{
    return CGRectInset(CGPathGetBoundingBox(self.path), - _lineWidth, - _lineWidth);
}

#if CLEANING_RECT_IN_CONTEXT
- (void)drawInContext:(CGContextRef)context inRect:(CGRect)drawRect {
    [self drawInContext:context];
}
#endif

- (void)drawInContext:(CGContextRef)context
{
    CGContextSaveGState(context); {
        CGContextSetBlendMode(context, kCGBlendModeClear);
        if (self.commitDrawing) {
            if (CGPointEqualToPoint(_initialPoint, _newLocation)) {
                // One-point touch
                CGPoint location = CGPointMake(_initialPoint.x - _lineWidth / 2.0f, _initialPoint.y - _lineWidth / 2.0f);
                CGRect frame = (CGRect){ location, CGSizeMake(_lineWidth, _lineWidth)};
                CGContextFillEllipseInRect(context, frame);
            } else {
                // Full redrawing
                CGContextAddPath(context, _fullPath);
                CGContextSetLineCap(context, kCGLineCapRound);
                CGContextSetLineWidth(context, _lineWidth);
                CGContextStrokePath(context);
            }
        } else {
            // Continuous line
#if INCREMENTAL_DRAWING
            CGContextAddPath(context, self.path);
#else
            CGContextAddPath(context, _fullPath);
#endif
            CGContextSetLineCap(context, kCGLineCapRound);
            CGContextSetLineWidth(context, _lineWidth);
            CGContextStrokePath(context);
            CGPathRelease(_path);
            _path = nil;
        }
    } CGContextRestoreGState(context);
}

@end