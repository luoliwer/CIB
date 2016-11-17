//
//  CIBHttpsRequset.h
//  CIBSafeBrowser
//
//  Created by cib on 8/10/14.
//  Copyright (c) 2014 cib. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CIBHttpsRequset : NSObject

+ (SecIdentityRef)identityWithCert;

+ (BOOL)identity:(SecIdentityRef *)outIdentity
  andCertificate:(SecCertificateRef*)outCert
  fromPKCS12Data:(NSData *)inPKCS12Data;

@end
