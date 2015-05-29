//
// Created with JetBrains AppCode.
// User: yvorontsov
// Date: 06.06.12
// Time: 20:12
// Copyright: ${COMPANY}
//


#import <Foundation/Foundation.h>
#import "SLRasterTool.h"
#import "SLGeometryPrimitive.h"


@interface SLTextDrawer : SLGeometryPrimitive
@property (strong, nonatomic) UIFont *font;
@property (copy, nonatomic) NSString *text;
- (instancetype)initWithControlPoint:(CGPoint)controlPoint font:(UIFont *)font;
@end