//
//  CIBHttpsRequset.m
//  CIBSafeBrowser
//
//  Created by cib on 8/10/14.
//  Copyright (c) 2014 cib. All rights reserved.
//

#import "CIBHttpsRequset.h"
#import "SecUtils.h"
#import "Config.h"
#import "AppDelegate.h"

#import <CIBBaseSDK/CIBBaseSDK.h>

@implementation CIBHttpsRequset

+ (SecIdentityRef)identityWithCert {
    
    NSData *decryptedData = nil;
    
    if ([AppDelegate delegate].decryptedP12Data) {
        decryptedData = [AppDelegate delegate].decryptedP12Data;
    } else {
        NSString *p12Path = [[SecUtils defaultCertDir] stringByAppendingPathComponent:SecFileP12];
        NSData *p12data = [NSData dataWithContentsOfFile:p12Path];
        decryptedData = [[[CryptoManager alloc] init] decryptData:p12data];
    }
    
    SecIdentityRef identity = NULL;
    SecCertificateRef certificate = NULL;
    
    if (!decryptedData) { // 没有证书文件
        CIBLog(@"Can not load pkcs12 cert , pls check!");
        return NULL;
    }
    
    [[self class] identity:&identity andCertificate:&certificate fromPKCS12Data:decryptedData];
    return identity;
}

+ (BOOL)identity:(SecIdentityRef *)outIdentity andCertificate:(SecCertificateRef*)outCert fromPKCS12Data:(NSData *)inPKCS12Data {
    CIBLog(@"CIBHttpRequest:验证证书");
    
    NSDictionary *optionsDictionary = [NSDictionary dictionaryWithObject:@"RVslMa/sC/aH6DAR6T19aQ" forKey:(__bridge id)kSecImportExportPassphrase];
    CFArrayRef items = CFArrayCreate(NULL, 0, 0, NULL);
    OSStatus securityError = SecPKCS12Import((__bridge CFDataRef)inPKCS12Data,(__bridge CFDictionaryRef)optionsDictionary,&items);
    
    if (securityError == errSecSuccess) {  // No error
        CFDictionaryRef myIdentityAndTrust = CFArrayGetValueAtIndex (items, 0);
        const void *tempIdentity = CFDictionaryGetValue (myIdentityAndTrust, kSecImportItemIdentity);
        *outIdentity = (SecIdentityRef)tempIdentity;
        const void *tempCert = CFDictionaryGetValue (myIdentityAndTrust, kSecImportItemCertChain);
        *outCert = (SecCertificateRef)tempCert;
    }
    else {
        CIBLog(@"SSSSLLLL Failed with error code %d", (int)securityError);
        return NO;
    }
    
    return YES;
}
@end
