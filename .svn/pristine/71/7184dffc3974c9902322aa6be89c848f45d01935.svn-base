//
//  SecUtils.m
//  CIBSafeBrowser
//
//  Created by CIB-Mac mini on 14-12-4.
//  Copyright (c) 2014年 cib. All rights reserved.
//

#import "SecUtils.h"
#import "AppDelegate.h"

#import <openssl/pem.h>
#import <openssl/pkcs12.h>
#import "openssl/err.h"

#import <CIBBaseSDK/CryptoManager.h>

@implementation SecUtils

/**
 *  生成一RSA密钥对，公私钥分别写入路径directory中的SecFilePriKeyPem、SecFilePubKeyPem中
 *
 *  @param directory 执行目录
 *
 *  @return 是否设执行成功标识（YES/NO）
 */
+ (BOOL)generateRSAKeyPairInDir:(NSString *)directory {
    // 检查文件夹是否存在，不存在返回NO
    BOOL isDir = NO;
    BOOL isFileExist = [[NSFileManager defaultManager] fileExistsAtPath:directory isDirectory:&isDir];
    if (!isFileExist || !isDir) {
        return NO;
    }
    
    int ret = 0;
    
    BIGNUM *bne = BN_new();  // public exponent
    ret = BN_set_word(bne, RSA_F4);
    if (ret != 1) {
        BN_free(bne);
        return NO;
    }
    
    // 产生密钥对
    RSA *rsa = RSA_new();
    ret = RSA_generate_key_ex(rsa, 2048, bne, NULL);  // 密钥长度2048
    BN_free(bne);
    if (ret != 1) {
        RSA_free(rsa);
        return NO;
    }
    
    // 保存私钥(pem格式)到文件SecFilePubKeyPem
    NSString *priPath = [directory stringByAppendingPathComponent:SecFilePriKeyPem];
    FILE *priFilePtr = fopen([priPath cStringUsingEncoding:NSASCIIStringEncoding], "wb");
    if (NULL == priFilePtr) {  // 文件无法打开
        NSLog(@"无法打开SecFilePriKeyPem");
        
        RSA_free(rsa);
        return  NO;
    }
    
    RSA *priRsa = RSAPrivateKey_dup(rsa);
    ret = PEM_write_RSAPrivateKey(priFilePtr, priRsa, NULL, NULL, 512, NULL, NULL);
    RSA_free(priRsa);
    fclose(priFilePtr);
    
    if (ret != 1) {
        NSLog(@"写入SecFilePriKeyPem错误");

        RSA_free(rsa);
        return  NO;
    }
    
    // 保存公钥(pem格式)到文件SecFilePubKeyPem
    NSString *pubPath = [directory stringByAppendingPathComponent:SecFilePubKeyPem];
    FILE *pubFilePtr = fopen([pubPath cStringUsingEncoding:NSASCIIStringEncoding], "wb");
    if (NULL == pubFilePtr) {  // 文件无法打开
        NSLog(@"无法打开SecFilePubKeyPem");

        RSA_free(rsa);
        return NO;
    }
    
    RSA *pubRsa = RSAPublicKey_dup(rsa);
    ret = PEM_write_RSAPublicKey(pubFilePtr, pubRsa);
    RSA_free(pubRsa);
    fclose(pubFilePtr);
    
    if (ret != 1) {
        NSLog(@"写入SecFilePubKeyPem错误");
        
        RSA_free(rsa);
        return  NO;
    }

    // 释放相关内存
    RSA_free(rsa);
    CRYPTO_cleanup_all_ex_data();
    
    NSLog(@"生成密钥对成功");
    return YES;
}

/**
 *  利用directory下的SecFilePriKeyPem和SecFilePubKeyPem生成证书请求文件SecFileX509ReqPem
 *
 *  @param directory 执行目录
 *
 *  @return 是否设执行成功标识（YES/NO）
 */
