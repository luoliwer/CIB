//
//  DataBaseManager.m
//  CommunityFinancial
//
//  Created by wuxiyao on 15/4/21.
//  Copyright (c) 2015年 pactera. All rights reserved.
//

#import "ChatDBManager.h"
#import "Message.h"
#import "Chatter.h"

@interface ChatDBManager ()

@property (nonatomic, strong) FMDatabaseQueue   *queue;

@end

static NSString *messageTable = @"MessageTable";
static NSString *ContactorTable = @"ContactorTable";
static NSString *newestMsgTable = @"NewestMessageTable";

static NSString *contactorIDColumn = @"ContactorID";//联系人id
static NSString *contactorNameColumn = @"contactorName";//联系人姓名
static NSString *iconPathColumn = @"iconPath";//联系人头像路径

static NSString *msgFromerIdColumn = @"MsgFromerId";//消息来自谁
static NSString *msgFromerNameColumn = @"MsgFromerName";//消息来自谁（昵称）
static NSString *msgContentColumn = @"MsgContent";//消息体
static NSString *msgToIdColumn = @"msgToId";//消息发送给谁（昵称）
static NSString *msgToNameColumn = @"MsgToName";//消息发送给谁（昵称）
static NSString *msgTimeColumn = @"MsgTime";//消息发送的时间
static NSString *msgNumColumn = @"MsgNum";//未读消息的数量
static NSString *msgTypeColumn = @"MsgType";//消息是我的还是别人发来的
static NSString *chatTypeColumn = @"ChatType";//单聊/群聊
static NSString *groupIdColumn = @"GroupId";//群号
static NSString *groupNameColumn = @"GroupName";//群昵称
static NSString *fileTypeColumn = @"FileType";//消息的类型 是文本 0 还是图片 1 或者是其他文件形式 2

@implementation ChatDBManager

- (id)init
{
    self = [super init];
    if (self) {
        //加载（创建）数据库
        [self createContactorTable];//创建联系人表
        [self createNewestMessageTable];//创建消息表
        [self createMessageTable];//创建聊天记录表
    }
    return self;
}

+ (ChatDBManager *) sharedDatabaseManager
{
    static dispatch_once_t pred;
    static ChatDBManager *_sharedDatabaseManager = nil;
    dispatch_once(&pred, ^{
        if (_sharedDatabaseManager == nil) {
            _sharedDatabaseManager = [[self alloc] init];
        }
    });
    return _sharedDatabaseManager;
}

#pragma mark - 创建联系人表

-(void)createContactorTable {
    
    NSURL *appUrl = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSString *dbPath = [[appUrl path] stringByAppendingPathComponent:@"chat.db"];
    _queue = [FMDatabaseQueue databaseQueueWithPath:dbPath];
    [_queue inTransaction:^(FMDatabase *_db, BOOL *rollback) {
        NSString *createTableSql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (cid integer primary key asc autoincrement, %@ text, %@ text, %@ text)",ContactorTable, contactorIDColumn, contactorNameColumn, iconPathColumn];
        if(![_db executeUpdate:createTableSql])
        {
            NSLog(@"Could not create table: %@", [_db lastErrorMessage]);
        }
    }];
}

#pragma mark - 创建消息表

-(void)createMessageTable {
    
    NSURL *appUrl = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSString *dbPath = [[appUrl path] stringByAppendingPathComponent:@"chat.db"];
    _queue = [FMDatabaseQueue databaseQueueWithPath:dbPath];
    [_queue inTransaction:^(FMDatabase *_db, BOOL *rollback) {
        NSString *createTableSql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (cid integer primary key asc autoincrement, %@ text, %@ text, %@ text, %@ text, %@ text, %@ text, %@ text, %@ text, %@ integer, %@ text)",messageTable,msgFromerIdColumn,msgFromerNameColumn, msgContentColumn, msgToIdColumn, msgToNameColumn, msgTimeColumn, msgTypeColumn, groupIdColumn, fileTypeColumn, groupNameColumn];
        if(![_db executeUpdate:createTableSql])
        {
            NSLog(@"Could not create table: %@", [_db lastErrorMessage]);
        }
    }];
}

#pragma mark -- 创建最新消息记录表

