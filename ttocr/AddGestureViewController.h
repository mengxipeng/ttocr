//
//  AddGestureViewController.h
//  ttocr
//
//  Created by mengxipeng on 24/8/12.
//  Copyright (c) 2012 mengxipeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#include "baseapi.h"

@interface AddGestureViewController : UIViewController<UIGestureRecognizerDelegate>

{
    CGFloat _lastScale;
	CGFloat _lastRotation;
	CGFloat _firstX;
	CGFloat _firstY;
    
    CGFloat _drawStartX;
    CGFloat _drawStartY;
    
    CGRect _markRect;
    
    CGPoint _lastLocation;
    
    CAShapeLayer *_marque;
    
    tesseract::TessBaseAPI* tess;
}

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
//@property (strong, nonatomic) UIImage* image;

@end
