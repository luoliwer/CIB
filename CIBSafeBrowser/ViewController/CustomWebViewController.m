//
//  CustomWebViewController.m
//  CIBSafeBrowser
//
//  Created by cib on 14/12/9.
//  Copyright (c) 2014年 cib. All rights reserved.
//

#import "CustomWebViewController.h"

#import "EventMoble.h"
#import "TabsViewController.h"
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

#import "OpenChatController.h"
#import "MyUtils.h"

#import "ViewPhotoController.h"
#import "PhotoEventHandleUtils.h"
#import "FileHandleController.h"
#import "LoginViewController.h"
static NSString *beginDownloadNoti   = @"beginDownloadNotification";
static NSString *successDownloadNoti = @"successDownloadNotification";
static NSString *failureDownloadNoti = @"failureDownloadNotification";



@interface CustomWebViewController () <UIWebViewDelegate, UIGestureRecognizerDelegate, UIAlertViewDelegate,ABNewPersonViewControllerDelegate, ABPeoplePickerNavigationControllerDelegate>
{
    UISwipeGestureRecognizer *swipeGestureUp;  // 上滑隐藏toolbar
    UISwipeGestureRecognizer *swipeGestureDown;  // 下滑显示toolbar
    
    MBProgressHUD *HUD;  // 菊花等
    CustomStatusBar *_customStatusBar;
    NSString *teleNumber; // 可能出现的电话号码
    NSString *fileNa; //下载文件的文件名
    
    NSString *_notesId;
}

@property WebViewJavascriptBridge *bridge;
@property (strong, nonatomic) NSThread *webThread; // webView所占用的线程，通过UIWebView调用Js代码需在此线程进行。

@property (strong, nonatomic) IBOutlet UIToolbar *toolbar;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *backwardButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *forwardButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *refreshButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *homeButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *tabButton;

@property(nonatomic, assign) BOOL isManualStop;  // 是否手动停止，用于手动停止时取消警告

- (IBAction)backwardBtnPress:(id)sender;
- (IBAction)forwardBtnPress:(id)sender;
- (IBAction)refreshBtnPress:(id)sender;
- (IBAction)homeBtnPress:(id)sender;
- (IBAction)tabBtnPress:(id)sender;

@end

@implementation CustomWebViewController

@synthesize requestType;
@synthesize requestURL;
@synthesize localFile;
@synthesize pageTitle;
@synthesize appno;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //    if ([requestType intValue] != CWRequestTypeLocalFile) {
    //        // cache生命期，生产使用一个月，目前测试使用一天
    //        long cacheTime = [[MyUtils propertyOfResource:@"Setting" forKey:@"CacheExpire"] longValue];
    //        CIBURLCache *urlCache = [[CIBURLCache alloc] initWithMemoryCapacity:20 * 1024 * 1024
    //                                                               diskCapacity:200 * 1024 * 1024
    //                                                                   diskPath:nil
    //                                                                  cacheTime:cacheTime];
    //        // 此处为消息应用地址，请注意，特例
    //        if ([self.requestURL isEqualToString:@"http://220.250.30.210:7555/chat"]) {
    //            NSMutableArray *blackList = [[NSMutableArray alloc] initWithObjects:[self combineParaForUrl:self.requestURL], nil];
    //            [urlCache setBlackList:blackList];
    //        }
    //        [CIBURLCache setSharedURLCache:urlCache];
    //    }
    
    // 为webview增加上下滑动手势，用于隐藏、显示toolbar
    //    swipeGestureUp = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleWebviewSwipeUp:)];
    //    swipeGestureUp.direction = UISwipeGestureRecognizerDirectionUp;
    //    swipeGestureUp.delegate = self;
    //    swipeGestureDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleWebviewSwipeDown:)];
    //    swipeGestureDown.direction = UISwipeGestureRecognizerDirectionDown;
    //    swipeGestureDown.delegate = self;
    //    [self.webview addGestureRecognizer:swipeGestureUp];
    //    [self.webview addGestureRecognizer:swipeGestureDown];
    _notesId = [AppInfoManager getValueForKey:kKeyOfUserName];
    if ([requestType intValue] == CWRequestTypeWebApp) {  // 请求加载的是webapp
        NSURL *reqURL = [NSURL URLWithString:[self combineParaForUrl:self.requestURL]];
        NSURLRequest *request = [NSURLRequest requestWithURL:reqURL];
        [self.webview loadRequest:request];
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];  // 显示状态栏网络活动标志
    }
    else if ([requestType intValue] == CWRequestTypeLocalFile) {  // 请求加载的是本地文件
        [self.refreshButton setEnabled:NO];
        self.requestURL = localFile.fileAlias;
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentDir = [paths objectAtIndex:0];
        NSString *filePath = [documentDir stringByAppendingPathComponent:localFile.fileAlias];
        
        NSData *fileData = [NSData dataWithContentsOfFile:filePath];
        NSData *decryptData  = [[[CryptoManager alloc] init] decryptData:fileData];
        [self.webview loadData:decryptData MIMEType:localFile.mimeType textEncodingName:@"GBK" baseURL:nil];
    }
    else {  //  请求加载的是其它内容，如测试网页等
        NSURL *reqURL = nil;
        if (self.appno == kAppNoOfSearchedUser) {
            reqURL = [NSURL URLWithString:[self combineContactUserParamForURL:self.requestURL]];
        }
        else {
            reqURL = [NSURL URLWithString:requestURL];
        }
        
        NSURLRequest *request = [NSURLRequest requestWithURL:reqURL];
        [self.webview loadRequest:request];
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];  // 显示状态栏网络活动标志
    }
    
#ifdef CIBDEBUG
    [WebViewJavascriptBridge enableLogging];
