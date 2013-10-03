//
//  AskSessionResponse.h
//  iknowapp
//
//  Created by Peter Liu on 8/24/12.
//  Copyright (c) 2012 xiaoi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSObject+JTObjectMapping.h"

@interface AskSessionResponseDomainPlugIn : NSObject

@property (nonatomic, strong) NSString                      *ID;
@property (nonatomic, strong) NSString                      *name;
@property (nonatomic, strong) NSArray                       *args;

+ (NSDictionary *)mapping;

@end

@interface AskSessionResponseDomain : NSObject
{

}

@property (nonatomic, strong) NSString                          *type;
@property (nonatomic, strong) NSString                          *content;
@property (nonatomic, strong) NSArray                           *callsJSON;
@property (nonatomic, strong) NSString                          *tts;
@property (nonatomic, strong) NSArray                           *buttonsJSON;
@property (nonatomic, strong) NSDictionary                      *pluginJSON;
@property (nonatomic, strong) NSString                          *state;
@property (nonatomic, strong) NSString                          *record;

+ (NSArray *)buttonsFromJSON:(NSArray *)btnsJSON;
+ (AskSessionResponseDomainPlugIn *)pluginFromJSON:(NSDictionary *)pluginJSON;
+ (NSArray *)callsFromnJSON:(NSArray *)callsJSON;

+ (NSDictionary *)mapping;

@end

@interface AskSessionResponseDomainButton : NSObject
@property (nonatomic, strong) NSString                      *content;
@property (nonatomic, strong) NSString                      *params;
@property (nonatomic, strong) NSString                      *action;
@property (nonatomic, strong) NSString                      *caption;
@property (nonatomic, strong) NSString                      *tts;

+ (NSDictionary *)mapping;


@end


