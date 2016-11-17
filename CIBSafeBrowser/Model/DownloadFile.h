//
//  DownloadFile.h
//  CIBSafeBrowser
//
//  Created by cib on 14/12/25.
//  Copyright (c) 2014年 cib. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FileInfo.h"

@interface DownloadFile : NSObject

@property (strong, nonatomic) NSString *fileName;  // 文件原名，用于显示
@property (strong, nonatomic) NSString *fileAlias; // 文件url经hash后得到的别名，用于存储和检验文件是否存在
@property (strong, nonatomic) NSString *mimeType;  // 文件MIME类型，用于打开
@property (strong, nonatomic) NSString *downloadTime;  // 下载时间
@property (assign, nonatomic) FileDownloadStatus downloadStatus; //下载状态
@end
