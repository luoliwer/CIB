//
//  MessageView.m
//  ChatDemo
//
//  Created by YangChao on 19/1/16.
//  Copyright © 2016年 swy. All rights reserved.
//

#import "MessageView.h"
#import "MessageCell.h"
#import "Message.h"
#import "Config.h"
#import "MessageFrame.h"
#import "MJRefresh.h"

#import "HPGrowingTextView.h"

#define textViewInitHeight 30
#define chatViewInitHeight 50
@interface MessageView ()<UITableViewDataSource, UITableViewDelegate,HPGrowingTextViewDelegate>
{
    //键盘显示隐藏标识
    BOOL _showFlag;
    BOOL _hideFlag;
    float keyboardHeight;
}

@property (nonatomic, strong) UITableView *msgTable;

@property (nonatomic, weak) UIButton *backButton;

@property (nonatomic, weak) UIButton *sendMsgButton;

@property (nonatomic, weak) UIButton *moreFuncButton;

@property (nonatomic, weak) UIView *contentView;

//@property (nonatomic, weak) UITextField *messageField;

@property (nonatomic, weak) HPGrowingTextView *messageTextView;

@property (nonatomic, weak) UIView *chatView;

//添加照片，模仿微信等功能
@property (nonatomic, strong) UIView *moreFunctionView;

@end

static CGFloat moreFunctionViewHeight = 80;

@implementation MessageView

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

- (UIView *)moreFunctionView
{
    if (_moreFunctionView == nil) {
        _moreFunctionView = [[UIView alloc] init];
        _moreFunctionView.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width, moreFunctionViewHeight);
        _moreFunctionView.backgroundColor = [UIColor colorWithRed:224/255.0 green:224/255.0 blue:224/255.0 alpha:1.0];
        
        //发送图片功能按钮
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(15, 15, moreFunctionViewHeight - 30, moreFunctionViewHeight - 30);
        button.layer.borderColor = [[UIColor whiteColor] CGColor];
        button.layer.borderWidth = 1;
        button.layer.cornerRadius = 4;
//        [button setImage:[UIImage imageNamed:@"btn_pop_back"] forState:UIControlStateNormal];
//        [button setImage:[UIImage imageNamed:@"btn_pop_back_p"] forState:UIControlStateHighlighted];
        [button setTitle:@"图片" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(choosePhoto) forControlEvents:UIControlEventTouchUpInside];
        [_moreFunctionView addSubview:button];
    }
    return _moreFunctionView;
}

