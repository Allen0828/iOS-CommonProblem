//
//  ReaderHeader.h
//  iOS_note
//
//  Created by allen0828 on 2023/1/10.
//

#ifndef ReaderHeader_h
#define ReaderHeader_h

#import "XPYUtilities.h"
#import "Masonry.h"
#import "XPYDatabaseManager.h"

typedef void (^XPYVoidHandler)(void);
typedef void (^XPYSuccessHandler)(id result);
typedef void (^XPYFailureHandler)(NSError *error);


//NSString * const XPYIsFirstInstallKey = @"";
//NSString * const XPYLoginStatusDidChangeNotification = @"XPYLoginStatusDidChange";


#pragma mark - 阅读字号和字号等级
/// 默认阅读字号 19号字体
static NSInteger const XPYDefaultReadFontSize = 19;
/// 最小字号等级
static NSInteger const XPYMinReadFontSize = 25;
/// 最大字号等级
static NSInteger const XPYMaxReadFontSize = 13;

#pragma mark - 阅读间距
/// 默认阅读间距等级
static NSInteger const XPYDefaultReadSpacingLevel = 2;
/// 最小阅读间距等级
static NSInteger const XPYMinReadSpacingLevel = 0;
/// 最大阅读间距等级
static NSInteger const XPYMaxReadSpacingLevel = 4;

#pragma mark - 自动阅读速度
/// 默认自动阅读速度
static NSInteger const XPYDefaultAutoReadSpeed = 5;
/// 最小自动阅读速度
static NSInteger const XPYMinAutoReadSpeed = 1;
/// 最大自动阅读速度
static NSInteger const XPYMaxAutoReadSpeed = 15;

#pragma mark - 阅读背景颜色，这里随便设置了六种
#define XPYReadBackgroundColor1 [UIColor whiteColor]
#define XPYReadBackgroundColor2 XPYColorFromHex(0xF33333)
#define XPYReadBackgroundColor3 [UIColor grayColor]
#define XPYReadBackgroundColor4 XPYColorFromHex(0xD1E1D1)
#define XPYReadBackgroundColor5 [UIColor lightGrayColor]
#define XPYReadBackgroundColor6 [UIColor blackColor]
#define ReadSelectedColor [UIColor redColor]

/// 网络状态
typedef NS_ENUM(NSUInteger, XPYNetworkStatus) {
    XPYNetworkStatusUnknown,        // 未知网络
    XPYNetworkStatusUnreachable,    // 没有网络
    XPYNetworkStatusReachableWWAN,  // 手机网络
    XPYNetworkStatusReachableWiFi   // WiFi网络
};

/// 网络请求方式
typedef NS_ENUM(NSUInteger, XPYHTTPRequestType) {
    XPYHTTPRequestTypeGet,          // GET
    XPYHTTPRequestTypePost,         // POST
    XPYHTTPRequestTypeUploadFile,   // Upload
    XPYHTTPRequestTypeDownloadFile  // Download
};

/// 书籍类型
typedef NS_ENUM(NSUInteger, XPYBookType) {
    XPYBookTypeInternal,            // 网络书籍（通过接口请求获取）
    XPYBookTypeLocal                // 本地书籍（保存在本地，当前的本地测试书籍直接放在项目中）
};

/// 阅读翻页模式
typedef NS_ENUM(NSInteger, XPYReadPageType) {
    XPYReadPageTypeCurl = 0,            // 仿真
    XPYReadPageTypeVerticalScroll,  // 上下翻页
    XPYReadPageTypeTranslation,     // 左右平移
    XPYReadPageTypeNone             // 无动画
};

/// 阅读行间距/段间距等级
typedef NS_ENUM(NSInteger, XPYReadSpacingLevel) {
    XPYReadSpacingLevelZero = 0,
    XPYReadSpacingLevelOne,
    XPYReadSpacingLevelTwo,
    XPYReadSpacingLevelThree
};

/// 自动阅读模式
typedef NS_ENUM(NSInteger, XPYAutoReadMode) {
    XPYAutoReadModeScroll,  // 滚屏
    XPYAutoReadModeCover    // 覆盖
};


#define XPYDeviceIsIphoneX [XPYUtilities isIphoneX]

/// 是否深色模式
#define XPYIsDarkUserInterfaceStyle [XPYUtilities isDarkUserInterfaceStyle]

