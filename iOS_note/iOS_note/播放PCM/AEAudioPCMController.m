//
//  AEAudioPCMController.m
//  iOS_note
//
//  Created by allen0828 on 2022/7/7.
//

#import "AEAudioPCMController.h"
// 使用 AudioToolbox
#import <AudioToolbox/AudioToolbox.h>

#import "PCMData.h"

// 队列缓冲个数
#define QUEUE_BUFFER_SIZE 4
// 每次从文件读取的长度
#define EVERY_READ_LENGTH 1000
// 每帧最小数据长度
#define MIN_SIZE_PER_FRAME 2000

@interface AEAudioPCMController () {

    AudioStreamBasicDescription audioDescription;///音频参数
    AudioQueueRef audioQueue;//音频播放队列
    AudioQueueBufferRef audioQueueBuffers[QUEUE_BUFFER_SIZE];//音频缓存
    NSLock *synlock ;///同步控制
    UInt8 *pcmDataBuffer;//pcm的读文件数据区
    FILE *file;//pcm源文件
}

@end


static void AudioPlayerAQInputCallback(void* input, AudioQueueRef outQ, AudioQueueBufferRef outQB) {
    NSLog(@"AudioPlayerAQInputCallback");
    AEAudioPCMController *vc = (__bridge AEAudioPCMController *)input;
    [vc readPCMAndPlay:outQ buffer:outQB];
}


@implementation AEAudioPCMController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;

    UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(50, 300, 250, 35)];
    btn.backgroundColor = UIColor.redColor;
    [btn setTitle:@"播放" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(play) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];

    UIButton *btn1 = [[UIButton alloc]initWithFrame:CGRectMake(50, 400, 250, 35)];
    btn1.backgroundColor = UIColor.redColor;
    [btn1 setTitle:@"暂停" forState:UIControlStateNormal];
    [btn1 addTarget:self action:@selector(pause) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn1];
    UIButton *btn2 = [[UIButton alloc]initWithFrame:CGRectMake(50, 500, 250, 35)];
    btn2.backgroundColor = UIColor.redColor;
    [btn2 setTitle:@"继续" forState:UIControlStateNormal];
    [btn2 addTarget:self action:@selector(resume) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn2];
}

- (void)play {
    // data
    PCMData *pcm = [PCMData new];
    [pcm resetPlay];
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle]pathForResource:@"alove" ofType:@"pcm"]];
    NSData *data = [[NSData alloc] initWithContentsOfURL:url];
    NSMutableData *mData = [[NSMutableData alloc] initWithData:data];
    NSInteger tem = 5000;
    NSInteger count = mData.length/tem + 1;
    for (int i=0; i<count; i++) {
        NSData *subData;
        if (i == count-1) {
            subData  =[mData subdataWithRange:NSMakeRange(i*tem, mData.length-i*tem)];
        }else{
            subData  =[mData subdataWithRange:NSMakeRange(i*tem, tem)];
        }
        NSLog(@"数据i------：%d",i);
        [pcm playWithData:subData];
    }
    
    // file
//    [self initFile];
//    [self initAudio];
//
//    AudioQueueStart(audioQueue, NULL);
//
//    for(int i=0; i<QUEUE_BUFFER_SIZE; i++) {
//        [self readPCMAndPlay:audioQueue buffer:audioQueueBuffers[i]];
//    }
}

- (void)pause {

    OSStatus status = AudioQueuePause(audioQueue);
    if (status != noErr) {
        NSLog(@"Audio Player: Audio Queue pause failed status:%d \n",(int)status);
    }else {
        NSLog(@"Audio Player: Audio Queue pause successful");
    }
}

- (void)resume {
    OSStatus status = AudioQueueStart(audioQueue, NULL);
    if (status != noErr) {
        NSLog(@"Audio Player: Audio Queue resume failed status:%d \n",(int)status);
    }else {
        NSLog(@"Audio Player: Audio Queue resume successful");
    }
}

