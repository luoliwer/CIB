//
//  DatabaseManageHelper.m
//  SqlitePlugInDemo
//
//  Created by YangChao on 21/12/15.
//  Copyright © 2015年 swy. All rights reserved.
//

#import "DatabaseManageHelper.h"
#import "FMDB.h"

@interface DatabaseManageHelper ()
{
    FMDatabaseQueue   *_queue;
    NSString          *_currentDbPath;
}
@end

static DatabaseManageHelper *sharedManageHelperInstance;

@implementation DatabaseManageHelper

+ (instancetype)sharedManagerHelper
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (sharedManageHelperInstance == nil) {
            sharedManageHelperInstance = [[DatabaseManageHelper alloc] init];
        }
    });
    return sharedManageHelperInstance;
}

/**
 *  打开数据库，如果数据库不存在，先创建数据库。
 *  @pragram dbName  数据库名称
 *
 *  return YES 打开成功， NO 打开失败
 */
- (BOOL)openDatabase:(NSString *)dbName
{
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *dbPath = [documentPath stringByAppendingPathComponent:dbName];
    
    if (_queue && ![_currentDbPath isEqualToString:dbName]) {
        [_queue close];
    }
    
    _queue = [FMDatabaseQueue databaseQueueWithPath:dbPath];
    
    _currentDbPath = dbPath;
    
    return _queue.openFlags;
}

/**
 *  关闭数据库
 *  @pragram dbName  数据库名称
 *
 *  return YES 成功， NO 失败
 */
- (void)closeDatabase:(NSString *)dbName;
{
    [_queue close];
}

///**
// *  通过传入表名称和表的列明，创建对应的表
// *  @pragram sql 创建表的sql语句
// *  return YES 删除成功， NO 删除失败
// */
//- (BOOL)createTableWithSql:(NSString *)sql
//{
//    __block BOOL createSuccess = NO;
//    [_queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
//        createSuccess = [db executeUpdate:sql];
//    }];
//    return createSuccess;
//}
//
///**
// *  通过传入参数，删除对应的存在表
// *  @pragram tableName  传入待删除的表名称
// 
// *  return YES 删除成功， NO 删除失败
// */
//- (BOOL)deleteTable:(NSString *)sql
//{
//    __block BOOL deleted = NO;
//    [_queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
//        deleted = [db executeUpdate:sql];
//    }];
//    return deleted;
//}

/**
 *  通过传入sql语句，可以插入、删除、修改对应的sql语句
 *  @pragram sqls  传入待执行的sql语句，可以传入多条sql，用分号隔开
 
 *  return int 返回最近执行的sql语句对数据表的更新数。
 */
- (BOOL)excuSQL:(NSString *)sqls
{
    __block BOOL changed = NO;
    [_queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        changed = [db executeStatements:sqls];
        
    }];
    return changed;
}

/**
 *  通过传入sql语句，查询结果，并将返回的数据拼接成需要的Json字符串
 *  @pragram sqls  传入待执行的sql语句
 
 *  return 字符串 将查询的数据返回成JSON串。
 */
- (NSString *)query:(NSString *)sql params:(NSArray *)params
{
    __block NSString *jsonStr = @"";
    [_queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        FMResultSet *findResult = [db executeQuery:sql withArgumentsInArray:params];
        if ([db hadError])
        {
            NSLog(@"Error %d : %@",[db lastErrorCode],[db lastErrorMessage]);
        } else {
            jsonStr = [self toJson:findResult];
        }
    }];
    return jsonStr;
}

- (NSString *)toJson:(FMResultSet *)resultSet
{
    NSString *json = nil;
    NSMutableArray *vals = [NSMutableArray array];
    int columns = [resultSet columnCount];
    while ([resultSet next])
    {
        NSMutableDictionary *tempDic = [NSMutableDictionary dictionary];
        for (int i = 0; i < columns; i++) {
            NSString *key = [resultSet columnNameForIndex:i];
            id val = [resultSet objectForColumnIndex:i];
            [tempDic addEntriesFromDictionary:@{key:val}];
        }
        [vals addObject:tempDic];
    }
    [resultSet close];
    
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:vals options:NSJSONWritingPrettyPrinted error:&error];
    if (jsonData.length > 0 && error == nil) {
        json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    return json;
}

@end
