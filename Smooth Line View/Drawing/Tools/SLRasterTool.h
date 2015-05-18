//
//  PrimitiveContext.h
//  Smooth Line View
//
//  Created by Yaroslav Vorontsov on 06.06.12.
//  Copyright (c) 2012 Yaroslav Vorontsov. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
* Several notes on freehand drawing:
*
*   1. http://stackoverflow.com/questions/10797037/smoother-freehand-drawing-experience-ios
*   2. http://code.tutsplus.com/tutorials/ios-sdk_freehand-drawing--mobile-13164
*   3. http://www.effectiveui.com/blog/2011/12/02/how-to-build-a-simple-painting-app-for-ios/
*/


@protocol SLRasterTool <NSObject>
@property(assign, nonatomic, readonly) CGRect boundingBox;
@property(assign, nonatomic) CGPoint previousTouchLocation;
@property(assign, nonatomic) CGPoint touchLocation;
@property(assign, nonatomic) BOOL commitDrawing;
- (void)drawInContext:(CGContextRef)context;
@end
