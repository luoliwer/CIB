//
//  FingerWorkManager.h
//  baseSDK
//  手势口令管理类
//  Created by AveryChen on 14-9-17.
//  Copyright (c) 2014年 cib. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FingerWorkManager : NSObject

/**
*  检查本地手势口令是否存在
*
*  @return 是否存在标识（YES/NO）
*/
+ (BOOL)isFingerWorkExisted;

/**
 *  设置本地手势口令
 *
 *  @param fingerWorkString 手势口令的字符串
 *
 *  @return 是否设置成功标识（YES/NO）
 */
+ (BOOL)setFingerWork:(NSString *)fingerWorkString;

/**
 *  验证本地手势口令
 *
 *  @param fingerWorkString 手势口令的字符串
 *
 *  @return 是否验证成功标识（YES/NO）
 */
+ (BOOL)verifyFingerWork:(NSString *)fingerWorkString;

/**
 *  清除本地手势口令
 *
 *  @return 是否清除成功标识（YES/NO）
 */
+ (BOOL)clearFingerWork;

/**
 *  查询本地手势口令剩余可验证次数
 *
 *  @return 手势口令剩余可验证次数
 */
+ (NSInteger)getFingerWorkRemainTestTimes;

@end
