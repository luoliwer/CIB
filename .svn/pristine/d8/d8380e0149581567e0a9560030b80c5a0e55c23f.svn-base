//
//  MyUtils.m
//  CIBSafeBrowser
//
//  Created by CIB-Mac mini on 14-8-27.
//  Copyright (c) 2014年 cib. All rights reserved.
//

#import "MyUtils.h"
#import "Reachability.h"
#import "MBProgressHUD.h"
#import "SecUtils.h"
#import "Config.h"
#import <CommonCrypto/CommonDigest.h>
#import <CIBBaseSDK/CIBBaseSDK.h>
#import "CoreDataManager.h"
#import "AppDelegate.h"
#import "CustomWebViewController.h"
#import "MainViewController.h"
#import "AppFavor.h"
@implementation MyUtils

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        if ([[UIScreen mainScreen] scale] == 2.0) {
            UIGraphicsBeginImageContextWithOptions(newSize, YES, 2.0);
        } else {
            UIGraphicsBeginImageContext(newSize);
        }
    } else {
        UIGraphicsBeginImageContext(newSize);
    }
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}


+ (NSString *)mimeType:(NSString *)filePath {
    NSURL *url = [NSURL fileURLWithPath:filePath];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLResponse *response = nil;
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
    return [response MIMEType];
}

// 获取资源文件中的设置
+ (id)propertyOfResource:(NSString *)src forKey:(NSString *)key {
    NSString *pathString = [[NSBundle mainBundle] pathForResource:src ofType:@"plist"];
    NSDictionary *serverSetting = [NSDictionary dictionaryWithContentsOfFile:pathString];
    return [serverSetting objectForKey:key];
}

// 网络状态是否可用
+ (BOOL)isNetworkAvailable {
    Reachability *conn = [Reachability reachabilityForInternetConnection];
    return ([conn currentReachabilityStatus] != NotReachable);
}
// 新闻
+ (BOOL)isNetworkAvailableInView:(UIView *)view {
    // 检查网络，网络不可用时提示
    if (![MyUtils isNetworkAvailable]) {
        MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:view];
        [view addSubview:hud];
        
        // 定义样式
        UIImage *img = [UIImage imageNamed:@"noNetworkMark"];
        hud.customView = [[UIImageView alloc] initWithImage:img];
        hud.mode = MBProgressHUDModeCustomView;
        hud.labelText = @"当前网络不可用";
        //hud.minSize = CGSizeMake(135.f, 135.f);
        
        [hud showAnimated:YES whileExecutingBlock:^{
            sleep(1.5);
        } completionBlock:^{
            [hud removeFromSuperview];
        }];
        
        return NO;
    }
    return YES;
}

// wifi是否可用
+ (BOOL)isWifiAvailable {
    Reachability *conn = [Reachability reachabilityForLocalWiFi];
    return ([conn currentReachabilityStatus] != NotReachable);
}

// 显示一个只有确定按钮的alert
+ (void)showAlertWithTitle:(NSString *)title message:(NSString *)message {
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
                                   handler:^(UIAlertAction *action)
                                   {
                                       
                                   }];
        
        [alertController addAction:okAction];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.005 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            UIViewController *currentVC = [self getCurrentVC];
            UIViewController* controller= currentVC.presentedViewController;
            if(controller){
                 [controller presentViewController:alertController animated:YES completion:nil];
            }else{
                [currentVC presentViewController:alertController animated:YES completion:nil];
            }
        });
    }

}

// MD5摘要
+ (NSString *)MD5Digest:(NSString *)key {
    const char *str = [key UTF8String];
    if (str == NULL) {
        str = "";
    }
    unsigned char r[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)strlen(str), r);
    NSString *digest = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                          r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10], r[11], r[12], r[13], r[14], r[15]];
    
    return digest;
}

