//
//  CoreDataManager.h
//  CIBSafeBrowser
//
//  Created by CIB-Mac mini on 14-9-1.
//  Copyright (c) 2014年 cib. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "AppProduct.h"
#import "DownloadFile.h"
@class AppFavor;

@interface CoreDataManager : NSObject

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (NSArray *)getAppList;  // 获取所有应用列表
- (BOOL)updateAppInfo:(AppProduct *)app;  // 更新APP信息
- (BOOL)insertAppInfos:(NSArray *)apps;  // 插入应用信息

- (float)getUpdateTimeByName:(NSString *)name;  // 获取某项内容的更新时间
- (BOOL)updateUpdateTimeByName:(NSString *)name;  // 更新某项内容的更新时间
- (BOOL)resetUpdateTimeByName:(NSString *)name;  // 重置某项内容的更新时间

- (BOOL)isFileExist:(NSString *)alias;  // 根据文件别名判断文件是否存在
- (NSArray *)getFileList;  // 获取所有文件列表
- (BOOL)insertFileInfo:(DownloadFile *)file;  // 插入文件信息
- (BOOL)deleteFileInfoByAlias:(NSString *)alias;  // 根据别名删除文件信息
- (DownloadFile *)getFileByFileAlias:(NSString *)fileAlias; //根据别名找到对应的文件
- (BOOL)updateFileStatusOfFileInfo:(DownloadFile *)file; //更新数据库中文件下载状态字段
- (void)resetData;  // 清空所有数据

- (NSString *)lastUserId;  // 获取上个登录id
- (BOOL)setLastUserId:(NSString *)userId;  // 设置最近登录id

- (AppProduct *)getAppProductByAppNo:(NSNumber *)appNo; // 根据appno查询整条app记录

- (AppProduct *)getAppProductByAppName:(NSString *)appName; // 根据appName查询整条app记录

- (BOOL)migrateAppInfoToCipher;



// appFavor 相关
//- (AppFavor *)getAppFavorByName:(NSString *)name;
- (BOOL)insertAppFavors:(NSArray *)apps;
-(BOOL) insertAppFavorWithAppName:(NSString*) appName sortIndex:(int) sortIndex;
-(BOOL) deleteAppFavor:(NSString*)appName;
- (NSMutableArray *)getAppFavorList;
- (BOOL)updateAppFavor:(AppFavor *)app ;
@end
