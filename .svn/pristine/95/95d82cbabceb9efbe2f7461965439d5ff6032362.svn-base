//
//  GroupInfoView.h
//  CIBSafeBrowser
//
//  Created by YangChao on 29/1/16.
//  Copyright © 2016年 cib. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Chatter;
@interface GroupInfoView : UIView

@property (nonatomic, strong) NSMutableArray *members;

@property (nonatomic, strong) void (^BackBlock)();//返回按钮事件

@property (nonatomic, strong) void (^AddNewMembers)();//添加新成员到群的事件

@property (nonatomic, strong) void (^QuitOutOfGroup)();//退出群的事件

@property (nonatomic, strong) void (^DelGroupMember)(Chatter *chatter);//踢人出群

@end
