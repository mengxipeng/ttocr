//
//  ApplicationData.m
//  ttocr
//
//  Created by mengxipeng on 25/8/12.
//  Copyright (c) 2012 mengxipeng. All rights reserved.
//

#import "ApplicationData.h"

static ApplicationData* applicationData = nil;

#define strKeyImage  @"image"
#define strKeyServerName @"serverName"
#define strOnlyNumber @"onlyNumber"

@implementation ApplicationData

//@synthesize image=_image;
//@synthesize serverName;
@synthesize onlyNumber=_onlyNumber;

+(ApplicationData*)sharedApplicationData{
    if (applicationData==nil) {
        applicationData = [[ApplicationData alloc] init];
    }
    return applicationData;
}

#if false
-(UIImage*)image{
    //return [[NSUserDefaults standardUserDefaults] objectForKey:strKeyImage];
    NSData* encodedImageData = [[NSUserDefaults standardUserDefaults] objectForKey:strKeyImage];
    NSData* imageData = [NSKeyedUnarchiver unarchiveObjectWithData:encodedImageData];
    return [UIImage imageWithData:imageData];
}

-(void)setImage:(UIImage *)aImage{
    //[[NSUserDefaults standardUserDefaults] setObject:aImage forKey:strKeyImage];
    //[[NSUserDefaults standardUserDefaults]synchronize];
    NSData* imageData = UIImagePNGRepresentation(aImage);
    NSData* encodedImageData = [NSKeyedArchiver archivedDataWithRootObject:imageData];
    [[NSUserDefaults standardUserDefaults] setObject:encodedImageData forKey:strKeyImage];
}


-(NSString*)serverName{
    return [[NSUserDefaults standardUserDefaults] objectForKey:strKeyServerName];
}

-(void)setServerName:(NSString *)aServerName{
    [[NSUserDefaults standardUserDefaults] setObject:aServerName forKey:strKeyServerName];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#endif

-(BOOL)onlyNumber
{
  return [[NSUserDefaults standardUserDefaults] boolForKey:strOnlyNumber];
}

-(void)setOnlyNumber:(BOOL)onlyNumber
{
  [[NSUserDefaults standardUserDefaults]setBool:onlyNumber forKey:strOnlyNumber];
  [[NSUserDefaults standardUserDefaults]synchronize];
}

@end
