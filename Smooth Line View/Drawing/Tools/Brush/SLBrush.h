//
//  LineContext.h
//  Smooth Line View
//
//  Created by Yaroslav Vorontsov on 06.06.12.
//  Copyright (c) 2012 Yaroslav Vorontsov. All rights reserved.
//

@import Foundation;
@import QuartzCore;
#import "SLRasterTool.h"

@interface SLBrush : NSObject <SLRasterTool>
- (instancetype)initWithControlPoint:(CGPoint)controlPoint
                           lineWidth:(CGFloat)lineWidth
                               color:(UIColor *)color;
@end
