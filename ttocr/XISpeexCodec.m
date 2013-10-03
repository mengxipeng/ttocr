//
//  XISpeexCodec.m
//  speexdemo
//
//  Created by 波 李 on 11-12-21.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "XISpeexCodec.h"

@implementation XISpeexCodec


- (XISpeexCodec* ) initWithMode: (int)mode
{
    if(mode == 0)
    {
        encodeState = speex_encoder_init(&speex_nb_mode);
        decodeState = speex_decoder_init(&speex_nb_mode);
    }
    else if(mode == 1) 
    {
        encodeState = speex_encoder_init(&speex_wb_mode);
        decodeState = speex_decoder_init(&speex_wb_mode);
    }
    
    speex_bits_init(&bits);
    
    int quality=7;
	speex_encoder_ctl(encodeState, SPEEX_SET_QUALITY, &quality);
    
    int frameSize;
    speex_encoder_ctl(encodeState,SPEEX_GET_FRAME_SIZE,&frameSize);
    
    int enh=1;
	speex_decoder_ctl(decodeState, SPEEX_SET_ENH, &enh);
    
    buflen = frameSize*2;
    buf = malloc(buflen);
    
    return self;
}

- (int) getSamplingRate 
{
    int samplingRate=0;
    speex_encoder_ctl(encodeState,SPEEX_GET_SAMPLING_RATE,&samplingRate);
    return samplingRate;
}

- (int) getFrameSize
{
    int frameSize=0;
    speex_encoder_ctl(encodeState,SPEEX_GET_FRAME_SIZE,&frameSize);
    return frameSize;
}

- (NSData* )encode:(NSData*)inData
{
    NSMutableData* outData = [[NSMutableData alloc] init];
    
    const char* data = [inData bytes];
    unsigned long inlen = [inData length];
    
    int len;

    @synchronized(self)
    {
        for (int i=0; i<inlen; i+=buflen)
        {
            if (buflen > inlen - i) 
                break;
            
            speex_bits_reset(&bits);
            
            speex_encode_int(encodeState, (short*)(data+i), &bits);
            
            len = speex_bits_write(&bits, buf+1, buflen);
            
            (*buf) = (char)len;
            
            [outData appendBytes:buf length:len+1];

        }
    }
	return outData;
}

- (NSData* )decode:(NSData*)inData
{
    NSMutableData* outData = [[NSMutableData alloc] init];
    
    const char* data = [inData bytes];
    unsigned long inlen = [inData length];
    
    int len;
    
    @synchronized(self)
    {
        for (int i=0; i<inlen; i++)
        {
            len = *(data+i);
            
            speex_bits_read_from(&bits, (char*)(data+i+1), len);
            
            speex_decode_int(decodeState, &bits, (short*)buf);
            
            [outData appendBytes:buf length:buflen];
            
            i += len;
            
        }
    }
	return outData;
}

- (void) dealloc
{
    speex_encoder_destroy(encodeState);
    speex_decoder_destroy(decodeState);
	speex_bits_destroy(&bits);
    
    free(buf);
}

@end
