//
//  SettingViewController.m
//  CIBSafeBrowser
//
//  Created by cib on 14/12/6.
//  Copyright (c) 2014年 cib. All rights reserved.
//

#import "SettingViewController.h"

#import "AppDelegate.h"
#import "MainViewController.h"
#import "SettingCell.h"
#import "LoginViewController.h"
#import "FilesViewController.h"
#import "SecureViewController.h"
#import "ActivationViewController.h"
#import "AboutViewController.h"

#import "SecUtils.h"
#import "MyUtils.h"
#import "Config.h"
#import "CoreDataManager.h"

#import "MBProgressHUD.h"
#import "ImageAlertView.h"
#import "SDWebImageManager.h"
#import "UIImageView+WebCache.h"
#import "ImageCropView.h"
#import "ChatDBManager.h"
#import "Chatter.h"

#import "SetAuthorViewController.h"

#import <CIBBaseSDK/CIBBaseSDK.h>

#import "ChatDBManager.h"

@interface SettingViewController () <UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate,UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (strong, nonatomic) IBOutlet UITableView *settingTableView;
@property (strong, nonatomic) UIImagePickerController *imagePickerVC;
@property (strong, nonatomic) NSString *userIconRelativeURL;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *iconConstraintWidth;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *iconConstraintHeight;

@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;  // 不显示顶部空白
    //初始化拍照和选取相册照片相关的VC
    self.imagePickerVC = [[UIImagePickerController alloc] init];
    self.imagePickerVC.delegate = self;
}

// Dispose of any resources that can be recreated.
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
// 屏幕将要旋转时执行的方法
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator NS_AVAILABLE_IOS(8_0){
    [self.settingTableView reloadData];
}


#pragma mark - Table view data source

// 分成三块区域
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

// Return the number of rows in the section.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 1) {
        return 1;
    }
    else if (section == 2)
    {
        return 5;
    }
    else
        return 0;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"SettingPrototypeCell";
    SettingCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    if (indexPath.section == 1) {
       
        cell.icon.image = [UIImage imageNamed:@"ic_document"];
        cell.title.text = @"本地文档";
        cell.detail.text = @"";
    }
    else if (indexPath.section == 2) {
        switch (indexPath.row) {
            case 0:  // 安全设置
            {
                cell.icon.image = [UIImage imageNamed:@"ic_security"];
                
                cell.title.text = @"安全设置";
                cell.detail.text = @"";
                break;
            }
            case 1:  // 修改条线
                cell.icon.image = [UIImage imageNamed:@"ic_authorLine"];
                cell.title.text = @"修改条线";
                cell.detail.text = @"";
                break;
            case 2:  // 清除缓存
                cell.icon.image = [UIImage imageNamed:@"cleanCache"];
                cell.title.text = @"清除缓存";
                cell.detail.text = [self getCacheFileSize];
                break;
            case 3:  // 检查更新
            {
                cell.icon.image = [UIImage imageNamed:@"update"];
                cell.title.text = @"检查更新";
                // 获取版本信息
                NSString *versionCode = [AppInfoManager getValueForKey:@"versionCode" forApp:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"]];  // build
                NSString *versionName = [AppInfoManager getValueForKey:@"versionName" forApp:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"]];  // version
                // 比对版本信息
                if (versionCode && versionName) {
                    NSString *curVersionCode = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];  // build
                    if ([versionCode intValue] > [curVersionCode intValue]) {  // 如果服务端版本较新
                        cell.detail.text = @"有新版本";
                    }
                    else {
                        cell.detail.text = @"已是最新版";
                    }
                }
                else {
                    cell.detail.text = @"已是最新版";
                }
            }
                break;
            case 4:  // 关于
                cell.icon.image = [UIImage imageNamed:@"about"];
                cell.title.text = @"关于";
                cell.detail.text = @"";
                break;
            default:
                break;
        }
    }
    cell.iconConstraintWidth.constant=cell.icon.image.size.width;
    cell.iconConstraintHeight.constant=cell.icon.image.size.height;
    cell.moreConstraintWidth.constant=cell.moreBtn.image.size.width;
    cell.moreConstraintHeight.constant=cell.moreBtn.image.size.height;
    return cell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger) section {
    CGFloat hight = [UIScreen mainScreen].bounds.size.height;
    if (section == 0) {
        return 224.f / 667.f * hight;
    }
    else
        return 6.f / 667.f * hight;
}


- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    CGFloat hight = [UIScreen mainScreen].bounds.size.height;
    if (section == 2) {
        return 100.f / 667.f * hight;
    }
    else
        return 6.f / 667.f * hight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50.f;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section != 0) {
        return nil;
    }

    // 表头增加头像区域
    CGFloat tableWidth = self.settingTableView.bounds.size.width;
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    CGRect frame = CGRectMake(0.f, 0.f, tableWidth, 224.f / 667.f * height);
    UIView *head = [[UIView alloc] initWithFrame:frame];
    [head setBackgroundColor:kUIColorLight];
    
    //渐变颜色
    CAGradientLayer *newShadow = [[CAGradientLayer alloc] init];
    newShadow.frame = head.frame;
    
    newShadow.colors = [NSArray arrayWithObjects:(id)[[[UIColor colorWithRed:18.f/255.0 green:119.f/255.0 blue:211.f/255.0 alpha:1] colorWithAlphaComponent:1] CGColor],(id)[[[UIColor colorWithRed:8.f/255.0 green:91.f/255.0 blue:168.f/255.0 alpha:1] colorWithAlphaComponent:1] CGColor], nil];
    [head.layer addSublayer:newShadow];

    //返回按钮
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(12, 30, 24, 24);
    [button setBackgroundImage:[UIImage imageNamed:@"btn_back"] forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageNamed:@"btn_back_p"] forState:UIControlStateHighlighted];
    [button addTarget: self action:@selector(setBackPress) forControlEvents:UIControlEventTouchUpInside];
    [head addSubview:button];
    
    //头像
    CGFloat iconRadius = 80.0f / 667.f * height;//圆形view的直径
    CGFloat iconViewPosX = (frame.size.width - iconRadius)/ 2;//圆形view的横坐标
    CGFloat iconViewPosY = 64.f / 667.f * height ;//圆形view的纵坐标
    UIImageView *icon = [[UIImageView alloc] initWithFrame:CGRectMake(iconViewPosX, iconViewPosY, iconRadius, iconRadius)];
    
    // 将imageView设置为圆形
    icon.layer.masksToBounds = YES;
    icon.layer.cornerRadius = iconRadius / 2;
    
    // 添加imageView的点击事件
    icon.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(iconViewTapped:)];
    [icon addGestureRecognizer:singleTap];
    
    [head addSubview:icon];
    
    // 设置头像view的自动位置调整
    icon.translatesAutoresizingMaskIntoConstraints = NO;
    [head addConstraint:[NSLayoutConstraint constraintWithItem:icon attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:head attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    [head addConstraint:[NSLayoutConstraint constraintWithItem:icon attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:head attribute:NSLayoutAttributeTop multiplier:1 constant:iconViewPosY]];
    [head addConstraint:[NSLayoutConstraint constraintWithItem:icon attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:head attribute:NSLayoutAttributeWidth multiplier:0 constant:iconRadius]];
    [head addConstraint:[NSLayoutConstraint constraintWithItem:icon attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:head attribute:NSLayoutAttributeHeight multiplier:0 constant:iconRadius]];

    // 首先获取本地的占位头像
    UIImage *placeHolderImage = [self loadLocalUserIcon];
    icon.image = placeHolderImage;
    
    // 检查是否达到更新间隔
    CoreDataManager *cdManager = [[CoreDataManager alloc] init];
    double lastUpdateTime = [cdManager getUpdateTimeByName:@"IconUpdate"];
    double currentTime = [[NSDate date] timeIntervalSince1970];
    NSNumber *updateTimeInterval = [MyUtils propertyOfResource:@"Setting" forKey:@"IconUpdateInterval"];
    
    if (lastUpdateTime != 0.0 && currentTime - lastUpdateTime < [updateTimeInterval longValue]) {
        
    }
    else {
        
        // 调用服务端头像查询接口，查询此用户是否有头像
        NSDictionary *paramDic = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%@", [AppInfoManager getUserName]] forKey:@"notesId"];
        [CIBRequestOperationManager invokeAPI:@"faceck" byMethod:@"POST" withParameters:paramDic onRequestSucceeded:^(NSString *responseCode, NSString *responseInfo) {
            if ([responseCode isEqualToString:@"I00"]) {
                NSDictionary *responseDic = (NSDictionary *)responseInfo;
                NSString *resultCode = [responseDic objectForKey:@"resultCode"];
                if ([resultCode isEqualToString:@"0"]) {
                    self.userIconRelativeURL = [responseDic objectForKey:@"path"];
                    
                    // 从服务端静态地址异步获取用户头像
                    NSString *httpAddr = nil;
                    NSString *baseURL = [URLAddressManager getBasicURLAddress];
                    httpAddr = baseURL;
                    NSString *userIconURL = [MyUtils combineURLWithBaseURL:httpAddr andRelativeURL:self.userIconRelativeURL];
                    SDWebImageManager *manager = [SDWebImageManager sharedManager];
                    [[manager imageCache] removeImageForKey:userIconURL fromDisk:YES];
                    [icon sd_setImageWithURL:[NSURL URLWithString:userIconURL] placeholderImage:placeHolderImage completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                        // 成功从服务端获取
                        if (image && !error) {
                            [cdManager updateUpdateTimeByName:@"IconUpdate"];
                            // 覆盖本地文件
                            // 获取应用程序沙盒的Documents目录
                            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                            NSString *documentDir = [paths objectAtIndex:0];
                            // 拼装头像文件存储路径
                            NSString *fileName = @"userIcon.jpeg";
                            NSString *iconDir = [documentDir stringByAppendingPathComponent:fileName];
                            
                            NSData *serverData = UIImageJPEGRepresentation(image, 1.0);
                            [serverData writeToFile:iconDir atomically:YES];
                        }
                    }];
                }
                else {
                    // 服务端未找到此用户头像，直接显示占位头像
                    icon.image = placeHolderImage;
                }
            }
            else {
                icon.image = placeHolderImage;
            }
        } onRequestFailed:^(NSString *responseCode, NSString *responseInfo) {
            icon.image = placeHolderImage;
        }];
    }
    
    // 增加头像下方的用户姓名
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, iconViewPosY + iconRadius + 20.f / 667.f * height, iconRadius, 15.f)];
    [nameLabel setTextAlignment:NSTextAlignmentCenter];
    [nameLabel setTextColor:[UIColor whiteColor]];
    nameLabel.text = [AppInfoManager getValueForKey:kKeyOfUserRealName];
    [nameLabel setFont:[UIFont boldSystemFontOfSize:16]];
    [head addSubview:nameLabel];
    
    nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [head addConstraint:[NSLayoutConstraint constraintWithItem:nameLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:head attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    [head addConstraint:[NSLayoutConstraint constraintWithItem:nameLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:icon attribute:NSLayoutAttributeBottom multiplier:1 constant:20.f / 667.f * height]];
    [head addConstraint:[NSLayoutConstraint constraintWithItem:nameLabel attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:head attribute:NSLayoutAttributeWidth multiplier:1 constant:0]];
    [head addConstraint:[NSLayoutConstraint constraintWithItem:nameLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:head attribute:NSLayoutAttributeHeight multiplier:0 constant:15.0f]];
    
    // 增加头像下方的用户编号
    UILabel *numberLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, iconViewPosY + iconRadius + (20.f + 10) / 667.f * height + 15, iconRadius, 15.f)];
    [numberLabel setTextAlignment:NSTextAlignmentCenter];
    [numberLabel setTextColor:[UIColor whiteColor]];
    NSString *userName = [AppInfoManager getValueForKey:kKeyOfUserName];
    numberLabel.text = [NSString stringWithFormat:@"NO.%@",userName];
    [numberLabel setFont:[UIFont boldSystemFontOfSize:16]];
    [head addSubview:numberLabel];
    
    numberLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [head addConstraint:[NSLayoutConstraint constraintWithItem:numberLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:head attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    [head addConstraint:[NSLayoutConstraint constraintWithItem:numberLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:nameLabel attribute:NSLayoutAttributeBottom multiplier:1 constant:10.f / 667.f * height]];
    [head addConstraint:[NSLayoutConstraint constraintWithItem:numberLabel attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:head attribute:NSLayoutAttributeWidth multiplier:1 constant:0]];
    [head addConstraint:[NSLayoutConstraint constraintWithItem:numberLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:head attribute:NSLayoutAttributeHeight multiplier:0 constant:15.0f]];
    
    //返回按钮
    
    
    return head;
}
// 响应返回按钮
- (void)setBackPress{
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (section != 2) {
        return nil;
    }
    
    // 表尾增加退出登录按钮
    CGFloat tableWidth = self.settingTableView.bounds.size.width;
    CGFloat heigth = [UIScreen mainScreen].bounds.size.height;
    CGRect frame = CGRectMake(0.f, 0.f, tableWidth, 100.f / 667.f * heigth);
    UIView *foot = [[UIView alloc] initWithFrame:frame];
   
    UIButton *logoutButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [logoutButton.layer setCornerRadius:22.f];
    [logoutButton setBackgroundColor:kUIColorLight];
    UIFont *titleFont = [UIFont boldSystemFontOfSize:16];
    [logoutButton.titleLabel setFont:titleFont];
    
    [logoutButton setTitle:@"退出登陆" forState:UIControlStateNormal];
    [logoutButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    //点击高亮状态
    [logoutButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [logoutButton addTarget:self action:@selector(changeBtnColor:) forControlEvents:UIControlEventTouchDown];
    [logoutButton addTarget:self action:@selector(logoutBtnPress:) forControlEvents:UIControlEventTouchUpInside];  // 关联事件
    
    [foot addSubview:logoutButton];
    
    //  设置退出登录按钮的自动位置调整
    logoutButton.translatesAutoresizingMaskIntoConstraints = NO;
    [foot addConstraint:[NSLayoutConstraint constraintWithItem:logoutButton attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:foot attribute:NSLayoutAttributeLeft multiplier:1 constant:28.0f / 667.f * heigth]];
    [foot addConstraint:[NSLayoutConstraint constraintWithItem:logoutButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:foot attribute:NSLayoutAttributeTop multiplier:1 constant:40.0f / 667.f * heigth]];
    [foot addConstraint:[NSLayoutConstraint constraintWithItem:logoutButton attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:foot attribute:NSLayoutAttributeRight multiplier:1 constant:-28.0f / 667.f * heigth]];
    [foot addConstraint:[NSLayoutConstraint constraintWithItem:logoutButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:foot attribute:NSLayoutAttributeHeight multiplier:0 constant:44.0f]];
    
    return foot;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // 选中后立即取消选中状态
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Setting" bundle:[NSBundle mainBundle]];
    @try {
        if (indexPath.section == 1) {
            //本地文档
            FilesViewController *files = [story instantiateViewControllerWithIdentifier:@"files"];
            [self.navigationController pushViewController:files animated:YES];
        }
        else if (indexPath.section == 2)
        {
            switch (indexPath.row) {
                    //            case 0:  // 当前账号
                    //                break;
                case 0:  //安全设置
                {
                    SecureViewController *secure = [story instantiateViewControllerWithIdentifier:@"secure"];
                    [self.navigationController pushViewController:secure animated:YES];
                }
                    break;
                case 1:  //设置条线
                {
//                    SecureViewController *secure = [story instantiateViewControllerWithIdentifier:@"secure"];
//                    [self.navigationController pushViewController:secure animated:YES];
//                    self.parentViewController present
                     UIStoryboard *mainStory = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
                    SetAuthorViewController *setAuthor = [mainStory instantiateViewControllerWithIdentifier:@"setAuthor"];
                    setAuthor.isMondify=YES;
                    [self.navigationController pushViewController:setAuthor animated:YES];
                }
                    break;
                case 2:  //清除缓存
                {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                                    message:@"清除缓存可以释放一部分空间，但可能会降低您下一次的应用加载速度。\n是否要清除缓存？"
                                                                   delegate:self
                                                          cancelButtonTitle:@"取消"
                                                          otherButtonTitles:@"确定",nil];
                    [alert setTag:8504];
                    [alert show];
                }
                    break;
                case 3:  // 检查更新
                    if ([MyUtils isNetworkAvailableInView:self.view]) {
                        [self checkUpdate];
                    }
                    break;
                case 4:
                {
                    AboutViewController *about = [story instantiateViewControllerWithIdentifier:@"about"];
                    [self.navigationController pushViewController:about animated:YES];
                }
                    break;
                default:
                    break;
            }
        }

    }
    @catch (NSException *exception) {
         NSLog(@"exception:%@", exception);
    }
    @finally {
        
    }
}


//响应头像视图的点击
- (void)iconViewTapped:(UITapGestureRecognizer *)gestureRecognizer {
    //下面去弹出拍照或者选取相册照片
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照", @"从相册选择", nil];
    //    [actionSheet showInView:self.view];
    // 在iPad上，上述方法actionsheet会出现在屏幕正中，故采用如下方法
    UIView *gesView = gestureRecognizer.view;
    CGRect rect = gesView.bounds ;
    [actionSheet showFromRect:rect inView:gesView animated:YES];
}

// 响应退出登录按钮
- (void)changeBtnColor:(UIButton *)button
{
    [button setBackgroundColor:[UIColor colorWithRed:0/255.0 green:102.0/255.0 blue:194.0/255.0 alpha:1]];
}
- (IBAction)logoutBtnPress:(id)sender {
    [sender setBackgroundColor:kUIColorLight];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                    message:@"退出登录会注销您在本设备上的注册信息及相关证书，这将影响到本设备上的所有兴业银行企业内部应用，您需要重新注册激活才能使用。是否确定？"
                                                   delegate:self
                                          cancelButtonTitle:@"取消"
                                          otherButtonTitles:@"确定",nil];
    [alert setTag:8501];
    [alert show];
}

#pragma marks - UIAlertViewDelegate --
// 根据被点击按钮的索引处理点击事件，此处只处理确定按钮（index = 1）
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (alertView.tag == 8501 && buttonIndex == 1) {  // 退出登录提示框
        [[AppDelegate delegate] loginOut:self];
    }
    else if (alertView.tag == 8502 && buttonIndex == 1) {  // 更新提示框
        // 打开更新url
        NSString *versionUrl = [AppInfoManager getValueForKey:@"versionUrl" forApp:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"]];
        NSURL *appUrl = [NSURL URLWithString:versionUrl];
        [[UIApplication sharedApplication] openURL:appUrl];
    }
    else if (alertView.tag == 8503 && buttonIndex == 1) {  // 头像存储失败提示框
        // 返回设置界面
        [self.imagePickerVC dismissViewControllerAnimated:YES completion:nil];
    }
    else if (alertView.tag == 8504 && buttonIndex == 1) {  // 清除缓存确认提示框
        // 返回设置界面
        [self cleanCacheFile];
    }
}

// 检查应用更新
- (void)checkUpdate {    
//    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
//    hud.labelText = @"检查更新...";
//    [self.view addSubview:hud];
//    [hud show:YES];
    ImageAlertView *alertView = [[ImageAlertView alloc] initWithFrame:self.view.frame];
    alertView.isHasBtn = NO;
    [alertView viewShowWithImage:[UIImage imageNamed:@"ic_refresh"] message:@"检查更新..."];
    [self.view addSubview:alertView];
    // 设备类型
    NSString *deviceType = @"iPhone";
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {  // ipad
        deviceType = @"iPad";
    }

    // 请求更新数据
    id paramDic = @{@"appId":[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"], @"deviceType":deviceType};
    [CIBRequestOperationManager invokeAPI:@"cav"
                                 byMethod:@"POST"
                           withParameters:paramDic
                       onRequestSucceeded:^(NSString *responseCode, NSString *responseInfo) {
                           [alertView removeFromSuperview];  // 隐藏菊花
                           // 标记一下此时设备已经激活，可以打开WebApp
                           [AppDelegate delegate].isActive = YES;
                           
                           if ([responseCode isEqualToString:@"0"] || [responseCode isEqualToString:@"I00"]) {
                               CIBLog(@"getUpdateInfo succeeded, info = %@", responseInfo);
                               
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
                                       
                                       // 设置栏提示
                                       NSIndexPath *index = [NSIndexPath indexPathForRow:2 inSection:2];
                                       SettingCell *cell = (SettingCell *)[self.settingTableView cellForRowAtIndexPath:index];
                                       NSString *alerInfo = [NSString stringWithFormat:@"有更新"];
                                       cell.detail.text = alerInfo;
                                       
                                       // 弹窗提示
                                       NSString *msg = versionInfo;
                                       if (![MyUtils isWifiAvailable]) {
                                           msg = [NSString stringWithFormat:@"%@\n当前非Wi-Fi网络环境，请确认是否执行更新。", msg];
                                       }
                                       if ([[[UIDevice currentDevice]systemVersion]floatValue] >= 8.0) {
                                           UIAlertController *alert = [UIAlertController alertControllerWithTitle:alerInfo message:msg preferredStyle:UIAlertControllerStyleAlert];
                                           UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
                                           UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                                               
                                               NSString *versionUrl = [AppInfoManager getValueForKey:@"versionUrl" forApp:[AppInfoManager getAppID]];
                                               NSURL *appUrl = [NSURL URLWithString:versionUrl];
                                               [[UIApplication sharedApplication] openURL:appUrl];
                                               
                                           }];
                                           
                                           [alert addAction:cancelAction];
                                           [alert addAction:sureAction];
                                           [self presentViewController:alert animated:YES completion:nil];

                                       }else{
                                           
                                       UIAlertView *alert = [[UIAlertView alloc] initWithTitle:alerInfo
                                                                                       message:msg
                                                                                      delegate:self
                                                                             cancelButtonTitle:@"取消"
                                                                             otherButtonTitles:@"确定", nil];
                                       [alert setTag:8502];
                                       [alert show];
                                       }
                                   }
                               }
                           }

                       } onRequestFailed:^(NSString *responseCode, NSString *responseInfo) {
                           [alertView removeFromSuperview];  // 隐藏菊花
                           if ([responseCode isEqualToString:@"11"]) {
                               [MyUtils showAlertWithTitle:responseInfo message:nil];
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
                           else {
                               [MyUtils showAlertWithTitle:responseInfo message:nil];
                           }
                       }
     ];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        //调用相机
        [self takePhoto];
    }
    else if (buttonIndex == 1) {
        //调用相册
        [self pickPhotoFromAlbum];
    }
    else {
        [actionSheet dismissWithClickedButtonIndex:buttonIndex animated:YES];
    }
}

