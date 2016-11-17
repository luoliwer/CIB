//
//  MainViewController.m
//  CIBSafeBrowser
//
//  Created by cib on 15/2/10.
//  Copyright (c) 2015年 cib. All rights reserved.
//

#import "MainViewController.h"

#import "LoginViewController.h"
#import "FavorViewController.h"
#import "SearchViewController.h"
#import "TabsViewController.h"
#import "SettingViewController.h"
#import "ActivationViewController.h"
#import "CommonNavViewController.h"
#import "CustomStatusBar.h"
#import "AppCell.h"
#import "AppDelegate.h"
#import "AppProduct.h"
#import "ImageAlertView.h"

#import "MyUtils.h"
#import "SecUtils.h"
#import "CoreDataManager.h"
#import "Config.h"

#import "MBProgressHUD.h"
#import "UIImageView+WebCache.h"
#import "UIImage+BlurGlass.h"

#import <CIBBaseSDK/CIBBaseSDK.h>
#import "MyTouchView.h"
#import "SetAuthorViewController.h"
#import "AppFavor.h"

#define IS_iPad  [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface MainViewController () <UITextFieldDelegate, UIGestureRecognizerDelegate, UIAlertViewDelegate,UIScrollViewDelegate>
{
    FavorViewController *favorVC;
    SearchViewController *searchVC;
    CustomStatusBar *_customStatusBar;
    CGRect _currentFrame;
}

@property (strong, nonatomic) IBOutlet UIView *favorContainerView;  // 收藏区
@property (strong, nonatomic) IBOutlet UIView *toolTabView;

@property (nonatomic, strong) UIView *navigationView;
@property (nonatomic, strong) MyTouchView *toolEditView;
@property (nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;
@property(nonatomic, assign) CGPoint panGestureStartLocation;
@property(nonatomic, assign) CGRect originLogoIVBounds, originSearchTFBounds, originFavorCVBounds,originInfoViewBounds;
@property(nonatomic, assign) BOOL isOriginSet;
@property(nonatomic, assign) CGFloat navigateHeight;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *favorTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *favorHeightConstraint;
@property(nonatomic, assign) CGFloat defalutY;  //collectionY 在最顶端的距离

- (IBAction)appDeletPress:(id)sender;
- (IBAction)editExitPress:(id)sender;

@end

@implementation MainViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.mainFromState=MainFromDefault;  //设置默认状态
    [self setupGestureRecognizers];
    self.view.backgroundColor = UIColorFromRGB(0xfcfcfc);
    self.mainViewState = MainViewControllerStateStreched;
    self.isOriginSet = NO;
    [self.view bringSubviewToFront:self.searchContainerView];
    self.searchContainerView.hidden = YES;
    [self navigationBarViewOut];//显示顶部导航栏
    
    [self favorContaitViewLoad];
    [self tagViewLoad];
    [self initToolEdit];
    self.favorContainerView.backgroundColor=[UIColor clearColor];
    favorVC.view.backgroundColor=[UIColor clearColor];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hadLongPress) name:@"longPressGestureRecognized" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pressCancelBtn) name:@"pressCancelBtn" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addAppDone) name:@"appChangeDone" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getOffsetY:) name:@"moveItemContentOffset" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didDeletApp) name:@"didDeletApp" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateWebappFromServer) name:@"setAuthorSucc" object:nil];
    
     CoreDataManager *cdManager = [[CoreDataManager alloc] init];
    NSString *lastUserId = [cdManager lastUserId];
    if ([lastUserId isEqualToString:@""]) { // 解决首次安装未经过登陆界面 没有记住用户名ID
        lastUserId = [AppInfoManager getUserID];
        [cdManager setLastUserId:lastUserId];
    }
}
- (void)comeToAddFavor{
    [self performSegueWithIdentifier:@"mainToAddSegue" sender:nil];
}

- (void)setupGestureRecognizers {
    self.panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    self.panGestureRecognizer.maximumNumberOfTouches = 1;
//    [favorVC.view addGestureRecognizer:self.panGestureRecognizer];
    [self.view addGestureRecognizer:self.panGestureRecognizer];
}
- (void)pan:(UIPanGestureRecognizer *)recognizer
{
    CGPoint location = [recognizer locationInView:self.navigationView];
    BOOL isCon = CGRectContainsPoint(self.navigationView.frame,location);
    //如果触摸的是上访导航栏区域
    if(isCon){
        return;
    }
//    //判断是否在最顶部
    BOOL ifInTop = fabs(self.favorTopConstraint.constant-self.defalutY)<0.2;
    CGRect f = _currentFrame;
    if(f.size.height+self.navigateHeight <=[[UIScreen mainScreen] bounds].size.height && ifInTop){
        return;
    }
    CGPoint translation = [recognizer translationInView:self.view];
    float newY =f.origin.y + translation.y;
//    //下啦到顶部
    newY=newY>self.navigateHeight-20?self.navigateHeight-20:newY;
    //上拉到顶部
    float tabHeight =20; //底部背景显示区域的高度
    float toolEditHeight=0;//底部编辑栏高度
    if(_toolEditView){
        //显示状态
        if(_toolEditView.frame.origin.y<[[UIScreen mainScreen] bounds].size.height){
            toolEditHeight=_toolEditView.frame.size.height;
        }
    }
    float mainHeight =[[UIScreen mainScreen] bounds].size.height-tabHeight-toolEditHeight;
    if(newY+f.size.height<mainHeight && f.size.height+self.navigateHeight >[[UIScreen mainScreen] bounds].size.height){
       newY=mainHeight-f.size.height;
    }
    //当删除应用上 顶部有超出屏幕区域 底部有空白是 不能向上滑动
    if(newY+f.size.height<=[[UIScreen mainScreen] bounds].size.height-toolEditHeight-40 && translation.y<0){
        return;
    }
    f.origin.y =newY;
    self.favorTopConstraint.constant=newY;
    CGRect fr = self.favorContainerView.frame;
    fr.size.height=f.size.height;
    self.favorContainerView.frame=fr;
    [recognizer setTranslation:CGPointMake(0, 0) inView:self.view];
    [self calibrateFrameOfFavorColletionView];
    _currentFrame = f;
    
}

