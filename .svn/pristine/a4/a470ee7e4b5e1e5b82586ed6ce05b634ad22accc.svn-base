//
//  AddToFavorTableViewController.m
//  CIBSafeBrowser
//
//  Created by cib on 14/12/9.
//  Copyright (c) 2014年 cib. All rights reserved.
//

#import "AddToFavorTableViewController.h"

#import "AppDelegate.h"
#import "AppCell.h"
#import "AppProduct.h"
#import "MainViewController.h"
#import "LoginViewController.h"
#import "MBProgressHUD.h"

#import "CoreDataManager.h"
#import "Config.h"
#import "MyUtils.h"
#import "AppFavor.h"

#import "UIImageView+WebCache.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]


@interface AddToFavorTableViewController ()
{
    NSMutableArray *appList;
    CGSize cellSize;
    
    NSInteger oldWidth;
    
    NSMutableArray *changedAppList;
}

@property (strong, nonatomic) IBOutlet UIButton *doneButton;
@property (strong, nonatomic) IBOutlet UIButton *backButton;
- (IBAction)doneButtonPress:(id)sender;
- (IBAction)backButtonPress:(id)sender;

@end

@implementation AddToFavorTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadtableView) name:@"deleteApplication" object:nil];
    if (_refreshHeaderView == nil) {
        EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(100.0f, 0.0f - self.tableView.bounds.size.height, self.view.frame.size.width, self.tableView.bounds.size.height)];
        view.delegate = self;
        [self.tableView addSubview:view];
        _refreshHeaderView = view;
    }
    [self.tableView setSeparatorColor:[UIColor colorWithRed:0.96 green:0.96 blue:0.96 alpha:1.0]];
    self.automaticallyAdjustsScrollViewInsets = NO;

    [self loadData];
    changedAppList = [[NSMutableArray alloc] init];
}


// Dispose of any resources that can be recreated.
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
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

// 屏幕将要旋转时执行的方法
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator NS_AVAILABLE_IOS(8_0){
    [self.tableView reloadData];
    
    
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
//    // 宽度发生变化时重新计算
//    if ((int)self.appCollectionView.frame.size.width != oldWidth) {
//        oldWidth = self.appCollectionView.frame.size.width;
//        [self initCellSize];
//        [self.appCollectionView reloadData];
//    }
}

// 旋转后的处理
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    
    // 宽度发生变化，重新计算
//    [self initCellSize];
//    [self.appCollectionView reloadData];
}
#pragma mark -- tableView data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return appList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"AddToCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
    }else{
        
        // 删除cell中的子对象,刷新覆盖问题
        while ([cell.contentView.subviews lastObject] != nil) {
            [(UIView*)[cell.contentView.subviews lastObject] removeFromSuperview];
        }
    }
    cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    UIImageView *imageView1 = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.origin.x + 12, cell.center.y - 21, 27, 27)];
    imageView1.backgroundColor = [UIColor clearColor];
     [cell addSubview:imageView1];
    UIImageView *imageView2 = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 32, imageView1.center.y - 8.5, 20, 20)];
    imageView2.backgroundColor = [UIColor clearColor];
    [imageView2 setImage:[UIImage imageNamed:@"unselected"]];
    [cell addSubview:imageView2];
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(imageView1.frame.origin.x + 66, imageView1.center.y - 8, 100, 16)];
    label.textAlignment = NSTextAlignmentLeft;
    label.font = [UIFont systemFontOfSize:15];
    [cell addSubview:label];
    
    //加载数据
    AppProduct *app = appList[indexPath.row];

    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    UIImage *image = [[manager imageCache] imageFromMemoryCacheForKey:app.appIconUrl];
    if (image) {
        imageView1.image = image;
    }
    else {
        [imageView1 sd_setImageWithURL:[NSURL URLWithString:app.appIconUrl] placeholderImage:[UIImage imageNamed:@"defalutIcon"]];
    }
    label.text = app.appShowName;
//    label.textColor = app.isFavorite ? kUIColorLight : [UIColor blackColor];
    imageView2.image = app.isFavorite ? [UIImage imageNamed:@"selected"] :[UIImage imageNamed:@"unselected"];

    return cell;
}
#pragma mark -- UITableViewDelegate


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 改变收藏状态
    AppProduct *app = appList[indexPath.row];
    app.isFavorite = !app.isFavorite;
    
    // 刷新列表项
    [tableView reloadData];
    
    // 将收藏状态改变的app加入列表
    for (AppProduct *changedApp in changedAppList) {
        if (changedApp.appNo == app.appNo) {
            //            changedApp.isFavorite = !changedApp.isFavorite;
            return;
        }
    }
    [changedAppList addObject:app];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if (sender == self.doneButton) {  // 只处理完成按钮
        //测试，暂时不过滤NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isFavorite==YES"];
        //测试，暂时不过滤[self updateAppInfo:[appList filteredArrayUsingPredicate:predicate]];
//        [self updateAppInfo:appList];
        [self updateAppInfo:changedAppList];
    }
    else if (sender == self.backButton)
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark -- custom

