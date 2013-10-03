//
//  AskSessionController.h
//  iknowapp
//
//  Created by Peter Liu on 8/27/12.
//  Copyright (c) 2012 xiaoi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AskSessionResponseDomain.h"

@class AskSessionController;

@protocol AskSessionControllerDelegate<NSObject>

@optional
- (void)askSessionController:(AskSessionController *)ctrl didFinished:(AskSessionResponseDomain *)domain;
- (void)askSessionController:(AskSessionController *)ctrl failed:(NSError *)error;

@end

@interface AskSessionParams : NSObject

@property (nonatomic, copy) NSString *sessionID;
@property (nonatomic, copy) NSString *userID;
@property (nonatomic, copy) NSString *question;
@property (nonatomic, copy) NSString *platform;
@property (nonatomic, copy) NSString *location;
@property (nonatomic, copy) NSString *brand;
@property (nonatomic, copy) NSString *format;
@property (nonatomic, copy) NSString *ver;
@property (nonatomic, copy) NSString *baseURL;

@end

@interface AskSessionController : NSObject
{
@private
    AskSessionParams                    *_params;
    id<AskSessionControllerDelegate>     _delegate;
    NSString                            *_lastResponseJSON;
}

@property (nonatomic, strong, readonly) NSString    *lastResponseJSON;
@property (nonatomic, strong, readonly) AskSessionParams *params;

- (BOOL)begin:(AskSessionParams *)params delegate:(id<AskSessionControllerDelegate>)delegate;

- (BOOL)begin:(AskSessionParams *)params
      success:(void (^)(AskSessionController *ctrl, AskSessionResponseDomain *domain))success
       failed:(void (^)(AskSessionController *ctrl, NSError *error))failed;

@end
