//
//  AERotateScreenController.m
//  iOS_note
//
//  Created by gw_pro on 2022/5/25.
//

#import "AERotateScreenController.h"
#import "AETestRotateView.h"

#define ScreenWidth [UIScreen mainScreen].bounds.size.width
#define ScreenHeighe [UIScreen mainScreen].bounds.size.heighe

@interface AEFullScreenController : UIViewController

@property (nonatomic,strong) UIView *fullView;
@property (nonatomic,weak) UIView *superViwe;


@end



@interface AERotateScreenController ()

@property (nonatomic,weak) AEFullScreenController *tmpVC;
@property (nonatomic,strong) AETestRotateView *showView;

@end

@implementation AERotateScreenController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.showView = [[AETestRotateView alloc] initWithFrame:CGRectMake(0, 100, ScreenWidth, 300)];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTap)];
    [self.showView addGestureRecognizer:tap];
    
    [self.view addSubview:self.showView];
    
}

int a = 0;
- (void)viewTap {
    NSLog(@"tap");
    if (a == 0) {
        AEFullScreenController *vc = [AEFullScreenController new];
        vc.fullView = self.showView;
        vc.superViwe = self.showView.superview;
        vc.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:vc animated:false completion:^{

        }];
        self.tmpVC = vc;
        a = 1;
    } else {
        [self.tmpVC dismissViewControllerAnimated:false completion:^{
            [self test];
        }];
//        self.showView.frame = CGRectMake(0, 100, ScreenWidth, 300);
//        [self.view addSubview:self.tmpVC.fullView];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSLog(@"----");
        });

        a = 0;
    }
    
}

- (void)test {
    self.showView.backgroundColor = UIColor.greenColor;
    self.showView.frame = CGRectMake(0, 100, ScreenWidth, 300);
    NSLog(@"%@", self.showView);
    [self.view addSubview:self.showView];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    [self interfaceOrientation:UIInterfaceOrientationLandscapeRight];
    
    
}


// 强制旋转当前屏幕
- (void)landscapAction:(id)sender {
    [self interfaceOrientation:UIInterfaceOrientationLandscapeRight];
}
- (void)portraitAction:(id)sender {
    [self interfaceOrientation:UIInterfaceOrientationPortrait];
}
- (void)interfaceOrientation:(UIInterfaceOrientation)orientation
{
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        SEL selector = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        UIInterfaceOrientation val = orientation;
        [invocation setArgument:&val atIndex:2];
        [invocation invoke];
    }
}

// 将view当载体进行旋转



@end



@implementation AEFullScreenController

- (BOOL)prefersStatusBarHidden {
    return NO;
}
- (BOOL)shouldAutorotate {
    return NO;
}
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscapeRight;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.fullView.frame = self.view.bounds;
    [self.view addSubview:self.fullView];
    NSLog(@"viewDidLayoutSubviews");
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    [self dismissViewControllerAnimated:false completion:nil];
}

- (void)dealloc {
    NSLog(@"AEFullScreenController--dealloc");
}

@end

