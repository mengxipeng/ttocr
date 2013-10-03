//
//  XISpeexCodec.h
//  speexdemo
//
//  Created by 波 李 on 11-12-21.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#include "speex/speex.h"

@interface XISpeexCodec : NSObject {
    void *encodeState;
    void *decodeState;
    SpeexBits bits;
    char *buf;
    int buflen;
}

- (XISpeexCodec* ) initWithMode: (int)mode;

- (int) getSamplingRate;

- (int) getFrameSize;

- (NSData* )encode: (NSData*)inData;

- (NSData* )decode: (NSData*)inData;

@end
