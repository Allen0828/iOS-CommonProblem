//
//  ViewController.m
//  iOS_note
//
//  Created by gw_pro on 2022/5/25.
//

#import "ViewController.h"
#import "AERecordController.h"
#import "AERotateScreenController.h"
#import "AEImgWatermarkController.h"
#import "AEVidoPostController.h"
#import "AEDownloadController.h"


@interface ViewController () <UITableViewDataSource, UITableViewDelegate>
{
    NSArray *_arr;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _arr = @[@"录音", @"旋转屏幕", @"图片水印", @"视频音频合成", @"点击下载"];
    
    
    UITableView *table = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
    table.dataSource = self;
    table.delegate = self;
    table.rowHeight = 40;
    table.tableFooterView = nil;
    table.tableHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 1, 50)];
    [self.view addSubview:table];
    
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
            
        default:
            break;
    }
    [self.navigationController pushViewController:vc animated:true];
}




@end
