//
//  AEImgWatermarkController.m
//  iOS_note
//
//  Created by gw_pro on 2022/6/9.
//

#import "AEImgWatermarkController.h"
#import <Photos/Photos.h>

#define ScreenWidth [UIScreen mainScreen].bounds.size.width

@interface AEImgWatermarkController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic,strong) UIImageView *selectImg;
@property (nonatomic,strong) UIImageView *finishImg;

@end

@implementation AEImgWatermarkController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
    
    self.selectImg = [[UIImageView alloc]initWithFrame:CGRectMake((ScreenWidth-250)/2, 44, 250, 250)];
    self.selectImg.backgroundColor = UIColor.linkColor;
    self.selectImg.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:self.selectImg];
    
    UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake((ScreenWidth-250)/2, 300, 250, 35)];
    btn.backgroundColor = UIColor.redColor;
    [btn setTitle:@"选择照片" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(selectPic) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    self.finishImg = [[UIImageView alloc]initWithFrame:CGRectMake((ScreenWidth-250)/2, CGRectGetMaxY(btn.frame)+20, 250, 250)];
    self.finishImg.backgroundColor = UIColor.linkColor;
    self.finishImg.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:self.finishImg];
    
}


- (void)selectPic {
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (status != PHAuthorizationStatusAuthorized) {
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"相册权限未设置,请开启相册权限" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]]) {
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
                    }
                }];
                UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil];
                [alertController addAction:cancelAction];
                [alertController addAction:okAction];
                [self presentViewController:alertController animated:YES completion:nil];
                
            } else {
                UIImagePickerController *picker = [[UIImagePickerController alloc] init];
                picker.modalPresentationStyle = UIModalPresentationCurrentContext;
                picker.delegate = self;
                picker.mediaTypes = [NSArray arrayWithObjects:@"public.movie", @"public.image", nil];
                [self presentViewController:picker animated:YES completion:nil];
            }
            
        });
    }];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    self.selectImg.image = info[@"UIImagePickerControllerOriginalImage"];
    [picker dismissViewControllerAnimated:true completion:nil];
    
    UIImage *image = (UIImage*)info[@"UIImagePickerControllerOriginalImage"];
    UIGraphicsBeginImageContextWithOptions(image.size, NO, 0);
    [image drawAtPoint:CGPointZero];
    NSString *str = @"i am 图片水印";
    [str drawAtPoint:CGPointMake(20, 20) withAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:30], NSForegroundColorAttributeName: [UIColor redColor]}];
    UIImage *logoImg = [UIImage imageNamed:@"pic_front"];
    [logoImg drawAtPoint:CGPointMake(image.size.width - logoImg.size.width - 20 , image.size.height - logoImg.size.height - 20)];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.finishImg.image = image;
}




@end
