//
//  NewsListView.m
//  ChatDemo
//
//  Created by YangChao on 18/1/16.
//  Copyright © 2016年 swy. All rights reserved.
//

#import "NewsListView.h"
#import "NewsCell.h"
#import "Message.h"
#import "ChatDBManager.h"
#import "Config.h"

@interface NewsListView ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) UITableView *msgListTable;

@property (nonatomic, weak) UIButton *backButton;

@end

@implementation NewsListView


- (instancetype)init
{
    if (self = [super init]) {
        self.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        
        [self setup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.frame = frame;
        
        [self setup];
    }
    return self;
}

- (void)setup
{
    //背景色
    self.backgroundColor = [UIColor colorWithRed:18.0/255 green:119.0/255 blue:179.0/255 alpha:1.0];
    
    UILabel *titleLb = [[UILabel alloc] init];
    CGFloat titleW = 160;
    CGFloat titleH = 44;
    CGFloat titleX = ([UIScreen mainScreen].bounds.size.width - titleW) / 2;
    CGFloat titleY = 20;
    titleLb.frame = CGRectMake(titleX, titleY, titleW, titleH);
    titleLb.font = [UIFont systemFontOfSize:18];
    titleLb.textAlignment = NSTextAlignmentCenter;
    titleLb.textColor = [UIColor whiteColor];
    titleLb.text = @"消息列表";
    [self addSubview:titleLb];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 20, 44, 44);
    [button setContentMode:UIViewContentModeCenter];
    [button setImage:[UIImage imageNamed:@"btn_pop_back"] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@"btn_pop_back_p"] forState:UIControlStateHighlighted];
    [button addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button];
    
    self.backButton = button;
    
    //添加对话按钮
    UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    CGFloat w = 44, h = 44;
    CGFloat x = [UIScreen mainScreen].bounds.size.width - 44 - 14;//距离右边14个dp
    
    [addBtn setFrame:CGRectMake(x, 20, w, h)];
    
    [addBtn setImage:[UIImage imageNamed:@"btn_add"] forState:UIControlStateNormal];
    
    [addBtn addTarget:self action:@selector(showChooeBox:) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:addBtn];
    
    //列表
    UITableView *listTable = [[UITableView alloc] init];
    listTable.frame = CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 64);
    listTable.backgroundColor = [UIColor colorWithRed:236/255.0 green:240/255.0 blue:243/255.0 alpha:1.0];
    listTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    listTable.dataSource = self;
    listTable.delegate = self;
    [self addSubview:listTable];
    
    UIView *view = [[UIView alloc]init];
    view.backgroundColor = [UIColor clearColor];
    [listTable setTableFooterView:view];
    
    self.msgListTable = listTable;
}

- (void)setSourceDatas:(NSMutableArray *)sourceDatas
{
    _sourceDatas = sourceDatas;
    
    [self.msgListTable reloadData];
}

#pragma mark -- 返回上一页
- (void)back
{
    if (_BackBlock) {
        _BackBlock();
    }
}

#pragma mark -- 发起会话功能
- (void)showChooeBox:(UIButton *)btn
{
    if (_openFunctions) {
        _openFunctions();
    }
}

#pragma mark -- UITaleView的数据源和代理
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _sourceDatas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *iD = @"NewsCell";
    NewsCell *cell = [tableView dequeueReusableCellWithIdentifier:iD];
    
    if (cell == nil) {
        cell = [[NSBundle mainBundle] loadNibNamed:@"NewsCell" owner:nil options:nil][0];
    }
    
    Message *message = _sourceDatas[indexPath.row];
    
    cell.message = message;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0;
}

#pragma mark--点击设置高亮显示和通用情况
- (void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.backgroundColor = [UIColor lightGrayColor];
}

- (void)tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.backgroundColor = [UIColor whiteColor];
}

#pragma mark--删除
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSLog(@"删除中...");
        //清除对应的本地聊天数据
        Message *msg = _sourceDatas[indexPath.row];
        [[ChatDBManager sharedDatabaseManager] deleteNewestMessage:msg];
        if (msg.chatType == 1) {//群消息
            [[ChatDBManager sharedDatabaseManager] deleteGroupMessageWithGroupID:msg.msgFromerId];//删除对应的群消息
        } else {
            [[ChatDBManager sharedDatabaseManager] deleteMessageWithFromerID:msg.msgFromerId toId:msg.msgToId];//
        }
        //从数据源中移除数据
        [_sourceDatas removeObjectAtIndex:indexPath.row];
        //更新当前行
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        // 更新未读消息数目
        [self updateUnreadMsgNumberWhenClickedOnMessage:msg];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Message *msg = _sourceDatas[indexPath.row];
    
    // 更新未读消息数目
    [self updateUnreadMsgNumberWhenClickedOnMessage:msg];

    if (_ChatWithSomeone) {
        _ChatWithSomeone(msg);
    }
}

- (void)updateUnreadMsgNumberWhenClickedOnMessage:(Message *)msg {
    NSInteger msgNumber = (long)msg.msgNum;
    
    NSInteger currentUnreadMsgNumber = [[[NSUserDefaults standardUserDefaults] objectForKey:kKeyOfUnreadMsgNumber] integerValue];
    
    currentUnreadMsgNumber -= msgNumber;
    if (currentUnreadMsgNumber < 0) {
        currentUnreadMsgNumber = 0;
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%ld", (long)currentUnreadMsgNumber] forKey:kKeyOfUnreadMsgNumber];
    [[NSNotificationCenter defaultCenter] postNotificationName:kUnreadMsgNumberUpdatedNotification object:nil];
}

@end
