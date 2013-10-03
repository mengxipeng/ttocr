//
//  ViewController.m
//  ttocr
//
//  Created by mengxipeng on 21/8/12.
//  Copyright (c) 2012 mengxipeng. All rights reserved.
//


#import "ViewController.h"
#import "PreviewVideoViewController.h"
#import "AddGestureViewController.h"
#import "ApplicationData.h"
#import "UIView+Addition.h"
#import "UIImage+Addiction.h"
#import "Tesseract.h"
#import "AppDelegate.h"
#import "NSString+Addictioin.h"

#define TAG_CONFIRM_OCR_RESULT 1000

#define MARK_MARGIN 2.0f



@interface ViewController()

@property(nonatomic, strong) UIPopoverController* popover;
@property(nonatomic, strong) UIActionSheet* asGetImage;
@property(nonatomic, strong) UIActionSheet* asProcess;

@end

@implementation ViewController

@synthesize mbProgressHUD=_mbProgressHUD;
@synthesize popover=_popover;

@synthesize asGetImage=_asGetImage;
@synthesize asProcess=_asProcess;
//@synthesize bannerView=_bannerView;

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"recognise" style:UIBarButtonItemStylePlain target:self action: @selector(recognise:)];
  self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"photo" style:UIBarButtonItemStylePlain target:self action: @selector(getPhoto:)];
  if (!_marque) {
    _marque = [CAShapeLayer layer];
    _marque.fillColor = [[UIColor clearColor] CGColor];
    _marque.strokeColor = [[UIColor redColor] CGColor];
    _marque.lineWidth = MARK_MARGIN;
    _marque.lineJoin = kCALineJoinRound;
    _marque.lineDashPattern = [NSArray arrayWithObjects:[NSNumber numberWithInt:10],[NSNumber numberWithInt:5], nil];
    _marque.bounds = CGRectMake(0,0, self.view.frame.size.width, self.view.frame.size.height);
    _marque.position = CGPointMake(0,0);
    _marque.frame = self.view.frame;
    _marque.hidden=YES;
  }
  
  [[self.view layer] addSublayer:_marque];
  
  self.capturedImage.userInteractionEnabled=YES;
  
  UIPinchGestureRecognizer *pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(scale:)] ;
  [pinchRecognizer setDelegate:self];
  [self.view addGestureRecognizer:pinchRecognizer];
  
  UIRotationGestureRecognizer *rotationRecognizer = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotate:)] ;
  [rotationRecognizer setDelegate:self];
  [self.view addGestureRecognizer:rotationRecognizer];
  
  UIPanGestureRecognizer* panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(move:)];
  [panGestureRecognizer setDelegate:self];
  [panGestureRecognizer setMaximumNumberOfTouches:2];
  [panGestureRecognizer setMinimumNumberOfTouches:2];
  [self.view addGestureRecognizer:panGestureRecognizer];
  
  UIPanGestureRecognizer* drawPanGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(draw:)];
  [drawPanGestureRecognizer setDelegate:self];
  [drawPanGestureRecognizer setMaximumNumberOfTouches:1];
  [drawPanGestureRecognizer setMinimumNumberOfTouches:1];
  [self.view addGestureRecognizer:drawPanGestureRecognizer];
  
  CGRect rect=CGRectMake(self.view.frame.size.width/4, self.view.frame.size.height/4, self.view.frame.size.width/2, self.view.frame.size.height/2);
  _markRect = rect;
  [self showOverlayWithFrame:rect];
  [self showOverlay:NO];
  
  
  
  
//  self.bannerView = [[ADBannerView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
  // Optional to set background color to clear color
//  [self.bannerView setBackgroundColor:[UIColor clearColor]];
//  [self.view addSubview: self.bannerView];
}

-(void)viewWillAppear:(BOOL)animated{
  [super viewWillAppear:animated];
  [self becomeFirstResponder];
  self.capturedImage.center=CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2);
  self.capturedImage.transform=CGAffineTransformIdentity;
}

- (void)viewDidUnload
{
  // [self setCaptuerImageView:nil];
  [self setCapturedImage:nil];
  _marque=nil;
  [super viewDidUnload];
  // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
  } else {
    return YES;
  }
}