// 是否支持转屏
- (BOOL)shouldAutorotate {
    if (IS_iPad && !self.searchContainerView.hidden) {
        return YES;
    }else{
        return NO;
    }
}
-(NSUInteger)supportedInterfaceOrientations{
    if (IS_iPad && !self.searchContainerView.hidden) {
        return UIInterfaceOrientationMaskAll;
    }
    else{
        return UIInterfaceOrientationMaskPortrait;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // 根据tab数切换相应图标
    NSArray *tabList = [AppDelegate delegate].tabList;
    NSArray *subviews = [self.toolTabView subviews];
    if (tabList) {
        for (UIView *view in subviews) {
            if ([view isKindOfClass:[UILabel class]]) {
                UILabel *label = (UILabel *)view;
                label.text = [NSString stringWithFormat:@"%lu",(unsigned long)[tabList count]];
            }
        }
    }
    [favorVC reloadFavors];
    
}
-(void) appearInit{
    // 保留原有位置信息
    // 因为显示后不会有变，而viewdidload阶段有时获取不正确（600*600）
    if (!self.isOriginSet) {
        self.originFavorCVBounds = self.favorContainerView.frame;
        self.isOriginSet = YES;
        
    }
    
    // 检查更新
    if (![AppDelegate delegate].hasCheckedUpdate && [MyUtils isNetworkAvailable]) {
        [AppDelegate delegate].hasCheckedUpdate = YES;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            [self checkUpdate];
            dispatch_async(dispatch_get_main_queue(), ^{});
        });
    }
    // 检查设备在应用服务端的推送注册状态
    NSString *deviceToken = [[NSUserDefaults standardUserDefaults] objectForKey:kKeyOfDeviceToken];
    // 此设备标识在应用服务端未能注册成功
    if (deviceToken) {
        if (![[NSUserDefaults standardUserDefaults] boolForKey:deviceToken]) {
            [[AppDelegate delegate] registerPushServiceToAppServerWithDeviceToken:deviceToken];
        }
    }
    else {
        CIBLog(@"没有读取到token");
    }
    // 检查缓存更新
    // 检查是否达到资源文件检查更新的间隔
    CoreDataManager *cdManager = [[CoreDataManager alloc] init];
    double lastUpdateTime = [cdManager getUpdateTimeByName:@"ResourceFileUpdate"];
    double currentTime = [[NSDate date] timeIntervalSince1970];
    NSNumber *updateTimeInterval = [MyUtils propertyOfResource:@"Setting" forKey:@"ResourceFileUpdateInterval"];
    
    if (lastUpdateTime != 0.0 && currentTime - lastUpdateTime < [updateTimeInterval longValue]) {
        
    }
    else {
        [[AppDelegate delegate] updateResourceFileInfo];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    
    self.view.backgroundColor=[UIColor colorWithRed:239/255.0 green:240/255.0 blue:245/255.0 alpha:1.0];
    [super viewDidAppear:animated];
    
    if(self.navigateHeight==0.0){
        _currentFrame = self.favorContainerView.frame;
        self.navigateHeight=_currentFrame.origin.y;
    }
    AppDelegate *appDelegate = [AppDelegate delegate];
    
    if(self.ifReturn){
        self.ifReturn=FALSE;
        return;
    }
    //isSucc true:已经验证不需要跳往激活界面
    __block id currSelf = self;
    void(^CAValiCallback)(BOOL)=^(BOOL isSucc){
        if(isSucc){
           if(![FingerWorkManager isFingerWorkExisted]) {
                [[AppDelegate delegate] showLockViewController:LockViewTypeCreate
                                                   onSucceeded:^(){
                                                       appDelegate.isLogin = YES;
                                                       appDelegate.isUnlock = YES;
                                                   }
                                                      onFailed:nil
                 ];
                
                return;
            }
            else if (!appDelegate.isUnlock) {
                [[AppDelegate delegate] showLockViewController:LockViewTypeCheck
                                                   onSucceeded:^(){
                                                       appDelegate.isLogin = YES;
                                                       appDelegate.isUnlock = YES;
                                                   }
                                                      onFailed:nil
                 ];
                
                return;
            }else {
                [currSelf appearInit];
            }
        }else{
            [currSelf appearInit];
        }
    };
    
    // 检查设备激活状态
    // 暂无该接口，只能在通信中判断
    BOOL ifValidate = YES;
    if (![DeviceKeyManager isDeviceKeyExisted] ||  // 第一次登录（申请devicekey）
        (!appDelegate.isLogin &&   // 重新登录
         (![FingerWorkManager isFingerWorkExisted] ||
          [FingerWorkManager getFingerWorkRemainTestTimes] < 1  // 兼容老版本
          )
         )
        ) {
        LoginViewController *loginVC = [[LoginViewController alloc] init];
        __block LoginViewController* loginVCBlock=loginVC;
        loginVC.loginSucceededBlock = ^(){
            self.loginSucceededBlock();
            [loginVCBlock dismissViewControllerAnimated:YES completion:nil];
        };
        [self presentViewController:loginVC animated:YES completion:nil];
        return;
    } else if (![SecUtils isP12ExistInDir:[SecUtils defaultCertDir]]) {  // 检查证书
        ifValidate=NO;
        if ([MyUtils isNetworkAvailable]) {
            [self loadCACertificate:CAValiCallback toView:self.view];
        }
    }
    else if ([MyUtils isNetworkAvailable]) {  // 有证书就刷新app
        //每次启动 同步下favor 与AppList
        static dispatch_once_t onceToken ;
        dispatch_once(&onceToken, ^{
            NSArray *appList = [[AppDelegate delegate] getAppProductListFilter];
            CoreDataManager *cdManager = [[CoreDataManager alloc] init];
            for (AppProduct* product in appList) {
                if(product.isFavorite){
                    [cdManager insertAppFavorWithAppName:product.appName sortIndex:product.sortIndex];
                }else{
                    [cdManager deleteAppFavor:product.appName];
                }
            }
        }) ;
        
        NSArray *appList = [[AppDelegate delegate] getAppProductList];
        if (!appDelegate.hasLoadAppListFromServer)  { // 从没刷新过
            
            
            if (!appList ||[appList count] == 0) { // 当前列表为空
                [self loadAppListFromServerWithHUD:YES ifFromSetAuthor:NO];
            }
            else {
                [self loadAppListFromServerWithHUD:NO  ifFromSetAuthor:NO];
            }
            
        }else if(self.mainFromState==MainFromSetAuthorSucc){
            self.mainFromState=MainFromDefault;
            if (!appList ||[appList count] == 0) { // 当前列表为空
                [self loadAppListFromServerWithHUD:YES ifFromSetAuthor:YES];
            }
            else {
                [self loadAppListFromServerWithHUD:NO  ifFromSetAuthor:YES];
            }
        }
        
    }
    if(ifValidate){
        CAValiCallback(YES);
    }
}

