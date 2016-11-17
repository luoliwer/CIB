//
//  DeviceKeyManager.h
//  baseSDK
//  终端密钥管理类
//  Created by AveryChen on 14-9-17.
//  Copyright (c) 2014年 cib. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DeviceKeyManager : NSObject

/**
*  检查本地密钥是否存在
*
*  @return 是否存在标识（YES/NO）
*/
+ (BOOL)isDeviceKeyExisted;



/**
 *  注销终端密钥
 *
 *  @param onSucceededBlock 注销成功的回调函数
 *  @param onFailedBlock    注销失败的回调函数
 */
+ (void)cancelDeviceKeyOnCancelSucceeded:(void(^)(NSString* responseCode, NSString* responseInfo))onSucceededBlock
                          onCancelFailed:(void(^)(NSString* responseCode, NSString* responseInfo))onFailedBlock;

/**
 *  删除本地密钥
 *
 *  @return 是否删除成功标识（YES/NO）
 */
+ (BOOL)deleteDeviceKey;



/**
 *  登录（申请密钥/验证用户名密码）
 *
 *  @param username         用户名
 *  @param password         密码
 *  @param onSucceededBlock 成功的回调函数
 *  @param onFailedBlock    失败的回调函数
 */
+ (void)loginWithUsername:(NSString *)username
              andPassword:(NSString *)password
         onLoginSucceeded:(void (^)(NSString *, NSString *))onSucceededBlock
            onLoginFailed:(void (^)(NSString *, NSString *))onFailedBlock;

/**
 *  兴资讯专用登录（申请密钥/验证用户名）
 *
 *  @param username         用户名
 *  @param onSucceededBlock 成功的回调函数
 *  @param onFailedBlock    失败的回调函数
 */
+ (void)loginWithUsername:(NSString *)username
         onLoginSucceeded:(void (^)(NSString *, NSString *))onSucceededBlock
            onLoginFailed:(void (^)(NSString *, NSString *))onFailedBlock;

@end
