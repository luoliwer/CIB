//
//  Station.m
//  SmartHall
//
//  Created by YangChao on 26/10/15.
//  Copyright © 2015年 IndustrialBank. All rights reserved.
//  工位信息实体类

#import "Message.h"

@implementation Message

- (instancetype)copyWithZone:(NSZone *)zone
{
    Message *msg = [[self class] allocWithZone:zone];
    msg.msgId = _msgId;
    msg.msgFromerId = [_msgFromerId copy];
    msg.msgFromerName = [_msgFromerName copy];
    msg.msgContent = [_msgContent copy];
    msg.msgToId = [_msgToId copy];
    msg.msgToName = [_msgToName copy];
    msg.msgTime = [_msgTime copy];
    msg.msgNum = _msgNum;
    msg.msgType = [_msgType copy];
    msg.groupId = [_groupId copy];
    msg.chatType = _chatType;
    msg.fileType = _fileType;
    return msg;
}

@end