+ (BOOL)generateX509ReqInDir:(NSString *)directory {
    // 检查文件夹是否存在，不存在返回NO
    BOOL isDir = NO;
    BOOL isFileExist = [[NSFileManager defaultManager] fileExistsAtPath:directory isDirectory:&isDir];
    if (!isFileExist || !isDir) {
        return NO;
    }
    
    int ret = 0;

    // 申请X509_REQ对象
    X509_REQ *x509Req = X509_REQ_new();
    
    // 设置版本号
    int nVersion = 1;
    ret = X509_REQ_set_version(x509Req, nVersion);
    if (ret != 1){
        X509_REQ_free(x509Req);
        return NO;
    }
    
    // 设置X509_REQ对象的主体信息
    X509_NAME *x509Name = X509_REQ_get_subject_name(x509Req);
    const char *szCountry = "CN";
    const char *szProvince = "SH";
    const char *szCity = "SH";
    const char *szOrganization = "CIB";
    const char *szCommon = "localhost";
    ret *= X509_NAME_add_entry_by_txt(x509Name, "C", MBSTRING_ASC, (const unsigned char*)szCountry, -1, -1, 0);  // 国家
    ret *= X509_NAME_add_entry_by_txt(x509Name, "ST", MBSTRING_ASC, (const unsigned char*)szProvince, -1, -1, 0);  // 省份
    ret *= X509_NAME_add_entry_by_txt(x509Name, "L", MBSTRING_ASC, (const unsigned char*)szCity, -1, -1, 0);  // 城市
    ret *= X509_NAME_add_entry_by_txt(x509Name, "O", MBSTRING_ASC, (const unsigned char*)szOrganization, -1, -1, 0);  // 组织
    ret *= X509_NAME_add_entry_by_txt(x509Name, "CN", MBSTRING_ASC, (const unsigned char*)szCommon, -1, -1, 0);  // 通用名
    /*不设置更多了。。。在浏览器中没多大用*/
    if (ret != 1) {  // 肯定有个失败了为0
        NSLog(@"设置X509_REQ对象的主体信息失败");
        
        X509_REQ_free(x509Req);
        return NO;
    }

    // 读入公钥
    NSString *pubPath = [directory stringByAppendingPathComponent:SecFilePubKeyPem];
    FILE *pubFilePtr = fopen([pubPath cStringUsingEncoding:NSUTF8StringEncoding], "rb");
    if (NULL == pubFilePtr) {
        NSLog(@"无法打开SecFilePubKeyPem");
        
         X509_REQ_free(x509Req);
        return NO;
    }
    RSA *pubRsa = PEM_read_RSAPublicKey(pubFilePtr, NULL, NULL, NULL);
    fclose(pubFilePtr);

    // 向X509_REQ对象加入主体公钥
    EVP_PKEY *pKeyPub = EVP_PKEY_new();
    EVP_PKEY_assign_RSA(pKeyPub, pubRsa);
    ret = X509_REQ_set_pubkey(x509Req, pKeyPub);
    EVP_PKEY_free(pKeyPub);
    // RSA_free(pubRsa); // will be free pubRsa when EVP_PKEY_free(pKeyPub)
    
    if (ret != 1){
        NSLog(@"向X509_REQ对象加入主体公钥失败");
        
        X509_REQ_free(x509Req);
        return NO;
    }
    
    // 读入私钥
    NSString *priPath = [directory stringByAppendingPathComponent:SecFilePriKeyPem];
    FILE *priFilePtr = fopen([priPath cStringUsingEncoding:NSUTF8StringEncoding], "rb");
    if (NULL == priFilePtr) {
        NSLog(@"无法打开SecFilePriKeyPem");
        
        X509_REQ_free(x509Req);
        return NO;
    }
    RSA *priRsa = PEM_read_RSAPrivateKey(priFilePtr, NULL, NULL, NULL);
    fclose(priFilePtr);
    
    // 用主体的私钥对X509_REQ进行签名，使用sha1算法 --（非必须）
    EVP_PKEY *pKeyPri = EVP_PKEY_new();
    EVP_PKEY_assign_RSA(pKeyPri, priRsa);
    ret = X509_REQ_sign(x509Req, pKeyPri, EVP_sha1());  // return x509_req->signature->length
    EVP_PKEY_free(pKeyPri);
    // RSA_free(priRsa);  // will be free priRsa when EVP_PKEY_free(pKeyPri)

    if (ret < 1){
        NSLog(@"使用私钥对X509_REQ对象签名失败");
        
        X509_REQ_free(x509Req);
        return NO;
    }
    
//    NSString *csrPath = [directory stringByAppendingPathComponent:SecFileX509ReqPem];
//    BIO *csrOut = BIO_new_file([csrPath cStringUsingEncoding:NSUTF8StringEncoding], "wb");
//    ret = PEM_write_bio_X509_REQ(csrOut, x509Req);
//    BIO_free_all(csrOut);
    NSString *csrPath = [directory stringByAppendingPathComponent:SecFileX509ReqPem];
    FILE *csrOut = fopen([csrPath cStringUsingEncoding:NSUTF8StringEncoding], "wb");
    ret = PEM_write_X509_REQ(csrOut, x509Req);
    fclose(csrOut);
    X509_REQ_free(x509Req);
    
    if (ret != 1) {
        NSLog(@"写入SecFileX509ReqPem失败");
        return NO;
    }
    
    CRYPTO_cleanup_all_ex_data();

    NSLog(@"生成证书请求文件成功");
    return YES;
}

