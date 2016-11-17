//
//  AppInfoManager.h
//  baseSDK
//  应用信息管理类
//  Created by AveryChen on 14-9-17.
//  Copyright (c) 2014年 cib. All rights reserved.
//

#import <Foundation/Foundation.h>

//组件相关的数据键值，以下键值对应的数据，应用只能读取不能修改
static NSString *kKeyOfDeviceID = @"DeviceID";//设备号
static NSString *kKeyOfAppID = @"AppID";//应用ID
static NSString *kKeyOfUserID = @"UserID";//用户流水号
static NSString *kKeyOfUserName = @"UserName";//用户名
static NSString *kKeyOfOrgID = @"OrgID";//机构ID
static NSString *kKeyOfUserRealName = @"UserRealName";//用户真实姓名
//组件相关的数据键值，以下键值对应的数据，应用可以读取和修改
static NSString *kKeyOfDeviceType = @"DeviceType";
//static NSString *kKeyOfLoginType = @"LoginType";//用于标识用户登录类型（第一次登录/重新登录）
//组件相关的数据键值，以下键值对应的数据，特定应用可以修改，任何应用不能读取
static NSString *kKeyOfBrowserPrivateKey = @"BrowserPrivateKey";//浏览器私钥
//应用相关的数据，以下键值对应的数据，应用只能读取不能修改
static NSString *kKeyOfUserToken = @"UserToken";//用于安全浏览器的用户标识

//其余未特殊指明的键值，可自行定义键值


typedef enum : NSUInteger {
    DeviceTypeBYOD,
    DeviceTypeMDM
} DeviceType;

@interface AppInfoManager : NSObject

/**
 *  以特定的基础URL地址初始化组件相关信息
 *
 *  @param address 基础的URL地址（例如:http://168.3.23.190:7555/openapi/）
 */
+ (void)initialAppInfoWithBasicURLAddress:(NSString *)address;

/**
 *  以特定的键值存储数据，应用只能设置自身相关的数据
 *
 *  @param value 待存储的数据
 *  @param key   键值
 *
 *  @return 是否存储成功的标识
 */
+ (BOOL)setValue:(NSString *)value
          forKey:(NSString *)key;

/**
 *  根据应用ID和特定的键值读取数据，应用可以读取自身、其它应用和组件相关的数据
 *
 *  @param key   键值
 *  @param appID 应用ID，需读取组件相关数据时，可任意填写
 *
 *  @return 数据值
 */
+ (NSString *)getValueForKey:(NSString *)key
                      forApp:(NSString *)appID;

/**
 *  获取应用自身的数据
 *
 *  @param key 键值
 *
 *  @return 数据值
 */
+ (NSString *)getValueForKey:(NSString *)key;

/**
 *  获取设备ID
 *
 *  @return 设备ID
 */
+ (NSString *)getDeviceID;


/**
 *  获取应用ID
 *
 *  @return 应用ID
 */
+ (NSString *)getAppID;

/**
 *  获取用户ID
 *
 *  @return 用户ID
 */
+ (NSString *)getUserID;

/**
 *  获取用户名
 *
 *  @return 用户名
 */
+ (NSString *)getUserName;

/**
 *  设置设备类型
 *
 *  @param type 设备类型
 *
 *  @return 是否存储成功的标识
 */
+ (BOOL)setDeviceType:(DeviceType) type;

/**
 *  获取设备类型
 *
 *  @return 设备类型
 */
+ (DeviceType)getDeviceType;

/**
 *  清除用户登录信息
 */
+ (void)clearUserInfo;

/**
 *  获取随机数
 *
 *  @return 用于通信加密的随机数
 */
+ (NSString *)getRandomNumber;

/**
 *  重置用户Token（仅用于安全浏览器）
 *
 *  @param finishBlock 重置的回调函数
 */
+ (void)resetUserToken:(void (^)(NSString* response))finishBlock;

/**
 *  检测设备是否越狱
 *
 *  @return 设备是否越狱的标识
 */
+ (BOOL)isDevicePrisonBroken;

@end


