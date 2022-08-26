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

@property (nonatomic,strong) UIView *controlView;
@property (nonatomic,strong) UISlider *progressSlider;

@property (nonatomic,strong) UILabel *nowTime;
@property (nonatomic,strong) UILabel *totalTime;


@end

@implementation AETestRotateView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = UIColor.redColor;
        
//        self.btn = [[UIButton alloc]initWithFrame:CGRectMake(50, 50, 50, 50)];
//        self.btn.backgroundColor = UIColor.blueColor;
//        [self.btn addTarget:self action:@selector(btnDidClick) forControlEvents:UIControlEventTouchUpInside];
//        [self addSubview:self.btn];
//
//
        AVPlayer *plyer = [[AVPlayer alloc] initWithURL:[NSURL URLWithString:@"https://vd4.bdstatic.com/mda-netzy37b5v0wkwdg/sc/cae_h264/1653782659158225117/mda-netzy37b5v0wkwdg.mp4"]];
        self.avLayer = [[AVPlayerLayer alloc] init];
        self.avLayer.player = plyer;
        self.avLayer.frame = self.bounds;
        [self.avLayer.player play];

        [self.layer addSublayer:self.avLayer];
        [self config];
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

- (void)config {
    self.controlView = [[UIView alloc] init];
    self.controlView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
    self.controlView.translatesAutoresizingMaskIntoConstraints = false;
    [self addSubview:self.controlView];
    NSArray<NSLayoutConstraint *> *constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[control]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:@{@"control": self.controlView}];
    [self addConstraints:constraints];
    NSArray<NSLayoutConstraint *> *constraintsV = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[control(60)]" options:NSLayoutFormatAlignAllBottom metrics:nil views:@{@"control": self.controlView}];
    [self addConstraints:constraintsV];

    NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:self.controlView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
    [self addConstraint:bottom];
    
    
    self.nowTime = [[UILabel alloc] init];
    self.nowTime.translatesAutoresizingMaskIntoConstraints = false;
    self.nowTime.text = @"132:32";
    self.nowTime.textColor = UIColor.whiteColor;
    [self.controlView addSubview:self.nowTime];
    NSArray<NSLayoutConstraint *> *nowTimeV = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[nowTime]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:@{@"nowTime": self.nowTime}];
    [self.controlView addConstraints:nowTimeV];
    
    self.progressSlider = [[UISlider alloc] init];
    self.progressSlider.translatesAutoresizingMaskIntoConstraints = false;
    [self.controlView addSubview:self.progressSlider];
    NSArray<NSLayoutConstraint *> *sliderV = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[slider]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:@{@"slider": self.progressSlider}];
    [self.controlView addConstraints:sliderV];
    
    self.totalTime = [[UILabel alloc] init];
    self.totalTime.translatesAutoresizingMaskIntoConstraints = false;
    self.totalTime.text = @"132:32";
    self.totalTime.textColor = UIColor.whiteColor;
    [self.controlView addSubview:self.totalTime];
    NSArray<NSLayoutConstraint *> *totalTimeV = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[totalTime]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:@{@"totalTime": self.totalTime}];
    [self.controlView addConstraints:totalTimeV];
    
    NSArray<NSLayoutConstraint *> *itemH = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[nowTime]-[slider]-[totalTime]-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:@{@"nowTime": self.nowTime, @"slider": self.progressSlider, @"totalTime": self.totalTime}];
    [self.controlView addConstraints:itemH];
}

@end
