//
//  CIBResourceInfo.h
//  CIBSafeBrowser
//
//  Created by 陈宇劢 on 15/5/6.
//  Copyright (c) 2015年 cib. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CIBResourceInfo : NSObject

@property(nonatomic, retain)  NSString *urlAddress;
@property(nonatomic, retain)  NSString *fileName;
@property(nonatomic, retain)  NSString *versionCode;
@property(nonatomic, retain)  NSString *mimeType;
@property(nonatomic, retain)  NSString *encodingType;

- (id)initWithUrlAddress:(NSString *)urlAddress
                fileName:(NSString *)fileName
             versionCode:(NSString *)versionCode
                mimeType:(NSString *)mimeType
            encodingType:(NSString *)encodingType;
@end
