//
//  AEDownloadController.m
//  iOS_note
//
//  Created by allen0828 on 2022/6/28.
//

#import "AEDownloadController.h"
#import "FileDownloadManager.h"
#import <AVKit/AVKit.h>

@interface AEDownloadController ()

@property (nonatomic,strong) AVPlayerLayer *avLayer;

@end

@implementation AEDownloadController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
    
    UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(50, 300, 250, 35)];
    btn.backgroundColor = UIColor.redColor;
    [btn setTitle:@"点击下载" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(testDownload) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
}

FileDownloadManager *manager;
- (void)testDownload {
    __weak typeof(self) weakSelf = self;
    manager = [FileDownloadManager new];
    manager.downloadFinishBlock = ^(NSString *filePath) {
        NSLog(@"下载完成----%@", filePath);
        [weakSelf play:filePath];
    };
    
    
    [manager startDownload:@"https://media.w3.org/2010/05/sintel/trailer.mp4" withType:URLSessionDownloadDefault];
}

- (void)play:(NSString*)path {
    
    NSString *slink = [path stringByAppendingPathExtension:@"mp4"];
    NSFileManager *filemgr = [NSFileManager defaultManager];
    if (![filemgr fileExistsAtPath:slink]) {
        NSError *error = nil;
        [filemgr createSymbolicLinkAtPath:[path stringByAppendingPathExtension:@"mp4"] withDestinationPath: path error: &error];
        if (error) {
            NSLog(@"error=%@", error);
        }
    }
    
    AVPlayer *plyer = [[AVPlayer alloc] initWithURL:[NSURL fileURLWithPath:slink]];
    NSLog(@"error=%@", plyer.error);
    
    self.avLayer = [[AVPlayerLayer alloc] init];
    self.avLayer.player = plyer;
    self.avLayer.frame = self.view.bounds;
    [self.avLayer.player play];
    
    [self.view.layer addSublayer:self.avLayer];
    
}

@end
