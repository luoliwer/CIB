//
//  CIBRequestOperationManager.h
//  BasicSuite
//
//  Created by CIB-Mac mini on 14-9-16.
//  Copyright (c) 2014年 cib. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CIBRequestOperationManager : NSObject

/**
 *  调用服务端远程方法
 *
 *  @param uri              方法名/方法编号
 *  @param method           调用方式 POST/GET
 *  @param parameters       参数字典
 *  @param onSucceededBlock 调用成功的回调函数
 *  @param onFailedBlock    调用失败的回调函数
 */
+(void)invokeAPI:(NSString *)uri
        byMethod:(NSString *)method
  withParameters:(id)parameters
onRequestSucceeded:(void(^)(NSString* responseCode, NSString* responseInfo))onSucceededBlock
 onRequestFailed:(void(^)(NSString* responseCode, NSString* responseInfo))onFailedBlock;

@end
