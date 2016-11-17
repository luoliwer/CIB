//
//  CoreDataManager.m
//  CIBSafeBrowser
//
//  Created by CIB-Mac mini on 14-9-1.
//  Copyright (c) 2014年 cib. All rights reserved.
//

#import "CoreDataManager.h"
#import "AppInfo.h"
#import "AppProduct.h"
#import "UpdateInfo.h"
#import "FileInfo.h"
#import "DownloadFile.h"
#import "UserInfo.h"
#import "Config.h"
#import "AppDelegate.h"
#import <CIBBaseSDK/CryptoManager.h>

#import "AppFavor.h"

@implementation CoreDataManager

@synthesize managedObjectContext = _managedObjectContext;

- (NSManagedObjectContext *)managedObjectContext {
    if (_managedObjectContext == nil) {
        
        NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        NSURL *storedDBURL = [url URLByAppendingPathComponent:@"Model.sqlite"];
        NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                                 
                                 [NSNumber numberWithBool:YES],
                                 
                                 NSMigratePersistentStoresAutomaticallyOption,
                                 
                                 [NSNumber numberWithBool:YES],
                                 
                                 NSInferMappingModelAutomaticallyOption, nil];
        
        
        NSError *error = nil;
        
        NSPersistentStoreCoordinator *persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[NSManagedObjectModel mergedModelFromBundles:nil]];
        
        if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storedDBURL options:options error:&error]) {
            CIBLog(@"Error while loading persistent store ...%@",error);
        }
        
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        
        [_managedObjectContext setPersistentStoreCoordinator:persistentStoreCoordinator];
    }
    
    return _managedObjectContext;
}
#pragma mark-- appFavors相关操作
// 获取所有收藏
- (NSMutableArray *)getAppFavorList {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *query = [NSEntityDescription entityForName:@"AppFavor" inManagedObjectContext:self.managedObjectContext];
    [request setEntity:query];
    NSError *error = nil;
    NSArray *results = [self.managedObjectContext executeFetchRequest:request error:&error];
    if (results == nil || [results count] == 0) {
        return nil;
    }
    NSMutableArray *array = [NSMutableArray arrayWithArray:results];
    [array sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        NSNumber *sort1  =((AppFavor* )obj1).sortIndex;
        NSNumber *sort2  = ((AppFavor* )obj1).sortIndex;
        NSComparisonResult result = [sort1 compare:sort2];
        return result==NSOrderedDescending;//// 升序
    }];
    return array;
}
// 根据App名获取信息
- (AppFavor *)getAppFavorByName:(NSString *)name {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *query = [NSEntityDescription entityForName:@"AppFavor" inManagedObjectContext:self.managedObjectContext];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"appName==%@", name];
    [request setEntity:query];
    [request setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *results = [self.managedObjectContext executeFetchRequest:request error:&error];
    if (results == nil || [results count] == 0) {
        return nil;
    }
    else {
        AppFavor *result = [results objectAtIndex:0];
        return result;
    }
}
// 更新APPFavors信息
- (BOOL)updateAppFavor:(AppFavor *)app {
    AppFavor *targetApp = [self getAppFavorByName:app.appName];
    if (targetApp == nil) {
        CIBLog(@"CoreDataManager: app %@ not exist", app.appName);
        return NO;
    }
    
    targetApp.sortIndex = app.sortIndex;
    NSError *error = nil;
    if ([self.managedObjectContext hasChanges]) {
        if (![self.managedObjectContext save:&error]) {
            CIBLog(@"CoreDataManager updateAppInfo err:%@", [error localizedDescription]);
            return NO;
        }
        else {
            return YES;
        }
    }
    return NO;
}
-(BOOL) deleteAppFavor:(NSString*)appName{
    AppFavor* app = [self getAppFavorByName:appName];
    if(app){
       [self.managedObjectContext deleteObject:app];
    
        NSError *error = nil;
        if (![self.managedObjectContext save:&error]) {
            CIBLog(@"CoreDataManager deleteAppFavor err:%@", [error localizedDescription]);
        }
    }
    return YES;
}
-(BOOL) insertAppFavorWithAppName:(NSString*) appName sortIndex:(int) sortIndex{
    [self deleteAppFavor:appName];
    AppFavor *aInfo = (AppFavor *)[NSEntityDescription insertNewObjectForEntityForName:@"AppFavor" inManagedObjectContext:self.managedObjectContext];
    aInfo.appName = appName;
    aInfo.sortIndex = [NSNumber numberWithInt:sortIndex];
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        CIBLog(@"CoreDataManager insertAppInfo err:%@", [error localizedDescription]);
        return NO;
    }
    else {
        return YES;
    }
}
// 插入应用信息(清空原来)
- (BOOL)insertAppFavors:(NSArray *)apps {
    // 清空数据库
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"AppFavor"];
    NSArray *arr = [self.managedObjectContext executeFetchRequest:request error:nil];
    for (NSManagedObject *obj in arr) {
        [self.managedObjectContext deleteObject:obj];
    }
    // 同步数据库
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        CIBLog(@"CoreDataManager insertAppFavors err:%@", [error localizedDescription]);
        return NO;
    }
    
    BOOL flag = YES;
    for (AppFavor *app in apps) {
        flag &= [self insertAppFavorWithAppName:app.appName sortIndex:[app.sortIndex intValue]];
    }
    return flag;
}
#pragma mark-- appFavor结束＃＃＃＃＃＃＃＃＃＃＃＃＃





