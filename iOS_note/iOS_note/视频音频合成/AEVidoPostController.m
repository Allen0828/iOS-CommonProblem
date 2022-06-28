//
//  AEVidoPostController.m
//  iOS_note
//
//  Created by gw_pro on 2022/6/9.
//

#import "AEVidoPostController.h"
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>

@interface AEVidoPostController ()
{
    AVMutableComposition *_mixComposition;

}

@end

@implementation AEVidoPostController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
    
    UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(30, 88, 250, 35)];
    btn.backgroundColor = UIColor.redColor;
    [btn setTitle:@"自定义音频合成视频带水印" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(mixing) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    UIButton *btn1 = [[UIButton alloc]initWithFrame:CGRectMake(30, 200, 250, 35)];
    btn1.backgroundColor = UIColor.redColor;
    [btn1 setTitle:@"视频带水印" forState:UIControlStateNormal];
    [btn1 addTarget:self action:@selector(addWatermarkImg) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn1];

}

- (void)mixing {
    NSString *outPath = [NSString stringWithFormat:@"%@test001.mp4",NSTemporaryDirectory()];
    
    NSURL *audioInputUrl = [NSURL fileURLWithPath: [[NSBundle mainBundle]pathForResource:@"111" ofType:@"mp3"]];
    NSURL *videoInputUrl = [NSURL fileURLWithPath: [[NSBundle mainBundle]pathForResource:@"002" ofType:@"mp4"]];
    NSURL *outputFileUrl = [NSURL fileURLWithPath: outPath];
    if ([[NSFileManager defaultManager] fileExistsAtPath:outPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:outPath error:nil];
    }
    CMTime timeZero = kCMTimeZero;
    AVMutableComposition *comosition = [AVMutableComposition composition];
    
    AVURLAsset *videoAsset = [[AVURLAsset alloc] initWithURL:videoInputUrl options:nil];
    CMTimeRange videoTimeRange = CMTimeRangeMake(kCMTimeZero, videoAsset.duration);
    AVMutableCompositionTrack *videoTrack = [comosition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    AVAssetTrack *videoAssetTrack = [[videoAsset tracksWithMediaType:AVMediaTypeVideo] firstObject];
    [videoTrack insertTimeRange:videoTimeRange ofTrack:videoAssetTrack atTime:timeZero error:nil];
    
    AVURLAsset *audioAsset = [[AVURLAsset alloc] initWithURL:audioInputUrl options:nil];
    
    CGFloat videoDuration = (CGFloat)videoAsset.duration.value / videoAsset.duration.timescale;
    CGFloat audioDuration = (CGFloat)audioAsset.duration.value / audioAsset.duration.timescale;
    
    if (false) { // self.useAudioDuration
        CMTimeRange audioTimeRange;
        audioTimeRange = CMTimeRangeMake(kCMTimeZero, audioAsset.duration);

        AVMutableCompositionTrack *audioTrack = [comosition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        AVAssetTrack *audioAssetTrack = [[audioAsset tracksWithMediaType:AVMediaTypeAudio] firstObject];
        [audioTrack insertTimeRange:audioTimeRange ofTrack:audioAssetTrack atTime:timeZero error:nil];
    } else {
        NSInteger count = (NSInteger)ceil(videoDuration / audioDuration);
        __block AVURLAsset *audioAsset;
        dispatch_group_t group = dispatch_group_create();
        dispatch_group_enter(group);
        if (count < 2) {
            audioAsset = [[AVURLAsset alloc] initWithURL:audioInputUrl options:nil];
            dispatch_group_leave(group);
        } else {
            AVURLAsset *aAsset = [[AVURLAsset alloc] initWithURL:audioInputUrl options:nil];
            AVMutableComposition *audioCompostion = [AVMutableComposition composition];
            NSMutableArray <AVMutableCompositionTrack *> *audioCompositionTrackArr = [NSMutableArray arrayWithCapacity:0];
            NSMutableArray <AVAssetTrack *> *audioAssetTrackArr = [NSMutableArray arrayWithCapacity:0];
            for (int i=0; i<count; i++) {
                AVMutableCompositionTrack *audioCompositionTrack = [audioCompostion addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:0];
                [audioCompositionTrackArr addObject:audioCompositionTrack];
                AVAssetTrack *audioAssetTrack = [[aAsset tracksWithMediaType:AVMediaTypeAudio] firstObject];
                [audioAssetTrackArr addObject:audioAssetTrack];
            }
            CMTime cmTime = kCMTimeZero;
            for (int i=0; i<count; i++) {
                if (i == 0) {
                    cmTime = kCMTimeZero;
                } else {
                    cmTime = CMTimeAdd(cmTime, aAsset.duration);
                }
                [audioCompositionTrackArr[i] insertTimeRange:CMTimeRangeMake(kCMTimeZero, aAsset.duration) ofTrack:audioAssetTrackArr[i] atTime:cmTime error:nil];
            }
            AVAssetExportSession *session = [[AVAssetExportSession alloc] initWithAsset:audioCompostion presetName:AVAssetExportPresetAppleM4A];
            NSArray *libPaths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
            NSString *libDirectory = [libPaths objectAtIndex:0];
            NSString *outPutFilePath = [NSString stringWithFormat:@"%@/tempBGAudio.m4a", libDirectory];
            if ([[NSFileManager defaultManager] fileExistsAtPath:outPutFilePath]) {
                [[NSFileManager defaultManager] removeItemAtPath:outPutFilePath error:nil];
            }
            session.outputURL = [NSURL fileURLWithPath:outPutFilePath];
            session.outputFileType = @"com.apple.m4a-audio";
            session.shouldOptimizeForNetworkUse = YES;
            [session exportAsynchronouslyWithCompletionHandler:^{
                audioAsset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:outPutFilePath] options:nil];
                dispatch_group_leave(group);
            }];
        }
            
            
        dispatch_group_notify(group, dispatch_get_main_queue(), ^{
            CMTimeRange audioTimeRange;
            audioTimeRange = CMTimeRangeMake(kCMTimeZero, videoAsset.duration);
            AVMutableCompositionTrack *audioTrack = [comosition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
            AVAssetTrack *audioAssetTrack = [[audioAsset tracksWithMediaType:AVMediaTypeAudio] firstObject];
            [audioTrack insertTimeRange:audioTimeRange ofTrack:audioAssetTrack atTime:timeZero error:nil];
            
            
            CGSize videoSize = [videoTrack naturalSize];
            UIImage *myImage = [UIImage imageNamed:@"pic_front"];
            CALayer *imgLay = [CALayer layer];
            imgLay.contents = (__bridge id _Nullable)(myImage.CGImage);
            imgLay.frame = CGRectMake(100, 100, 200, 200);
            imgLay.opacity = 1.0;
            CALayer *parentLayer = [CALayer layer];
            parentLayer.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);;
            CALayer *videoLayer = [CALayer layer];
            videoLayer.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
            [parentLayer addSublayer:videoLayer];
            [parentLayer addSublayer:imgLay];
            parentLayer.geometryFlipped = true;
            
            double fps = [[[comosition tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] nominalFrameRate];

            AVMutableVideoComposition *videoWorkbench = [AVMutableVideoComposition videoComposition];
            videoWorkbench.frameDuration = CMTimeMake(1, fps);
            videoWorkbench.renderSize = videoSize;
            videoWorkbench.animationTool = [AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];
            
            AVMutableVideoCompositionInstruction *videoinstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
            videoinstruction.timeRange = CMTimeRangeMake(kCMTimeZero, [comosition duration]);
            AVAssetTrack *workbenchVideoTrack = [[comosition tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
            AVMutableVideoCompositionLayerInstruction* layerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:workbenchVideoTrack];
            videoinstruction.layerInstructions = [NSArray arrayWithObject:layerInstruction];
            videoWorkbench.instructions = [NSArray arrayWithObject: videoinstruction];
            

            AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:comosition presetName:AVAssetExportPreset1280x720];
            exportSession.videoComposition = videoWorkbench;
            exportSession.outputFileType = AVFileTypeQuickTimeMovie;
            exportSession.outputURL = outputFileUrl;
            exportSession.shouldOptimizeForNetworkUse = YES;
            
            // loading
            [exportSession exportAsynchronouslyWithCompletionHandler:^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([exportSession status] == AVAssetExportSessionStatusCompleted) {
                        NSLog(@"finish -- ");
//                        [self addWatermark: outputFileUrl];
                        if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(outPath)) {
                            UISaveVideoAtPathToSavedPhotosAlbum(outPath, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
                        }
                    }
                    if ([exportSession status] == AVAssetExportSessionStatusCancelled) {
                        NSLog(@"finish -- Cancelled");
                    }
                    if ([exportSession status] == AVAssetExportSessionStatusFailed) {
                        NSLog(@"finish -- Failed");
                    }
                });
            }];
        });
    }
}


- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (error) {
        NSLog(@"保存视频失败%@", error.localizedDescription);
    }
}

- (void)addWatermarkImg {
    [self addWatermark: [[NSBundle mainBundle] URLForResource:@"video" withExtension:@"mp4"]];
}


- (void)addWatermark:(NSURL *)videoPath {
    
    AVMutableComposition *composition = [AVMutableComposition composition];
    AVMutableCompositionTrack *mainVideoTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    AVMutableCompositionTrack *mainAudioTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    NSURL *videoURL = videoPath;//[NSURL URLWithString:videoPath];
    AVURLAsset* videoAsset = [[AVURLAsset alloc]initWithURL:videoURL options:nil];
    AVAssetTrack *videoTrack = [[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    AVAssetTrack *audioTrack = [[videoAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
    
    [mainVideoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoAsset.duration) ofTrack:videoTrack atTime:kCMTimeZero error:nil];
    [mainAudioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoAsset.duration) ofTrack:audioTrack atTime:kCMTimeZero error:nil];
    
    // 图片
//    CGSize videoSize = [videoTrack naturalSize];
//    UIImage *myImage = [UIImage imageNamed:@"pic_front"];
//    CALayer *imgLay = [CALayer layer];
//    imgLay.contents = (__bridge id _Nullable)(myImage.CGImage);
//    imgLay.frame = CGRectMake(100, 100, 200, 200);
//    imgLay.opacity = 1.0;
//    CALayer *parentLayer = [CALayer layer];
//    parentLayer.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);;
//    CALayer *videoLayer = [CALayer layer];
//    videoLayer.frame=CGRectMake(0, 0, videoSize.width, videoSize.height);
//    [parentLayer addSublayer:videoLayer];
//    [parentLayer addSublayer:imgLay];
//    parentLayer.geometryFlipped = true;
    
    // 文字
//    CGSize videoSize = [videoTrack naturalSize];
//    UIFont *font = [UIFont systemFontOfSize:70.0];
//    CATextLayer *tLayer = [[CATextLayer alloc] init];
//    [tLayer setFontSize:70];
//    [tLayer setString:@"Hello world"];
//    [tLayer setAlignmentMode:kCAAlignmentCenter];
//    [tLayer setForegroundColor:[[UIColor greenColor] CGColor]];
//    [tLayer setBackgroundColor:[UIColor clearColor].CGColor];
//    CGSize textSize = [@"Hello world" sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:font,NSFontAttributeName, nil]];
//    [tLayer setFrame:CGRectMake(10, 200, textSize.width+20, textSize.height+10)];
//    tLayer.anchorPoint = CGPointMake(0.5, 1.0);
//
//    CALayer *parentLayer = [CALayer layer];
//    parentLayer.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);;
//    CALayer *videoLayer = [CALayer layer];
//    videoLayer.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
//    [parentLayer addSublayer:videoLayer];
//    [parentLayer addSublayer:tLayer];
//    parentLayer.geometryFlipped = true;
    
    // 动画
//    CGSize videoSize = [videoTrack naturalSize];
//    CALayer *parentLayer = [CALayer layer];
//    parentLayer.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
//    CALayer *videoLayer = [CALayer layer];
//    videoLayer.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
//    [parentLayer addSublayer:videoLayer];
//    parentLayer.geometryFlipped = true;
//    CALayer *animationLay = [CALayer layer];
//    animationLay.frame = CGRectMake(100, 100, 100, 100);
//    animationLay.backgroundColor = UIColor.redColor.CGColor;
//    animationLay.anchorPoint = CGPointMake(0.5, 1.0);
//    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.scale.y"];
//    animation.fromValue = @(0.2f);
//    animation.toValue = @(-3.0f);
//    animation.beginTime = AVCoreAnimationBeginTimeAtZero;
//    animation.duration = 2.0f;
//    animation.repeatCount = HUGE_VALF;
//    animation.removedOnCompletion = NO;
//    [animationLay addAnimation:animation forKey:nil];
//    [parentLayer addSublayer:animationLay];
    
    // gif
    CGSize videoSize = [videoTrack naturalSize];
    CALayer *gifLayer1 = [[CALayer alloc] init];
    gifLayer1.frame = CGRectMake(150 , 340 , 298 , 253 );
    CAKeyframeAnimation *gifLayer1Animation = [self animationForGifWithURL:[[NSBundle mainBundle] URLForResource:@"son" withExtension:@"gif"]];
    gifLayer1Animation.beginTime = AVCoreAnimationBeginTimeAtZero;
    gifLayer1Animation.removedOnCompletion = NO;
    [gifLayer1 addAnimation:gifLayer1Animation forKey:@"gif"];
    CALayer *parentLayer = [CALayer layer];
    parentLayer.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);;
    CALayer *videoLayer = [CALayer layer];
    videoLayer.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
    [parentLayer addSublayer:videoLayer];
    [parentLayer addSublayer:gifLayer1];
    parentLayer.geometryFlipped = true;
    

    double fps = [[[composition tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] nominalFrameRate];
    AVMutableVideoComposition *videoWorkbench = [AVMutableVideoComposition videoComposition];
    videoWorkbench.frameDuration = CMTimeMake(1, fps);
    videoWorkbench.renderSize = videoSize;
    videoWorkbench.animationTool = [AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];
    
    
    AVMutableVideoCompositionInstruction *videoinstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    videoinstruction.timeRange = CMTimeRangeMake(kCMTimeZero, [composition duration]);
    AVAssetTrack *workbenchVideoTrack = [[composition tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    AVMutableVideoCompositionLayerInstruction* layerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:workbenchVideoTrack];
    videoinstruction.layerInstructions = [NSArray arrayWithObject:layerInstruction];
    videoWorkbench.instructions = [NSArray arrayWithObject: videoinstruction];
    
    NSString *outPath = [NSString stringWithFormat:@"%@test002.mp4",NSTemporaryDirectory()];
    NSURL *outputFileUrl = [NSURL fileURLWithPath: outPath];
    if ([[NSFileManager defaultManager] fileExistsAtPath:outPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:outPath error:nil];
    }
    
    
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:composition presetName:AVAssetExportPreset1280x720];
    exportSession.videoComposition = videoWorkbench;
    exportSession.outputURL = outputFileUrl;
    exportSession.outputFileType = AVFileTypeQuickTimeMovie;
    exportSession.shouldOptimizeForNetworkUse = YES;
    
    
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        switch (exportSession.status) {
            case AVAssetExportSessionStatusUnknown:
                NSLog(@"AVAssetExportSessionStatusUnknown");
                break;
            case AVAssetExportSessionStatusWaiting:
                NSLog(@"AVAssetExportSessionStatusWaiting");
                break;
            case AVAssetExportSessionStatusExporting:
                NSLog(@"AVAssetExportSessionStatusExporting");
                break;
            case AVAssetExportSessionStatusFailed:
                NSLog(@"AVAssetExportSessionStatusFailed");
                break;
            case AVAssetExportSessionStatusCancelled:
                NSLog(@"AVAssetExportSessionStatusCancelled");
                break;
            case AVAssetExportSessionStatusCompleted:
                NSLog(@"export succeed");
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"playVideo----");
                    if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(outPath)) {
                        UISaveVideoAtPathToSavedPhotosAlbum(outPath, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
                    }
                });
                break;
        }
    }];
}