// 屏幕截屏
+ (UIImage *)screenShotFromView:(UIView *)view {
//    UIGraphicsBeginImageContext([UIScreen mainScreen].bounds.size);
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    [[[[UIApplication sharedApplication] keyWindow] layer] renderInContext:context];
//    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
    
    UIGraphicsBeginImageContext(view.frame.size);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

// 绘制颜色线性渐变图片(固定方向)
+ (UIImage*) drawLinearGradientImageFromColors:(NSArray*)colors
                                     locations:(const CGFloat [])locations
                                  gradientType:(LinearGradientDerection)gradientDerection
                                          size:(CGSize)size {
    CGPoint start;
    CGPoint end;
    switch (gradientDerection) {
        case LinearGradientDerectionTopToBottom:
            start = CGPointMake(0.0, 0.0);
            end = CGPointMake(0.0, size.height);
            break;
        case LinearGradientDerectionLeftToRight:
            start = CGPointMake(0.0, 0.0);
            end = CGPointMake(size.width, 0.0);
            break;
        case LinearGradientDerectionUpLeftToLowRight:
            start = CGPointMake(0.0, 0.0);
            end = CGPointMake(size.width, size.height);
            break;
        case LinearGradientDerectionUpRightToLowLeft:
            start = CGPointMake(size.width, 0.0);
            end = CGPointMake(0.0, size.height);
            break;
        default:
            start = CGPointMake(0.0, 0.0);
            end = CGPointMake(size.width, 0.0);
            break;
    }
    
    return [MyUtils drawLinearGradientImageFromColors:colors locations:locations startPoint:start endPoint:end size:size];
}

// 绘制颜色线性渐变图片(自定义方向)
+ (UIImage*) drawLinearGradientImageFromColors:(NSArray *)colors
                                     locations:(const CGFloat [])locations
                                    startPoint:(CGPoint)start
                                      endPoint:(CGPoint)end
                                          size:(CGSize)size {
    NSParameterAssert(colors.count > 0);
    
    NSMutableArray *arr = [NSMutableArray array];
    for(UIColor *c in colors) {
        [arr addObject:(id)c.CGColor];
    }
    
    UIGraphicsBeginImageContextWithOptions(size, YES, 1);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    CGColorSpaceRef colorSpace = CGColorGetColorSpace([[colors lastObject] CGColor]);
//    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (CFArrayRef)arr, locations);
    
    /*绘制线性渐变
     context:图形上下文
     gradient:渐变色
     startPoint:起始位置
     endPoint:终止位置
     options:绘制方式,kCGGradientDrawsBeforeStartLocation 开始位置之前就进行绘制，到结束位置之后不再绘制，
     kCGGradientDrawsAfterEndLocation开始位置之前不进行绘制，到结束点之后继续填充
     */
    CGContextDrawLinearGradient(context, gradient, start, end, kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    CGGradientRelease(gradient);
    CGContextRestoreGState(context);
    CGColorSpaceRelease(colorSpace);
    UIGraphicsEndImageContext();
    
    return image;
}

// 绘制颜色径向渐变图片
+ (UIImage*) drawRadialGradientImageFromColors:(NSArray *)colors
                                     locations:(const CGFloat [])locations
                                   startCenter:(CGPoint)start
                                   startRadius:(CGFloat)startRadius
                                     endCenter:(CGPoint)end
                                   endRadius:(CGFloat)endRadius
                                          size:(CGSize)size {
    NSParameterAssert(colors.count > 0);
    
    NSMutableArray *arr = [NSMutableArray array];
    for(UIColor *c in colors) {
        [arr addObject:(id)c.CGColor];
    }
    
    UIGraphicsBeginImageContextWithOptions(size, YES, 1);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    CGColorSpaceRef colorSpace = CGColorGetColorSpace([[colors lastObject] CGColor]);
    //    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (CFArrayRef)arr, locations);
    
    /*绘制径向渐变
     context:图形上下文
     gradient:渐变色
     startCenter:起始点位置
     startRadius:起始半径（通常为0，否则在此半径范围内容无任何填充）
     endCenter:终点位置（通常和起始点相同，否则会有偏移）
     endRadius:终点半径（也就是渐变的扩散长度）
     options:绘制方式,kCGGradientDrawsBeforeStartLocation 开始位置之前就进行绘制，但是到结束位置之后不再绘制，
     kCGGradientDrawsAfterEndLocation开始位置之前不进行绘制，但到结束点之后继续填充
     */
    CGContextDrawRadialGradient(context, gradient, start, startRadius, end, endRadius, kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    CGGradientRelease(gradient);
    CGContextRestoreGState(context);
    CGColorSpaceRelease(colorSpace);
    UIGraphicsEndImageContext();
    
    return image;
}

// UIImage转UIColor
+ (UIImage*) createImageWithColor: (UIColor*)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

+ (NSString *)combineURLWithBaseURL:(NSString *)baseURL andRelativeURL:(NSString *)relativeURL {
    if (!baseURL) {
        return relativeURL;
    }
    if (!relativeURL) {
        return baseURL;
    }
    NSString *retURL = nil;
    // 前半部分是否以斜杠结尾
    BOOL isBaseURLEndWithSlash = [[baseURL substringFromIndex:([baseURL length] - 1)] isEqualToString:@"/"];
    // 后半部分是否以斜杠开头
    BOOL isRelativeURLStartWithSlash = [[relativeURL substringToIndex:1] isEqualToString:@"/"];
    // 前半部分或后半部分中一个有斜杠
    if (isBaseURLEndWithSlash ^ isRelativeURLStartWithSlash) {
        retURL = [NSString stringWithFormat:@"%@%@", baseURL,relativeURL];
    }
    // 前半部分和后半部分均有斜杠
    else if (isBaseURLEndWithSlash && isRelativeURLStartWithSlash) {
        baseURL = [baseURL substringToIndex:([baseURL length] - 1)];
        retURL = [NSString stringWithFormat:@"%@%@", baseURL,relativeURL];
    }
    // 前半部分和后半部分均无斜杠
    else {
        retURL = [NSString stringWithFormat:@"%@/%@", baseURL,relativeURL];
    }
    return retURL;
}

+ (BOOL)isSystemVersionBelowEight {
    return ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0f);
}

//获取当前屏幕显示的viewcontroller
+ (UIViewController *)getCurrentVC
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
    
    if ([nextResponder isKindOfClass:[UIViewController class]]){
        result = nextResponder;
    }
    else{
        result = window.rootViewController;
    }
    UIViewController* controller= result.presentedViewController;
    if(controller){
        if([controller isKindOfClass:[UINavigationController class]]){
            result=((UINavigationController*)controller).viewControllers.lastObject;
        }
    }else{
        result=controller;
    }
    
    return result;
}

// 显示一个只有确定按钮的alert
+ (void)showAlertWithTitle:(NSString *)title message:(NSString *)message autoHideAfterSeconds:(int)second {
    if ([self isSystemVersionBelowEight]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles: nil];
        [alert show];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (alert) {
                [alert dismissWithClickedButtonIndex:0 animated:YES];
            }
        });
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
            UIViewController *currentVC = [self getCurrentVC];
            [currentVC presentViewController:alertController animated:YES completion:nil];
        });
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (alertController) {
                [alertController dismissViewControllerAnimated:YES completion:nil];
            }
        });
    }
    
}

