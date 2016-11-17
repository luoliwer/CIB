//
//  MessagesController.m
//  ChatDemo
//
//  Created by YangChao on 19/1/16.
//  Copyright © 2016年 swy. All rights reserved.
//

#import "MessagesController.h"
#import "Message.h"
#import "MessageFrame.h"
#import "MessageView.h"
#import "JFRWebSocket.h"
#import "ChatDBManager.h"
#import "Chatter.h"
#import "NewsListController.h"
#import "Config.h"
#import <CIBBaseSDK/CIBBaseSDK.h>
#import "GroupInfoController.h"
#import "HttpManager.h"
#import "Public.h"
#import "AppDelegate.h"
#import "CustomWebViewController.h"
#import "CoreDataManager.h"
#import "NewWebViewController.h"
#import "MyUtils.h"
#import "ImageCropView.h"


@interface MessagesController ()<JFRWebSocketDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate, UIAlertViewDelegate>
{
    NSMutableArray *_messagesDataSource;
    NSString *_groupId;
    UIImagePickerController *_imagePickerController;
    BOOL _isSenderPicture;//如果是发送图片，则设置为yes 否则为no
    int _currentPage;//当前页码
    int _perpageNum;//每一页显示的条数
}

@property (nonatomic, weak) MessageView *msgView;
@end

@implementation MessagesController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _imagePickerController = [[UIImagePickerController alloc] init];
    _currentPage = 0;
    _perpageNum = 20;
    
    //界面及事件处理
    MessageView *messageView = [[MessageView alloc] init];
    
    if (_chatType == ChatTypeGroup) {
        messageView.showGroupInfo = YES;
    }
    
    //返回上一级
    messageView.BackBlock = ^{
        [self back];
    };
    
    //查看群信息
    if (_chatType == ChatTypeGroup) {
        messageView.QueryGroupInfo = ^{
            [self groupInfo:_groupId];
        };
    }
    
    //发送消息
    messageView.SendMessage = ^(NSString *message) {
        [self sendMsg:message fileType:0];
    };
    [self.view addSubview:messageView];
    
    //选择照片上传形式 -- 本地或者照相机
    messageView.ChooseActionSheet = ^{
        [self showChooseActionSheet];
    };
    
    //下拉，刷新获取更多数据
    messageView.refreshMore = ^ {
        [self moreMessage];
    };
    
    //查看图片或者文件
    messageView.ViewFile = ^(int fileType, NSString *filePath){
        [self handleFile:fileType filePath:filePath];
    };
    
    // 在新的页面打开url
    messageView.OpenUrlInNewView = ^(NSString *url, NSString *appNo) {
        [self openUrl:url OfApp:appNo];
    };
    
    // 在新的tab打开webApp
    messageView.OpenAppInNewTab = ^(NSString *appNo) {
        [self openApp:appNo];
    };
    
    messageView.ViewOriginalImage = ^(UIImage *image) {
        [self viewOriginalImage:image];
    };
    
    self.msgView = messageView;
    
    _messagesDataSource = [NSMutableArray array];
    
    //设置聊天的顶部信息 -- 和谁聊天
    messageView.titleLb.text = _msg.msgFromerName;
    if (_chatType == ChatTypeGroup) {
        _groupId = _msg.groupId;
    }
    //设置聊天数据展示在界面上
    [self localMessages];
}

