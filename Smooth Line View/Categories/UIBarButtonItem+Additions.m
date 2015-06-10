//
// Created by Yaroslav Vorontsov on 02.06.15.
// Copyright (c) 2015 Yaroslav Vorontsov. All rights reserved.
//

#import "UIBarButtonItem+Additions.h"


@implementation UIBarButtonItem (Additions)

+ (instancetype)flexibleSpace
{
    return [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
}

@end