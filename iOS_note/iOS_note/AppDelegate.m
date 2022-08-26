//
//  AppDelegate.m
//  iOS_note
//
//  Created by gw_pro on 2022/5/25.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "LaunchAn.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = UIColor.whiteColor;
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:[ViewController new]];
    [self.window makeKeyAndVisible];
    
    LaunchAn *view = [[LaunchAn alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [self.window addSubview:view];
    
    return YES;
}




@end