/**
 *  利用directory下的证书文件SecFileX509Cert和私钥SecFilePriKeyPem合成p12文件SecFileP12
 *
 *  @param directory 执行目录
 *
 *  @return 是否设执行成功标识（YES/NO）
 */
+ (BOOL)generateP12InDir:(NSString *)directory {
    // 检查文件夹是否存在，不存在返回NO
    BOOL isDir = NO;
    BOOL isFileExist = [[NSFileManager defaultManager] fileExistsAtPath:directory isDirectory:&isDir];
    if (!isFileExist || !isDir) {
        return NO;
    }
    
    // should init openssl at the first of time and only once
    CRYPTO_malloc_init();
    ERR_load_crypto_strings();
    OpenSSL_add_all_algorithms();
    OpenSSL_add_all_ciphers();
    OpenSSL_add_all_digests();
    
    // 读入私钥
    NSString *priPath = [directory stringByAppendingPathComponent:SecFilePriKeyPem];
    FILE *priFilePtr = fopen([priPath cStringUsingEncoding:NSUTF8StringEncoding], "rb");
    if (NULL == priFilePtr) {
        NSLog(@"无法打开SecFilePriKeyPem");
        
        EVP_cleanup();
        CRYPTO_cleanup_all_ex_data();
        return NO;
    }
    RSA *priRsa = PEM_read_RSAPrivateKey(priFilePtr, NULL, NULL, NULL);
    fclose(priFilePtr);

    EVP_PKEY *pKeyPri = EVP_PKEY_new();
    EVP_PKEY_assign_RSA(pKeyPri, priRsa);
    
    // 读入X509证书
    NSString *cerPath = [directory stringByAppendingPathComponent:SecFileX509Cert];
    FILE *cerFilePtr = fopen([cerPath cStringUsingEncoding:NSUTF8StringEncoding], "rb");
    if (cerFilePtr == NULL) {
        NSLog(@"无法打开SecFileX509Cert");
        
        EVP_PKEY_free(pKeyPri);
        EVP_cleanup();
        CRYPTO_cleanup_all_ex_data();
        return NO;
    }
    X509 *cert = PEM_read_X509(cerFilePtr, NULL, NULL, NULL);
    fclose(cerFilePtr);
    
    // 产生PKCS12内容
    PKCS12 *p12 = PKCS12_create("RVslMa/sC/aH6DAR6T19aQ", NULL, pKeyPri, cert, NULL, 0, 0, 0, 0, 0);
    EVP_PKEY_free(pKeyPri);
    X509_free(cert);
    if (!p12) {
        NSLog(@"创建PKCS#12结构失败");
        ERR_print_errors_fp(stderr);
        
        EVP_cleanup();
        CRYPTO_cleanup_all_ex_data();
        return NO;
    }
    
    // 写入p12文件
    NSString *p12Path = [directory stringByAppendingPathComponent:SecFileP12];  // 正式文件
    NSString *p12TmpPath = [NSString stringWithFormat:@"%@.tmp", p12Path];  // 临时文件
    FILE *p12FilePtr = fopen([p12TmpPath cStringUsingEncoding:NSUTF8StringEncoding], "wb");
    if (p12FilePtr == NULL) {
        NSLog(@"写入SecFileP12失败");
        
        PKCS12_free(p12);
        EVP_cleanup();
        CRYPTO_cleanup_all_ex_data();
        return NO;
    }
    i2d_PKCS12_fp(p12FilePtr, p12);
    PKCS12_free(p12);
    fclose(p12FilePtr);

    EVP_cleanup();  // frees all three stacks and sets their pointers to NULL ---- EVP_CIPHER
    CRYPTO_cleanup_all_ex_data();
    
    // 将P12文件数据加密后写入正式文件
    NSData *p12Data = [NSData dataWithContentsOfFile:p12TmpPath];
    NSData *cryptP12Data = [[[CryptoManager alloc] init] encryptData:p12Data];
    [cryptP12Data writeToFile:p12Path atomically:YES];
    // 原始的文件数据写入全局变量
    [AppDelegate delegate].decryptedP12Data = [NSData dataWithData:p12Data];
    
    
    // 删除各种临时文件：公私钥证书等
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:p12TmpPath error:nil];
    [fileManager removeItemAtPath:[directory stringByAppendingPathComponent:SecFilePriKeyPem] error:nil];
    [fileManager removeItemAtPath:[directory stringByAppendingPathComponent:SecFilePubKeyPem] error:nil];
    [fileManager removeItemAtPath:[directory stringByAppendingPathComponent:SecFileX509ReqPem] error:nil];
    [fileManager removeItemAtPath:[directory stringByAppendingPathComponent:SecFileX509Cert] error:nil];
    
    NSLog(@"生成P12文件成功");
    return YES;
}

