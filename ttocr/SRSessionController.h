//
//  SRSessionController.h
//  iknowapp
//
//  Created by Peter Liu on 8/27/12.
//  Copyright (c) 2012 xiaoi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SRSessionResponseDomain.h"

enum SREngineType
{
    SRET_XIAOI_DEFAULT = 0,
    SRET_XIAOI_IREC,
    SRET_GOOGLE,
    SRET_IFLY
};

@interface SRSessionParams : NSObject

@property (nonatomic, strong) NSData    *audioData;
@property (nonatomic, assign) NSInteger audioBitsPerSample;
@property (nonatomic, assign) NSInteger audioRate;
@property (nonatomic, strong) NSString  *audioEncode;
@property (nonatomic, strong) NSString  *retTextEncode;
@property (nonatomic, strong) NSString  *baseURL;
@property (nonatomic, assign) enum SREngineType SREngineType;

@end

@class SRSessionController;

@protocol SRSessionControllerDelegate<NSObject>


@optional
- (void)SRSessionController:(SRSessionController *)ctrl didFinished:(SRSessionResponseDomain *)domain;
- (void)SRSessionController:(SRSessionController *)ctrl failed:(NSError *)error;

@end

@interface SRSessionController : NSObject
{
@private
    id<SRSessionControllerDelegate>     _delegate;
    SRSessionParams                     *_params;
    SRSessionResponseDomain             *_domain;
    
}

@property (nonatomic, strong, readonly) SRSessionParams *params;

- (BOOL)begin:(SRSessionParams *)params delegate:(id<SRSessionControllerDelegate>)delegate;

- (BOOL)begin:(SRSessionParams *)params
      success:(void(^)(SRSessionParams *params, SRSessionResponseDomain *domain))success
       failed:(void(^)(SRSessionParams *params, NSError *))failed;

@end
