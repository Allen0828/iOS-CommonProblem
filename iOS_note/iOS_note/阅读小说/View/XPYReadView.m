//
//  XPYReadView.m
//  XPYReader
//
//  Created by zhangdu_imac on 2020/8/6.
//  Copyright © 2020 xiang. All rights reserved.
//

#import "XPYReadView.h"

#import "XPYChapterModel.h"
#import "XPYChapterPageModel.h"
#import "XPYParagraphModel.h"

#import "XPYReadParser.h"
#import "AECursorView.h"
#import "UIGestureRecognizer+XPYTag.h"
#import "XPYReadConfigManager.h"
#import <CoreText/CoreText.h>
#import "XPYViewControllerHelper.h"

#import "XPYReaderManagerController.h"


@interface XPYReadView ()

/// 长按选择手势
@property (nonatomic, strong) UILongPressGestureRecognizer *longPress;
/// 单击取消手势
@property (nonatomic, strong) UITapGestureRecognizer *singleTap;

@property (nonatomic, strong) XPYChapterModel *chapterModel;
@property (nonatomic, strong) XPYChapterPageModel *pageModel;

/// 选中行数组
@property (nonatomic, copy) NSArray<NSString*> *selectedRects;

@property (nonatomic,assign) NSRange selectRange;

@property (nonatomic,strong) AECursorView *cursorLeft;
@property (nonatomic,strong) AECursorView *cursorRight;
@property (nonatomic,assign) BOOL isTouchCursor;
// false = left, true = right
@property (nonatomic,assign) BOOL isTouchCursor_L_R;

@end

@implementation XPYReadView

#pragma mark - Initializer
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [XPYReadConfigManager sharedInstance].currentBackgroundColor;
        
        [self addGestureRecognizer:self.longPress];
        [self addGestureRecognizer:self.singleTap];
    }
    return self;
}

#pragma mark - Draw
- (void)drawRect:(CGRect)rect {
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    CGContextSetTextMatrix(contextRef, CGAffineTransformIdentity);
    CGContextTranslateCTM(contextRef, 0, CGRectGetHeight(self.bounds));
    CGContextScaleCTM(contextRef, 1.0, - 1.0);
    CTFrameRef frameRef = [XPYReadParser frameRefWithAttributedString:self.pageModel.pageContent rect:self.bounds];
    // 处理选中行
    if (self.selectedRects.count > 0) {
        CGRect rectangles[self.selectedRects.count];
        for (int i = 0; i < self.selectedRects.count; i++) {
            rectangles[i] = CGRectFromString(self.selectedRects[i]);
        }

        CGMutablePathRef mutablePath = CGPathCreateMutable();
        [[[XPYReadConfigManager sharedInstance].currentTextColor colorWithAlphaComponent:0.5] setFill];
        
        CGPathAddRects(mutablePath, nil, (const CGRect *)&rectangles, self.selectedRects.count);

        CGContextAddPath(contextRef, mutablePath);
        CGContextFillPath(contextRef);
        CGPathRelease(mutablePath);


    }
    CTFrameDraw(frameRef, contextRef);
    CFRelease(frameRef);
}


#pragma mark - Instance methods
- (void)setupPageModel:(XPYChapterPageModel *)pageModel chapter:(XPYChapterModel *)chapterModel {
    self.pageModel = pageModel;
    self.chapterModel = chapterModel;
    [self setNeedsDisplay];
}