-(CAKeyframeAnimation *)animationForGifWithURL:(NSURL *)url {
    
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"contents"];
    
    NSMutableArray * frames = [NSMutableArray new];
    NSMutableArray *delayTimes = [NSMutableArray new];
    
    CGFloat totalTime = 0.0;
    CGFloat gifWidth;
    CGFloat gifHeight;
    
    CGImageSourceRef gifSource = CGImageSourceCreateWithURL((CFURLRef)url, NULL);
    
    size_t frameCount = CGImageSourceGetCount(gifSource);
    for (size_t i = 0; i < frameCount; ++i) {
        CGImageRef frame = CGImageSourceCreateImageAtIndex(gifSource, i, NULL);
        [frames addObject:(__bridge id)frame];
        CGImageRelease(frame);
        NSDictionary *dict = (NSDictionary*)CFBridgingRelease(CGImageSourceCopyPropertiesAtIndex(gifSource, i, NULL));
        gifWidth = [[dict valueForKey:(NSString*)kCGImagePropertyPixelWidth] floatValue];
        gifHeight = [[dict valueForKey:(NSString*)kCGImagePropertyPixelHeight] floatValue];
        NSDictionary *gifDict = [dict valueForKey:(NSString*)kCGImagePropertyGIFDictionary];
        [delayTimes addObject:[gifDict valueForKey:(NSString*)kCGImagePropertyGIFUnclampedDelayTime]];
        
        totalTime = totalTime + [[gifDict valueForKey:(NSString*)kCGImagePropertyGIFUnclampedDelayTime] floatValue];
    }
    if (gifSource) {
        CFRelease(gifSource);
    }
    
    NSMutableArray *times = [NSMutableArray arrayWithCapacity:3];
    CGFloat currentTime = 0;
    NSInteger count = delayTimes.count;
    for (int i = 0; i < count; ++i) {
        [times addObject:[NSNumber numberWithFloat:(currentTime / totalTime)]];
        currentTime += [[delayTimes objectAtIndex:i] floatValue];
    }
    
    NSMutableArray *images = [NSMutableArray arrayWithCapacity:3];
    for (int i = 0; i < count; ++i) {
        [images addObject:[frames objectAtIndex:i]];
    }
    
    animation.keyTimes = times;
    animation.values = images;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    animation.duration = totalTime;
    animation.repeatCount = HUGE_VALF;
    
    return animation;
}

@end