//  生成ssl通信证书
+ (void)loadCACertificateSuccess:(void (^)(NSString *, NSString *))success failure:(void (^)(NSString *, NSString *))failure {
    
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
                if ([responseCode isEqualToString:@"I00"] || [responseCode isEqualToString:@"0"]) {
                    CIBLog(@"CA认证成功");
                    
                    // 此处应该往keychain中写入私钥信息
                    NSString *priPath = [certDir stringByAppendingPathComponent:SecFilePriKeyPem];
                    NSString *priKey = [NSString stringWithContentsOfFile:priPath encoding:NSUTF8StringEncoding error:nil];
                    [AppInfoManager setValue:priKey forKey:kKeyOfBrowserPrivateKey];
                    
                    if (responseInfo == nil) {
                        [MyUtils showAlertWithTitle:@"证书内容为空" message:nil];
                        
                        return;
                    }
                    else {
                        NSError *error = nil;
                        NSString *filePath = [certDir stringByAppendingPathComponent:SecFileX509Cert];
                        NSString *decodeContent = [Function decodeFromPercentEscapeString:responseInfo];
                        [decodeContent writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
                        if (error == nil) {
                            [SecUtils generateP12InDir:certDir];  // 合成p12文件
                            
                            // 更新证书更换时间
                            CoreDataManager *cdManager = [[CoreDataManager alloc] init];
                            [cdManager updateUpdateTimeByName:@"BrowserCert"];
                        }
                        else {
                            [MyUtils showAlertWithTitle:error.localizedDescription message:nil];
                        }
                    }
                }
                else {
                    CIBLog(@"failed ,code = %@, info = %@", responseCode, responseInfo);
                    [MyUtils showAlertWithTitle:responseInfo message:nil];
                }
                success(responseCode, responseInfo);
            };
            
            // 请求失败的回调函数
            void(^failedBlock)(NSString *, NSString *) = ^(NSString *responseCode, NSString *responseInfo) {
                [MyUtils showAlertWithTitle:responseInfo message:nil];
                failure(responseCode, responseInfo);
            };
            
            
            @try {
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
                [MyUtils showAlertWithTitle:exception.description message:nil];
            }
            
        });
    });
    
}

