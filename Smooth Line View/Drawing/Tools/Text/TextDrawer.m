//
// Created with JetBrains AppCode.
// User: yvorontsov
// Date: 06.06.12
// Time: 20:12
// Copyright: ${COMPANY}
//


#import "TextDrawer.h"


@implementation TextDrawer
{
}
@synthesize centerPoint = _centerPoint;
@synthesize text = _text;
@synthesize font = _font;

- (CGRect)boundingRect
{
    CGSize textSize = [_text sizeWithFont:_font];
    return CGRectMake(_centerPoint.x - textSize.width/2, _centerPoint.y - textSize.height/2, textSize.width, textSize.height);
}

- (void)drawInContext:(CGContextRef)context
{
    [_text drawInRect:[self boundingRect] withFont:_font lineBreakMode:UILineBreakModeTailTruncation];
}

@end