//
//  ApplicationData.h
//  ttocr
//
//  Created by mengxipeng on 25/8/12.
//  Copyright (c) 2012 mengxipeng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ApplicationData : NSObject

+(ApplicationData*)sharedApplicationData;

#define TAG_SERVERNAME @"servername"

//@property (strong, nonatomic) UIImage* image;
//@property (strong, nonatomic) NSString* serverName;
@property (nonatomic) BOOL onlyNumber;

@end