#pragma mark - imagepicker delegate method
-(void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info{
  
  NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
  if([mediaType isEqualToString:(NSString*)kUTTypeImage]){
    UIImage* image = [info objectForKey:UIImagePickerControllerOriginalImage];
    [self.capturedImage setImage:image];
  }
  
  if (picker.sourceType==UIImagePickerControllerSourceTypeCamera) {
    [self dismissModalViewControllerAnimated:YES];
    return;
  }
  
  if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
    [self.popover dismissPopoverAnimated:YES];
  }
  else
  {
    [self dismissModalViewControllerAnimated:YES];
  }
}

- (IBAction)getPhoto:(id)sender
{
  //[self callCameraFun:sender];
  self.asGetImage  = [[UIActionSheet alloc ] initWithTitle:nil delegate:self cancelButtonTitle:@"cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take Phto", @"Choose From Library", nil];
  [self.asGetImage showInView:self.view];
}



-(void)chooseImageFromLibrary:(id)sender
{
  
  // We are using an iPad
  UIImagePickerController *picker = [[UIImagePickerController alloc] init];
  picker.delegate = self;
  if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
    UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:picker];
    [popover presentPopoverFromRect:self.navigationController.navigationBar.bounds inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    self.popover = popover;
  } else {
    [self presentModalViewController:picker animated:YES];
  }
}



- (IBAction)callCameraFun:(id)sender {
  // debug information
  BOOL cameraAvailable = [ UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
  NSLog(@"cameraAvailable %d", cameraAvailable);
  BOOL cameraFrontAvailable = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
  NSLog(@"cameraFrontAvailable %d", cameraFrontAvailable);
  
  UIImagePickerController *picker = [[UIImagePickerController alloc] init];
  picker.delegate = (id<UINavigationControllerDelegate,UIImagePickerControllerDelegate>)self;
  if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    NSLog(@"get photo from camera");
  } else {
    picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
  }
  picker.mediaTypes = [NSArray arrayWithObjects:
                       (NSString *) kUTTypeImage,
                       nil];
  [self presentModalViewController: picker animated: YES];
}

-(void)draw:(id)sender {
  
  UIPanGestureRecognizer* drawPaneGestureRecognizer = (UIPanGestureRecognizer*)sender;
  //   CGPoint translatedPoint = [drawPaneGestureRecognizer translationInView:self.view];
  CGPoint locationPoint = [drawPaneGestureRecognizer locationInView:self.view];
  if (drawPaneGestureRecognizer.state == UIGestureRecognizerStateBegan) {
    _drawStartX = locationPoint.x;
    _drawStartY = locationPoint.y;
    return ;
  }
  
  CGFloat curX = locationPoint.x;
  CGFloat curY = locationPoint.y;
  CGFloat startX = MIN(_drawStartX, curX);
  CGFloat startY = MIN(_drawStartY, curY);
  CGFloat width  = ABS(_drawStartX-curX);
  CGFloat heigth = ABS(_drawStartY-curY);
 
  if (drawPaneGestureRecognizer.state == UIGestureRecognizerStateEnded) {
    // send whold image and user's touch to the web server
    return ;
  }
  
  [drawPaneGestureRecognizer setTranslation:CGPointMake(0, 0) inView:self.view];
  
  // draw mark line
  CGRect markRect = CGRectMake(startX, startY, width, heigth);
  _markRect = markRect;
  if (self.capturedImage.image!=nil) {
    [self showOverlay:YES];
  }
  else
    [self showOverlay:NO];
  [self showOverlayWithFrame:markRect];
}

