//
//  PCMData.m
//  iOS_note
//
//  Created by allen0828 on 2022/7/8.
//

#import "PCMData.h"
#import <AudioToolbox/AudioToolbox.h>

#define MIN_SIZE_PER_FRAME 5000   //每个包的大小,室内机要求为960,具体看下面的配置信息
#define QUEUE_BUFFER_SIZE  3      //缓冲器个数
#define SAMPLE_RATE        44100 //采样频率

@interface PCMData() {
    AudioQueueRef audioQueue;                                 //音频播放队列
    AudioStreamBasicDescription _audioDescription;
    AudioQueueBufferRef audioQueueBuffers[QUEUE_BUFFER_SIZE]; //音频缓存
    BOOL audioQueueBufferUsed[QUEUE_BUFFER_SIZE];             //判断音频缓存是否在使用
    NSLock *sysnLock;
    NSMutableData *tempData;
    OSStatus osState;
}
@end

@implementation PCMData

- (instancetype)init {
    self = [super init];
    if (self) {
        sysnLock = [[NSLock alloc]init];
        _audioDescription.mSampleRate = SAMPLE_RATE;
        _audioDescription.mFormatID = kAudioFormatLinearPCM;
        _audioDescription.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
        _audioDescription.mChannelsPerFrame = 1;
        _audioDescription.mFramesPerPacket = 1;
        _audioDescription.mBitsPerChannel = 16;
        _audioDescription.mBytesPerFrame = (_audioDescription.mBitsPerChannel / 8) * _audioDescription.mChannelsPerFrame;
        _audioDescription.mBytesPerPacket = _audioDescription.mBytesPerFrame * _audioDescription.mFramesPerPacket;
        AudioQueueNewOutput(&_audioDescription, AudioPlayerAQInputCallback, (__bridge void * _Nullable)(self), nil, 0, 0, &audioQueue);
        AudioQueueSetParameter(audioQueue, kAudioQueueParam_Volume, 1.0);
        for (int i = 0; i < QUEUE_BUFFER_SIZE; i++) {
            audioQueueBufferUsed[i] = false;
            osState = AudioQueueAllocateBuffer(audioQueue, MIN_SIZE_PER_FRAME, &audioQueueBuffers[i]);
        }
        osState = AudioQueueStart(audioQueue, NULL);
        if (osState != noErr) {
            NSLog(@"AudioQueueStart Error");
        }
    }
    return self;
}

- (void)resetPlay {
    if (audioQueue != nil) {
        AudioQueueReset(audioQueue);
    }
}

// 播放相关
-(void)playWithData:(NSData *)data {
    
    [sysnLock lock];
    tempData = [NSMutableData new];
    [tempData appendData: data];
    // 得到数据
    NSUInteger len = tempData.length;
    Byte *bytes = (Byte*)malloc(len);
    [tempData getBytes:bytes length: len];
    
    int i = 0;
    while (true) {
        if (!audioQueueBufferUsed[i]) {
            audioQueueBufferUsed[i] = true;
            break;
        }else {
            i++;
            if (i >= QUEUE_BUFFER_SIZE) {
                i = 0;
            }
        }
    }
    
    audioQueueBuffers[i] -> mAudioDataByteSize =  (unsigned int)len;
    // 把bytes的头地址开始的len字节给mAudioData
    memcpy(audioQueueBuffers[i] -> mAudioData, bytes, len);

    if (bytes) {
        free(bytes);
    }
    AudioQueueEnqueueBuffer(audioQueue, audioQueueBuffers[i], 0, NULL);
    printf("本次播放数据大小: %lu", len);
    [sysnLock unlock];
}

// 回调回来把buffer状态设为未使用
static void AudioPlayerAQInputCallback(void* inUserData,AudioQueueRef audioQueueRef, AudioQueueBufferRef audioQueueBufferRef) {
    
    PCMData* player = (__bridge PCMData*)inUserData;
    [player resetBufferState:audioQueueRef and:audioQueueBufferRef];
}

- (void)resetBufferState:(AudioQueueRef)audioQueueRef and:(AudioQueueBufferRef)audioQueueBufferRef {
    for (int i = 0; i < QUEUE_BUFFER_SIZE; i++) {
        if (audioQueueBufferRef == audioQueueBuffers[i]) {
            audioQueueBufferUsed[i] = false;
        }
    }
}

- (void)dealloc {
    if (audioQueue != nil) {
        AudioQueueStop(audioQueue, true);
    }
    audioQueue = nil;
    sysnLock = nil;
    NSLog(@"dealloc----");
}



@end