// cao
// 根据App名获取信息
- (AppInfo *)getAppByName:(NSString *)name {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *query = [NSEntityDescription entityForName:@"AppInfo" inManagedObjectContext:self.managedObjectContext];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"appName==%@", name];
    [request setEntity:query];
    [request setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *results = [self.managedObjectContext executeFetchRequest:request error:&error];
    if (results == nil || [results count] == 0) {
        return nil;
    }
    else {
        AppInfo *result = [results objectAtIndex:0];
        return result;
    }
}
// cao
// 更新APP信息
- (BOOL)updateAppInfo:(AppProduct *)app {
    AppInfo *targetApp = [self getAppByName:app.appName];
    if (targetApp == nil) {
        CIBLog(@"CoreDataManager: app %@ not exist", app.appName);
        return NO;
    }
    
    targetApp.isFavorite = [NSNumber numberWithBool:app.isFavorite];
    targetApp.appNo = [NSNumber numberWithInt:[app.appNo intValue]];
    targetApp.showName = app.appShowName;
    targetApp.type = app.type;
    targetApp.status = app.status;
    targetApp.releaseTime = app.releaseTime;
    targetApp.notiNo = app.notiNo;
    
    //新增排序使用
    targetApp.sortIndex = [NSNumber numberWithInt:app.sortIndex];
    CryptoManager *manager = [[CryptoManager alloc] init];
    NSString *cipheredIndexURL = [manager encryptString:app.appIndexUrl];
    NSString *cipheredIconURL = [manager encryptString:app.appIconUrl];
    targetApp.indexURL = cipheredIndexURL;
    targetApp.iconURL = cipheredIconURL;
    
    if (app.isFavorite) {
        targetApp.favoriteTimeStamp = [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]];
    }
    NSError *error = nil;
    if ([self.managedObjectContext hasChanges]) {
        if (![self.managedObjectContext save:&error]) {
            CIBLog(@"CoreDataManager updateAppInfo err:%@", [error localizedDescription]);
            return NO;
        }
        else {
            return YES;
        }
    }
    
    return NO;
}

// 插入应用信息
- (BOOL)insertAppInfo:(AppProduct *)app {
    AppInfo *aInfo = (AppInfo *)[NSEntityDescription insertNewObjectForEntityForName:@"AppInfo" inManagedObjectContext:self.managedObjectContext];
    aInfo.appNo = [NSNumber numberWithInt:[app.appNo intValue]];
    aInfo.appName = app.appName;
    aInfo.showName = app.appShowName;
    //    aInfo.indexURL = app.appIndexUrl;
    //    aInfo.iconURL = app.appIconUrl;
    aInfo.type = app.type;
    aInfo.status = app.status;
    aInfo.releaseTime = app.releaseTime;
    aInfo.isFavorite = [NSNumber numberWithBool:app.isFavorite];
    if (app.isFavorite) {
        aInfo.favoriteTimeStamp = app.favoriteTimeStamp;
    }
    CryptoManager *manager = [[CryptoManager alloc] init];
    NSString *cipheredIndexURL = [manager encryptString:app.appIndexUrl];
    NSString *cipheredIconURL = [manager encryptString:app.appIconUrl];
    aInfo.indexURL = cipheredIndexURL;
    aInfo.iconURL = cipheredIconURL;
    
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        CIBLog(@"CoreDataManager insertAppInfo err:%@", [error localizedDescription]);
        return NO;
    }
    else {
        return YES;
    }
}

