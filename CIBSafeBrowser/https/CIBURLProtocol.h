//
//  CIBURLProtocol.h
//  CIBSafeBrowser
//
//  Created by cib on 8/10/14.
//  Copyright (c) 2014 cib. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    NotiDidReceiveResponse,
    NotiDidReceiveData,
    NotiDidFailWithError,
    NotiDidFinishLoading
} CIBURLProtocolNotiType;
static NSString *CIBURLProtocolNoti = @"CIBURLProtocolNoti";

typedef enum {
    NavTypeLinkClick,
    NavTypeDownload,
    NavTypeOther
} CIBURLProtocolNavType;
static NSString *NavTypeLinkClickStr = @"LinkClick";
static NSString *NavTypeDownloadStr = @"Download";
static NSString *NavigationTypeHeader = @"NavigationType";

static NSString *DidURLHeader = @"CIBURLProtocol";

@interface CIBURLProtocol : NSURLProtocol

@end