+ (void)openUrl:(NSString *)url ofApp:(AppProduct *)app{
    
    AppDelegate *appDelegate = [AppDelegate delegate];
    
    for (CustomWebViewController *vc in appDelegate.tabList) {
        // 如果tab中已存在，直接打开
        if ([[NSString stringWithFormat:@"%d",[app.appNo intValue]] isEqualToString:vc.appno]) {
            // 如果WebApp的相对路径不同
            if (![url isEqualToString:vc.requestURL]) {
                // 重新设置页面的url
                [vc setRequestURL:url];
                NSString *reqURLString = nil;
                if ([vc respondsToSelector:@selector(combineParaForUrl:)]) {
                    reqURLString = [vc performSelector:@selector(combineParaForUrl:) withObject:vc.requestURL];
                }
                NSURL *reqURL = [NSURL URLWithString:reqURLString];
                NSURLRequest *request = [NSURLRequest requestWithURL:reqURL];
                [vc.webview loadRequest:request];
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];  // 显示状态栏网络活动标志
            }
            // 页面跳转（WebApp界面一律在主界面上进行present，且保证主界面之前present的界面已全部dismiss掉）
            UIViewController *currentRootVC = appDelegate.window.rootViewController;
            if ([currentRootVC isKindOfClass:[MainViewController class]]) {
                if (currentRootVC.presentedViewController) {
                    [currentRootVC dismissViewControllerAnimated:NO completion:^{
                        [currentRootVC presentViewController:vc animated:YES completion:nil];
                    }];
                }
                else {
                    [currentRootVC presentViewController:vc animated:YES completion:nil];
                }
            }
            else {
                NSLog(@"当前rootViewController是 %@", NSStringFromClass([currentRootVC class]));
            }
            return;
        }
    }
    
    // tab不存在，生成新页面
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Browser" bundle:[NSBundle mainBundle]];
    //由storyboard根据myView的storyBoardID来获取我们要切换的视图
    CustomWebViewController *webviewVC = [story instantiateViewControllerWithIdentifier:@"webview"];
    if ([app.type isEqualToString:@"ENTERPRISE"] || [app.type isEqualToString:@"FIXED"]) {
        [webviewVC setRequestType:[NSNumber numberWithInt:CWRequestTypeWebApp]];
    }
    else {
        [webviewVC setRequestType:[NSNumber numberWithInt:CWRequestTypeOther]];
    }
    [webviewVC setRequestURL:app.appIndexUrl];
    [webviewVC setPageTitle:app.appShowName];
    [webviewVC setAppno:[NSString stringWithFormat:@"%d",[app.appNo intValue]]];
    
    // 页面跳转
    UIViewController *currentRootVC = appDelegate.window.rootViewController;
    if ([currentRootVC isKindOfClass:[MainViewController class]]) {
        if (currentRootVC.presentedViewController) {
            [currentRootVC dismissViewControllerAnimated:NO completion:^{
                [currentRootVC presentViewController:webviewVC animated:YES completion:nil];
            }];
        }
        else {
            [currentRootVC presentViewController:webviewVC animated:YES completion:nil];
        }
    }
    else {
        NSLog(@"当前rootViewController是 %@", NSStringFromClass([currentRootVC class]));
    }
}

