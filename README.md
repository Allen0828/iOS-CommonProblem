iOS 工作/学习/面试中遇到的问题和测试代码汇总

## iOS
- 传递链和响应链{ button重写了响应区域方法，点击后的事件传递 }

- 锁
  <div>
   1 互斥锁 </br>
   @synchronized </br>
   是对互斥锁的一种封装 </br>
   具体点是种特殊的互斥锁->递归锁，内部搭配 nil防止死锁 </br>
   通过表的结构存要锁的对象 </br>
   表内部的对象又是通过哈希存储的 </br>
   坑点：在大量线程异步同时操作同一个对象时，因为递归锁会不停的alloc/release,在某一个对象会是nil；而此时 @synchronized (obj) 会判断obj==nil，就不会再加锁，导致线程访问冲突；</br></br>
   
   2 线程锁 </br>
   NSLock </br>
   NSLock是对pthread_mutex的封装 </br>
   NSLock还有timeout超时控制 坑点:当NSLock对同一个线程锁两次，就会造成死锁；即不能实现递归锁，这种情况需要用到NSRecursiveLock </br>
   
   NSRecursiveLock  </br>
   NSRecursiveLock也是对pthread_mutex的封装，不同的是加Recursive递归调用功能  </br>
   
   NSCondition </br>
   NSCondition 也是对pthread_mutex的封装 </br>
   使用wait信号可以让当前线程处于等待中 </br>
   使用signal信号可以告诉其他某一个线程不用再等待了，可以继续执行 </br>
   内部还有一个broadcast(广播)信号，用于发送(signal)信号给其他所有线程 </br>

   3 自旋锁 </br>
   OSSpinLock 在iOS10 之前，OSSpinLock 是一种自旋锁，也只有加锁，解锁，尝试加锁三个方法。和 NSLock 不同的是 NSLock 请求加锁失败的话，会先轮询，但一秒过后便会使线程进入 waiting 状态，等待唤醒。而 OSSpinLock 会一直轮询，等待时会消耗大量 CPU 资源，不适用于较长时间的任务。而因为OSSpinLock不再线程安全，在iOS10之后OSSpinLock被废弃内部封装了 </br>
   dispatch_barrier_async 特殊的的自旋锁；它能做到多读单写 </br>

   atomic 和 nonatomic  由于atomic使用了自旋锁，性能比nonatomic慢20倍 </br>
   atomic 在对象get/set的时候，会有一个spinlock_t控制。即当两个线程A和B，如果A正在执行getter时，B如果想要执行settet，就要等A执行getter完成后才能执行
  </div>
  
- GCD 信号量
  </br>
  信号量中场景的锁 </br>
  dispatch_semaphore PV操作  </br>
  
- runloop </br>
   1.runloop是一个事件驱动的循环,收到事件就去处理,没有事件就进入睡眠. </br>
   2.应用一启动主线程被创建后,主线程对应的runloop也被创建,runloop也保证了程序能够一直运行.之后创建的子线程默认是没有runloop的,只有当调用[NSRunLoop currentRunLoop]去获取的时候才被创建. </br>
   3.runloop的模式: 
   ### mode
   NSDefaultRunLoopMode 默认 </br>
   UITrackingRunLoopMode UI专用 </br>
   UIInitializationRunLoopMode 在刚启动App时第进入的第一个Mode，启动完成后就不再使用 </br>
   GSEventReceiveRunLoopMode 接受系统事件的内部Mode </br>
   NSRunLoopCommonModes 这是一个占位用的Mode，不是一种真正的Mode </br>

  </br><div>
   
  </div>
  
  ### aotoreleasePool
  <div>
   每一个autoreleasepool都是由一个或多个AutoreleasePoolPage的双向链表组成的
  </div>
  
  ```swift
   AutoreleasePoolPage {
       magic_t const magic;     // magic用来校验AutoreleasePoolPage结构是否完整
       id *next;                // next指向第一个可用的地址
       pthread_t const thread;  // thread指向当前的线程
       AutoreleasePoolPage * const parent; // parent指向父类
       AutoreleasePoolPage *child; // child指向子类
       uint32_t const depth;    //
       uint32_t hiwat;          //
   }
  ```
  AutoreleasePoolPage的大小都是一样的4096;
  当对象调用[object autorelease]的方法的时候就会加到autoreleasepool中;
  
  当执行到这个objc_autoreleasePoolPop方法的时候
  autoreleasepool会向POOL_SENTINEL地址后面的对象都发release消息，直到第一个POOL_SENTINEL对象截止。

   使用场景 </br>
   1 如果你编写的程序不是基于 UI 框架的，比如说命令行工具；</br>
   2 如果你编写的循环中创建了大量的临时对象；</br>
   3 如果你创建了一个辅助线程。</br>
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