// 旋转后的处理
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    
    // 重新保留原有位置信息
    self.originFavorCVBounds = self.favorContainerView.frame;
    self.isOriginSet = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"childOfFavorSegue"]) {
        favorVC = [segue destinationViewController];
    }
    else if ([segue.identifier isEqualToString:@"childOfSearchSegue"]) {
        searchVC = [segue destinationViewController];
    }else if([segue.identifier isEqualToString:@"setAuthorSegue"]){
        SetAuthorViewController* authorView = [segue destinationViewController];
        if(sender){
            authorView.lineTypeArray=sender;
            authorView.isMondify=NO;
        }
    }
}
//  生成ssl通信证书
- (void)loadCACertificate:(void(^)(BOOL ifSucc)) resultBlock toView:(UIView*) currView {
    ImageAlertView *alertView = [[ImageAlertView alloc] initWithFrame:currView.frame];
    alertView.isHasBtn = NO;
    [alertView viewShowWithImage:[UIImage imageNamed:@"ic_refresh"] message:@"正在生成证书..."];
    [currView addSubview:alertView];
    // 新开线程生成证书
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        // 处理耗时操作的代码块...（生成证书）
        NSString *certDir = [SecUtils defaultCertDir];
        [SecUtils generateRSAKeyPairInDir:certDir];  // 创建密钥对
        [SecUtils generateX509ReqInDir:certDir];  // 创建证书请求
        
        NSString *csrPath = [certDir stringByAppendingPathComponent:SecFileX509ReqPem];
        NSString *csrString = [[NSString alloc] initWithContentsOfFile:csrPath encoding:NSUTF8StringEncoding error:nil];
        
        // 线程完成时的操作，此处为请求服务器对证书进行签名
        dispatch_async(dispatch_get_main_queue(), ^{
            
            // 请求成功的回调函数
            void(^succeededBlock)(NSString *, NSString *) = ^(NSString *responseCode, NSString *responseInfo) {
                resultBlock(YES);
                
                if ([responseCode isEqualToString:@"I00"] || [responseCode isEqualToString:@"0"]) {
                    CIBLog(@"CA认证成功");
                    // 标记一下此时设备已经激活，可以打开WebApp
                    [AppDelegate delegate].isActive = YES;
                    
                    // 此处应该往keychain中写入私钥信息
                    NSString *priPath = [certDir stringByAppendingPathComponent:SecFilePriKeyPem];
                    NSString *priKey = [NSString stringWithContentsOfFile:priPath encoding:NSUTF8StringEncoding error:nil];
                    [AppInfoManager setValue:priKey forKey:kKeyOfBrowserPrivateKey];
                    
                    if (responseInfo == nil) {
                        [alertView removeFromSuperview];
//                        [hud removeFromSuperview];
                        [MyUtils showAlertWithTitle:@"证书内容为空" message:nil];
                        
                        return;
                    }
                    else {
                        NSError *error = nil;
                        NSString *filePath = [certDir stringByAppendingPathComponent:SecFileX509Cert];
                        NSString *decodeContent = [Function decodeFromPercentEscapeString:responseInfo];
                        [decodeContent writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
                        if (error == nil) {
                            [alertView viewShowWithImage:[UIImage imageNamed:@"ic_refresh"] message:@"正在安装证书..."];
//                            hud.labelText = @"正在安装证书...";
                            [SecUtils generateP12InDir:certDir];  // 合成p12文件
//                            [hud removeFromSuperview];
                            [alertView removeFromSuperview];
                            
                            // 更新证书更换时间
                            CoreDataManager *cdManager = [[CoreDataManager alloc] init];
                            [cdManager updateUpdateTimeByName:@"BrowserCert"];
                            
                            // 如果还没检查过应用更新
                            if (![AppDelegate delegate].hasLoadAppListFromServer) {
//                                [self loadAppListFromServer];
                                // 如果app列表为空，则带有遮罩的进行app列表获取，避免用户进入添加页后空白
                                if ([[AppDelegate delegate] getAppProductList]) {
                                    [self loadAppListFromServerWithHUD:NO  ifFromSetAuthor:NO];
                                }
                                else {
                                    [self loadAppListFromServerWithHUD:YES  ifFromSetAuthor:NO];
                                }
                            }
                            [[AppDelegate delegate] updateResourceFileInfo];
                        }
                        else {
//                            [hud removeFromSuperview];
                            [alertView removeFromSuperview];
                            [MyUtils showAlertWithTitle:error.localizedDescription message:nil];
                        }
                    }
                }
                else {
                    [alertView removeFromSuperview];
//                    [hud removeFromSuperview];
                    CIBLog(@"failed ,code = %@, info = %@", responseCode, responseInfo);
                    [MyUtils showAlertWithTitle:responseInfo message:nil];
                }
            };
            
            // 请求失败的回调函数
            void(^failedBlock)(NSString *, NSString *) = ^(NSString *responseCode, NSString *responseInfo) {
//                [hud removeFromSuperview];
                BOOL ifExistCA= NO;
                [alertView removeFromSuperview];
                if ([responseCode isEqualToString:@"11"]) {
//                    [MyUtils showAlertWithTitle:responseInfo message:nil];
                    // 标记一下此时设备未激活，不能打开WebApp
                    [AppDelegate delegate].isActive = NO;
                    [MyUtils showAlertWithTitle:responseInfo message:nil autoHideAfterSeconds:1];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        
                        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Setting" bundle:[NSBundle mainBundle]];
                        ActivationViewController *activation = [story instantiateViewControllerWithIdentifier:@"activation"];
                        [self presentViewController:activation animated:YES completion:nil];
                    });
                    
                }
                // 用户名密码N天未验证
                else if ([responseCode isEqualToString:@"18"]) {
                    [MyUtils showAlertWithTitle:responseInfo message:nil autoHideAfterSeconds:1];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        LoginViewController *loginVC = [[LoginViewController alloc] init];
                        __block LoginViewController *loginVCBlock=loginVC;
                        loginVC.loginSucceededBlock = ^(){
                            self.loginSucceededBlock();
                            [loginVCBlock dismissViewControllerAnimated:YES completion:nil];
                        };
                        [self presentViewController:loginVC animated:YES completion:nil];
                    });
                }
                else {
                   [MyUtils showAlertWithTitle:responseInfo message:nil];
                    ifExistCA= YES;
                }
                
                resultBlock(ifExistCA);
                
            };
            
            
            @try {
                [alertView viewShowWithImage:[UIImage imageNamed:@"ic_refresh"] message:@"服务器认证中..."];
//                hud.labelText = @"服务器认证中...";
                
                NSString *isIntern = @"";
                
                // 测试配置
                if ([[URLAddressManager getBasicURLAddress] rangeOfString:@"168.3.23.207"].location != NSNotFound) {
                    isIntern = @"true";
                }
                
                id paramDic = @{@"pkcs":[Function encodeToPercentEscapeString:csrString], @"isIntern":isIntern, @"days":@"365"};
                NSString *URI = @"signCert";
                [CIBRequestOperationManager invokeAPI:URI
                                             byMethod:@"POST"
                                       withParameters:paramDic
                                   onRequestSucceeded:succeededBlock
                                      onRequestFailed:failedBlock];
            }
            @catch (NSException *exception) {
                [alertView removeFromSuperview];
//                [hud removeFromSuperview];
                [MyUtils showAlertWithTitle:exception.description message:nil];
            }
            
        });
    });
    
}

