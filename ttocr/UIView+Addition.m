//
//  UIView+Addition.m
//  ttocr
//
//  Created by mengxipeng on 25/8/12.
//  Copyright (c) 2012 mengxipeng. All rights reserved.
//

#import "UIView+Addition.h"

@implementation UIView (Addition)

- (UIImage *)imageByRenderingView
{
    UIGraphicsBeginImageContext(self.bounds.size);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resultingImage;
}

@end
