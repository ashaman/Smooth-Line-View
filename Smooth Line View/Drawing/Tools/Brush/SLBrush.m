//
//  LineContext.m
//  Smooth Line View
//
//  Created by Yaroslav Vorontsov on 06.06.12.
//  Copyright (c) 2012 Yaroslav Vorontsov. All rights reserved.
//

#import "SLBrush.h"

static inline CGPoint midPoint(CGPoint p1, CGPoint p2) {
    return CGPointMake((p1.x + p2.x) * 0.5f, (p1.y + p2.y) * 0.5f);
}

@interface SLBrush ()
@property(nonatomic, assign, readonly) CGPoint bezierControlPoint;
@property(nonatomic, assign, readonly) CGPoint bezierPoint1;
@property(nonatomic, assign, readonly) CGPoint bezierPoint2;
@end

@implementation SLBrush
{
    UIColor *_lineColor;
    CGPoint _initialPoint;
    CGPoint _point1;
    CGPoint _point2;
    CGPoint _point3;
    CGFloat _lineWidth;
    CGMutablePathRef _path;
}
@synthesize bezierControlPoint = _point2;
@synthesize touchLocation = _point3, previousTouchLocation = _point1;
@synthesize commitDrawing;

- (instancetype)initWithControlPoint:(CGPoint)controlPoint
                           lineWidth:(CGFloat)lineWidth
                               color:(UIColor *)color
{
    if ((self = [super init])) {
        _initialPoint = controlPoint;
        _point1 = controlPoint;
        _point2 = controlPoint;
        _point3 = controlPoint;
        _lineWidth = lineWidth;
        _lineColor = color;
    }
    return self;
}

- (void)setPreviousTouchLocation:(CGPoint)location
{
    _point1 = _point2;
    _point2 = location;
    _bezierPoint1 = midPoint(_point1, _point2);
}

- (void)setTouchLocation:(CGPoint)location
{
    _point3 = location;
    _bezierPoint2 = midPoint(_point2, _point3);
}

- (CGPathRef)path
{
    if (!_path) {
        _path = CGPathCreateMutable();
        CGPathMoveToPoint(_path, NULL, self.bezierPoint1.x, self.bezierPoint1.y);
        CGPathAddQuadCurveToPoint(_path, NULL, self.bezierControlPoint.x, self.bezierControlPoint.y, self.bezierPoint2.x, self.bezierPoint2.y);
    }
    return _path;
}

- (CGRect)boundingBox
{
    // compute the rect containing the new segment plus padding for drawn line
    return CGRectInset(CGPathGetBoundingBox(self.path), - _lineWidth * 2, - _lineWidth * 2);
}

- (void)drawInContext:(CGContextRef)context
{
    CGContextSaveGState(context); {
        CGContextSetStrokeColorWithColor(context, _lineColor.CGColor);
        if (self.commitDrawing && CGPointEqualToPoint(_initialPoint, _point3)) {
            // One-point touch
            CGPoint location = CGPointMake(_initialPoint.x - _lineWidth / 2.0f, _initialPoint.y - _lineWidth / 2.0f);
            CGRect frame = (CGRect){ location, CGSizeMake(_lineWidth, _lineWidth)};
            CGContextFillEllipseInRect(context, frame);
        } else {
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