// 检查应用更新
- (void)checkUpdate {
    CoreDataManager *cdManager = [[CoreDataManager alloc] init];
    double lastUpdateTime = [cdManager getUpdateTimeByName:@"AppUpdate"];
    double currentTime = [[NSDate date] timeIntervalSince1970];
    NSNumber *updateTimeInterval = [MyUtils propertyOfResource:@"Setting" forKey:@"UpdateTimeInterval"];
    
    if (lastUpdateTime != 0.0 && currentTime - lastUpdateTime < [updateTimeInterval longValue]) {
        return;
    }
    
    // 设备类型
    NSString *deviceType = @"iPhone";
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {  // ipad
        deviceType = @"iPad";
    }
    
    // 请求失败的回调函数
    void(^failedBlock)(NSString *, NSString *) = ^(NSString *responseCode, NSString *responseInfo) {
        //        [MyUtils showAlertWithTitle:responseInfo message:nil]; // 静默，不提示
        if ([responseCode isEqualToString:@"11"]) {
            // 标记一下此时设备未激活，不能打开WebApp
            [AppDelegate delegate].isActive = NO;
        }
        // 用户名密码N天未验证
        else if ([responseCode isEqualToString:@"18"]) {
            [MyUtils showAlertWithTitle:responseInfo message:nil autoHideAfterSeconds:1];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                LoginViewController *loginVC = [[LoginViewController alloc] init];
                __block LoginViewController *loginVCBlock=loginVC;
                loginVC.loginSucceededBlock = ^(){
                    self.loginSucceededBlock();
                    [loginVCBlock dismissViewControllerAnimated:YES completion:nil];
                };
                [self presentViewController:loginVC animated:YES completion:nil];
            });
        }
    };
    
    // 请求更新数据
    id paramDic = @{@"appId":[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"], @"deviceType":deviceType};
    [CIBRequestOperationManager invokeAPI:@"cav"
                                 byMethod:@"POST"
                           withParameters:paramDic
                       onRequestSucceeded:^(NSString *responseCode, NSString *responseInfo) {
                           if ([responseCode isEqualToString:@"0"] || [responseCode isEqualToString:@"I00"]) {
                               CIBLog(@"getUpdateInfo succeeded, info = %@", responseInfo);
                               
                               // 标记一下此时设备已经激活，可以打开WebApp
                               [AppDelegate delegate].isActive = YES;
                               
                               // 重置检查更新时间
                               CoreDataManager *cdManager = [[CoreDataManager alloc] init];
                               [cdManager updateUpdateTimeByName:@"AppUpdate"];
                               
                               if (responseInfo != nil) {
                                   NSDictionary *info = [NSJSONSerialization JSONObjectWithData:[responseInfo dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                                   NSDictionary *result;
                                   if (info) {
                                       result = [info objectForKey:@"result"];
                                   }
                                   
                                   // 获取最新版本信息
                                   NSString *versionCode, *versionName, *versionUrl, *versionInfo;
                                   if (result) {
                                       versionCode = [result objectForKey:@"versionCode"];
                                       versionName = [result objectForKey:@"versionName"];
                                       versionUrl = [result objectForKey:@"url"];
                                       versionInfo = [result objectForKey:@"txt"];
                                       
                                       // 以下避免出现NSNull
                                       versionCode = [NSString stringWithFormat:@"%@", versionCode];
                                       versionName = [NSString stringWithFormat:@"%@", versionName];
                                       versionUrl = [NSString stringWithFormat:@"%@", versionUrl];
                                       versionInfo = [NSString stringWithFormat:@"%@", versionInfo];
                                   }
                                   
                                   // 比对最新版本
                                   NSString *curVersionCode = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];  // build
                                   if (versionCode && [versionCode intValue] > [curVersionCode intValue]) {  // 如果有新版本
                                       // 设备本地版本信息
                                       [AppInfoManager setValue:versionCode forKey:@"versionCode"];
                                       [AppInfoManager setValue:versionName forKey:@"versionName"];
                                       [AppInfoManager setValue:versionUrl forKey:@"versionUrl"];
                                       [AppInfoManager setValue:versionInfo forKey:@"versionInfo"];
                                       
                                       // wifi可用时弹窗提示
                                       if ([MyUtils isWifiAvailable]) {
                                       NSString *alerInfo = [NSString stringWithFormat:@"版本V%@可更新", versionName];
                                       UIAlertView *alert = [[UIAlertView alloc] initWithTitle:alerInfo
                                                                                       message:versionInfo
                                                                                      delegate:self
                                                                             cancelButtonTitle:@"取消"
                                                                             otherButtonTitles:@"确定", nil];
                                       [alert show];
                                       }
                                   }
                               }
                           }
                           
                       } onRequestFailed:failedBlock];
}

// 刷新应用列表
- (void)loadAppListFromServerWithHUD:(BOOL) isHUDShow ifFromSetAuthor:(BOOL)ifFrom{
//    MBProgressHUD *hud = nil;
    ImageAlertView *alertView = [[ImageAlertView alloc] initWithFrame:self.view.frame];
    if (isHUDShow) {
        alertView.isHasBtn = NO;
        [alertView viewShowWithImage:[UIImage imageNamed:@"ic_refresh"] message:@"正在获取应用列表..."];
        [self.view addSubview:alertView];
    }
    
    CoreDataManager *cdManager = [[CoreDataManager alloc] init];
    double lastLoadTime = [cdManager getUpdateTimeByName:@"AppList"];
    double currentTime = [[NSDate date] timeIntervalSince1970];
    NSNumber *loadDataInterval = [MyUtils propertyOfResource:@"Setting" forKey:@"LoadDataInterval"];
    
    //只有不是来自设置条线的地方才时间判断
    if(!ifFrom && lastLoadTime != 0.0 && currentTime - lastLoadTime < [loadDataInterval longValue]) {
        if (isHUDShow) {
            [alertView removeFromSuperview];
        }
        return;
    }
    
    id paramDic = @{@"type": @"ALL",
                    @"userId":[NSString stringWithFormat:@"%@", [AppInfoManager getUserID]]};
    NSString *URI = @"getWebAppList";
    
    // 请求成功的回调函数
    void(^succeededBlock)(NSString *, NSString *) = ^(NSString *responseCode, NSString *responseInfo) {
        if (isHUDShow) {
            [alertView removeFromSuperview];
        }
        
        if ([responseCode isEqualToString:@"0"] || [responseCode isEqualToString:@"I00"]) {
            CIBLog(@"getWebAppList succeeded, info = %@", responseInfo);
            
            // 标记一下此时设备已经激活，可以打开WebApp
            [AppDelegate delegate].isActive = YES;
            
            CoreDataManager *cdManager = [[CoreDataManager alloc] init];
//             NSMutableArray *appList = [[NSMutableArray alloc]initWithArray:[cdManager getAppList]]; // app列表
            NSMutableArray *appList = [[NSMutableArray alloc]initWithArray:[[AppDelegate delegate] getAppProductList]];
            
            if (responseInfo != nil && [responseInfo isKindOfClass:[NSArray class]]) {
                NSMutableArray *apps = [[NSMutableArray alloc] init];
                NSArray *infoArray = (NSArray *)responseInfo;
                NSArray* favorList = [cdManager getAppFavorList];
                if (infoArray != nil && [infoArray count] > 0) {
                    for (NSDictionary *dic in infoArray) {
                        AppProduct *app = [[AppProduct alloc] init];
                        app.appNo = [dic objectForKey:@"appNo"];
                        app.type = [dic objectForKey:@"type"];
                        app.status = [dic objectForKey:@"status"];
                        app.appName = [dic objectForKey:@"appName"];
                        app.appShowName = [dic objectForKey:@"appShowName"];
                        app.appIndexUrl = [dic objectForKey:@"appIndexUrl"];
                        app.appIconUrl = [dic objectForKey:@"appIcon"];
                        app.releaseTime = [dic objectForKey:@"releaseTime"];
                        //
                        app.notiNo = [NSNumber numberWithInt:0];
                        for (AppProduct *item in appList) {
                            if (item != (id)[NSNull null] && [item.appName isEqualToString:app.appName]) {
//                                app.isFavorite = item.isFavorite;
                                app.favoriteTimeStamp = item.favoriteTimeStamp;
                                app.notiNo = item.notiNo;
                                break;
                            }
                        }
                        
                        for(AppFavor* favor in favorList){
                            if([favor.appName isEqualToString:app.appName]){
                                app.isFavorite=YES;
                                app.sortIndex=[favor.sortIndex intValue];
                                break;
                            }
                        }
                        [apps addObject:app];
                    }
                }
                // 存入数据库
                [cdManager insertAppInfos:apps];
                // 更新明文临时变量为空 需要重新从数据库中读取
                [[AppDelegate delegate] setAppProductList:apps];
            }
            
            // 更新获取列表时间
            [cdManager updateUpdateTimeByName:@"AppList"];
            [AppDelegate delegate].hasLoadAppListFromServer = YES;
            [favorVC reloadFavors];
        }
        else { // TODO: 理论上是不用管alert的，而是转向其它操作
            CIBLog(@"getWebAppList failed ,code = %@, info = %@", responseCode, responseInfo);
//            [MyUtils showAlertWithTitle:responseInfo message:nil]; // 静默，不提示
        }
    };
    
    // 请求失败的回调函数
    void(^failedBlock)(NSString *, NSString *) = ^(NSString *responseCode, NSString *responseInfo) {
        if (isHUDShow) {
            [alertView removeFromSuperview];
        }
//        [MyUtils showAlertWithTitle:responseInfo message:nil]; // 静默，不提示
        if ([responseCode isEqualToString:@"11"]) {
            // 标记一下此时设备未激活，不能打开WebApp
            [AppDelegate delegate].isActive = NO;
        }
        // 用户名密码N天未验证
        else if ([responseCode isEqualToString:@"18"]) {
            [MyUtils showAlertWithTitle:responseInfo message:nil autoHideAfterSeconds:1];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                LoginViewController *loginVC = [[LoginViewController alloc] init];
                __block LoginViewController *loginVCBlock=loginVC;
                loginVC.loginSucceededBlock = ^(){
                    self.loginSucceededBlock();
                    [loginVCBlock dismissViewControllerAnimated:YES completion:nil];
                };
                [self presentViewController:loginVC animated:YES completion:nil];
            });
        }
    };
    
    // 发起网络请求
    [CIBRequestOperationManager invokeAPI:URI
                                 byMethod:@"POST"
                           withParameters:paramDic
                       onRequestSucceeded:succeededBlock
                          onRequestFailed:failedBlock];
}