-(void)move:(id)sender {
  CGPoint translatedPoint = [(UIPanGestureRecognizer*)sender translationInView:self.view];
  
  if([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateBegan) {
    _firstX = [self.capturedImage center].x;
    _firstY = [self.capturedImage center].y;
  }
  
  translatedPoint = CGPointMake(_firstX+translatedPoint.x, _firstY+translatedPoint.y);
  
  [self.capturedImage setCenter:translatedPoint];
}

-(void)scale:(id)sender {
  
  if([(UIPinchGestureRecognizer*)sender state] == UIGestureRecognizerStateBegan) {
    _lastScale = 1.0;
  }
  
  CGFloat scale = 1.0 - (_lastScale - [(UIPinchGestureRecognizer*)sender scale]);
  
  CGAffineTransform currentTransform = self.capturedImage.transform;
  CGAffineTransform newTransform = CGAffineTransformScale(currentTransform, scale, scale);
  
  [self.capturedImage setTransform:newTransform];
  
  _lastScale = [(UIPinchGestureRecognizer*)sender scale];
}

-(void)rotate:(id)sender {
  
  if([(UIRotationGestureRecognizer*)sender state] == UIGestureRecognizerStateEnded) {
    
    _lastRotation = 0.0;
    return;
  }
  
  CGFloat rotation = 0.0 - (_lastRotation - [(UIRotationGestureRecognizer*)sender rotation]);
  
  CGAffineTransform currentTransform = self.capturedImage.transform;
  CGAffineTransform newTransform = CGAffineTransformRotate(currentTransform,rotation);
  
  [self.capturedImage setTransform:newTransform];
  
  _lastRotation = [(UIRotationGestureRecognizer*)sender rotation];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
  return YES;
}

#pragma mark - private methods

-(void)showOverlay:(BOOL)show
{
  _marque.hidden=!show;
}

-(void)showOverlayWithFrame:(CGRect)frame {
  if (![_marque actionForKey:@"linePhase"]) {
    CABasicAnimation *dashAnimation;
    dashAnimation = [CABasicAnimation animationWithKeyPath:@"lineDashPhase"];
    [dashAnimation setFromValue:[NSNumber numberWithFloat:0.0f]];
    [dashAnimation setToValue:[NSNumber numberWithFloat:15.0f]];
    [dashAnimation setDuration:0.5f];
    [dashAnimation setRepeatCount:HUGE_VALF];
    [_marque addAnimation:dashAnimation forKey:@"linePhase"];
  }
  
  CGMutablePathRef path = CGPathCreateMutable();
  CGPathAddRect(path, NULL, frame);
  [_marque setPath:path];
  CGPathRelease(path);
  //_marque.hidden = NO;
}

-(void)saveImage:(UIImage*)image
{
  // Do something useful with the text!
  
  NSDate *currentDateTime = [NSDate date];
  
  // Instantiate a NSDateFormatter
  NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
  
  // Set the dateFormatter format
  [dateFormatter setDateFormat:@"yyyy.MM.dd.HH.mm.ss"];
  
  // Get the date time in NSString
  NSString *dateInStringFormated = [dateFormatter stringFromDate:currentDateTime];
  NSLog(@"%@", dateInStringFormated);
  
  NSString *imgDir = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:@"/imgs"];
  if (![[NSFileManager defaultManager] fileExistsAtPath:imgDir]) {
    [[NSFileManager defaultManager] createDirectoryAtPath:imgDir withIntermediateDirectories:NO attributes:nil error:nil];
  }
  NSData* imageData = [NSData dataWithData:UIImagePNGRepresentation(image)];
  //NSString* fullFileName= [[[[[imgDir stringByAppendingString:@"/"]stringByAppendingString:dateInStringFormated] stringByAppendingString:@"_"]stringByAppendingString:text] stringByAppendingString:@".png"];
  NSString* fullFileName= [[[[imgDir stringByAppendingString:@"/"]stringByAppendingString:dateInStringFormated] stringByAppendingString:@"_"] stringByAppendingString:@".png"];
  
  [imageData writeToFile:fullFileName atomically:YES];

}

-(NSString*)ocrImage:(UIImage*)uiImage
{
  Tesseract* tesseract = [[Tesseract alloc]initWithDataPath:@"tessdata" language:@"eng"];
  //Tesseract* tesseract = [[Tesseract alloc] initWithDataPath:@"tessdata" language:@"chi_sim"];
  
  if ([ApplicationData sharedApplicationData].onlyNumber) {
    [tesseract setVariableValue:@"0123456789" forKey:@"tessedit_char_whitelist" ];
//    "tessedit_char_whitelist", "abcdefghijklmnopqrstuvwxyz012345789"
  }
  
  [tesseract setImage:uiImage];
  [tesseract recognize];
  return [tesseract recognizedText];
}

- (NSString *) applicationDocumentsDirectory
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectoryPath = [paths objectAtIndex:0];
	return documentsDirectoryPath;
}

-(NSString*)doRecognise:(UIImage*)image
{
  UIImage* selectImage = [image croppedImageWithImage:CGRectMake(_markRect.origin.x+MARK_MARGIN, _markRect.origin.y+MARK_MARGIN, _markRect.size.width-2*MARK_MARGIN, _markRect.size.height-2*MARK_MARGIN)];
  
  UIImage* croppedSelectImage = selectImage;
  NSString* text  =  [self ocrImage:croppedSelectImage];
  NSLog(@"text:%@", text);
  
  UIPasteboard* pasteBoard = [UIPasteboard generalPasteboard];
  [pasteBoard setPersistent:YES];
  [pasteBoard setString:text];
  return text;
}


