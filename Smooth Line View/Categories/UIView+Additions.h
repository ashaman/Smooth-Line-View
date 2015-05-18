//
// Created by Yaroslav Vorontsov on 02.07.14.
// Copyright (c) 2014 Yaroslav Vorontsov. All rights reserved.
//

@import UIKit;

@interface UIView (Additions)
- (void)pinToSuperview;
- (void)pinToSuperviewWithInsets:(UIEdgeInsets)insets;
- (UIView *)firstResponderView;
@end