#endif
    //响应JS通过send发送给OC的消息（通过bridge主要是异步调用）
    
    self.bridge = [WebViewJavascriptBridge bridgeForWebView:self.webview webViewDelegate:self handler:^(id data, NSArray * responseCallbackArray) {
        
        CIBLog(@"Method: %@", data);
        
        if ([data isKindOfClass:[NSString class]]) {
            if (responseCallbackArray && [data isEqualToString:@"getLoginInfo"]) {
                
                WVJBResponseCallback responseCallback = responseCallbackArray[0];
                if (responseCallback) {
                    NSString *userToken = [AppInfoManager getValueForKey:kKeyOfUserToken forApp:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"]];
                    NSString *deviceId = [AppInfoManager getDeviceID];
                    NSString *userId = [AppInfoManager getUserID];
                    NSString *userName = [AppInfoManager getUserName];
                    NSString *orgId = [AppInfoManager getValueForKey:kKeyOfOrgID];
                    id retDic = @{@"flag":@"0",
                                  @"info":@{@"usertoken":userToken,
                                            @"deviceid":deviceId,
                                            @"userid":userId,
                                            @"notesid":userName,
                                            @"orgid":orgId}};
                    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:retDic options:NSJSONWritingPrettyPrinted error:nil];
                    NSString *retString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                    responseCallback(retString);
                }
                
            }
            else if (responseCallbackArray && [data isEqualToString:@"resetToken"]) {
                
                WVJBResponseCallback responseCallback = responseCallbackArray[0];
                if (responseCallback) {
                    [AppInfoManager resetUserToken:^(NSString *response) {
                        responseCallback(response);
                    }];
                }
            }
        }
        else if ([data isKindOfClass:[NSArray class]]) {
            if (responseCallbackArray) {
                if ([[data objectAtIndex:0] isEqualToString:@"openUrl"]) {
                    NSString *url = [data objectAtIndex:1];
                    // 改为通过appName读取具体appNo
                    NSString *appName = [data objectAtIndex:2];
                    
                    CoreDataManager *cdManager = [[CoreDataManager alloc] init];
                    AppProduct *app = [cdManager getAppProductByAppName:appName];
                    NSNumber *appNo = app.appNo;
                    NSString *destinationAppno = [appNo stringValue];
                    AppDelegate *appDelegate = [AppDelegate delegate];
                    // 首先检查一下当前的webview是否在tab中
                    BOOL isCurrentVCInTab = NO;
                    for (CustomWebViewController *vc in appDelegate.tabList) {
                        if ([vc.requestURL isEqualToString:self.requestURL]) {
                            isCurrentVCInTab = YES;
                            break;
                        }
                    }
                    if (!isCurrentVCInTab) {
                        [self addToTabs];
                    }
                    
                    NSString *appIndexUrl = app.appIndexUrl;
                    [MyUtils openUrl:appIndexUrl ofApp:app];
                    
                }
                else if ([[data objectAtIndex:0] isEqualToString:@"addReminder"])
                {
                    NSNumber *alertTime = [data objectAtIndex:1];
                    NSNumber *happenTime = [data objectAtIndex:2];
                    NSNumber *intervalTime = [data objectAtIndex:3];
                    NSString *title = [data objectAtIndex:4];
                    int requestCode = [data objectAtIndex:5];
                    NSString *serialNo = [data objectAtIndex:6];
                    if ([serialNo isEqual:[NSNull null]] || !serialNo) {
                        serialNo = [NSString stringWithFormat:@"%d", requestCode];
                    }
                    NSTimeInterval intervalInSec = (double) [alertTime doubleValue] / 1000.0;
                    [ReminderUtils addReminder:serialNo WithTitle:title atTime:intervalInSec];
                }
                else if ([[data objectAtIndex:0] isEqualToString:@"cancelReminder"])
                {
                    int requestCode = [data objectAtIndex:1];
                    NSString *serialNo = [data objectAtIndex:2];
                    if ([serialNo isEqual:[NSNull null]] || !serialNo) {
                        serialNo = [NSString stringWithFormat:@"%d", requestCode];
                    }
                    [ReminderUtils cancelReminder:serialNo];
                }
                else if ([[data objectAtIndex:0] isEqualToString:@"cancelAllReminder"])
                {
                    [ReminderUtils cancelAllReminders];
                }
                else if ([[data   objectAtIndex:0] isEqualToString:@"showLoading"]) {
                    
                    BOOL isVisible = NO;
                    id indicator = [data objectAtIndex:1];
                    if ([indicator isKindOfClass:[NSString class]]) { // 传进来的是字符串类型
                        if ([indicator isEqualToString:@"true" ] || [indicator isEqualToString:@"1"]) {
                            isVisible = YES;
                        }
                    }
                    else if ([indicator isKindOfClass:[NSNumber class]]) { // 传进来的是数字类型或者布尔类型
                        int t = [indicator intValue];
                        if (t == 1) {
                            isVisible = YES;
                        }
                    }
                    
//                    NSString *msg = [data objectAtIndex:2];
                    id msg = [data objectAtIndex:2];
                    if (!msg || [msg isEqual:[NSNull null]]) {
                        msg = @"加载中";
                    }
                    if (isVisible) {
                        // 加载进度条
                        if (!HUD) {
                            HUD = [MBProgressHUD showHUDAddedTo:self.webview animated:YES];
                            HUD.labelText = msg;
                        }
                    }
                    else {
                        if (HUD) {
                            [HUD removeFromSuperview];
                            HUD = nil;
                        }
                    }
                }
                //拍照
                else if ([[data objectAtIndex:0] isEqualToString:@"takePhoto"]) {
                    WVJBResponseCallback successCallback = responseCallbackArray[0];
                    WVJBResponseCallback failureCallback = responseCallbackArray[1];
                    
                    PhotoEventHandleUtils *utils = [PhotoEventHandleUtils sharedPhotoEventHandleUtils];
                    //判断相机是否可用
                    BOOL avilable = [utils isCameraAvailable];
                    
                    if (YES) {
                        //打开相机
                        [utils openCameraInViewController:self];
                        NSString *appId = [data objectAtIndex:1];
                        if (!appId) {
                            appId = @"";
                        }
                        [[NSUserDefaults standardUserDefaults] setObject:appId forKey:@"PhotoEventHandleUtilsCurrentAppId"];
                        //设置图片压缩宽高
                        NSNumber *height = [data lastObject];
                        NSInteger len = [data count];
                        NSNumber *width = [data objectAtIndex:len-2];
                        utils.pixelWidth = [width floatValue];
                        utils.pixelHeight = [height floatValue];
                        //设置文件保存名字
                        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                        [formatter setDateFormat:@"yyyyMMddHHmmss"];
                        NSString *date = [formatter stringFromDate:[NSDate date]];
                        utils.fileName = [NSString stringWithFormat:@"%@.jpg", date];
                        //拍摄成功返回数据信息
                        utils.takePhotoSuccess = ^(NSString *fileID, NSString *thumbnail){
                            NSDictionary *dic = @{@"fileId":fileID, @"thumbnail":thumbnail};
                            //                        NSError *error = nil;
                            //                        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&error];
                            //                        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                            NSString *jsonString = [self jsonStringWithDictionary:dic];
                            successCallback(jsonString);
                        };
                        
                        //拍摄失败返回数据信息
                        utils.takePhotoFailure = ^(NSString *fileID, NSString *info){
                            NSDictionary *dic = @{@"flag":fileID, @"info":info};
                            //                        NSError *error = nil;
                            //                        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&error];
                            //                        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                            NSString *jsonString = [self jsonStringWithDictionary:dic];
                            failureCallback(jsonString);
                        };
                    } else {//未授权
                        if (currentOSVersion >= 8.0) {
                            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"相机授权" message:@"当前无法使用相机，请前往设置界面打开拍照权限" preferredStyle:UIAlertControllerStyleAlert];
                            
                            
                            UIAlertAction *goAction = [UIAlertAction
                                                       actionWithTitle:@"去设置"
                                                       style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * _Nonnull action) {
                                                           NSURL *url = [NSURL URLWithString:@"prefs:root=Privacy"];
                                                           if ([[UIApplication sharedApplication] canOpenURL:url]) {
                                                               [[UIApplication sharedApplication] openURL:url];
                                                           }
                                                       }];
                            UIAlertAction *cancelAction = [UIAlertAction
                                                       actionWithTitle:@"取消"
                                                       style:UIAlertActionStyleDefault
                                                       handler:nil];
                            
                            [alertController addAction:cancelAction];
                            [alertController addAction:goAction];
                            
                            [self presentViewController:alertController animated:YES completion:nil];
                        } else {
                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"相机授权"
                                                                            message:@"当前无法使用相机，请前往设置界面打开拍照权限"
                                                                           delegate:self
                                                                  cancelButtonTitle:@"取消"
                                                                  otherButtonTitles:@"去设置", nil];
                            alert.tag = 8000;
                            [alert show];
                        }
                    }
                }
                //上传
                else if ([[data objectAtIndex:0] isEqualToString:@"uploadPhotos"]) {
                    if (responseCallbackArray) {
                        WVJBResponseCallback successCallback = responseCallbackArray[0];
                        WVJBResponseCallback failureCallback = responseCallbackArray[1];
                        
                        //获取图片id数组
                        NSArray *files = [data objectAtIndex:1];
                        
                        PhotoEventHandleUtils *utils = [PhotoEventHandleUtils sharedPhotoEventHandleUtils];
                        if (_notesId) {
                            [utils uploadFiles:files noteId:_notesId success:^(NSString *flag, NSString *info) {
//                                NSLog(@"flag---%@ /ninfo---%@", flag, info);
                                NSDictionary *dic = @{@"flag":flag, @"info":info};
                                NSError *error = nil;
                                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&error];
                                NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                                successCallback(jsonString);
                            } failure:^(NSString *flag, NSString *info) {
//                                NSLog(@"flag---%@ /ninfo---%@", flag, info);
                                NSDictionary *dic = @{@"flag":flag, @"info":info};
//                                NSError *error = nil;
//                                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&error];
//                                NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                                NSString *jsonString = [self jsonStringWithDictionary:dic];
                                failureCallback(jsonString);
                            } progress:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
                                
                            }];
                        } else {
                            NSDictionary *dic = @{@"flag":@"-2", @"info":@"用户notesid不存在"};
                            NSString *jsonString = [self jsonStringWithDictionary:dic];
                            failureCallback(jsonString);
                        }
                        
                    }
                }
                //下载
                else if ([[data objectAtIndex:0] isEqualToString:@"viewAuthorizedFile"])
                {
                    HUD = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
                    HUD.labelText = @"开始下载...";
                    NSString *uri = [data objectAtIndex:1];
                    NSString *json = [data objectAtIndex:2];
                    NSData *data = [json dataUsingEncoding:NSUTF8StringEncoding];
                    NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                    //获取沙盒路径
                    NSString *Path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
                    
                    NSString *appId = [AppInfoManager getValueForKey:kKeyOfUserName];
                    //构建文件夹路径
                    NSString *directoryPath = [NSString stringWithFormat:@"%@/%@", Path, appId];
                    NSString *fileId = [NSString stringWithFormat:@"%@.pdf", [jsonDic valueForKey:@"sqwjzj"]];
                    NSString *filePath = [directoryPath stringByAppendingPathComponent:fileId];
                    //判断本地是否存在当前需要下载的文档
                    //判断该文件夹是否存在
                    NSFileManager *manager = [NSFileManager defaultManager];
                    if ([manager fileExistsAtPath:filePath]) {//本地存在
                        FileHandleController *controller = [[FileHandleController alloc] init];
                        controller.pdfPath = filePath;
                        [self presentViewController:controller animated:YES completion:nil];
                        if (HUD) {
                            [HUD removeFromSuperview];
                        }
                    } else {//本地不存在，调下载接口
                        [[PhotoEventHandleUtils sharedPhotoEventHandleUtils] downloadPhotoWithURI:uri parameter:jsonDic success:^(NSString *picString) {
                            //返回成功
                            FileHandleController *controller = [[FileHandleController alloc] init];
                            controller.pdfPath = picString;
                            [self presentViewController:controller animated:YES completion:nil];
                            if (HUD) {
                                [HUD removeFromSuperview];
                            }
                        } failure:^(NSString *flag, NSString *info) {
                            FileHandleController *controller = [[FileHandleController alloc] init];
                            controller.pdfPath = @"";
                            [self presentViewController:controller animated:YES completion:nil];
                            if (HUD) {
                                [HUD removeFromSuperview];
                            }
                        } progress:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
                            CGFloat rate = (float)totalBytesRead / totalBytesExpectedToRead;
                            HUD.labelText = [NSString stringWithFormat:@"已下载%.0f%%", rate * 100];
                        }];
                    }
                }
                else if ([[data objectAtIndex:0] isEqualToString:@"invokeApi"])
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
                            if([responseCode isEqualToString:@"18"]){
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
                                return;
                            }
                            id response = @{@"flag":responseCode,@"info":responseInfo};
                            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:response options:NSJSONWritingPrettyPrinted error:nil];
                            
                            NSString *responseString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                            failureCallback(responseString);
                        }];
                    }
                }
                else if ([[data objectAtIndex:0] isEqualToString:@"downloadFile"])
                {
                    WVJBResponseCallback failureCallback = responseCallbackArray[0];
                    WVJBResponseCallback successCallback = responseCallbackArray[1];
                    WVJBResponseCallback progressCallback = responseCallbackArray[2];
                    
                    NSString *uri = [data objectAtIndex:1];
                    NSString *path = [data objectAtIndex:2];
                    NSString *filePath = [uri stringByAppendingString:path];
                    NSString *fileAlias = [MyUtils MD5Digest:filePath];
                    
                    //准备下载
                    CoreDataManager *coreDataManager = [[CoreDataManager alloc]init];
                    NSArray *fileList = [coreDataManager getFileList];
                    FileDownloadStatus fileStatus = FileUndownload;
                    BOOL isFileExist = NO;
                    for (DownloadFile *file in fileList) {
                        if ([file.fileAlias isEqualToString:fileAlias]) {
                            fileStatus = file.downloadStatus;
                            isFileExist = YES;
                        }
                    }
                    
                    if (fileStatus == FileDownloading) {
                        //弹出该文件正在下载的提示
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                                            message:@"该文件正在下载"
                                                                           delegate:self
                                                                  cancelButtonTitle:@"确定"
                                                                  otherButtonTitles:nil];
                        [alertView show];
                        
                    }else if (fileStatus == FileDownloaded){
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                                        message:@"该文件已经下载"
                                                                       delegate:self
                                                              cancelButtonTitle:@"确定"
                                                              otherButtonTitles:nil];
                        
                        
                        [alert show];
                        
                    }else{
                        DownloadFile *file = [[DownloadFile alloc]init];
                        file.fileAlias = fileAlias;
                        file.downloadStatus = FileUndownload;
                        
                        if (isFileExist) {
                            [coreDataManager updateFileStatusOfFileInfo:file];
                        }else{
                            [coreDataManager insertFileInfo:file];
                        }
                        
                        //构造路径
                        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                        NSString *documentDirectory = [paths objectAtIndex:0];
                        NSString *documentPath = [documentDirectory stringByAppendingPathComponent:fileAlias];
                        
                        id parameter = @{@"path":path};
                        
                        //新开线程进行下载
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                            if (successCallback && failureCallback && progressCallback)
                            {
                                [CIBFileOperationManager downloadFileWithURI:uri andParameter:parameter success:^(NSDictionary *responseHeader, NSData *responseBody) {
                                    //成功下载
                                    
                                    fileNa = [[responseHeader objectForKey:@"fileName"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                                    NSString *fileType = [responseHeader objectForKey:@"Content-type"];
                                    
                                    DownloadFile *file = [[DownloadFile alloc]init];
                                    file.fileAlias = fileAlias;
                                    file.fileName = fileNa;
                                    file.mimeType = fileType;
                                    
                                    NSDate *date = [NSDate date];
                                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
                                    [dateFormatter setDateFormat:@"YYYY-MM-DD HH-mm"];
                                    file.downloadTime = [dateFormatter stringFromDate:date];
                                    
                                    //加密，缓存文件
                                    NSData *cryptFileData = [[[CryptoManager alloc]init]encryptData:responseBody];
                                    if (cryptFileData != nil ) {
                                        NSError *error = nil;
                                        [cryptFileData writeToFile:documentPath options:NSDataWritingAtomic error:&error];
                                        if (error != nil) {
                                            CIBLog(@"Save failed:%@",[error description]);
                                        }
                                    }
                                    
                                    //发送通知
                                    [[NSNotificationCenter defaultCenter] postNotificationName:successDownloadNoti object:fileNa];
                                    
                                    //修改下载状态
                                    file.downloadStatus = FileDownloaded;
                                    
                                    //更新数据库中文件下载状态字段
                                    [coreDataManager updateFileStatusOfFileInfo:file];
                                    
                                    successCallback([NSNull null]);
                                    
                                } failure:^(NSString *responseCode, NSString *responseInfo) {
                                    //下载失败
                                    
                                    id response = @{@"flag":responseCode,@"info":responseInfo};
                                    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:response options:NSJSONWritingPrettyPrinted error:nil];
                                    NSString *responseString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                                    failureCallback(responseString);
                                    
                                    //修改下载状态
                                    file.downloadStatus = FileUndownload;
                                    
                                    //更新数据库中文件下载状态字段
                                    [coreDataManager updateFileStatusOfFileInfo:file];
                                    
                                    //发送通知
                                    [[NSNotificationCenter defaultCenter] postNotificationName:failureDownloadNoti object:fileNa];
                                    
                                } progress:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
                                    
                                    //返回下载进度
                                    float progress = totalBytesRead / (totalBytesExpectedToRead / 1.0);
                                    NSString *progressString = [NSString stringWithFormat:@"%.2f",progress];
                                    progressCallback(progressString);
                                    
                                    //修改下载状态
                                    file.downloadStatus = FileDownloading;
                                    
                                    //更新数据库中文件下载状态字段
                                    [coreDataManager updateFileStatusOfFileInfo:file];
                                    
                                    
                                } header:^(NSDictionary *responseHeader) {
                                    
                                    fileNa = [[responseHeader objectForKey:@"fileName"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ;
                                    
                                    //修改下载状态
                                    file.downloadStatus = FileDownloading;
                                    
                                    //更新数据库中文件下载状态字段
                                    [coreDataManager updateFileStatusOfFileInfo:file];
                                    
                                    //发送通知
                                    [[NSNotificationCenter defaultCenter] postNotificationName:beginDownloadNoti object:fileNa];
                                }];
                            }
                            
                        });
                    }
                    
                }