- (void)createNewestMessageTable
{
    NSURL *appUrl = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSString *dbPath = [[appUrl path] stringByAppendingPathComponent:@"chat.db"];
    _queue = [FMDatabaseQueue databaseQueueWithPath:dbPath];
    [_queue inTransaction:^(FMDatabase *_db, BOOL *rollback) {
        NSString *createTableSql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (cid integer primary key asc autoincrement, %@ text, %@ text, %@ text, %@ text, %@ text, %@ text, %@ integer, %@ integer, %@ integer, %@ text)",newestMsgTable,msgFromerIdColumn,msgFromerNameColumn, msgContentColumn, msgToIdColumn, msgToNameColumn, msgTimeColumn, msgNumColumn, chatTypeColumn, fileTypeColumn, groupNameColumn];
        if(![_db executeUpdate:createTableSql])
        {
            NSLog(@"Could not create table: %@", [_db lastErrorMessage]);
        }
    }];
}

#pragma mark - 联系人相关方法

- (void)addContactor:(Chatter *)chatter
{
    [_queue inTransaction:^(FMDatabase *_db, BOOL *rollback) {
        NSString *insertNewestMessage = [NSString stringWithFormat:@"INSERT INTO %@ (%@,%@,%@) VALUES (?,?,?)",ContactorTable, contactorIDColumn, contactorNameColumn, iconPathColumn];
        
        if(![_db executeUpdate:insertNewestMessage,
             chatter.chatterId, chatter.chatterName, chatter.iconPath])
        {
            NSLog(@"Could not insert user: %@", [_db lastErrorMessage]);
        }
    }];
}

- (void)updateContactor:(NSString *)contactorID name:(NSString *)name iconPath:(NSString *)iconPath
{
    [_queue inTransaction:^(FMDatabase *_db, BOOL *rollback) {
        
        NSString *updateNewestMessage = [NSString stringWithFormat:@"UPDATE %@ set %@ = ?, %@ = ? where %@ = ?", ContactorTable, contactorNameColumn, iconPathColumn, contactorIDColumn];
        
        if(![_db executeUpdate:updateNewestMessage, name, iconPath, contactorID])
        {
            NSLog(@"Could not update painting item: %@", [_db lastErrorMessage]);
        }
    }];
}

- (Chatter *)queryContactor:(NSString *)contactorID
{
    __block Chatter *chatter;
    [_queue inTransaction:^(FMDatabase *_db, BOOL *rollback) {
        NSString* sqlFind = [NSString stringWithFormat:@"SELECT * from %@ WHERE %@ = ?",ContactorTable, contactorIDColumn];
        FMResultSet* findResult = [_db executeQuery:sqlFind, contactorID];
        if ([_db hadError])
        {
            NSLog(@"Error %d : %@",[_db lastErrorCode],[_db lastErrorMessage]);
        }
        else
        {
            while ([findResult next])
            {
                Chatter *chat = [[Chatter alloc] init];
                chat.chatterId = [findResult objectForColumnName:contactorIDColumn];
                chat.chatterName = [findResult objectForColumnName:contactorNameColumn];
                chat.iconPath = [findResult objectForColumnName:iconPathColumn];
                
                chatter = chat;
            }
        }
    }];
    return chatter;
}

- (void)deleteAllContactor
{
    [_queue inTransaction:^(FMDatabase *_db, BOOL *rollback) {
        NSString *sqlDelete = [NSString stringWithFormat:@"DELETE FROM %@ ",ContactorTable];
        [_db executeUpdate:sqlDelete];
    }];
}

#pragma mark -- 最新消息方法

-(void) addNewestMessage:(Message *) chatMessage
{
    [_queue inTransaction:^(FMDatabase *_db, BOOL *rollback) {
        NSString *insertNewestMessage = [NSString stringWithFormat:@"INSERT INTO %@ (%@,%@,%@,%@,%@,%@,%@,%@,%@,%@) VALUES (?,?,?,?,?,?,?,?,?,?)",newestMsgTable, msgFromerIdColumn, msgFromerNameColumn, msgContentColumn, msgToIdColumn, msgToNameColumn, msgTimeColumn, msgNumColumn, chatTypeColumn, fileTypeColumn, groupNameColumn];

        if(![_db executeUpdate:insertNewestMessage,
             chatMessage.msgFromerId, chatMessage.msgFromerName, chatMessage.msgContent, chatMessage.msgToId, chatMessage.msgToName,chatMessage.msgTime,[NSNumber numberWithInt:chatMessage.msgNum],[NSNumber numberWithInt:chatMessage.chatType],[NSNumber numberWithInt:chatMessage.fileType], chatMessage.groupName])
        {
            NSLog(@"Could not insert user: %@", [_db lastErrorMessage]);
        }
    }];
}