- (void)setup
{
    UIView *contView = [[UIView alloc] init];
    contView.backgroundColor = [UIColor colorWithRed:236/255.0 green:240/255.0 blue:243/255.0 alpha:1.0];
    CGFloat contentH = [UIScreen mainScreen].bounds.size.height - 64;
    contView.frame = CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, contentH);
    [self addSubview:contView];
    
    self.contentView = contView;
    
    //自定义导航视图
    UIView *naviView = [[UIView alloc] init];
    naviView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 64);
    naviView.backgroundColor = [UIColor colorWithRed:18.0/255 green:119.0/255 blue:179.0/255 alpha:1.0];
    [self addSubview:naviView];
    
    UILabel *title = [[UILabel alloc] init];
    CGFloat titleW = 200;
    CGFloat titleH = 44;
    CGFloat titleX = ([UIScreen mainScreen].bounds.size.width - 200) / 2;
    CGFloat titleY = 20;
    title.frame = CGRectMake(titleX, titleY, titleW, titleH);
    title.font = [UIFont systemFontOfSize:18];
    title.textAlignment = NSTextAlignmentCenter;
    title.textColor = [UIColor whiteColor];
    [self addSubview:title];
    
    self.titleLb = title;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 20, 44, 44);
    [button setContentMode:UIViewContentModeCenter];
    [button setImage:[UIImage imageNamed:@"btn_pop_back"] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@"btn_pop_back_p"] forState:UIControlStateHighlighted];
    [button addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button];
    
    self.backButton = button;
    
    //懒加载uitableview
    _msgTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, contentH - chatViewInitHeight) style:UITableViewStylePlain];
    _msgTable.dataSource = self;
    _msgTable.delegate = self;
    _msgTable.backgroundColor = [UIColor colorWithRed:236/255.0 green:240/255.0 blue:243/255.0 alpha:1.0];
    _msgTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    [contView addSubview:_msgTable];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    tap.numberOfTapsRequired = 1;
    tap.numberOfTouchesRequired = 1;
    [self addGestureRecognizer:tap];
    
    UIView *chatView = [[UIView alloc] init];
    chatView.frame = CGRectMake(0, contentH - 50, [UIScreen mainScreen].bounds.size.width, chatViewInitHeight);
    chatView.backgroundColor = [UIColor colorWithRed:230/255.0 green:230/255.0 blue:230/255.0 alpha:1.0];
    [contView addSubview:chatView];
    
    HPGrowingTextView *textView = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(12, 10, chatView.frame.size.width - 80, textViewInitHeight)];
    textView.isScrollable = NO;
    textView.contentInset = UIEdgeInsetsMake(0, 2, 0, 2);
    
    textView.minNumberOfLines = 1;
    textView.maxNumberOfLines = 6;
    // you can also set the maximum height in points with maxHeight
    // textView.maxHeight = 200.0f;
    textView.returnKeyType = UIReturnKeyGo; //just as an example
    textView.font = [UIFont systemFontOfSize:15.0f];
    textView.delegate = self;
    textView.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(5, 0, 5, 0);
    textView.backgroundColor = [UIColor whiteColor];
    textView.placeholder = @"输入聊天内容";
    textView.layer.cornerRadius=15.0;
    self.messageTextView=textView;
    [chatView addSubview:textView];
    
    
    UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    addBtn.frame = CGRectMake(chatView.frame.size.width - 45, 10, 30, 30);
    addBtn.layer.borderColor = [[UIColor colorWithRed:200/255.0 green:200/255.0 blue:200/255.0 alpha:1.0] CGColor];
    addBtn.layer.borderWidth = 2;
    addBtn.layer.cornerRadius = 15;
    [addBtn setImage:[UIImage imageNamed:@"btn_add"] forState:UIControlStateNormal];
    addBtn.contentMode = UIViewContentModeCenter;
    [addBtn addTarget:self action:@selector(showPhotoes:) forControlEvents:UIControlEventTouchUpInside];
    [chatView addSubview:addBtn];
    
    self.moreFuncButton = addBtn;
    // 默认显示+号
    [self.moreFuncButton setHidden:NO];
    
    UIButton *sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    sendBtn.frame = CGRectMake(chatView.frame.size.width - 60, 10, 50, 30);
    sendBtn.hidden = YES;
    [sendBtn setTitle:@"发送" forState:UIControlStateNormal];
    [sendBtn setBackgroundColor:[UIColor colorWithRed:18.0/255 green:119.0/255 blue:179.0/255 alpha:1.0]];
    sendBtn.layer.cornerRadius = 4;
    sendBtn.titleLabel.font = [UIFont systemFontOfSize:18];
    [sendBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [sendBtn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    sendBtn.contentMode = UIViewContentModeCenter;
    [sendBtn addTarget:self action:@selector(sendMessage:) forControlEvents:UIControlEventTouchUpInside];
    [chatView addSubview:sendBtn];
    
    self.chatView = chatView;
    
    self.sendMsgButton = sendBtn;
    // 无需发送按钮，发送由键盘的按钮完成
    [self.sendMsgButton setHidden:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showKeyboard:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideKeyboard:) name:UIKeyboardWillHideNotification object:nil];
    
    [self addSubview:self.moreFunctionView];
    
    //添加刷新功能
    self.msgTable.header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        //去本地读取数据
        if (_refreshMore) {
            _refreshMore();
        }
        //结束刷新
        [self performSelector:@selector(endFresh) withObject:nil afterDelay:1.5];
    }];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (self.showGroupInfo) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake([UIScreen mainScreen].bounds.size.width - 44, 20, 44, 44);
        [button setContentMode:UIViewContentModeCenter];
        [button setImage:[UIImage imageNamed:@"btn_ndividualism white"] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:@"btn_ndividualism"] forState:UIControlStateHighlighted];
        [button addTarget:self action:@selector(more) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
    }
}

- (void)back
{
    if (_BackBlock) {
        _BackBlock();
    }
}

- (void)more
{
    if (_QueryGroupInfo) {
        _QueryGroupInfo();
    }
}

