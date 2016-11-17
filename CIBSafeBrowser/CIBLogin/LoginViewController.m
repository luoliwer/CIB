//
//  LoginViewController.m
//  CIBSafeBrowser
//
//  Created by CIB-Mac mini on on 14-12-31.
//  Copyright (c) 2014年 cib. All rights reserved.
//

#import "AppDelegate.h"
#import "JFRWebSocket.h"

#import "LoginViewController.h"
#import "MainViewController.h"
#import "ImageAlertView.h"

#import "MyUtils.h"
#import "CoreDataManager.h"
#import "Config.h"
#import "ChatDBManager.h"

#import "MBProgressHUD.h"
#import <CIBBaseSDK/CIBBaseSDK.h>

#define IS_iPad  [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad
#define kAlphaNum @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
#define KEYBOARD_NIB_PATH @"Resoure.bundle/resources/HYKeyboard"
@interface LoginViewController () <UITextFieldDelegate,HYKeyboardDelegate>
@property (strong, nonatomic) IBOutlet UIImageView *loginGbImage;
@property (strong, nonatomic) IBOutlet UILabel *chineseLable;
@property (strong, nonatomic) IBOutlet UILabel *englishLabel;
@property (strong, nonatomic) IBOutlet UIImageView *logoImage;
@property (strong, nonatomic) UIButton *loginButton;

@end

@implementation LoginViewController

- (id)init {
    if ((self = [super init])) {
        self.dismissWhenSucceeded = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    usesafeKeyboard = [[MyUtils propertyOfResource:@"Setting" forKey:@"UseSafeKeyboard"] boolValue];
    [self loadBackGroundImage];
    
    // 输入区圆角边框
    self.userNameView.layer.cornerRadius = 24.f;
    self.userNameView.clipsToBounds = YES;
    
    //placeholder字体颜色
    [self.usernameTextField setValue: kUIColorLight forKeyPath:@"_placeholderLabel.textColor"];
    
    // 如果是需要验证用户名密码的情景，在用户名输入框直接填充之前的用户名，且不可修改
    if ([DeviceKeyManager isDeviceKeyExisted]) {
        self.usernameTextField.text = [AppInfoManager getUserName];
//        self.usernameTextField.userInteractionEnabled = NO;
                self.usernameTextField.userInteractionEnabled = YES;
    }
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterBackground1) name:UIApplicationDidEnterBackgroundNotification object:nil];
    //键盘出现与隐藏
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHidden:) name:UIKeyboardWillHideNotification object:nil];
    
    
   
}
- (void)enterBackground1
{
  self.usernameTextField.text=@"";
}

// 键盘监听事件
- (void)keyboardWillShow:(NSNotification *)noti
{
    NSDictionary *userInfo = [noti userInfo];
    NSValue *avalue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect rect = [avalue CGRectValue];
    CGFloat higth = rect.size.height;
    CGFloat y =self.view.frame.size.height- (self.loginButton.frame.origin.y + 44 + higth );
    if(y<0){
        self.view.frame = CGRectMake(0, y-10, self.view.frame.size.width, self.view.frame.size.height);
    }
}

- (void)keyboardWillHidden:(NSNotification *)noti
{
    self.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
}
// 点击屏幕任何地方，键盘消失
- (void) touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.usernameTextField resignFirstResponder];
}


