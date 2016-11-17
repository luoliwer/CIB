//
//  DatabaseManageHelper.h
//  SqlitePlugInDemo
//
//  Created by YangChao on 21/12/15.
//  Copyright © 2015年 swy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DatabaseManageHelper : NSObject

//@property (copy, nonatomic) NSString *dbPath;

+ (instancetype)sharedManagerHelper;

/**
 *  打开数据库，如果数据库不存在，先创建数据库。
 *  @pragram dbName  数据库名称
 *
 *  return YES 打开成功， NO 打开失败
 */
- (BOOL)openDatabase:(NSString *)dbName;


/**
 *  关闭数据库
 *  @pragram dbName  数据库名称
 *
 *  return YES 成功， NO 失败
 */
- (void)closeDatabase:(NSString *)dbName;

///**
// *  通过传入表名称和表的列明，创建对应的表
// *  @pragram sql 创建表的sql语句
// *  return YES 删除成功， NO 删除失败
// */
//- (BOOL)createTableWithSql:(NSString *)sql;
//
///**
// *  通过传入参数，删除对应的存在表
// *  @pragram tableName  传入待删除的表名称
// 
// *  return YES 删除成功， NO 删除失败
// */
//- (BOOL)deleteTable:(NSString *)sql;

/**
 *  通过传入sql语句，可以创建表、插入、删除、修改对应的sql语句以及删除表操作
 *  @pragram sqls  传入待执行的sql语句，可以传入多条sql，用分号隔开
 
 *  return 是否操作成功，YES 操作成功 NO操作失败。
 */
- (BOOL)excuSQL:(NSString *)sqls;

/**
 *  通过传入sql语句，查询结果，并将返回的数据拼接成需要的Json字符串
 *  @pragram sqls  传入待执行的sql语句
 
 *  return 字符串 将查询的数据返回成JSON串。
 */
- (NSString *)query:(NSString *)sql params:(NSArray *)params;

@end
