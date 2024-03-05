iOS 工作/学习/面试中遇到的问题和测试代码汇总

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
  </br><div>
   每个 UIView 内部都有一个 CALayer 在背后提供内容的绘制和显示，并且 UIView 的尺寸样式都由内部的 Layer 所提供。两者都有树状层级结构，layer 内部有 SubLayers，View 内部有 SubViews.但是 Layer 比 View 多了个AnchorPoint</br>
   在 View显示的时候，UIView 做为 Layer 的CALayerDelegate,View 的显示内容取决于内部的 CALayer 的 display</br>
   CALayer 是默认修改属性支持隐式动画的，在给 UIView 的 Layer 做动画的时候，View 作为 Layer 的代理，Layer 通过 actionForLayer:forKey:向 View请求相应的action(动画行为)</br>
   layer 内部维护着三分layer tree,分别是 presentLayer Tree(动画树),modeLayer Tree(模型树), Render Tree (渲染树),在做 iOS动画的时候，我们修改动画的属性，在动画的其实是 Layer 的 presentLayer的属性值,而最终展示在界面上的其实是提供 View的modelLayer
   两者最明显的区别是 View可以接受并处理事件，而 Layer 不可以</br>
  </div>
  
- NSArray和NSSet区别
  </br><div>
  NSArray有序的集合，存储的元素在一个整块的内存中并按序排列，存储数据的方式是连续的，后一个数据在内存中是紧接着前一个数据的；</br>
  NSSet无序的集合，散列存储。存储的时候并不是需要一块连续的内存，有可能我第一个数据在这个地方，而第二个数据和第一个数据中间还隔得有其他内容，我只是在存储第二个数据的时候，随便找了个可以放下的位置就存下来了</br>
  哈希表也叫散列表，哈希表是一种数据结构，它提供了快速的插入操作和查找操作，无论哈希表总中有多少条数据，插入和查找的时间复杂度都是为O(1)。</br>
</div>
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
```

# 文件夹中多个.a 合并成一个
libtool -static -o libXXXX.a *.a


## C++ 
malloc 和 new   单例的两种模式  那种锁的效率高  类的虚继承解决什么问题  虚函数表的实现(子类对象的内存地址怎么排列的)