#pragma mark - Event response
- (void)longPressAction:(UILongPressGestureRecognizer *)press {
    // 触摸点在当前视图的位置
    CGPoint point = [press locationInView:self];
    // 触摸点在Window视图的位置
    // CGPoint pointInWindow = [press locationInView:XPYKeyWindow];
    switch (press.state) {
        case UIGestureRecognizerStateBegan: {
            
        }
            break;
        case UIGestureRecognizerStateChanged: {
            
        }
            break;
        case UIGestureRecognizerStateEnded: {
            // 获取当前页面CTFrame
            CTFrameRef frameRef = [XPYReadParser frameRefWithAttributedString:self.pageModel.pageContent rect:self.bounds];
            // 获取触摸点所在行
            NSRange lineRange = [XPYReadParser touchLineRangeWithPoint:point frameRef:frameRef];
            if (lineRange.location == NSNotFound) {
                CFRelease(frameRef);
                return;
            }
            // 获取页面段落
            NSArray <XPYParagraphModel *> *paragraphs = [XPYReadParser paragraphsWithPageModel:self.pageModel chapterName:self.chapterModel.chapterName];
            // 逆序遍历段落
            [paragraphs enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(XPYParagraphModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (obj.range.location <= lineRange.location && (obj.range.location + obj.range.length) >= (lineRange.location + lineRange.length)) {
                    // 找到触摸点所在段
                    // 获取选中段落范围
                    self.selectedRects = [XPYReadParser rectsWithRange:obj.range content:self.pageModel.pageContent.string frameRef:frameRef];
                    self.selectRange = obj.range;
                    
                    if (self.selectedRects.count > 0) {
                        // 设置单击手势有效
                        self.singleTap.enabled = true;
                        self.longPress.enabled = false;
                    }
                    CFRelease(frameRef);
                    // 重绘
                    [self setNeedsDisplay];
                    *stop = YES;
                }
            }];
            [self showMenu];
            [self showCursor];
        }
            break;
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed: {
        }
            break;
        default:
            break;
    }
}

- (void)singleTap:(UITapGestureRecognizer *)tap {
    // 单击取消当前选中内容
    self.selectedRects = nil;
    self.selectRange = NSMakeRange(0, 0);
    [self removeCursor];
    // 设置单击手势失效
    self.singleTap.enabled = false;
    self.longPress.enabled = true;
    // 重绘
    [self setNeedsDisplay];
}

#pragma mark - Getters
- (UILongPressGestureRecognizer *)longPress {
    if (!_longPress) {
        _longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressAction:)];
        _longPress.tag = 10000;
    }
    return _longPress;
}
- (UITapGestureRecognizer *)singleTap {
    if (!_singleTap) {
        _singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
        _singleTap.tag = 10001;
        _singleTap.enabled = NO;
    }
    return _singleTap;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"Began");
    [self updateTouch:touches touchType:TouchTypeBegin];
}
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"Moved");
    [self updateTouch:touches touchType:TouchTypeMove];
}
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"Ended");
    [self updateTouch:touches touchType:TouchTypeEnd];
}
- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"cancel");
    [self updateTouch:touches touchType:TouchTypeEnd];
}


- (void)updateTouch:(NSSet<UITouch *> *)touches touchType:(TouchType)type {
    UITouch *touch = touches.anyObject;
    CGPoint point = [touch locationInView:self];
    CGPoint windowPoint = [touch locationInView:self.window];
   
    [self updateTouchType:type selectPoint:point windowPoint:windowPoint];
}