// Dispose of any resources that can be recreated.
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
-(void) viewWillDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
}
// 响应输入框的回车事件
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.usernameTextField) {
        [self.usernameTextField resignFirstResponder];
         [self performSelector:@selector(onLoginButtonPress:) withObject:self.loginButton];
    }
    return YES;
}
#pragma mark  UITextFieldDelegate
//判断是否是数字，不是的话就输入失败
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:kAlphaNum] invertedSet];
    
    NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""]; //按cs分离出数组,数组按@""分离出字符串
    
    BOOL canChange = [string isEqualToString:filtered];
    return canChange;
}
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    
    if (usesafeKeyboard) {
        [textField resignFirstResponder];
        [self showSecureKeyboardAction];
    }
    
}
#pragma mark--
/**初始化安全键盘*/
- (void)showSecureKeyboardAction{
    
    if (keyboard) {
        [keyboard.view removeFromSuperview];
        keyboard.view =nil;
        keyboard=nil;
    }
    
    keyboard = [[HYKeyboard alloc] initWithNibName:KEYBOARD_NIB_PATH bundle:nil];
    /**弹出安全键盘的宿主控制器，不能传nil*/
    keyboard.hostViewController = self;
    /**是否设置按钮无按压和动画效果*/
    keyboard.btnPressAnimation=YES;
    /**是否设置按钮随机变化*/
    keyboard.btnrRandomChange=YES;
    /**是否显示密码明文动画*/
    keyboard.shouldTextAnimation=YES;
    /**安全键盘事件回调，必须实现HYKeyboardDelegate内的其中一个*/
    keyboard.keyboardDelegate=self;
    /**弹出安全键盘的宿主输入框，可以传nil*/
    keyboard.hostTextField = self.usernameTextField;
    /**是否输入内容加密*/
    keyboard.secure = NO;
    //    keyboard.arrayText = [NSMutableArray arrayWithArray:contents];//把已输入的内容以array传入;
    /**输入框已有的内容*/
    keyboard.contentText=inputText;
    keyboard.synthesize = YES;//hostTextField输入框同步更新，用*填充
    /**是否清空输入框内容*/
    keyboard.shouldClear = NO;
    /**背景提示*/
    keyboard.stringPlaceholder = self.usernameTextField.placeholder;
    keyboard.intMaxLength = 12;//最大输入长度
    keyboard.keyboardType = HYKeyboardTypeNone;//输入框类型
    /**更新安全键盘输入类型*/
    [keyboard shouldRefresh:HYKeyboardTypeNumber];
    
    //--------添加安全键盘到ViewController---------
    
    [self.view addSubview:keyboard.view];
    [self.view bringSubviewToFront:keyboard.view];
    //安全键盘显示动画
    CGRect rect=keyboard.view.frame;
    rect.size.width=self.view.frame.size.width;
    rect.origin.y=self.view.frame.size.height+10;
    keyboard.view.frame=rect;
    //显示输入框动画
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:0.2f];
    rect.origin.y=self.view.frame.size.height-keyboard.view.frame.size.height;
    keyboard.view.frame=rect;
    [UIView commitAnimations];
}

#pragma mark--关闭键盘回调
//输入的内容以NSArray返回
//-(void)inputOverWithTextField:(UITextField *)textField inputArrayText:(NSArray *)arrayText
//{
//    contents=arrayText;//接收输入内容
//
//    [self hiddenKeyboardView];
//}
/**安全键盘点击确定回调方法,输入的内容以NSString返回
 @textField 传入的宿主输入框对象
 @text安全键盘输入的内容，NSString
 */
-(void)inputOverWithTextField:(UITextField *)textField inputText:(NSString *)text
{
    inputText=text;
    [self hiddenKeyboardView];
}

-(void)inputOverWithChange:(UITextField *)textField changeText:(NSString *)text
{
    NSLog(@"变化内容:%@",text);
}

-(void)hiddenKeyboardView
{
    //隐藏输入框动画
    [ UIView animateWithDuration:0.3 animations:^
     {
         CGRect rect=keyboard.view.frame;
         rect.origin.y=self.view.frame.size.height+10;
         keyboard.view.frame=rect;
         
     }completion:^(BOOL finished){
         
         [keyboard.view removeFromSuperview];
         keyboard.view =nil;
         keyboard=nil;
     }];
}


#pragma mark - Managing the view
// 是否支持转屏
- (BOOL)shouldAutorotate {
    return YES;
}
// 支持的屏幕方向
- (NSUInteger)supportedInterfaceOrientations {
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {  // ipad
        return UIInterfaceOrientationMaskAll;
    }
    else {  // iPhone&iPod
        return UIInterfaceOrientationMaskPortrait;
    }
}

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message {
    if ([MyUtils isSystemVersionBelowEight]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles: nil];
        [alert show];
    }
    else {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        
        
        UIAlertAction *okAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"确定", @"OK action")
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action)
                                   {
                                       
                                   }];
        
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }
    
}

