//
//  Station.h
//  SmartHall
//
//  Created by YangChao on 26/10/15.
//  Copyright © 2015年 IndustrialBank. All rights reserved.
//  消息实体类

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef enum : int {
    FileTypeText = 0,
    FileTypePic,
    FileTypeOther,
    FileTypeOpenUrl,
    FileTypeOpenApp
} FileType;

@interface Message : NSObject<NSCopying>

@property (nonatomic, assign) int msgId;
@property (nonatomic, copy) NSString *msgFromerId;
@property (nonatomic, copy) NSString *msgFromerName;
@property (nonatomic, copy) NSString *msgToId;
@property (nonatomic, copy) NSString *msgToName;
@property (nonatomic, copy) NSString *msgTime;
@property (nonatomic, copy) NSString *msgContent;
@property (nonatomic, assign) int msgNum;
@property (nonatomic, assign) int chatType;//单聊群聊
@property (nonatomic, copy) NSString *msgType;//0 me 1 other 消息发自谁
@property (nonatomic, copy) NSString *groupId;//群号
@property (nonatomic, copy) NSString *groupName;//群昵称

@property (nonatomic, strong) UIImage *sendPicImage;//发送图片消息

@property (nonatomic, assign) FileType fileType;//文件类型 0 表示普通文字消息 1 表示发送图片消息 2 表示其他文件

@end