- (void)tap:(UITapGestureRecognizer *)tap
{
    [self keyboardDismiss];
}

- (void)sendMessage:(UIButton *)btn
{
    if (_SendMessage) {
        _SendMessage(self.messageTextView.internalTextView.text);
    }
    self.messageTextView.internalTextView.text=@"";
    
    [self setTablePosiWithanimate:YES];
    CGRect chatFrame = self.chatView.frame;
    chatFrame.size.height=chatViewInitHeight;
    self.chatView.frame=chatFrame;
    CGRect textViewFrame = self.messageTextView.frame;
    textViewFrame.size.height=textViewInitHeight;
    self.messageTextView.frame=textViewFrame;
    
    //发送消息后，返回最初状态
    self.sendMsgButton.hidden = YES;
    self.moreFuncButton.hidden = NO;
}

//点击加号，展示处可以使用的功能，当前支持照片。
- (void)showPhotoes:(UIButton *)sender
{
    [self keyboardDismiss];
    [self showOrHide:sender];
}

/**
 *  显示或者隐藏发送图片的功能界面
 *
 *  @param sender
 */
- (void)showOrHide:(UIButton *)sender
{
    if (sender.isSelected) {
        self.moreFunctionView.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width, moreFunctionViewHeight);
        self.contentView.frame = CGRectMake(0, self.contentView.frame.origin.y + moreFunctionViewHeight, self.contentView.frame.size.width, self.contentView.frame.size.height);
    } else {
        self.moreFunctionView.frame = CGRectMake(0, self.moreFunctionView.frame.origin.y - moreFunctionViewHeight, self.moreFunctionView.frame.size.width, self.moreFunctionView.frame.size.height);
        self.contentView.frame = CGRectMake(0, self.contentView.frame.origin.y - moreFunctionViewHeight, self.contentView.frame.size.width, self.contentView.frame.size.height);
    }
    sender.selected = !sender.isSelected;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _messagesDataSource.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *iD = @"MessageCell";
//    MessageCell *cell = [tableView dequeueReusableCellWithIdentifier:iD];
    
//    if (cell == nil) {
        MessageCell *cell = [[MessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:iD];
        cell.contentView.backgroundColor = [UIColor colorWithRed:236/255.0 green:240/255.0 blue:243/255.0 alpha:1.0];
//    }
    
    cell.msgFrame = _messagesDataSource[indexPath.row];
    cell.ViewPic = ^(int fileType, NSString *filePath) {//点击事件
        if (_ViewFile) {
            _ViewFile(fileType, filePath);
        }
    };
    cell.OpenAppInNewTab = ^(NSString *appNo) {
        if (_OpenAppInNewTab) {
            _OpenAppInNewTab(appNo);
        }
    };
    cell.OpenUrlInNewView = ^(NSString *url, NSString *appNo) {
        if (_OpenUrlInNewView) {
            _OpenUrlInNewView(url, appNo);
        }
    };
    cell.ViewOriginalImage = ^(UIImage *image) {
        if (_ViewOriginalImage) {
            _ViewOriginalImage(image);
        }
    };
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MessageFrame *msgFrame = _messagesDataSource[indexPath.row];
    return msgFrame.cellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 20;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    //
    MessageCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell click];
}


#pragma mark - scrollView Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    [self keyboardDismiss];
}

#pragma mark - table view scroll index row

- (void) tableViewScrolPositionBottom
{
    NSInteger sectionCount = [self.msgTable numberOfSections];
    if (sectionCount) {
        NSInteger rowConunt = [self.msgTable numberOfRowsInSection:0];
        if (rowConunt) {
            [self.msgTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:rowConunt - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom  animated:YES];
        }
    }
}

- (void) tableViewScrolPositionToIndex:(NSInteger)index
{
    [self.msgTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:index - 1 inSection:0] atScrollPosition:UITableViewScrollPositionMiddle  animated:NO];
}

#pragma mark --HPGrowingTextViewDelegate 输入框代理
- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height
{
    float diff = (height-growingTextView.frame.size.height);
    
    CGRect r = self.chatView.frame;
    r.size.height += diff;
    r.origin.y -= diff;
    self.chatView.frame = r;
    
    [UIView animateWithDuration:0.5 animations:^{
        CGRect tr = self.msgTable.frame;
        tr.origin.y -= diff;
        self.msgTable.frame = tr;
    }];
    
}
- (void)growingTextViewDidEndEditing:(HPGrowingTextView *)growingTextView{
    NSString* text = growingTextView.internalTextView.text;
    if ([text isEqualToString:@""]) {//发送按钮和更多功能按钮显示与隐藏
        self.sendMsgButton.hidden = YES;
        self.moreFuncButton.hidden = NO;
    }
}

