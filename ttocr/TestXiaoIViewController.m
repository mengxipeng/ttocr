//
//  ConfigurationViewController.m
//  ttocr
//
//  Created by mengxipeng on 27/8/12.
//  Copyright (c) 2012 mengxipeng. All rights reserved.
//

#import "TestXiaoIViewController.h"
#import "ApplicationData.h"
#import "SRSessionController.h"



@interface TestXiaoIViewController ()

@end

@implementation TestXiaoIViewController
@synthesize textFieldQuestion;
@synthesize textLabelAnswer;
@synthesize webViewTest;
@synthesize textFieldServerName;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.textFieldServerName.text = [ApplicationData sharedApplicationData].serverName;
    self.textFieldServerName.delegate = self;
    
    self.textFieldQuestion.text = @"北京到上海的飞机票";
    
    [self.webViewTest loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.baidu.com"]]];
    self.webViewTest.delegate=self;
}

- (void)viewDidUnload
{
    [self setTextFieldServerName:nil];
    [self setTextFieldQuestion:nil];
    [self setTextLabelAnswer:nil];
    [self setWebViewTest:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

-(void)viewWillDisappear:(BOOL)animated
{
    [ApplicationData sharedApplicationData].serverName = self.textFieldServerName.text;
    [super viewWillDisappear:animated];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - UITextFieldDelegate methods
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField==textFieldServerName) {
        [textField resignFirstResponder];
    }

    return YES;
}


#pragma mark - the methods realed to xiaoI AI platform
- (IBAction)testXiaoIAudioInpout:(UIButton *)sender {
    
    self.audioQueueService = [[AudioQueueService alloc] init];
    [self.audioQueueService initRecording];
    self.audioQueueService.delegate=self;
    [self.audioQueueService record];
}

- (void) audioPlayDidFinished{
    
}
- (void) audioRecordDidFinished: (NSData *) dataAudio{
    if (dataAudio!=nil || [dataAudio length]>0) {
        XISpeexCodec* xiSpeexCode = [[XISpeexCodec alloc] initWithMode:0];
        NSData* encodedAudio = [xiSpeexCode encode:dataAudio];
        
        //NSString* sampleAudioData = [[NSBundle mainBundle] pathForResource:@"audiosample" ofType:@"dat"];
        
        //test google;
        SRSessionParams *params1 = [[SRSessionParams alloc] init];
        
        params1.baseURL = @"http://nlp.xiaoi.com";
        params1.audioBitsPerSample = 16;
        params1.audioRate = 8000;
        params1.audioEncode = @"speex-wb;7";
        params1.retTextEncode = @"utf-8";
        params1.SREngineType = SRET_XIAOI_DEFAULT;
        //params1.audioData = [NSData dataWithContentsOfFile:sampleAudioData];
        params1.audioData = encodedAudio;
        
        SRSessionController *ctrl1 = [[SRSessionController alloc] init];
        [ctrl1 begin:params1 delegate:self];

        
    }
}
- (void) updateLevelMeter: (int) iValue{
    
}


- (void)SRSessionController:(SRSessionController *)ctrl didFinished:(SRSessionResponseDomain *)domain
{
    NSString* text = domain.textContent;
    NSLog(@"text:%@", text);
    
    
}
- (void)SRSessionController:(SRSessionController *)ctrl failed:(NSError *)error
{
   
}

- (IBAction)stopAudioInput:(UIButton *)sender {
    [self.audioQueueService stopRecording ];
}

- (IBAction)textTextAsk:(UIButton *)sender {
    
    
    
    // active didFinished delegate methord;
    AskSessionParams  *params1 = [[AskSessionParams alloc] init];
    
    params1.baseURL = @"http://nlp.xiaoi.com";
    params1.ver = @"155";
    params1.platform = @"android";
    params1.userID = [NSString stringWithFormat:@"%d", arc4random()];
    params1.question = [textFieldQuestion text];
    params1.format = @"json";
    
    AskSessionController *ctrl1 = [[AskSessionController alloc] init];
    
    [ctrl1 begin:params1 delegate:self];
}

- (void)askSessionController:(AskSessionController *)ctrl didFinished:(AskSessionResponseDomain *)domain
{
    NSString* text= ctrl.lastResponseJSON;
    NSLog(@"text:%@", text);
    textLabelAnswer.text=text;
}
- (void)askSessionController:(AskSessionController *)ctrl failed:(NSError *)error
{
}

- (IBAction)testText2Speech:(UIButton *)sender {
    [self testWebView];
}

#pragma mark - test methods
-(void)testWebView
{
    [webViewTest loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://wwww.baidu.com"]]];
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"error %@", [error localizedDescription]);
    [UIApplication sharedApplication].networkActivityIndicatorVisible=NO;
}

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSLog(@"finish Loading");
    [UIApplication sharedApplication].networkActivityIndicatorVisible=NO;
    NSString *myText = [webViewTest stringByEvaluatingJavaScriptFromString:@"document.documentElement.outerHTML"];
    NSLog(@"myText %@", myText);
}

-(void)webViewDidStartLoad:(UIWebView *)webView
{
    NSLog(@"start loading");
    [UIApplication sharedApplication].networkActivityIndicatorVisible=YES;
}

@end
