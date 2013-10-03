//
//  PreviewVideoViewController.h
//  ttocr
//
//  Created by mengxipeng on 24/8/12.
//  Copyright (c) 2012 mengxipeng. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <AVFoundation/AVFoundation.h> 
#import <ImageIO/CGImageProperties.h>

@interface PreviewVideoViewController : UIViewController

@property(nonatomic, retain) AVCaptureStillImageOutput *stillImageOutput;
@property (strong, nonatomic) IBOutlet UIView *videoPreview;
@property (strong, nonatomic) IBOutlet UIImageView *videoImage;
-(IBAction)captureScreen:(id)sender;

@end