- (void)updateTouchType:(TouchType)type selectPoint:(CGPoint)selectPoint windowPoint:(CGPoint)windowPoint {
    if (self.selectRange.length == 0) {
        return;
    }
    CGPoint point = CGPointMake(MIN(MAX(selectPoint.x, 0), self.frame.size.width), MIN(MAX(selectPoint.y, 0), self.pageModel.contentHeight));
    UIViewController *vc = [XPYViewControllerHelper findViewController:self];
    if (type == TouchTypeBegin) {
        for (UIViewController *v in vc.navigationController.viewControllers) {
            NSLog(@"%@", v);
            if ([v isKindOfClass:[XPYReaderManagerController class]])
            {
                XPYReaderManagerController *vcManager = (XPYReaderManagerController*)v;
                [vcManager setScrollEnabled:false];
            }
        }
        CGRect frameL = CGRectInset(self.cursorLeft.frame, -60, -60);
        CGRect frameR = CGRectInset(self.cursorRight.frame, -60, -60);
        
        self.isTouchCursor = true;
        if (CGRectContainsPoint(frameL, point)) {
            NSLog(@"触摸了左边光标");
            [[UIMenuController sharedMenuController] setMenuVisible:false animated:true];
            self.isTouchCursor_L_R = true;
        } else if (CGRectContainsPoint(frameR, point)) {
            NSLog(@"触摸了右0000边光标");
            [[UIMenuController sharedMenuController] setMenuVisible:false animated:true];
            self.isTouchCursor_L_R = false;
        } else {
            self.isTouchCursor = false;
        }
    } else if (type == TouchTypeMove) {
        if (self.isTouchCursor && self.selectRange.location > 0) {
            CTFrameRef frameRef = [XPYReadParser frameRefWithAttributedString:self.pageModel.pageContent rect:self.bounds];
            NSRange lineRange = [XPYReadParser touchLineRangeWithPoint:point frameRef:frameRef];
            if (lineRange.location == NSNotFound) {
                CFRelease(frameRef);
                return;
            }
            NSLog(@"%@", NSStringFromRange(lineRange));
            [self updateSelectRange:lineRange.location];
            
            self.selectedRects = [XPYReadParser rectsWithRange:self.selectRange content:self.pageModel.pageContent.string frameRef:frameRef];
            CFRelease(frameRef);
            [self updateCursorFrame];
        }
    } else {
        if (self.isTouchCursor) {
            [self showMenu];
        }
        self.isTouchCursor = false;
        for (UIViewController *v in vc.navigationController.viewControllers) {
            NSLog(@"%@", v);
            if ([v isKindOfClass:[XPYReaderManagerController class]])
            {
                XPYReaderManagerController *vcManager = (XPYReaderManagerController*)v;
                [vcManager setScrollEnabled:true];
            }
        }
    }
    
    [self setNeedsDisplay];
}

- (void)updateSelectRange:(NSUInteger)location {
    NSUInteger leftLocation = self.selectRange.location;
    NSUInteger rightLocation = self.selectRange.location + self.selectRange.length;
    
    if (self.isTouchCursor_L_R) {
        if (location < rightLocation) {
            if (location > leftLocation) {
                NSRange newRange = self.selectRange;
                newRange.length -= (location - leftLocation);;
                newRange.location = location;
                
                self.selectRange = newRange;
            } else if (location < leftLocation) {
                NSRange newRange = self.selectRange;
                newRange.length += leftLocation - location;
                newRange.location = location;
    
                self.selectRange = newRange;
            }
        } else {
            self.isTouchCursor_L_R = false;

            NSUInteger length = location - rightLocation;
            NSUInteger tempLength = (length == 0 ? 1 : 0);
            length = (length == 0 ? 1 : length);
            NSRange newRange;
            newRange.length = length;
            newRange.location = rightLocation - tempLength;
           
            self.selectRange = newRange;
            [self updateSelectRange:location];
        }
    } else {
        if (location > leftLocation) {
            if (location > rightLocation) {
                NSRange newRange = self.selectRange;
                newRange.length += location - rightLocation;
                
                self.selectRange = newRange;
            } else if (location < rightLocation) {
                NSRange newRange = self.selectRange;
                newRange.length -= rightLocation - location;

                self.selectRange = newRange;
            }
        } else {
            self.isTouchCursor_L_R = true;
            
            NSUInteger tempLength = leftLocation - location;
            NSUInteger length = (tempLength == 0 ? 1 : tempLength);
            
            NSRange newRange;
            newRange.length = length;
            newRange.location = leftLocation - tempLength;
           
            self.selectRange = newRange;
            [self updateSelectRange:location];
        }
    }
}


