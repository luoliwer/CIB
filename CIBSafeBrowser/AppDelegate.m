//
//  AppDelegate.m
//  CIBSafeBrowser
//
//  Created by cib on 14/12/4.
//  Copyright (c) 2014年 cib. All rights reserved.
//

#import "AppDelegate.h"

#import "LoginViewController.h"
#import "CustomWebViewController.h"
#import "MainViewController.h"

#import "CIBURLProtocol.h"
#import "MyUtils.h"
#import "Config.h"
#import "CoreDataManager.h"
#import "AppProduct.h"
#import "SecUtils.h"
#import "CIBURLCache.h"
#import "CIBResourceInfo.h"
#import "GlobleData.h"

#import "UIImage+BlurGlass.h"

#import <CIBBaseSDK/CIBBaseSDK.h>
#import <openssl/crypto.h>
#import "PushManager.h"
#import "TalkingData.h"

#import "Message.h"
#import "Public.h"
#import "ChatDBManager.h"
#import "Chatter.h"
#import "HttpManager.h"

#import "iflyMSC/IFlyMSC.h"
#import "Definition.h"

#import "ImageAlertView.h"
//#include <objc/runtime.h>
#import "PhotoEventHandleUtils.h"

@interface AppDelegate () <PushManagerDelegate, DeviceTokenDelegate, JFRWebSocketDelegate, UIAlertViewDelegate>
{
    NSDate *enterBackgroundTime;  // 进入后台时间
    int lockInterval;  // 进入后台 -> 进入前台 需要解锁的间隔，单位:s
    NSTimer *timer; // 发送websocket心跳消息的时间间隔
}

@end

@implementation AppDelegate

// Override point for customization after application launch.
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
//    Class LSApplicationWorkspace_class = objc_getClass("LSApplicationWorkspace");
//    NSObject* workspace = [LSApplicationWorkspace_class performSelector:@selector(defaultWorkspace)];
//    NSArray *result = [workspace performSelector:@selector(applicationsAvailableForHandlingURLScheme:)withObject:@"alipay"];
    
    // 解除bug
//    [DeviceKeyManager deleteDeviceKey];
//    [FingerWorkManager clearFingerWork];
//    [AppInfoManager clearUserInfo];
    
    //显示SDK的版本号
    NSLog(@"verson=%@",[IFlySetting getVersion]);
    
    //设置sdk的log等级，log保存在下面设置的工作路径中
    [IFlySetting setLogFile:LVL_ALL];
    
    //打开输出在console的log开关
    [IFlySetting showLogcat:NO];
    
    //设置sdk的工作路径
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachePath = [paths objectAtIndex:0];
    [IFlySetting setLogFilePath:cachePath];
    
    //创建语音配置,appid必须要传入，仅执行一次则可
    NSString *initString = [[NSString alloc] initWithFormat:@"appid=%@",APPID_VALUE];
    
    //所有服务启动前，需要确保执行createUtility
    [IFlySpeechUtility createUtility:initString];
    
    [self configEnv];
    
    // 通过推送消息打开应用的情况
    if (launchOptions) {
        NSDictionary *userInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];

        BOOL isWebAppNoti = [userInfo objectForKey:@"isWebAppNoti"];
        if (isWebAppNoti) {
            // 获取推送来自的WebApp名称
            NSString *notiAppName = [userInfo objectForKey:@"appName"];
            // 修改数据库中相应WebApp的通知相关字段
            CoreDataManager *cdManager = [[CoreDataManager alloc] init];
//            NSArray *appList = [cdManager getAppList];
            NSArray *appList = [[AppDelegate delegate] getAppProductList];
            for (AppProduct *app in appList) {
                if ([notiAppName isEqualToString:app.appName]) {
                    int notiNo = [app.notiNo intValue];
                    notiNo ++;
                    app.notiNo = [NSNumber numberWithInt:notiNo];
                    [cdManager updateAppInfo:app];
                    // 更新明文临时变量为空 需要重新从数据库中读取
                    [[AppDelegate delegate] setAppProductList:appList];
                    break;
                }
            }
        }
        else {
            // 如果是应用门户本身的推送消息，做相应处理
        }
        
    }
    // 去除app图标上的小红点
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    // 由于mPush的SDK没有注册成功的回调方法，只有收到deviceToken的回调方法。因此，无法判断推送服务是否注册成功。只能采用每次程序启动时，均注册推送服务的方法。
    
    float currentOsVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
    
    if (currentOsVersion < 11.0) {
        // 注册推送服务
        [PushManager startPushServicePushDelegate:self tokenDelegate:self];
        //    [PushManager setDebugMode:YES];
        
        // 设置收到消息的处理Delegate
        [PushManager setPushDelegate:self append:NO];
    }
    

    
    
    // 设置本地通知
    if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]) {
        UIUserNotificationType type = UIUserNotificationTypeBadge|UIUserNotificationTypeSound|UIUserNotificationTypeAlert;
        
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:type categories:nil]];
    }

    // 设置初始状态
    self.hasCheckedUpdate = NO;
    self.hasLoadAppListFromServer = NO;
    self.lockVc = nil;
    self.tabList = [[NSMutableArray alloc] init];
    self.isLogin = NO;
    self.isUnlock = NO;
    self.isActive = YES;
    
    // 状态栏浅色
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];

    
    
    // 使用自定义的NSURLProtocol实现ssl双向认证
    [NSURLProtocol registerClass:[CIBURLProtocol class]];
    
    long cacheTime = [[MyUtils propertyOfResource:@"Setting" forKey:@"CacheExpire"] longValue];
    CIBURLCache *urlCache = [[CIBURLCache alloc] initWithMemoryCapacity:20 * 1024 * 1024
                                                           diskCapacity:200 * 1024 * 1024
                                                               diskPath:[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject]
                                                              cacheTime:cacheTime];
    
    [CIBURLCache setSharedURLCache:urlCache];
    
    // 手势解锁间隔，单位s
    lockInterval = [[MyUtils propertyOfResource:@"Setting" forKey:@"LockInterval"] intValue];
    
    [self.window makeKeyAndVisible];
    
    //  如果是此版本的第一次启动
    NSString *versionString = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSString *bundleFilesCachedKey = [NSString stringWithFormat:@"IsBundleFilesCachedForVersion %@", versionString];
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"IsBundleFilesCached"]) {
        [self cacheLocalResourceFiles];
        // app包里的文件已经复制到缓存中
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"IsBundleFilesCached"];
    }
    
    
    
    if ([SecUtils isP12ExistInDir:[SecUtils defaultCertDir]]) {
        
        // 检查是否达到资源文件检查更新的间隔
        CoreDataManager *cdManager = [[CoreDataManager alloc] init];
        double lastUpdateTime = [cdManager getUpdateTimeByName:@"ResourceFileUpdate"];
        double currentTime = [[NSDate date] timeIntervalSince1970];
        NSNumber *updateTimeInterval = [MyUtils propertyOfResource:@"Setting" forKey:@"ResourceFileUpdateInterval"];
        
        if (lastUpdateTime != 0.0 && currentTime - lastUpdateTime < [updateTimeInterval longValue]) {
            
        }
        else {
            [self updateResourceFileInfo];
        }
    }
    
    _isAppActive = YES;
    
    // 如果本地已经存在浏览器证书的话，把解密后的p12数据读取到全局变量里
    NSString *p12Path = [[SecUtils defaultCertDir] stringByAppendingPathComponent:SecFileP12];
    if ([Function isFileExistedAtPath:p12Path]) {
        NSData *p12data = [NSData dataWithContentsOfFile:p12Path];
        _decryptedP12Data = [[[CryptoManager alloc] init] decryptData:p12data];
    }
    else {
        _decryptedP12Data = nil;
    }
    
    // 由于在applicationDidBecomeActive方法中，也有初始化websocket的代码，此处可以注释掉