#pragma marks -- UIAlertViewDelegate --
// 根据被点击按钮的索引处理点击事件，此处只处理确定按钮（index = 1）
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        // 打开更新url
        NSString *versionUrl = [AppInfoManager getValueForKey:@"versionUrl" forApp:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"]];
        NSURL *appUrl = [NSURL URLWithString:versionUrl];
        [[UIApplication sharedApplication] openURL:appUrl];
    }
}

- (void)calibrateFrameOfFavorColletionView {
    CGRect favorCltFrame = favorVC.favorCollectionView.frame;
//    NSLog(@"favorCltFrame.height = %f",favorCltFrame.size.height);
    
    CGRect favorConFrame = self.favorContainerView.frame;
//    NSLog(@"favorContainFrame.height = %f",favorConFrame.size.height);
    float correctHeight = favorConFrame.size.height;
    
    favorVC.favorCollectionView.frame = CGRectMake(favorCltFrame.origin.x, favorCltFrame.origin.y, favorCltFrame.size.width, correctHeight);

}

- (void)reloadFavorCollectionView {
    [favorVC reloadFavors];
}

- (void)favorContaitViewLoad
{
    CGFloat heigth = [self heightForFav];
    self.favorHeightConstraint.constant=heigth;
    CGFloat favContaintHeigth = heigth;
    
    self.favorContainerView.frame = CGRectMake(self.favorContainerView.frame.origin.x, self.favorContainerView.frame.origin.y, [UIScreen mainScreen].bounds.size.width, favContaintHeigth);
    
    [self calibrateFrameOfFavorColletionView];
    _currentFrame = self.favorContainerView.frame;

}

