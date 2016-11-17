//
//  MessageFrame.h
//  ChatDemo
//
//  Created by YangChao on 18/1/16.
//  Copyright © 2016年 swy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define kTop 20 //间隔
#define kTimeTop 35 //显示时间间隔高度

#define kTrailing 64 //间隔

#define kLeading 12 //间隔
#define kPadding -4 //间隔

#define kIconWH 40 //头像宽高
#define kContentW 180 //内容宽度

#define kTimeMarginW 5 //时间文本与边框间隔宽度方向

#define kContentTop 12 //文本内容与按钮上边缘间隔
#define kContentLeft 12 //文本内容与按钮左边缘间隔
#define kContentBottom 12 //文本内容与按钮下边缘间隔
#define kContentRight 20 //文本内容与按钮右边缘间隔

#define kTimeFont [UIFont systemFontOfSize:14] //时间字体
#define kContentFont [UIFont systemFontOfSize:16] //内容字体

typedef enum {
    MessageTypeMe = 0,
    MessageTypeOther = 1
}MessageType;

@class Message;
@interface MessageFrame : NSObject

@property (nonatomic, assign, readonly) CGRect iconFrame;
@property (nonatomic, assign, readonly) CGRect nameFrame;
@property (nonatomic, assign, readonly) CGRect msgContentFrame;
@property (nonatomic, assign, readonly) CGRect msgTimeFrame;

@property (nonatomic, assign, readonly) CGFloat cellHeight;

@property (nonatomic, assign) MessageType msgType;//消息类型
@property (nonatomic, assign) BOOL showTime;
@property (nonatomic, assign) BOOL showName;

@property (nonatomic, strong) Message *message;

@end