//    [self initWebsocket];
    
    return YES;
}

//初始化websocket
- (void)initWebsocket
{
    NSString *notesId = [AppInfoManager getUserName];
    
    if (notesId == nil) {
        return;
    }
    
    //websocket初始化
    NSString *serverUrl = kWebSocketURL;
    
    
    if (self.socket == nil) {
        self.socket = [[JFRWebSocket alloc] initWithURL:[NSURL URLWithString:serverUrl] protocols:nil];
    }
    
    self.socket.selfSignedSSL = YES;
    
    if (self.socket.delegate == nil) {
        self.socket.delegate = self;
    }
    //建立连接
    [self.socket connect];
    
    __weak AppDelegate *weak = self;
    __weak NSTimer *weakTimer = timer;
    self.socket.onConnect = ^{
        NSLog(@"websocket %@ is connected", [AppInfoManager getUserName]);
        //把 消息 图标激活
        [[NSNotificationCenter defaultCenter] postNotificationName:@"changMessageIcon_enable" object:nil];
        NSString *msg = [NSString stringWithFormat:@"[\"login\",\"%@\",\"string\"]", notesId];
        [weak.socket writeString:msg];
        // 设置定时任务，发送心跳
        if (!weakTimer) {
            timer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(sendWsPing) userInfo:nil repeats:YES];
            [weakTimer setFireDate:[NSDate distantPast]];
        }
    };
}

// 缓存一些常用js、css等资源
- (void) cacheMajorFiles {
    NSMutableArray *whiteList = [[NSMutableArray alloc] initWithObjects:
                                 @"https://220.250.30.210:8051/contact/js/global/allinone.min.js",
                                 @"https://220.250.30.210:8051/contact/css/global/allinone.min.css",
                                 nil];
    // sendSynchronousRequest请求也要经过NSURLCache，所以无需额外处理
    for (NSString *url in whiteList) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
            [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
        });
    }
}

// 从服务端获取资源文件的更新信息，并更新资源文件
- (void)updateResourceFileInfo {
    
    // 向服务端查询缓存文件的版本信息
    [CIBRequestOperationManager invokeAPI:@"gsfl" byMethod:@"POST" withParameters:nil onRequestSucceeded:^(NSString *responseCode, NSString *responseInfo) {
        if ([responseCode isEqualToString:@"I00"]) {
            NSDictionary *responseDic = (NSDictionary *)responseInfo;
            NSString *resultCode = [responseDic objectForKey:@"resultCode"];
            if ([resultCode isEqualToString:@"0"]) {
                
                NSArray *resourceInfoList = [responseDic objectForKey:@"result"];
                
                if (resourceInfoList && [resourceInfoList count] != 0) {
                    CoreDataManager *cdManager = [[CoreDataManager alloc] init];
                    [cdManager updateUpdateTimeByName:@"ResourceFileUpdate"];
                }
                
                NSOperationQueue *queue = [[NSOperationQueue alloc] init];
                [queue setMaxConcurrentOperationCount:3];
                
                for (NSDictionary *info in resourceInfoList) {
                    NSString *url = [info objectForKey:@"url"];
                    NSString *versionCode = [info objectForKey:@"versionCode"];
                    NSString *mimeType = [info objectForKey:@"mimeType"];
                    NSString *encodingType = [info objectForKey:@"encoding"];
                    
                    
                    
                    CIBLog(@"queue count: %lu", (unsigned long)[queue operationCount]);
                    
                    // 直接将request加入queue
                    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
                    // 将版本信息、mime类型、编码类型写进request的头里，以便后续使用
                    [request setValue:versionCode forHTTPHeaderField:@"versionCode"];
                    [request setValue:mimeType forHTTPHeaderField:@"mimeType"];
                    [request setValue:encodingType forHTTPHeaderField:@"encodingType"];
                    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                        
                    }];
                    
                    
                }
            }
        }
    } onRequestFailed:^(NSString *responseCode, NSString *responseInfo) {
        
    }];
}


// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
- (void)applicationWillResignActive:(UIApplication *)application {
    UIViewController *rootVC = self.window.rootViewController;
    // Webview进入后台后增加毛玻璃模糊效果
    if ([rootVC isKindOfClass:[MainViewController class]] ) {
        // 检查当前presented是否是WebView界面
        UIViewController *presentedVC = rootVC.presentedViewController;
        if ([presentedVC isKindOfClass:[CustomWebViewController class]]) {
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
            imageView.tag = 71111;
            imageView.image = [[MyUtils screenShotFromView:presentedVC.view] imgWithBlur];  // 默认配置即可
            [[[UIApplication sharedApplication] keyWindow] addSubview:imageView];
        }
        
    }
    //通过banner 进入 新闻详情
    if(self.newsDetailController){
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        imageView.tag = 71111;
        imageView.image = [[MyUtils screenShotFromView:self.newsDetailController.view] imgWithBlur];  // 默认配置即可
        [[[UIApplication sharedApplication] keyWindow] addSubview:imageView];
    }
    // 标记app为非激活状态
    _isAppActive = NO;
    enterBackgroundTime = [NSDate date];
    
    //  断开websocket连接，转为使用推送接收消息
    [self.socket disconnect];
    //  停止发送心跳消息的定时器
    if (timer) {
        [timer setFireDate:[NSDate distantFuture]];
    }
    self.socket.delegate = nil;
}

// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
- (void)applicationDidEnterBackground:(UIApplication *)application {
    
}

// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
- (void)applicationWillEnterForeground:(UIApplication *)application {
    // 手势解锁相关
    if ([FingerWorkManager isFingerWorkExisted]) {
        NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:enterBackgroundTime];
        if (interval > lockInterval) {
//            [self showLockViewController:LockViewTypeCheck onSucceeded:nil onFailed:nil];
        }
    }
        // 去除app图标上的小红点
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;

}

// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
- (void)applicationDidBecomeActive:(UIApplication *)application {
    // 移除Webview毛玻璃模糊效果
    if ([self.window.rootViewController isKindOfClass:[MainViewController class]] || self.newsDetailController) {
        NSArray *subViews = [[UIApplication sharedApplication] keyWindow].subviews;
        for (id object in subViews) {
            if ([[object class] isSubclassOfClass:[UIImageView class]]) {
                UIImageView *imageView = (UIImageView *)object;
                if(imageView.tag == 71111) {  // 动画移除模糊层
                    [UIView animateWithDuration:0.2 animations:^{
                        imageView.alpha = 0;
                        [imageView removeFromSuperview];
                    }];
                }
            }
        }
    }
    // 若app是从未激活状态返回且超过五分钟，弹出手势界面
    if (!_isAppActive) {
        _isAppActive = YES;
        if ([FingerWorkManager isFingerWorkExisted]) {
            NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:enterBackgroundTime];
            if (interval > lockInterval) {
               [self showLockViewController:LockViewTypeCheck onSucceeded:nil onFailed:nil];
            }
        }
    }
    
    // 重新连接websocket
    [self initWebsocket];
    //  启动发送心跳的定时器
    if (timer) {
        [timer setFireDate:[NSDate distantPast]];
    }
}

// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
- (void)applicationWillTerminate:(UIApplication *)application {
    CRYPTO_cleanup_all_ex_data();  // crypto.h中抄的注释:Release all "exself.data" state to prevent memory leaks.
//    [[NSURLCache sharedURLCache] removeAllCachedResponses];  // 目前版本禁止缓存
}
- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
//    [[CIBURLCache sharedURLCache] removeAllCachedResponses];
}

+ (AppDelegate *)delegate {
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

#pragma mark - 弹出手势解锁密码输入框
/*
 typedef enum {
     LockViewTypeCheck,  // 检查手势密码
     LockViewTypeCreate, // 创建手势密码
     LockViewTypeModify, // 修改
     LockViewTypeClean,  // 清除
 } LockViewType;
 */
- (void)showLockViewController:(LockViewType)type onSucceeded:(void(^)())onSucceededBlock onFailed:(void(^)())onFailedBlock
{
    if (self.lockVc == nil)
    {
        self.lockVc = [[LockViewController alloc] initWithType:type user:[AppInfoManager getUserName]];
        
        // 验证手势成功时的操作
        self.lockVc.succeededBlock = ^()
        {
            [AppDelegate delegate].lockVc = nil;
            
            if (onSucceededBlock) {
                onSucceededBlock();
                
            }
            
        };
        
        // 验证手势失败时的操作
        self.lockVc.failBlock = ^()
        {
            [AppDelegate delegate].lockVc = nil;
            
            if (onFailedBlock)
            {
                onFailedBlock();
            }
            
            LoginViewController *loginVC = [[LoginViewController alloc] init];
            loginVC.dismissWhenSucceeded = NO;
            UIViewController *vcPointer = loginVC;
            loginVC.loginSucceededBlock = ^()
            {
                
                // 登录成功后重新设置手势
                [AppDelegate delegate].isLogin = YES;
                [vcPointer dismissViewControllerAnimated:YES completion:^
                 {
                     [[AppDelegate delegate] showLockViewController:LockViewTypeCreate onSucceeded:nil onFailed:nil];
                 }];
            };
            
            [[AppDelegate delegate].window.rootViewController presentViewController:loginVC animated:YES completion:nil];
            
        };
        
        UIViewController *activeController = [UIApplication sharedApplication].keyWindow.rootViewController;
        while (activeController.presentedViewController) {
            activeController = activeController.presentedViewController;
        }
        self.lockVc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [activeController presentViewController:self.lockVc animated:YES completion:nil];
    }
}

#pragma mark - 向应用服务端注册推送服务
- (void)registerPushServiceToAppServerWithDeviceToken:(NSString *)deviceToken {
    // 如果本地密钥存在，则调用应用服务端注册接口，上报设备标识
    if ([DeviceKeyManager isDeviceKeyExisted]) {
        NSString *pushAppId = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"MPushAppID"];
        NSString *pushAppKey = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"MPushAppKey"];
        NSString *appId = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
        NSString *deviceId = [AppInfoManager getDeviceID];
        NSString *notesId = [NSString stringWithFormat:@"%@", [AppInfoManager getUserName]];
        id paramDic = @{@"pushAppId":pushAppId,
                        @"pushAppKey":pushAppKey,
                        @"pushToken":deviceToken,
                        @"notesId":notesId,
                        @"appId":appId,
                        @"sysType":@"ios",
                        @"deviceId":deviceId};
        [CIBRequestOperationManager invokeAPI:@"pushreg" byMethod:@"POST" withParameters:paramDic onRequestSucceeded:^(NSString *responseCode, NSString *responseInfo) {
            NSDictionary *responseDic = (NSDictionary *)responseInfo;
            NSString *resultCode = [responseDic objectForKey:@"resultCode"];
            if ([resultCode isEqualToString:@"0"]) {
                CIBLog(@"注册服务调用成功");
                // 此设备标识已经在应用服务端注册成功
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:deviceToken];
                // 标记一下此时设备已经激活，可以打开WebApp
                [AppDelegate delegate].isActive = YES;
            }
            else {
                CIBLog(@"注册服务调用失败");
                // 此设备标识在应用服务端注册失败
                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:deviceToken];
            }
            
        } onRequestFailed:^(NSString *responseCode, NSString *responseInfo) {
            CIBLog(@"注册服务调用失败");
            // 此设备标识在应用服务端注册失败
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:deviceToken];
            if ([responseCode isEqualToString:@"11"]) {
                // 标记一下此时设备未激活，不能打开WebApp
                [AppDelegate delegate].isActive = NO;
            }
        }];
    }
}
#pragma mark - 本地通知的处理逻辑