// 改
- (void)tagViewLoad
{
    NSString *imageNamedTab = nil;
    CGFloat with = [UIScreen mainScreen].bounds.size.width;
    CGFloat higth = 0;
    //tag框与上面spot中心对齐
    CGFloat tagCenterX = 0;
    UIImageView *tabImagebgView = [[UIImageView alloc] init];
    CGFloat screenHiegth = [UIScreen mainScreen].bounds.size.height;
    if (IS_iPad) {
        if ([UIScreen mainScreen].bounds.size.height > [UIScreen mainScreen].bounds.size.width) {
          imageNamedTab = @"tag-bg_6+.png";
            higth = (214.0 / 3) * (1024.0 / 736) * 1.33333;
            tagCenterX = (228.0/3+8*2+4+2) * 1.84555;
        }else{
            
            imageNamedTab = @"tag-bg_6+.png";
            higth = 214.0/3;
            tagCenterX = 228.0/3+8*2+4+2;
        }
    }
    else if (screenHiegth == 480 || screenHiegth == 568) {
        imageNamedTab = @"tag-bg_5、4s.png";
        higth = 130.0/2;
        tagCenterX = 134.0/2+8*2+4+2;
    }
    else if (screenHiegth == 667){
        imageNamedTab = @"tag-bg_6.png";
        higth = 130.0/2;
        tagCenterX = 132.0/2+8*2+4+2;
    }
    else if (screenHiegth == 736)
    {
        imageNamedTab = @"tag-bg_6+.png";
        higth = 214.0/3;
        tagCenterX = 228.0/3+8*2+4+2;
    }
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.toolTabView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:0 constant:higth]];
    