- (void)takePhoto {
    //拍照
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    if ([UIImagePickerController isSourceTypeAvailable:sourceType]) {
        self.imagePickerVC.sourceType = sourceType;
        [self presentViewController:self.imagePickerVC animated:YES completion:nil];
    }
    else {
        CIBLog(@"模拟器中无法打开照相机,请在真机中使用");
    }
}

- (void)pickPhotoFromAlbum {
    //从相册选择
    self.imagePickerVC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:self.imagePickerVC animated:YES completion:nil];
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    if (mediaType) {
        UIImage *iconImage = [info objectForKey:UIImagePickerControllerOriginalImage];
        iconImage = [iconImage fixOrientation];
        // 裁剪图片尺寸
        float squareSideLength = MIN(iconImage.size.height, iconImage.size.width);
        CGRect squareRect = CGRectMake(0.0, 0.0, squareSideLength, squareSideLength);
        CGImageRef sourceImageRef = [iconImage CGImage];
        CGImageRef squareImageRef = CGImageCreateWithImageInRect(sourceImageRef, squareRect);
        UIImage *squareImage = [UIImage imageWithCGImage:squareImageRef];
        
        // 压缩尺寸
        CGSize newSize = CGSizeMake(200, 200);
        UIGraphicsBeginImageContext(newSize);
        [squareImage drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
        UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        // 压缩图片大小
        NSData *iconData = nil;
        iconData = UIImageJPEGRepresentation(newImage, 1);
        if (iconData) {
            //存储头像
            // 获取应用程序沙盒的Documents目录
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentDir = [paths objectAtIndex:0];
            // 拼装头像文件存储路径
            NSString *fileName = @"userIcon.jpeg";
            NSString *iconDir = [documentDir stringByAppendingPathComponent:fileName];
            BOOL saveSuccess = [iconData writeToFile:iconDir atomically:YES];
            if (!saveSuccess) {
                //提示上传失败（其实是存储失败）
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message: @"抱歉，头像上传失败" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                alertView.tag = 8503;
                [alertView show];
            }
            else {
                // 隐藏拍照/选择照片的view
                [self.imagePickerVC dismissViewControllerAnimated:YES completion:nil];

//                MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
//                hud.labelText = @"头像上传中...";
//                [self.view addSubview:hud];
//                [hud show:YES];
                ImageAlertView *alertView = [[ImageAlertView alloc] initWithFrame:self.view.frame];
                alertView.isHasBtn = NO;
                [alertView viewShowWithImage:[UIImage imageNamed:@"ic_refresh"] message:@"头像上传中..."];
                [self.view addSubview:alertView];
                
//                id paramDic = @{@"userId":[AppInfoManager getUserID]};
                // 为了配合通讯录和消息WebApp获取其他人的头像，将userID改为NotesID
                id paramDic = @{@"notesId":[AppInfoManager getUserName]};
                [CIBFileOperationManager uploadFileAtPath:iconDir withURI:@"face" andParameter:paramDic success:^(NSString *responseCode, NSString *responseInfo) {
                    [alertView removeFromSuperview];// 隐藏菊花
                    self.userIconRelativeURL = responseInfo;
                    // 更新显示的头像
                    [self.settingTableView reloadData];
                    
                    //更新本地消息存储的用户信息
//                    [self updateLocalmessageInfo];
                    [self performSelector:@selector(updateLocalmessageInfo) withObject:nil afterDelay:3.0];
                } failure:^(NSString *responseCode, NSString *responseInfo) {
                    [alertView removeFromSuperview];// 隐藏菊花
                    // 提示上传失败
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"头像上传失败" message:responseInfo  delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//                    alertView.tag = 8503;
                    [alertView show];
                } progress:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
                    
                }];
            }
        }
        else {
            //提示上传失败（其实是存储失败）
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message: @"抱歉，头像上传失败" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//            alertView.tag = 8503;
            [alertView show];
        }
    }
}
-(void) updateLocalmessageInfo{
    Chatter* fromUser =[[ChatDBManager sharedDatabaseManager] queryContactor:[AppInfoManager getUserName]];
    //已经保存了才更新本地
    if(fromUser){
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            NSDictionary *param = [NSDictionary dictionaryWithObject:[AppInfoManager getUserName] forKey:@"notesid"];
            [CIBRequestOperationManager invokeAPI:@"contactsguiv2" byMethod:@"POST" withParameters:param onRequestSucceeded:^(NSString *responseCode, NSString *responseInfo) {
                if([responseCode isEqualToString:@"I00"]){
                    NSDictionary* resourceInfo = (NSDictionary*)responseInfo;
                    if([[resourceInfo objectForKey:@"resultCode"] isEqualToString:@"0"]){
                        NSArray* userInfo = [resourceInfo objectForKey:@"result"];
                        [self performSelectorOnMainThread:@selector(refreshData:) withObject:userInfo[0] waitUntilDone:NO];
                    }
                }
            } onRequestFailed:^(NSString *responseCode, NSString *responseInfo) {
                NSLog(@"获取个人详情失败。。。。%@",responseInfo);
            }];
        });
    }
}

