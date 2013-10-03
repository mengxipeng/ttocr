//
//  AddGestureViewController.m
//  ttocr
//
//  Created by mengxipeng on 24/8/12.
//  Copyright (c) 2012 mengxipeng. All rights reserved.
//

#import "AddGestureViewController.h"
#import "ViewController.h"
#import "DrawUIView.h"
#import "ApplicationData.h"
#import "UIView+Addition.h"
#import "UIImage+Addiction.h"

#define MARK_MARGIN 2.0f

@interface AddGestureViewController ()

@end

@implementation AddGestureViewController
@synthesize imageView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        // init the tesseract engine.
        // [self startTesseract];
        
    }
    return self;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    
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

    imageView.userInteractionEnabled=YES;
    
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
    
    UITapGestureRecognizer* selectGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectImage:)];
    [selectGestureRecognizer setDelegate:self];
    [selectGestureRecognizer setNumberOfTapsRequired:2]; // double tap
    [self.view addGestureRecognizer:selectGestureRecognizer];
    
    //NSLog(@"frame %f %f %f %f", self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height);
    
    CGRect rect=CGRectMake(self.view.frame.size.width/4, self.view.frame.size.height/4, self.view.frame.size.width/2, self.view.frame.size.height/2);
    _markRect = rect;
    [self showOverlayWithFrame:rect];
    
    [self startTesseract];
   
}

- (void)viewDidUnload
{
    [self setImageView:nil];
    _marque=nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    
    //tess->End();
    tess=NULL;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    imageView.image = [ApplicationData sharedApplicationData].image;
    [imageView setNeedsDisplay];
    
    //DrawUIView* drawView = (DrawUIView*)self.view;
    //[drawView drawRect:CGRectMake(50, 60, 300, 300)];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    //UIImage* maskedImage = [[self.view imageByRenderingView] croppedImageWithImage:_markRect];
    //UIImage* maskedImage = [self.view imageByRenderingView];
    //[ApplicationData sharedApplicationData].image=maskedImage;
  //  ViewController* parentViewController = (ViewController*)self.navigationController.parentViewController;
    //parentViewController.captuerImageView.image=maskedImage;
    //[parentViewController.captuerImageView setNeedsDisplay];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - gesture handle methods

-(void)selectImage:(id)sender{
    if (_marque.hidden) {
        return;
    }
    
    //_marque.hidden=YES;
    
    //UITapGestureRecognizer* selectGestureRecognizer = (UITapGestureRecognizer*)sender;
    //CGPoint locationPoint = [selectGestureRecognizer locationInView:self.view];
   // if (!CGRectContainsPoint(_markRect, locationPoint)) {
   //     return;
   // }
    
    // get the select image
    UIImage* viewImage = [self.view imageByRenderingView];
    UIImage* selectImage = [viewImage croppedImageWithImage:CGRectMake(_markRect.origin.x+MARK_MARGIN, _markRect.origin.y+MARK_MARGIN, _markRect.size.width-2*MARK_MARGIN, _markRect.size.height-2*MARK_MARGIN)];
    
    // save the uiimage to a file
    {
        [self saveImage:selectImage];
        NSString* text  =  [self ocrImage:selectImage];
        NSLog(@"text:%@", text);
    }
    
 
    return ;
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
    
    //NSLog(@"x = %f, y = %f, width = %f, height = %f",
          //translatedPoint.x, translatedPoint.y,
     //     startX, startY, width, heigth);
    
    if (drawPaneGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        // send whold image and user's touch to the web server
        return ;
    }
    
    [drawPaneGestureRecognizer setTranslation:CGPointMake(0, 0) inView:self.view];
    
    // draw mark line
    CGRect markRect = CGRectMake(startX, startY, width, heigth);
    _markRect = markRect;
    [self showOverlayWithFrame:markRect];
    //DrawUIView* drawUIView = (DrawUIView*)self.view;
    //[drawUIView drawRect:markRect];
}

-(void)move:(id)sender {
    //[[[(UITapGestureRecognizer*)sender view] layer] removeAllAnimations];
    
    CGPoint translatedPoint = [(UIPanGestureRecognizer*)sender translationInView:self.view];
    
    if([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateBegan) {
        _firstX = [imageView center].x;
        _firstY = [imageView center].y;
    }
    
    translatedPoint = CGPointMake(_firstX+translatedPoint.x, _firstY+translatedPoint.y);
    
    [imageView setCenter:translatedPoint];
    
}

-(void)scale:(id)sender {
    
    if([(UIPinchGestureRecognizer*)sender state] == UIGestureRecognizerStateBegan) {
        _lastScale = 1.0;
    }
    
    CGFloat scale = 1.0 - (_lastScale - [(UIPinchGestureRecognizer*)sender scale]);
    
    CGAffineTransform currentTransform = imageView.transform;
    CGAffineTransform newTransform = CGAffineTransformScale(currentTransform, scale, scale);
    
    [imageView setTransform:newTransform];
    
    _lastScale = [(UIPinchGestureRecognizer*)sender scale];
}

-(void)rotate:(id)sender {
    
    if([(UIRotationGestureRecognizer*)sender state] == UIGestureRecognizerStateEnded) {
        
        _lastRotation = 0.0;
        return;
    }
    
    CGFloat rotation = 0.0 - (_lastRotation - [(UIRotationGestureRecognizer*)sender rotation]);
    
    CGAffineTransform currentTransform = imageView.transform;
    CGAffineTransform newTransform = CGAffineTransformRotate(currentTransform,rotation);
    
    [imageView setTransform:newTransform];
    
    _lastRotation = [(UIRotationGestureRecognizer*)sender rotation];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}




#pragma mark - private methods



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
    
    //_marque.bounds = CGRectMake(0,0,frame.size.width, frame.size.height);
    //_marque.frame = frame;
    //_marque.position = CGPointMake(frame.origin.x, frame.origin.y);
    

    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, frame);
    [_marque setPath:path];
    CGPathRelease(path);
    
    _marque.hidden = NO;
    
}