- (BOOL)ifExistNewestMessage:(Message *)chatMessage
{
    __block BOOL ifExist = NO;
    [_queue inTransaction:^(FMDatabase *_db, BOOL *rollback) {
        NSString* sqlFind = [NSString stringWithFormat:@"SELECT %@ from %@ WHERE %@ = ?",msgFromerIdColumn, newestMsgTable, msgFromerIdColumn];
        FMResultSet* findResult = [_db executeQuery:sqlFind, chatMessage.msgFromerId];
        if ([_db hadError])
        {
            NSLog(@"Error %d : %@",[_db lastErrorCode],[_db lastErrorMessage]);
        }
        else
        {
            while ([findResult next])
            {
                ifExist = YES;
            }
        }
    }];
    return ifExist;
}

- (Message *)findNewestMessageFromerID:(NSString *)fromerID
{
    __block Message *msg;
    [_queue inTransaction:^(FMDatabase *_db, BOOL *rollback) {
        NSString* sqlFind = [NSString stringWithFormat:@"SELECT * from %@ WHERE %@ = ?",newestMsgTable, msgFromerIdColumn];
        FMResultSet* findResult = [_db executeQuery:sqlFind, fromerID];
        if ([_db hadError])
        {
            NSLog(@"Error %d : %@",[_db lastErrorCode],[_db lastErrorMessage]);
        }
        else
        {
            while ([findResult next])
            {
                Message *chatMessage = [[Message alloc] init];
                chatMessage.msgId = [[findResult objectForColumnName:@"cid"] intValue];
                chatMessage.msgFromerId = [findResult objectForColumnName:msgFromerIdColumn];
                chatMessage.msgFromerName = [findResult objectForColumnName:msgFromerNameColumn];
                chatMessage.msgContent = [findResult objectForColumnName:msgContentColumn];
                chatMessage.msgToId = [findResult objectForColumnName:msgToIdColumn];
                chatMessage.msgToName = [findResult objectForColumnName:msgToNameColumn];
                chatMessage.msgTime = [findResult objectForColumnName:msgTimeColumn];
                chatMessage.msgNum = [[findResult objectForColumnName:msgNumColumn] intValue];
                chatMessage.chatType = [[findResult objectForColumnName:chatTypeColumn] intValue];
                chatMessage.fileType = [[findResult objectForColumnName:fileTypeColumn] intValue];
                chatMessage.groupName = [findResult objectForColumnName:groupNameColumn];
                
                msg = chatMessage;
            }
        }
    }];
    return msg;
}

- (NSMutableArray *)allNewestMessage
{
    NSMutableArray *destinationArray = [NSMutableArray array];
    [_queue inTransaction:^(FMDatabase *_db, BOOL *rollback) {
        NSString* sqlFind = [NSString stringWithFormat:@"SELECT * from %@ order by %@ desc", newestMsgTable, msgTimeColumn];
        FMResultSet* findResult = [_db executeQuery:sqlFind];
        if ([_db hadError])
        {
            NSLog(@"Error %d : %@",[_db lastErrorCode],[_db lastErrorMessage]);
        }
        else
        {
            while ([findResult next])
            {
                Message *chatMessage = [[Message alloc] init];
                chatMessage.msgId = [[findResult objectForColumnName:@"cid"] intValue];
                chatMessage.msgFromerId = [findResult objectForColumnName:msgFromerIdColumn];
                chatMessage.msgFromerName = [findResult objectForColumnName:msgFromerNameColumn];
                chatMessage.msgContent = [findResult objectForColumnName:msgContentColumn];
                chatMessage.msgToId = [findResult objectForColumnName:msgToIdColumn];
                chatMessage.msgToName = [findResult objectForColumnName:msgToNameColumn];
                chatMessage.msgTime = [findResult objectForColumnName:msgTimeColumn];
                chatMessage.msgNum = [[findResult objectForColumnName:msgNumColumn] intValue];
                chatMessage.chatType = [[findResult objectForColumnName:chatTypeColumn] intValue];
                chatMessage.fileType = [[findResult objectForColumnName:fileTypeColumn] intValue];
                chatMessage.groupName = [findResult objectForColumnName:groupNameColumn];
                
                [destinationArray addObject:chatMessage];
            }
        }
    }];
    return destinationArray;
}

