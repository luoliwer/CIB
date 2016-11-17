//
//  ViewController.m
//  ChatDemo
//
//  Created by YangChao on 18/1/16.
//  Copyright © 2016年 swy. All rights reserved.
//

#import "NewsListController.h"
#import "MessagesController.h"
#import "Message.h"
#import "NewsListView.h"
#import "ChatFunctionView.h"
#import "OpenChatController.h"
#import "JFRWebSocket.h"
#import "Chatter.h"
#import "ChatDBManager.h"
#import "Config.h"
#import "HttpManager.h"
#import "Public.h"
#import <CIBBaseSDK/CIBBaseSDK.h>
#import "AppDelegate.h"
#import "NewWebViewController.h"
#import "MyUtils.h"

@interface NewsListController ()<JFRWebSocketDelegate, UIAlertViewDelegate>
{
    NSMutableArray *_messagesArray;
}

@property (nonatomic, weak) NewsListView *msgListView;

@end

@implementation NewsListController

- (void)viewDidLoad {
    [super viewDidLoad];
    _messagesArray = [NSMutableArray array];
    
    NewsListView *listView = [[NewsListView alloc] init];
    listView.ChatWithSomeone = ^(Message *msg){
        [self chat:msg];
    };
    listView.openFunctions = ^{
        [self openFuns];
    };
    listView.BackBlock = ^{
        [self back];
    };
    [self.view addSubview:listView];
    
    self.msgListView = listView;
    
//    //暂时不用该接口
//    [self userLoginAndValidate];
    
    //获取当前用户信息，保存到本地数据库
    NSString *ID = [AppInfoManager getUserName];
    Chatter *currentLoginUser = [[ChatDBManager sharedDatabaseManager] queryContactor:ID];
    
    if (!currentLoginUser) {
        [self getChatterNameFromChatterId:ID success:^(NSString *chatterName, NSString *iconPath) {
            
            Chatter *chat = [[Chatter alloc] init];
            chat.chatterId= ID;
            chat.chatterName = chatterName;
            chat.iconPath = iconPath;
            
            [[ChatDBManager sharedDatabaseManager] addContactor:chat];
        } failure:^(NSError *error) {
            
        }];
    }
    
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
    //本地获取聊天数据
    [self localMessages];
    
    [self initSocket];
    
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

- (void)userLoginAndValidate
{
    NSString *userId = [AppInfoManager getUserID];
    [AppInfoManager resetUserToken:^(NSString *response) {//设置TOKEN
        NSLog(@"response token:%@", response);
        NSArray *temp = [response componentsSeparatedByString:@","];
        NSArray *tokenArr = [temp[1] componentsSeparatedByString:@":"];
        NSString *deviceId = [AppInfoManager getDeviceID];
        NSString *token = [tokenArr[1] substringToIndex:[tokenArr[1] length] - 2];
        NSString *parameter = [NSString stringWithFormat:@"[\"%@\", %@, \"false\", \"%@\", \"1\"]", userId, token, deviceId];
        
        NSLog(@"login URL is %@", parameter);
        [[HttpManager sharedHttpManager] login:kLoginServerURL parameters:@{@"parameter":parameter} success:^(NSDictionary *dic) {
            if (dic) {
                NSLog(@"登录信息：%@", dic);
            }
        } fail:^(NSError *error) {
            NSLog(@"登录信息：%@", error);
        }];
    }];
    
}

#pragma mark - 返回

- (void)back
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 和某人聊天

- (void)chat:(Message *)msg
{
    MessagesController *msgController = [[MessagesController alloc] init];
    msgController.msg = msg;
    //设置聊天模式
    msgController.chatType = msg.chatType;
    if (msg.chatType == ChatTypeGroup) {
        msg.groupId = msg.msgFromerId;
    }
    //将新消息数置为0
    msg.msgNum = 0;
    //更新本地数据信息
    [[ChatDBManager sharedDatabaseManager] updateNewestMessage:msg];
    [self.navigationController pushViewController:msgController animated:YES];
}

- (void)openFuns
{
//    ChatFunctionView *funView = [[ChatFunctionView alloc] init];
//    [funView showViewHandleClickEventHandle:^(NSIndexPath *indexPath) {
//        //进入发起聊天页面
//        OpenChatController *openController = [[OpenChatController alloc] initWithNibName:@"OpenChatController" bundle:nil];
//        [self.navigationController pushViewController:openController animated:YES];
//    }];
//    [self.view addSubview:funView];
    
    //进入发起聊天页面
    OpenChatController *openController = [[OpenChatController alloc] initWithNibName:@"OpenChatController" bundle:nil];
    openController.isFromShare = NO;
    [self.navigationController pushViewController:openController animated:YES];
    
}

#pragma mark -- WebSocket Delegate methods.

-(void)websocketDidConnect:(JFRWebSocket*)socket {
    
}

-(void)websocketDidDisconnect:(JFRWebSocket*)socket error:(NSError*)error {
    NSLog(@"websocket is disconnected: %ld", [error code]);
    NSInteger code = error.code;
    //把 消息 图标设置为灰色
    [[NSNotificationCenter defaultCenter] postNotificationName:@"changMessageIcon" object:nil];
    if (![AppDelegate delegate].isAppActive) { // app已处于后台状态，无需弹出websocket断开的提示框
        return;
    }
    
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

-(void)websocket:(JFRWebSocket*)socket didReceiveMessage:(NSString*)string {
    NSLog(@"Received text: %@", string);
    [[AppDelegate delegate] updateUnreadMsgNumber:string];
    [self dealString:string];
}

-(void)websocket:(JFRWebSocket*)socket didReceiveData:(NSData*)data {
    NSLog(@"Received data: %@", data);
}

#pragma mark -- 接收到消息处理

- (void)dealString:(NSString *)msg
{
    NSError *err;
    NSData *data = [msg dataUsingEncoding:NSUTF8StringEncoding];
    id item = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&err];
    
    if ([item isKindOfClass:[NSArray class]]) {
        NSArray *temp = (NSArray *)item;
        NSString *chatType = temp[0];
        NSString *toID = [AppInfoManager getUserName];
        NSString *toName = [AppInfoManager getValueForKey:kKeyOfUserRealName];
        if ([chatType isEqualToString:@"chat"]) {
            //根据返回的数据来判断该消息是群聊消息 还是单聊消息
            NSString *flag = temp[2];
            ChatType type = 0;
            if (flag && ![flag isEqualToString:@""]) {
                type = ChatTypeGroup;
            } else {
                type = ChatTypeDefault;
            }
            Message *message = [[Message alloc] init];
            NSString *fileType = temp[5];
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
//            NSLog(@"收到的URL消息是%@,%d", message.msgContent, message.fileType);
            if (type == ChatTypeGroup) {
                message.groupId = temp[1];
                message.msgFromerId = temp[2];
                message.msgTime = [Public stringFromDate:[NSDate date] formatt:@"yyyy-MM-dd HH:mm:ss"];
                id content = temp[4];
                if ([content isKindOfClass:[NSString class]]) { // 文字/图片/文件类消息
                    message.msgContent = (NSString *)content;
                }
                else if ([content isKindOfClass:[NSDictionary class]]) { // url/app类消息
                    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:content options:NSJSONWritingPrettyPrinted error:nil];
                    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
//                    NSLog(@"收到消息体是：%@", jsonString);
                    message.msgContent = jsonString;
                }
                else {
                    message.msgContent = @"消息格式解析错误";
                }
                message.msgToId = toID;
                message.msgToName = toName;
                message.msgType = @"1";
            } else {
                message.msgFromerId = temp[1];
                message.msgTime = [Public stringFromDate:[NSDate date] formatt:@"yyyy-MM-dd HH:mm:ss"];
                id content = temp[4];
                if ([content isKindOfClass:[NSString class]]) { // 文字/图片/文件类消息
                    message.msgContent = (NSString *)content;
                }
                else if ([content isKindOfClass:[NSDictionary class]]) { // url/app类消息
                    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:content options:NSJSONWritingPrettyPrinted error:nil];
                    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                    message.msgContent = jsonString;
//                    NSLog(@"收到消息体是：%@", jsonString);
                }
                else {
                    message.msgContent = @"消息格式解析错误";
                }
                message.msgToId = toID;
                message.msgToName = toName;
                message.msgType = @"1";
                message.groupId = @"";
            }
            message.chatType = type;
            Chatter *chat = [[ChatDBManager sharedDatabaseManager] queryContactor:message.msgFromerId];

            if (chat) {
                if (chat.iconPath == nil || [chat.iconPath isEqual:[NSNull null]]) {
                    [self getChatterNameFromChatterId:message.msgFromerId success:^(NSString *chatterName, NSString *iconPath) {
                        message.msgFromerName = chatterName;
                        // 更新此联系人
                        [[ChatDBManager sharedDatabaseManager] updateContactor:message.msgFromerId name:chatterName iconPath:iconPath];
                    } failure:^(NSError *error) {
                    }];
                }
                message.msgFromerName = chat.chatterName;
                [self messageHandle:message];
            } else {
                [self getChatterNameFromChatterId:message.msgFromerId success:^(NSString *chatterName, NSString *iconPath) {
                    message.msgFromerName = chatterName;
                    // 存储此新的联系人
                    Chatter *newChatter = [[Chatter alloc] init];
                    newChatter.chatterId = message.msgFromerId;
                    newChatter.chatterName = chatterName;
                    newChatter.iconPath = iconPath;
                    [[ChatDBManager sharedDatabaseManager] addContactor:newChatter];
                    [self messageHandle:message];
                } failure:^(NSError *error) {
                    message.msgFromerName = message.msgFromerId;
                    [self messageHandle:message];
                }];
            }
            
            
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
                                //根据返回的数据来判断该消息是群聊消息 还是单聊消息
                                NSString *flag = [(NSArray *)item objectAtIndex:0];
                                ChatType type = 0;
                                if (flag && ![flag isEqualToString:@""]) {
                                    type = ChatTypeGroup;
                                } else {
                                    type = ChatTypeDefault;
                                }
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
//                                NSLog(@"收到的URL消息是%@,%d", unlineMsg.msgContent, unlineMsg.fileType);
                                if (type == ChatTypeGroup) {
                                    unlineMsg.groupId = notesId;
                                    unlineMsg.msgFromerId = [(NSArray *)item objectAtIndex:0];
                                    unlineMsg.msgTime = [(NSArray *)item objectAtIndex:1];
                                    id content = [(NSArray *)item objectAtIndex:2];
                                    if ([content isKindOfClass:[NSString class]]) { // 文字/图片/文件类消息
                                        unlineMsg.msgContent = (NSString *)content;
                                    }
                                    else if ([content isKindOfClass:[NSDictionary class]]) { // url/app类消息
                                        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:content options:NSJSONWritingPrettyPrinted error:nil];
                                        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                                        unlineMsg.msgContent = jsonString;
//                                        NSLog(@"收到消息体是：%@", jsonString);
                                    }
                                    else {
                                        unlineMsg.msgContent = @"消息格式解析错误";
                                    }
                                } else {
                                    unlineMsg.groupId = @"";
                                    unlineMsg.msgFromerId = notesId;
                                    unlineMsg.msgTime = [(NSArray *)item objectAtIndex:1];
                                    id content = [(NSArray *)item objectAtIndex:2];
                                    if ([content isKindOfClass:[NSString class]]) { // 文字/图片/文件类消息
                                        unlineMsg.msgContent = (NSString *)content;
                                    }
                                    else if ([content isKindOfClass:[NSDictionary class]]) { // url/app类消息
                                        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:content options:NSJSONWritingPrettyPrinted error:nil];
                                        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                                        unlineMsg.msgContent = jsonString;
//                                        NSLog(@"收到消息体是：%@", jsonString);
                                    }
                                    else {
                                        unlineMsg.msgContent = @"消息格式解析错误";
                                    }
                                }
                                unlineMsg.msgToId = toID;
                                unlineMsg.msgToName = toName;
                                unlineMsg.msgType = @"1";
                                unlineMsg.chatType = type;
                                Chatter *chat = [[ChatDBManager sharedDatabaseManager] queryContactor:unlineMsg.msgFromerId];
                                
                                if (chat) {
                                    if (chat.iconPath == nil || [chat.iconPath isEqual:[NSNull null]]) {
                                        [self getChatterNameFromChatterId:unlineMsg.msgFromerId success:^(NSString *chatterName, NSString *iconPath) {
                                            unlineMsg.msgFromerName = chatterName;
                                            // 更新此联系人
                                            [[ChatDBManager sharedDatabaseManager] updateContactor:unlineMsg.msgFromerId name:chatterName iconPath:iconPath];
                                        } failure:^(NSError *error) {
                                        }];
                                    }
                                    unlineMsg.msgFromerName = chat.chatterName;
                                    [self messageHandle:unlineMsg];
                                } else {
                                    [self getChatterNameFromChatterId:unlineMsg.msgFromerId success:^(NSString *chatterName, NSString *iconPath) {
                                        unlineMsg.msgFromerName = chatterName;
                                        // 存储此新的联系人
                                        Chatter *newChatter = [[Chatter alloc] init];
                                        newChatter.chatterId = unlineMsg.msgFromerId;
                                        newChatter.chatterName = chatterName;
                                        newChatter.iconPath = iconPath;
                                        [[ChatDBManager sharedDatabaseManager] addContactor:newChatter];
                                        [self messageHandle:unlineMsg];
                                    } failure:^(NSError *error) {
                                        unlineMsg.msgFromerName = unlineMsg.msgFromerId;
                                        [self messageHandle:unlineMsg];
                                    }];
                                }
                                
                            }
                        }
                    }
                }
            }
            
        }
    
}

