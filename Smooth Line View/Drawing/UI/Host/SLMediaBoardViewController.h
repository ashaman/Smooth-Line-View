//
// Created by Yaroslav Vorontsov on 13.05.15.
// Copyright (c) 2015 Yaroslav Vorontsov. All rights reserved.
//

@import UIKit;

typedef enum
{
    SLEraserDrawing = -1,
    SLBrushDrawing = 0,
    SLLineDrawing,
    SLRectangleDrawing,
    SLEllipseDrawing,
    SLImageDrawing,
    SLTextDrawing,
} SLDrawingMode;

@interface SLMediaBoardViewController : UIViewController
@end