#pragma mark - until methods
-(void)saveImage:(UIImage*)image
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    
    NSData *binaryImageData = UIImageJPEGRepresentation(image, 1.0f);
    
    NSDateComponents *components = [[NSCalendar currentCalendar] components: NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit |  NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit fromDate:[NSDate date]];
    
    NSString* imageFileName = [NSString stringWithFormat:@"/%04d-%02d-%02d.%02d.%02d.%02d.jpg", [components year], [components month], [components day], [components hour], [components minute], [components second]];
    
    NSString* fullFileName = [basePath stringByAppendingString:imageFileName];
    //NSLog(@"fullFileName %@", fullFileName);
    
    [binaryImageData writeToFile:fullFileName atomically:YES];
}


-(NSString*)ocrImage:(UIImage*)uiImage
{
#if 0
  
    {
        
        //code from http://robertcarlsen.net/2009/12/06/ocr-on-iphone-demo-1043
        
        CGSize imageSize = [uiImage size];
        double bytes_per_line	= CGImageGetBytesPerRow([uiImage CGImage]);
        double bytes_per_pixel	= CGImageGetBitsPerPixel([uiImage CGImage]) / 8.0;
        
        CFDataRef data = CGDataProviderCopyData(CGImageGetDataProvider([uiImage CGImage]));
        const UInt8 *imageData = CFDataGetBytePtr(data);
        
        // this could take a while. maybe needs to happen asynchronously.
        char* text = tess->TesseractRect(imageData,(int)bytes_per_pixel,(int)bytes_per_line, 0, 0,(int) imageSize.height,(int) imageSize.width);
        
        // Do something useful with the text!
        NSLog(@"Converted text: %@",[NSString stringWithCString:text encoding:NSUTF8StringEncoding]);
        
        return [NSString stringWithCString:text encoding:NSUTF8StringEncoding];
    }
#else
  return @"";
#endif

}

- (NSString *) applicationDocumentsDirectory
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectoryPath = [paths objectAtIndex:0];
	return documentsDirectoryPath;
}

- (void) startTesseract
{
	//code from http://robertcarlsen.net/2009/12/06/ocr-on-iphone-demo-1043
    
	NSString *dataPath = [[self applicationDocumentsDirectory] stringByAppendingPathComponent:@"tessdata"];
	/*
	 Set up the data in the docs dir
	 want to copy the data to the documents folder if it doesn't already exist
	 */
	NSFileManager *fileManager = [NSFileManager defaultManager];
	// If the expected store doesn't exist, copy the default store.
	if (![fileManager fileExistsAtPath:dataPath]) {
		// get the path to the app bundle (with the tessdata dir)
		NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
		NSString *tessdataPath = [bundlePath stringByAppendingPathComponent:@"tessdata"];
		if (tessdataPath) {
			[fileManager copyItemAtPath:tessdataPath toPath:dataPath error:NULL];
		}
	}
	
	NSString *dataPathWithSlash = [[self applicationDocumentsDirectory] stringByAppendingString:@"/"];
	setenv("TESSDATA_PREFIX", [dataPathWithSlash UTF8String], 1);
#if 0
	
	// init the tesseract engine.
	tess = new tesseract::TessBaseAPI();
	
	tess->Init([dataPath cStringUsingEncoding:NSUTF8StringEncoding],  // Path to tessdata-no ending /.
					 "eng");
#endif
	
	
}



@end