- (void)initSocket
{
    JFRWebSocket *socket = [AppDelegate delegate].socket;
    if (socket.delegate) {
        socket.delegate = nil;
    }
    socket.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //建立连接
    [self initSocket];
    
    //如果是私聊请求私聊对象信息
    if(self.chatType==ChatTypeDefault){
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            NSDictionary *param = [NSDictionary dictionaryWithObject:self.msg.msgFromerId forKey:@"notesid"];
            [CIBRequestOperationManager invokeAPI:@"contactsguiv2" byMethod:@"POST" withParameters:param onRequestSucceeded:^(NSString *responseCode, NSString *responseInfo) {
                if([responseCode isEqualToString:@"I00"]){
                    NSDictionary* resourceInfo = (NSDictionary*)responseInfo;
                    if([[resourceInfo objectForKey:@"resultCode"] isEqualToString:@"0"]){
                        NSArray* userInfo = [resourceInfo objectForKey:@"result"];
                        if (userInfo && [userInfo count] > 0) {
                            [self performSelectorOnMainThread:@selector(refreshData:) withObject:userInfo[0] waitUntilDone:NO];
                        }
                        
                    }
                }
            } onRequestFailed:^(NSString *responseCode, NSString *responseInfo) {
                NSLog(@"获取个人详情失败。。。。%@",responseInfo);
            }];
        });
    }
}
-(void) refreshData:(NSDictionary*) data{
    //更新本地保存得个人信息
    //获取本地保存的 头像
    
    NSString *requestIconPath = [data objectForKey:@"PICSTRING"];
    NSString* userName =[data objectForKey:@"USERNAME"];
    
    Chatter* fromUser =[[ChatDBManager sharedDatabaseManager] queryContactor:self.msg.msgFromerId];
    if(requestIconPath==nil || [requestIconPath isKindOfClass:[NSNull class]] ){
        return;
    }
    if(![requestIconPath isEqualToString:fromUser.iconPath] || ![userName isEqualToString:fromUser.chatterName]){
        [[ChatDBManager sharedDatabaseManager] updateContactor:self.msg.msgFromerId name:userName iconPath:requestIconPath];
        [self.msgView dataReload];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    JFRWebSocket *socket = [AppDelegate delegate].socket;
    if (socket.delegate) {
        socket.delegate = nil;
    }
    
    socket.delegate = [AppDelegate delegate];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)localMessages
{
    if (_messagesDataSource && _messagesDataSource.count > 0) {
        [_messagesDataSource removeAllObjects];
    }
    NSMutableArray *messages = [NSMutableArray array];
    
    //获取最新10条聊天记录
    if (_chatType == ChatTypeGroup) {//群聊历史消息
        messages = [[ChatDBManager sharedDatabaseManager] queryGroupMessageWithPerpageNum:_perpageNum page:_currentPage groupID:_msg.groupId];
    } else {//单聊历史消息
        messages = [[ChatDBManager sharedDatabaseManager] queryNewestChatMessageWithPerpageNum:_perpageNum page:_currentPage fromerID:_msg.msgFromerId toId:_msg.msgToId];
    }
    NSString *previousTime = nil;
    for (Message *item in messages) {
        
        MessageFrame *msgFrame = [self compentMessageFrameWithMessage:item previousTime:previousTime];
        
        [_messagesDataSource addObject:msgFrame];
        
        previousTime = item.msgTime;
    }
    
    [self.msgView setMessagesDataSource:_messagesDataSource];
}

- (MessageFrame *)compentMessageFrameWithMessage:(Message *)message previousTime:(NSString *)previousTime
{
    MessageFrame *msgFrame = [[MessageFrame alloc] init];
    if ([message.msgType isEqualToString:@"1"]) {
        msgFrame.msgType = MessageTypeOther;
    }
    if (_chatType == ChatTypeGroup) {
        msgFrame.showName = YES;
    }
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    if (previousTime == nil) {
        msgFrame.showTime = YES;
    } else {
        double date1 =[[formatter dateFromString:message.msgTime] timeIntervalSince1970] ;
        double date2 = [[formatter dateFromString:previousTime] timeIntervalSince1970];
        if (date1 - date2 >= 5 * 60 ) {//5分钟
            msgFrame.showTime = YES;
        }
    }
    msgFrame.message = message;
    
    return msgFrame;
}

#pragma mark -- 返回上一级
- (void)back
{
    if([self.fromHere isEqualToString:@"userInfo"]){
        [self dismissViewControllerAnimated:YES completion:^{
        }];
        return;
    }
    if (_backToViewControllerName && ![_backToViewControllerName isEqualToString:@""]) {
        for (UIViewController *item in self.navigationController.viewControllers) {
            if ([item isKindOfClass:NSClassFromString(_backToViewControllerName)]) {
                [self.navigationController popToViewController:item animated:YES];
            }
        }
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}

- (void)moreMessage
{
    _currentPage++;
    _msgView.refresh = YES;
    
    NSMutableArray *messages = [NSMutableArray array];
    
    //获取最新20条聊天记录
    if (_chatType == ChatTypeGroup) {//群聊历史消息
        messages = [[ChatDBManager sharedDatabaseManager] queryGroupMessageWithPerpageNum:_perpageNum page:_currentPage groupID:_msg.groupId];
    } else {//单聊历史消息
        messages = [[ChatDBManager sharedDatabaseManager] queryNewestChatMessageWithPerpageNum:_perpageNum page:_currentPage fromerID:_msg.msgFromerId toId:_msg.msgToId];
    }
    
    //通过该数字来让其滑动到该行
    _msgView.refreshMsgNum = messages.count;
    
    NSString *previousTime = nil;
    for (Message *item in messages) {
        
        MessageFrame *msgFrame = [self compentMessageFrameWithMessage:item previousTime:previousTime];
        
        [_messagesDataSource addObject:msgFrame];
        
        previousTime = item.msgTime;
    }
    
    NSMutableArray *desArray = [NSMutableArray arrayWithArray:[_messagesDataSource sortedArrayUsingComparator:^NSComparisonResult(MessageFrame *obj1, MessageFrame *obj2) {
        return [obj1.message.msgTime compare:obj2.message.msgTime];
    }]];
    
    [self.msgView setMessagesDataSource:desArray];
    _msgView.refresh = NO;
}

#pragma mark -- 查看群消息
- (void)groupInfo:(NSString *)groupId
{
    GroupInfoController *groupController = [[GroupInfoController alloc] init];
    groupController.groupId = groupId;
    groupController.backToViewControllerName = @"NewsListController";
    [self.navigationController pushViewController:groupController animated:YES];
}

#pragma mark -- WebSocket监听消息方法

-(void)websocketDidConnect:(JFRWebSocket*)socket {
    
}

-(void)websocketDidDisconnect:(JFRWebSocket*)socket error:(NSError*)error {
    NSLog(@"websocket is disconnected: %ld", [error code]);
    NSInteger code = error.code;
    
    if (![AppDelegate delegate].isAppActive) { // app已处于后台状态，无需弹出websocket断开的提示框
        return;
    }
    [self showWebSocket:socket DisconnectedAlertWithErrorCode:code];
}

-(void)websocket:(JFRWebSocket*)socket didReceiveMessage:(NSString*)string {
    NSLog(@"Received text: %@", string);
    [self dealString:string];
}

-(void)websocket:(JFRWebSocket*)socket didReceiveData:(NSData*)data {
    NSLog(@"Received data: %@", data);
}


#pragma mark -- 消息处理
/**
 *  接收到的消息处理
 *  判断其是否为在线/离线消息 数据结构不一样 处理方式不一样
 *  @param msg 接受到的消息
 */
- (void)dealString:(NSString *)msg
{
    // 测试数据
    
    NSError *err;
    NSData *data = [msg dataUsingEncoding:NSUTF8StringEncoding];
    id item = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&err];
    
    if ([item isKindOfClass:[NSArray class]]) {
        NSArray *temp = (NSArray *)item;
        NSString *chatType = temp[0];
        //接受到的消息类型
        if ([chatType isEqualToString:@"chat"]) {//在线即时消息
            NSString *fileType = temp[5];
            Message *message = [[Message alloc] init];
            if ([fileType isEqualToString:@"string"]) {
                message.fileType = FileTypeText;
            } else if ([fileType isEqualToString:@"pic"]) {
                message.fileType = FileTypePic;//图片
            }
            else if ([fileType isEqualToString:@"url"]) {
                message.fileType = FileTypeOpenUrl;//打开特定连接
            }
            else if ([fileType isEqualToString:@"app"]) {
                message.fileType = FileTypeOpenApp;//打开特定webApp
            }
            else  {
                message.fileType = FileTypeOther;//其他类型（文件）
            }
            //判断消息是否发送给当前用户或者当前群
            BOOL msgSendToMe = NO;
            if (_chatType == ChatTypeGroup) {
                message.groupId = temp[1];
                message.msgFromerId = temp[2];
                if ([temp[1] isEqualToString:_msg.groupId]) {
                    msgSendToMe = YES;
                }
                Chatter *chat = [[ChatDBManager sharedDatabaseManager] queryContactor:message.msgFromerId];
                if (chat) {
                    message.msgFromerName = chat.chatterName;
                } else {
//                    message.msgFromerName = _msg.msgFromerName;
                    message.msgFromerName = message.msgFromerId;
                }
                message.msgTime = [Public stringFromDate:[NSDate date] formatt:@"yyyy-MM-dd HH:mm:ss"];
                id content = temp[4];
                if ([content isKindOfClass:[NSString class]]) { // 文字/图片/文件类消息
                    message.msgContent = (NSString *)content;
                }
                else if ([content isKindOfClass:[NSDictionary class]]) { // url/app类消息
                    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:content options:NSJSONWritingPrettyPrinted error:nil];
                    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                    message.msgContent = jsonString;
                }
                else {
                    message.msgContent = @"消息格式解析错误";
                }
//                message.msgContent = temp[4];
                
                message.msgToId = [AppInfoManager getUserName];
                message.msgToName = [AppInfoManager getValueForKey:kKeyOfUserRealName];
                message.msgType = @"1";
                message.chatType = _chatType;
            } else {
                message.msgFromerId = temp[1];
                if ([temp[1] isEqualToString:_msg.msgFromerId]) {
                    msgSendToMe = YES;
                }
                Chatter *chat = [[ChatDBManager sharedDatabaseManager] queryContactor:message.msgFromerId];
                if (chat) {
                    message.msgFromerName = chat.chatterName;
                } else {
                    if (msgSendToMe) {
                        message.msgFromerName = _msg.msgFromerName;
                    } else {
                        message.msgFromerName = message.msgFromerId;
                    }
                }
//                message.msgTime = temp[3];
                message.msgTime = [Public stringFromDate:[NSDate date] formatt:@"yyyy-MM-dd HH:mm:ss"];
                id content = temp[4];
                if ([content isKindOfClass:[NSString class]]) { // 文字/图片/文件类消息
                    message.msgContent = (NSString *)content;
                }
                else if ([content isKindOfClass:[NSDictionary class]]) { // url/app类消息
                    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:content options:NSJSONWritingPrettyPrinted error:nil];
                    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                    message.msgContent = jsonString;
                }
                else {
                    message.msgContent = @"消息格式解析错误";
                }
                message.msgToId = [AppInfoManager getUserName];
                message.msgToName = [AppInfoManager getValueForKey:kKeyOfUserRealName];
                message.msgType = @"1";
                message.chatType = _chatType;
                message.groupId = @"";
            }
            if (msgSendToMe) {//发送给当前用户的消息
                //构建更新视图的模型
                Message *copyMsg = [message copy];
                [self updateChatView:copyMsg];
            }
            
            [self messageHandle:message isSendToMe:msgSendToMe];
        } else if ([chatType isEqualToString:@"chat_list"]) {
            //获取离线消息--几个人的离线消息
            NSDictionary *offlineMsgs = temp[1];
            for (NSString *notesId in offlineMsgs) {
                //每个人发来的离线消息处理
                    id msgItems = [offlineMsgs objectForKey:notesId];
                    if ([msgItems isKindOfClass:[NSArray class]]) {
                        NSArray *messages = (NSArray *)msgItems;
                        for (id item in messages) {
                            if ([item isKindOfClass:[NSArray class]]) {
                                Message *unlineMsg = [[Message alloc] init];
                                NSString *file = [(NSArray *)item objectAtIndex:3];
                                if ([file isEqualToString:@"string"]) {
                                    unlineMsg.fileType = FileTypeText;
                                } else if ([file isEqualToString:@"pic"]) {
                                    unlineMsg.fileType = FileTypePic;//图片
                                }
                                else if ([file isEqualToString:@"url"]) {
                                    unlineMsg.fileType = FileTypeOpenUrl;//打开特定连接
                                }
                                else if ([file isEqualToString:@"app"]) {
                                    unlineMsg.fileType = FileTypeOpenApp;//打开特定webApp
                                }
                                else  {
                                    unlineMsg.fileType = FileTypeOther;//其他类型（文件）
                                }
                                //判断消息是否发送给当前用户或者当前群
                                BOOL msgSendToMe = NO;
                                if (_chatType == ChatTypeGroup) {
                                    if ([notesId isEqualToString:_msg.groupId]) {
                                        msgSendToMe = YES;
                                    }
                                    unlineMsg.groupId = notesId;
                                    unlineMsg.msgFromerId = [(NSArray *)item objectAtIndex:0];
                                    if ([temp[1] isEqualToString:_msg.groupId]) {
                                        msgSendToMe = YES;
                                    }
                                    Chatter *chat = [[ChatDBManager sharedDatabaseManager] queryContactor:unlineMsg.msgFromerId];
                                    if (chat) {
                                        unlineMsg.msgFromerName = chat.chatterName;
                                    } else {
                                        unlineMsg.msgFromerName = unlineMsg.msgFromerId;
                                    }
                                    unlineMsg.msgTime = [(NSArray *)item objectAtIndex:1];
                                    unlineMsg.msgContent = [(NSArray *)item objectAtIndex:2];
                                    unlineMsg.msgContent = [unlineMsg.msgContent stringByReplacingOccurrencesOfString:@"\'" withString:@"\""];
                                    unlineMsg.msgToId = [AppInfoManager getUserName];
                                    unlineMsg.msgToName = [AppInfoManager getValueForKey:kKeyOfUserRealName];
                                    unlineMsg.msgType = @"1";
                                    unlineMsg.chatType = _chatType;
                                } else {
                                    if ([notesId isEqualToString:_msg.msgFromerId]) {
                                        msgSendToMe = YES;
                                    }
                                    unlineMsg.msgFromerId = notesId;
                                    Chatter *chat = [[ChatDBManager sharedDatabaseManager] queryContactor:unlineMsg.msgFromerId];
                                    if (chat) {
                                        unlineMsg.msgFromerName = chat.chatterName;
                                    } else {
                                        if (msgSendToMe) {
                                            unlineMsg.msgFromerName = _msg.msgFromerName;
                                        } else {
                                            unlineMsg.msgFromerName = unlineMsg.msgFromerId;
                                        }
                                    }
                                    unlineMsg.msgTime = [(NSArray *)item objectAtIndex:1];
                                    unlineMsg.msgContent = [(NSArray *)item objectAtIndex:2];
                                    unlineMsg.msgContent = [unlineMsg.msgContent stringByReplacingOccurrencesOfString:@"\'" withString:@"\""];
                                    unlineMsg.msgToId = [AppInfoManager getUserName];
                                    unlineMsg.msgToName = [AppInfoManager getValueForKey:kKeyOfUserRealName];
                                    unlineMsg.msgType = @"1";
                                    unlineMsg.chatType = _chatType;
                                    unlineMsg.groupId = @"";
                                }
                                
                                //注：需要判断当前消息是否是当前聊天者的消息 如果是 才显示更新视图
                                //如果不是 需要对其进行处理
                                //构建更新视图的模型
                                if (msgSendToMe) {
                                    Message *copyMsg = [unlineMsg copy];
                                    [self updateChatView:copyMsg];
                                }
                                
                                [self messageHandle:unlineMsg isSendToMe:msgSendToMe];
                            }
                        }
                    }
                }
                
            }
        }
}