- (void)loadBackGroundImage
{
    UIButton *loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    loginButton.backgroundColor = [UIColor whiteColor];
    loginButton.layer.cornerRadius = 22;
    loginButton.clipsToBounds = YES;

    //正常状态
    [loginButton setTitle:@"验证登陆" forState:UIControlStateNormal];
    loginButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [loginButton setTitleColor:[UIColor colorWithRed:18/255.0 green:119.0/255.0 blue:211.0/255.0 alpha:1] forState:UIControlStateNormal];
    //点击高亮状态
    [loginButton setTitleColor:[UIColor colorWithRed:0/255.0 green:87.0/255.0 blue:166.0/255.0 alpha:1] forState:UIControlStateHighlighted];
    
    [loginButton addTarget:self action:@selector(loginBtnChangeColor:) forControlEvents:UIControlEventTouchDown];
    [loginButton addTarget:self action:@selector(onLoginButtonPress:) forControlEvents:UIControlEventTouchUpInside];
    loginButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:loginButton];
    self.loginButton = loginButton;
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:loginButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:0 constant:44.0f]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:loginButton attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:loginButton attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1 constant:27]];
    
    self.chineseLable.translatesAutoresizingMaskIntoConstraints = NO;
    self.englishLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.userNameView.translatesAutoresizingMaskIntoConstraints = NO;
    self.logoImage.translatesAutoresizingMaskIntoConstraints = NO;
    
    CGFloat heigth = [UIScreen mainScreen].bounds.size.height;
    // iPad
    if (IS_iPad){
        self.loginGbImage.image = [UIImage imageNamed:@"login_xxhdpi.png"];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.chineseLable attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1 constant:76]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.englishLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.chineseLable attribute:NSLayoutAttributeBottom multiplier:1 constant:10]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.userNameView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.englishLabel attribute:NSLayoutAttributeBottom multiplier:1 constant:50]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.userNameView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1 constant:25]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:loginButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.userNameView attribute:NSLayoutAttributeBottom multiplier:1 constant:34]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.logoImage attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1 constant:-14]];
    }
    //4
    else  if (heigth == 480) {
        self.loginGbImage.image= [UIImage imageNamed:@"login_4.png"];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.chineseLable attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1 constant:76]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.englishLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.chineseLable attribute:NSLayoutAttributeBottom multiplier:1 constant:10]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.userNameView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.englishLabel attribute:NSLayoutAttributeBottom multiplier:1 constant:50]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.userNameView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1 constant:25]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:loginButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.userNameView attribute:NSLayoutAttributeBottom multiplier:1 constant:34]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.logoImage attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1 constant:-14]];
    }
    //5
    else if (heigth == 568)
    {
        self.loginGbImage.image = [UIImage imageNamed:@"login_5.png"];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.chineseLable attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1 constant:102]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.englishLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.chineseLable attribute:NSLayoutAttributeBottom multiplier:1 constant:10]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.userNameView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.englishLabel attribute:NSLayoutAttributeBottom multiplier:1 constant:70]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.userNameView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1 constant:25]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:loginButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.userNameView attribute:NSLayoutAttributeBottom multiplier:1 constant:34]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.logoImage attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1 constant:-24]];
    }
    //6
    else if (heigth == 667)
    {
        self.loginGbImage.image = [UIImage imageNamed:@"login_6.png"];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.chineseLable attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1 constant:152]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.englishLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.chineseLable attribute:NSLayoutAttributeBottom multiplier:1 constant:10]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.userNameView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.englishLabel attribute:NSLayoutAttributeBottom multiplier:1 constant:70]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.userNameView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1 constant:25]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:loginButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.userNameView attribute:NSLayoutAttributeBottom multiplier:1 constant:34]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.logoImage attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1 constant:-28]];
        
    }
    //6+
    else if (heigth == 736)
    {
        self.loginGbImage.image = [UIImage imageNamed:@"login_6+.png"];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.chineseLable attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1 constant:236]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.englishLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.chineseLable attribute:NSLayoutAttributeBottom multiplier:1 constant:15]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.userNameView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.englishLabel attribute:NSLayoutAttributeBottom multiplier:1 constant:127]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.userNameView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1 constant:37]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:loginButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.userNameView attribute:NSLayoutAttributeBottom multiplier:1 constant:34]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.logoImage attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1 constant:-38]];
    }
    
}

