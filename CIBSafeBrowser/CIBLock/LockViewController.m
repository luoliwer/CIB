//
//  LockViewController.m
//  CIBSafeBrowser
//
//  Created by CIB-Mac mini on 14-12-31.
//  Copyright (c) 2014年 cib. All rights reserved.
//

#import "LockViewController.h"
#import "LockIndicator.h"
#import "LockConfig.h"
#import "MainViewController.h"
#import "ImageAlertView.h"

#import "MyUtils.h"
#import "AppDelegate.h"
#import "Config.h"

#import <CIBBaseSDK/FingerWorkManager.h>
#import <LocalAuthentication/LocalAuthentication.h>

@interface LockViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *preSnapImageView; // 上一界面截图
@property (weak, nonatomic) IBOutlet UIImageView *currentSnapImageView; // 当前界面截图

@property (strong, nonatomic) IBOutlet UIImageView *logo;  // 兴业logo
@property (nonatomic, strong) IBOutlet LockIndicator* indecator; // 九点指示图
@property (nonatomic, strong) IBOutlet LockView* lockview; // 触摸田字控件

@property (strong, nonatomic) IBOutlet UILabel *titleLable;
@property (strong, nonatomic) IBOutlet UILabel *tipLable;
@property (strong, nonatomic) IBOutlet UIButton *tipButton; // 重设/(取消)的提示按钮
@property (strong, nonatomic) IBOutlet UIImageView *headPortrait;

@property (nonatomic, strong) NSString *passwordOld; // 旧密码
@property (nonatomic, strong) NSString *passwordNew; // 新密码
@property (nonatomic, strong) NSString *passwordconfirm; // 确认密码
@property (nonatomic, strong) NSString *tip1; // 三步提示语
@property (nonatomic, strong) NSString *tip2;
@property (nonatomic, strong) NSString *tip3;

@property(nonatomic, assign) UIStatusBarStyle preStatusBarStyle;

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@end


@implementation LockViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithType:(LockViewType)type
{
    self = [super init];
    if (self) {
        _nLockViewType = type;
    }
    return self;
}

- (id)initWithType:(LockViewType)type user:(NSString *)user
{
    self = [super init];
    if (self) {
        _nLockViewType = type;
        _user = user;
    }
    return self;
}


#pragma mark - life cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.isModify = NO;
    CGRect rect = [UIScreen mainScreen].bounds;
    CGSize size = rect.size;
    CGFloat width = size.width;
    if (width == 414) {
        _tipLable = [[UILabel alloc] initWithFrame:CGRectMake(0, 180, 414, 28)];
        _tipLable.textAlignment = NSTextAlignmentCenter;
        _tipLable.textColor = [UIColor colorWithRed:131 / 255.0 green:196 / 255.0 blue:255 / 255.0  alpha:1];
        _tipLable.font = [UIFont systemFontOfSize:15];
        [self.view addSubview:_tipLable];
        self.headPortrait = [[UIImageView alloc] initWithFrame:CGRectMake(self.superViewOfPortrait.frame.size.width / 2.0 - 50, 0, 100, 100)];
        [self.superViewOfPortrait addSubview:self.headPortrait];
    }else if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {  // ipad
        self.headPortrait = [[UIImageView alloc] initWithFrame:CGRectMake(self.superViewOfPortrait.frame.size.width / 2.0 - 40, 0, 80, 80)];
         [self.superViewOfPortrait addSubview:self.headPortrait];
    }else {
    
        self.headPortrait = [[UIImageView alloc] initWithFrame:CGRectMake(self.superViewOfPortrait.frame.size.width / 2.0 - 40, 0, 80, 80)];
        [self.superViewOfPortrait addSubview:self.headPortrait];

    }
    
    UIImage *portrait = [self loadLocalUserIcon];
    
    [self.headPortrait setImage:portrait];

    [self.headPortrait setHidden:YES];

//    self.horiScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 100, 320, 320)];
    
    self.lockview.delegate = self;
    self.preStatusBarStyle = [[UIApplication sharedApplication] statusBarStyle];
    [self showEvaluatePolicy];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterBackgroundAction) name:UIApplicationDidEnterBackgroundNotification object:nil];
    }
-(void) enterBackgroundAction{
    if(self.nLockViewType==LockViewTypeCreate){
        [self tipButtonPressed:nil];
    }
}
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