- (void)messageHandle:(Message *)msg isSendToMe:(BOOL)sendToMe
{
    //更新本地数据库存储
    _isSenderPicture = NO;
    [self updateDBSaveMessage:msg isSendToMe:sendToMe];
}

- (void)updateDBSaveMessage:(Message *)msg isSendToMe:(BOOL)sendToMe
{
    //将消息保存到本地
    [[ChatDBManager sharedDatabaseManager] addChatMessage:msg];
    //更新最新消息列表
    if (_chatType == ChatTypeGroup) {
        msg.msgFromerId = msg.groupId;//将来源改为群号
        msg.msgFromerName = _msg.msgFromerName;//设置群名称
    }
    
    //判断最新消息是否存在对应的id或者群号
    BOOL isExist = [[ChatDBManager sharedDatabaseManager] ifExistNewestMessage:msg];
    
    //存在 更新消息 不存在 插入数据库
    if (sendToMe) {
        if (isExist) {
            [[ChatDBManager sharedDatabaseManager] updateNewestMessage:msg];
        } else {
            [[ChatDBManager sharedDatabaseManager] addNewestMessage:msg];
        }
    } else { //消息不是发送给当前用户的
        if (isExist) {
            Message *message = [[ChatDBManager sharedDatabaseManager] findNewestMessageFromerID:msg.msgFromerId];
            if (message && message.chatType == ChatTypeGroup) {
                msg.msgFromerName = message.msgFromerName;
            }
            CGFloat num = message.msgNum;
            num++;
            msg.msgNum = num;
            [[ChatDBManager sharedDatabaseManager] updateNewestMessage:msg];
        } else {
            msg.msgNum = 1;
            [[ChatDBManager sharedDatabaseManager] addNewestMessage:msg];
        }
    }
    
    
}

