//
//  SRSessionController.m
//  iknowapp
//
//  Created by Peter Liu on 8/27/12.
//  Copyright (c) 2012 xiaoi. All rights reserved.
//

#import "SRSessionController.h"
#import "AFHTTPRequestOperation.h"
#import "JSONKit.h"

@interface SRSessionController(private)

- (BOOL)coreBegin:(SRSessionParams *)params
          success:(void(^)(AFHTTPRequestOperation *operation, id responseObject))success
           failed:(void(^)(AFHTTPRequestOperation *operation, NSError *error))failed;

@end

@implementation SRSessionParams

@synthesize audioData;
@synthesize audioBitsPerSample;
@synthesize audioRate;
@synthesize audioEncode;
@synthesize retTextEncode;

@end

@implementation SRSessionController

@synthesize params = _params;

- (BOOL)coreBegin:(SRSessionParams *)params
          success:(void(^)(AFHTTPRequestOperation *operation, id responseObject))success
           failed:(void(^)(AFHTTPRequestOperation *operation, NSError *error))failed
{
    if(params == nil)
        return NO;
    
    BOOL ret = NO;
    
    if(params.SREngineType == SRET_XIAOI_DEFAULT ||
       params.SREngineType == SRET_XIAOI_IREC)
    {
        NSString *strURL = [NSString stringWithFormat:@"%@/recog", params.baseURL];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:strURL]];
        
        [request addValue:@"application/audio" forHTTPHeaderField:@"Content-Type"];
        [request addValue:[NSString stringWithFormat:@"%d", [params.audioData length]] forHTTPHeaderField:@"Content-Length"];
        [request addValue:params.audioEncode forHTTPHeaderField:@"X-AUE"];
        [request addValue:params.retTextEncode forHTTPHeaderField:@"X-TXE"];
        
        [request addValue:[NSString stringWithFormat:@"audio/L%d;rate=%d",
                           params.audioBitsPerSample,
                           params.audioRate] forHTTPHeaderField:@"X-AUF"];
        
        [request setHTTPBody:params.audioData];
        [request setHTTPMethod:@"POST"];
        
        if(params.SREngineType == SRET_XIAOI_IREC)
            [request addValue:@"irec" forHTTPHeaderField:@"params"];
        
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        [operation setCompletionBlockWithSuccess:
         ^(AFHTTPRequestOperation *operation, id responseObject)
         {
             if(success != nil)
             {
                 SRSessionResponseDomain *domain = [[SRSessionResponseDomain alloc] init];
                 
                 NSHTTPURLResponse* rep = operation.response;
                 NSDictionary *header = [rep allHeaderFields];
                 
                 if([responseObject isKindOfClass:[NSData class]])
                 {
                     UInt16 endOfString = 0;
                     
                     domain.textTag = [header objectForKey:@"Content-Type"];
                     
                     NSMutableData *data = [[NSMutableData alloc] initWithCapacity:50];
                     [data appendBytes:[(NSData *)responseObject bytes] length:[(NSData *)responseObject length]];
                     [data appendBytes:&endOfString length:2];
                     
                     domain.textContent = [NSString stringWithUTF8String:[data bytes]];
                 }
                 else
                 {
                     domain.textTag = @"";
                     domain.textContent = @"";
                 }
                 
                 _domain = domain;
                 
                 success(operation, responseObject);
             }
             
         }
                                         failure:
         ^(AFHTTPRequestOperation *operation, NSError *error)
         {
             if(failed != nil)
             {
                 failed(operation, error);
             }
         }];
        
        ret = YES;
        
        _params = params;
        
        [operation start];
    }
    else if(params.SREngineType == SRET_GOOGLE)
    {
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://www.google.com/speech-api/v1/recognize?xjerr=1&client=chromium&lang=zh-cn"]];
        
        [request addValue:[NSString stringWithFormat:@"audio/speex; rate=%d",params.audioRate]  forHTTPHeaderField:@"Content-Type"];
        [request addValue:[NSString stringWithFormat:@"%d", [params.audioData length]] forHTTPHeaderField:@"Content-Length"];
        [request setHTTPBody:params.audioData];
        [request setHTTPMethod:@"POST"];
        
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        [operation setCompletionBlockWithSuccess:
         ^(AFHTTPRequestOperation *operation, id responseObject)
         {
             if(success != nil)
             {
                 SRSessionResponseDomain *domain = [[SRSessionResponseDomain alloc] init];
                 
                 NSHTTPURLResponse* rep = operation.response;
                 NSDictionary *header = [rep allHeaderFields];
                 
                 if([responseObject isKindOfClass:[NSData class]])
                 {
                     
                     domain.textTag = [header objectForKey:@"Content-Type"];
                     
                     JSONDecoder *decoder = [JSONDecoder decoder];
                     NSDictionary *dic = [decoder objectWithData:responseObject];
                     
                     NSArray *array = [dic objectForKey:@"hypotheses"];
                     
                     if(array != nil && [array count] > 0)
                     {
                         dic = [array objectAtIndex:0];
                         
                         if(dic != nil)
                         {
                             domain.textContent = [dic objectForKey:@"utterance"];
                         }
                     }
                 }
                 else
                 {
                     domain.textTag = @"";
                     domain.textContent = @"";
                 }
                 
                 _domain = domain;
                 
                 success(operation, responseObject);
             }
             
         }
                                         failure:
         ^(AFHTTPRequestOperation *operation, NSError *error)
         {
             if(failed != nil)
             {
                 failed(operation, error);
             }
         }];
        
        ret = YES;
        
        _params = params;
        
        [operation start];
        
    }
    
    return ret;
}

- (BOOL)begin:(SRSessionParams *)params delegate:(id<SRSessionControllerDelegate>)delegate
{
    if(params == nil || delegate == nil)
        return NO;
    
    _delegate = delegate;
    
    void (^successLocal)(AFHTTPRequestOperation *operation, id responseObject) = ^(AFHTTPRequestOperation *operation, id responseObject)
    {
        if(_delegate != nil && [_delegate respondsToSelector:@selector(SRSessionController:didFinished:)])
        {
            [_delegate SRSessionController:self didFinished:_domain];
        }
    };
    
    void (^failedLocal)(AFHTTPRequestOperation *operation, NSError *error) = ^(AFHTTPRequestOperation *operation, NSError *error)
    {
        if(_delegate != nil && [_delegate respondsToSelector:@selector(SRSessionController:failed:)])
        {
            [_delegate SRSessionController:self failed:error];
        }
    };
    
    return [self coreBegin:params success:successLocal failed:failedLocal];
    
}

- (BOOL)begin:(SRSessionParams *)params
      success:(void(^)(SRSessionParams *params, SRSessionResponseDomain *domain))success
       failed:(void(^)(SRSessionParams *params, NSError *))failed
{
    void (^successLocal)(AFHTTPRequestOperation *operation, id responseObject) = ^(AFHTTPRequestOperation *operation, id responseObject)
    {
        if(success != nil)
        {
            success(params, _domain);
        }
    };
    
    void (^failedLocal)(AFHTTPRequestOperation *operation, NSError *error) = ^(AFHTTPRequestOperation *operation, NSError *error)
    {
        if(failed != nil)
        {
            failed(params, error);
        }
    };
    
    return [self coreBegin:params success:successLocal failed:failedLocal]; 
}

@end
