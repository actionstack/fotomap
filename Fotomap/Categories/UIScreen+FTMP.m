//
//  UIScreen+FTMP.m
//  Fotomap
//
//  Created by Matt Quiros on 4/21/14.
//  Copyright (c) 2014 Action Stack. All rights reserved.
//

#import "UIScreen+FTMP.h"

@implementation UIScreen (FTMP)

+ (CGFloat)width
{
    return [[UIScreen mainScreen] bounds].size.width;
}

+ (CGFloat)height
{
    return [[UIScreen mainScreen] bounds].size.height;
}

@end
