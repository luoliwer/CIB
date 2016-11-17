//
//  WebSocketManager.m
//  ChatDemo
//
//  Created by YangChao on 25/1/16.
//  Copyright © 2016年 swy. All rights reserved.
//

#import "JSSendMessageManager.h"
#import "Config.h"
#import <CIBBaseSDK/CIBBaseSDK.h>
#import "Message.h"
#import "Public.h"
#import "ChatDBManager.h"
#import "HttpManager.h"
#import "JFRWebSocket.h"

@interface JSSendMessageManager ()

@end

@implementation JSSendMessageManager

- (instancetype)init
{
    if (self = [super init]) {
        
    }
    return self;
}

+ (instancetype)sharedManager
{
    static JSSendMessageManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[JSSendMessageManager alloc] init];
    });
    return sharedManager;
}


- (void)sendMessage:(NSString *)message socket:(JFRWebSocket *)socket disConnectBlock:(void(^)())disBlock
{
    if (!socket.isConnected) { // websocket连接已经断开
        if([socket.delegate respondsToSelector:@selector(websocketDidDisconnect:error:)]){
            disBlock();
            NSError *error=[NSError errorWithDomain:@"" code:50 userInfo:nil];
            [socket.delegate websocketDidDisconnect:socket error:error];
        }
        return;
    }
    //发送消息
    [socket writeString:message];
    
    NSError *err = nil;
    NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];
    id item = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&err];
    
    NSArray *msgContentArray = (NSArray *)item;
//    NSLog(@"获取的数据：%@", msgContentArray);
    int chatType = 0;
    int fileType = 0;
    NSString *fromId = @"";
    NSString *groupId = @"";
    NSString *msgContent = @"";
    NSString *file = msgContentArray[0];
    if ([file isEqualToString:@"string"]) {
        msgContent = msgContentArray[2];
        fileType = 0;
    } else if ([file isEqualToString:@"pic"]) {
        msgContent = msgContentArray[2];
        fileType = 1;
    } else if ([file isEqualToString:@"url"]) {
        fileType = 3;
        id item = msgContentArray[2];
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:item options:NSJSONWritingPrettyPrinted error:nil];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        msgContent = jsonString;
    } else if ([file isEqualToString:@"app"]) {
        fileType = 4;
        id item = msgContentArray[2];
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:item options:NSJSONWritingPrettyPrinted error:nil];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        msgContent = jsonString;
    } else {
        msgContent = msgContentArray[2];
        fileType = 2;
    }
    BOOL flag = [[msgContentArray lastObject] boolValue];//通过该字段来判断其是单聊还是群聊
    if (!flag) {
        chatType = 0;
        fromId = msgContentArray[1];
    } else {
        chatType = 1;
        groupId = msgContentArray[1];
    }
    
    [self achieveUserNameByID:fromId fromName:@"" groupName:@"" groupId:groupId messageContent:msgContent chatType:chatType fileType:fileType];
}