//                else if ([[data objectAtIndex:0] isEqualToString:@"execSQLite"]){
//                    NSString *sql = [data objectAtIndex:1];
//                    NSLog(@"创建表的SQL语句：%@", sql);
//                }
                else if ([[data objectAtIndex:0] isEqualToString:@"showFile"]){
                    NSString *uri = [data objectAtIndex:1];
                    NSString *path = [data objectAtIndex:2];
                    NSString *filePath = [uri stringByAppendingString:path];
                    NSString *fileAlias = [MyUtils MD5Digest:filePath];
                    
                    CoreDataManager *coreManager = [[CoreDataManager alloc]init];
                    DownloadFile *file =  [coreManager getFileByFileAlias:fileAlias];
                    
                    [MyUtils openFile:file];
                }
            }
        }
    }];
}

- (NSString *)jsonStringWithDictionary:(NSDictionary *)dic
{
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&error];
    if (error) {
        return nil;
    }
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

// Dispose of any resources that can be recreated.
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];  // 状态栏深色
    
    NSArray *tabList = [AppDelegate delegate].tabList;
    int tabCount = (int)tabList.count;
    if (![tabList containsObject:self]) {
        tabCount++;
    }
    tabCount=tabCount>8?8:tabCount;
    
    // 根据tab数切换相应图标
    self.tabButton.image = [UIImage imageNamed:[NSString stringWithFormat:@"tabb%d",tabCount]];
    
    // 注册截屏监测事件，目前iOS尚无法阻止截屏或者监测到截屏前时间，只有截屏后通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidTakeScreenshot) name:UIApplicationUserDidTakeScreenshotNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(successDownLoadNoti:) name:successDownloadNoti object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(beginDownLoadNoti:) name:beginDownloadNoti object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(failureDownLoadNoti:) name:failureDownloadNoti object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver: self selector:@selector(userDidTakeScreenshot) name:UIApplicationUserDidTakeScreenshotNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    //[self.webview stopLoading];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];  // 隐藏状态栏网络活动标志
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];  // 状态栏浅色
    
    // 移除截屏监测
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationUserDidTakeScreenshotNotification object:nil];
}

