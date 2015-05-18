//
// Created with JetBrains AppCode.
// User: yvorontsov
// Date: 06.06.12
// Time: 20:12
// Copyright: ${COMPANY}
//


#import <Foundation/Foundation.h>


@interface TextDrawer : NSObject
@property (nonatomic, assign) CGPoint centerPoint;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, strong) UIFont *font;
- (CGRect) boundingRect;
- (void) drawInContext:(CGContextRef)context;
@end