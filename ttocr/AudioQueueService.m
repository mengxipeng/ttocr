//
//  AudioQueueService.m
//  xiaoi
//
//  Created by 超 张 on 11-12-24.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "AudioQueueService.h"

static void MyAudioQueueInputCallback(
                                      void                                *inUserData,
                                      AudioQueueRef                       inAQ,
                                      AudioQueueBufferRef                 inBuffer,
                                      const AudioTimeStamp                *inStartTime,
                                      UInt32                              inNumberPacketDescriptions,
                                      const AudioStreamPacketDescription  *inPacketDescs);
static void MyAudioQueueOutputCallback(
                                       void                 *inUserData,
                                       AudioQueueRef        inAQ,
                                       AudioQueueBufferRef  inBuffer);

@interface AudioQueueService ()
- (void)prepareAudioQueueForPlay;
- (void)readPackets:(AudioQueueBufferRef)inBuffer;
@end

@implementation AudioQueueService

@synthesize m_fVolume;
@synthesize m_buffer;
@synthesize m_audioQueueObject;
@synthesize m_iPacketsToRead;
@synthesize m_iPacketsToWrite;
@synthesize m_iCurrentPacketCount;
@synthesize m_iMaxPacketCount;
@synthesize m_iAudioSize;
@synthesize delegate;

@synthesize m_bAutomaticStop;
@synthesize m_bStopRecording;

- (id)init
{
    self = [super init];
    if (self) {
        self.m_audioQueueObject = nil;
        m_bIsPlaying = NO;
        m_fVolume = 1.0f;
    }
    return self;
}

- (void) initRecording
{
    UInt32  bytesPerPacket = 2;
    UInt32  sec = 10;
    self.m_iCurrentPacketCount = 0;
    self.m_iMaxPacketCount = (kSampleRate * sec);
    self.m_buffer = malloc(m_iMaxPacketCount * bytesPerPacket);
    
    m_bAutomaticStop = YES;
    
    m_fLastValue = 0;
    
    m_fEh = 0.1;
    m_fZh = 4;
    m_fEl = 0.05;
    m_fZl = 3;
    m_fdelta = 0.03;
    m_iN = 5; //3;
    m_iM = 35;
    
    m_iAudioDidInputCount = 0;
    m_iAudioDidEndCount = 0;
    
    m_bAudioDidInput = NO;
    m_bStopRecording = NO;
    
    m_iLastLevel = 0;
    
    m_mutableArrayRecord = [NSMutableArray array];    
}

- (void)prepareAudioQueueForRecord
{    
    AudioStreamBasicDescription audioFormat;
    audioFormat.mSampleRate         = kSampleRate;
    audioFormat.mFormatID           = kAudioFormatLinearPCM;
    audioFormat.mFormatFlags        = kLinearPCMFormatFlagIsSignedInteger
    | kLinearPCMFormatFlagIsPacked;
    
    audioFormat.mFramesPerPacket    = 1;
    audioFormat.mChannelsPerFrame   = 1;
    audioFormat.mBitsPerChannel     = 16;  //16
    audioFormat.mBytesPerPacket     = 2;
    audioFormat.mBytesPerFrame      = 2;
    audioFormat.mReserved           = 0;
    
    AudioQueueNewInput(&audioFormat, MyAudioQueueInputCallback, (__bridge void *)self, NULL, NULL, 0, &m_audioQueueObject);
    
    m_iCurrentPacketCount = 0;
    AudioQueueBufferRef buffers[3];
    
    m_iPacketsToWrite = kPackagesCount;
    UInt32  bufferByteSize = m_iPacketsToWrite * audioFormat.mBytesPerPacket;
    
    int bufferIndex;
    for (bufferIndex = 0; bufferIndex < 3; bufferIndex++) {
        AudioQueueAllocateBuffer(m_audioQueueObject, bufferByteSize, &buffers[bufferIndex]);
        AudioQueueEnqueueBuffer(m_audioQueueObject, buffers[bufferIndex], 0, NULL);
    }
    
}

