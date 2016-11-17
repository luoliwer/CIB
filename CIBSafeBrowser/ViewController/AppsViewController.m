//
//  SecondViewController.m
//  CIBSafeBrowser
//
//  Created by cib on 14/12/4.
//  Copyright (c) 2014年 cib. All rights reserved.
//

#import "AppsViewController.h"

#import "CommonNavViewController.h"
#import "MainViewController.h"
#import "CustomWebViewController.h"
#import "LoginViewController.h"

#import "AppDelegate.h"
#import "AppProduct.h"
#import "AppCell.h"

#import "CoreDataManager.h"
#import "MyUtils.h"
#import "Config.h"

#import "UIImageView+WebCache.h"
#import "MBProgressHUD.h"
#import "ImageAlertView.h"
#import "MyUtils.h"

#import <CIBBaseSDK/CIBBaseSDK.h>

@interface AppsViewController ()
{
    NSMutableArray *appList;
    CGSize cellSize;
    int oldWidth;
}

@property (strong, nonatomic) IBOutlet UICollectionView *appsCollectionView;

- (IBAction)refreshBtnPress:(id)sender;  // 响应刷新按钮
- (IBAction)backBtnPress:(id)sender;  // 响应取消按钮

@end

@implementation AppsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initCellSize];
    [self loadData];
}

// 根据屏幕宽度初始化cell大小
- (void)initCellSize {
    CGFloat screenWidth = self.appsCollectionView.frame.size.width;
    
    int i = 3;  // 没排至少3个
    CGFloat cellWidth, tmp;
    cellWidth = tmp = screenWidth / i++;
    while (YES) {
        tmp = screenWidth / i++;
        if (tmp < 140 || i > 7) {
            break;
        }
        cellWidth = tmp;
    }
    
    cellSize = CGSizeMake(cellWidth, cellWidth);
}

// Dispose of any resources that can be recreated.
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // 宽度发生变化时重新计算计算
    if ((int)self.appsCollectionView.frame.size.width != oldWidth) {
        oldWidth = self.appsCollectionView.frame.size.width;
        [self initCellSize];
        [self.appsCollectionView reloadData];
    }
    // 列表为空，主动刷新一下
    if (appList == nil || [appList count] == 0) {
        [self refreshBtnPress:nil];
    }
}

// 是否支持转屏
- (BOOL)shouldAutorotate {
    return YES;
}

// 支持的屏幕方向，此处可直接返回 UIInterfaceOrientationMask 类型，也可以返回多个 UIInterfaceOrientationMask 取或运算后的值
// 除浏览器界面外，手机只支持 UIInterfaceOrientationMaskPortrait，平板支持 UIInterfaceOrientationMaskAll
- (NSUInteger)supportedInterfaceOrientations {
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {  // ipad
        return UIInterfaceOrientationMaskAll;
    }
    else {  // iPhone&iPod
        return UIInterfaceOrientationMaskPortrait;
    }
}

// 旋转后的处理
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    
    // 宽度发生变化，重新计算
    [self initCellSize];
    [self.appsCollectionView reloadData];
}

#pragma mark -- collection view data source

// item数
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [appList count];
}

// 加载item
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"AppPrototypeCell";
    AppCell *cell = (AppCell *) [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // 加载数据
    AppProduct *app = appList[indexPath.row];
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    UIImage* image = [[manager imageCache] imageFromMemoryCacheForKey:app.appIconUrl];
    if (image) {
        cell.icon.image = image;
    }
    else {
        [cell.icon sd_setImageWithURL:[NSURL URLWithString:app.appIconUrl] placeholderImage:[UIImage imageNamed:@"defalutIcon"]];
    }
    cell.name.text = app.appShowName;
    
    // 边框
    cell.layer.borderWidth = 1.0;
    cell.layer.borderColor = [UIColor colorWithRed:0.96 green:0.96 blue:0.96 alpha:1.0].CGColor;
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return cellSize;
}

#pragma mark -- UICollectionViewDelegate
/*  点击事件的处理顺序如下：
    手指按下
    shouldHighlightItemAtIndexPath (如果返回YES则向下执行，否则执行到这里为止)
    didHighlightItemAtIndexPath (高亮)
    手指松开
    didUnhighlightItemAtIndexPath (取消高亮)
    shouldSelectItemAtIndexPath (如果返回YES则向下执行，否则执行到这里为止)
    didSelectItemAtIndexPath (执行选择事件)
 */
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    // icon半透明
    AppCell* cell = (AppCell *) [collectionView cellForItemAtIndexPath:indexPath];
    [cell.icon setAlpha:0.5f];
    [cell.name setAlpha:0.5f];
}

