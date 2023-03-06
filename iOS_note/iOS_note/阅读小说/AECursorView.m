//
//  AECursorView.m
//  iOS_note
//
//  Created by allen0828 on 2023/1/11.
//

#import "AECursorView.h"
#import "ReaderHeader.h"

@implementation AECursorView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = UIColor.clearColor;
    }
    return self;
}


- (void)drawRect:(CGRect)rect {
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    [ReadSelectedColor set];
    CGFloat rectW = self.bounds.size.width/2;
    if (contextRef != nil) {
        CGContextAddRect(contextRef, CGRectMake((self.bounds.size.width-rectW)/2, 0, rectW, 100));
        CGContextFillPath(contextRef);
    }
    if (self.isEnd) {
        CGContextAddEllipseInRect(contextRef, CGRectMake(0, self.bounds.size.height-self.bounds.size.width, self.bounds.size.width, self.bounds.size.width));
    } else {
        CGContextAddEllipseInRect(contextRef, CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.width));
    }
    [ReadSelectedColor set];
    CGContextFillPath(contextRef);
}


@end
