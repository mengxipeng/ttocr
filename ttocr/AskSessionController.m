//
//  AskSessionController.m
//  iknowapp
//
//  Created by Peter Liu on 8/27/12.
//  Copyright (c) 2012 xiaoi. All rights reserved.
//

#import "AskSessionController.h"
#import "AFJSONRequestOperation.h"

@implementation AskSessionParams
@synthesize sessionID;
@synthesize userID;
@synthesize question;
@synthesize platform;
@synthesize location;
@synthesize brand;
@synthesize format;
@synthesize ver;

@end

@interface AskSessionController(private)
- (BOOL)notNilAndEmpty:(NSString *)str;
- (NSDictionary *)dicParams:(AskSessionParams *)params;
- (NSURLRequest *)requestFromParams:(AskSessionParams *)params;
- (BOOL)internalBegin:(AskSessionParams *)params
              success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
               failed:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failed;
@end

@implementation AskSessionController
@synthesize params = _params;
@synthesize lastResponseJSON = _lastResponseJSON;

- (NSURLRequest *)requestFromParams:(AskSessionParams *)params
{
    if(params == nil)
        return nil;
    
    NSDictionary *dic = [self dicParams:params];
    
    if([dic count] == 0)
    {
        return nil;
    }
    else
    {
        NSMutableString *strParams = [NSMutableString stringWithCapacity:100];
        
        int len = [dic count];
        
        for(NSString *key in dic)
        {
            if(len-- != 1)
                [strParams appendString:[NSString stringWithFormat:@"%@=%@&", key, [dic objectForKey:key]]];
            else
                [strParams appendString:[NSString stringWithFormat:@"%@=%@", key, [dic objectForKey:key]]];
        }
        
        NSString *strURL = [NSString stringWithFormat:@"%@/ask?%@", params.baseURL, strParams];
        
        strURL = (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                              (__bridge CFStringRef)strURL,
                                                                              nil,
                                                                              nil,
                                                                              kCFStringEncodingUTF8);
        
        NSURL *url = [NSURL URLWithString:strURL];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        
        return request;
    }
}

- (NSDictionary *)dicParams:(AskSessionParams *)params
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithCapacity:10];
    
    if([self notNilAndEmpty:params.sessionID])
    {
        [dic setObject:params.sessionID forKey:@"sessionId"];
    }
    
    if([self notNilAndEmpty:params.userID])
    {
        [dic setObject:params.userID forKey:@"userId"];
    }
    
    if([self notNilAndEmpty:params.question])
    {
        [dic setObject:params.question forKey:@"question"];
    }
    
    if([self notNilAndEmpty:params.platform])
    {
        [dic setObject:params.platform forKey:@"platform"];
    }
    
    if([self notNilAndEmpty:params.location])
    {
        [dic setObject:params.location forKey:@"location"];
    }
    
    if([self notNilAndEmpty:params.brand])
    {
        [dic setObject:params.brand forKey:@"brand"];
    }
    
    if([self notNilAndEmpty:params.format])
    {
        [dic setObject:params.format forKey:@"format"];
    }
    
    if([self notNilAndEmpty:params.ver])
    {
        [dic setObject:params.ver forKey:@"ver"];
    }
    
    return dic;
}

- (BOOL)notNilAndEmpty:(NSString *)str

{
    return str != nil && ![[str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""];
}

- (BOOL)begin:(AskSessionParams *)params delegate:(id<AskSessionControllerDelegate>)delegate
{
    if(params == nil || delegate == nil)
    {
        return NO;
    }
    
    _delegate = delegate;
    
    void (^success)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) =
    ^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
    {
        
        if(_delegate != nil && [_delegate  respondsToSelector:@selector(askSessionController:didFinished:)])
        {
            [_delegate askSessionController:self
                                didFinished:[AskSessionResponseDomain objectFromJSONObject:JSON
                                                                                   mapping:[AskSessionResponseDomain mapping]]];
        }
        
        
    };
    
    void (^failed)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) =
    ^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
    {

        if(_delegate != nil && [_delegate respondsToSelector:@selector(askSessionController:failed:)])
        {
            [_delegate askSessionController:self failed:error];
        }
        
        
    };
    
    return [self internalBegin:params success:success failed:failed];
}

- (BOOL)begin:(AskSessionParams *)params
      success:(void (^)(AskSessionController *ctrl, AskSessionResponseDomain *domain))success
       failed:(void (^)(AskSessionController *ctrl, NSError *error))failed
{
    if(params == nil)
        return NO;
    
    void (^success_local)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) =
    ^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
    {

        if(success != nil)
        {
            AskSessionResponseDomain *domain = [AskSessionResponseDomain objectFromJSONObject:JSON
                                                                                      mapping:[AskSessionResponseDomain mapping]];
         
            success(self, domain);
        }
        
        
    };
    
    void (^failed_local)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) =
    ^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
    {
        if(failed != nil)
        {
            failed(self, error);
        }
    };
    
    return [self internalBegin:params success:success_local failed:failed_local];
}

- (BOOL)internalBegin:(AskSessionParams *)params
              success:(void (^)(NSURLRequest *, NSHTTPURLResponse *, id))success
               failed:(void (^)(NSURLRequest *, NSHTTPURLResponse *, NSError *, id))failed
{
    
    if(params == nil)
    {
        return NO;
    }
    else
    {
        NSURLRequest *request = [self requestFromParams:params];
        
        if(request == nil)
        {
            return NO;
        }
        else
        {

            AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                                                 
                                                                                                success:
                                                 ^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
                                                 {
                                                     _lastResponseJSON = [NSString stringWithFormat:@"%@", JSON];
                                                     
                                                     if(success != nil)
                                                         success(request, response, JSON);
                                                 }
                                                 
                                                                                                failure:
                                                 ^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
                                                 {
                                                     _lastResponseJSON = [NSString stringWithFormat:@"%@", JSON];
                                                                                                          
                                                     if(failed != nil)
                                                         failed(request, response, error, JSON);
                                                     
                                                 }];
            

            
            [operation start];
            
            return YES;
        }
    }
}


@end