- (void)updateNewestMessageContent:(Message *)msg
{
    [_queue inTransaction:^(FMDatabase *_db, BOOL *rollback) {
        
        NSString *updateNewestMessage = [NSString stringWithFormat:@"UPDATE %@ set %@ = ? where %@ = ?", newestMsgTable, msgContentColumn, msgFromerIdColumn];
        
        if(![_db executeUpdate:updateNewestMessage, msg.msgContent, msg.msgFromerId])
        {
            NSLog(@"Could not update painting item: %@", [_db lastErrorMessage]);
        }
    }];
}

-(void) updateNewestMessage:(Message *)chatMessage
{
    [_queue inTransaction:^(FMDatabase *_db, BOOL *rollback) {

        NSString *updateNewestMessage = [NSString stringWithFormat:@"UPDATE %@ set %@ = ?, %@ = ?, %@ = ?, %@ = ?, %@ = ?, %@ = ?, %@ = ?, %@ = ?, %@ = ?, %@ = ? where %@ = ?", newestMsgTable, msgFromerIdColumn, msgFromerNameColumn, msgContentColumn, msgToIdColumn, msgToNameColumn, msgTimeColumn,msgNumColumn, chatTypeColumn,fileTypeColumn, groupNameColumn, msgFromerIdColumn];

        if(![_db executeUpdate:updateNewestMessage, chatMessage.msgFromerId, chatMessage.msgFromerName, chatMessage.msgContent, chatMessage.msgToId, chatMessage.msgToName, chatMessage.msgTime, [NSNumber numberWithInt:chatMessage.msgNum], [NSNumber numberWithInt:chatMessage.chatType], [NSNumber numberWithInt:chatMessage.fileType], chatMessage.groupName, chatMessage.msgFromerId])
        {
            NSLog(@"Could not update painting item: %@", [_db lastErrorMessage]);
        }
    }];
}

- (BOOL) deleteNewestMessage:(Message *) chatMessage
{
    __block BOOL deleteState = NO;
    [_queue inTransaction:^(FMDatabase *_db, BOOL *rollback) {
        NSString *sqlDelete = [NSString stringWithFormat:@"DELETE FROM %@ where %@=?",newestMsgTable, msgFromerIdColumn];
        if(![_db executeUpdate:sqlDelete, chatMessage.msgFromerId]){
            NSLog(@"delete_cate_sql error: %@", [_db lastErrorMessage]);
            deleteState = false;
        }
        else
        {
            NSLog(@"delete success!");
            deleteState = true;
        }
    }];
    return deleteState;
}

/**
 *  删除最新消表中的一条消息记录
 *
 *  @param  fromID 消息来源
 *
 *  @return 返回是否成功删除
 */
- (BOOL)deleteNewestMessageWithFromerID:(NSString *)fromID
{
    __block BOOL deleteState = NO;
    [_queue inTransaction:^(FMDatabase *_db, BOOL *rollback) {
        NSString *sqlDelete = [NSString stringWithFormat:@"DELETE FROM %@ where %@=?",newestMsgTable, msgFromerIdColumn];
        if(![_db executeUpdate:sqlDelete, fromID]){
            NSLog(@"delete_cate_sql error: %@", [_db lastErrorMessage]);
            deleteState = false;
        }
        else
        {
            NSLog(@"delete success!");
            deleteState = true;
        }
    }];
    return deleteState;
}

