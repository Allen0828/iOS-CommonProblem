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

#import "XPYReadRecordManager.h"





@interface AEReaderController ()

@property (nonatomic, copy) NSArray<XPYBookModel *> *dataSource;

@end

@implementation AEReaderController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
    
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"XPYIsFirstInstall"]) {
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
        NSString *localFilePath = [[NSBundle mainBundle] pathForResource:@"圣经和合本" ofType:@"txt"];
        
        [XPYReadParser parseLocalBookWithFilePath:localFilePath success:^(NSArray<XPYChapterModel *> * _Nonnull chapters) {
            // 创建书籍模型
            XPYBookModel *bookModel = [[XPYBookModel alloc] init];
            bookModel.bookType = XPYBookTypeLocal;
            bookModel.bookName = @"圣经和合本";
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
            NSLog(@"error");
            dispatch_semaphore_signal(semaphore);
        }];
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        [[NSUserDefaults standardUserDefaults] setObject:@NO forKey:@"XPYIsFirstInstall"];
    }
    self.dataSource = [[XPYReadRecordManager allBooksInStack] copy];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    XPYBookModel *bookModel = self.dataSource[0];
    [XPYReadHelper readWithBook:bookModel];
    
}


@end
