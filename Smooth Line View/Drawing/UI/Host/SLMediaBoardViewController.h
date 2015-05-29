//
// Created by Yaroslav Vorontsov on 13.05.15.
// Copyright (c) 2015 Yaroslav Vorontsov. All rights reserved.
//

@import UIKit;

typedef enum
{
    SLBrushDrawing = 0,
    SLLineDrawing,
    SLEllipseDrawing,
    SLRectangleDrawing,
    SLTextDrawing,
    SLEraserDrawing
} SLDrawingMode;

@interface SLMediaBoardViewController : UIViewController
@end