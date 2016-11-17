//
//  HttpManager.h
//  CommunityFinancial
//
//  Created by wuxiyao on 15/4/21.
//  Copyright (c) 2015年 pactera. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CIBBaseSDK/AFHTTPRequestOperationManager.h>
@class HttpManager;

// 网络请求
@interface HttpManager : NSObject

{
    AFHTTPRequestOperationManager *_manager;
}

/**
 *  单例
 *
 *  @return 整个工程就一个对像
 */
+ (HttpManager *) sharedHttpManager;

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
         fail:(void (^)(NSError *error))fail;

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
                  fail:(void (^)(NSError *error))fail;

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
                       fail:(void (^)(NSError *error))fail;

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
                        fail:(void (^)(NSError *error))fail;

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
                           fail:(void (^)(NSError *error))fail;

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
                fail:(void (^)(NSError *error))fail;

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
             progress:(void (^)(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite))progress;

@end
