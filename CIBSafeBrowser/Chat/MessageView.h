//
//  MessageView.h
//  ChatDemo
//
//  Created by YangChao on 19/1/16.
//  Copyright © 2016年 swy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MessageView : UIView

@property (nonatomic, assign) BOOL showGroupInfo;//是否显示群的信息 yes 显示查看群信息按钮

@property (nonatomic, weak) UILabel *titleLb;

@property (nonatomic, assign) BOOL refresh;

@property (nonatomic, assign) NSInteger refreshMsgNum;

@property (nonatomic, strong) NSMutableArray *messagesDataSource;

@property (nonatomic, strong) void (^BackBlock)();//返回按钮事件

@property (nonatomic, strong) void (^SendMessage)(NSString *msg);//发送消息事件

@property (nonatomic, strong) void (^QueryGroupInfo)();//查看群信息事件

@property (nonatomic, strong) void (^ChooseActionSheet)();//选择照片事件

@property (nonatomic, strong) void (^refreshMore)();//刷新获取更多数据

@property (nonatomic, strong) void (^ViewFile)(int fileType, NSString *filePath);//查看图片

@property (nonatomic, strong) void (^OpenUrlInNewView)(NSString *url, NSString *appNo); // 在新页面打开url

@property (nonatomic, strong) void (^OpenAppInNewTab)(NSString *appNo); //在新tab中打开webApp

@property (nonatomic, strong) void (^ViewOriginalImage)(UIImage *image); //查看原图


-(void) dataReload;
@end