- (void)stop {
    OSStatus stopRes = AudioQueueStop(audioQueue, true);
    if (stopRes == noErr){
        NSLog(@"Audio Player: stop Audio Queue success.");
    }else{
        NSLog(@"Audio Player: stop Audio Queue failed.");
    }
}

- (void)dispose {
    if (audioQueue) {
        for(int i=0; i<QUEUE_BUFFER_SIZE; i++) {
            AudioQueueFreeBuffer(audioQueue, audioQueueBuffers[i]);
        }
        OSStatus status = AudioQueueDispose(audioQueue, true);
        if (status != noErr) {
            NSLog(@"Audio Player: Dispose failed: %d",status);
        }else {
            audioQueue = NULL;
            NSLog(@"Audio Player: free AudioQueue successful.");
        }
    }
}

- (void)initFile {
    NSString *filepath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"alove.pcm"];
    NSLog(@"filepath = %@",filepath);
    NSFileManager *manager = [NSFileManager defaultManager];
    NSLog(@"file exist = %d",[manager fileExistsAtPath:filepath]);
    NSLog(@"file size = %lld",[[manager attributesOfItemAtPath:filepath error:nil] fileSize]) ;

    file = fopen([filepath UTF8String], "r");
    if(file) {
        fseek(file, 0, SEEK_SET);
        pcmDataBuffer = malloc(EVERY_READ_LENGTH);
    } else{
        NSLog(@"initFile error");
        return;
    }
    synlock = [[NSLock alloc] init];
}

- (void)initAudio {
    // 采样率
    audioDescription.mSampleRate = 44100;
    audioDescription.mFormatID = kAudioFormatLinearPCM;
//    // 声道数
    audioDescription.mChannelsPerFrame = 2;
    audioDescription.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
//    // 每个采样点16bit量化
    audioDescription.mBitsPerChannel = 16;

    audioDescription.mBytesPerFrame = (audioDescription.mBitsPerChannel/8) * audioDescription.mChannelsPerFrame;
    audioDescription.mBytesPerPacket = audioDescription.mBytesPerFrame;

    // 每一个packet数据
    audioDescription.mFramesPerPacket = 1;

    ///创建一个新的从audioqueue到硬件层的通道
    AudioQueueNewOutput(&audioDescription, AudioPlayerAQInputCallback, (__bridge void * _Nullable)(self), nil, nil, 0, &audioQueue);//使用player的内部线程播
    ////添加buffer区
    for(int i=0;i<QUEUE_BUFFER_SIZE;i++) {
        /// 创建buffer区，MIN_SIZE_PER_FRAME为每一侦所需要的最小的大小，该大小应该比每次往buffer里写的最大的一次还大
        int result =  AudioQueueAllocateBuffer(audioQueue, MIN_SIZE_PER_FRAME, &audioQueueBuffers[i]);
        NSLog(@"AudioQueueAllocateBuffer i = %d,result = %d",i,result);
    }
}


- (void)readPCMAndPlay:(AudioQueueRef)outQ buffer:(AudioQueueBufferRef)outQB {
    [synlock lock];
    unsigned long readLength = fread(pcmDataBuffer, 1, EVERY_READ_LENGTH, file);//读取文件
    NSLog(@"read raw data size = %ld",readLength);
    outQB->mAudioDataByteSize = (UInt32)readLength;
    Byte *audiodata = (Byte *)outQB->mAudioData;
    for(int i=0; i<readLength; i++) {
        audiodata[i] = pcmDataBuffer[i];
    }
    /*
     将创建的buffer区添加到audioqueue里播放
     AudioQueueBufferRef用来缓存待播放的数据区
     AudioQueueBufferRef有两个比较重要的参数
     AudioQueueBufferRef->mAudioDataByteSize用来指示数据区大小
     AudioQueueBufferRef->mAudioData用来保存数据区
     */
    AudioQueueEnqueueBuffer(outQ, outQB, 0, NULL);
    [synlock unlock];
}



@end