// 响应点击后退按钮
//- (IBAction)backwardBtnPress:(id)sender {
//    if ([self.webview canGoBack]) {
//        [self.webview goBack];
//        [self.forwardButton setEnabled:YES];  // 能后退就一定能前进
//        
//        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];  // 显示状态栏网络活动标志
//    }
//    else {
//        [self.backwardButton setEnabled:NO];
//    }
//}

// 响应点击前进按钮
//- (IBAction)forwardBtnPress:(id)sender {
//    if ([self.webview canGoForward]) {
//        [self.webview goForward];
//        [self.backwardButton setEnabled:YES];  // 能前进就一定能后退
//        
//        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];  // 显示状态栏网络活动标志
//    }
//    else {
//        [self.forwardButton setEnabled:NO];
//    }
//}

// 响应刷新按钮
- (IBAction)refreshBtnPress:(id)sender {
    //    // 加载或下载中不允许更新
    //    if (HUD) {
    //        return;
    //    }
    
//    if (self.webview.isLoading) {  // loading状态是停止
//        [self.webview stopLoading];
//        self.isManualStop = YES;
//        return;
//    }
    
    [self.webview reload]; // 这个只是刷新当前界面
    
    //    // 因为webview加载的是webapp，刷新时应是重载APP，重新拼加变量是为了获取当前token
    //    NSString *url = self.requestURL;
    //    if ([requestType intValue] == CWRequestTypeWebApp) {
    //        url = [self combineParaForUrl:self.requestURL];
    //    }
    //    NSURL *reqURL = [NSURL URLWithString:url];
    //    NSURLRequest *request = [NSURLRequest requestWithURL:reqURL];
    //    [self.webview loadRequest:request];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];  // 显示状态栏网络活动标志
}

// 响应点击主页(返回)按钮
- (IBAction)homeBtnPress:(id)sender {
    [self addToTabs];  // 添加当前页面到tab
    
    AppDelegate *appDelegate = [AppDelegate delegate];
    
    // 页面跳转
    UIViewController *currentRootVC = appDelegate.window.rootViewController;
    if ([currentRootVC isKindOfClass:[MainViewController class]]) {
        [currentRootVC dismissViewControllerAnimated:YES completion:nil];
    }
    else {
        NSLog(@"当前rootViewController是 %@", NSStringFromClass([currentRootVC class]));
    }
}

// 响应点击标签页按钮
- (IBAction)tabBtnPress:(id)sender {
    [self addToTabs];  // 添加当前页面到tab
    [[AppDelegate delegate] saveMainScreenShot:self.view];
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Browser" bundle:[NSBundle mainBundle]];
    TabsViewController *tabVC = [story instantiateViewControllerWithIdentifier:@"tabs"];
    [self presentViewController:tabVC animated:YES completion:nil];
}

// 添加当前页面到tab
- (void)addToTabs {
    AppDelegate *appDelegate = [AppDelegate delegate];
    
    if (![appDelegate.tabList containsObject:self]) {  // 同一tab不新增
        // 由于准入策略，同一webapp只会有一个VC，所以此处无需检查，故注释掉
        //        BOOL isIn = NO;
        //        for (CustomWebViewController *vc in appDelegate.tabList) {
        //            if ([vc.requestURL isEqual:self.requestURL]) {
        //                isIn = YES;
        //                break;
        //            }
        //        }
        //        if (!isIn) {
        [appDelegate.tabList insertObject:self atIndex:0];  // 插到头
        if (appDelegate.tabList.count > 8) {
            CustomWebViewController *vc = [appDelegate.tabList lastObject];
            [appDelegate.tabList removeLastObject]; // 最多只允许8个
            vc = nil;
        }
        //        }
    }
}