// 插入应用信息(清空原来)
- (BOOL)insertAppInfos:(NSArray *)apps {
    // 清空数据库
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"AppInfo"];
    NSArray *arr = [self.managedObjectContext executeFetchRequest:request error:nil];
    for (NSManagedObject *obj in arr) {
        [self.managedObjectContext deleteObject:obj];
    }
    // 同步数据库
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        CIBLog(@"CoreDataManager insertAppInfos err:%@", [error localizedDescription]);
        return NO;
    }
    
    BOOL flag = YES;
    for (AppProduct *app in apps) {
        flag &= [self insertAppInfo:app];
    }
    
    return flag;
}

// 获取所有应用列表
- (NSArray *)getAppList {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *query = [NSEntityDescription entityForName:@"AppInfo" inManagedObjectContext:self.managedObjectContext];
    [request setEntity:query];
    
    //    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"favoriteTimeStamp" ascending:YES];
    //    [request setSortDescriptors:[NSArray arrayWithObject:sort]];
    
    NSError *error = nil;
    NSArray *results = [self.managedObjectContext executeFetchRequest:request error:&error];
    if (results == nil || [results count] == 0) {
        return [[NSMutableArray alloc] init];
    }
    else {
        // change the AppInfo into AppProduct
        NSMutableArray *appList = [[NSMutableArray alloc] init];
        for (AppInfo *info in results) {
            AppProduct *app = [[AppProduct alloc] init];
            app.appNo = info.appNo;
            app.appName = info.appName;
            app.appShowName = info.showName;
            app.type = info.type;
            app.status = info.status;
            //            app.appIndexUrl = info.indexURL;
            //            app.appIconUrl = info.iconURL;
            app.releaseTime = info.releaseTime;
            app.isFavorite = [info.isFavorite boolValue];
            app.favoriteTimeStamp = info.favoriteTimeStamp;
            // 添加通知数目字段
            app.notiNo = info.notiNo;
            
            CryptoManager *manager = [[CryptoManager alloc] init];
            NSString *indexURL = [manager decryptString:info.indexURL];
            NSString *iconURL = [manager decryptString:info.iconURL];
            app.appIndexUrl = indexURL;
            app.appIconUrl = iconURL;
            
            //排序后 面新增字段
            app.sortIndex=[info.sortIndex intValue];
            
            [appList addObject:app];
        }
        return (NSArray *)appList;
    }
}

// 获取某项内容的更新时间
- (float)getUpdateTimeByName:(NSString *)name {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *query = [NSEntityDescription entityForName:@"UpdateInfo" inManagedObjectContext:self.managedObjectContext];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"updateName==%@", name];
    [request setEntity:query];
    [request setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *results = [self.managedObjectContext executeFetchRequest:request error:&error];
    if (results == nil || [results count] == 0) {
        return 0.0;
    }
    else {
        return [((UpdateInfo *)[results objectAtIndex:0]).updateTime floatValue];
    }
}


// 更新某项内容的更新时间
- (BOOL)updateUpdateTimeByName:(NSString *)name {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *query = [NSEntityDescription entityForName:@"UpdateInfo" inManagedObjectContext:self.managedObjectContext];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"updateName==%@", name];
    [request setEntity:query];
    [request setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *results = [self.managedObjectContext executeFetchRequest:request error:&error];
    if (results == nil || [results count] == 0) {
        
        UpdateInfo *targetApp = (UpdateInfo *)[NSEntityDescription insertNewObjectForEntityForName:@"UpdateInfo" inManagedObjectContext:self.managedObjectContext];
        targetApp.updateName = name;
        targetApp.updateTime = [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]];
        
    }
    else {
        UpdateInfo *targetInfo = (UpdateInfo *)[results objectAtIndex:0];
        targetInfo.updateTime = [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]];
    }
    
    if ([self.managedObjectContext hasChanges]) {
        if (![self.managedObjectContext save:&error]) {
            CIBLog(@"CoreDataManager updateUpdateTimeByName err:%@", [error localizedDescription]);
            return NO;
        }
        else {
            return YES;
        }
    }
    
    return NO;
}