- (void)updateChatView:(Message *)msg
{
    //构建更新视图的模型
    MessageFrame *lastMsg = [_messagesDataSource lastObject];
    Message *message = lastMsg.message;
    NSString *previousTime = message.msgTime;
    MessageFrame *msgFrame = [self compentMessageFrameWithMessage:msg previousTime:previousTime];
    [_messagesDataSource addObject:msgFrame];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        //显示到视图
        [self.msgView setMessagesDataSource:_messagesDataSource];
    });
}

#pragma mark -- 发送消息
- (void)sendMsg:(NSString *)message fileType:(int)type
{
    JFRWebSocket *socket = [AppDelegate delegate].socket;
    
    if (!socket.isConnected) { // websocket连接已经断开
//        [self showWebSocket:socket DisconnectedAlertWithErrorCode:50];
//        ((AppDelegate*)[UIApplication sharedApplication].delegate) websocketDidDisconnect;
        if([socket.delegate respondsToSelector:@selector(websocketDidDisconnect:error:)]){
            NSError *error=[NSError errorWithDomain:@"" code:50 userInfo:nil];
            [socket.delegate websocketDidDisconnect:socket error:error];
        }
        return;
    }
    
    //消息发送
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *nowTime = [formatter stringFromDate:[NSDate date]];
    NSString *sendMsg = nil;
    if (type == 1) {
        if (_chatType == ChatTypeGroup) {//文件
            sendMsg = [NSString stringWithFormat:@"[\"pic\",\"%@\",\"%@\",\"%@\",\"true\"]",_msg.msgFromerId, message, nowTime];
        } else {//单聊
            sendMsg = [NSString stringWithFormat:@"[\"pic\",\"%@\",\"%@\",\"%@\",\"false\"]",_msg.msgFromerId, message, nowTime];
        }
    } else {
        if (_chatType == ChatTypeGroup) {//文本
            sendMsg = [NSString stringWithFormat:@"[\"string\",\"%@\",\"%@\",\"%@\",\"true\"]",_msg.msgFromerId, message, nowTime];
        } else {//单聊
            sendMsg = [NSString stringWithFormat:@"[\"string\",\"%@\",\"%@\",\"%@\",\"false\"]",_msg.msgFromerId, message, nowTime];
        }
    }
    
    
    [socket writeString:sendMsg];
    
    //发送后 将消息保存在本地
    [self saveMsgToDB:message fileType:type sendTime:nowTime];
}