- (void)loginBtnChangeColor:(UIButton *)button
{
    [button setBackgroundColor:[UIColor colorWithRed:230.0/255.0 green:230.0/255.0 blue:230.0/255.0 alpha:1]];
}
// 响应登录按钮
- (void)onLoginButtonPress:(id)sender {
    //恢复button颜色
    [sender setBackgroundColor:[UIColor whiteColor]];
    
    [self.usernameTextField resignFirstResponder];
//    [self.passwordTextField resignFirstResponder];
    
    // 检查网络
    if (![MyUtils isNetworkAvailableInView:[self view]]) {
        return;
    }
    
    // 检查输入
    NSString *usr = self.usernameTextField.text;
//    NSString *pwd = self.passwordTextField.text;
//    if([usr isEqualToString:@""] || [pwd isEqualToString:@""] || usr == nil || pwd == nil) {
//        [self showAlertWithTitle:@"用户名和密码不能为空" message:nil];
//        return;
//    }
    if([usr isEqualToString:@""] ||  usr == nil ) {
        [self showAlertWithTitle:@"工号不能为空" message:nil];
        return;
    }
    
    // 弹出菊花
    ImageAlertView *alertView = [[ImageAlertView alloc] initWithFrame:self.view.frame];
    alertView.isHasBtn = NO;
    [alertView viewShowWithImage:[UIImage imageNamed:@"ic_refresh"] message:@"登录中..."];
    [self.view addSubview:alertView];
//    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
//    [self.view addSubview:hud];
//    hud.labelText = @"登录中...";
//    [hud show:YES];
    //记录调用login前，密钥是否存在
    BOOL isExisted = [DeviceKeyManager isDeviceKeyExisted];
    [DeviceKeyManager loginWithUsername:usr
                       onLoginSucceeded:^(NSString *responseCode, NSString *responseInfo) {
                           [alertView removeFromSuperview];
//                           [hud removeFromSuperview];  // 隐藏菊花
                           
                           if ([responseCode isEqualToString:@"0"]) {  // 密钥申请成功，执行回调
                               // 比对保存的上次登录id，不相同的话清空数据库数据，理论上一定相同
                               CoreDataManager *cdManager = [[CoreDataManager alloc] init];
                               NSString *lastUserId = [cdManager lastUserId];
                               
                               if ([lastUserId isEqualToString:@""]) { // 初次登录
                                   lastUserId = [AppInfoManager getUserID];
                                   [cdManager setLastUserId:lastUserId];
                               }
                               
                               if (![[AppInfoManager getUserID] isEqualToString:lastUserId]) {
                                   [self cleanOldUserInfo];
                                   
                               }
                               
                               
                               if (_dismissWhenSucceeded) {
                                   [self dismissViewControllerAnimated:YES completion:^{
                                       if (self.loginSucceededBlock) {
                                           self.loginSucceededBlock();
                                       }
                                   }];
                               }
                               else if (self.loginSucceededBlock) {
                                   self.loginSucceededBlock();
                               }
                               // 向应用服务器注册推送服务（仅在申请密钥成功，且login前本地无密钥的情况下）
                               if (!isExisted && [DeviceKeyManager isDeviceKeyExisted]) {
                                   NSString *deviceToken = [[NSUserDefaults standardUserDefaults] objectForKey:kKeyOfDeviceToken];
                                   if (deviceToken) {
                                       [[AppDelegate delegate] registerPushServiceToAppServerWithDeviceToken:deviceToken];
                                   }
                               }
                               
                               //第一次登录app 需要设置websocket
                               //断开之前的websocket连接
                               __block __weak JFRWebSocket *socket = [AppDelegate delegate].socket;
                               [socket disconnect];
                               
                               [[AppDelegate delegate] initWebsocket];
                           }
                           else {  // 密钥申请不成功，弹出错误提示框
                               [self showAlertWithTitle:responseInfo message:nil];
                               if (self.loginFailedBlock) {
                                   self.loginFailedBlock();
                               }
                           }
                           
                       }
                          onLoginFailed:^(NSString *responseCode, NSString *responseInfo) {
                              [alertView removeFromSuperview];
                              // 验证用户名密码的情况，但此时服务端删除了对应证书
                              if ([DeviceKeyManager isDeviceKeyExisted] && [responseCode isEqualToString:@"1"]) {
                                  [DeviceKeyManager deleteDeviceKey];
                                  [self onLoginButtonPress:sender];
                              }
                              else {
                                  
                                  ImageAlertView *imageAlert = [[ImageAlertView alloc] initWithFrame:self.view.frame];
                                  imageAlert.failure = YES;
                                  [imageAlert viewShowWithImage:[UIImage imageNamed:@"ic_wrong"] message:responseInfo];
                                  [self performSelector:@selector(deleteFromSuperView:) withObject:imageAlert afterDelay:2.0];
                                  [self.view addSubview:imageAlert];
                                  if (self.loginFailedBlock) {
                                      self.loginFailedBlock();
                                  }
                              }
                          }
     ];
}
- (void)deleteFromSuperView:(ImageAlertView *)alert{
    [alert removeFromSuperview];
}

