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
    CGMutablePathRef _path;
    CGPoint _initialPoint;
    CGPoint _previousLocation;
    CGPoint _newLocation;
    CGFloat _lineWidth;
}
@synthesize previousTouchLocation = _previousLocation, touchLocation = _newLocation;
@synthesize commitDrawing;

#pragma mark - Initialization and memory management

- (instancetype)initWithLineWidth:(CGFloat)lineWidth initialPoint:(CGPoint)point
{
    if ((self = [super init])) {
        _lineWidth = lineWidth;
    }
    return self;
}

- (void)dealloc
{
    CGPathRelease(_path);
}

#pragma mark - Helpers

- (CGPathRef)path
{
    if (!_path) {
        _path = CGPathCreateMutable();
        CGPathMoveToPoint(_path, NULL, _previousLocation.x, _previousLocation.y);
        CGPathAddLineToPoint(_path, NULL, _newLocation.x, _newLocation.y);
    }
    return _path;
}

#pragma mark - Protocol implementation

- (CGRect)boundingBox
{
    return CGRectInset(CGPathGetBoundingBox(self.path), - _lineWidth * 2, - _lineWidth * 2);
}

- (void)drawInContext:(CGContextRef)context
{
    CGContextSaveGState(context); {
        CGContextSetBlendMode(context, kCGBlendModeClear);
        if (self.commitDrawing && CGPointEqualToPoint(_initialPoint, _newLocation)) {
            // One-point touch
            CGPoint location = CGPointMake(_initialPoint.x - _lineWidth / 2.0f, _initialPoint.y - _lineWidth / 2.0f);
            CGRect frame = (CGRect){ location, CGSizeMake(_lineWidth, _lineWidth)};
            CGContextFillEllipseInRect(context, frame);
        } else {
            // Continuous line
            CGContextAddPath(context, self.path);
            CGContextSetLineCap(context, kCGLineCapRound);
            CGContextSetLineWidth(context, _lineWidth);
            CGContextStrokePath(context);
            CGPathRelease(_path);
            _path = nil;
        }
    } CGContextRestoreGState(context);
}


@end