- (void)viewWillAppear:(BOOL)animated
{
    [self shouldAutorotate];
    CGRect rect = [UIScreen mainScreen].bounds;
    CGSize size = rect.size;
    CGFloat width = size.width;
    if (width == 414) {
        self.headPortrait.layer.cornerRadius = 50;
        self.headPortrait.clipsToBounds = 50;
    }else{
        self.headPortrait.layer.cornerRadius = 40;
        self.headPortrait.clipsToBounds = 40;
    }
    
#ifdef LockAnimationOn
    [self capturePreSnap];
#endif
    
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];  // 状态栏浅色
    
    CGRect frame =  _logo.frame;
    CGFloat newY = (_indecator.frame.origin.y - frame.size.height) / 2;
    if (newY > frame.origin.y) {
        frame.origin.y = newY;
        _logo.frame = frame;
    }
    
    // 初始化内容
    switch (_nLockViewType) {
        case LockViewTypeCheck:
        {
            self.headPortrait.hidden = NO;
           
            _titleLable.text = @"";
            if (_user == nil) {
                _tipLable.text = @"请输入解锁密码";
            }
            else {
                _tipLable.text = [NSString stringWithFormat:@"请绘制手势密码登陆"];
            }
        }
            break;
        case LockViewTypeCreate:
        {
            _titleLable.text = @"设置手势密码";
            _tipLable.text = @"请绘制解锁图案";
        }
            break;
        case LockViewTypeModify:
        {
            self.headPortrait.hidden = YES;
            _titleLable.text = @"修改手势密码";
            _tipLable.text = @"请输入原来的密码";
        }
            break;
        case LockViewTypeClean:
        default:
        {
            self.headPortrait.hidden = NO;
            [self loadLocalUserIcon];

            _tipLable.text = @"请输入密码以清除密码";
        }
    }
    
    self.passwordOld = @"";
    self.passwordNew = @"";
    self.passwordconfirm = @"";
    
    [self updateTipButtonStatus];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:self.preStatusBarStyle];  // 状态栏恢复原有状态
    
     [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    CIBLog(@"lock--warning");
}

#pragma mark - 检查/更新密码
- (void)checkPassword:(NSString *)string
{
    // 验证密码正确
    if ([FingerWorkManager verifyFingerWork:string]) {
        
        if (_nLockViewType == LockViewTypeModify) { // 验证旧密码
            
            self.passwordOld = string; // 设置旧密码，说明是在修改
            
            [self setTip:@"请输入新的密码"]; // 这里和下面的delegate不一致，有空重构
            
        } else if (_nLockViewType == LockViewTypeClean) { // 清除密码

            [FingerWorkManager clearFingerWork];
            [self hide];
            
            [self showAlert:self.tip2];
            
        } else { // 验证成功
            
            [self hide];
            //设置状态为 手势密码反回
            id rootController = [AppDelegate delegate].window.rootViewController;
            if([rootController isKindOfClass:[MainViewController class]]){
                ((MainViewController*)rootController).mainFromState=MainFromLockSucc;
            }
        }
        
    }
    // 验证密码错误
    else if (string.length > 0) {
        
        NSInteger nRetryTimesRemain = [FingerWorkManager getFingerWorkRemainTestTimes];
        if (nRetryTimesRemain > 0) {
            
            if (1 == nRetryTimesRemain) {
                [self setErrorTip:[NSString stringWithFormat:@"最后的机会咯-_-!"]
                           errorPswd:string];
            } else {
                [self setErrorTip:[NSString stringWithFormat:@"密码错误，还可以再输入%d次", (int)nRetryTimesRemain]
                           errorPswd:string];
            }
            
        } else {
            
            // 强制注销该账户，并清除手势密码，以便重设
            [self dismissViewControllerAnimated:NO completion:^{
                [FingerWorkManager clearFingerWork];
                [self showAlert:@"您已输错多次，请重新登录"];
                
                if (_failBlock) {
                    _failBlock();
                }
            }];
        }
        
    } else {
        NSAssert(YES, @"手势验证发生意外");
    }
}