// 为url增加参数
- (NSString *)combineParaForUrl:(NSString *)url {
    NSString *userToken = [AppInfoManager getValueForKey:kKeyOfUserToken forApp:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"]];
    NSString *deviceId = [AppInfoManager getDeviceID];
    NSString *userId = [AppInfoManager getUserID];
    NSString *userName = [AppInfoManager getUserName];
    NSString *orgId = [AppInfoManager getValueForKey:kKeyOfOrgID];
    
    return [NSString stringWithFormat:@"%@?usertoken=%@&deviceid=%@&userid=%@&notesid=%@&orgid=%@", url, userToken, deviceId, userId, userName, orgId];
}

// 针对从搜索结果中打开的人名标签页增加参数
- (NSString *)combineContactUserParamForURL:(NSString *)url {
    if (self.appno != kAppNoOfSearchedUser || [self.requestType intValue] != CWRequestTypeOther) {
        return url;
    }
    
    
    // 仅针对人名标签页
    NSArray *urlArray = [url componentsSeparatedByString:@"#"];
    if (urlArray) {
        if ([urlArray count] != 2) {
            CIBLog(@"服务端返回的地址#位置和数目不对啊");
        }
        else {
            NSString *userToken = [AppInfoManager getValueForKey:kKeyOfUserToken forApp:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"]];
            NSString *deviceId = [AppInfoManager getDeviceID];
            NSString *userId = [AppInfoManager getUserID];
            NSString *userName = [AppInfoManager getUserName];
            NSString *orgId = [AppInfoManager getValueForKey:kKeyOfOrgID];
            
            NSString *firstPart = [urlArray objectAtIndex:0];
            // 检查前半部分最后一个字符是否为 ‘/’
            BOOL isLastCharDash = [[firstPart substringFromIndex:[firstPart length] - 1] isEqualToString:@"/"];
            if (isLastCharDash) {
                // 去掉'/'
                firstPart = [firstPart substringToIndex:[firstPart length] - 1];
                // 拼接
                firstPart = [NSString stringWithFormat:@"%@?usertoken=%@&deviceid=%@&userid=%@&notesid=%@&orgid=%@/", firstPart, userToken, deviceId, userId, userName, orgId];
            }
            else {
                firstPart = [NSString stringWithFormat:@"%@?usertoken=%@&deviceid=%@&userid=%@&notesid=%@&orgid=%@", firstPart, userToken, deviceId, userId, userName, orgId];
            }
            return [NSString stringWithFormat:@"%@#%@", firstPart, [urlArray objectAtIndex:1]];
        }
    }
    else {
        CIBLog(@"服务端返回的地址里面没有#");
    }
    
    return url;
}


#pragma mark -- UIWebViewDelegate

// 准备加载
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    CIBLog(@"准备加载: %@", request.URL);
    
    // 如果是点击链接
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        CIBLog(@"shouldStartLoadWithRequest clicked:%@", request.URL);
        if ([[[request.URL absoluteString] substringToIndex:4] isEqualToString:@"tel:"]) {
            CIBLog(@"这是个手机号码");
            NSString *teleNum = [[request.URL absoluteString] substringFromIndex:4];
            teleNum = [Function decodeFromPercentEscapeString:teleNum];
            if (![teleNum isEqualToString:@"无"] && ![teleNum isEqualToString:@""]) {
                NSString *msg = [NSString stringWithFormat:@"这是一个电话号码，您可以"];
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:teleNum message:msg delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"呼叫", @"发送短信", @"添加到手机通讯录", @"复制",nil];
                alertView.tag = 8001;
                [alertView show];
            }
            return NO;
        }
        // 检查网络
        if (![MyUtils isNetworkAvailableInView:self.view]) {
            return NO;
        }
        
        // 检查请求类型
        if (![CIBURLProtocol canInitWithRequest:request]) {
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];  // 显示状态栏网络活动标志
            return YES;
        }
        
        // TODO：暂时不搞那么麻烦，所以对链接的类型没有判断，最好限定一些保存的文件类型，剩下的直接打开
        
        // 地址摘要
        NSString *urlStr = [[request URL] absoluteString];
        NSString *alias = [MyUtils MD5Digest:urlStr];
        CIBLog(@"Alias: %@", alias);
        
        // 判断文件是否已下载
        CoreDataManager *cdManager = [[CoreDataManager alloc] init];
        if ([cdManager isFileExist:alias]) {
            //            [MyUtils showAlertWithTitle:[NSString stringWithFormat:@"文件%@已下载", urlStr] message:nil];
            [self showAlertWithTitle:[NSString stringWithFormat:@"文件%@已下载", urlStr] message:nil];
            
            return NO;
        }
        
        // 构造请求，通过NSError获取链接信息
        NSMutableURLRequest *downloadReq = [request mutableCopy];
        [downloadReq setValue:NavTypeLinkClickStr forHTTPHeaderField:NavigationTypeHeader];
        NSError *err = nil;
        [NSURLConnection sendSynchronousRequest:downloadReq returningResponse:nil error:&err];
        
        if (err == nil) {
            // 错误非空才对
            return NO;
        }
        else {
            NSString *mimeType = err.userInfo[@"MIME"];
            if ([mimeType rangeOfString:@"text/html"].location != NSNotFound) {
                return YES;
            }
        }
        
        // 注册通知，以便监听下载期间的事件
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleMyNotification:)
                                                     name:CIBURLProtocolNoti
                                                   object:nil];
        HUD = [MBProgressHUD showHUDAddedTo:self.webview animated:YES];
        
        // 新开线程
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            
            NSURLResponse *res = nil;
            NSError *err = nil;
            NSMutableURLRequest *downloadReq = [request mutableCopy];
            [downloadReq setValue:NavTypeDownloadStr forHTTPHeaderField:NavigationTypeHeader];
            NSData *fileData = [NSURLConnection sendSynchronousRequest:downloadReq returningResponse:&res error:&err];
            
            // 移除通知
            [[NSNotificationCenter defaultCenter] removeObserver:self name:nil object:self];
            
            if (err != nil) {
                // 出错了
                CIBLog(@"Download failed: %@", [err description]);
            }
            else {
                
                // 构造文件路径
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                NSString *documentDir = [paths objectAtIndex:0];
                NSString *docPath = [documentDir stringByAppendingPathComponent:alias];
                
                NSString *fileName = [res suggestedFilename];
                const char *byte = [fileName cStringUsingEncoding:NSISOLatin1StringEncoding];
                NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
                fileName = [[NSString alloc] initWithCString:byte encoding: enc]; //如是utf，此处应改为NSUTF8StringEncoding
                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)res;
                NSDictionary *dic = [httpResponse allHeaderFields];
                NSString *contentType = [dic objectForKey:@"Content-Type"];
                NSArray *arr = [contentType componentsSeparatedByString:NSLocalizedString(@";", nil)];
                NSString *mime = [arr[0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                CIBLog(@"MIME: %@", mime);
                
                // 此处加密文件内容
                NSData *cryptFileData = [[[CryptoManager alloc] init] encryptData:fileData];
                
                if (cryptFileData != nil) {
                    NSError *error = nil;
                    [cryptFileData writeToFile:docPath options:NSDataWritingAtomic error:&error];
                    
                    if (error != nil) {
                        CIBLog(@"Save failed: %@", [error description]);
                    }
                    
                    // 文件管理对象
                    DownloadFile *file = [[DownloadFile alloc] init];
                    file.fileName = fileName;
                    file.fileAlias = alias;
                    file.mimeType = mime;
                    
                    NSDate *now = [NSDate date];
                    NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
                    [dateformatter setDateFormat:@"YYYY-MM-dd HH:mm"];
                    file.downloadTime = [dateformatter stringFromDate:now];
                    
                    // 存入数据库
                    [cdManager insertFileInfo:file];
                    
                    // 打开
                    [self.webview loadData:fileData MIMEType:mime textEncodingName:@"GBK" baseURL:nil];
                }
                else {
                    CIBLog(@"链接似乎没有下载到什么内容");
                }
            }
            
            // 线程完成时的操作
            dispatch_async(dispatch_get_main_queue(), ^{
                if (HUD) {
                    [HUD removeFromSuperview];
                    HUD = nil;
                }
            });
            
        });
        
        return NO;
    }
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];  // 显示状态栏网络活动标志
    return YES;
}

// 开始加载
- (void)webViewDidStartLoad:(UIWebView *)webView {
    CIBLog(@"开始加载：%@", [[webView request] URL]);
    
    // 加载进度条
    if (!HUD) {
        HUD = [MBProgressHUD showHUDAddedTo:self.webview animated:YES];
    }
    
    // 显示停止按钮
    
    if (![MyUtils isSystemVersionBelowEight]) {
        [self.refreshButton setImage:[UIImage imageNamed:@"stop"]];
    }
    else {
        // 这种方式似乎会带来问题
        UIBarButtonItem *newItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"stop"] style:UIBarButtonItemStylePlain target:self  action:@selector(refreshBtnPress:)];
        int count = 0;
        NSMutableArray *newItems = [[NSMutableArray alloc] init];
        for (UIBarButtonItem *item in self.toolbar.items) {
            if (count == 3) {
                newItem.width = 10;
                [newItems addObject:newItem];
            }
            else {
                item.width = 10;
                [newItems addObject:item];
            }
            count ++;
        }
        [self.toolbar setItems:newItems];
    }
}

