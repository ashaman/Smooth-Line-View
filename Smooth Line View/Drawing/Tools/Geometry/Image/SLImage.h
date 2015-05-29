//
// Created by Yaroslav Vorontsov on 29.05.15.
// Copyright (c) 2015 dataart. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SLGeometryPrimitive.h"


@interface SLImage : SLGeometryPrimitive
@property (strong, nonatomic, readonly) UIImage *image;
- (instancetype)initWithControlPoint:(CGPoint)point image:(UIImage *)image;
@end