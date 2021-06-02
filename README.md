iOS 不常用 方法 汇总

## iOS
- 传递链和响应链{ button重写了响应区域方法，点击后的事件传递 }
- 视频缓存
- GCD 信号量{
   wait
   signal
}
- runloop {
  mode
  aotoreleasePool
}
- UIView和UILayer区别
- NSArray和NSSet区别
- 基于cocoapods组件化编程

## Objective-C
- 那些操作会让对象引用计数加1
- block 修改外部变量的原理
- runtime表管理

## Swift
- ?Optional 实现原理
- 枚举和OC枚举的区别
- protocol设置关键字
- struct引用对象后对象是如何赋值的
- 字典中通过key取值 值是可选类型 为什么

## 扩展知识
- openGL 着色器
- 一张黑白图片变成彩色图片的过程
- 双指针算法优化


## 基础知识
- iOS 10.0+
- 设置页面 App-Prefs:root
- 无线局域网 App-Prefs:root=WIFI
- 蓝牙 App-Prefs:root=Bluetooth
- 蜂窝移动网络 App-Prefs:root=MOBILE_DATA_SETTINGS_ID
- 个人热点 App-Prefs:root=INTERNET_TETHERING
- 运营商 App-Prefs:root=Carrier
- 通知 App-Prefs:root=NOTIFICATIONS_ID
- 通用 App-Prefs:root=General
- 通用-关于本机 App-Prefs:root=General&path=About
- 通用-键盘 App-Prefs:root=General&path=Keyboard
- 通用-辅助功能 App-Prefs:root=General&path=ACCESSIBILITY
- 通用-语言与地区 App-Prefs:root=General&path=INTERNATIONAL
- 通用-还原 App-Prefs:root=Reset
- 墙纸 App-Prefs:root=Wallpaper
- Siri App-Prefs:root=SIRI
- 隐私 App-Prefs:root=Privacy
- Safari App-Prefs:root=SAFARI
- 音乐 App-Prefs:root=MUSIC
- 音乐-均衡器 App-Prefs:root=MUSIC&path=com.apple.Music:EQ
- 照片与相机 App-Prefs:root=Photos
- FaceTime App-Prefs:root=FACETIME

- 系统自带app URL scheme收集参考：https://www.zhihu.com/question/51662806

# 使用终端或脚本编译工程

**前置条件 多人合作开发时 保证新的代码可以编译 于是使用脚本来进行编译**
- 0 先在电脑中 正常的运行一次代码
- 1 找到 `.xcodeproj` 工程 显示包内容. 打开`project.pbxproj` 找到DEVELOPMENT_TEAM
- 2 复制DEVELOPMENT_TEAM的Value  (10位数类似D5M8CJ9NDR)
- 3 终端切到 工程文件所在的文件夹
```shell
xcodebuild build -project 工程名.xcodeproj 
-configuration Release 
-allowProvisioningUpdates 
DEVELOPMENT_TEAM="D5M8CJ9NDR" 
CODE_SIGN_STYLE=Automatic 
CODE_SIGN_IDENTITY="Apple Development" 
OMBINE_HIDPI_IMAGES=YES


