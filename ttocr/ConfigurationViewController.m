//
//  ConfigurationViewController.m
//  ttocr
//
//  Created by mengxipeng on 29/11/12.
//  Copyright (c) 2012 mengxipeng. All rights reserved.
//

#import "ConfigurationViewController.h"
#import "ApplicationData.h"

@interface ConfigurationViewController ()

@end

@implementation ConfigurationViewController

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
  self.serverName.delegate=self;
  self.serverName.text = [ApplicationData sharedApplicationData].serverName;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setServerName:nil];
    [super viewDidUnload];
}

#pragma mask - textField delegate methods
-(void)textFieldDidEndEditing:(UITextField *)textField
{
  if (textField == self.serverName) {
    [ApplicationData sharedApplicationData].serverName=self.serverName.text;
  }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
  if (textField == self.serverName) {
    [self.serverName resignFirstResponder];
    [ApplicationData sharedApplicationData].serverName=self.serverName.text;
  }
  return YES;
}

@end
