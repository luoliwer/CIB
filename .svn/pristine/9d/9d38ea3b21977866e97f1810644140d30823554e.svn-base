//
//  CIBURLProtocol.m
//  CIBSafeBrowser
//
//  Created by cib on 8/10/14.
//  Copyright (c) 2014 cib. All rights reserved.
//

#import "CIBURLProtocol.h"
#import "CIBHttpsRequset.h"

#import "MyUtils.h"
#import <Config.h>

@interface CIBURLProtocol () <NSURLConnectionDelegate>
{
    NSURLConnection *pConnection;
    NSMutableData *resData;
    
    CIBURLProtocolNavType navigationType;  // NavTypeLinkClick：只是点击链接获取链接信息   NavTypeDownload：下载链接内容
    long long fileLength, fileCurLength;  // 文档总长度，当前下载长度
}

@end

@implementation CIBURLProtocol

// Returns whether the protocol subclass can handle the specified request.
// 确定本Protocol是否处理这个connection请求
+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    
    // 本Protocol只处理https
    if (![[[[request URL] scheme] uppercaseString] isEqualToString:@"HTTPS"]) {
        return NO;
    }
    
    // 如果用NSURLConnection来发起代理请求，那么那个代理请求的request也同样会经过这里来做判断，
    // 为了防止后续startLoading中可能存在的死循环，需要检查是否是已经处理过的request，然后返回NO，
    if ([request valueForHTTPHeaderField:DidURLHeader] != nil) {
        return NO;
    }
    
    // 访问应用接口服务器无需双向认证（应用接口服务器可能和apache代理服务器在同一台）
    if ([request.URL.absoluteString rangeOfString:[MyUtils propertyOfResource:@"Setting" forKey:@"BaseUrl"]].location != NSNotFound) {
        return NO;
    }
    
    // 读取配置(setting.plist)中的代理服务器列表进行判断
    NSArray *proxyList = [MyUtils propertyOfResource:@"Setting" forKey:@"ProxyList"];
    for (NSString *proxy in proxyList) {
        if ([request.URL.absoluteString rangeOfString:proxy].location != NSNotFound) {
            // CIBLog(@"自定义Protocol:canInitWithRequest - %@", request.URL);
            return YES;
        }
    }
    
    return NO;
}

// Returns a canonical version of the specified request.
+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    // CIBLog(@"自定义Protocol:canonicalRequestForRequest");
    return request;
}

// Starts protocol-specific loading of the request.
- (void)startLoading {
    CIBLog(@"自定义Protocol:startLoading - %@", self.request.URL.absoluteString);
    
    // 判断加载类型
    NSString *navType = [self.request valueForHTTPHeaderField:NavigationTypeHeader];
    if ([navType isEqualToString:NavTypeDownloadStr]) {// 下载请求
        navigationType = NavTypeDownload;
    }
    else if ([navType isEqualToString:NavTypeLinkClickStr]) { // 获取链接信息
        navigationType = NavTypeLinkClick;
    }
    else {
        navigationType = NavTypeOther;
    }

    // 构造新请求，在header中增加标记来证明已处理
    NSMutableURLRequest *proxyRequest = [self.request mutableCopy];
    [proxyRequest setValue:@"CIBURLProtocol" forHTTPHeaderField:DidURLHeader];
    //pConnection = [NSURLConnection connectionWithRequest:proxyRequest delegate:self];
    pConnection = [[NSURLConnection alloc] initWithRequest:proxyRequest delegate:self startImmediately:NO];
    
    // 启动连接
    [pConnection start];
}

// Stops protocol-specific loading of the request.
- (void)stopLoading {
    CIBLog(@"自定义Protocol:stopLoading");

    if (pConnection != nil) {
        [pConnection cancel];
    }
    pConnection = nil;
}

#pragma mark -- NSURLConnectionDelegate

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
    CIBLog(@"3.NSURLConnectionDelegate:canAuthenticateAgainstProtectionSpace");
    return YES;
}

// A CustomHTTPProtocol delegate callback, called when the protocol has an authenticate challenge that the delegate accepts via - customHTTPProtocol:canAuthenticateAgainstProtectionSpace:. In this specific case it's only called to handle server trust authentication challenges. It evaluates the trust based on both the global set of trusted anchors and the list of trusted anchors returned by the CredentialsManager.
- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    CIBLog(@"4.NSURLConnectionDelegate:didReceiveAuthenticationChallenge");
    
    assert(challenge != nil);
    
    // 使用客户端证书认证
    SecIdentityRef identity = [CIBHttpsRequset identityWithCert];
    if (identity == nil || identity == NULL) {
        // 证书有问题
    }
    NSURLCredential *credential = [NSURLCredential credentialWithIdentity:identity
                                                             certificates:nil
                                                              persistence:NSURLCredentialPersistencePermanent
                                   ];
    [challenge.sender useCredential:credential forAuthenticationChallenge:challenge];
}