- (void)cleanOldUserInfo {
    
    CoreDataManager *cdManager = [[CoreDataManager alloc] init];
    [cdManager resetData];
    [cdManager setLastUserId:[AppInfoManager getUserID]];
    [AppDelegate delegate].hasLoadAppListFromServer = NO;
    [AppDelegate delegate].hasCheckedUpdate = NO;
    // 清除WebApp缓存
    NSString *cacheDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSArray *cacheFilePaths = [[NSFileManager defaultManager] subpathsAtPath:cacheDir];
    for (NSString *cachePath in cacheFilePaths) {
        NSString *fullPath = [NSString stringWithFormat:@"%@/%@", cacheDir, cachePath];
        [Function deleteFileAtPath:fullPath];
    }
    // 重新读取资源文件
    [[AppDelegate delegate] cacheLocalResourceFiles];
    // 重置资源文件的更新时间
    [cdManager resetUpdateTimeByName:@"ResourceFileUpdate"];
    
    // 清除头像缓存
    // 获取应用程序沙盒的Documents目录
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDir = [paths objectAtIndex:0];
    // 拼装头像文件存储路径
    NSString *fileName = @"userIcon.jpeg";
    NSString *iconDir = [documentDir stringByAppendingPathComponent:fileName];
    if ([Function isFileExistedAtPath:iconDir]) {
        [Function deleteFileAtPath:iconDir];
    }
    // 清除设备推送注册的标示
    NSString *deviceToken = [[NSUserDefaults standardUserDefaults] objectForKey:kKeyOfDeviceToken];
    if (deviceToken) {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:deviceToken];
    }
    
    //清楚本地数据库的信息
    [[ChatDBManager sharedDatabaseManager] deleteAllContactor];
    [[ChatDBManager sharedDatabaseManager] deleteAllMessage];
    [[ChatDBManager sharedDatabaseManager] deleteAllNewestMessage];
    
    
    
    
    // 清理小红点
    [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:kKeyOfUnreadMsgNumber];
    // 发送通知更新首页的小红点显示
    [[NSNotificationCenter defaultCenter] postNotificationName:kUnreadMsgNumberUpdatedNotification object:nil];
}
@end
