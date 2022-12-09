//
//  AELandscapeRightVC.m
//  iOS_note
//
//  Created by allen0828 on 2022/10/12.
//

#import "AELandscapeRightVC.h"
#import <objc/runtime.h>
#import <objc/message.h>


static bool EngineFinishRotate = false;
@interface UINavigationController (TestNav)


@end

@implementation UINavigationController (TestNav)


+ (void)load{
   static dispatch_once_t onceToken;
   dispatch_once(&onceToken, ^{
       Method orginMethod = class_getInstanceMethod(self, @selector(supportedInterfaceOrientations));
       Method currentMethod = class_getInstanceMethod(self, @selector(gritSupportedInterfaceOrientations));
       method_exchangeImplementations(orginMethod, currentMethod);
   });
}

- (UIInterfaceOrientationMask)gritSupportedInterfaceOrientations {
    if ([self.topViewController isKindOfClass:[UIViewController class]]) {
        NSLog(@"controller2------");
        return UIInterfaceOrientationMaskLandscapeRight;
    }
    return [super supportedInterfaceOrientations];
}


//- (BOOL)shouldAutorotate {
//    NSLog(@"TestNav-shouldAutorotate");
//    if ([self.topViewController isKindOfClass:[AELandscapeRightVC class]])
//    {
//        if (EngineFinishRotate)
//            return false;
//        else
//            return true;
//    }
//    return [super shouldAutorotate];
//}
//- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
//    NSLog(@"TestNav-supportedInterfaceOrientations");
//    if (EngineFinishRotate)
//    {
//        return UIInterfaceOrientationMaskLandscapeRight;
//    }
//    return [self supportedInterfaceOrientations];
////    return self.topViewController.supportedInterfaceOrientations;
//}
//- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
//    NSLog(@"TestNav-preferredInterfaceOrientationForPresentation");
//    return UIInterfaceOrientationLandscapeRight;
////    return self.topViewController.preferredInterfaceOrientationForPresentation;
//}

@end




@interface AELandscapeRightVC ()

@end

@implementation AELandscapeRightVC

- (void)loadView
{
    [super loadView];
}

// present view controller
- (BOOL)shouldAutorotate {
    NSLog(@"vc-shouldAutorotate");
    return true;
}
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    NSLog(@"vc-supportedInterfaceOrientations");
    return UIInterfaceOrientationMaskLandscape;
}
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    NSLog(@"vc-preferredInterfaceOrientationForPresentation");
    return UIInterfaceOrientationLandscapeRight;
}
 

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.redColor;
    [self.navigationController setNavigationBarHidden:true animated:false];
    // Do any additional setup after loading the view.
    
    
    [UIViewController attemptRotationToDeviceOrientation];
    
//    if (@available(iOS 16.0, *)) {
//        NSArray *array = [[[UIApplication sharedApplication] connectedScenes] allObjects];
//        UIWindowScene *ws = (UIWindowScene *)array[0];
//
//        [ws.keyWindow.rootViewController setNeedsUpdateOfSupportedInterfaceOrientations];
//        [self.navigationController setNeedsUpdateOfSupportedInterfaceOrientations];
//        [self setNeedsUpdateOfSupportedInterfaceOrientations];
//        UIWindowSceneGeometryPreferencesIOS *geometryPreferences = [[UIWindowSceneGeometryPreferencesIOS alloc] init];
//        geometryPreferences.interfaceOrientations = UIInterfaceOrientationMaskLandscapeRight;
//        [ws requestGeometryUpdateWithPreferences:geometryPreferences errorHandler:^(NSError * _Nonnull error) {
//            NSString *err = [NSString stringWithFormat:@"requestGeometryUpdate error = %@", error];
//            NSLog(@"%@", err);
//
//        }];
//    }
//    else
//    {
        if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
            SEL selector = NSSelectorFromString(@"setOrientation:");
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
            [invocation setSelector:selector];
            [invocation setTarget:[UIDevice currentDevice]];
            UIInterfaceOrientation val = UIInterfaceOrientationLandscapeRight;
            [invocation setArgument:&val atIndex:2];
            [invocation invoke];
        }
        
        [UIViewController attemptRotationToDeviceOrientation];
//    }

    EngineFinishRotate = true;
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    NSLog(@"size= %@", NSStringFromCGSize(size));
}

- (void)dealloc
{
    NSLog(@"dealloc");
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
//    if (@available(iOS 16.0, *)) {
//        NSArray *array = [[[UIApplication sharedApplication] connectedScenes] allObjects];
//        UIWindowScene *ws = (UIWindowScene *)array[0];
//
////        [ws.keyWindow.rootViewController setNeedsUpdateOfSupportedInterfaceOrientations];
////        [self.navigationController setNeedsUpdateOfSupportedInterfaceOrientations];
////        [self setNeedsUpdateOfSupportedInterfaceOrientations];
//
//        UIWindowSceneGeometryPreferencesIOS *geometryPreferences = [[UIWindowSceneGeometryPreferencesIOS alloc] init];
//        geometryPreferences.interfaceOrientations = UIInterfaceOrientationMaskLandscapeRight;
//        [ws requestGeometryUpdateWithPreferences:geometryPreferences errorHandler:^(NSError * _Nonnull error) {
//            NSString *err = [NSString stringWithFormat:@"requestGeometryUpdate error = %@", error];
//            NSLog(@"%@", err);
//
//        }];
//    }
//    else
//    {
        if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
            SEL selector = NSSelectorFromString(@"setOrientation:");
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
            [invocation setSelector:selector];
            [invocation setTarget:[UIDevice currentDevice]];
            UIInterfaceOrientation val = UIInterfaceOrientationLandscapeRight;
            [invocation setArgument:&val atIndex:2];
            [invocation invoke];
        }
        [UIViewController attemptRotationToDeviceOrientation];
//    }
}

@end
