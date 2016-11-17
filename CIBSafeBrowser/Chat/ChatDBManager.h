//
//  DataBaseManager.h
//  CommunityFinancial
//
//  Created by wuxiyao on 15/4/21.
//  Copyright (c) 2015年 pactera. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDB.h"

@class Message, Chatter;
@interface ChatDBManager : NSObject

+ (ChatDBManager *) sharedDatabaseManager;

#pragma mark -- 联系人

- (void)addContactor:(Chatter *)chatter;

- (Chatter *)queryContactor:(NSString *)contactorID;

- (void)updateContactor:(NSString *)contactorID name:(NSString *)name iconPath:(NSString *)iconPath;

- (void)deleteAllContactor;

#pragma mark -- 聊天消息;

/**
 *  将聊天记录插入数据库
 *
 *  @param chatMessage 待记录的聊天信息
 */
- (void)addChatMessage:(Message *)chatMessage;

/**
 *  查找当前聊天对象和当前登录用户最近几条数据
 *
 *  @param num    需要查找的最近消息的条数
 *  @param fromID 消息来源或者当前用户发送的消息
 *  @param toID   消息来源或者当前用户发送的消息
 *
 *  @return 返回符合的数据
 */
- (NSMutableArray *)queryNewestChatMessageWithPerpageNum:(int)num page:(int)page fromerID:(NSString *)fromID toId:(NSString *)toID;

/**
 *  查询群消息
 *
 *  @param num     需要查找的最近的群消息记录
 *  @param groupID 群号
 *
 *  @return 返回群消息
 */
- (NSMutableArray *)queryGroupMessageWithPerpageNum:(int)num page:(int)page groupID:(NSString *)groupID;

/**
 *  清楚某个人和当前登录用户相关的聊天信息
 *
 *  @param fromID 消息来源或者当前用户发送的消息
 *  @param toID   消息来源或者当前用户发送的消息
 *
 *  @return  返回结果
 */
- (BOOL)deleteMessageWithFromerID:(NSString *)fromID toId:(NSString *)toID;

/**
 *  删除群消息
 *
 *  @param groupID 群号
 *
 *  @return 返回是否删除成功
 */
- (BOOL)deleteGroupMessageWithGroupID:(NSString *)groupID;

- (void)deleteAllMessage;

#pragma mark -- 最新消息;

/**
 *  添加最近的一条消息到最新信息表中
 *
 *  @param chatMessage 待记录的消息
 */
- (void)addNewestMessage:(Message *)chatMessage;

/**
 *  判断是否存在消息来源和当前用户的消息记录，存在则修改消息 不存在则添加
 *
 *  @param chatMessage 待记录的消息
 *
 *  @return 返回是否存在
 */
- (BOOL)ifExistNewestMessage:(Message *)chatMessage;

- (Message *)findNewestMessageFromerID:(NSString *)fromerID;

/**
 *  获取所有的消息
 *
 *  @return 结果
 */
- (NSMutableArray *)allNewestMessage;

/**
 *  更新当前最新消息
 *
 *  @param chatMessage 最近发来的一条消息
 */
- (void)updateNewestMessage:(Message *)chatMessage;

/**
 *  更新消息内容
 *
 *  @param msg 待更新消息
 */
- (void)updateNewestMessageContent:(Message *)msg;

/**
 *  删除最新消表中的一条消息记录
 *
 *  @param chatMessage 消息
 *
 *  @return 返回是否成功删除
 */
- (BOOL)deleteNewestMessage:(Message *)chatMessage;

/**
 *  删除最新消表中的一条消息记录
 *
 *  @param  fromID 消息来源
 *
 *  @return 返回是否成功删除
 */
- (BOOL)deleteNewestMessageWithFromerID:(NSString *)fromID;

- (void)deleteAllNewestMessage;

@end