// 加载完毕
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
    NSString *readyState = [webView stringByEvaluatingJavaScriptFromString:@"document.readyState"];
    if ([readyState isEqualToString:@"interactive"]) {  // 仅对已加载的部分文件有效，在此情况下，对象模型是有效但只读的
        CIBLog(@"interactive");
        
        // 页面已基本可用，去掉菊花等
        [self resetNavButtons];  // 重置前进后退按钮
        // 移除进度条
        if (HUD) {
            [HUD removeFromSuperview];
            HUD = nil;
        }
        
    }
    else if ([readyState isEqualToString:@"complete"]) {  // 文件已完全加载，代表加载成功
        CIBLog(@"加载完毕：%@", [[webView request] URL]);
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];  // 隐藏状态栏网络活动标志
        [self resetNavButtons];  // 重置前进后退按钮
        // 移除进度条
        if (HUD) {
            [HUD removeFromSuperview];
            HUD = nil;
        }
    }
    else {
        [self showAlertWithTitle:@"当前页面可能显示不完整" message:nil];
        [self.webview loadHTMLString:@"<html><body></body></html>" baseURL:nil];
    }
    
    [webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.style.webkitUserSelect='none';"];  // 禁用用户选择
    [webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.style.webkitTouchCallout='none';"];  // 禁用长按弹出框
    
    // JS同步调用OC方法
    JSContext *context = [self.webview valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    JSContext *this = context;
    context[@"encrypt"] = ^() {
        
        CIBLog(@"start encrypt");
        NSArray *args = [JSContext currentArguments];
        JSValue *jsVal = args[0];
        JSValue *ret = [JSValue valueWithObject:[[[CryptoManager alloc] init] encryptString:[jsVal toString]] inContext:this];
        return ret;
        
    };
    context[@"execSQLite"] = ^() {
        CIBLog(@"start create table");
        NSArray *args = [JSContext currentArguments];
        NSUInteger argsCount = [args count];
        NSString *dbName = nil;
        
        if (!args || argsCount <= 0) {
            return [JSValue valueWithObject:[NSNumber numberWithBool:NO] inContext:this];;
        }
        
        if (argsCount > 1) {
            dbName = [args[1] toString];
        }
        
        else {
            dbName = [NSString stringWithFormat:@"%@.db", self.appno];
        }
        
        DatabaseManageHelper *helper = [DatabaseManageHelper sharedManagerHelper];
        [helper openDatabase:dbName];
        
        JSValue *jsSql = args[0];
        NSString *sql = [jsSql toString];
        BOOL suc = NO;
        suc = [helper excuSQL:sql];
        
        JSValue *retJsVal = [JSValue valueWithObject:[NSNumber numberWithBool:suc] inContext:this];
        
        return retJsVal;
    };
    context[@"querySQLite"] = ^() {
        NSArray *args = [JSContext currentArguments];
        
        NSArray *params = nil;
        
        NSUInteger argsCount = [args count];
        NSString *dbName = nil;
        
        if (!args || argsCount <= 0) {
            return [JSValue valueWithObject:@"" inContext:this];;
        }
        
        if (argsCount > 1) {
            params = [args[1] toArray];
        }
        
        if (argsCount > 2) {
            dbName = [args[2] toString];
        }
        
        else {
            dbName = [NSString stringWithFormat:@"%@.db", self.appno];
        }
        NSString *querySql = [args[0] toString];
        DatabaseManageHelper *helper = [DatabaseManageHelper sharedManagerHelper];
        [helper openDatabase:dbName];
        
        NSString *json = [helper query:querySql params:params];
        return [JSValue valueWithObject:json inContext:this];
    };
    
    //原生给js提供发送websockect消息接口
    context[@"sendWsMessage"] = ^() {
        /*
        NSArray *args = [JSContext currentArguments];
        NSString *msg = [args[0] toString];
        JFRWebSocket *socket = [AppDelegate delegate].socket;
        JSSendMessageManager *manager = [JSSendMessageManager sharedManager];
        [manager sendMessage:msg socket:socket];
         */
        // js传入的两个参数分别为分享类型("url"/"app")和具体的消息内容({"appname":"news",...})
        NSArray *args = [JSContext currentArguments];
        if ([args count] < 2) {
            return;
        }
        NSString *shareType = [args[0] toString];
        NSString *message = [args[1] toString];
        OpenChatController *openChatVC = [[OpenChatController alloc] init];
        openChatVC.isFromShare = YES;
        openChatVC.shareType = shareType;
        openChatVC.shareContent = message;
        [self presentViewController:openChatVC animated:YES completion:nil];
        
    };
    
    context[@"fileStatus"] = ^() {
        
        NSArray *args = [JSContext currentArguments];
        NSString *uri = [args[0] toString];
        NSString *path = [args[1] toString];
        NSString *filePath = [uri stringByAppendingString:path];
        NSString *fileAlias = [MyUtils MD5Digest:filePath];
        
        CoreDataManager *coreDataManager = [[CoreDataManager alloc]init];
        NSArray *fileList = [coreDataManager getFileList];
        
        FileDownloadStatus fileStatus = FileUndownload;
        for (DownloadFile *file in fileList) {
            if ([file.fileAlias isEqualToString:fileAlias]) {
                fileStatus = file.downloadStatus;
                
            }
            
        }
        JSValue *ret =  [JSValue valueWithObject:[NSString stringWithFormat:@"%d",fileStatus] inContext:this];
        NSLog(@"fileStatus=%@",[NSString stringWithFormat:@"%d",fileStatus]);
        return ret;
        
    };
    
    context[@"viewPhoto"] = ^() {
        NSArray *args = [JSContext currentArguments];
        
        NSString *fileId = [[args firstObject] toString];
        ViewPhotoController *viewPhotoController = [[ViewPhotoController alloc] init];
        [self presentViewController:viewPhotoController animated:YES completion:^{
            viewPhotoController.imageName = fileId;
        }];
    };
    
    context[@"deletePhoto"] = ^() {
        NSArray *args = [JSContext currentArguments];
        NSString *fileId = [[args firstObject] toString];
        [[PhotoEventHandleUtils sharedPhotoEventHandleUtils] deletePhoto:fileId];
    };
    
    // 嵌入JS代码以支持JS调用原生功能
    NSString *embedInJS = @"if(!window.WebViewJavascriptBridge){document.addEventListener('WebViewJavascriptBridgeReady',null,false)};if(window.WebViewJavascriptBridge){window.WebViewJavascriptBridge.init();function getLoginInfo(responseCallback){window.WebViewJavascriptBridge.send('getLoginInfo',[responseCallback])}function resetToken(responseCallback){window.WebViewJavahscriptBridge.send('resetToken',[responseCallback])}function openUrl(url,appno){window.WebViewJavascriptBridge.send(['openUrl',url,appno])}function showLoading(visible,msg){window.WebViewJavascriptBridge.send(['showLoading',visible,msg])}function addReminder(alertTime,happenTime,intervalTime,title,requestCode,serialNo){window.WebViewJavascriptBridge.send(['addReminder',alertTime,happenTime,intervalTime,title,requestCode,serialNo])}function cancelReminder(requestCode,serialNo){window.WebViewJavascriptBridge.send(['cancelReminder',requestCode,serialNo])}function cancelAllReminder(){window.WebViewJavascriptBridge.send(['cancelAllReminder'])}function invoke(uri,method,param,success,failure){window.WebViewJavascriptBridge.send(['invokeApi',uri,method,param],[success,failure])}function downloadFile(uri,path,onFail,onSuccess,onProgress){window.WebViewJavascriptBridge.send(['downloadFile',uri,path],[onFail,onSuccess,onProgress])}function showFile(uri,path){window.WebViewJavascriptBridge.send(['showFile',uri,path])}function takePhoto(appId,description,success,failure,pixelW,pixelH){window.WebViewJavascriptBridge.send(['takePhoto',appId,description,pixelW,pixelH],[success,failure])}function uploadPhotos(fileIdArray,success,failure){window.WebViewJavascriptBridge.send(['uploadPhotos',fileIdArray],[success,failure])}function viewAuthorizedFile(uri,parameter){window.WebViewJavascriptBridge.send(['viewAuthorizedFile',uri,parameter])}WebApp={getLoginInfo:getLoginInfo,resetToken:resetToken,openUrl:openUrl,showLoading:showLoading,addReminder:addReminder,invoke:invoke,downloadFile:downloadFile,showFile:showFile,fileStatus:fileStatus,encrypt:encrypt,execSQLite:execSQLite,querySQLite:querySQLite,sendWsMessage:sendWsMessage,takePhoto:takePhoto,viewPhoto:viewPhoto,deletePhoto:deletePhoto,uploadPhotos:uploadPhotos,viewAuthorizedFile:viewAuthorizedFile}} ";
    [webView stringByEvaluatingJavaScriptFromString:embedInJS];
    // 显示刷新按钮
    if (![MyUtils isSystemVersionBelowEight]) {
        [self.refreshButton setImage:[UIImage imageNamed:@"Refresh1"]];
    }
    else {
        // 这种方式似乎会带来问题
        UIBarButtonItem *newItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Refresh1"] style:UIBarButtonItemStylePlain target:self  action:@selector(refreshBtnPress:)];
        int count = 0;
        NSMutableArray *newItems = [[NSMutableArray alloc] init];
        for (UIBarButtonItem *item in self.toolbar.items) {
            if (count == 3) {
                newItem.width = 10;
                [newItems addObject:newItem];
            }
            else {
                item.width = 10;
                [newItems addObject:item];
            }
            count ++;
        }
        [self.toolbar setItems:newItems];
    }
}

// 加载失败的回调
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    CIBLog(@"加载失败：%@", error);
    
    // 移除进度条
    if (HUD) {
        [HUD removeFromSuperview];
        HUD = nil;
    }
    
    if (!self.isManualStop && error.code != -999) {  // 收到停止和无意义的不报错
        //        [MyUtils showAlertWithTitle:[error localizedDescription] message:nil];
        if (error.code == -1205) { // 浏览器证书过期
            [self showAlertWithTitle:@"证书过期，请前往设置界面更换证书" message:nil];
        }
        else {
            [self showAlertWithTitle:[error localizedDescription] message:nil];
        }
    }
    else {
        self.isManualStop = NO;
    }
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];  // 隐藏状态栏网络活动标志
    [self resetNavButtons];  // 重置前进后退按钮
    
    // JS同步调用OC方法
    JSContext *context = [self.webview valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    JSContext *this = context;
    context[@"encrypt"] = ^() {
        
        CIBLog(@"start encrypt");
        NSArray *args = [JSContext currentArguments];
        JSValue *jsVal = args[0];
        JSValue *ret = [JSValue valueWithObject:[[[CryptoManager alloc] init] encryptString:[jsVal toString]] inContext:this];
        return ret;
        
    };
    context[@"fileStatus"] = ^() {
        
        NSArray *args = [JSContext currentArguments];
        NSString *uri = [args[0] toString];
        NSString *path = [args[1] toString];
        NSString *filePath = [uri stringByAppendingString:path];
        NSString *fileAlias = [MyUtils MD5Digest:filePath];
        
        CoreDataManager *coreDataManager = [[CoreDataManager alloc]init];
        NSArray *fileList = [coreDataManager getFileList];
        
        FileDownloadStatus fileStatus = FileUndownload;
        for (DownloadFile *file in fileList) {
            if ([file.fileAlias isEqualToString:fileAlias]) {
                fileStatus = file.downloadStatus;
                
            }
            
        }
        JSValue *ret =  [JSValue valueWithObject:[NSString stringWithFormat:@"%d",fileStatus] inContext:this];
        NSLog(@"fileStatus=%@",[NSString stringWithFormat:@"%d",fileStatus]);
        return ret;
        
    };
    
    
    // 嵌入JS代码以支持JS调用原生功能
    NSString *embedInJS = @"if(!window.WebViewJavascriptBridge){document.addEventListener('WebViewJavascriptBridgeReady',null,false)};if(window.WebViewJavascriptBridge){window.WebViewJavascriptBridge.init();function getLoginInfo(responseCallback){window.WebViewJavascriptBridge.send('getLoginInfo',[responseCallback])}function resetToken(responseCallback){window.WebViewJavahscriptBridge.send('resetToken',[responseCallback])}function openUrl(url,appno){window.WebViewJavascriptBridge.send(['openUrl',url,appno])}function showLoading(visible,msg){window.WebViewJavascriptBridge.send(['showLoading',visible,msg])}function addReminder(alertTime,happenTime,intervalTime,title,requestCode,serialNo){window.WebViewJavascriptBridge.send(['addReminder',alertTime,happenTime,intervalTime,title,requestCode,serialNo])}function cancelReminder(requestCode,serialNo){window.WebViewJavascriptBridge.send(['cancelReminder',requestCode,serialNo])}function cancelAllReminder(){window.WebViewJavascriptBridge.send(['cancelAllReminder'])}function invoke(uri,method,param,success,failure){window.WebViewJavascriptBridge.send(['invokeApi',uri,method,param],[success,failure])}function downloadFile(uri,path,onFail,onSuccess,onProgress){window.WebViewJavascriptBridge.send(['downloadFile',uri,path],[onFail,onSuccess,onProgress])}function showFile(uri,path){window.WebViewJavascriptBridge.send(['showFile',uri,path])}function takePhoto(appId,description,success,failure,pixelW,pixelH){window.WebViewJavascriptBridge.send(['takePhoto',appId,description,pixelW,pixelH],[success,failure])}function uploadPhotos(fileIdArray,success,failure){window.WebViewJavascriptBridge.send(['uploadPhotos',fileIdArray],[success,failure])}function viewAuthorizedFile(uri,parameter){window.WebViewJavascriptBridge.send(['viewAuthorizedFile',uri,parameter])}WebApp={getLoginInfo:getLoginInfo,resetToken:resetToken,openUrl:openUrl,showLoading:showLoading,addReminder:addReminder,invoke:invoke,downloadFile:downloadFile,showFile:showFile,fileStatus:fileStatus,encrypt:encrypt,execSQLite:execSQLite,querySQLite:querySQLite,sendWsMessage:sendWsMessage,takePhoto:takePhoto,viewPhoto:viewPhoto,deletePhoto:deletePhoto,uploadPhotos:uploadPhotos,viewAuthorizedFile:viewAuthorizedFile}} ";
    
    [webView stringByEvaluatingJavaScriptFromString:embedInJS];
    
    
    
    // 显示刷新按钮
    if (![MyUtils isSystemVersionBelowEight]) {
        [self.refreshButton setImage:[UIImage imageNamed:@"Refresh1"]];
    }
    else {
        // 这种方式似乎会带来问题
        UIBarButtonItem *newItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Refresh1"] style:UIBarButtonItemStylePlain target:self  action:@selector(refreshBtnPress:)];
        int count = 0;
        NSMutableArray *newItems = [[NSMutableArray alloc] init];
        for (UIBarButtonItem *item in self.toolbar.items) {
            if (count == 3) {
                newItem.width = 10;
                [newItems addObject:newItem];
            }
            else {
                item.width = 10;
                [newItems addObject:item];
            }
            count ++;
        }
        [self.toolbar setItems:newItems];
    }
}


#pragma mark -- UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}


#pragma mark -- custom

// 重置前进后退按钮
- (void)resetNavButtons {
    if ([requestType intValue] == CWRequestTypeLocalFile) {
        return;
    }
    
    [self.backwardButton setEnabled:[self.webview canGoBack]];
    [self.forwardButton setEnabled:[self.webview canGoForward]];
}

// webview上滑，隐藏toolbar
- (void)handleWebviewSwipeUp:(UIPanGestureRecognizer*)gestureRecognizer {
    [UIView animateWithDuration:0.4
                     animations:^{
                         CGRect frame = self.toolbar.frame;
                         frame.origin.y = CGRectGetMaxY(self.toolbar.superview.bounds);
                         self.toolbar.frame = frame;
                     }];
}

// webview下滑，显示toolbar
- (void)handleWebviewSwipeDown:(UIPanGestureRecognizer*)gestureRecognizer {
    [UIView animateWithDuration:0.4
                     animations:^{
                         CGRect frame = self.toolbar.frame;
                         frame.origin.y = CGRectGetMaxY(self.toolbar.superview.bounds) - CGRectGetHeight(self.toolbar.frame);
                         self.toolbar.frame = frame;
                     }];
}

// 处理文件下载时收到的通知
- (void)handleMyNotification:(NSNotification *)notification {
    
    if (!HUD) {
        return;
    }
    
    switch ([notification.userInfo[@"TYPE"] intValue]) {
        case NotiDidReceiveResponse:  // 获取服务器响应
            HUD.mode = MBProgressHUDModeDeterminate;
            break;
        case NotiDidReceiveData:  // 接收到数据
            HUD.progress = [notification.userInfo[@"PROGRESS"] floatValue];
            break;
        case NotiDidFailWithError:  // 出错
            //            [MyUtils showAlertWithTitle:notification.userInfo[@"DESC"] message:nil];
            [self showAlertWithTitle:notification.userInfo[@"DESC"] message:nil];
        case NotiDidFinishLoading:  // 下载结束
        default:
            //            [HUD removeFromSuperview];  // 写完文件后再消失
            //            HUD = nil;
            break;
    }
    
}

- (void)userDidTakeScreenshot {
    //    [MyUtils showAlertWithTitle:@"提示" message:@"您刚刚进行了截屏操作，该操作已被记录，请确认其合规性并删除不合规的截图。"];
//    [self showAlertWithTitle:@"提示" message:@"您刚刚进行了截屏操作，该操作已被记录，请确认其合规性并删除不合规的截图。"];
}

#pragma mark -- UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    // 点击电话号码后的alert view
    if (alertView.tag == 8001) {
        // buttonIndex从0到4分别是：取消，呼叫，发送短信，添加到手机通讯录和复制
        switch (buttonIndex) {
            case 0:
                break;
            case 1:
            {
                NSURL *dialURL = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", alertView.title]];
                NSURLRequest *request = [NSURLRequest requestWithURL:dialURL];
                [self.webview loadRequest:request];
            }
                break;
            case 2:
            {
                NSURL *dialURL = [NSURL URLWithString:[NSString stringWithFormat:@"sms:%@", alertView.title]];
                NSURLRequest *request = [NSURLRequest requestWithURL:dialURL];
                [self.webview loadRequest:request];
            }
                break;
            case 3:
                // 添加到手机通讯录
            {
                // 首先选择是新建联系人还是添加到现有联系人
                UIAlertView *nextAlertView = [[UIAlertView alloc] initWithTitle:alertView.title message:@"是一个电话号码，你可以" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"创建新联系人", @"添加到现有联系人", nil];
                nextAlertView.tag = 8002;
                [nextAlertView show];
            }
                break;
            case 4:
            {
                [UIPasteboard generalPasteboard].string = alertView.title;
            }
                break;
            default:
                break;
        }
    }
    // 点击添加到通讯录的alert view
    else if (alertView.tag == 8002) {
        // buttonIndex从0到2分别是：取消，创建新联系人和添加到现有联系人
        switch (buttonIndex) {
            case 0:
                break;
            case 1:
            {
                ABNewPersonViewController *newPersonVC  = [[ABNewPersonViewController alloc] init];
                newPersonVC.newPersonViewDelegate = self;
                UINavigationController *navCtrlr = [[UINavigationController alloc] initWithRootViewController:newPersonVC];
                // 构造要显示的联系人对象
                CFErrorRef error = NULL;
                ABRecordRef personRef = ABPersonCreate();
                // 电话号码属于具有多个值的项
                ABMutableMultiValueRef multi = ABMultiValueCreateMutable(kABMultiStringPropertyType);
                // 设置联系人电话值
                ABMultiValueAddValueAndLabel(multi, (__bridge CFTypeRef)(alertView.title), kABPersonPhoneMobileLabel, NULL);
                ABRecordSetValue(personRef, kABPersonPhoneProperty, multi, &error);
                
                newPersonVC.displayedPerson = personRef;
                [self presentViewController:navCtrlr animated:YES completion:nil];
                CFRelease(multi);
                CFRelease(personRef);
            }
                break;
            case 2:
            {
                ABPeoplePickerNavigationController *peoplePickerNavCtrlr = [[ABPeoplePickerNavigationController alloc] init];
                if (![MyUtils isSystemVersionBelowEight]) {
                    peoplePickerNavCtrlr.predicateForSelectionOfPerson = [NSPredicate predicateWithValue:true];
                }
                peoplePickerNavCtrlr.peoplePickerDelegate = self;
                // 暂存一下电话号码
                teleNumber = alertView.title;
                [self presentViewController:peoplePickerNavCtrlr animated:YES completion:nil];
            }
                break;
            default:
                break;
        }
    } else if (alertView.tag == 8000) {//相机拍照授权检测
        switch (buttonIndex) {
            case 0:
                
                break;
                
            case 1:
            {
                NSURL *url = [NSURL URLWithString:@"prefs:root=Privacy"];
                if ([[UIApplication sharedApplication] canOpenURL:url]) {
                    [[UIApplication sharedApplication] openURL:url];
                }
            }
                break;
                
            default:
                break;
        }
    }
}