- (void)prepareAudioQueueForPlay
{
    AudioStreamBasicDescription audioFormat;
    audioFormat.mSampleRate         = kSampleRate;
    audioFormat.mFormatID           = kAudioFormatLinearPCM;
    audioFormat.mFormatFlags        = kLinearPCMFormatFlagIsPacked | kAudioFormatFlagIsSignedInteger;;
    
    audioFormat.mFramesPerPacket    = 1;
    audioFormat.mChannelsPerFrame   = 1;
    audioFormat.mBitsPerChannel     = 16;
    audioFormat.mBytesPerPacket     = 2;
    audioFormat.mBytesPerFrame      = 2;
    audioFormat.mReserved           = 0;
    
    /* attention here */
    AudioQueueNewOutput(&audioFormat, MyAudioQueueOutputCallback, (__bridge void *)self, nil, nil, 0, &m_audioQueueObject);
    
    m_iCurrentPacketCount = 0;
    AudioQueueBufferRef buffers[3];
    
    m_iPacketsToRead = kPackagesCount;
    UInt32  bufferByteSize = m_iPacketsToRead * audioFormat.mBytesPerPacket;
    
    int bufferIndex;
    for (bufferIndex = 0; bufferIndex < 3; bufferIndex++) {
        AudioQueueAllocateBuffer(m_audioQueueObject, bufferByteSize, &buffers[bufferIndex]);
        MyAudioQueueOutputCallback((__bridge void *) self, m_audioQueueObject, buffers[bufferIndex]);
    }
    
    AudioQueueParameterValue    volume = m_fVolume;
    AudioQueueSetParameter(m_audioQueueObject, kAudioQueueParam_Volume, volume);
    
    //AudioQueueSetParameter(m_audioQueueObject, kAudioQueueParam_Pan, 1);
}

- (void)readPackets:(AudioQueueBufferRef)inBuffer
{
    UInt32  bytesPerPacket = 2;
    UInt32  numPackets = m_iMaxPacketCount - m_iCurrentPacketCount;
    if (m_iPacketsToRead < numPackets) {
        numPackets = m_iPacketsToRead;
    }
    
    if (0 < numPackets) {
        memcpy(inBuffer->mAudioData,
               (m_buffer + (bytesPerPacket * m_iCurrentPacketCount)),
               (bytesPerPacket * numPackets));
        inBuffer->mAudioDataByteSize = (bytesPerPacket * numPackets);
        inBuffer->mPacketDescriptionCount = numPackets;
        m_iCurrentPacketCount += numPackets;
    }
    else {
        inBuffer->mAudioDataByteSize = 0;
        inBuffer->mPacketDescriptionCount = 0;
    }
}

- (void)writePackets:(AudioQueueBufferRef)inBuffer
{
    UInt32  bytesPerPacket = 2;
    UInt32  numPackets = (inBuffer->mAudioDataByteSize / bytesPerPacket);    
    
    if ( !m_buffer ) {
        return ;
    }
    
    if ((m_iMaxPacketCount - m_iCurrentPacketCount) < numPackets) {
        numPackets = (m_iMaxPacketCount - m_iCurrentPacketCount);
    }
    
    if (0 < numPackets) {
        memcpy((self.m_buffer + (bytesPerPacket * m_iCurrentPacketCount)),
                   inBuffer->mAudioData,
                   (bytesPerPacket * numPackets));
        m_iCurrentPacketCount += numPackets;            
    }
    
    float fShortEnerge = 0;
    int   iZeroCount = 0;
    
    float fAbsMaxValue = 0;
    
    /* 计算短时能量 */
    for ( int i = 0 ; i < numPackets; i++ ) {
        float fValue = (float)(*(((SInt16 *)inBuffer->mAudioData) + i) / 32768.0);
        
        float fAbsValue = fabsf( fValue );
        if ( fAbsMaxValue < fAbsValue ) {
            fAbsMaxValue = fAbsValue;
        }
        
        if (( ((m_fLastValue > 0) && (fValue < 0) ) || ((m_fLastValue < 0) && (fValue > 0)) ) 
            && ( fabsf( m_fLastValue - fValue ) > m_fdelta ) ){
            iZeroCount++;
        }
         
        m_fLastValue = fValue;

        fShortEnerge += fValue * fValue;
    }
    
    /* for level meter */
    int iBaseValue = 600;
    int iAbsMaxValue = fAbsMaxValue * 1000;
    
    int iLevel = iAbsMaxValue * 1400 / (1000 - iBaseValue);
    
    iLevel = iLevel/100;
    
    iLevel++;
    if ( iLevel > 14 ) {
        iLevel = 14;
    }
    
    if ( m_iLastLevel != iLevel ) {
        if ( self.delegate && [delegate respondsToSelector: @selector(updateLevelMeter:)] ) {
            [self.delegate updateLevelMeter: iLevel];
        }
    }
    
    m_iLastLevel = iLevel;
    
    if ( m_bAutomaticStop ) {
        /* 如果（E > Eh || Z>Zh) 表示可能检测到语音活动，如果连续N次检测到判定存在语音活动。 */
        if ( (fShortEnerge > m_fEh) || (iZeroCount > m_fZh) ) {
            m_iAudioDidInputCount++;
        }else{
            m_iAudioDidInputCount = 0;
        }
        
        if ( m_iAudioDidInputCount >= m_iN ){
            m_bAudioDidInput = YES;
        }
        
        /* 如果 ( E<El && Z<Zl ) 表示可能检测到语音活动结束，如果连续M次检测到则判定语音活动结束。 */
        if ( m_bAudioDidInput ) {
            if ( (fShortEnerge < m_fEl) && (iZeroCount < m_fZl) ) {
                m_iAudioDidEndCount++;
            }else{
                m_iAudioDidEndCount = 0;
            }
        }
        
        if ( m_iAudioDidEndCount >=  m_iM ) {
            [self stopRecording];
        }
    }
    
    if ( ![NSThread isMainThread] ) {
        NSLog( @"-----------recording" );
        if([[NSThread currentThread] isCancelled])
        {
            [self stopRecording];
            
            //[NSThread exit];//终止线程
        }
    }
 
    if ( m_bStopRecording ){
        NSLog(@" stop by button ");
        
        [self stopRecording];
    }
}

