//  用于生成SSL双向认证中客户端密钥的工具类
//  为防止外部使用不善导致内存泄露，不直接返回RSA、X509_REQ等结构变量，全部以文件为中介
//  SecUtils.h
//  CIBSafeBrowser
//
//  Created by CIB-Mac mini on 14-12-4.
//  Copyright (c) 2014年 cib. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <openssl/rsa.h>

typedef enum {
    KeyTypePublic,
    KeyTypePrivate
} KeyType;

/*
 cer/crt是用于存放证书，它是2进制形式存放的，不含私钥。
 pem跟crt/cer的区别是它以ASCII来表示。
 pfx/p12用于存放个人证书/私钥，他通常包含保护密码，2进制方式
 */

static NSString *SecFilePriKeyPem = @"kGR8malO5VlXQboSjt8ngg";//@"private.pem";
static NSString *SecFilePubKeyPem = @"anAK8PpLdDrDbkNCgvr37g";//@"public.pem";
static NSString *SecFileX509ReqPem = @"iCSH9IIAWC8Zcto0SnQuPw";//@"x509Req.pem";
static NSString *SecFileX509Cert = @"JeCMv1XmFOd4JQ3CAHqANg";//@"res.cer";
static NSString *SecFileP12 = @"TriWbEvALKiBcIAhQYgz7w";//@"client.p12";

@interface SecUtils : NSObject

//- (RSA *)importRSAKeyWithType:(KeyType)type;
//- (BOOL) generateX509ReqWithPath:(NSString *)path;  //generate a PEM csr in the Document
//- (void)combineP12; //method to generate p12 file by cer and privateKey
//- (BOOL)isP12Exist;

/**
 *  生成一RSA密钥对，公私钥分别写入路径directory中的SecFilePriKeyPem、SecFilePubKeyPem中
 *
 *  @param directory 执行目录
 *
 *  @return 是否设执行成功标识（YES/NO）
 */
+ (BOOL)generateRSAKeyPairInDir:(NSString *)directory;

/**
 *  利用directory下的SecFilePriKeyPem和SecFilePubKeyPem生成证书请求文件SecFileX509ReqPem
 *
 *  @param directory 执行目录
 *
 *  @return 是否设执行成功标识（YES/NO）
 */
+ (BOOL)generateX509ReqInDir:(NSString *)directory;

/**
 *  利用directory下的证书文件SecFileX509Cert和私钥SecFilePriKeyPem合成p12文件SecFileP12
 *
 *  @param directory 执行目录
 *
 *  @return 是否设执行成功标识（YES/NO）
 */
+ (BOOL)generateP12InDir:(NSString *)directory;

/**
 *  检查directory下p12文件SecFileP12文件是否存在
 *
 *  @param directory 执行目录
 *
 *  @return 文件是否存在标识（YES/NO）
 */
+ (BOOL)isP12ExistInDir:(NSString *)directory;

/**
 *  获取一个默认证书文件目录，如果目录不存在，生成之
 *
 *  @return 目录路径
 */
+ (NSString *)defaultCertDir;

@end
