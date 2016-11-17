//
//  AppDelegate.h
//  CIBSafeBrowser
//
//  Created by cib on 14/12/4.
//  Copyright (c) 2014年 cib. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LockViewController.h"
#import "JFRWebSocket.h"
#import "NewWebViewController.h"
@interface AppDelegate : UIResponder <UIApplicationDelegate, JFRWebSocketDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic) BOOL hasCheckedUpdate;  // 本次启动是否已检查更新
@property (nonatomic) BOOL hasLoadAppListFromServer;  // 本次启动是否已刷新App列表

@property (strong, nonatomic) LockViewController *lockVc; // 解锁界面

@property (nonatomic, strong) NSMutableArray *tabList;  // 选项卡列表
@property (nonatomic, assign) BOOL isLogin;  // 应用登录状态
@property (nonatomic, assign) BOOL isUnlock;  // 应用解锁状态
@property (nonatomic, assign) BOOL isActive; // 证书激活状态
@property (nonatomic, assign) BOOL isAppActive; // 应用激活状态

@property (nonatomic, strong) NSData *decryptedP12Data;  // 解密后的p12二进制数据

@property (nonatomic, strong) NSArray *plainAppProductList; // 明文的WebApp信息

@property (nonatomic, strong) JFRWebSocket *socket;

@property (nonatomic, strong) UIImageView *mainScreenShot;  // 主页截屏
//@property (strong, nonatomic) LockViewController *lockVc1; // 解锁界面

@property (strong,nonatomic) NewWebViewController *newsDetailController;  // 是否在新闻详情界面


+ (AppDelegate *)delegate;
- (void)showLockViewController:(LockViewType)type onSucceeded:(void(^)())onSucceededBlock onFailed:(void(^)())onFailedBlock;

/**
 *  向应用服务端注册推送服务
 *
 *  @param deviceToken 设备标识
 */
- (void)registerPushServiceToAppServerWithDeviceToken:(NSString *)deviceToken;

/**
 *  更新资源文件
 */
- (void)updateResourceFileInfo;

/**
 *  获取临时的明文WebApp信息
 *
 *  @return 临时的明文WebApp信息
 */
- (NSArray *)getAppProductList;

- (NSArray *)getAppProductListFilter;

/**
 *  设置临时的明文WebApp信息
 *
 *  @param appProductList 临时的明文WebApp信息
 */
- (void)setAppProductList:(NSArray *)appProductList;


- (void)cacheLocalResourceFiles;

//初始化websocket
- (void)initWebsocket;

//获取banner高度
-(float) getBannerHeight:(float) viewWidth;
-(void) loginOut:(UIViewController*) currController;
-(void) saveMainScreenShot:(UIView*) mainView;

// 更新未读消息条数
- (void)updateUnreadMsgNumber:(NSString *)message;

@end

