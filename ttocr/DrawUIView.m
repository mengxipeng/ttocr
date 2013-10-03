//
//  DrawUIView.m
//  ttocr
//
//  Created by mengxipeng on 25/8/12.
//  Copyright (c) 2012 mengxipeng. All rights reserved.
//

#import "DrawUIView.h"

@implementation DrawUIView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        //self.contentMode=UIViewContentModeScaleToFill;
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/


/*
- (void)drawRect:(CGRect)rect {
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetLineWidth(context, 2.0);
    
    CGContextSetStrokeColorWithColor(context, [UIColor blueColor].CGColor);
    
    CGRect rectangle = CGRectMake(60,170,200,80);
    
    CGContextAddRect(context, rectangle);
    
    CGContextStrokePath(context);
}
*/

- (UIImage *)imageByRenderingView
{
    UIGraphicsBeginImageContext(self.bounds.size);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return resultingImage;
    
}

@end
