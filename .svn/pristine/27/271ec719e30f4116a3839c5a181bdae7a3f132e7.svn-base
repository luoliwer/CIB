//
//  CollectionFootView.m
//  CIBSafeBrowser
//
//  Created by wangzw on 16/1/4.
//  Copyright © 2016年 cib. All rights reserved.
//

#import "CollectionFootView.h"

#import "AppDelegate.h"
#import "CustomWebViewController.h"
#import "CommonNavViewController.h"
#import "NewsListController.h"
#import "GlobleData.h"

#import "CoreDataManager.h"
#import "AppProduct.h"
#import "MyUtils.h"
#import "Config.h"

@implementation CollectionFootView
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
    }
    return self;
}

- (IBAction)phoneListPress:(id)sender {
    AppProduct *app =[self appWith:@"通讯录"];
    
    // 判断一下基础的url地址，据此来决定是否将外网地址替换为内网
    NSString *basicUrl = [URLAddressManager getBasicURLAddress];
    if ([basicUrl rangeOfString:@"220.250.30.210"].location == NSNotFound) { // 测试环境内网或生产环境
        app.appIndexUrl = [app.appIndexUrl stringByReplacingOccurrencesOfString:@"220.250.30.210:8052" withString:@"168.3.23.207:7052"];
    }
    else { // 测试环境外网
        app.appIndexUrl = [app.appIndexUrl stringByReplacingOccurrencesOfString:@"168.3.23.207:7052" withString:@"220.250.30.210:8052"];
    }
    
    [self openApp:app];
}
- (IBAction)messagePress:(id)sender {
    
    
    
    
    // 更新未读消息数目及小红点显示
//    [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:kKeyOfUnreadMsgNumber];
//    [[NSNotificationCenter defaultCenter] postNotificationName:kUnreadMsgNumberUpdatedNotification object:nil];
    // 注释上述代码，改为点击消息列表页中的条目后，更新未读消息数目及小红点显示
    
    AppDelegate *appDelegate = [AppDelegate delegate];
    //socket 未连接
    if(!appDelegate.socket.isConnected){
        if([appDelegate.socket.delegate respondsToSelector:@selector(websocketDidDisconnect:error:)]){
            NSError *error=[NSError errorWithDomain:@"" code:50 userInfo:nil];
            [appDelegate.socket.delegate websocketDidDisconnect:appDelegate.socket error:error];
        }
        return;
    }
    UIViewController *controller =  appDelegate.window.rootViewController;
    NewsListController *listController = [[NewsListController alloc] init];
//    UINavigationController *chatNavigationVc = [[UINavigationController alloc] initWithRootViewController:listController];
    CommonNavViewController *chatNavigationVc = [[CommonNavViewController alloc] initWithRootViewController:listController];
    chatNavigationVc.navigationBarHidden = YES;
    [controller presentViewController:chatNavigationVc animated:YES completion:nil];
}
- (IBAction)newsPress:(id)sender {
    AppProduct *app = [self appWith:@"新闻"];
    
    // 判断一下基础的url地址，据此来决定是否将外网地址替换为内网
    NSString *basicUrl = [URLAddressManager getBasicURLAddress];
    if ([basicUrl rangeOfString:@"220.250.30.210"].location == NSNotFound) { // 测试环境内网或生产环境
        app.appIndexUrl = [app.appIndexUrl stringByReplacingOccurrencesOfString:@"220.250.30.210:8052" withString:@"168.3.23.207:7052"];
    }
    else { // 测试环境外网
        app.appIndexUrl = [app.appIndexUrl stringByReplacingOccurrencesOfString:@"168.3.23.207:7052" withString:@"220.250.30.210:8052"];
    }
    
    // 仅用于在生产环境下连接测试环境的新闻
    
#ifdef USING_TEST_ENV_NEWS_QUOTA
    app.appIndexUrl = @"http://220.250.30.210:8052/news/";
#endif

    [self openApp:app];
}

- (AppProduct *)appWith:(NSString *)appShowName
{
    NSArray *appList = [[NSMutableArray alloc]initWithArray:[[AppDelegate delegate] getAppProductList]];
    
    if (appList == nil) {
        appList = [[NSMutableArray alloc] init];
    }
    AppProduct *app = nil;
    for (AppProduct *theApp in appList) {
        if ([theApp.appShowName isEqualToString:appShowName]) {
            app = theApp;
            break;
        }
    }
    
    return app;
}
- (void)openApp:(AppProduct *)app
{
    if ([app.notiNo intValue] > 0) {
        //去除app图标上的推送消息标记，更新数据库中的未读消息数目
        app.notiNo = [NSNumber numberWithInt:0];
        CoreDataManager *cdManager = [[CoreDataManager alloc] init];
        [cdManager updateAppInfo:app];
        
        // 更新明文临时变量为空 需要重新从数据库中读取
        [[AppDelegate delegate] setAppProductList:nil];
        
    }
    
    // 检查网络
    //        if (![MyUtils isNetworkAvailableInView:self.view.superview.superview]) {
    if (![MyUtils isNetworkAvailableInView:self]) {
        return;
    }
    
    NSString *appIndexUrl = app.appIndexUrl;
    [MyUtils openUrl:appIndexUrl ofApp:app];
}


@end