/**
 *  获取的新消息处理
 *  判断该消息的来源和当前用户的消息记录是否存在，存在则修改本地数据和界面数据
 *  不存在，插入数据和添加到本地
 *  @param msg 消息
 */
- (void)messageHandle:(Message *)msg
{
    //将获取到的消息记录
    [[ChatDBManager sharedDatabaseManager] addChatMessage:msg];
    if (msg.chatType == ChatTypeGroup) {
        msg.msgFromerId = msg.groupId;
    }
    
    BOOL isExist = [[ChatDBManager sharedDatabaseManager] ifExistNewestMessage:msg];
    
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
    
    [self localMessages];
}

#pragma mark -- 本地聊天数据获取

- (void)localMessages
{
    if (_messagesArray && _messagesArray.count > 0) {
        [_messagesArray removeAllObjects];
    }
    _messagesArray = [[ChatDBManager sharedDatabaseManager] allNewestMessage];
     NSInteger unreadMsgCounts = 0;
    for (Message *chatMessage in _messagesArray) {
        unreadMsgCounts = unreadMsgCounts + chatMessage.msgNum;
    }

    [self.msgListView setSourceDatas:_messagesArray];
}

- (void)getChatterNameFromChatterId:(NSString *)chatterId
                            success:(void (^)(NSString *chatterName, NSString *iconPath))success
                            failure:(void (^)(NSError *error))failure;
{
    /*
    id noteIdDic = @{@"notesId":chatterId};
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
            
            NSString *userName = [[[dic objectForKey:@"result"] firstObject] valueForKey:@"USERNAME"] ? : chatterId;
            NSString *iconPath = [[[dic objectForKey:@"result"] firstObject] valueForKey:@"PICSTRING"];
            
            NSLog(@"用户姓名：%@", userName);
            success(userName, iconPath);
        }
    } fail:^(NSError *error) {
        NSLog(@"%@", error);
        failure(error);
    }];
     */
    id noteIdDic = @{@"notesid":chatterId};
    [CIBRequestOperationManager invokeAPI:@"contactsguiv2" byMethod:@"POST" withParameters:noteIdDic onRequestSucceeded:^(NSString *responseCode, NSString *responseInfo) {
        
        if ([responseCode isEqualToString:@"I00"]) {
            NSString *resultCode = [responseInfo valueForKey:@"resultCode"];
            if ([resultCode isEqualToString:@"0"]) {
                NSArray *resultDic = [responseInfo valueForKey:@"result"];
                NSString *userName = [[resultDic firstObject] valueForKey:@"USERNAME"] ? : chatterId;
                NSLog(@"用户姓名：%@", userName);
                NSString *iconPath = [[resultDic firstObject] valueForKey:@"PICSTRING"];
                
                success(userName, iconPath);
            }
        }
        
    } onRequestFailed:^(NSString *responseCode, NSString *responseInfo) {
        NSLog(@"%@", responseInfo);
        NSError *error = [NSError errorWithDomain:@"com.cib.chat" code:[responseCode integerValue] userInfo:@{NSLocalizedDescriptionKey: responseInfo}];
        failure(error);
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


@end