// 当服务器提供了足够客户程序创建NSURLResponse对象的信息时，代理对象会收到一个connection:didReceiveResponse:消息，在消息内可以检查NSURLResponse对象和确定数据的预期长度、mime类型、文件名以及其他服务器提供的元信息
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    CIBLog(@"5.NSURLConnectionDelegate:didReceiveResponse");
    
    // 如果只是点击了链接，那么只是为了获取链接信息，完成后取消connection，利用error返回相关信息
    if (navigationType == NavTypeLinkClick) {
        [connection cancel];
        
        NSString *fileName = [response suggestedFilename];
        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        NSDictionary *dic = [httpResponse allHeaderFields];
        NSString *contentType = [dic objectForKey:@"Content-Type"];
        NSArray *arr = [contentType componentsSeparatedByString:NSLocalizedString(@";", nil)];
        NSString *mime = [arr[0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        // 还可以分离charset
        
        NSDictionary *fileInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                  fileName, @"NAME",
                                  mime, @"MIME",
                                  nil];
        NSError *err = [NSError errorWithDomain:@"com.cib" code:-9999 userInfo:fileInfo];
        
        [self.client URLProtocol:self didFailWithError:err];
    }
    // 如果是点击链接之后的下载请求
    else if (navigationType == NavTypeDownload) {
        fileLength = MAX([response expectedContentLength], 1);
        fileCurLength = 0;
        
        // 发送通知，通知viewcontroller处理响应事件（菊花等）
        NSDictionary *dic =[[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:NotiDidReceiveResponse], @"TYPE", nil];
        NSNotification *notification =[NSNotification notificationWithName:CIBURLProtocolNoti object:nil userInfo:dic];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
    }

    // 目前版本禁止缓存 - NSURLCacheStorageAllowed,NSURLCacheStorageAllowedInMemoryOnly,NSURLCacheStorageNotAllowed,
    [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
}

// 当下载开始的时候，每当有数据接收，代理会定期收到connection:didReceiveData:消息代理应当在实现中储存新接收的数据
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    CIBLog(@"6.NSURLConnectionDelegate:didReceiveData");
    
    // 如果是文件下载，发送通知，通知viewcontroller处理响应事件（进度等）
    if (navigationType == NavTypeDownload) {
        fileCurLength += [data length];
        float progress = fileCurLength / (float)fileLength;
        
        NSDictionary *dic =[[NSDictionary alloc] initWithObjectsAndKeys:
                            [NSNumber numberWithInt:NotiDidReceiveData], @"TYPE",
                            [NSNumber numberWithFloat:progress], @"PROGRESS",
                            nil];
        NSNotification *notification =[NSNotification notificationWithName:CIBURLProtocolNoti object:nil userInfo:dic];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
    }
    
    if (resData == nil) {
        resData = [data mutableCopy];
    }
    else {
        [resData appendData:data];
    }
}

// 当下载的过程中有错误发生的时候，代理会收到一个connection：didFailWithError消息消息参数里面的NSError对象提供了具体的错误细节，它也能提供在用户信息字典里面失败的url请求（使用NSErrorFailingURLStringKey）
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    CIBLog(@"7.NSURLConnectionDelegate:didFailWithError - %@", error);
    
    // 如果是文件下载，发送通知，通知viewcontroller处理响应事件（关掉菊花等）
    if (navigationType == NavTypeDownload) {
        NSDictionary *dic =[[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:NotiDidFailWithError], @"TYPE", [error localizedDescription], @"DESC",nil];
        NSNotification *notification =[NSNotification notificationWithName:CIBURLProtocolNoti object:nil userInfo:dic];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
    }
    
    [self.client URLProtocol:self didFailWithError:error];
}

// 下载成功
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    // 如果是文件下载，发送通知，通知viewcontroller处理响应事件（关掉菊花等）
    if (navigationType == NavTypeDownload) {
        NSDictionary *dic =[[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:NotiDidFinishLoading], @"TYPE", nil];
        NSNotification *notification =[NSNotification notificationWithName:CIBURLProtocolNoti object:nil userInfo:dic];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
    }
    
    NSData *data = resData;
    [self.client URLProtocol:self didLoadData:data];
    [self.client URLProtocolDidFinishLoading:self];
}

@end
