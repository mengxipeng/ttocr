//
//  AskSessionResponse.m
//  iknowapp
//
//  Created by Peter Liu on 8/24/12.
//  Copyright (c) 2012 xiaoi. All rights reserved.
//

#import "AskSessionResponseDomain.h"
#import "NSObject+JTObjectMapping.h"

@implementation AskSessionResponseDomainButton

+ (NSDictionary *)mapping
{
    NSDictionary *ret = [NSDictionary dictionaryWithObjectsAndKeys:
                         @"content", @"content",
                         @"params", @"params",
                         @"action", @"action",
                         @"caption", @"caption",
                         @"tts", @"tts",
                         nil];
    
    return ret;
}

@end

@implementation AskSessionResponseDomainPlugIn

+ (NSDictionary *)mapping
{
    NSDictionary *ret = [NSDictionary dictionaryWithObjectsAndKeys:
                         @"ID", @"id",
                         @"name", @"name",
                         @"args", @"args",
                         nil];
    
    return ret;
}



@end

@implementation AskSessionResponseDomain


+ (NSDictionary *)mapping
{
    NSDictionary *ret = [NSDictionary dictionaryWithObjectsAndKeys:
                         @"type", @"type",
                         @"content", @"content",
                         @"callsJSON", @"calls",
                         @"tts", @"tts",
                         @"buttonsJSON", @"buttons",
                         @"pluginJSON", @"plugin",
                         @"state", @"state",
                         @"record", @"record",
                         nil];
    
    return ret;
}

+ (NSArray *)buttonsFromJSON:(NSArray *)btnsJSON
{
    NSMutableArray *arrayBtns = [[NSMutableArray alloc] initWithCapacity:3];
    
    for(NSDictionary *btnJSON in btnsJSON)
    {
        AskSessionResponseDomainButton *btn = [AskSessionResponseDomainButton objectFromJSONObject:btnJSON
                                                                                           mapping:[AskSessionResponseDomainButton mapping]];
        
        [arrayBtns addObject:btn];
    }
    
    return arrayBtns;
}


+ (AskSessionResponseDomainPlugIn *)pluginFromJSON:(NSDictionary *)pluginJSON;
{
    AskSessionResponseDomainPlugIn* ret = [AskSessionResponseDomainPlugIn objectFromJSONObject:pluginJSON
                                                                                       mapping:[AskSessionResponseDomainPlugIn mapping]];
    
    return ret;
    
}

+ (NSArray *)callsFromnJSON:(NSArray *)callsJSON
{
    return nil;
}

@end