- (void)saveMsgToDB:(NSString *)message fileType:(int)type sendTime:(NSString *)time
{
    Message *sendMessage = [[Message alloc] init];
    sendMessage.msgFromerId = _msg.msgFromerId;
    sendMessage.msgFromerName = _msg.msgFromerName;
    sendMessage.msgContent = message;
    sendMessage.msgToId = [AppInfoManager getUserName];
    sendMessage.msgToName = [AppInfoManager getValueForKey:kKeyOfUserRealName];
    sendMessage.msgTime = time;
    sendMessage.msgType = @"0";
    sendMessage.fileType = type;
    sendMessage.chatType = _chatType;
    if (_chatType == ChatTypeGroup) {
        sendMessage.groupId = _msg.groupId;
    } else {
        sendMessage.groupId = @"";
    }
    
    if (!_isSenderPicture) {
        
        [self updateChatView:sendMessage];
    }
    
    [self messageHandle:sendMessage isSendToMe:YES];
}

#pragma mark -- 发送图片（文件）

- (void)showChooseActionSheet
{
    if (currentOSVersion >= 9.0) {//最新系统
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"选择本地相册图片" message:@"或者通过相机拍摄" preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        
        
        UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"相册" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *sheet){
            
            [self imagePickerShow:UIImagePickerControllerSourceTypePhotoLibrary];
        }];
        UIAlertAction *archiveAction = [UIAlertAction actionWithTitle:@"相机" style:UIAlertActionStyleDefault handler:^(UIAlertAction *sheet){
            
            [self imagePickerShow:UIImagePickerControllerSourceTypeCamera];
        }];
        
        [alertController addAction:cancelAction];
        [alertController addAction:deleteAction];
        [alertController addAction:archiveAction];
        
        [self presentViewController:alertController animated:YES completion:nil];
    } else {//9.0之前的版本
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"选择本地相册图片\n或者通过相机拍摄" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"相机", @"相册", nil];
        [actionSheet showInView:self.view];
    }
}

