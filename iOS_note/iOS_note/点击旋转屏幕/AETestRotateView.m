//
//  AETestRotateView.m
//  iOS_note
//
//  Created by gw_pro on 2022/5/29.
//

#import "AETestRotateView.h"
#import <AVKit/AVKit.h>

@interface AETestRotateView ()

@property (nonatomic,strong) UIButton *btn;
@property (nonatomic,strong) AVPlayerLayer *avLayer;


@end

@implementation AETestRotateView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = UIColor.redColor;
        
        self.btn = [[UIButton alloc]initWithFrame:CGRectMake(50, 50, 50, 50)];
        self.btn.backgroundColor = UIColor.blueColor;
        [self.btn addTarget:self action:@selector(btnDidClick) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.btn];
        
        
        AVPlayer *plyer = [[AVPlayer alloc] initWithURL:[NSURL URLWithString:@"https://vd4.bdstatic.com/mda-netzy37b5v0wkwdg/sc/cae_h264/1653782659158225117/mda-netzy37b5v0wkwdg.mp4"]];
        self.avLayer = [[AVPlayerLayer alloc] init];
        self.avLayer.player = plyer;
        self.avLayer.frame = self.bounds;
        [self.avLayer.player play];
        
        [self.layer addSublayer:self.avLayer];
        
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.avLayer.frame = self.bounds;
    NSLog(@"layoutSubviews");
}

- (void)btnDidClick {
    
}

@end
