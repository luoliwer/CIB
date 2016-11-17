//
//  ActivationViewController.m
//  CIBSafeBrowser
//
//  Created by cib on 15/1/11.
//  Copyright (c) 2015年 cib. All rights reserved.
//

#import "ActivationViewController.h"

#import "AppDelegate.h"
#import "Config.h"
#import "MyUtils.h"
#import "SettingViewController.h"
#import "CommonNavViewController.h"
#import <CIBBaseSDK/CIBBaseSDK.h>
#import "MBProgressHUD.h"
#import "ImageAlertView.h"
#import "LoginViewController.h"
#import "MainViewController.h"
#import "AppDelegate.h"
@interface ActivationViewController ()
{
    NSTimer *timer;
    UIColor *enableTextColor, *disableTextColor;
    int count;
}

@property (strong, nonatomic) IBOutlet UITextField *pinTextField;  // 动态密码输入框
@property (strong, nonatomic) IBOutlet UIButton *getPinButton;  // 获取动态密码按钮
@property (strong, nonatomic) IBOutlet UIView *editField;  // 输入区域（输入框和获取按钮）
@property (strong, nonatomic) IBOutlet UIView *infoView;
@property (strong, nonatomic) IBOutlet UILabel *infoLable;

/// 进入后台的时间记录
@property (nonatomic, strong) NSDate    *enterBackgroundDate;

- (IBAction)getPinBtnPress:(id)sender;
- (IBAction)goBackBtnPress:(id)sender;

@end

@implementation ActivationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.infoView.hidden = YES;
    
    enableTextColor = [UIColor colorWithRed:66.0/255.0 green:187.0/255.0 blue:252.0/255.0 alpha:1.0];
    disableTextColor = [UIColor colorWithRed:195.0/255.0 green:203.0/255.0 blue:204.0/255.0 alpha:1.0];
    
    //文本框placeholer文字设置
    [self.pinTextField setValue:[UIFont systemFontOfSize:15] forKeyPath:@"_placeholderLabel.font"];
    [self.pinTextField setValue:[UIColor colorWithRed:195.0/255.0 green:203.0/255.0 blue:204.0/255.0 alpha:1] forKeyPath:@"_placeholderLabel.textColor"];
    
    //边框
    [self.editField.layer setBorderWidth:1.f];
    [self.editField.layer setBorderColor:[[UIColor colorWithRed:230.0/255.0 green:230.0/255.0 blue:230.0/255.0 alpha:1.0] CGColor]];
    [self loadSendButton];
    
   //记录后台时间 （解决 进入后台也要倒计时）
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)enterBackground
{
    self.pinTextField.text=@"";
    self.enterBackgroundDate = [NSDate date];
}