/**
 *  通过UIImagePickerControllerSourceType来弹出对应的controller
 *
 *  @param type
 */
- (void)imagePickerShow:(UIImagePickerControllerSourceType)type
{
    //判断是否有摄像头
    if(![UIImagePickerController isSourceTypeAvailable:type])
    {
        type = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    
    [_imagePickerController setDelegate:self];
    [_imagePickerController setSourceType:type];
    
    [self presentViewController:_imagePickerController animated:YES completion:nil];
}

#pragma mark -- ios9.0之前的代理

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"index:%ld", buttonIndex);
    
    if (buttonIndex == 2) {//取消
        
        [actionSheet removeFromSuperview];
    } else if (buttonIndex == 1) {//相册
        
        [self imagePickerShow:UIImagePickerControllerSourceTypePhotoLibrary];
    } else if (buttonIndex == 0) {//相机
        
        [self imagePickerShow:UIImagePickerControllerSourceTypeCamera];
    }
}

#pragma mark -- 拍照或者获取相册图片后，选择图片后的处理

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    
    // 调整图片方向
    image = [image fixOrientation];
    
    //上传文件
    _isSenderPicture = YES;
    [self uploadFiles:image];
    
    Message *sendMessage = [[Message alloc] init];
    sendMessage.msgFromerId = _msg.msgFromerId;
    sendMessage.msgFromerName = _msg.msgFromerName;
    sendMessage.msgContent = @"";
    sendMessage.msgToId = [AppInfoManager getUserName];
    sendMessage.msgToName = [AppInfoManager getValueForKey:kKeyOfUserRealName];
    sendMessage.msgTime = [Public stringFromDate:[NSDate date] formatt:@"yyyy-MM-dd HH:mm:ss"];
    sendMessage.msgType = @"0";
    sendMessage.fileType = 1;
    sendMessage.chatType = _chatType;
    if (_chatType == ChatTypeGroup) {
        sendMessage.groupId = _msg.groupId;
    } else {
        sendMessage.groupId = @"";
    }
    sendMessage.sendPicImage = image;
    
    //更新视图
    [self updateChatView:sendMessage];
}