- (void)loadData {
//    CoreDataManager *cdManager = [[CoreDataManager alloc] init];
//    appList = [[NSMutableArray alloc]initWithArray:[cdManager getAppList]];
    appList = [[NSMutableArray alloc]initWithArray:[[AppDelegate delegate] getAppProductList]];

    if (appList == nil) {
        appList = [[NSMutableArray alloc] init];
    }
    
    //测试，暂时不过滤NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isFavorite==NO"];
    //测试，暂时不过滤[appList filterUsingPredicate:predicate];
    // 过滤掉app类型属于置顶类型的app
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        if ([evaluatedObject isKindOfClass:[AppProduct class]]) {
            AppProduct *product = (AppProduct *)evaluatedObject;
            if ([[product type] isEqualToString:@"FIXED"]) {
                return NO;
            }
        }
        return YES;
    }];
    [appList filterUsingPredicate:predicate];
}

- (void)updateAppInfo:(NSArray *)favAppList {

    CoreDataManager *cdManager = [[CoreDataManager alloc] init];
    NSArray* favorArray = [cdManager getAppFavorList];
    int lastSortIndex = 0;
    if([favorArray count]>0){
        lastSortIndex=[((AppFavor*)[favorArray objectAtIndex:[favorArray count]-1]).sortIndex intValue];
    }
    int index = 1;
    for (AppProduct *app in favAppList) {
        //删除或插入 appFavor（本地数据库表） 数据
        if(app.isFavorite){
            app.sortIndex=lastSortIndex+index;//排序号
            index++;
            [cdManager insertAppFavorWithAppName:app.appName sortIndex:app.sortIndex];
        }else{
            [cdManager deleteAppFavor:app.appName];
        }
        
        [cdManager updateAppInfo:app];
        
    }
    
    // 更新明文临时变量为空 需要重新从数据库中读取
    [[AppDelegate delegate] setAppProductList:nil];
}

- (void)reloadTableViewDataSource{
    _reloading = YES;
    
    //开始刷新后执行后台线程，在此之前可以开启HUD或其他对UI进行阻塞
    [NSThread detachNewThreadSelector:@selector(doInBackground) toTarget:self withObject:nil];
    
}
- (void)doneLoadingTableViewData{    
    _reloading = NO;
    [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
    //刷新表格内容
    [self.tableView reloadData];
}

-(void)doInBackground{
    if (![MyUtils isNetworkAvailableInView:self.view]) {
        return;
    }
    
    id paramDic = @{@"type": @"ALL",
                    @"userId":[NSString stringWithFormat:@"%@", [AppInfoManager getUserID]]};
    NSString *URI = @"getWebAppList";
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
                    //后台操作线程执行完后，到主线程更新UI
                    NSLog(@"成功");
                    [self performSelectorOnMainThread:@selector(doneLoadingTableViewData) withObject:nil waitUntilDone:YES];
                    
                }
            }
            
            // 更新获取列表时间
            [cdManager updateUpdateTimeByName:@"AppList"];
        }else { // TODO: 理论上是不用管alert的，而是转向其它操作
            CIBLog(@"getWebAppList failed ,code = %@, info = %@", responseCode, responseInfo);

            
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
            NSString *failureStr = [NSString stringWithFormat:@"刷新失败，%@",responseInfo];
            [self showAlertViewTitle:failureStr andMessage:nil];
            // 标记一下此时设备未激活                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   ，不能打开WebApp
            [AppDelegate delegate].isActive = NO;
        }
        // 用户名密码N天未验证
        else if ([responseCode isEqualToString:@"18"]) {
            [self showAlertViewTitle:responseInfo andMessage:nil];
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
            [self showAlertViewTitle:responseInfo andMessage:nil];
        }
        NSLog(@"失败");
    };
    
    // 发起网络请求
    [CIBRequestOperationManager invokeAPI:URI
                                 byMethod:@"POST"
                           withParameters:paramDic
                       onRequestSucceeded:succeededBlock
                          onRequestFailed:failedBlock];
    
    
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
- (BOOL)isSystemVersionBelowEight {
    return ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0f);
}


#pragma mark UIScrollViewDelegate Methods
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    
    [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}

#pragma mark EGORefreshTableHeaderDelegate Methods
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
    
    [self reloadTableViewDataSource];
    [self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:3.0];
}
- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{

    return _reloading;
}
- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
    return [NSDate date];
}

- (IBAction)doneButtonPress:(id)sender {
    [self updateAppInfo:changedAppList];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"appChangeDone" object:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)backButtonPress:(id)sender {
    for (AppProduct *appPro in changedAppList) {
        appPro.isFavorite = !appPro.isFavorite;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"appChangeDone" object:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)reloadtableView{
    
}
@end
