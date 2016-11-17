//
//  CryptoManager.h
//  baseSDK
//  加密工具类
//  Created by AveryChen on 14-9-19.
//  Copyright (c) 2014年 cib. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CryptoManager : NSObject

/**
 *  使用服务端应用公钥加密字符串
 *
 *  @param sourceString 待加密的字符串
 *
 *  @return 加密后的字符串
 */
- (NSString *)encryptStringWithServerAppPublicKey:(NSString *)sourceString;

/**
 *  使用浏览器私钥解密字符串
 *
 *  @param encryptedString 加密后的字符串
 *
 *  @return 源字符串
 */
- (NSString *)decryptStringWithBrowserPrivateKey:(NSString *)encryptedString;

/**
 *  加密字符串（加密算法和加密密钥由方法已预设好）
 *
 *  @param sourceString 源字符串
 *
 *  @return 加密后的字符串
 */
- (NSString *)encryptString:(NSString *)sourceString;

/**
 *  解密字符串（解密算法和解密密钥由方法已预设好）
 *
 *  @param encryptedString 加密后的字符串
 *
 *  @return 源字符串
 */
- (NSString *)decryptString:(NSString *)encryptedString;

/**
 *  加密二进制数据（加密算法和加密密钥由方法已预设好）
 *
 *  @param sourceData 源数据
 *
 *  @return 加密后的二进制数据
 */
- (NSData *)encryptData:(NSData *)sourceData;

/**
 *  解密二进制数据（解密算法和解密密钥由方法已预设好）
 *
 *  @param encryptedData 加密后的二进制数据
 *
 *  @return 源数据
 */
- (NSData *)decryptData:(NSData *)encryptedData;

/**
 *  使用设备私钥签名字符串
 *
 *  @param sourceString 待签名的字符串
 *
 *  @return 签名后的字符串
 */
- (NSString *)signStringWithDevicePrivateKey:(NSString *)sourceString;

/**
 *  使用AES算法加密字符串
 *
 *  @param sourceString 待加密的字符串
 *  @param key          AES加密密钥
 *
 *  @return 加密后的字符串
 */
- (NSString *)encryptString:(NSString *)sourceString
                 withAESKey:(NSString *)key;

/**
 *  使用AES算法解密字符串
 *
 *  @param encryptedString 加密后的字符串
 *  @param key             AES加密密钥
 *
 *  @return 原字符串
 */
- (NSString *)decryptString:(NSString *)encryptedString
                 withAESKey:(NSString *)key;
/**
 *  使用AES算法加密二进制数据
 *
 *  @param sourceData 待加密的数据
 *  @param key        AES加密密钥
 *
 *  @return 加密后的二进制数据
 */
- (NSData *)encryptData:(NSData *)sourceData
            withAESKey:(NSString *)key;

/**
 *  使用AES算法解密二进制数据
 *
 *  @param encryptedData 加密后的二进制数据
 *  @param key           AES加密密钥
 *
 *  @return 原二进制数据
 */
- (NSData *)decryptData:(NSData *)encryptedData
             withAESKey:(NSString *)key;

@end