//    [self.view addConstraint:[NSLayoutConstraint constraintWithItem: self.toolTabView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0]];
    tabImagebgView.frame = CGRectMake(0, 0, with, higth);
    tabImagebgView.image = [UIImage imageNamed:imageNamedTab];
    tabImagebgView.tag = 2006;
    [self.toolTabView addSubview:tabImagebgView];
    UIImageView *tagImageView = [[UIImageView alloc] init];
    if (IS_iPad) {
        tagImageView.frame = CGRectMake(0, 0, 32, 32);
    }else{
        tagImageView.frame = CGRectMake(0, 0, 24, 24);
    }
    tagImageView.image = [UIImage imageNamed:@"btn_tag"];
    tagImageView.center = CGPointMake(tabImagebgView.frame.size.width-tagCenterX, tabImagebgView.frame.size.height/2);
    tagImageView.tag = 2005;
    [self.toolTabView addSubview:tagImageView];
    //打开网页数目
    AppDelegate *appDelegate = [AppDelegate delegate];
    NSInteger cout = [appDelegate.tabList count];
    UILabel *numberLabel = [[UILabel alloc] init];
    if (IS_iPad) {
        numberLabel.frame = CGRectMake(0, 0, 21, 21);
        numberLabel.backgroundColor = [UIColor clearColor];
        numberLabel.font = [UIFont systemFontOfSize:14];
        numberLabel.textColor = [UIColor whiteColor];
        numberLabel.text = [NSString stringWithFormat:@"%ld",(long)cout];
        numberLabel.textAlignment = NSTextAlignmentCenter;
        numberLabel.center = CGPointMake(tabImagebgView.frame.size.width-tagCenterX-5, tabImagebgView.frame.size.height/2+5);
        [self.toolTabView addSubview:numberLabel];
    }else{
        numberLabel.frame = CGRectMake(0, 0, 17, 17);
        numberLabel.backgroundColor = [UIColor clearColor];
        numberLabel.font = [UIFont systemFontOfSize:12];
        numberLabel.textColor = [UIColor whiteColor];
        numberLabel.text = [NSString stringWithFormat:@"%ld",(long)cout];
        numberLabel.textAlignment = NSTextAlignmentCenter;
        numberLabel.center = CGPointMake(tabImagebgView.frame.size.width-tagCenterX-3, tabImagebgView.frame.size.height/2+3);
        [self.toolTabView addSubview:numberLabel];
    }
    
    //添加按钮，点击触发
    UIButton *tagBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    tagBtn.frame = CGRectMake(0, 0, tabImagebgView.frame.size.height, tabImagebgView.frame.size.height);
    tagBtn.center = tagImageView.center;
    tagBtn.backgroundColor = [UIColor clearColor];
    [tagBtn addTarget:self action:@selector(tabBtnPressMain) forControlEvents:UIControlEventTouchUpInside];
    [tagBtn addTarget:self action:@selector(tagChangeIamge) forControlEvents:UIControlEventTouchDown];
    tagBtn.tag=1001;
    [self.toolTabView addSubview:tagBtn];
    
}
// 按下选项卡按钮
- (void)tabBtnPressMain
{
    NSArray *array = [self.toolTabView subviews];
    UIImageView *imageView = nil;
    for (UIView *image in array) {
        if ([image isKindOfClass:[UIImageView class]]) {
            if (image.tag == 2005) {
                imageView = (UIImageView *)image;
            }
        }
    }
    imageView.image = [UIImage imageNamed:@"btn_tag"];
    [[AppDelegate delegate] saveMainScreenShot:self.view];
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Browser" bundle:[NSBundle mainBundle]];
    TabsViewController *tabVC = [story instantiateViewControllerWithIdentifier:@"tabs"];
    
    [self presentViewController:tabVC animated:YES completion:nil];
}
// 改
- (void)navigationBarViewOut
{
    static UIView *navigationBarView;
    if (_navigationView == nil) {
        CGFloat higth = 0;
        CGFloat screenHiegth = [UIScreen mainScreen].bounds.size.height;
        if (IS_iPad) {
            higth = 64.0 / 667.0 * screenHiegth;
        }
        else if (screenHiegth == 480 || screenHiegth == 568 || screenHiegth == 667) {
            higth = 64.0;
        }
        else if (screenHiegth == 736)
        {
            higth = 64.0 / 667.0 * screenHiegth;
        }
        self.favorTopConstraint.constant=higth-20;
        
        self.defalutY=self.favorTopConstraint.constant;
        
            //bgView
        navigationBarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, higth)];
        navigationBarView.backgroundColor = kUIColorLight;
        navigationBarView.tag = 2003;
        [self.view addSubview:navigationBarView];
        
        _navigationView = navigationBarView;
        
        //设置
        UIButton *settingButton = [UIButton buttonWithType:UIButtonTypeCustom];
        settingButton.frame = CGRectMake(12, 20, 24, 24);
        settingButton.clipsToBounds = YES;
        settingButton.center = CGPointMake(settingButton.center.x, (higth - 20) / 2.0 + 18);
        settingButton.frame = CGRectMake(settingButton.frame.origin.x, 28.0, settingButton.frame.size.width, settingButton.frame.size.height);
   
        [settingButton setBackgroundImage:[UIImage imageNamed:@"btn_ndividualism white"] forState:UIControlStateNormal];
        [settingButton setBackgroundImage:[UIImage imageNamed:@"btn_ndividualism_p"] forState:UIControlStateHighlighted];
        [settingButton addTarget:self action:@selector(settingBtnPress) forControlEvents:UIControlEventTouchUpInside];
        [navigationBarView addSubview:settingButton];
        
        //搜索
        UIButton *searchButton = [UIButton buttonWithType:UIButtonTypeCustom];
        searchButton.frame = CGRectMake(self.view.frame.size.width-24-12, 20, 24, 24);
        searchButton.center = CGPointMake(searchButton.center.x, (higth - 20) / 2.0 + 18);
        searchButton.frame = CGRectMake(searchButton.frame.origin.x, 28.0, searchButton.frame.size.width, searchButton.frame.size.height);
        [searchButton setBackgroundImage:[UIImage imageNamed:@"btn_search white"] forState:UIControlStateNormal];
        [searchButton setBackgroundImage:[UIImage imageNamed:@"btn_search_p"] forState:UIControlStateHighlighted];
        [searchButton addTarget:self action:@selector(seachBtnPress) forControlEvents:UIControlEventTouchUpInside];
        searchButton.clipsToBounds = YES;
        [navigationBarView addSubview:searchButton];
        
        //标签
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, navigationBarView.frame.size.width, 24)];
        label.center = CGPointMake(navigationBarView.frame.size.width / 2, searchButton.center.y);
        label.text = @"兴业银行移动应用门户";
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:18.0];
        label.textColor = [UIColor whiteColor];
        [navigationBarView addSubview:label];
    }
}
-(void) initToolEdit{
    CGFloat higth = 0;
    CGFloat top = 0;
    CGFloat bottom = 0;
    CGFloat screenHiegth = [UIScreen mainScreen].bounds.size.height;
    if (IS_iPad) {
        higth = 90.0 / 667.0 * screenHiegth;
        top = 24.0 / 667.0 * screenHiegth;
        bottom = 12.0 / 667.0 * screenHiegth;
    }
    else if (screenHiegth == 480 || screenHiegth == 568 || screenHiegth == 667) {
        higth = 90.0;
        top = 24.0;
        bottom = 12.0;
    }
    else if (screenHiegth == 736)
    {
        higth = 90.0 / 667.0 * screenHiegth;
        top = 24.0 / 667.0 * screenHiegth;
        bottom = 12.0 / 667.0 * screenHiegth;
    }
    static UIView *toolEditView = nil;
    if (_toolEditView == nil) {
        //bgView
        toolEditView = [[UIView alloc] initWithFrame:CGRectMake(0, screenHiegth, self.view.frame.size.width, higth)];
        toolEditView.backgroundColor = kUIColorLight;
        [self.view addSubview:toolEditView];
        _toolEditView = toolEditView;
        
        //删除
        UIControl *deletView = [[UIControl alloc] initWithFrame:CGRectMake(20, top, 60, 52)];
        deletView.center = CGPointMake(toolEditView.center.x * 2 / 3 - 35, deletView.center.y);
        deletView.backgroundColor = [UIColor clearColor];
        [deletView addTarget:self action:@selector(appDeletPress:) forControlEvents:UIControlEventTouchUpInside];
        [deletView addTarget:self action:@selector(changeIamge:) forControlEvents:UIControlEventTouchDown];
        deletView.tag = 2000;
        [toolEditView addSubview:deletView];
        
        UIImageView *deletImage = [[UIImageView alloc] initWithFrame:CGRectMake(deletView.frame.size.width/2 - 24.0/2, 0, 24, 24)];
        deletImage.image = [UIImage imageNamed:@"btn_del"];
        deletImage.clipsToBounds = YES;
        [deletView addSubview:deletImage];
        
        UILabel *deletLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, deletImage.frame.origin.y + 24 + bottom, deletView.frame.size.width, 24)];
        deletLabel.font = [UIFont systemFontOfSize:14];
        deletLabel.textColor = [UIColor whiteColor];
        deletLabel.textAlignment = NSTextAlignmentCenter;
        deletLabel.text = @"删除应用";
        [deletView addSubview:deletLabel];
        
        //退出编辑
        UIControl *editExit = [[UIControl alloc] initWithFrame:CGRectMake(20, top, 60, 52)];
        editExit.center = CGPointMake(toolEditView.center.x * 4 / 3 + 35, deletView.center.y);
        editExit.backgroundColor = [UIColor clearColor];
        [editExit addTarget:self action:@selector(editExitPress:) forControlEvents:UIControlEventTouchUpInside];
        [editExit addTarget:self action:@selector(changeIamge:) forControlEvents:UIControlEventTouchDown];
        editExit.tag = 2001;
        [toolEditView addSubview:editExit];
        
        UIImageView *editExitImage = [[UIImageView alloc] initWithFrame:CGRectMake(editExit.frame.size.width/2 - 24.0/2, 0, 24, 24)];
        editExitImage.image = [UIImage imageNamed:@"btn_out.png"];
        editExitImage.clipsToBounds = YES;
        [editExit addSubview:editExitImage];
        
        UILabel *editExitLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, deletImage.frame.origin.y + 24 + bottom, editExit.frame.size.width, 24)];
        editExitLabel.font = [UIFont systemFontOfSize:14];
        editExitLabel.textColor = [UIColor whiteColor];
        editExitLabel.textAlignment = NSTextAlignmentCenter;
        editExitLabel.text = @"退出编辑";
        [editExit addSubview:editExitLabel];
    }
}