- (void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    AppCell* cell = (AppCell *) [collectionView cellForItemAtIndexPath:indexPath];
    [cell.icon setAlpha:1.0f];
    [cell.name setAlpha:1.0f];
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (![MyUtils isNetworkAvailableInView:self.view]) {
        return;
    }
    
    AppProduct *app = appList[indexPath.row];
    NSString *appIndexUrl = app.appIndexUrl;
    [MyUtils openUrl:appIndexUrl ofApp:app];
}

//// In a storyboard-based application, you will often want to do a little preparation before navigation
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    // Get the new view controller using [segue destinationViewController].
//    // Pass the selected object to the new view controller.
//}

// 刷新按钮的点击事件
- (IBAction)refreshBtnPress:(id)sender {
    if (![MyUtils isNetworkAvailableInView:self.view]) {
        return;
    }
    
    id paramDic = @{@"type": @"ALL",
                    @"userId":[NSString stringWithFormat:@"%@", [AppInfoManager getUserID]]};
    NSString *URI = @"getWebAppList";
    
    // 菊花
//    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
//    [self.view addSubview:hud];
//    hud.labelText = @"正在刷新...";
//    [hud show:YES];
    ImageAlertView *alertView = [[ImageAlertView alloc] initWithFrame:self.view.frame];
    alertView.isHasBtn = NO;
    [alertView viewShowWithImage:[UIImage imageNamed:@"ic_refresh"] message:@"正在刷新..."];
    [self.view addSubview:alertView];

    
    // 请求成功的回调函数
    void(^succeededBlock)(NSString *, NSString *) = ^(NSString *responseCode, NSString *responseInfo) {
        
        if ([responseCode isEqualToString:@"0"] || [responseCode isEqualToString:@"I00"]) {
            CIBLog(@"getWebAppList succeeded, info = %@", responseInfo);
            // 标记一下此时设备已经激活，可以打开WebApp
            [AppDelegate delegate].isActive = YES;
            
            CoreDataManager *cdManager = [[CoreDataManager alloc] init];
            if (responseInfo != nil && [responseInfo isKindOfClass:[NSArray class]]) {
                
                NSMutableArray *apps = [[NSMutableArray alloc] init];
                NSArray *infoArray = (NSArray *)responseInfo;
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
                            if ([item.appName isEqualToString:app.appName]) {
                                app.isFavorite = item.isFavorite;
//                                if ([app.type isEqualToString:@"FIXED"]) {
//                                    app.favoriteTimeStamp = [NSNumber numberWithDouble:0.0];
//                                } else {
                                    app.favoriteTimeStamp = item.favoriteTimeStamp;
//                                }
                                app.notiNo = item.notiNo;
                                break;
                            }
                        }
                        
                        [apps addObject:app];
                    }
                    
                    // 存入数据库
                    [cdManager insertAppInfos:apps];
                    
                    // 更新明文临时变量为空 需要重新从数据库中读取
                    [[AppDelegate delegate] setAppProductList:apps];
                    
                }
            }
            
            // 更新获取列表时间
            [cdManager updateUpdateTimeByName:@"AppList"];
            
            // 更新界面
            [alertView removeFromSuperview];
            // 更新UI
            [self loadData];
            [self.appsCollectionView reloadData];
        }
        else { // TODO: 理论上市不用管alert的，而是转向其它操作
            CIBLog(@"getWebAppList failed ,code = %@, info = %@", responseCode, responseInfo);
            [alertView removeFromSuperview];
            
            if ([responseCode isEqualToString:@"003"]) { // session未建立
                
            }
            else {
                [MyUtils showAlertWithTitle:responseInfo message:nil];
            }
        }
    };
    
    // 请求失败的回调函数
    void(^failedBlock)(NSString *, NSString *) = ^(NSString *responseCode, NSString *responseInfo) {
        CIBLog(@"failed cause %@", responseInfo);
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
                loginVC.dismissWhenSucceeded = YES;
                loginVC.loginSucceededBlock = ^(){};
                [self presentViewController:loginVC animated:YES completion:nil];
            });
        }
        else {
            [MyUtils showAlertWithTitle:responseInfo message:nil];
        }
    };
    
    // 发起网络请求
    [CIBRequestOperationManager invokeAPI:URI
                                 byMethod:@"POST"
                           withParameters:paramDic
                       onRequestSucceeded:succeededBlock
                          onRequestFailed:failedBlock];
}

// 响应取消按钮
- (IBAction)backBtnPress:(id)sender {
    /*
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    MainViewController *mainVC = [story instantiateViewControllerWithIdentifier:@"main"];
     */
}

#pragma mark -- custom

- (void)loadData {
//    CoreDataManager *cdManager = [[CoreDataManager alloc] init];
//    appList = [[NSMutableArray alloc]initWithArray:[cdManager getAppList]];
    appList = [[NSMutableArray alloc] initWithArray:[[AppDelegate delegate] getAppProductList]];
    
    if (appList == nil) {
        appList = [[NSMutableArray alloc] init];
    }
}

@end