- (void)enterForeground
{
    NSDate *nowDate = [NSDate date];
    NSTimeInterval date = [nowDate timeIntervalSinceDate:self.enterBackgroundDate];
    count =count-date;
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [timer invalidate];  // 关闭定时器
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
}
// 获取验证码
- (IBAction)getPinBtnPress:(id)sender {
    // 检查网络
    if (![MyUtils isNetworkAvailableInView:self.view]) {
        return;
    }
    
    // 禁用获取按钮
    [self.getPinButton setEnabled:NO];
    [self.getPinButton setTitle:@"已获取(60s)" forState:UIControlStateDisabled];
    [self.getPinButton setTitleColor:disableTextColor forState:UIControlStateDisabled];

    // 启动计时器，每秒执行一次
    count = 60;
    timer = [NSTimer scheduledTimerWithTimeInterval:1.f target:self selector:@selector(scrollTimer) userInfo:nil repeats:YES];
    
    // 发送获取动态密码的请求
//    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithCapacity:1];
//    NSString *sParamArr =[NSString stringWithFormat:@"[\"%@\",\"%@\",\"getDynPwd\"]", [AppInfoManager getUserID], [AppInfoManager getDeviceID]];
//    [params setObject:sParamArr forKey:@"parameter"];
//    [CIBRequestOperationManager invokeAPI:@"login/dynamicPwd.xxx?"/*login/dynamicPwd.jsp? 测试*/
//                                 byMethod:@"POST"
//                           withParameters:params
//                       onRequestSucceeded:^(NSString *responseCode, NSString *responseInfo) {
//                           if ([responseCode isEqualToString:@"26"]) {
//                               [MyUtils showAlertWithTitle:@"已经发送短信密码" message:nil];
//                           }
//                           else {
//                               [MyUtils showAlertWithTitle:responseInfo message:nil];
//                           }
//                       }
//                          onRequestFailed:^(NSString *responseCode, NSString *responseInfo) {
//                              [MyUtils showAlertWithTitle:responseInfo message:nil];
//                          }];
    
    // 菊花
//    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
//    [self.view addSubview:hud];
//    hud.labelText = @"正在获取...";
//    [hud show:YES];
    ImageAlertView *alertView = [[ImageAlertView alloc] initWithFrame:self.view.frame];
    alertView.isHasBtn = NO;
    [alertView viewShowWithImage:[UIImage imageNamed:@"ic_refresh"] message:@"正在获取..."];
    [self.view addSubview:alertView];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
//    NSString *sParamArr =[NSString stringWithFormat:@"[\"%@\",\"%@\",\"getDynPwd\"]", [AppInfoManager getUserID], [AppInfoManager getDeviceID]];
    NSString *userID = [NSString stringWithFormat:@"%@", [AppInfoManager getUserID]];
    NSString *deviceID = [NSString stringWithFormat:@"%@", [AppInfoManager getDeviceID]];
    [params setObject:userID forKey:@"userId"];
    [params setObject:deviceID forKey:@"deviceId"];
    [CIBRequestOperationManager invokeAPI:@"gdp"
                                 byMethod:@"POST"
                           withParameters:params
                       onRequestSucceeded:^(NSString *responseCode, NSString *responseInfo) {
                           [alertView removeFromSuperview];
                           if ([responseCode isEqualToString:@"I00"]) {
                               NSDictionary *resultDic = (NSDictionary *)responseInfo;
                               NSString *resultCode = [resultDic objectForKey:@"resultCode"];
                               NSString *resultInfo = [resultDic objectForKey:@"result"];
                               if ([resultCode isEqualToString:@"26"]) {
                                   NSLog(@"responseInfo = %@",resultInfo);
                                   NSCharacterSet *characterSet = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet];
                                   NSString *newString = [[resultInfo componentsSeparatedByCharactersInSet:characterSet] componentsJoinedByString:@""];
                                   [self showInfoView:newString];
                                   //[MyUtils showAlertWithTitle:newString message:nil];
                               } else {
                                   [MyUtils showAlertWithTitle:resultInfo message:nil];
                               }
                           }
                           else {
                               [MyUtils showAlertWithTitle:responseInfo message:nil];
                           }
                       }
                          onRequestFailed:^(NSString *responseCode, NSString *responseInfo) {
                              [alertView removeFromSuperview];
                              [MyUtils showAlertWithTitle:responseInfo message:nil];
                          }];
}


- (void)scrollTimer {
    if (--count <= 0) {
        [timer invalidate];  // 关闭定时器
        
        // 启用获取按钮
        [self.getPinButton setEnabled:YES];
        [self.getPinButton setTitle:@"重新发送" forState:UIControlStateNormal];
        [self.getPinButton setTitleColor:enableTextColor forState:UIControlStateNormal];
    }
    else {
        [self.getPinButton setTitle:[NSString stringWithFormat:@"已获取(%ds)", count] forState:UIControlStateDisabled];
    }
}

//点击时的颜色
- (void)changeBtnColor:(UIButton *)button
{
    [button setBackgroundColor:[UIColor colorWithRed:0/255.0 green:102.0/255.0 blue:194.0/255.0 alpha:1]];
}

