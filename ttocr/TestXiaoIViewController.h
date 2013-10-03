//
//  ConfigurationViewController.h
//  ttocr
//
//  Created by mengxipeng on 27/8/12.
//  Copyright (c) 2012 mengxipeng. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AudioQueueService.h"
#import "XISpeexCodec.h"
#import "SRSessionController.h"
#import "AskSessionController.h"

@interface TestXiaoIViewController : UIViewController<UITextFieldDelegate, AudioQueueServeiceDelegate, SRSessionControllerDelegate, AskSessionControllerDelegate, UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *textFieldServerName;

@property (strong, nonatomic) AudioQueueService* audioQueueService;
@property (weak, nonatomic) IBOutlet UITextField *textFieldQuestion;
@property (weak, nonatomic) IBOutlet UILabel *textLabelAnswer;
@property (weak, nonatomic) IBOutlet UIWebView *webViewTest;

@end