- (void)newPersonViewController:(ABNewPersonViewController *)newPersonView didCompleteWithNewPerson:(ABRecordRef)person {
    [newPersonView.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker didSelectPerson:(ABRecordRef)person {
    
    // 添加本次获取到的电话号码
    ABMutableMultiValueRef multiPhone = ABMultiValueCreateMutableCopy (ABRecordCopyValue(person, kABPersonPhoneProperty));
    ABMultiValueAddValueAndLabel(multiPhone, (__bridge CFTypeRef)(teleNumber), kABPersonPhoneMobileLabel, NULL);
    ABRecordSetValue(person, kABPersonPhoneProperty, multiPhone,nil);
    ABAddressBookHasUnsavedChanges(peoplePicker.addressBook);
    
    ABNewPersonViewController *vc = [[ABNewPersonViewController alloc] init];
    vc.displayedPerson = person;
    vc.newPersonViewDelegate = self;
    UINavigationController *navCtrlr = [[UINavigationController alloc] initWithRootViewController:vc];
    
    if (multiPhone)
        CFRelease(multiPhone);
    
    // 由于ABPeoplePickerNavigationController会自动的pop掉所有view，因此延时处理ABNewPersonViewController的弹出。
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self presentViewController:navCtrlr animated:YES completion:nil];
    });
    
}

