//
//  FileInfo.h
//  CIBSafeBrowser
//
//  Created by cib on 14/12/25.
//  Copyright (c) 2014年 cib. All rights reserved.
//

#import <CoreData/CoreData.h>
typedef enum{
    FileDownloaded = 0,
    FileUndownload,
    FileDownloading,
}FileDownloadStatus;

@interface FileInfo : NSManagedObject

@property (nonatomic, retain) NSString *fileName;
@property (nonatomic, retain) NSString *fileAlias; // 文件url经MD5摘要后得到的别名，用于存储和检验文件是否存在
@property (nonatomic, retain) NSString *mimeType;
@property (nonatomic, retain) NSString *downloadTime;
@property (nonatomic, assign) FileDownloadStatus downloadStatus;


@end