-(void) refreshData:(NSDictionary*) data{
    //更新本地保存得个人信息
    //获取本地保存的 头像
    NSString *requestIconPath = [data objectForKey:@"PICSTRING"];
    NSString* userName =[data objectForKey:@"USERNAME"];
    
    Chatter* fromUser =[[ChatDBManager sharedDatabaseManager] queryContactor:[AppInfoManager getUserName]];
    if(requestIconPath==nil || [requestIconPath isKindOfClass:[NSNull class]] ){
        return;
    }
    bool iconPathR =[requestIconPath isEqualToString:fromUser.iconPath];
    bool ur =[userName isEqualToString:fromUser.chatterName];
    if(![requestIconPath isEqualToString:fromUser.iconPath] || ![userName isEqualToString:fromUser.chatterName]){
        [[ChatDBManager sharedDatabaseManager] updateContactor:[AppInfoManager getUserName] name:userName iconPath:requestIconPath];
    }
}

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

- (void)cleanCacheFile {
    
//    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
//    [self.view addSubview:hud];
//    hud.labelText = @"正在清除缓存...";
//    [hud show:YES];
    ImageAlertView *alertView = [[ImageAlertView alloc] initWithFrame:self.view.frame];
    alertView.isHasBtn = NO;
    [alertView viewShowWithImage:[UIImage imageNamed:@"ic_refresh"] message:@"正在清除缓存..."];
    [self.view addSubview:alertView];
    
    // 清除WebApp缓存
    NSString *cacheDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSArray *cacheFilePaths = [[NSFileManager defaultManager] subpathsAtPath:cacheDir];
    for (NSString *cachePath in cacheFilePaths) {
        NSString *fullPath = [NSString stringWithFormat:@"%@/%@", cacheDir, cachePath];
        [Function deleteFileAtPath:fullPath];
    }
    // 重置资源文件的更新时间
    CoreDataManager *cdManager = [[CoreDataManager alloc] init];
    [cdManager resetUpdateTimeByName:@"ResourceFileUpdate"];
    
    //清楚本地数据库的信息
    [[ChatDBManager sharedDatabaseManager] deleteAllContactor];
    [[ChatDBManager sharedDatabaseManager] deleteAllMessage];
    [[ChatDBManager sharedDatabaseManager] deleteAllNewestMessage];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [alertView removeFromSuperview];
        [self.settingTableView reloadData];
    });
}

