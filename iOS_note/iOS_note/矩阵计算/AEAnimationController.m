//
//  AEAnimationController.m
//  iOS_note
//
//  Created by allen0828 on 2022/7/29.
//

#import "AEAnimationController.h"

@interface AEAnimationController ()

@property (nonatomic, strong) UIImageView *img;
@property (nonatomic,strong) NSTimer *mainLoopTimer;

@end

@implementation AEAnimationController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
    self.img = [[UIImageView alloc] initWithFrame:CGRectMake(60, 100, 200, 200)];
    self.img.image = [UIImage imageNamed:@"pic_front"];
    
    [self.view addSubview:self.img];
    
    self.mainLoopTimer = [NSTimer scheduledTimerWithTimeInterval:(1.0/20) target:self selector:@selector(mainLoop) userInfo:nil repeats:YES];

//    [self rotateView: self.img];
}

float animation = 0;
- (void)mainLoop {
    animation += 20;
    CATransform3D unit = CATransform3DIdentity;
    unit = CATransform3DRotate(unit, animation/180*M_PI, 0, 1, 0);
//    self.img.transform3D = unit;
    
    self.img.transform3D = [self getMatrix: animation/180*M_PI];

}

- (CATransform3D)getMatrix:(float)angle {
    CATransform3D transform = {
        cosf(angle), 0.0, -sinf(angle), 0.0,
                0.0,   1,          0.0, 0.0,
        sinf(angle), 0.0,  cosf(angle), 0.0,
                0.0, 0.0,          0.0,   1,
    };
    return transform;
}

- (void)rotateView:(UIImageView *)view {
    CABasicAnimation *rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.y"];
    rotationAnimation.toValue = [NSNumber numberWithFloat:M_PI*2.0];
    rotationAnimation.duration = 1;
    rotationAnimation.repeatCount = HUGE_VALF;
    [view.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}


@end