//用户取消拍照
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -- 发送文件

- (void)uploadFiles:(id)file
{
    NSData *imgData = UIImageJPEGRepresentation(file, 0.1);
    
    [[HttpManager sharedHttpManager] fileUploadURL:kUploadFileServerURL data:imgData name:@"file" mimeType:@"image/jpg" fileName:@"123.jpg" success:^(NSDictionary *dic) {
        
        if (dic) {
            NSString *filePath = [dic valueForKey:@"url"];
            
            //将此消息发送给对方
            [self sendMsg:filePath fileType:1];
            
            //保存到本地
            [self saveImageToLocal:file fileName:filePath];
        }
    } fail:^(NSError *error) {
        NSLog(@"上传图片失败：%@", error);
    } progress:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
        NSString *percent = [NSString stringWithFormat:@"%.2f", ((double)totalBytesWritten) / totalBytesExpectedToWrite];
        NSLog(@"%@", percent);
    }];
}

- (BOOL)saveImageToLocal:(UIImage *)image fileName:(NSString *)fileName
{
    BOOL saved = NO;
    NSRange range = [fileName rangeOfString:@"/" options:NSBackwardsSearch];
    NSString *shotFileName = fileName;
    if (range.location != NSNotFound) {
        shotFileName = [fileName substringFromIndex:range.location];
    }
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[paths firstObject] stringByAppendingFormat:@"%@", shotFileName];
    BOOL isHave = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
    if (!isHave) {
        BOOL isSuccess = [UIImageJPEGRepresentation(image, 0.1) writeToFile:filePath atomically:YES];
        saved = isSuccess;
    }
    return saved;
}