/// 强制旋转屏幕
#define XPYChangeInterfaceOrientation(aOrientation) [XPYUtilities changeInterfaceOrientation:aOrientation]

/// 根据Hex值和透明度获取颜色
#define XPYColorFromHexWithAlpha(aHex, aAlpha) [UIColor colorWithRed:((float)((aHex & 0xFF0000) >> 16)) / 255.0 green:((float)((aHex & 0xFF00) >> 8)) / 255.0 blue:((float)(aHex & 0xFF)) / 255.0 alpha:aAlpha]

/// 根据Hex值获取颜色（透明度为1）
#define XPYColorFromHex(aHex) XPYColorFromHexWithAlpha(aHex, 1)

/// 根据Hex字符串和透明度获取颜色
#define XPYColorFromHexStringWithAlpha(aHexString, aAlpha) [XPYUtilities colorFromHexString:aHexString alpha:aAlpha]

/// 根据Hex字符串获取颜色（透明度为1）
#define XPYColorFromHexString(aHexString) XPYColorFromHexStringWithAlpha(aHexString, 1)

/// 获取文字高度
#define XPYTextHeight(aText, aWidth, aFont, aSpacing) [XPYUtilities textHeightWithText:aText width:aWidth font:aFont spacing:aSpacing]

/// 对象判空
#define XPYIsEmptyObject(aObject) [XPYUtilities isEmptyObject:aObject]

/// 字符串MD5加密
#define XPYMD5StringWithString(aString) [XPYUtilities md5StringWithString:aString]

#pragma mark - 阅读器
#define XPYReadViewLeftSpacing [XPYUtilities readViewLeftSpacing]
#define XPYReadViewRightSpacing [XPYUtilities readViewRightSpacing]
#define XPYReadViewTopSpacing [XPYUtilities readViewTopSpacing]
#define XPYReadViewBottomSpacing [XPYUtilities readViewBottomSpacing]





/// KeyWindow
#define XPYKeyWindow  [UIApplication sharedApplication].delegate.window
/// 以375宽度屏幕为基准自适应
#define XPYScreenScaleConstant(aConstant) CGRectGetWidth([UIScreen mainScreen].bounds) / 375 * aConstant

/// 屏幕宽度
#define XPYScreenWidth CGRectGetWidth([UIScreen mainScreen].bounds)
/// 屏幕高度
#define XPYScreenHeight CGRectGetHeight([UIScreen mainScreen].bounds)
/// statusbar高度
#define XPYStatusBarHeight (XPYDeviceIsIphoneX ? 44.0f : 20.0f)
/// App Document文件夹路径
#define XPYDocumentDirectory NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject

/// 弱引用对象
#define weakify(object) autoreleasepool{} __weak __typeof__(object) weak##_##object = object;
/// 强引用对象
#define strongify(object) autoreleasepool{} __typeof__(object) object = weak##_##object;

/// 阅读器文字区域Rect
#define XPYReadViewBounds CGRectMake(0, 0, XPYScreenWidth - XPYReadViewLeftSpacing - XPYReadViewRightSpacing, XPYScreenHeight - XPYReadViewTopSpacing - XPYReadViewBottomSpacing)
/// 阅读器文字区域宽度
#define XPYReadViewWidth (XPYScreenWidth - XPYReadViewLeftSpacing - XPYReadViewRightSpacing)
/// 阅读去文字区域高度
#define XPYReadViewHeight (XPYScreenHeight - XPYReadViewTopSpacing - XPYReadViewBottomSpacing)

#pragma mark - Font
#define XPYFontBold(x) [UIFont fontWithName:@"PingFangSC-Semibold" size:x]
#define XPYFontRegular(x) [UIFont fontWithName:@"PingFangSC-Regular" size:x]
#define XPYFontMedium(x) [UIFont fontWithName:@"PingFangSC-Medium" size:x]
#define XPYFontLight(x) [UIFont fontWithName:@"PingFangSC-Light" size:x]

static inline NSString * XPYFilePath(NSString *name) {
    if (!name) {
        return XPYDocumentDirectory;
    }
    NSString *path = [XPYDocumentDirectory stringByAppendingPathComponent:name];
    BOOL isDirectory;
    if (![[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDirectory]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return path;
}





#endif /* ReaderHeader_h */