- (BOOL)resetUpdateTimeByName:(NSString *)name {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *query = [NSEntityDescription entityForName:@"UpdateInfo" inManagedObjectContext:self.managedObjectContext];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"updateName==%@", name];
    [request setEntity:query];
    [request setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *results = [self.managedObjectContext executeFetchRequest:request error:&error];
    if (results == nil || [results count] == 0) {
        
        UpdateInfo *targetApp = (UpdateInfo *)[NSEntityDescription insertNewObjectForEntityForName:@"UpdateInfo" inManagedObjectContext:self.managedObjectContext];
        targetApp.updateName = name;
        targetApp.updateTime = [NSNumber numberWithFloat:0.0f];
        
    }
    else {
        UpdateInfo *targetInfo = (UpdateInfo *)[results objectAtIndex:0];
        targetInfo.updateTime = [NSNumber numberWithFloat:0.0f];
    }
    
    if ([self.managedObjectContext hasChanges]) {
        if (![self.managedObjectContext save:&error]) {
            CIBLog(@"CoreDataManager resetUpdateTimeByName err:%@", [error localizedDescription]);
            return NO;
        }
        else {
            return YES;
        }
    }
    
    return NO;
}

// 根据文件别名判断文件是否存在
- (BOOL)isFileExist:(NSString *)alias {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *query = [NSEntityDescription entityForName:@"FileInfo" inManagedObjectContext:self.managedObjectContext];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"fileAlias==%@", alias];
    [request setEntity:query];
    [request setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *results = [self.managedObjectContext executeFetchRequest:request error:&error];
    if (results == nil || [results count] == 0) {
        return NO;
    }
    else {
        return YES;
    }
}

//更新数据库中的文件下载状态字段
- (BOOL)updateFileStatusOfFileInfo:(DownloadFile *)file{
    NSFetchRequest *request = [[NSFetchRequest alloc]init];
    NSEntityDescription *query = [NSEntityDescription entityForName:@"FileInfo" inManagedObjectContext:self.managedObjectContext];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"fileAlias == %@",file.fileAlias];
    [request setEntity:query];
    [request setPredicate:predicate];
    NSError *error = nil;
    NSArray *results = [self.managedObjectContext executeFetchRequest:request error:&error];
    if (results == nil || [results count] == 0) {
        [self insertFileInfo:file];
    }
    else{
        for (FileInfo *info in results) {
            
            info.fileName = file.fileName;
            info.fileAlias = file.fileAlias;
            info.mimeType = file.mimeType;
            info.downloadTime = file.downloadTime;
            info.downloadStatus = file.downloadStatus;
        }
    }
    if ([self.managedObjectContext hasChanges]) {
        if (![self.managedObjectContext save:&error]) {
            CIBLog(@"CoreDataManager updateAppInfo err:%@", [error localizedDescription]);
            return NO;
        }
        else {
            return YES;
        }
    }
    return NO;
}
//通过别名获取对应的文件
- (DownloadFile *)getFileByFileAlias:(NSString *)fileAlias{
    
    NSFetchRequest *request = [[NSFetchRequest alloc]init];
    NSEntityDescription *query = [NSEntityDescription entityForName:@"FileInfo" inManagedObjectContext:self.managedObjectContext];
    [request setEntity:query];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"fileAlias==%@", fileAlias];
    [request setPredicate:predicate];
    NSError *error = nil;
    NSArray *results = [self.managedObjectContext executeFetchRequest:request error:&error];
    if (results == nil) {
        return nil;
    }
    for (FileInfo *info in results) {
        DownloadFile *file = [[DownloadFile alloc]init];
        file.fileName = info.fileName;
        file.fileAlias = info.fileAlias;
        file.mimeType = info.mimeType;
        file.downloadTime = info.downloadTime;
        file.downloadStatus = info.downloadStatus;
        return file;
    }
    
    
    
    return  nil;
}