#pragma mark -- 文件查看

- (void)handleFile:(int)fileType filePath:(NSString *)path
{
    NSLog(@"fileType:%d, file:%@", fileType, path);
}

// 在新页面打开url
- (void)openUrl:(NSString *)url OfApp:(NSString *)appNo {
    NSLog(@"url: %@, of App: %@", url, appNo);
    //
    NewWebViewController *newWebVC = [[NewWebViewController alloc] init];
    newWebVC.url = url;
    newWebVC.appNo = appNo;
    [self.navigationController pushViewController:newWebVC animated:YES];
}

- (void)openApp:(NSString *)appNo {
    NSLog(@"app: %@", appNo);
    
    if (!appNo) {
        NSLog(@"未找到分享的app");
        if (currentOSVersion >= 9.0) {
            UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"未找到分享的应用" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            
            [alertVc addAction:cancel];
            [self presentViewController:alertVc animated:YES completion:nil];
        }
        else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"分享未找到分享的应用" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
        }
        return;
    }
    
    AppProduct *destinationApp = [[[CoreDataManager alloc] init] getAppProductByAppNo:[NSNumber numberWithInt:[appNo intValue]]];
    
    NSString *appIndexUrl = destinationApp.appIndexUrl;
    [MyUtils openUrl:appIndexUrl ofApp:destinationApp];
    
}

- (void)viewOriginalImage:(UIImage *)image{
    
    NSLog(@"view image");
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height, 0, 0)];
    
    imgView.image = image;
    imgView.tag = 9001;
    imgView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(finishViewOriginalImage)];
    [imgView addGestureRecognizer:tap];
    
    [UIView animateWithDuration:0.4 animations:^{
        [self.view addSubview:imgView];
        imgView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    }];
    
    
}

// 是否支持转屏
- (BOOL)shouldAutorotate {
    BOOL isIpad = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad;
    if (isIpad) {
        return YES;
    }else{
        return NO;
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (alertView.tag) {
        case 9001:
            switch (buttonIndex) {
                case 0:
                    exit(0);
                    break;
                case 1:
                    [[AppDelegate delegate].socket connect];
                    break;
                default:
                    break;
            }
            
            break;
        case 9002:
            switch (buttonIndex) {
                case 0:
                    break;
                case 1:
                    [[AppDelegate delegate].socket connect];
                    break;
                default:
                    break;
            }
            break;
        default:
            break;
    }
}

- (void)finishViewOriginalImage {
    for (UIView *view in self.view.subviews) {
        if (view.tag == 9001) {
            [view removeFromSuperview];
        }
    }
}
- (void)showWebSocket:(JFRWebSocket*)socket DisconnectedAlertWithErrorCode:(NSInteger) code {
    //把 消息 图标设置为灰色
    [[NSNotificationCenter defaultCenter] postNotificationName:@"changMessageIcon" object:nil];
    if ([MyUtils isSystemVersionBelowEight]) {
        if (code == 1000) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"您的账号在异地登录" delegate:self cancelButtonTitle:@"退出应用" otherButtonTitles:@"重新登录", nil];
            alert.tag = 9001;
            [alert show];
            
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"您的网络出问题咯，可能无法正常使用消息的功能。" delegate:self cancelButtonTitle:@"稍后再试" otherButtonTitles:@"重新连接", nil];
            alert.tag = 9002;
            [alert show];
            
        }
        
    }
    else {
        if (code == 1000) {
            UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"您的账号在异地登录" preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *relogin = [UIAlertAction actionWithTitle:@"重新登录" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                [socket connect];
            }];
            
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"退出应用" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                exit(0);
            }];
            
            [alertVc addAction:cancel];
            [alertVc addAction:relogin];
            
            [self presentViewController:alertVc animated:YES completion:nil];
        } else {
            UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"您的网络出问题咯，可能无法正常使用消息的功能。" preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *relogin = [UIAlertAction actionWithTitle:@"重新连接" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                [socket connect];
            }];
            
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"稍后再试" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            
            [alertVc addAction:cancel];
            [alertVc addAction:relogin];
            
            [self presentViewController:alertVc animated:YES completion:nil];
        }
    }
}


@end