- (void)achieveUserNameByID:(NSString *)ID fromName:(NSString *)fromName groupName:(NSString *)groupName groupId:(NSString *)groupId messageContent:(NSString *)msgContent chatType:(int)chatType fileType:(int)fileType
{
    /*
    //通过id获取用户信息
    id noteIdDic = @{@"notesId":ID};
    NSData *dicData = [NSJSONSerialization dataWithJSONObject:noteIdDic options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonStr = [[NSString alloc] initWithData:dicData encoding:NSUTF8StringEncoding];
    id parameter = @{@"command":@"userinfo", @"parameter":jsonStr};
    [[HttpManager sharedHttpManager] userNameAndIcon:kUserNameAndIconServerURL parameters:parameter success:^(NSDictionary *dic) {
        if (dic) {
            NSLog(@"用户信息：%@", dic);
            NSString *userInfo = [dic valueForKey:@"info"];
            
            NSData *jsonData = [userInfo dataUsingEncoding:NSUTF8StringEncoding];
            NSError *err;
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                options:NSJSONReadingMutableContainers
                                                                  error:&err];
            if(err) {
                NSLog(@"json解析失败：%@",err);
            }
            
            if (!dic) {
                return ;
            }
            
            NSString *userName = [[[dic objectForKey:@"result"] firstObject] valueForKey:@"USERNAME"] ? : ID;
            NSLog(@"用户姓名：%@", userName);
            if (chatType == 1) {
                
                [self achieveGroupNameByGroupId:groupId messageContent:msgContent chatType:chatType fileType:fileType];
            } else {
                [self messageHandleFromId:ID fromName:userName groupName:@"" groupId:groupId messageContent:msgContent chatType:chatType fileType:fileType];
            }
        }
    } fail:^(NSError *error) {
//        NSLog(@"%@", error);
    }];
     */
    // TODO 改为使用invoke来调用人员详情接口
    id noteIdDic = @{@"notesid":ID};
    [CIBRequestOperationManager invokeAPI:@"contactsguiv2" byMethod:@"POST" withParameters:noteIdDic onRequestSucceeded:^(NSString *responseCode, NSString *responseInfo) {
        
        if ([responseCode isEqualToString:@"I00"]) {
            NSString *resultCode = [responseInfo valueForKey:@"resultCode"];
            if ([resultCode isEqualToString:@"0"]) {
                NSArray *resultDic = [responseInfo valueForKey:@"result"];
                NSString *userName = [[resultDic firstObject] valueForKey:@"USERNAME"] ? : ID;
                NSLog(@"用户姓名：%@", userName);
                if (chatType == 1) {
                    
                    [self achieveGroupNameByGroupId:groupId messageContent:msgContent chatType:chatType fileType:fileType];
                } else {
                    [self messageHandleFromId:ID fromName:userName groupName:@"" groupId:groupId messageContent:msgContent chatType:chatType fileType:fileType];
                }
            }
        }
        
    } onRequestFailed:^(NSString *responseCode, NSString *responseInfo) {
        NSLog(@"%@", responseInfo);
    }];
}

- (void)achieveGroupNameByGroupId:(NSString *)ID messageContent:(NSString *)msgContent chatType:(int)chatType fileType:(int)fileType
{
    //如果是群消息，则去调用群名称接口
    NSString *url = [NSString stringWithFormat:@"%@parameter=['getGroupNickName',%@]",kServerURL, ID];
    [[HttpManager sharedHttpManager] groupNameUrl:url parameters:nil success:^(NSDictionary *dic) {
        
        if (dic) {
            NSString *groupName = @"";
            [self messageHandleFromId:[AppInfoManager getUserName] fromName:[AppInfoManager getValueForKey:kKeyOfUserRealName] groupName:groupName groupId:ID messageContent:msgContent chatType:chatType fileType:fileType];
        }
    } fail:^(NSError *error) {
        
    }];
}

- (void)messageHandleFromId:(NSString *)fromId fromName:(NSString *)fromName groupName:(NSString *)groupName groupId:(NSString *)groupId messageContent:(NSString *)msgContent chatType:(int)chatType fileType:(int)fileType
{
    //构建实体类 保存到数据库
    Message *sendMessage = [[Message alloc] init];
    sendMessage.msgFromerId = fromId;
    sendMessage.msgFromerName = fromName;
    sendMessage.msgContent = msgContent;
    sendMessage.msgToId = [AppInfoManager getUserName];
    sendMessage.msgToName = [AppInfoManager getValueForKey:kKeyOfUserRealName];
    sendMessage.msgTime = [Public stringFromDate:[NSDate date] formatt:@"yyyy-MM-dd HH:mm:ss"];
    sendMessage.msgType = @"0";
    sendMessage.fileType = fileType;
    sendMessage.chatType = chatType;
    sendMessage.groupId = groupId;
    sendMessage.groupName = groupName;
    
    [self updateDBSaveMessage:sendMessage];
}

- (void)updateDBSaveMessage:(Message *)msg
{
    //将消息保存到本地
    [[ChatDBManager sharedDatabaseManager] addChatMessage:msg];
    
    //更新最新消息列表
    if (msg.chatType == 1) {
        msg.msgFromerId = msg.groupId;//将来源改为群号
    }
    
    //判断最新消息是否存在对应的id或者群号
    BOOL isExist = [[ChatDBManager sharedDatabaseManager] ifExistNewestMessage:msg];
    
    //存在 更新消息 不存在 插入数据库
    if (isExist) {
        [[ChatDBManager sharedDatabaseManager] updateNewestMessage:msg];
    } else {
        [[ChatDBManager sharedDatabaseManager] addNewestMessage:msg];
    }
}

@end