- (void)deleteAllNewestMessage
{
    [_queue inTransaction:^(FMDatabase *_db, BOOL *rollback) {
        NSString *sqlDelete = [NSString stringWithFormat:@"DELETE FROM %@ ",newestMsgTable];
        [_db executeUpdate:sqlDelete];
    }];
}

#pragma mark -- 聊天消息记录

- (void)addChatMessage:(Message *)chatMessage
{
    [_queue inTransaction:^(FMDatabase *_db, BOOL *rollback) {
        NSString *insertChatMessage = [NSString stringWithFormat:@"INSERT INTO %@ (%@,%@,%@,%@,%@,%@,%@,%@,%@,%@) VALUES (?,?,?,?,?,?,?,?,?,?)",messageTable, msgFromerIdColumn, msgFromerNameColumn, msgContentColumn, msgToIdColumn, msgToNameColumn, msgTimeColumn, msgTypeColumn, groupIdColumn, fileTypeColumn, groupNameColumn];
        
        if(![_db executeUpdate:insertChatMessage,
             chatMessage.msgFromerId, chatMessage.msgFromerName, chatMessage.msgContent, chatMessage.msgToId, chatMessage.msgToName, chatMessage.msgTime, chatMessage.msgType, chatMessage.groupId, [NSNumber numberWithInt:chatMessage.fileType], chatMessage.groupName])
        {
            NSLog(@"Could not insert user: %@", [_db lastErrorMessage]);
        }
    }];
}

/**
 *  查找当前聊天对象和当前登录用户最近几条数据
 *
 *  @param num    需要查找的最近消息的条数
 *  @param fromID 消息来源或者当前用户发送的消息
 *  @param toID   消息来源或者当前用户发送的消息
 *
 *  @return 返回符合的数据
 */
- (NSMutableArray *)queryNewestChatMessageWithPerpageNum:(int)num page:(int)page fromerID:(NSString *)fromID toId:(NSString *)toID
{
    NSMutableArray *destinateArray = [NSMutableArray array];
    [_queue inTransaction:^(FMDatabase *_db, BOOL *rollback) {
        NSString *sqlFind = [NSString stringWithFormat:@"SELECT * FROM %@ where %@ = ? and %@ = ? and %@=? order by %@ desc limit %d,%d", messageTable, msgFromerIdColumn, msgToIdColumn, groupIdColumn, msgTimeColumn, page * num, (page + 1) * num];
        FMResultSet *findResult = [_db executeQuery:sqlFind, fromID, toID, @""];
        if ([_db hadError])
        {
            NSLog(@"Error %d : %@",[_db lastErrorCode],[_db lastErrorMessage]);
        } else {
            while ([findResult next])
            {
                Message *chatMessage = [[Message alloc] init];
                chatMessage.msgId = [[findResult objectForColumnName:@"cid"] intValue];
                chatMessage.msgFromerId = [findResult objectForColumnName:msgFromerIdColumn];
                chatMessage.msgFromerName = [findResult objectForColumnName:msgFromerNameColumn];
                chatMessage.msgContent = [findResult objectForColumnName:msgContentColumn];
                chatMessage.msgToId = [findResult objectForColumnName:msgToIdColumn];
                chatMessage.msgToName = [findResult objectForColumnName:msgToNameColumn];
                chatMessage.msgTime = [findResult objectForColumnName:msgTimeColumn];
                chatMessage.msgType = [findResult objectForColumnName:msgTypeColumn];
                chatMessage.groupId = [findResult objectForColumnName:groupIdColumn];
                chatMessage.fileType = [[findResult objectForColumnName:fileTypeColumn] intValue];
                chatMessage.groupName = [findResult objectForColumnName:groupNameColumn];
                
                [destinateArray addObject:chatMessage];
            }
            [findResult close];
        }
    }];
    NSMutableArray *desArray = [NSMutableArray arrayWithArray:[destinateArray sortedArrayUsingComparator:^NSComparisonResult(Message *obj1, Message *obj2) {
        return [obj1.msgTime compare:obj2.msgTime];
    }]];
    return desArray;
}

/**
 *  查询群消息
 *
 *  @param num     需要查找的最近的群消息记录
 *  @param groupID 群号
 *
 *  @return 返回群消息
 */