// 获取所有文件列表
- (NSArray *)getFileList {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *query = [NSEntityDescription entityForName:@"FileInfo" inManagedObjectContext:self.managedObjectContext];
    [request setEntity:query];
    
    NSError *error = nil;
    NSArray *results = [self.managedObjectContext executeFetchRequest:request error:&error];
    if (results == nil || [results count] == 0) {
        return nil;
    }
    else {
        // change the FileInfo into DownloadFile
        NSMutableArray *fileList = [[NSMutableArray alloc] init];
        for (FileInfo *info in results) {
            DownloadFile *file = [[DownloadFile alloc] init];
            file.fileName = info.fileName;
            file.fileAlias = info.fileAlias;
            file.mimeType = info.mimeType;
            file.downloadTime = info.downloadTime;
            file.downloadStatus = info.downloadStatus;
            [fileList addObject:file];
        }
        
        return (NSArray *)fileList;
    }
}

// 插入文件信息
- (BOOL)insertFileInfo:(DownloadFile *)file {
    FileInfo *info = (FileInfo *)[NSEntityDescription insertNewObjectForEntityForName:@"FileInfo" inManagedObjectContext:self.managedObjectContext];
    info.fileName = file.fileName;
    info.fileAlias = file.fileAlias;
    info.mimeType = file.mimeType;
    info.downloadTime = file.downloadTime;
    info.downloadStatus = file.downloadStatus;
    
    NSError *error = nil;;
    if (![self.managedObjectContext save:&error]) {
        CIBLog(@"CoreDataManager insertFileInfo err:%@", [error localizedDescription]);
        return NO;
    }
    else {
        return YES;
    }
    
}

// 删除文件信息
- (BOOL)deleteFileInfoByAlias:(NSString *)alias {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *query = [NSEntityDescription entityForName:@"FileInfo" inManagedObjectContext:self.managedObjectContext];
    [request setEntity:query];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"fileAlias==%@", alias];
    [request setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *results = [self.managedObjectContext executeFetchRequest:request error:&error];
    if (results == nil) {
        return NO;
    }
    
    for (FileInfo *info in results) {
        [self.managedObjectContext deleteObject:info];
    }
    
    if (![self.managedObjectContext save:&error]) {
        CIBLog(@"CoreDataManager deleteFileInfoByAlias err:%@", [error localizedDescription]);
        return NO;
    }
    
    return YES;
}

- (void)resetData {
    // 清空应用表
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"AppInfo"];
    NSArray *arr = [self.managedObjectContext executeFetchRequest:request error:nil];
    for (NSManagedObject *obj in arr) {
        [self.managedObjectContext deleteObject:obj];
    }
    
    //清空应用收藏表
    NSFetchRequest *request1 = [NSFetchRequest fetchRequestWithEntityName:@"AppFavor"];
    NSArray *arr1 = [self.managedObjectContext executeFetchRequest:request1 error:nil];
    for (NSManagedObject *obj in arr1) {
        [self.managedObjectContext deleteObject:obj];
    }
    
    // 清空文件表
    request = [NSFetchRequest fetchRequestWithEntityName:@"FileInfo"];
    arr = [self.managedObjectContext executeFetchRequest:request error:nil];
    for (NSManagedObject *obj in arr) {
        [self.managedObjectContext deleteObject:obj];
    }
    
    // 清空更新表
    request = [NSFetchRequest fetchRequestWithEntityName:@"UpdateInfo"];
    arr = [self.managedObjectContext executeFetchRequest:request error:nil];
    for (NSManagedObject *obj in arr) {
        [self.managedObjectContext deleteObject:obj];
    }
    
    // 更新明文临时变量为空 需要重新从数据库中读取
    [[AppDelegate delegate] setAppProductList:nil];
}

- (NSString *)lastUserId {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *query = [NSEntityDescription entityForName:@"UserInfo" inManagedObjectContext:self.managedObjectContext];
    [request setEntity:query];
    
    NSError *error = nil;
    NSArray *results = [self.managedObjectContext executeFetchRequest:request error:&error];
    if (results == nil || [results count] == 0) {
        return @"";
    }
    else {
        UserInfo *info = results[0];
        return info.userId;
    }
}

