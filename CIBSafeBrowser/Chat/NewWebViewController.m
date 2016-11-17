//
//  NewWebViewController.m
//  CIBSafeBrowser
//
//  Created by 陈宇劢 on 16/2/26.
//  Copyright © 2016年 cib. All rights reserved.
//

#import "NewWebViewController.h"
#import "CustomWebViewController.h"

#import "EventMoble.h"
#import "AppDelegate.h"
#import "MainViewController.h"
#import "CustomStatusBar.h"

#import "MyUtils.h"
#import "CoreDataManager.h"
#import "Config.h"
#import "CIBURLProtocol.h"
#import "CIBHttpsRequset.h"
#import "MyUtils.h"
#import "CIBURLCache.h"
#import "FileInfo.h"

#import "SearchViewController.h"
#import "WebViewJavascriptBridge.h"
#import "MBProgressHUD.h"
#import "ReminderUtils.h"

#import <CIBBaseSDK/CIBBaseSDK.h>

#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import <JavaScriptCore/JavaScriptCore.h>

#import "DatabaseManageHelper.h"
#import "JSSendMessageManager.h"

@interface NewWebViewController () <UIWebViewDelegate> {
    MBProgressHUD *HUD;
}

@property WebViewJavascriptBridge *bridge;

@end



@implementation NewWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [AppDelegate delegate].newsDetailController=self;
    // Do any additional setup after loading the view from its nib.
    [WebViewJavascriptBridge enableLogging];
    self.bridge = [WebViewJavascriptBridge bridgeForWebView:_webView webViewDelegate:self handler:^(id data, NSArray * responseCallbackArray) {
        
        CIBLog(@"Method: %@", data);
        
        if ([data isKindOfClass:[NSArray class]]) {
            if ([[data objectAtIndex:0] isEqualToString:@"invokeApi"])
            {
                NSString *uri = [data objectAtIndex:1];
                NSString *method = [data objectAtIndex:2];
                id parameters = [data objectAtIndex:3];
                
                if ([parameters isKindOfClass:[NSString class]]) {
                    //                        NSData *paramData = [parameters dataUsingEncoding:NSUTF8StringEncoding];
                    //                        id result = [NSJSONSerialization JSONObjectWithData:paramData options:NSJSONReadingMutableContainers error:nil];
                    //                        parameters = result;
                }
                
                WVJBResponseCallback successCallback = responseCallbackArray[0];
                WVJBResponseCallback failureCallback = responseCallbackArray[1];
                
                if (successCallback && failureCallback) {
                    [CIBRequestOperationManager invokeAPI:uri byMethod:method withParameters:parameters onRequestSucceeded:^(NSString *responseCode, NSString *responseInfo) {
                        // responseInfo的类型可能为NSString* 或者  NSDictionary *，处理有所不同
                        if ([responseInfo isKindOfClass:[NSString class]]) {
                            NSString *responseString = [NSString stringWithFormat:@"{\"flag\":\"%@\",\"info\":%@}", responseCode, responseInfo];
                            successCallback(responseString);
                        }
                        else if ([responseInfo isKindOfClass:[NSDictionary class]]) {
                            id response = @{@"flag":responseCode,@"info":responseInfo};
                            
                            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:response options:NSJSONWritingPrettyPrinted error:nil];
                            
                            NSString *responseString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                            successCallback(responseString);
                        }
                    } onRequestFailed:^(NSString *responseCode, NSString *responseInfo) {
                        // 失败
                        id response = @{@"flag":responseCode,@"info":responseInfo};
                        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:response options:NSJSONWritingPrettyPrinted error:nil];
                        
                        NSString *responseString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                        failureCallback(responseString);
                    }];
                }
            }
        }
    }];
//    _url = [Function encodeToPercentEscapeString:_url];
    _url = [_url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:_url];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];  // 显示状态栏网络活动标志
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)back:(id)sender {
//    [self.navigationController popViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:^{
        [AppDelegate delegate].newsDetailController=nil;
    }];
}

- (void)openApp:(id)sender {
    
    if (!_appNo) {
        NSLog(@"未找到分享的app");
        if (currentOSVersion >= 9.0) {
            UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"未找到分享的应用" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            
            [alertVc addAction:cancel];
            [self presentViewController:alertVc animated:YES completion:nil];
        }
        else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"未找到分享的应用" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
        }
        return;
    }
    
    AppProduct *destinationApp = [[[CoreDataManager alloc] init] getAppProductByAppNo:[NSNumber numberWithInt:[_appNo intValue]]];
    
    NSString *appIndexUrl = destinationApp.appIndexUrl;
    [MyUtils openUrl:appIndexUrl ofApp:destinationApp];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    // 加载进度条
    if (!HUD) {
        HUD = [MBProgressHUD showHUDAddedTo:self.webView animated:YES];
    }
}

-(void)webViewDidFinishLoad:(UIWebView *)webView {
    NSString *embedInJS =  @"if(!window.WebViewJavascriptBridge){document.addEventListener('WebViewJavascriptBridgeReady',null,false)};if(window.WebViewJavascriptBridge){window.WebViewJavascriptBridge.init();function invoke(uri, method, param, success, failure) {window.WebViewJavascriptBridge.send(['invokeApi',uri,method,param],[success,failure])}WebApp={invoke:invoke}}" ;
    
    [webView stringByEvaluatingJavaScriptFromString:embedInJS];
    
    // 移除进度条
    if (HUD) {
        [HUD removeFromSuperview];
        HUD = nil;
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    NSString *embedInJS =  @"if(!window.WebViewJavascriptBridge){document.addEventListener('WebViewJavascriptBridgeReady',null,false)};if(window.WebViewJavascriptBridge){window.WebViewJavascriptBridge.init();function invoke(uri, method, param, success, failure) {window.WebViewJavascriptBridge.send(['invokeApi',uri,method,param],[success,failure])}WebApp={invoke:invoke}}" ;
    [webView stringByEvaluatingJavaScriptFromString:embedInJS];
    
    // 移除进度条
    if (HUD) {
        [HUD removeFromSuperview];
        HUD = nil;
    }
}

@end
