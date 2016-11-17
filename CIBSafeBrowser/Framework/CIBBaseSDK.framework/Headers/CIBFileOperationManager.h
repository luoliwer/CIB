//
//  CIBFileOperationManager.h
//  CIBShop
//
//  Created by AveryChen on 14/11/10.
//  Copyright (c) 2014年 cib. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFURLRequestSerialization.h"

@class AFHTTPRequestOperation;

@interface CIBFileOperationManager : NSObject


/**
 *  调用服务端接口下载文件
 *
 *  @param uri       下载接口的URI
 *  @param parameter 下载的参数
 *  @param success   下载成功的回调函数
 *  @param failure   下载失败的回调函数
 *  @param progress  下载进度的回调函数（bytesRead:本次下载的数据量，totalBytesRead：目前已下载的数据量，totalBytesExpectedToRead：应下载的数据总量）
 *  @param header    获取到responseHeader的回调函数
 */
+ (void)downloadFileWithURI:(NSString *)uri
               andParameter:(id)parameter
                    success:(void(^)(NSDictionary *responseHeader, NSData *responseBody))success
                    failure:(void(^)(NSString *responseCode, NSString *responseInfo))failure
                   progress:(void (^)(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead))progress
                     header:(void(^)(NSDictionary *responseHeader))header;

+ (void)uploadFileAtPath:(NSString *)filePath
                 withURI:(NSString *)uri
            andParameter:(id)parameter
                 success:(void(^)(NSString *responseCode, NSString *responseInfo))success
                 failure:(void(^)(NSString *responseCode, NSString *responseInfo))failure
                progress:(void (^)(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead))progress;

/**
 *  向服务端上传错误日志
 *
 *  @param relativeURL 上传错误页面的相对路径，默认置为nil
 *  @param method      请求方式(POST/GET)
 *  @param parameters  参数字典
 *  @param block       form表单的创建函数，如无特殊要求则置为nil
 *  @param success     成功的回调函数
 *  @param failure     失败的回调函数
 */
+ (void)uploadErrFileToURL:(NSString *)relativeURL
                  byMethod:(NSString *)method
                parameters:(id)parameters
          constructingBody:(void (^)(id <AFMultipartFormData> formData))block
                   success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                   failure:(void (^)(NSString *errorCode, NSString *errorInfo))failure;
@end