- (void)createPassword:(NSString *)string
{
    // 输入密码
    if ([self.passwordNew isEqualToString:@""] && [self.passwordconfirm isEqualToString:@""]) {
        
        // 检查最小长度
        int minLength;
    #ifdef LOCK_PWD_WITH_SEPARATOR  // 兼容老版本的string（逗号分隔）
        minLength = 2 * LOCK_MIN_PWD_LENGTH - 1; // 2n-1
    #else
        minLength = LOCK_MIN_PWD_LENGTH;
    #endif
        
        if ([string length] < minLength) {
            [self updateTipButtonStatus];
            [self setErrorTip:[NSString stringWithFormat:@"密码至少%d位，请重新绘制", LOCK_MIN_PWD_LENGTH] errorPswd:string];
            return;
        }
        
        self.passwordNew = string;
        [self setTip:self.tip2];
    }
    // 确认输入密码
    else if (![self.passwordNew isEqualToString:@""] && [self.passwordconfirm isEqualToString:@""]) {

        self.passwordconfirm = string;
        
        if ([self.passwordNew isEqualToString:self.passwordconfirm]) { // 成功
//            [self showAlert:self.tip3];
            [FingerWorkManager setFingerWork:string];
            [AppDelegate delegate].isUnlock = YES;
            
            // 判断是修改还是刚刚创建
            if (self.isModify) {
                [self performSelector:@selector(hide) withObject:nil afterDelay:0.0];
            }else{
            ImageAlertView *imageAlert = [[ImageAlertView alloc] initWithFrame:self.view.frame];
            imageAlert.autoHideAfterSeconds = 3.0;
            imageAlert.isHasBtn = NO;
            NSString *messageStr = @"设置手势密码成功，正在进入主页...";
            UIImage *image = [UIImage imageNamed:@"successCreated"];
            [imageAlert viewShowWithImage:image message:messageStr];
            [self.view addSubview:imageAlert];
            [self performSelector:@selector(hide) withObject:nil afterDelay:1.0];
            
                //设置状态为 手势密码反回
            id rootController = [AppDelegate delegate].window.rootViewController;
            if([rootController isKindOfClass:[MainViewController class]]){
                ((MainViewController*)rootController).mainFromState=MainFromLockSucc;
            }
        }
            
            
        } else {
            
            self.passwordconfirm = @"";
            [self setTip:self.tip2];
            [self setErrorTip:@"与上一次绘制不一致，请重新绘制" errorPswd:string];
            
        }
    } else {
        NSAssert(1, @"设置密码意外");
    }
}

#pragma mark - 显示提示
- (void)setTip:(NSString *)tip
{
    [_tipLable setText:tip];
    [_tipLable setTextColor:kTipColorNormal];
    
    _tipLable.alpha = 0;
    [UIView animateWithDuration:0.8
                     animations:^{
                          _tipLable.alpha = 1;
                     }completion:^(BOOL finished){
                     }
     ];
}

// 错误
- (void)setErrorTip:(NSString *)tip errorPswd:(NSString *)string
{
    // 显示错误点点
    [self.lockview showErrorCircles:string];
    
    // 直接_变量的坏处是
    [_tipLable setText:tip];
    [_tipLable setTextColor:UIColorFromRGB(0xff2a00)];
    [_tipLable setFont:[UIFont systemFontOfSize:15]];
    
    [self shakeAnimationForView:_tipLable];
}

#pragma mark 新建/修改后保存
// 重设TipButton
- (void)updateTipButtonStatus
{
    if ((_nLockViewType == LockViewTypeCreate || _nLockViewType == LockViewTypeModify) &&
        ![self.passwordNew isEqualToString:@""]) // 新建或修改 & 确认时 显示
    {
        [self.tipButton setTitle:@"重新设置手势密码" forState:UIControlStateNormal];
        [self.tipButton setAlpha:1.0];
        
    }
    else if (_nLockViewType == LockViewTypeCheck)  // 解锁时 显示
    {
        [self.tipButton setTitle:@"忘记手势密码？" forState:UIControlStateNormal];
        
        [self.tipButton setAlpha:1.0];
    }
    else if (_nLockViewType == LockViewTypeModify && [self.passwordNew isEqualToString:@""]) {  // 修改 & 未输入 时显示
        [self.tipButton setTitle:@"取消修改" forState:UIControlStateNormal];
        [self.tipButton setAlpha:1.0];
    }
    else {
        [self.tipButton setAlpha:0.0];
    }
    
    // 更新指示圆点
    if (![self.passwordNew isEqualToString:@""] && [self.passwordconfirm isEqualToString:@""]){
        self.indecator.hidden = NO;
        [self.indecator setPasswordString:self.passwordNew];
    } else {
        self.indecator.hidden = YES;
    }
}