- (void)showCursor {
    if (self.cursorLeft == nil) {
        self.cursorLeft = [AECursorView new];
        [self addSubview:self.cursorLeft];
    }
    if (self.cursorRight == nil) {
        self.cursorRight = [AECursorView new];
        self.cursorRight.isEnd = true;
        [self addSubview:self.cursorRight];
    }
    [self updateCursorFrame];
}
- (void)removeCursor {
    if (self.cursorLeft != nil) {
        [self.cursorLeft removeFromSuperview];
        self.cursorLeft = nil;
    }
    if (self.cursorRight != nil) {
        [self.cursorRight removeFromSuperview];
        self.cursorRight = nil;
    }
}

- (void)updateCursorFrame {
    if (self.selectedRects.count == 0) return;
    CGFloat cursorViewW = 10;
    CGFloat cursorViewSpaceW = cursorViewW / 4;
    CGFloat cursorViewSpaceH = cursorViewW / 1.1;
    NSString *firstStr = self.selectedRects.firstObject;
    NSString *lastStr = self.selectedRects.lastObject;
    CGRect first = CGRectFromString(firstStr);
    CGRect last = CGRectFromString(lastStr);
     
    CGFloat leftX = CGRectGetMinX(first) - cursorViewW + cursorViewSpaceW;
    CGFloat leftY = self.bounds.size.height - CGRectGetMinY(first) - first.size.height - cursorViewSpaceH;
    self.cursorLeft.frame = CGRectMake(leftX, leftY, cursorViewW, first.size.height + cursorViewSpaceH);
    
    CGFloat rightX = CGRectGetMaxX(last) - cursorViewSpaceW;
    CGFloat rightY = self.bounds.size.height - CGRectGetMinY(last) - last.size.height;
    self.cursorRight.frame = CGRectMake(rightX, rightY, cursorViewW, last.size.height + cursorViewSpaceH);
}


- (void)showMenu {
    if (self.selectedRects.count == 0) return;
    CGRect rect = [self getMenuRect:self.selectedRects viewFrame:self.bounds];
    [self becomeFirstResponder];
    UIMenuController *menu = [UIMenuController sharedMenuController];
    UIMenuItem *share = [[UIMenuItem alloc] initWithTitle:@"分享" action:@selector(shareClick)];
    UIMenuItem *copy = [[UIMenuItem alloc] initWithTitle:@"复制" action:@selector(copyClick)];
    menu.menuItems = @[share, copy];
    [menu setTargetRect:rect inView:self];
    [menu setMenuVisible:YES animated:YES];
}

- (CGRect)getMenuRect:(NSArray<NSString*>*)rects viewFrame:(CGRect)viewFrame {
    CGRect menuRect;
    if (rects.count == 1) {
        menuRect = CGRectFromString(rects[0]);
    } else {
        menuRect = CGRectFromString(rects[0]);
        for (NSString *rectStr in rects) {
            CGRect rect = CGRectFromString(rectStr);
            
            CGFloat minX = MIN(menuRect.origin.x, rect.origin.x);
            CGFloat maxX = MAX(menuRect.origin.x+menuRect.size.width, rect.origin.x+rect.size.width);
            
            CGFloat minY = MIN(menuRect.origin.y, rect.origin.y);
            CGFloat maxY = MAX(menuRect.origin.y+menuRect.size.height, rect.origin.y+rect.size.height);
            
            menuRect.origin.x = minX;
            menuRect.origin.y = minY;
            menuRect.size.width = maxX - minX;
            menuRect.size.height = maxY - minY;
        }
        menuRect.origin.y = viewFrame.size.height - menuRect.origin.y - menuRect.size.height;
    }
    return menuRect;
}

- (void)shareClick {
    
}
- (void)copyClick {
    if (self.selectRange.length > 0) {
       NSString *str = [_pageModel.pageContent.string substringWithRange: self.selectRange];
        NSLog(@"%@", str);
    }
    
}



@end