-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    
}

#pragma mark - 推送相关的回调方法
/**
 *  接收到推送消息的回调函数
 *
 *  @param title     消息的标题
 *  @param content   消息的正文
 *  @param extention 消息的附带信息（用于标记具体的WebApp等）
 *
 *  @return BOOL 当返回YES时，仅处理至当前事件处，后续事件将不再执行，当返回NO时，按照事件链继续执行，直至返回YES或者所有事件执行完。
 */
- (BOOL)onMessage:(NSString *)title content:(NSString *)content extention:(NSDictionary *)extention {
    CIBLog(@"title : %@ \n content : %@ \n extention : %@ \n",title,content,[extention description]);

    // 判断此消息是应用门户自身的消息还是给WebApp的消息
    BOOL isWebAppNoti = [extention objectForKey:@"isWebAppNoti"];
    if (isWebAppNoti) {
        /*
        // 获取推送来自的WebApp名称
        NSString *notiAppName = [extention objectForKey:@"appName"];
        // 修改数据库中相应WebApp的通知相关字段
        CoreDataManager *cdManager = [[CoreDataManager alloc] init];
//        NSArray *appList = [cdManager getAppList];
        NSArray *appList = [[AppDelegate delegate] getAppProductList];
        for (AppProduct *app in appList) {
            if ([notiAppName isEqualToString:app.appName]) {
                int notiNo = [app.notiNo intValue];
                notiNo ++;
                app.notiNo = [NSNumber numberWithInt:notiNo];
                [cdManager updateAppInfo:app];
                // 更新明文临时变量为空 需要重新从数据库中读取
                [[AppDelegate delegate] setAppProductList:appList];
                break;
            }
        }
        // 如果当前显示页面是主页的话，刷新一下主页上WebApp的图标
        if ([self.window.rootViewController isKindOfClass:[MainViewController class]]) {
            UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
            MainViewController *mainVC = [story instantiateViewControllerWithIdentifier:@"main"];
            if ([mainVC respondsToSelector:@selector(reloadFavorCollectionView)]) {
                [mainVC performSelector:@selector(reloadFavorCollectionView) withObject:nil];
            }
            
        }
         */
    }
    else {
        // 如果是应用门户本身的推送消息，做相应处理
    }

    return YES;
}

-(void)didReciveDeviceToken:(NSString *)deviceToken {
    CIBLog(@"deviceToken --- String : %@",deviceToken);
//    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:deviceToken];
    // 获取之前存储的设备标识
    NSString *formerDeviceToken = [[NSUserDefaults standardUserDefaults] objectForKey:kKeyOfDeviceToken];

    // 如果从未有过设备标识，或者此次获得的设备标识与之前本次存储的不一致，则将此新的设备标识存储在本地
    if (!formerDeviceToken || ![formerDeviceToken isEqualToString:deviceToken]) {
        [[NSUserDefaults standardUserDefaults] setObject:deviceToken forKey:kKeyOfDeviceToken];
        [self registerPushServiceToAppServerWithDeviceToken:deviceToken];
    }
    // 两次返回的设备标识一致
    
    else {
        // 此设备标识在应用服务端ƒ未能注册成功
        if (![[NSUserDefaults standardUserDefaults] boolForKey:deviceToken]) {
            [self registerPushServiceToAppServerWithDeviceToken:deviceToken];
        }
    }
}
- (NSArray *)getAppProductList {
    if (!_plainAppProductList) {
        _plainAppProductList = [[[CoreDataManager alloc] init] getAppList];
    }
    return _plainAppProductList;
}
- (NSArray *)getAppProductListFilter {
    NSArray* resultArry =[self getAppProductList];//[[[CoreDataManager alloc] init] getAppList];
    NSMutableArray* arrayList =[[NSMutableArray alloc] initWithArray:resultArry];
    // 找出有收藏标示的app和属于置顶类型的app
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        if ([evaluatedObject isKindOfClass:[AppProduct class]]) {
            
            AppProduct *product = (AppProduct *)evaluatedObject;
            //过滤掉 新闻 通讯录 信息
            if([[product appShowName] isEqualToString:@"新闻"] || [[product appShowName] isEqualToString:@"通讯录"] || [[product appShowName] isEqualToString:@"信息"]){
                return NO;
            }
            if ([product isFavorite]) {
                return YES;
            }
            if ([[product type] isEqualToString:@"FIXED"]) {
                return YES;
            }
        }
        return NO;
    }];
    
    [arrayList filterUsingPredicate:predicate];
    //按照sortIndex排序
    [arrayList sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        NSNumber *sort1  =[NSNumber numberWithInt:((AppProduct* )obj1).sortIndex];
        NSNumber *sort2  = [NSNumber numberWithInt:((AppProduct* )obj2).sortIndex];
        NSComparisonResult result = [sort1 compare:sort2];
        return result==NSOrderedDescending;//// 升序
    }];
    
    return arrayList;
}

- (void)setAppProductList:(NSArray *)appProductList {
    _plainAppProductList = appProductList;
}

- (void)cacheLocalResourceFiles {
    // 将本地包中的js、css等资源文件读取到缓存中
    NSMutableArray *resourceInfoList = [[NSMutableArray alloc] init];
    
    id resourceFileInfoArray = [MyUtils propertyOfResource:@"ResourceFile" forKey:@"ResourceFileInfo"];
    if ([resourceFileInfoArray isKindOfClass:[NSArray class]]) {
        for (NSDictionary *infoDic in resourceFileInfoArray) {
            NSString *url = [infoDic objectForKey:@"url"];
            NSString *fileName = [infoDic objectForKey:@"fileName"];
            NSString *versionCode = [infoDic objectForKey:@"versionCode"];
            NSString *mimeType = [infoDic objectForKey:@"mimeType"];
            NSString *encodingType = [infoDic objectForKey:@"encodingType"];
            CIBResourceInfo *resourceInfo = [[CIBResourceInfo alloc] initWithUrlAddress:url fileName:fileName versionCode:versionCode mimeType:mimeType encodingType:encodingType];
            [resourceInfoList addObject:resourceInfo];
        }
    }
    CIBURLCache *cache = (CIBURLCache *)[CIBURLCache sharedURLCache];
    for (CIBResourceInfo *info in resourceInfoList) {
        NSString *localFilePath = [[NSBundle mainBundle] pathForResource:[info fileName] ofType:nil];
        if ([Function isFileExistedAtPath:localFilePath]) {
            [cache readLocalFileResourceToCache:info];
        }
    }
}