+ (void)openFile:(DownloadFile *)file {
    
    // 如果tab中已存在，直接打开
    AppDelegate *appDelegate = [AppDelegate delegate];
    for (CustomWebViewController *vc in appDelegate.tabList) {
        if ([vc.localFile.fileAlias isEqual:file.fileAlias]) {
            // 页面跳转（WebApp界面一律在主界面上进行present，且保证主界面之前present的界面已全部dismiss掉）
            UIViewController *currentRootVC = appDelegate.window.rootViewController;
            if ([currentRootVC isKindOfClass:[MainViewController class]]) {
                if (currentRootVC.presentedViewController) {
                    [currentRootVC dismissViewControllerAnimated:NO completion:^{
                        [currentRootVC presentViewController:vc animated:YES completion:nil];
                    }];
                }
                else {
                    [currentRootVC presentViewController:vc animated:YES completion:nil];
                }
            }
            else {
                NSLog(@"当前rootViewController是 %@", NSStringFromClass([currentRootVC class]));
            }
            return;
        }
    }
    
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Browser" bundle:[NSBundle mainBundle]];
    //由storyboard根据myView的storyBoardID来获取我们要切换的视图
    CustomWebViewController *webviewVC = [story instantiateViewControllerWithIdentifier:@"webview"];
    [webviewVC setRequestType:[NSNumber numberWithInt:CWRequestTypeLocalFile]];
    [webviewVC setLocalFile:file];
    [webviewVC setPageTitle:file.fileName];
    
    // 页面跳转
    UIViewController *currentRootVC = appDelegate.window.rootViewController;
    if ([currentRootVC isKindOfClass:[MainViewController class]]) {
        if (currentRootVC.presentedViewController) {
            [currentRootVC dismissViewControllerAnimated:NO completion:^{
                [currentRootVC presentViewController:webviewVC animated:YES completion:nil];
            }];
        }
        else {
            [currentRootVC presentViewController:webviewVC animated:YES completion:nil];
        }
    }
    else {
        NSLog(@"当前rootViewController是 %@", NSStringFromClass([currentRootVC class]));
    }
}
+(AppProduct*) getProductFromList:(NSArray*) array withAppName:(NSString*) appName{
    AppProduct* returnProduct=nil;
    for (AppProduct* product in array) {
        if(![product isKindOfClass:[NSNull class]] && [product.appName isEqualToString:appName]){
            returnProduct=product;
            break;
        }
    }
    return returnProduct;
}
+(AppFavor*) getFavorFromList:(NSArray*) array withAppName:(NSString*) appName{
    AppFavor* returnFavor=nil;
    for (AppFavor* favor in array) {
        if([favor.appName isEqualToString:appName]){
            returnFavor=favor;
            break;
        }
    }
    return returnFavor;
}
@end