// 改
- (void)toolEditeViewOut:(BOOL)isOut
{
    CGFloat higth = 0;
    CGFloat top = 0;
    CGFloat bottom = 0;
    CGFloat screenHiegth = [UIScreen mainScreen].bounds.size.height;
    if (IS_iPad) {
        higth = 90.0 / 667.0 * screenHiegth;
        top = 24.0 / 667.0 * screenHiegth;
        bottom = 12.0 / 667.0 * screenHiegth;
    }
   else if (screenHiegth == 480 || screenHiegth == 568 || screenHiegth == 667) {
        higth = 90.0;
        top = 24.0;
        bottom = 12.0;
    }
    else if (screenHiegth == 736)
    {
        higth = 90.0 / 667.0 * screenHiegth;
        top = 24.0 / 667.0 * screenHiegth;
        bottom = 12.0 / 667.0 * screenHiegth;
    }
    
    if (isOut) {
        [UIView animateWithDuration:0.05 animations:^{
            _toolEditView.frame = CGRectMake(0, screenHiegth- higth, self.view.frame.size.width, higth);
        } completion: nil];
    }
    else
    {
        [UIView animateWithDuration:0.05 animations:^{
            _toolEditView.frame = CGRectMake(0, screenHiegth, self.view.frame.size.width, higth);
        }];
    }
    
}
- (void)settingBtnPress {
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Setting" bundle:[NSBundle mainBundle]];
    CommonNavViewController *common = [story instantiateViewControllerWithIdentifier:@"setting"];
    [common setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
    [self presentViewController:common animated:YES completion:nil];
}

- (void)seachBtnPress {
    [self.view bringSubviewToFront:self.searchContainerView];
    self.searchContainerView.hidden = NO;
}

- (IBAction)appDeletPress:(id)sender {
    UIControl *control = (UIControl *)sender;
    NSArray *array = [control subviews];
    UIImageView *imageView = nil;
    for (UIView *image in array) {
        if ([image isKindOfClass:[UIImageView class]]) {
            imageView = (UIImageView *)image;
            imageView.image = [UIImage imageNamed:@"btn_del"];
        }
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"deletApp" object:nil];
}

// 改
- (IBAction)editExitPress:(id)sender {
    UIControl *control = (UIControl *)sender;
    NSArray *array = [control subviews];
    UIImageView *imageView = nil;
    for (UIView *image in array) {
        if ([image isKindOfClass:[UIImageView class]]) {
            imageView = (UIImageView *)image;
            imageView.image = [UIImage imageNamed:@"btn_out"];
        }
    }
    [self toolEditeViewOut:NO];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"editExit" object:nil];
    if(self.favorContainerView.frame.size.height+self.navigateHeight <=[[UIScreen mainScreen] bounds].size.height){
        return;
    }
    float mainHeight =[[UIScreen mainScreen] bounds].size.height-20-self.favorContainerView.frame.size.height;
    if(self.favorTopConstraint.constant< mainHeight){
        self.favorTopConstraint.constant=mainHeight;
    }
}

// 改
- (void)hadLongPress
{
     [self toolEditeViewOut:YES];
}

// 改
- (CGFloat)heightForFav
{
    //根据app书签列表计算fav最大高度
    NSInteger cout = [favorVC.appList count];
    CGFloat itemWidth = self.view.frame.size.width / 3;
    // height为header的高度
    CGFloat higth = 0.0;
    CGFloat screenHiegth = [UIScreen mainScreen].bounds.size.height;
    float tempH = [[AppDelegate delegate] getBannerHeight:self.view.frame.size.width];
    if (IS_iPad) {
        higth=1024.0 * (778.0/3 + 380.0/3 - 16 + 7) / 736 - 50;
    }
    else  if (screenHiegth == 480) {
        higth = tempH + 230.0/2 - 10 + 7;
    }
    else if (screenHiegth == 568) {
        higth = tempH + 230.0/2 - 10 + 7;
    }
    else if (screenHiegth == 667){
        higth = tempH + 230.0/2 - 10 + 7;
    }
    else if (screenHiegth == 736)
    {
        higth = tempH + 380.0/3 - 10 + 7;
    }
    CGFloat favorCollectionHeight = (cout + 2) / 3 * itemWidth;
    return favorCollectionHeight + higth;
}
- (void)addAppDone
{
    [favorVC reloadFavors];
    CGFloat favorVCHiegth = [self heightForFav];
    CGRect f = _currentFrame;
    f.size.height=favorVCHiegth;
    self.favorHeightConstraint.constant=favorVCHiegth;
    float top = self.favorTopConstraint.constant;
//            self.favorContainerView.frame = f;
    [self calibrateFrameOfFavorColletionView];
    _currentFrame = f;
}

- (void)getOffsetY:(NSNotification *)notification
{
    float offsetY = [notification.object floatValue];
    CGFloat heigth = _currentFrame.size.height;
    CGRect f  = CGRectMake(_currentFrame.origin.x, _currentFrame.origin.y- offsetY, _currentFrame.size.width, heigth + offsetY );
    self.favorContainerView.frame = f;
    [self calibrateFrameOfFavorColletionView];
    _currentFrame = f;
}
- (void)didDeletApp
{
    CGFloat favorVCHiegth = [self heightForFav];
    CGRect f = _currentFrame;
    f.size.height = favorVCHiegth;
    self.favorContainerView.frame = f;
    [self calibrateFrameOfFavorColletionView];
    _currentFrame = f;
}

- (void)changeIamge:(UIControl *)control
{
    NSArray *array = [control subviews];
    UIImageView *imageView = nil;
    for (UIView *image in array) {
        if ([image isKindOfClass:[UIImageView class]]) {
            imageView = (UIImageView *)image;
        }
    }

    switch (control.tag) {
        case 2000:
            imageView.image = [UIImage imageNamed:@"btn_del_p"];
            break;
        case 2001:
            imageView.image = [UIImage imageNamed:@"btn_out_p"];
            break;
        default:
            break;
    }
}
- (void)tagChangeIamge
{
    NSArray *array = [self.toolTabView subviews];
    UIImageView *imageView = nil;
    for (UIView *image in array) {
        if ([image isKindOfClass:[UIImageView class]]) {
            if (image.tag == 2005) {
                imageView = (UIImageView *)image;
            }
        }
    }
    imageView.image = [UIImage imageNamed:@"btn_tag_p"];
}

// 收到搜索页面点击“取消”按钮发送的通知后进行的处理
- (void)pressCancelBtn{
    float height = [UIScreen mainScreen].bounds.size.height;
    float width = [UIScreen mainScreen].bounds.size.width;
    BOOL  m_bScreen;
    if (height < width) {
        m_bScreen = YES;
    }else{
        m_bScreen = NO;
    }
    
    // 强制将main页面竖直显示
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        
        NSNumber *num = [[NSNumber alloc] initWithInt:(m_bScreen?UIInterfaceOrientationPortrait:UIInterfaceOrientationLandscapeRight)];
        [[UIDevice currentDevice] performSelector:@selector(setOrientation:) withObject:(id)num];
        [UIViewController attemptRotationToDeviceOrientation];//这行代码是关键
    }
}
-(void) updateWebappFromServer{
    [self loadAppListFromServerWithHUD:NO  ifFromSetAuthor:YES];
}
@end