/**
 *  检查directory下p12文件SecFileP12文件是否存在
 *
 *  @param directory 执行目录
 *
 *  @return 文件是否存在标识（YES/NO）
 */
+ (BOOL)isP12ExistInDir:(NSString *)directory {
    if (directory == nil) {
        return NO;
    }
    
    NSString *p12FilePath = [directory stringByAppendingPathComponent:SecFileP12];
    return [[NSFileManager defaultManager] fileExistsAtPath:p12FilePath];
}

/**
 *  获取一个默认证书文件目录，如果目录不存在，生成之
 *
 *  @return 目录路径
 */
+ (NSString *)defaultCertDir {
    // 获取应用程序沙盒的Documents目录
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDir = [paths objectAtIndex:0];
    
    // 拼装证书目录certDir
    NSString *folerName = @"maytheforcebewithyou";//@"cert";
    NSString *certDir = [documentDir stringByAppendingPathComponent:folerName];
    
    // 判断路径是否存在，是否是文件夹
    BOOL isDir = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isFileExist = [fileManager fileExistsAtPath:certDir isDirectory:&isDir];

    if (isFileExist && isDir) {  // 路径存在且为目录，do nothing
    }
    else if (isFileExist && !isDir) {  // 路径存在但不是目录，删除并生成目录
        [fileManager removeItemAtPath:certDir error:nil];
        [fileManager createDirectoryAtPath:certDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    else {  // 文件不存在，生成目录
        [fileManager createDirectoryAtPath:certDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return certDir;
}

@end
