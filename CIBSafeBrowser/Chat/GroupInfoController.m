//
//  GroupInfoController.m
//  CIBSafeBrowser
//
//  Created by YangChao on 29/1/16.
//  Copyright © 2016年 cib. All rights reserved.
//

#import "GroupInfoController.h"
#import "GroupInfoView.h"
#import "OpenChatController.h"
#import "HttpManager.h"
#import "Config.h"
#import <CIBBaseSDK/CIBBaseSDK.h>
#import "ChatDBManager.h"
#import "Chatter.h"
#import "Message.h"

@interface GroupInfoController ()
{
    NSArray *_hadMembers;//现有成员的id
}

@property (nonatomic, weak) GroupInfoView *groupView;

@end

@implementation GroupInfoController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _hadMembers = [NSArray array];
    
    GroupInfoView *infoView = [[GroupInfoView alloc] init];
    
    //返回上一级
    infoView.BackBlock = ^{
        [self back];
    };
    
    //添加成员
    infoView.AddNewMembers = ^{
        [self addMember];
    };
    
    //退出群
    infoView.QuitOutOfGroup = ^{
        [self quitOutGroup];
    };
    
    //踢人出群
    infoView.DelGroupMember = ^(Chatter *chatter) {
        [self deleteGroupMember:chatter];
    };
    
    [self.view addSubview:infoView];
    
    self.groupView = infoView;
    
    //获取群名称
    [self groupName:_groupId];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //获取全部成员
    [self allMembers:_groupId];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark -- 获取群成员

- (void)allMembers:(NSString *)groupId
{
    NSString *parameter = [NSString stringWithFormat:@"%@parameter=['getMembers','%@']",kServerURL, groupId];
    NSLog(@"所有群成员参数：%@", parameter);
    [[HttpManager sharedHttpManager] allMembersOfGroupUrl:[parameter stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] parameters:nil success:^(NSDictionary *dic) {
        
        if (dic) {
            
            if ([[dic valueForKey:@"flag"] boolValue] && [dic valueForKey:@"info"]) {
                
                NSString *infoVal = [dic valueForKey:@"info"];
                NSError *err = nil;
                NSData *data = [infoVal dataUsingEncoding:NSUTF8StringEncoding];
                NSArray *item = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&err];
                _hadMembers = item;
                NSMutableArray *members = [NSMutableArray arrayWithArray:item];
                self.groupView.members = members;
            }
        }
    } fail:^(NSError *error) {
        
    }];
}

#pragma mark -- 返回上一级
- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -- 添加群成员
- (void)addMember
{
    OpenChatController *controller = [[OpenChatController alloc] initWithNibName:@"OpenChatController" bundle:nil];
    controller.groupId = _groupId;
    controller.groupHadMembers = _hadMembers;
    controller.isFromShare = NO;
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark -- 退出群
- (void)quitOutGroup
{
    NSString *parameter = [NSString stringWithFormat:@"%@parameter=['removeGroupMembers','%@',['%@']]",kServerURL, _groupId, [AppInfoManager getUserName]];
    NSLog(@"所有群成员参数：%@", parameter);
    [[HttpManager sharedHttpManager] removeMemberOutGroupUrl:[parameter stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] parameters:nil success:^(NSDictionary *dic) {
        
        //退出成功
        if (dic) {
            
            if ([[dic valueForKey:@"flag"] boolValue]) {
                //删除本地聊天数据
                [[ChatDBManager sharedDatabaseManager] deleteNewestMessageWithFromerID:_groupId];
                [[ChatDBManager sharedDatabaseManager] deleteGroupMessageWithGroupID:_groupId];
                
                //跳转到指定的页面
                if (_backToViewControllerName && ![_backToViewControllerName isEqualToString:@""]) {
                    for (UIViewController *item in self.navigationController.viewControllers) {
                        if ([item isKindOfClass:NSClassFromString(_backToViewControllerName)]) {
                            [self.navigationController popToViewController:item animated:YES];
                        }
                    }
                }
            }
        }
    } fail:^(NSError *error) {
        
    }];
}

#pragma mark -- 踢人出群
- (void)deleteGroupMember:(Chatter *)chatter
{
    NSString *parameter = [NSString stringWithFormat:@"%@parameter=['removeGroupMembers','%@',['%@']]",kServerURL, _groupId, chatter.chatterId];
    NSLog(@"所有群成员参数：%@", parameter);
    [[HttpManager sharedHttpManager] removeMemberOutGroupUrl:[parameter stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] parameters:nil success:^(NSDictionary *dic) {
        
        //踢人成功
        if (dic) {
            
            if ([[dic valueForKey:@"flag"] boolValue]) {
                
                //跳转到指定的页面
                if (_backToViewControllerName && ![_backToViewControllerName isEqualToString:@""]) {
                    for (UIViewController *item in self.navigationController.viewControllers) {
                        if ([item isKindOfClass:NSClassFromString(_backToViewControllerName)]) {
                            [self.navigationController popToViewController:item animated:YES];
                        }
                    }
                }
            }
        }
    } fail:^(NSError *error) {
        
    }];
}

#pragma mark -- 获取群名称

- (void)groupName:(NSString *)groupId
{
    NSString *parameter = [NSString stringWithFormat:@"%@parameter=['getGroupNickName',%@]",kServerURL, groupId];
    
    [[HttpManager sharedHttpManager] groupNameUrl:[parameter stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] parameters:nil success:^(NSDictionary *dic) {
        if (dic) {
            NSLog(@"获取的群名称：%@", dic);
            
            Message *message = [[ChatDBManager sharedDatabaseManager] findNewestMessageFromerID:groupId];
            
            if (message) {
                //将群名称设置成最新获取的群昵称
                message.msgFromerName = @"黄药师、洪七公、黄蓉";
//                [[ChatDBManager sharedDatabaseManager] updateNewestMessage:message];
            }
        }
    } fail:^(NSError *error) {
        
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

@end
