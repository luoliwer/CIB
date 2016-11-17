//
//  MessagesController.h
//  ChatDemo
//
//  Created by YangChao on 19/1/16.
//  Copyright © 2016年 swy. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : int {
    ChatTypeDefault = 0,
    ChatTypeGroup,
} ChatType;

@class Message;
@interface MessagesController : UIViewController

@property (nonatomic, strong) Message *msg;

//单聊/群聊
@property (nonatomic, assign) ChatType chatType;

//返回到指定的viewcontroller
@property (nonatomic, assign) NSString *backToViewControllerName;

@property (nonatomic, strong) NSString *fromHere;//重哪里调往次界面（重个人详情（@“userInfo”） 不是以push 弹出的，在back 处理不一样 ）

@end
