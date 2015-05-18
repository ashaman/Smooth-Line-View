//
//  EraserContext.h
//  Smooth Line View
//
//  Created by Yaroslav Vorontsov on 06.06.12.
//  Copyright (c) 2012 Yaroslav Vorontsov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SLRasterTool.h"

@interface SLEraser : NSObject  <SLRasterTool>
- (instancetype)initWithLineWidth:(CGFloat)lineWidth initialPoint:(CGPoint)point;
@end
