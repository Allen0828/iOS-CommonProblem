//
//  XPYReadView.h
//  XPYReader
//
//  Created by zhangdu_imac on 2020/8/6.
//  Copyright © 2020 xiang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class XPYReadView, XPYChapterPageModel, XPYChapterModel;

typedef enum {
    TouchTypeBegin = 0,
    TouchTypeMove = 1,
    TouchTypeEnd = 2,
}TouchType;


@interface XPYReadView : UIView

/// 设置内容
/// @param pageModel 页面数据
/// @param chapterModel 章节数据
- (void)setupPageModel:(XPYChapterPageModel *)pageModel chapter:(XPYChapterModel *)chapterModel;

- (void)updateTouchType:(TouchType)type selectPoint:(CGPoint)selectPoint windowPoint:(CGPoint)windowPoint;

@end