-(void)recognise:(id)sender
{
  
  if (self.capturedImage.image==nil || _marque.hidden==YES) {
    // show result
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning"
                                                    message:@"Please shot a photo first and adjust your photo using two figure, and draw a border using one figure."
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    return;
  }

  UIImage* viewImage = [self.view imageByRenderingView];
  NSString* __block text=[[NSString alloc]init];
  //[self startProgressHUD:@"Recongizing..."];
  self.mbProgressHUD = [[MBProgressHUD alloc] initWithWindow:self.view.window];
  [self.view.window addSubview:self.mbProgressHUD];
  self.mbProgressHUD.delegate=self;
  self.mbProgressHUD.labelText=@"Recongizing...";
  [self.mbProgressHUD showAnimated:YES whileExecutingBlock:^(void){
    text=[self doRecognise:viewImage];
  } completionBlock:^(void)
  {
    // show result
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Is this result correct?"
                                                    message:text
                                                   delegate:nil
                                          cancelButtonTitle:@"No"
                                          otherButtonTitles:@"Yes", nil];
    //[alert setValue:text forKey:@"text"];
    alert.delegate=self;
    alert.tag=TAG_CONFIRM_OCR_RESULT;
    [alert show];
  }];
}

-(void) motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
  if (event.subtype == UIEventSubtypeMotionShake) {
    [self performSegueWithIdentifier:@"configParameter" sender:self];
  }
}

-(BOOL)canBecomeFirstResponder
{
  return YES;
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
  [alertView dismissWithClickedButtonIndex:buttonIndex animated:YES];
  if (alertView.tag == TAG_CONFIRM_OCR_RESULT) {
    NSLog(@"buttonIndex %d", buttonIndex);
    if (buttonIndex==1) {
      self.asProcess = [[UIActionSheet alloc ] initWithTitle:nil delegate:self cancelButtonTitle:@"cancel" destructiveButtonTitle:nil otherButtonTitles:@"Google search", @"Baidu search", nil];

      NSString* text = alertView.message;
      [[NSUserDefaults standardUserDefaults] setValue:text forKey:@"text"];
      [self.asProcess showInView:self.view];
    }
  }
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
  if (actionSheet==self.asGetImage)
  {
    {
      switch (buttonIndex) {
        case 0:
          [self callCameraFun:self];
          break;
          
        case 1:
          [self chooseImageFromLibrary:actionSheet];
        default:
          break;
      }
    }
    self.asGetImage=nil;
  }
  else if(actionSheet==self.asProcess)
  {
    //NSLog(@"buttonIndex = %d", buttonIndex);
    NSString* text = [[NSUserDefaults standardUserDefaults] valueForKey:@"text"];
    switch (buttonIndex) {
      case 0:
      {
        NSString* urlString = [@"http://www.google.com/search?q=" stringByAppendingString:[text urlencode]];
        NSURL* url = [NSURL URLWithString:urlString];
        [[UIApplication sharedApplication] openURL:url];
        //[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[ ]]];
      }
        break;
        
      case 1:
      {
        NSString* urlString = [@"http://www.baidu.com/s?wd=" stringByAppendingString:[text urlencode]];
        NSURL* url = [NSURL URLWithString:urlString];
        [[UIApplication sharedApplication] openURL:url];
      }
        
        break;
        
      default:
        break;
    }
    self.asProcess=nil;
  }
}

-(void)startProgressHUD:(NSString*)message
{
  self.mbProgressHUD = [[MBProgressHUD alloc] initWithWindow:self.view.window];
  [self.view.window addSubview:self.mbProgressHUD];
  [self.mbProgressHUD show:YES];
  self.mbProgressHUD.labelText=message;
}

-(void)stopProgressHUD
{
  //[MBProgressHUD hideAllHUDsForView:self.view animated:YES];
  [self.mbProgressHUD show:NO];
  [self.mbProgressHUD removeFromSuperview];
  self.mbProgressHUD=nil;
}

#pragma mark - AdViewDelegates

-(void)bannerView:(ADBannerView *)banner
didFailToReceiveAdWithError:(NSError *)error{
  NSLog(@"Error loading");
}

-(void)bannerViewDidLoadAd:(ADBannerView *)banner{
  NSLog(@"Ad loaded");
}
-(void)bannerViewWillLoadAd:(ADBannerView *)banner{
  NSLog(@"Ad will load");
}
-(void)bannerViewActionDidFinish:(ADBannerView *)banner{
  NSLog(@"Ad did finish");
  
}

@end
