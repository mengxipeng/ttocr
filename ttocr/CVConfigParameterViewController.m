//
//  CVConfigParameterViewController.m
//  ttocr
//
//  Created by mengxipeng on 29/4/13.
//  Copyright (c) 2013 mengxipeng. All rights reserved.
//

#import "CVConfigParameterViewController.h"
#import "ApplicationData.h"

@interface CVConfigParameterViewController ()

@end

@implementation CVConfigParameterViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
      
    }
    return self;
}

-(void)viewWillDisappear:(BOOL)animated
{
  [super viewWillDisappear:animated];
  //((AppDelegate*)[[UIApplication sharedApplication]delegate]).servername=self.serverName.text;
  //((AppDelegate*)[[UIApplication sharedApplication]delegate]).uploadServer=self.uploadServer.on;
  [ApplicationData sharedApplicationData].onlyNumber = self.onlyNumber.on;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
  
  //self.characterCategory.delegate=self;
  //self.characterCategory.showsSelectionIndicator=YES;
  //[self.characterCategory reloadAllComponents];
  //[self.characterCategory selectRow:((AppDelegate*)[[UIApplication sharedApplication] delegate]).characterCategory inComponent:0 animated:YES];
  //[self.characterCategory selectedRowInComponent:((AppDelegate*)[[UIApplication sharedApplication]delegate]).characterCategory];
	// Do any additional setup after loading the view.
  //[self.serverName setText:((AppDelegate*)[[UIApplication sharedApplication] delegate]).servername];
  //self.characterCategory
  //[self.uploadServer setOn:((AppDelegate*)[[UIApplication sharedApplication]delegate]).uploadServer animated:YES];
  //[self.onlyNumber setOn:((AppDelegate*)[[UIApplication sharedApplication]delegate]).onlyNumber];
  [self.onlyNumber setOn:[ApplicationData sharedApplicationData].onlyNumber];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
//  [self setServerName:nil];
//    [self setUploadServer:nil];
//    [self setCharacterCategory:nil];
    [self setOnlyNumber:nil];
  [super viewDidUnload];
}

#pragma mark - uipicker delegate methods

#if 0
-(void) pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
  ((AppDelegate*)[[UIApplication sharedApplication] delegate]).characterCategory = row;
}


-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
  switch (row) {
    case 0:
      return @"Digital";
      break;
    
    case 1:
      return @"English";
      break;
      
    case 2:
      return @"Chinese Simple";
      break;
      
    case 3:
      return @"Chinese traindation";
    default:
      break;
  }
  return @"";
}



-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
  return 3;
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
  return 1;
}
#endif

@end
