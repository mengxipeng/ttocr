//
//  AudioQueueService.h
//  xiaoi
//
//  Created by 超 张 on 11-12-24.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>


#define kSampleRate 8000   //16000
#define kPackagesCount 320  //320

@protocol AudioQueueServeiceDelegate;

@interface AudioQueueService : NSObject{
    BOOL m_bIsPlaying;
    BOOL m_bIsRecording;
    
    int  m_iLastLevel;
    
    /* automatic stop */
    //float m_fShortEnerge;
    float m_fLastValue;
    //int  m_iZeroCount;
    
    float m_fEh;
    float m_fZh;
    float m_fEl;
    float m_fZl;
    float m_fdelta;
    int   m_iN;
    int   m_iM;
    
    int   m_iAudioDidInputCount;
    int   m_iAudioDidEndCount;
    
    BOOL  m_bAudioDidInput;
    
    NSMutableArray *m_mutableArrayRecord;    
}

@property (nonatomic) float                     m_fVolume;
@property (nonatomic) void                      *m_buffer;
@property (nonatomic) AudioQueueRef             m_audioQueueObject;
@property (nonatomic) UInt32                    m_iPacketsToRead;
@property (nonatomic) UInt32                    m_iPacketsToWrite;
@property (nonatomic) SInt64                    m_iCurrentPacketCount;
@property (nonatomic) SInt64                    m_iMaxPacketCount;
@property (nonatomic) SInt32                    m_iAudioSize;

@property (nonatomic) BOOL                      m_bAutomaticStop;
@property (nonatomic) BOOL                      m_bStopRecording;

@property (nonatomic, unsafe_unretained) id <AudioQueueServeiceDelegate> delegate;

- (void) initRecording;
- (void) record;
- (void) setPlayerData: (NSData *)dataAudio;
- (void) play;
- (void) stopRecording;
- (void) stopPlaying;
- (BOOL) isPlaying;
- (BOOL) isRecording;

@end

@protocol AudioQueueServeiceDelegate <NSObject>

@optional 
- (void) audioPlayDidFinished;
- (void) audioRecordDidFinished: (NSData *) dataAudio;
- (void) updateLevelMeter: (int) iValue;
@end