- (void) record
{
    if (self.m_audioQueueObject)
        return;
    
    [self prepareAudioQueueForRecord];
    
    OSStatus err = AudioQueueStart(m_audioQueueObject, NULL);
    
    if (err) {
        NSLog(@"record error!");
    }
    
    m_bIsRecording = YES;
}

- (void) setPlayerData: (NSData *)dataAudio
{
    int iAudioSize = [dataAudio length];
    self.m_buffer = malloc( iAudioSize );
    
    memcpy(m_buffer, (UInt16 *)[dataAudio bytes], iAudioSize);
    
    m_iMaxPacketCount = iAudioSize/2;
}

- (void) play
{
    if (m_audioQueueObject)
        return;
        
    [self prepareAudioQueueForPlay];
    
    OSStatus err = AudioQueueStart(m_audioQueueObject, NULL);
    
    if ( err ) {
        NSLog(@"start play error!");
    }else{
        m_bIsPlaying = YES;
    }
}

- (void) stopRecording
{
    m_bAutomaticStop = NO;
    
    m_bIsRecording = NO;
    
    if ( self.delegate && [delegate respondsToSelector: @selector(audioRecordDidFinished:)] ) {
        if ( m_buffer ) {
            int iBytesPerPack = 2;
            NSData *dataAudio = [NSData dataWithBytes: m_buffer length: m_iCurrentPacketCount * iBytesPerPack];
            
            if ( m_bAudioDidInput ) {
                [self.delegate audioRecordDidFinished: dataAudio];
            }else{
                [self.delegate audioRecordDidFinished: nil];
            }
        }
    }
    
    AudioQueueStop(m_audioQueueObject, YES);
    AudioQueueDispose(m_audioQueueObject, YES);
    m_audioQueueObject = NULL;
    
    if ( m_buffer ){
        free( m_buffer );
        m_buffer = nil;
    }
}

- (void) stopPlaying
{    
    AudioQueueStop(m_audioQueueObject, YES);
    AudioQueueDispose(m_audioQueueObject, YES);
    m_audioQueueObject = NULL;
    m_bIsPlaying = NO;
    
    if ( m_buffer ){
        free( m_buffer );
        m_buffer = nil;
    }
    
    if ( self.delegate && [delegate respondsToSelector: @selector(audioPlayDidFinished)] ) {
        [delegate audioPlayDidFinished];
    }
}

- (BOOL) isPlaying
{
    return m_bIsPlaying;
}

- (BOOL) isRecording
{
    return m_bIsRecording;
}

@end


static void MyAudioQueueInputCallback(
                                      void                                *inUserData,
                                      AudioQueueRef                       inAQ,
                                      AudioQueueBufferRef                 inBuffer,
                                      const AudioTimeStamp                *inStartTime,
                                      UInt32                              inNumberPacketDescriptions,
                                      const AudioStreamPacketDescription  *inPacketDescs)
{
    AudioQueueService    *aqService = (__bridge AudioQueueService *) inUserData;
    [aqService writePackets: inBuffer];
    AudioQueueEnqueueBuffer(inAQ, inBuffer, 0, NULL);
    
    if (aqService.m_iMaxPacketCount <= aqService.m_iCurrentPacketCount) {
        [aqService stopRecording];
    }
}


static void MyAudioQueueOutputCallback(
                                       void                 *inUserData,
                                       AudioQueueRef        inAQ,
                                       AudioQueueBufferRef  inBuffer)
{
    AudioQueueService    *aqService = (__bridge AudioQueueService *) inUserData;
    [aqService readPackets:inBuffer];
    AudioQueueEnqueueBuffer(inAQ, inBuffer, 0, NULL);
    
    if ( aqService.m_iMaxPacketCount <= aqService.m_iCurrentPacketCount ) {
        [aqService stopPlaying];
    }
}