- (void)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker didSelectPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier {
    
}

- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person {
    return YES;
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier {
    return YES;
}

#pragma mark - 状态栏提示
- (void)beginDownLoadNoti:(NSNotification *)notification
{
    _customStatusBar = [[CustomStatusBar alloc] initWithFrame:[UIApplication sharedApplication].statusBarFrame];
    [_customStatusBar showStatusMessage:[NSString stringWithFormat:@"%@ 正在下载",notification.object]];
    
}

- (void)successDownLoadNoti:(NSNotification *)notification
{
    _customStatusBar.messageLabel.text = [NSString stringWithFormat:@"%@ 下载成功",notification.object];
    [self performSelector:@selector(statusBarHidden:) withObject:_customStatusBar afterDelay:5.0f];
}
- (void)statusBarHidden:(CustomStatusBar *)customStatusBar
{
    [customStatusBar hide];
}
- (void)failureDownLoadNoti:(NSNotification *)notification
{
    _customStatusBar.messageLabel.text = [NSString stringWithFormat:@"%@ 下载失败",notification.object];
    [self performSelector:@selector(statusBarHidden:) withObject:_customStatusBar afterDelay:5.0f];
}


// 显示一个只有确定按钮的alert
// 在这类重写一次showAlert方法的原因：
// 1.iOS8上必须使用UIAlertController，才能保证屏幕旋转时，alert提示框不旋转
// 2.当用户从tab页重新进入webview时，由于页面的层级关系，调用MyUtils类里的方法展示UIAlertController会出现异常。因此，在此类中重写一遍。
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
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.005 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self presentViewController:alertController animated:YES completion:nil];
        });
    }
    
}

@end