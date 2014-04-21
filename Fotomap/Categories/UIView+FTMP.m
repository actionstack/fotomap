//
//  UIView+FTMP.m
//  Fotomap
//
//  Created by Matt Quiros on 4/21/14.
//  Copyright (c) 2014 Action Stack. All rights reserved.
//

#import "UIView+FTMP.h"

@implementation UIView (FTMP)

- (CGFloat)width
{
    return self.frame.size.width;
}

- (CGFloat)height
{
    return self.frame.size.height;
}

- (void)centerFrameInParent:(UIView *)parent
{
    CGFloat centerX = [parent width] / 2 - [self width] / 2;
    CGFloat centerY = [parent height] / 2 - [self height] / 2;
    self.frame = CGRectMake(centerX, centerY, [self width], [self height]);
}

@end
