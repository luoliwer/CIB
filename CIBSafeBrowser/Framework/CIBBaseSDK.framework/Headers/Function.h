//
//  Function.h
//  baseSDK
//  常用方法类
//  Created by AveryChen on 14-9-22.
//  Copyright (c) 2014年 cib. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Function : NSObject

/**
*  返回Documents资源路径
*
*  @param relativePath 相对路径
*
*  @return 资源的绝对路径
*/
+ (NSString *)getPathForDocumentsResource:(NSString *)relativePath;

/**
 *  删除指定路径的文件
 *
 *  @param filePath 文件的绝对路径
 */
+ (void)deleteFileAtPath:(NSString *)filePath;

/**
 *  检查指定路径的文件是否存在
 *
 *  @param filePath 文件的绝对路径
 *
 *  @return 是否存在的标识(YES/NO)
 */
+ (BOOL)isFileExistedAtPath:(NSString *)filePath;

/**
 *  获取设备的UUID
 *
 *  @return 设备UUID的字符串
 */
+ (NSString *)getUUID;

/**
 *  获取设备型号
 *
 *  @return 设备型号的字符串
 */
+ (NSString *)getDevicePlatform;


/**
 *  获取系统版本号
 *
 *  @return 系统版本号的字符串
 */
+ (NSString *)getSystemVersion;

/**
 *  将字符串编码为URL编码
 *
 *  @param input 待编码的字符串
 *
 *  @return URL编码后的字符串
 */
+ (NSString *)encodeToPercentEscapeString:(NSString *)input;

/**
 *  将URL编码的字符串还原
 *
 *  @param input URL编码后的字符串
 *
 *  @return 原字符串
 */
+ (NSString *)decodeFromPercentEscapeString:(NSString *)input;

/**
 *  检测网络是否可用
 *
 *  @return 网络是否可用的标识（YES/NO）
 */
+ (BOOL)isNetworkAvailable;

@end