#pragma mark -- WebSocket Delegate methods.


-(void)websocketDidDisconnect:(JFRWebSocket*)socket error:(NSError*)error {
    NSLog(@"websocket is disconnected: %@", [error localizedDescription]);
    NSInteger code = error.code;
    
    if (!_isAppActive) { // app已处于后台状态，无需弹出websocket断开的提示框
        return;
    }
    //把 消息 图标设置为灰色
    [[NSNotificationCenter defaultCenter] postNotificationName:@"changMessageIcon" object:nil];
    if ([MyUtils isSystemVersionBelowEight]) {
        if (code == 1000) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"您的账号在异地登录" delegate:self cancelButtonTitle:@"退出应用" otherButtonTitles:@"重新登录", nil];
            alert.tag = 9001;
            [alert show];
            
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"您的网络出问题咯，可能无法正常使用消息的功能。" delegate:self cancelButtonTitle:@"稍后再试" otherButtonTitles:@"重新连接", nil];
            alert.tag = 9002;
            [alert show];

        }
    }
    
    else {
        if (code == 1000) {
            UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"您的账号在异地登录" preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *relogin = [UIAlertAction actionWithTitle:@"重新登录" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                [socket connect];
            }];
            
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"退出应用" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                exit(0);
            }];
            
            [alertVc addAction:cancel];
            [alertVc addAction:relogin];
            
            if(self.window.rootViewController.presentedViewController){
                [self.window.rootViewController.presentedViewController presentViewController:alertVc animated:YES completion:nil];
            }else{
                [self.window.rootViewController presentViewController:alertVc animated:YES completion:nil];
            }
        } else {
            UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"您的网络出问题咯，可能无法正常使用消息的功能。" preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *relogin = [UIAlertAction actionWithTitle:@"重新连接" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                [socket connect];
            }];
            
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"稍后再试" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            
            [alertVc addAction:cancel];
            [alertVc addAction:relogin];
            if(self.window.rootViewController.presentedViewController){
               
                [self.window.rootViewController.presentedViewController presentViewController:alertVc animated:YES completion:nil];
            }else{
                [self.window.rootViewController presentViewController:alertVc animated:YES completion:nil];
            }
        }
    }
}

-(void)websocket:(JFRWebSocket*)socket didReceiveMessage:(NSString*)string {
    NSLog(string);
    
    [self updateUnreadMsgNumber:string];
    
    [self dealString:string];
    
}
#pragma mark -- 接收到消息处理

