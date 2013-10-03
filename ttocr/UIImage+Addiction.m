//
//  UIImage+Addiction.m
//  ttocr
//
//  Created by mengxipeng on 25/8/12.
//  Copyright (c) 2012 mengxipeng. All rights reserved.
//

#import "UIImage+Addiction.h"

@implementation UIImage (Addiction)


- (UIImage*)croppedImageWithImage:(CGRect)croppedRect
{

    // Grab our original image
  
    
    // Make a new bounding rectangle including our crop
    
    // Create a new image in quartz with our new bounds and original image
    CGImageRef tmp = CGImageCreateWithImageInRect([self CGImage], croppedRect);
    
    // Pump our cropped image back into a UIImage object
    UIImage *newImage = [UIImage imageWithCGImage:tmp];
    
    // Be good memory citizens and release the memory
    CGImageRelease(tmp);
    
    return newImage;

}

@end