- (NSMutableArray *)queryGroupMessageWithPerpageNum:(int)num page:(int)page groupID:(NSString *)groupID
{
    NSMutableArray *destinateArray = [NSMutableArray array];
    [_queue inTransaction:^(FMDatabase *_db, BOOL *rollback) {
        NSString *sqlFind = [NSString stringWithFormat:@"SELECT * FROM %@ where %@ = ? order by %@ desc limit %d,%d", messageTable, groupIdColumn, msgTimeColumn, page * num, (page + 1) * num];
        FMResultSet *findResult = [_db executeQuery:sqlFind, groupID];
        if ([_db hadError])
        {
            NSLog(@"Error %d : %@",[_db lastErrorCode],[_db lastErrorMessage]);
        } else {
            while ([findResult next])
            {
                Message *chatMessage = [[Message alloc] init];
                chatMessage.msgId = [[findResult objectForColumnName:@"cid"] intValue];
                chatMessage.msgFromerId = [findResult objectForColumnName:msgFromerIdColumn];
                chatMessage.msgFromerName = [findResult objectForColumnName:msgFromerNameColumn];
                chatMessage.msgContent = [findResult objectForColumnName:msgContentColumn];
                chatMessage.msgToId = [findResult objectForColumnName:msgToIdColumn];
                chatMessage.msgToName = [findResult objectForColumnName:msgToNameColumn];
                chatMessage.msgTime = [findResult objectForColumnName:msgTimeColumn];
                chatMessage.msgType = [findResult objectForColumnName:msgTypeColumn];
                chatMessage.groupId = [findResult objectForColumnName:groupIdColumn];
                chatMessage.fileType = [[findResult objectForColumnName:fileTypeColumn] intValue];
                chatMessage.groupName = [findResult objectForColumnName:groupNameColumn];
                
                [destinateArray addObject:chatMessage];
            }
            [findResult close];
        }
    }];
    NSMutableArray *desArray = [NSMutableArray arrayWithArray:[destinateArray sortedArrayUsingComparator:^NSComparisonResult(Message *obj1, Message *obj2) {
        return [obj1.msgTime compare:obj2.msgTime];
    }]];
    return desArray;
}

/**
 *  清楚某个人和当前登录用户相关的聊天信息
 *
 *  @param fromID 消息来源或者当前用户发送的消息
 *  @param toID   消息来源或者当前用户发送的消息
 *
 *  @return  返回结果
 */
- (BOOL)deleteMessageWithFromerID:(NSString *)fromID toId:(NSString *)toID
{
    __block BOOL deleteState = NO;
    [_queue inTransaction:^(FMDatabase *_db, BOOL *rollback) {
        NSString *sqlDelete = [NSString stringWithFormat:@"DELETE FROM %@ where %@=? and %@=? and %@=?",messageTable, msgFromerIdColumn, msgToIdColumn, groupIdColumn];
        if(![_db executeUpdate:sqlDelete, fromID, toID, @""]){
            NSLog(@"delete_cate_sql error: %@", [_db lastErrorMessage]);
            deleteState = false;
            NSLog(@"delete success!");
        } else {
            NSLog(@"delete success!");
            deleteState = true;
        }
    }];
    return deleteState;
}

/**
 *  删除群消息
 *
 *  @param groupID 群号
 *
 *  @return 返回是否删除成功
 */
- (BOOL)deleteGroupMessageWithGroupID:(NSString *)groupID
{
    __block BOOL deleteState = NO;
    [_queue inTransaction:^(FMDatabase *_db, BOOL *rollback) {
        NSString *sqlDelete = [NSString stringWithFormat:@"DELETE FROM %@ where %@=?",messageTable, groupIdColumn];
        if(![_db executeUpdate:sqlDelete, groupID]){
            NSLog(@"delete_cate_sql error: %@", [_db lastErrorMessage]);
            deleteState = false;
        } else {
            NSLog(@"delete success!");
            deleteState = true;
        }
    }];
    return deleteState;
}

- (void)deleteAllMessage
{
    [_queue inTransaction:^(FMDatabase *_db, BOOL *rollback) {
        NSString *sqlDelete = [NSString stringWithFormat:@"DELETE FROM %@ ",messageTable];
        [_db executeUpdate:sqlDelete];
    }];
}

@end