- (void)dealString:(NSString *)msg
{
    NSError *err;
    NSData *data = [msg dataUsingEncoding:NSUTF8StringEncoding];
    id item = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&err];
    
    if ([item isKindOfClass:[NSArray class]]) {
        NSArray *temp = (NSArray *)item;
        NSString *chatType = temp[0];
        NSString *toID = [AppInfoManager getUserName];
        NSString *toName = [AppInfoManager getValueForKey:kKeyOfUserRealName];
        if ([chatType isEqualToString:@"chat"]) {
            //根据返回的数据来判断该消息是群聊消息 还是单聊消息
            NSString *flag = temp[2];
            int type = 0;
            if (flag && ![flag isEqualToString:@""]) {
                type = 1;
            } else {
                type = 0;
            }
            Message *message = [[Message alloc] init];
            NSString *fileType = temp[5];
            if ([fileType isEqualToString:@"string"]) {
                message.fileType = FileTypeText;
            } else if ([fileType isEqualToString:@"pic"]) {
                message.fileType = FileTypePic;//图片
            }
            else if ([fileType isEqualToString:@"url"]) {
                message.fileType = FileTypeOpenUrl;//打开特定连接
            }
            else if ([fileType isEqualToString:@"app"]) {
                message.fileType = FileTypeOpenApp;//打开特定webApp
            }
            else  {
                message.fileType = FileTypeOther;//其他类型（文件）
            }
            //            NSLog(@"收到的URL消息是%@,%d", message.msgContent, message.fileType);
            if (type == 1) {
                message.groupId = temp[1];
                message.msgFromerId = temp[2];
                message.msgTime = [Public stringFromDate:[NSDate date] formatt:@"yyyy-MM-dd HH:mm:ss"];
                id content = temp[4];
                if ([content isKindOfClass:[NSString class]]) { // 文字/图片/文件类消息
                    message.msgContent = (NSString *)content;
                }
                else if ([content isKindOfClass:[NSDictionary class]]) { // url/app类消息
                    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:content options:NSJSONWritingPrettyPrinted error:nil];
                    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                    //                    NSLog(@"收到消息体是：%@", jsonString);
                    message.msgContent = jsonString;
                }
                else {
                    message.msgContent = @"消息格式解析错误";
                }
                message.msgToId = toID;
                message.msgToName = toName;
                message.msgType = @"1";
            } else {
                message.msgFromerId = temp[1];
                message.msgTime = [Public stringFromDate:[NSDate date] formatt:@"yyyy-MM-dd HH:mm:ss"];
                id content = temp[4];
                if ([content isKindOfClass:[NSString class]]) { // 文字/图片/文件类消息
                    message.msgContent = (NSString *)content;
                }
                else if ([content isKindOfClass:[NSDictionary class]]) { // url/app类消息
                    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:content options:NSJSONWritingPrettyPrinted error:nil];
                    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                    message.msgContent = jsonString;
                    //                    NSLog(@"收到消息体是：%@", jsonString);
                }
                else {
                    message.msgContent = @"消息格式解析错误";
                }
                message.msgToId = toID;
                message.msgToName = toName;
                message.msgType = @"1";
                message.groupId = @"";
            }
            message.chatType = type;
            Chatter *chat = [[ChatDBManager sharedDatabaseManager] queryContactor:message.msgFromerId];
            
            if (chat) {
                if (chat.iconPath == nil || [chat.iconPath isEqual:[NSNull null]]) {
                    [self getChatterNameFromChatterId:message.msgFromerId success:^(NSString *chatterName, NSString *iconPath) {
                        message.msgFromerName = chatterName;
                        // 更新此联系人
                        [[ChatDBManager sharedDatabaseManager] updateContactor:message.msgFromerId name:chatterName iconPath:iconPath];
                    } failure:^(NSError *error) {
                    }];
                }
                message.msgFromerName = chat.chatterName;
                [self messageHandle:message];
            } else {
                [self getChatterNameFromChatterId:message.msgFromerId success:^(NSString *chatterName, NSString *iconPath) {
                    message.msgFromerName = chatterName;
                    // 存储此新的联系人
                    Chatter *newChatter = [[Chatter alloc] init];
                    newChatter.chatterId = message.msgFromerId;
                    newChatter.chatterName = chatterName;
                    newChatter.iconPath = iconPath;
                    [[ChatDBManager sharedDatabaseManager] addContactor:newChatter];
                    [self messageHandle:message];
                } failure:^(NSError *error) {
                    message.msgFromerName = message.msgFromerId;
                    [self messageHandle:message];
                }];
            }
            
            
        } else if ([chatType isEqualToString:@"chat_list"]) {
            //获取离线消息--几个人的离线消息
            for (int i = 1; i < temp.count; i++) {
                //每个人发来的离线消息处理
                NSDictionary *offlineMsgs = temp[1];
                for (NSString *notesId in offlineMsgs) {
                    //每个人发来的离线消息处理
                    id msgItems = [offlineMsgs objectForKey:notesId];
                    if ([msgItems isKindOfClass:[NSArray class]]) {
                        NSArray *messages = (NSArray *)msgItems;
                        for (id item in messages) {
                            if ([item isKindOfClass:[NSArray class]]) {
                                Message *unlineMsg = [[Message alloc] init];
                                //根据返回的数据来判断该消息是群聊消息 还是单聊消息
                                NSString *flag = [(NSArray *)item objectAtIndex:0];
                                int type = 0;
                                if (flag && ![flag isEqualToString:@""]) {
                                    type = 1;
                                } else {
                                    type = 0;
                                }
                                NSString *file = [(NSArray *)item objectAtIndex:3];
                                if ([file isEqualToString:@"string"]) {
                                    unlineMsg.fileType = FileTypeText;
                                } else if ([file isEqualToString:@"pic"]) {
                                    unlineMsg.fileType = FileTypePic;//图片
                                }
                                else if ([file isEqualToString:@"url"]) {
                                    unlineMsg.fileType = FileTypeOpenUrl;//打开特定连接
                                }
                                else if ([file isEqualToString:@"app"]) {
                                    unlineMsg.fileType = FileTypeOpenApp;//打开特定webApp
                                }
                                else  {
                                    unlineMsg.fileType = FileTypeOther;//其他类型（文件）
                                }
                                //                                NSLog(@"收到的URL消息是%@,%d", unlineMsg.msgContent, unlineMsg.fileType);
                                if (type == 1) {
                                    unlineMsg.groupId = notesId;
                                    unlineMsg.msgFromerId = [(NSArray *)item objectAtIndex:0];
                                    unlineMsg.msgTime = [(NSArray *)item objectAtIndex:1];
                                    id content = [(NSArray *)item objectAtIndex:2];
                                    if ([content isKindOfClass:[NSString class]]) { // 文字/图片/文件类消息
                                        unlineMsg.msgContent = (NSString *)content;
                                    }
                                    else if ([content isKindOfClass:[NSDictionary class]]) { // url/app类消息
                                        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:content options:NSJSONWritingPrettyPrinted error:nil];
                                        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                                        unlineMsg.msgContent = jsonString;
                                        //                                        NSLog(@"收到消息体是：%@", jsonString);
                                    }
                                    else {
                                        unlineMsg.msgContent = @"消息格式解析错误";
                                    }
                                } else {
                                    unlineMsg.groupId = @"";
                                    unlineMsg.msgFromerId = notesId;
                                    unlineMsg.msgTime = [(NSArray *)item objectAtIndex:1];
                                    id content = [(NSArray *)item objectAtIndex:2];
                                    if ([content isKindOfClass:[NSString class]]) { // 文字/图片/文件类消息
                                        unlineMsg.msgContent = (NSString *)content;
                                    }
                                    else if ([content isKindOfClass:[NSDictionary class]]) { // url/app类消息
                                        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:content options:NSJSONWritingPrettyPrinted error:nil];
                                        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                                        unlineMsg.msgContent = jsonString;
                                        //                                        NSLog(@"收到消息体是：%@", jsonString);
                                    }
                                    else {
                                        unlineMsg.msgContent = @"消息格式解析错误";
                                    }
                                }
                                unlineMsg.msgToId = toID;
                                unlineMsg.msgToName = toName;
                                unlineMsg.msgType = @"1";
                                unlineMsg.chatType = type;
                                Chatter *chat = [[ChatDBManager sharedDatabaseManager] queryContactor:unlineMsg.msgFromerId];
                                
                                if (chat) {
                                    if (chat.iconPath == nil || [chat.iconPath isEqual:[NSNull null]]) {
                                        [self getChatterNameFromChatterId:unlineMsg.msgFromerId success:^(NSString *chatterName, NSString *iconPath) {
                                            unlineMsg.msgFromerName = chatterName;
                                            // 更新此联系人
                                            [[ChatDBManager sharedDatabaseManager] updateContactor:unlineMsg.msgFromerId name:chatterName iconPath:iconPath];
                                        } failure:^(NSError *error) {
                                        }];
                                    }
                                    unlineMsg.msgFromerName = chat.chatterName;
                                    [self messageHandle:unlineMsg];
                                } else {
                                    [self getChatterNameFromChatterId:unlineMsg.msgFromerId success:^(NSString *chatterName, NSString *iconPath) {
                                        unlineMsg.msgFromerName = chatterName;
                                        // 存储此新的联系人
                                        Chatter *newChatter = [[Chatter alloc] init];
                                        newChatter.chatterId = unlineMsg.msgFromerId;
                                        newChatter.chatterName = chatterName;
                                        newChatter.iconPath = iconPath;
                                        [[ChatDBManager sharedDatabaseManager] addContactor:newChatter];
                                        [self messageHandle:unlineMsg];
                                    } failure:^(NSError *error) {
                                        unlineMsg.msgFromerName = unlineMsg.msgFromerId;
                                        [self messageHandle:unlineMsg];
                                    }];
                                }
                                
                            }
                        }
                    }
                }
            }
            
        }
    }
    
}

