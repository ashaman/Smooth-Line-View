//
// Created by Yaroslav Vorontsov on 29.05.15.
// Copyright (c) 2015 Yaroslav Vorontsov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SLRasterTool.h"


@interface SLGeometryPrimitive : NSObject <SLRasterTool>
@property (strong, nonatomic) UIColor *strokeColor;
@property (strong, nonatomic) UIColor *fillColor;
@property (assign, nonatomic, readonly) CGPoint initialPoint;
@property (assign, nonatomic) CGFloat strokeWidth;
- (instancetype)initWithControlPoint:(CGPoint)controlPoint;
- (instancetype)initWithControlPoint:(CGPoint)controlPoint
                           lineWidth:(CGFloat)lineWidth
                         strokeColor:(UIColor *)strokeColor;
- (instancetype)initWithControlPoint:(CGPoint)controlPoint
                           fillColor:(UIColor *)fillColor;
@end