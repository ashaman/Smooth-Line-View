//
// Created with JetBrains AppCode.
// User: yvorontsov
// Date: 06.06.12
// Time: 20:12
// Copyright: ${COMPANY}
//


#import <Foundation/Foundation.h>
#import "SLRasterTool.h"


@interface SLTextDrawer : NSObject <SLRasterTool>
@property (strong, nonatomic) UIFont *font;
@property (strong, nonatomic) UIColor *color;
@property (copy, nonatomic) NSString *text;
- (instancetype)initWithControlPoint:(CGPoint)controlPoint font:(UIFont *)font;
@end