- (BOOL)growingTextView:(HPGrowingTextView *)growingTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if (![text isEqualToString:@""]) {//发送按钮和更多功能按钮显示与隐藏
        self.sendMsgButton.hidden = NO;
        self.moreFuncButton.hidden = YES;
    }
    return YES;
}

-(void) setTablePosiWithanimate:(BOOL) ifAnimate{
    float height =0.0;
    float toBottom = [self getToBottmSize];
    height=keyboardHeight-toBottom;
    height=height<0?0:height;
    // 方法1：简单的将整个view向上移动，不变更view的高度及其内部子view的属性
    float changeHeight = self.chatView.frame.size.height-chatViewInitHeight;
    if(ifAnimate){
           [UIView animateWithDuration:0.5 animations:^{
               self.msgTable.frame = CGRectMake(0, - height-changeHeight, self.msgTable.frame.size.width, self.msgTable.frame.size.height);
           }];
    }else{
        self.msgTable.frame = CGRectMake(0,  - height-changeHeight, self.msgTable.frame.size.width, self.msgTable.frame.size.height);

    }
    
    CGRect chatFrame = self.chatView.frame;
    chatFrame.origin.y=self.contentView.frame.size.height-chatFrame.size.height - keyboardHeight;
//    chatFrame.size.height=chatViewInitHeight;
    self.chatView.frame=chatFrame;
}
#pragma mark -- 键盘显示隐藏通知
- (void)showKeyboard:(NSNotification *)t
{
    keyboardHeight = [[[t userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    
    if (!_showFlag) {
        [self setTablePosiWithanimate:NO];
        _showFlag = YES;
    }
}

- (void)hideKeyboard:(NSNotification *)t
{
    keyboardHeight=0.0;
    if (!_hideFlag) {
        
        // 方法1：简单的将整个view向下移动，不变更view的高度及其内部子view的属性
        float chatCurrHeight = self.chatView.frame.size.height;
        
        self.msgTable.frame = CGRectMake(0, -(chatCurrHeight-chatViewInitHeight), self.msgTable.frame.size.width, self.msgTable.frame.size.height);
        CGRect chatFrame = self.chatView.frame;
        chatFrame.origin.y=self.contentView.frame.size.height-self.chatView.frame.size.height;
        self.chatView.frame=chatFrame;
        
        _hideFlag = YES;
    }
}
//获取tableview 内容高度到屏幕底部的距离
-(float) getToBottmSize{
    float contentHeight_table=_msgTable.contentSize.height;
    float contentHeight_view = self.contentView.frame.size.height-self.chatView.frame.size.height;
    
    if(contentHeight_table<contentHeight_view){
        return contentHeight_view-contentHeight_table;
    }
    return 0;
}
//键盘隐藏，标识返回初始化值
- (void)keyboardDismiss
{
    if (self.moreFuncButton.isSelected) {
        [self showOrHide:self.moreFuncButton];
    }
    _hideFlag = NO;
    _showFlag = NO;
    [self.messageTextView resignFirstResponder];
}

- (void)setMessagesDataSource:(NSMutableArray *)messagesDataSource
{
    _messagesDataSource = messagesDataSource;
    
    [self.msgTable reloadData];
    [self setTablePosiWithanimate:YES];
    if (!_refresh) {
        [self tableViewScrolPositionBottom];
    } else {
        if (_refreshMsgNum != 0) {
            [self tableViewScrolPositionToIndex:_refreshMsgNum];
        }
    }
}

#pragma mark -- 发送图片（文件）

- (void)choosePhoto
{
    //隐藏键盘
    [self keyboardDismiss];
    //弹出actionview
    
    if (_ChooseActionSheet) {
        _ChooseActionSheet();
    }
}

#pragma mark -- 刷新数据

- (void)endFresh
{
    [self.msgTable.header endRefreshing];
}
-(void) dataReload{
    [self.msgTable reloadData];
}
@end