#pragma mark - 点击了按钮
- (IBAction)tipButtonPressed:(id)sender {
    if (_nLockViewType == LockViewTypeModify && [self.passwordNew isEqualToString:@""]) {  // 点击取消修改
        [self dismissViewControllerAnimated:YES completion:^{
            if (_succeededBlock) {
                _succeededBlock();
            }
        }];
    }
    else if (_nLockViewType != LockViewTypeCheck) {
        self.passwordNew = @"";
        self.passwordconfirm = @"";
        [self setTip:self.tip1];
        [self updateTipButtonStatus];
    }
    else {  // 点击忘记手势作失败处理
        [[AppDelegate delegate] loginOut:self];
        // 强制注销该账户，并清除手势密码，以便重设
//        [self dismissViewControllerAnimated:NO completion:^{
//            [FingerWorkManager clearFingerWork];
//            if (_failBlock) {
//                _failBlock();
//            }
//        }];
    }
}

#pragma mark - 成功后返回
- (void)hide
{
    switch (_nLockViewType) {
            
        case LockViewTypeCheck:
        {
        }
            break;
        case LockViewTypeCreate:
        {
            
        }
        case LockViewTypeModify:
        {
            [FingerWorkManager setFingerWork:self.passwordNew];
        }
            break;
        case LockViewTypeClean:
        default:
        {
            [FingerWorkManager clearFingerWork];
        }
    }
    
    // 在这里可能需要回调上个页面做一些刷新什么的动作
    if (_succeededBlock) {
        _succeededBlock();
    }

#ifdef LockAnimationOn
     [self captureCurrentSnap];
    // 隐藏控件
    for (UIView* v in self.view.subviews) {
        if (v.tag > 10000) continue;
        v.hidden = YES;
    }
    // 动画解锁
    [self animateUnlock];
#else
    [self dismissViewControllerAnimated:YES completion:nil];
#endif
    
}

#pragma mark - delegate 每次划完手势后
- (void)lockString:(NSString *)string
{    
    switch (_nLockViewType) {
            
        case LockViewTypeCheck:
        {
            if (_user == nil) {
                self.tip1 = @"请输入解锁密码";
            }
            else {
                self.tip1 = [NSString stringWithFormat:@"您好，%@", _user];
            }
            [self checkPassword:string];
        }
            break;
        case LockViewTypeCreate:
        {
            self.tip1 = @"请绘制解锁图案";
            self.tip2 = @"请再次绘制解锁图案";
            self.tip3 = @"设置手势密码成功，正在进入主页...";
            [self createPassword:string];
        }
            break;
        case LockViewTypeModify:
        {
            self.isModify = YES;
            if ([self.passwordOld isEqualToString:@""]) {
                self.tip1 = @"请输入原来的密码";
                [self checkPassword:string];
            } else {
                self.tip1 = @"请绘制新的解锁图案";
                self.tip2 = @"请再次绘制解锁图案";
                self.tip3 = @"设置手势密码成功，正在进入主页...";
                [self createPassword:string];
            }
            self.isModify = NO;
        }
            break;
        case LockViewTypeClean:
        default:
        {
            self.tip1 = @"请输入密码以清除密码";
            self.tip2 = @"解锁密码清除成功";
            [self checkPassword:string];
        }
    }
    
    [self updateTipButtonStatus];
}

