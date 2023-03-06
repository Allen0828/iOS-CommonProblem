//
//  XPYReaderManagerController.h
//  XPYReader
//
//  Created by zhangdu_imac on 2020/8/4.
//  Copyright © 2020 xiang. All rights reserved.
//  阅读器总控制器

#import "XPYBaseReadViewController.h"

@class XPYBookModel;


@interface XPYReaderManagerController : XPYBaseReadViewController

@property (nonatomic, strong) XPYBookModel *book;


- (void)setScrollEnabled:(BOOL)value;


@end