- (BOOL)setLastUserId:(NSString *)userId {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *query = [NSEntityDescription entityForName:@"UserInfo" inManagedObjectContext:self.managedObjectContext];
    [request setEntity:query];
    
    NSError *error = nil;
    NSArray *results = [self.managedObjectContext executeFetchRequest:request error:&error];
    if (results == nil || [results count] == 0) {
        
        UserInfo *info = (UserInfo *)[NSEntityDescription insertNewObjectForEntityForName:@"UserInfo" inManagedObjectContext:self.managedObjectContext];
        info.userId = userId;
        
    }
    else {
        UserInfo *info = (UserInfo *)[results objectAtIndex:0];
        info.userId = userId;
    }
    
    if ([self.managedObjectContext hasChanges]) {
        if (![self.managedObjectContext save:&error]) {
            CIBLog(@"CoreDataManager setLastUserId err:%@", [error localizedDescription]);
            return NO;
        }
        else {
            return YES;
        }
    }
    
    return NO;
}

- (AppProduct *)getAppProductByAppNo:(NSNumber *)appNo {
    AppProduct *app = [[AppProduct alloc] init];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *query = [NSEntityDescription entityForName:@"AppInfo" inManagedObjectContext:self.managedObjectContext];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"appNo==%@", appNo];
    [request setEntity:query];
    [request setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *results = [self.managedObjectContext executeFetchRequest:request error:&error];
    if (results == nil || [results count] == 0) {
        return nil;
    }
    else {
        AppInfo *info = [results objectAtIndex:0];
        app.appNo = info.appNo;
        app.appName = info.appName;
        app.appShowName = info.showName;
        app.type = info.type;
        app.status = info.status;
        //        app.appIndexUrl = info.indexURL;
        //        app.appIconUrl = info.iconURL;
        app.releaseTime = info.releaseTime;
        app.isFavorite = [info.isFavorite boolValue];
        app.favoriteTimeStamp = info.favoriteTimeStamp;
        app.notiNo = info.notiNo;
        CryptoManager *manager = [[CryptoManager alloc] init];
        NSString *indexURL = [manager decryptString:info.indexURL];
        NSString *iconURL = [manager decryptString:info.iconURL];
        app.appIndexUrl = indexURL;
        app.appIconUrl = iconURL;
        return app;
    }
}

- (AppProduct *)getAppProductByAppName:(NSString *)appName {
    AppProduct *app = [[AppProduct alloc] init];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *query = [NSEntityDescription entityForName:@"AppInfo" inManagedObjectContext:self.managedObjectContext];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"appName==%@", appName];
    [request setEntity:query];
    [request setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *results = [self.managedObjectContext executeFetchRequest:request error:&error];
    if (results == nil || [results count] == 0) {
        return nil;
    }
    else {
        AppInfo *info = [results objectAtIndex:0];
        app.appNo = info.appNo;
        app.appName = info.appName;
        app.appShowName = info.showName;
        app.type = info.type;
        app.status = info.status;
        app.releaseTime = info.releaseTime;
        app.isFavorite = [info.isFavorite boolValue];
        app.favoriteTimeStamp = info.favoriteTimeStamp;
        app.notiNo = info.notiNo;
        CryptoManager *manager = [[CryptoManager alloc] init];
        NSString *indexURL = [manager decryptString:info.indexURL];
        NSString *iconURL = [manager decryptString:info.iconURL];
        app.appIndexUrl = indexURL;
        app.appIconUrl = iconURL;
        return app;
    }
}

- (BOOL)migrateAppInfoToCipher {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *query = [NSEntityDescription entityForName:@"AppInfo" inManagedObjectContext:self.managedObjectContext];
    [request setEntity:query];
    
    NSError *error = nil;
    NSArray *results = [self.managedObjectContext executeFetchRequest:request error:&error];
    if (results == nil || [results count] == 0) {
        return NO;
    }
    else {
        // 加密AppInfo中的indexURL和iconURL字段
        for (AppInfo *info in results) {
            CryptoManager *manager = [[CryptoManager alloc] init];
            NSString *indexURL = [manager encryptString:info.indexURL];
            NSString *iconURL = [manager encryptString:info.iconURL];
            info.indexURL = indexURL;
            info.iconURL = iconURL;
        }
        NSError *error = nil;
        if ([self.managedObjectContext hasChanges]) {
            if (![self.managedObjectContext save:&error]) {
                CIBLog(@"CoreDataManager updateAppInfo err:%@", [error localizedDescription]);
                return NO;
            }
            else {
                return YES;
            }
        }
        
        return NO;
    }
    
}

@end
