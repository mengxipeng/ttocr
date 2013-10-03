//
//  ViewController.h
//  ttocr
//
//  Created by mengxipeng on 21/8/12.
//  Copyright (c) 2012 mengxipeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>

#import <AVFoundation/AVFoundation.h>

#include <Accelerate/Accelerate.h>
#include <iAd/iAd.h>
#import "MBProgressHUD.h"



@interface ViewController : UIViewController<UIImagePickerControllerDelegate, UINavigationBarDelegate,UINavigationControllerDelegate, NSURLConnectionDelegate, UIGestureRecognizerDelegate, UIAlertViewDelegate, UIActionSheetDelegate, ADBannerViewDelegate, MBProgressHUDDelegate>

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

}
- (IBAction)callCameraFun:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *capturedImage;
@property (strong, nonatomic) MBProgressHUD* mbProgressHUD;

//@property (strong, nonatomic) ADBannerView* bannerView;



@end
