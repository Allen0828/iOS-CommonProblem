//
//  ViewController.m
//  iOS_note
//
//  Created by gw_pro on 2022/5/25.
//

#import "ViewController.h"
#import "iOS_note-Swift.h"


#import "AERecordController.h"
#import "AERotateScreenController.h"
#import "AEImgWatermarkController.h"
#import "AEVidoPostController.h"
#import "AEDownloadController.h"
#import "AEAudioPCMController.h"
#import "AEAnimationController.h"
#import "AELocationController.h"
#import "AELandscapeRightVC.h"


inline UIViewController* GetVC() {
    UIViewController *vc = [AELandscapeRightVC new];
    vc.modalPresentationStyle = UIModalPresentationFullScreen;
    return vc;
}


@interface ViewController () <UITableViewDataSource, UITableViewDelegate>
{
    NSArray *_arr;
}
@property (nonatomic,strong) UILabel *finalLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _arr = @[@"录音", @"旋转屏幕", @"图片水印", @"视频音频合成", @"点击下载", @"播放PCM", @"旋转动画", @"同步获取位置信息", @"进入横屏"];
    
    self.finalLabel = [[UILabel alloc] initWithFrame:CGRectMake(74, 8, 0, 50)];
    self.finalLabel.text = @"GritWorld ™";
    self.finalLabel.font = [UIFont systemFontOfSize:30 weight:UIFontWeightBold];
    self.finalLabel.textColor = UIColor.blackColor;
    self.finalLabel.adjustsFontForContentSizeCategory = true;
    [self.view addSubview:self.finalLabel];
    
//    UITableView *table = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
//    table.dataSource = self;
//    table.delegate = self;
//    table.rowHeight = 40;
//    table.tableFooterView = nil;
//    table.tableHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 1, 50)];
//    [self.view addSubview:table];
    
//    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"backgroundColor"];
//    // [NSValue valueWithCGRect:CGRectMake(74, 8, 180, 50)];
//    // (id)[UIColor cyanColor].CGColor;
////    animation.fromValue = [NSValue valueWithCGRect:CGRectMake(74, 8, 0, 50)];
//    animation.fromValue = (id)[UIColor cyanColor].CGColor;
//    //  [NSValue valueWithCGRect:CGRectMake(74, 8, 0, 50)];
//    // (id)[UIColor magentaColor].CGColor;
////    animation.toValue = [NSValue valueWithCGRect:CGRectMake(74, 8, 180, 50)];
//    animation.toValue = (id)[UIColor magentaColor].CGColor;
//
//    animation.duration = 2.0;
//    animation.fillMode = kCAFillModeBoth;
////    animation.removedOnCompletion = NO;
////    animation.autoreverses = NO;
//    animation.repeatCount = HUGE_VALF;
//    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
//    [self.finalLabel.layer addAnimation:animation forKey:@"backgroundColorAnimation"];
    
    [UIView animateWithDuration:2.0 animations:^{
        self.finalLabel.frame = CGRectMake(74, 8, 180, 50);
    }];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _arr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [UITableViewCell new];
    cell.textLabel.text = _arr[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIViewController *vc = [UIViewController new];
    switch (indexPath.row) {
        case 0:
            vc = [AERecordController new];
            break;
        case 1:
            vc = [AERotateScreenController new];
            break;
        case 2:
            vc = [AEImgWatermarkController new];
            break;
        case 3:
            vc = [AEVidoPostController new];
            break;
        case 4:
            vc = [AEDownloadController new];
            break;
        case 5:
            vc = [AEAudioPCMController new];  //[[AEAudioSwift alloc] init]; //
            break;
        case 6:
            vc = [AEAnimationController new];
            break;
        case 7:
            vc = [AELocationController new];
        case 8:
        {
            [self presentViewController:GetVC() animated:false completion:nil];
//            vc = GetVC();
        }
        default:
            break;
    }
    
//    [self.navigationController pushViewController:vc animated:true];
}




@end
