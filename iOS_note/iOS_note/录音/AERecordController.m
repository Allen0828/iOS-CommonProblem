//
//  AERecordController.m
//  iOS_note
//
//  Created by gw_pro on 2022/5/25.
//

#import "AERecordController.h"

#import <AVFoundation/AVFoundation.h>

@interface AERecordController () <AVAudioRecorderDelegate>

@property (nonatomic,strong) AVAudioRecorder *recorder;
@property (nonatomic,copy) NSString *name;

@end

@implementation AERecordController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
    
    
   

}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    AVAudioSession * session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [session setActive:YES error:nil];
    //录音设置
    NSMutableDictionary * recordSetting = [[NSMutableDictionary alloc]init];
    //设置录音格式 kAudioFormatLinearPCM kAudioFormatMPEG4AAC
    [recordSetting  setValue:[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey:AVFormatIDKey];
    //设置录音采样率（HZ）
    [recordSetting setValue:[NSNumber numberWithFloat:8000] forKey:AVSampleRateKey];
    //录音通道数
    [recordSetting setValue:[NSNumber  numberWithInt:1] forKey:AVNumberOfChannelsKey];
    //线性采样位数
    [recordSetting  setValue:[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];

     
    //获取沙盒路径 作为存储录音文件的路径
    NSString * strUrl = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)lastObject];
    NSLog(@"path = %@",strUrl);
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    self.name = [formatter stringFromDate:[NSDate date]];
    NSLog(@"%@",self.name);
    //创建url
    NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@.wav",strUrl,self.name]];
    //            self.urlPlay = url;
    NSError * error ;
    //初始化AVAudioRecorder
    self.recorder = [[AVAudioRecorder alloc]initWithURL:url settings:recordSetting error:&error];
    //开启音量监测
    self.recorder.meteringEnabled = YES;
    self.recorder.delegate = self;
    if(error){
        NSLog(@"创建录音对象时发生错误，错误信息：%@",error.localizedDescription);
    }
    [self.recorder prepareToRecord];
    
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayAndRecord error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    
    [self.recorder record];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.recorder stop];
    });
}


-(void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag {
    NSLog(@"flag=%d",flag);
}
-(void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error {
    NSLog(@"error=%@",error);
}


@end