/**
 *  获取的新消息处理
 *  判断该消息的来源和当前用户的消息记录是否存在，存在则修改本地数据和界面数据
 *  不存在，插入数据和添加到本地
 *  @param msg 消息
 */
- (void)messageHandle:(Message *)msg
{
    //将获取到的消息记录
    [[ChatDBManager sharedDatabaseManager] addChatMessage:msg];
    if (msg.chatType == 1) {
        msg.msgFromerId = msg.groupId;
    }
    
    BOOL isExist = [[ChatDBManager sharedDatabaseManager] ifExistNewestMessage:msg];
    
    if (isExist) {
        Message *message = [[ChatDBManager sharedDatabaseManager] findNewestMessageFromerID:msg.msgFromerId];
        if (message && message.chatType == 1) {
            msg.msgFromerName = message.msgFromerName;
        }
        CGFloat num = message.msgNum;
        num++;
        msg.msgNum = num;
        [[ChatDBManager sharedDatabaseManager] updateNewestMessage:msg];
    } else {
        msg.msgNum = 1;
        [[ChatDBManager sharedDatabaseManager] addNewestMessage:msg];
    }
}

- (void)getChatterNameFromChatterId:(NSString *)chatterId
                            success:(void (^)(NSString *chatterName, NSString *iconPath))success
                            failure:(void (^)(NSError *error))failure;
{
    /*
    
    id noteIdDic = @{@"notesId":chatterId};
    NSData *dicData = [NSJSONSerialization dataWithJSONObject:noteIdDic options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonStr = [[NSString alloc] initWithData:dicData encoding:NSUTF8StringEncoding];
    id parameter = @{@"command":@"userinfo", @"parameter":jsonStr};
    [[HttpManager sharedHttpManager] userNameAndIcon:kUserNameAndIconServerURL parameters:parameter success:^(NSDictionary *dic) {
        if (dic) {
            NSLog(@"用户信息：%@", dic);
            NSString *userInfo = [dic valueForKey:@"info"];
            
            NSData *jsonData = [userInfo dataUsingEncoding:NSUTF8StringEncoding];
            NSError *err;
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                options:NSJSONReadingMutableContainers
                                                                  error:&err];
            if(err) {
                NSLog(@"json解析失败：%@",err);
            }
            
            if (!dic) {
                return ;
            }
            
            NSString *userName = [[[dic objectForKey:@"result"] firstObject] valueForKey:@"USERNAME"] ? : chatterId;
            NSString *iconPath = [[[dic objectForKey:@"result"] firstObject] valueForKey:@"PICSTRING"];
            
            NSLog(@"用户姓名：%@", userName);
            success(userName, iconPath);
        }
    } fail:^(NSError *error) {
        NSLog(@"%@", error);
        failure(error);
    }];
     */
    id noteIdDic = @{@"notesid":chatterId};
    [CIBRequestOperationManager invokeAPI:@"contactsguiv2" byMethod:@"POST" withParameters:noteIdDic onRequestSucceeded:^(NSString *responseCode, NSString *responseInfo) {
        
        if ([responseCode isEqualToString:@"I00"]) {
            NSString *resultCode = [responseInfo valueForKey:@"resultCode"];
            if ([resultCode isEqualToString:@"0"]) {
                NSArray *resultDic = [responseInfo valueForKey:@"result"];
                NSString *userName = [[resultDic firstObject] valueForKey:@"USERNAME"] ? : chatterId;
                NSLog(@"用户姓名：%@", userName);
                NSString *iconPath = [[resultDic firstObject] valueForKey:@"PICSTRING"];
                
                success(userName, iconPath);
            }
        }
        
    } onRequestFailed:^(NSString *responseCode, NSString *responseInfo) {
        NSLog(@"%@", responseInfo);
        NSError *error = [NSError errorWithDomain:@"com.cib.chat" code:[responseCode integerValue] userInfo:@{NSLocalizedDescriptionKey: responseInfo}];
        failure(error);
    }];
    
}

-(void)websocket:(JFRWebSocket*)socket didReceiveData:(NSData*)data {
//    NSLog(@"Received data: %@", data);
}

- (void)sendWsPing {
//    NSLog(@"sending ping");
    [_socket writePing:nil];
}
-(float) getBannerHeight:(float) viewWidth{
    CGFloat tempH;
    CGFloat screenHiegth = [UIScreen mainScreen].bounds.size.height;

    CGFloat netImgWidth = 665;
    CGFloat netImgHeight=340;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        netImgWidth= netImgWidth/2;
        netImgHeight=netImgHeight/2;
    }
    else if (screenHiegth == 480) {
        netImgWidth= netImgWidth/2;
        netImgHeight=netImgHeight/2;
    }
    else if (screenHiegth == 568) {
        netImgWidth= netImgWidth/2;
        netImgHeight=netImgHeight/2;
    }
    else if (screenHiegth == 667){
        netImgWidth= netImgWidth/2;
        netImgHeight=netImgHeight/2;
    }
    else if (screenHiegth == 736)
    {
        netImgWidth= netImgWidth/3;
        netImgHeight=netImgHeight/3;
        
    }
    tempH =(netImgHeight*viewWidth)/netImgWidth;
    return tempH;
}

