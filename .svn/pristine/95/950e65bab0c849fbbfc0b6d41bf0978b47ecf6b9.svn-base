//
//  HttpManager.m
//  CommunityFinancial
//
//  Created by wuxiyao on 15/4/21.
//  Copyright (c) 2015年 pactera. All rights reserved.
//

#import "HttpManager.h"

@implementation HttpManager

#pragma mark - init

- (instancetype)init
{
    self = [super init];
    if (self) {
        _manager = [AFHTTPRequestOperationManager manager];
        _manager.requestSerializer = [AFHTTPRequestSerializer serializer];
        _manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    }
    return self;
}

#pragma mark - 单例

+ (HttpManager *) sharedHttpManager
{
    static dispatch_once_t pred;
    static HttpManager *_sharedHttpManager = nil;
    dispatch_once(&pred, ^{
        
        if (_sharedHttpManager == nil)
        {
            _sharedHttpManager = [[HttpManager alloc] init];
        }
    });
    
    return _sharedHttpManager;
}

- (NSDictionary *)responeDataToDic:(id)data
{
    NSError *err = nil;
    NSDictionary *objDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&err];
    if (err) {
        objDic = nil;
    }
    return objDic;
}

/**
 *  用户登录
 *
 *  @param url     访问服务器地址
 *  @param parmes  入参
 *  @param success 创建成功返回
 *  @param error   创建失败返回
 */
- (void)login:(NSString *)url
   parameters:(id)parmes
      success:(void (^)(NSDictionary *dic))success
         fail:(void (^)(NSError *error))fail
{
    _manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    _manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [_manager.securityPolicy setAllowInvalidCertificates:YES];
    [_manager POST:url parameters:parmes success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *dic = [self responeDataToDic:responseObject];
        
        success(dic);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        fail(error);
        
    }];
}

/**
 *  用户名称和头像
 *
 *  @param url     访问服务器地址
 *  @param parmes  入参
 *  @param success 创建成功返回
 *  @param error   创建失败返回
 */
- (void)userNameAndIcon:(NSString *)url
             parameters:(id)parmes
                success:(void (^)(NSDictionary *dic))success
                   fail:(void (^)(NSError *error))fail;
{
    _manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    _manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [_manager.securityPolicy setAllowInvalidCertificates:YES];
    [_manager POST:url parameters:parmes success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *dic = [self responeDataToDic:responseObject];
        
        success(dic);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        fail(error);
        
    }];
}

/**
 *  创建群
 *
 *  @param url     访问服务器地址
 *  @param parmes  入参
 *  @param success 创建成功返回
 *  @param error   创建失败返回
 */
- (void)createGroupUrl:(NSString *)url
            parameters:(id)parmes
               success:(void (^)(NSDictionary *dic))success
                  fail:(void (^)(NSError *error))fail
{
    _manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    _manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [_manager.securityPolicy setAllowInvalidCertificates:YES];
    [_manager GET:url parameters:parmes success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *dic = [self responeDataToDic:responseObject];
        
        success(dic);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        fail(error);
        
    }];
}

/**
 *  添加群成员
 *
 *  @param url     访问服务器地址
 *  @param parmes  入参
 *  @param success 创建成功返回
 *  @param error   创建失败返回
 */
- (void)addMemberToGroupUrl:(NSString *)url
                 parameters:(id)parmes
                    success:(void (^)(NSDictionary *dic))success
                       fail:(void (^)(NSError *error))fail
{
    _manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    _manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [_manager.securityPolicy setAllowInvalidCertificates:YES];
    [_manager GET:url parameters:parmes success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *dic = [self responeDataToDic:responseObject];
        
        success(dic);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        fail(error);
        
    }];
}

/**
 *  所有群成员
 *
 *  @param url     访问服务器地址
 *  @param parmes  入参
 *  @param success 创建成功返回
 *  @param error   创建失败返回
 */
- (void)allMembersOfGroupUrl:(NSString *)url
                  parameters:(id)parmes
                     success:(void (^)(NSDictionary *dic))success
                        fail:(void (^)(NSError *error))fail
{
    _manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    _manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [_manager GET:url parameters:parmes success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *dic = [self responeDataToDic:responseObject];
        
        success(dic);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        fail(error);
        
    }];
}

/**
 *  退群
 *
 *  @param url     访问服务器地址
 *  @param parmes  入参
 *  @param success 创建成功返回
 *  @param error   创建失败返回
 */
- (void)removeMemberOutGroupUrl:(NSString *)url
                     parameters:(id)parmes
                        success:(void (^)(NSDictionary *dic))success
                           fail:(void (^)(NSError *error))fail
{
    _manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    _manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [_manager GET:url parameters:parmes success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *dic = [self responeDataToDic:responseObject];
        
        success(dic);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        fail(error);
        
    }];
}

/**
 *  获取群名称
 *
 *  @param url     访问服务器地址
 *  @param parmes  入参
 *  @param success 创建成功返回
 *  @param error   创建失败返回
 */
- (void)groupNameUrl:(NSString *)url
          parameters:(id)parmes
             success:(void (^)(NSDictionary *dic))success
                fail:(void (^)(NSError *error))fail
{
    _manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    _manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [_manager GET:url parameters:parmes success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *dic = [self responeDataToDic:responseObject];
        
        success(dic);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        fail(error);
        
    }];
}

/**
 *  文件上传
 *
 *  @param url     访问服务器地址
 *  @param parmes  入参
 *  @param success 创建成功返回
 *  @param error   创建失败返回
 */
- (void)fileUploadURL:(NSString *)url
                 data:(NSData *)data
                 name:(NSString *)name
             mimeType:(NSString *)mimeType
             fileName:(NSString *)fileName
              success:(void (^)(NSDictionary *dic))success
                 fail:(void (^)(NSError *error))fail
             progress:(void (^)(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite))progress
{
    _manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    _manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [_manager POST:url parameters:data constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        [formData appendPartWithFileData:data name:name fileName:fileName mimeType:mimeType];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *dic = [self responeDataToDic:responseObject];
        
        success(dic);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        fail(error);
    } progress:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
        
        progress(bytesWritten, totalBytesWritten, totalBytesExpectedToWrite);
    } header:^(NSDictionary *responseHeader) {
        
    }];
}

@end
