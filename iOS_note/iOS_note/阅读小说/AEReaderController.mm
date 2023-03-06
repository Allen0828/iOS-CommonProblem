//
//  AEReaderController.m
//  iOS_note
//
//  Created by allen0828 on 2023/1/10.
//

#import "AEReaderController.h"
#import "XPYReadParser.h"
#import "XPYBookModel.h"
#import "XPYChapterModel.h"
#import "XPYReadHelper.h"
#import "XPYChapterDataManager.h"


#import "XPYBookStackViewController.h"


@interface AEReaderController ()

@end

@implementation AEReaderController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
    
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"XPYIsFirstInstall"]) {
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
        NSString *localFilePath = [[NSBundle mainBundle] pathForResource:@"圣经和合本新约" ofType:@"txt"];
        
        [XPYReadParser parseLocalBookWithFilePath:localFilePath success:^(NSArray<XPYChapterModel *> * _Nonnull chapters) {
            // 创建书籍模型
            XPYBookModel *bookModel = [[XPYBookModel alloc] init];
            bookModel.bookType = XPYBookTypeLocal;
            bookModel.bookName = @"圣经和合本新约";
            // 本地书随机生成ID
            bookModel.bookId = [NSString stringWithFormat:@"%@", @([[NSDate date] timeIntervalSince1970] * 1000)];
            bookModel.chapterCount = chapters.count;
            for (XPYChapterModel *chapter in chapters) {
                chapter.bookId = bookModel.bookId;
            }
            [XPYReadHelper addToBookStackWithBook:bookModel complete:^{
                [XPYChapterDataManager insertChaptersWithModels:chapters];
                dispatch_semaphore_signal(semaphore);
            }];
        } failure:^(NSError *error) {
//            // [MBProgressHUD xpy_showErrorTips:error.userInfo[NSUnderlyingErrorKey]];
            dispatch_semaphore_signal(semaphore);
        }];
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        [[NSUserDefaults standardUserDefaults] setObject:@NO forKey:@"XPYIsFirstInstall"];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    XPYBookStackViewController *vc = [XPYBookStackViewController new];
    [self.navigationController pushViewController:vc animated:true];
}


@end