// 响应返回按钮
- (void)setBackPress:(UIViewController*)currController{

    [currController dismissViewControllerAnimated:YES completion:nil];
    
}
-(void) loginOut:(UIViewController*) currController{
    [AppDelegate delegate].lockVc=nil;
    ImageAlertView *alertView = [[ImageAlertView alloc] initWithFrame:currController.view.frame];
    alertView.isHasBtn = NO;
    [alertView viewShowWithImage:[UIImage imageNamed:@"ic_refresh"] message:@"正在注销..."];
    [currController.view addSubview:alertView];
    
    //清楚本地数据库的信息
//    [[ChatDBManager sharedDatabaseManager] deleteAllContactor];
//    [[ChatDBManager sharedDatabaseManager] deleteAllMessage];
//    [[ChatDBManager sharedDatabaseManager] deleteAllNewestMessage];
    
    // 清除WebApp缓存的图片
    NSString *cacheDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSArray *cacheFilePaths = [[NSFileManager defaultManager] subpathsAtPath:cacheDir];
    for (NSString *cachePath in cacheFilePaths) {
        NSRange range = [cachePath rangeOfString:@".jpg"];
        if (range.location != NSNotFound) {
            NSString *fullPath = [NSString stringWithFormat:@"%@/%@", cacheDir, cachePath];
            [Function deleteFileAtPath:fullPath];
        }
    }
    
    // 清除用户私钥
    [DeviceKeyManager cancelDeviceKeyOnCancelSucceeded:^(NSString *responseCode, NSString *responseInfo) {
        CIBLog(@"cancelDeviceKeySucceeded");
        [alertView removeFromSuperview];
        
        // 清除手势、个人信息、浏览器证书
        [FingerWorkManager clearFingerWork];
        [AppInfoManager clearUserInfo];
        NSString *p12FilePath = [[SecUtils defaultCertDir] stringByAppendingPathComponent:SecFileP12];
        [[NSFileManager defaultManager] removeItemAtPath:p12FilePath error:nil];
        // 清除前一用户的浏览记录
        [AppDelegate delegate].tabList = [[NSMutableArray alloc] init];
        [self setBackPress:currController];
    }
                                        onCancelFailed:^(NSString *responseCode, NSString *responseInfo) {
                                            CIBLog(@"cancelDeviceKeyFailed: %@", responseInfo);
                                            [alertView removeFromSuperview];
                                            
                                            // 清除手势、个人信息、浏览器证书
                                            [FingerWorkManager clearFingerWork];
                                            //            [AppInfoManager clearUserInfo];  // 失败时不删除userinfo，重新登录会覆盖
                                            [DeviceKeyManager deleteDeviceKey];
                                            NSString *p12FilePath = [[SecUtils defaultCertDir] stringByAppendingPathComponent:SecFileP12];
                                            [[NSFileManager defaultManager] removeItemAtPath:p12FilePath error:nil];
                                            // 清除前一用户的浏览记录
                                            [AppDelegate delegate].tabList = [[NSMutableArray alloc] init];
                                            
                                            [self setBackPress:currController];
                                        }];
}

//截取屏幕
-(void) saveMainScreenShot:(UIView*) mainView{
    UIImageView *imageView1 = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    imageView1.image = [[MyUtils screenShotFromView:mainView] imgWithBlur];  // 默认配置即可
    [AppDelegate delegate].mainScreenShot=imageView1;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (alertView.tag) {
        case 9001:
            switch (buttonIndex) {
                case 0:
                    exit(0);
                    break;
                case 1:
                    [self.socket connect];
                    break;
                default:
                    break;
            }
            
            break;
        case 9002:
            switch (buttonIndex) {
                case 0:
                    break;
                case 1:
                    [self.socket connect];
                    break;
                default:
                    break;
            }
            break;
        default:
            break;
    }
}

- (void)updateUnreadMsgNumber:(NSString *)message {
    
    NSInteger countFromThisMessage = 0;
    
    NSError *err;
    NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];
    id item = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&err];
    
    if ([item isKindOfClass:[NSArray class]]) {
        NSArray *temp = (NSArray *)item;
        NSString *chatType = temp[0];
        if ([chatType isEqualToString:@"chat"]) {
            countFromThisMessage += 1;
        }
        else if ([chatType isEqualToString:@"chat_list"]) {
            NSDictionary *offlineMsgs = temp[1];
            for (NSString *notesId in offlineMsgs) {
                NSArray *msgs = [offlineMsgs objectForKey:notesId];
                if ([msgs isKindOfClass:[NSArray class]]) {
                    countFromThisMessage += [msgs count];
                }
            }
        }
    }
    
    // 更新小红点逻辑
    NSString *unreadMsgNumber = [[NSUserDefaults standardUserDefaults] objectForKey:kKeyOfUnreadMsgNumber];
    if (unreadMsgNumber == nil) { // 从未在本地存储过未读消息数目
        unreadMsgNumber = [NSString stringWithFormat:@"%ld", (long)countFromThisMessage];
    }
    else {
        NSInteger oldUnreadMsgNumber = [unreadMsgNumber integerValue];
        unreadMsgNumber = [NSString stringWithFormat:@"%ld", (long)(oldUnreadMsgNumber + countFromThisMessage)];
    }
    [[NSUserDefaults standardUserDefaults] setObject:unreadMsgNumber forKey:kKeyOfUnreadMsgNumber];
    // 发送通知更新首页的小红点显示
    [[NSNotificationCenter defaultCenter] postNotificationName:kUnreadMsgNumberUpdatedNotification object:nil];
}

// 配置环境（生产/测试外网/测试内网）
- (void)configEnv {
    
    // 读取Plist文件中相关值
    NSDictionary *infoDic = [[NSBundle mainBundle] infoDictionary];
//    NSString *version = [infoDic objectForKey:@"CFBundleVersion"];

    
#ifdef TEST_ENV_INNER
    
//    [AppInfoManager initialAppInfoWithBasicURLAddress:@"https://168.3.23.207:7050/openapi"];
    [AppInfoManager initialAppInfoWithBasicURLAddress:@"https://168.7.1.49:9000/openapi"];
    
#else
#ifdef TEST_ENV_OUTER
    
    // OPENAPI地址
    [AppInfoManager initialAppInfoWithBasicURLAddress:@"https://220.250.30.210:8050/openapi/"];
    
    // MPush服务器地址及AppKey等（MPush从info.plist中读取数据，如何区分测试环境和生产环境？）
    
    // TalkingData服务AppKey
    NSString *tdKey = [infoDic valueForKey:@"TalkingDataKey_TestEnv"];
    [TalkingData sessionStarted:tdKey withChannelId:nil];
    [TalkingData setExceptionReportEnabled:YES];
    
#else
    
    [AppInfoManager initialAppInfoWithBasicURLAddress:[MyUtils propertyOfResource:@"Setting" forKey:@"BaseUrl"]];
    
    NSString *tdKey = [infoDic valueForKey:@"TalkingDataKey_ProdEnv"];
    [TalkingData sessionStarted:tdKey withChannelId:nil];
    [TalkingData setExceptionReportEnabled:YES];

#endif
    
#endif
}

@end
