//
//  URLAddressManager.h
//  baseSDK
//
//  Created by AveryChen on 14-9-18.
//  Copyright (c) 2014年 cib. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface URLAddressManager : NSObject

/**
*  设置基本的URL地址
*
*  @param URLAddress 基本的URL地址
*
*  @return 基本的URL地址
*/
+ (NSString *)setBasicURLAddress:(NSString *)URLAddress;

/**
 *  获取基本的URL地址
 *
 *  @return 基本的URL地址
 */
+ (NSString *)getBasicURLAddress;

@end