// 发送
- (IBAction)sendBtnPress:(id)sender {
    [sender setBackgroundColor:kUIColorLight];
    
    [self.pinTextField resignFirstResponder];
    // 检查输入
    if (self.pinTextField.text == nil || [[self.pinTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@""]) {
        [self showAlertViewTitle:@"请输入短信验证码" andMessage:nil];
        return;
    }
    
    // 检查网络
    if (![MyUtils isNetworkAvailableInView:self.view]) {
        return;
    }
    
    void(^CAValiCallback)(BOOL)=^(BOOL isSucc){
        //如果已经验证了
        if(isSucc){
            [MyUtils showAlertWithTitle:@"已经成功激活" message:nil];
            if(self.activationSuccBlock){
                self.activationSuccBlock();
            }
            return;
        }
    
    
    // 菊花
//    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
//    [self.view addSubview:hud];
//    hud.labelText = @"正在刷新...";
//    [hud show:YES];
    ImageAlertView *alertView = [[ImageAlertView alloc] initWithFrame:self.view.frame];
    alertView.isHasBtn = NO;
    [alertView viewShowWithImage:[UIImage imageNamed:@"ic_refresh"] message:@"正在激活..."];
    [self.view addSubview:alertView];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    NSString *userID = [NSString stringWithFormat:@"%@", [AppInfoManager getUserID]];
    NSString *deviceID = [NSString stringWithFormat:@"%@", [AppInfoManager getDeviceID]];
    [params setObject:userID forKey:@"userId"];
    [params setObject:deviceID forKey:@"deviceId"];
    [params setObject:self.pinTextField.text forKey:@"dynPwd"];
    [CIBRequestOperationManager invokeAPI:@"vdp"
                                 byMethod:@"POST"
                           withParameters:params
                       onRequestSucceeded:^(NSString *responseCode, NSString *responseInfo) {
                           [alertView removeFromSuperview];
                           if ([responseCode isEqualToString:@"I00"]) {
                               NSDictionary *resultDic = (NSDictionary *)responseInfo;
                               NSString *resultCode = [resultDic objectForKey:@"resultCode"];
                               NSString *resultInfo = [resultDic objectForKey:@"result"];
                               if ([resultCode isEqualToString:@"30"]) {
                                   [MyUtils showAlertWithTitle:@"已经成功激活" message:nil];
                                   if(self.activationSuccBlock){
                                       self.activationSuccBlock();
                                   }
                               } else {
//                                   [self showAlertViewTitle:resultInfo andMessage:nil];
                                   [MyUtils showAlertWithTitle:resultInfo message:nil];
                                   self.pinTextField.text=@"";
                               }
                           }
                           else {
                               [MyUtils showAlertWithTitle:responseInfo message:nil];
                           }
                       }
                          onRequestFailed:^(NSString *responseCode, NSString *responseInfo) {
                              [alertView removeFromSuperview];
                              
                              [MyUtils showAlertWithTitle:responseInfo message:nil];
                          }];
    };
    id rootController = [AppDelegate delegate].window.rootViewController;
    if([rootController isKindOfClass:[MainViewController class]]){
        [(MainViewController*)rootController loadCACertificate:CAValiCallback toView:self.view];
    }else{
        CAValiCallback(NO);
    }
    
}

- (IBAction)goBackBtnPress:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    if(self.backBlock){
        self.backBlock();
    }
}

- (void)showInfoView:(NSString *)string
{
    [self.view bringSubviewToFront:self.infoView];
    self.infoView.layer.cornerRadius = 4.f;
    self.infoView.clipsToBounds = YES;
    self.infoView.hidden = NO;
    self.infoView.alpha = 0;
    NSString *preString = [string substringWithRange:NSMakeRange(0, 3)];
    NSString *lastString = [string substringFromIndex:7];
    NSLog(@"%@,  %@",preString,lastString);
    self.infoLable.text = [NSString stringWithFormat:@"已发送短信至 %@****%@",preString,lastString];
//    CGSize textSize = [self.infoLable.text sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]}];
//    self.infoLable.frame = CGRectMake(self.infoLable.frame.origin.x, self.infoLable.frame.origin.y,textSize.width+35, textSize.height);
    [UIView animateWithDuration:1.5 animations:^{
        self.infoView.alpha = 1;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:1.5 animations:^{
            self.infoView.alpha = 0;
        } completion:nil];
    }];
}

- (void)loadSendButton
{
    UIButton *sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [sendButton.layer setCornerRadius:22.f];
    sendButton.clipsToBounds = YES;
    [sendButton setBackgroundColor:kUIColorLight];
    UIFont *titleFont = [UIFont boldSystemFontOfSize:15];
    [sendButton.titleLabel setFont:titleFont];
    
    [sendButton setTitle:@"立即激活" forState:UIControlStateNormal];
    [sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    //点击高亮状态
    [sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [sendButton addTarget:self action:@selector(changeBtnColor:) forControlEvents:UIControlEventTouchDown];
    [sendButton addTarget:self action:@selector(sendBtnPress:) forControlEvents:UIControlEventTouchUpInside];  // 关联事件
    
    [self.view addSubview:sendButton];
    
    //  设置退出登录按钮的自动位置调整
    sendButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:sendButton attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1 constant:28.0f]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:sendButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.editField attribute:NSLayoutAttributeBottom multiplier:1 constant:40.0f]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:sendButton attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1 constant:-28.0f]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:sendButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:0 constant:44.0f]];

}

- (BOOL)isSystemVersionBelowEight {
    return ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0f);
}

- (void)showAlertViewTitle:(NSString *)title andMessage:(NSString *)message{
    if ([self isSystemVersionBelowEight]) {
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
                                   handler:nil];
        
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}
// 点击屏幕任何地方，键盘消失
- (void) touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.pinTextField resignFirstResponder];
}
#pragma mark--UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if(textField==self.pinTextField){
        if (string.length == 0) return YES;
        NSInteger existedLength = textField.text.length;
        NSInteger selectedLength = range.length;
        NSInteger replaceLength = string.length;
        if (existedLength - selectedLength + replaceLength > 4) {
            return NO;
        }
    }
    return YES;
}


@end
