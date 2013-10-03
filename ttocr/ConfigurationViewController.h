//
//  ConfigurationViewController.h
//  ttocr
//
//  Created by mengxipeng on 29/11/12.
//  Copyright (c) 2012 mengxipeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ConfigurationViewController : UIViewController <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *serverName;

@end
