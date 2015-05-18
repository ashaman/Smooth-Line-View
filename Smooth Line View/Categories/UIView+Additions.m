//
// Created by Yaroslav Vorontsov on 02.07.14.
// Copyright (c) 2014 Yaroslav Vorontsov. All rights reserved.
//

#import "UIView+Additions.h"


@implementation UIView (Additions)

- (void)pinToSuperview
{
    if (self.superview)
    {
        UIView *aView = self;
        aView.translatesAutoresizingMaskIntoConstraints = NO;
        self.frame = self.superview.bounds;
        [self.superview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[aView]|"
                                                                               options:NSLayoutFormatAlignAllBaseline
                                                                               metrics:nil
                                                                                 views:NSDictionaryOfVariableBindings(aView)]];
        [self.superview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[aView]|"
                                                                               options:NSLayoutFormatAlignAllBaseline
                                                                               metrics:nil
                                                                                 views:NSDictionaryOfVariableBindings(aView)]];
    }
}

- (void)pinToSuperviewWithInsets:(UIEdgeInsets)insets
{
    if (self.superview)
    {
        UIView *aView = self;
        aView.translatesAutoresizingMaskIntoConstraints = NO;
        self.frame = self.superview.bounds;
        NSString *horizontalFormat = [NSString stringWithFormat:@"H:|-%.0f-[aView]-%.0f-|", insets.left, insets.right];
        [self.superview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:horizontalFormat
                                                                               options:NSLayoutFormatAlignAllBaseline
                                                                               metrics:nil
                                                                                 views:NSDictionaryOfVariableBindings(aView)]];
        NSString *verticalFormat = [NSString stringWithFormat:@"V:|-%.0f-[aView]-%.0f-|", insets.top, insets.bottom];
        [self.superview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:verticalFormat
                                                                               options:NSLayoutFormatAlignAllBaseline
                                                                               metrics:nil
                                                                                 views:NSDictionaryOfVariableBindings(aView)]];

    }
}


- (UIView *)firstResponderView
{
    if (self.isFirstResponder)
        return self;
    for (UIView *subView in self.subviews)
    {
        UIView *firstResponder = [subView firstResponderView];
        if (firstResponder != nil)
            return firstResponder;
    }
    return nil;
}


@end