//单个文件的大小
- (long long)fileSizeAtPath:(NSString*) filePath{
    NSFileManager* manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:filePath]){
        return [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
    }
    return 0;
}

//遍历文件夹获得文件夹大小，返回多少M
- (float)folderSizeAtPath:(NSString*) folderPath{
    NSFileManager* manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:folderPath]) return 0;
    NSEnumerator *childFilesEnumerator = [[manager subpathsAtPath:folderPath] objectEnumerator];
    NSString* fileName;
    long long folderSize = 0;
    while ((fileName = [childFilesEnumerator nextObject]) != nil){
        NSString* fileAbsolutePath = [folderPath stringByAppendingPathComponent:fileName];
        folderSize += [self fileSizeAtPath:fileAbsolutePath];
    }
    return folderSize/(1024.0*1024.0);
}

- (NSString *)getCacheFileSize {
    NSString *cacheDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    float cacheSize = [self folderSizeAtPath:cacheDir];
    if (cacheSize >= 0.1f) {
        return [NSString stringWithFormat:@"%.1f M", cacheSize];
    }
    else {
        return @"无缓存";
    }
}

- (void)openWbg {
    NSString *urlOfWbg = @"wxf2c0c83042d0b222://";
    
    NSURL *url  = [NSURL URLWithString:urlOfWbg];
    
    NSURL *downloadUrl = [NSURL URLWithString:@"https://dly.cib.com.cn:26062/wbg.html"];
    
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
    }
    
    else {
        [[UIApplication sharedApplication] openURL:downloadUrl];
    }

}

@end