#pragma mark - 解锁动画
// 截屏，用于动画
#ifdef LockAnimationOn
- (UIImage *)imageFromView:(UIView *)theView
{
    UIGraphicsBeginImageContext(theView.frame.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [theView.layer renderInContext:context];
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

// 上一界面截图
- (void)capturePreSnap
{
    self.preSnapImageView.hidden = YES; // 默认是隐藏的
    self.preSnapImageView.image = [self imageFromView:self.presentingViewController.view];
}

// 当前界面截图
- (void)captureCurrentSnap
{
    self.currentSnapImageView.hidden = YES; // 默认是隐藏的
    self.currentSnapImageView.image = [self imageFromView:self.view];
}

- (void)animateUnlock {
    
    self.currentSnapImageView.hidden = NO;
    self.preSnapImageView.hidden = NO;
    
    static NSTimeInterval duration = 0.5;
    
    // currentSnap
    CABasicAnimation* scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation.fromValue = [NSNumber numberWithFloat:1.0];
    scaleAnimation.toValue = [NSNumber numberWithFloat:2.0];
    
    CABasicAnimation *opacityAnimation;
    opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.fromValue=[NSNumber numberWithFloat:1];
    opacityAnimation.toValue=[NSNumber numberWithFloat:0];
    
    CAAnimationGroup* animationGroup =[CAAnimationGroup animation];
    animationGroup.animations = @[scaleAnimation, opacityAnimation];
    animationGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animationGroup.duration = duration;
    animationGroup.delegate = self;
    animationGroup.autoreverses = NO; // 防止最后显现
    animationGroup.fillMode = kCAFillModeForwards;
    animationGroup.removedOnCompletion = NO;
    [self.currentSnapImageView.layer addAnimation:animationGroup forKey:nil];
    
    // preSnap
    scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation.fromValue = [NSNumber numberWithFloat:1.5];
    scaleAnimation.toValue = [NSNumber numberWithFloat:1.0];
    
    opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.fromValue = [NSNumber numberWithFloat:0];
    opacityAnimation.toValue = [NSNumber numberWithFloat:1];
    
    animationGroup = [CAAnimationGroup animation];
    animationGroup.animations = @[scaleAnimation, opacityAnimation];
    animationGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animationGroup.duration = duration;

    [self.preSnapImageView.layer addAnimation:animationGroup forKey:nil];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    self.currentSnapImageView.hidden = YES;
    [self dismissViewControllerAnimated:NO completion:nil];
    
    self.preSnapImageView = nil;
    self.currentSnapImageView = nil;
}
#endif

#pragma mark 抖动动画
- (void)shakeAnimationForView:(UIView *)view
{
    CALayer *viewLayer = view.layer;
    CGPoint position = viewLayer.position;
    CGPoint left = CGPointMake(position.x - 10, position.y);
    CGPoint right = CGPointMake(position.x + 10, position.y);
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [animation setFromValue:[NSValue valueWithCGPoint:left]];
    [animation setToValue:[NSValue valueWithCGPoint:right]];
    [animation setAutoreverses:YES]; // 平滑结束
    [animation setDuration:0.08];
    [animation setRepeatCount:3];
    
    [viewLayer addAnimation:animation forKey:nil];
}

#pragma mark - 指纹验证提示
- (void)showEvaluatePolicy
{
    //只有当检查手势密码时，弹出指纹验证
    if (self.nLockViewType == LockViewTypeCheck) {
        LAContext *context = [LAContext new];
        context.localizedFallbackTitle = @"验证手势密码";
        NSError *error;
        
        if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]) {
            [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:@"请验证您的指纹ID" reply:^(BOOL success, NSError *error) {
                if (success) {
                    
                    if (self.succeededBlock) {
                        self.succeededBlock();
                    }
                    
                    [self dismissViewControllerAnimated:YES completion:nil];
                }
            }];
        }
        
    }
}


#pragma mark - 提示信息
- (void)showAlert:(NSString *)string
{
    /*
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:nil
                                                    message:string
                                                   delegate:nil
                                          cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
    [alert show];
    
    UIAlertController *alertController = [UIAlertController    alertControllerWithTitle:nil message:string preferredStyle:UIAlertControllerStyleAlert];
    
    
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:NSLocalizedString(@"确定", @"OK action")
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                   
                               }];
    
    [alertController addAction:okAction];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.0005 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIViewController *currentVC = [self getCurrentVC];
        [currentVC presentViewController:alertController animated:YES completion:nil];
    });
      */
    [MyUtils showAlertWithTitle:nil message:string];
    
}
/*
//获取当前屏幕显示的viewcontroller
- (UIViewController *)getCurrentVC
{
    UIViewController *result = nil;
    
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal)
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows)
        {
            if (tmpWin.windowLevel == UIWindowLevelNormal)
            {
                window = tmpWin;
                break;
            }
        }
    }
    
    UIView *frontView = [[window subviews] objectAtIndex:0];
    id nextResponder = [frontView nextResponder];
    
    if ([nextResponder isKindOfClass:[UIViewController class]])
        result = nextResponder;
    else
        result = window.rootViewController;
    
    return result;
}
 */
- (UIImage *)loadLocalUserIcon {
    UIImage *image = nil;
    // 获取应用程序沙盒的Documents目录
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDir = [paths objectAtIndex:0];
    // 拼装头像文件存储路径
    NSString *fileName = @"userIcon.jpeg";
    NSString *iconDir = [documentDir stringByAppendingPathComponent:fileName];
    if ([Function isFileExistedAtPath:iconDir]) {
        image = [UIImage imageWithContentsOfFile:iconDir];
    }
    if (image) {
        return image;
    }
    // 返回默认头像
    else {
        return [UIImage imageNamed:@"defaultUserIcon"];
    }
}
- (void)jumpToMainVc{
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
