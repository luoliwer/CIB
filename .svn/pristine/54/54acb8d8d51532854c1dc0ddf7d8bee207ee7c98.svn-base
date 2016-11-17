//
//  OrderChoseView.m
//  CommercialTenantClient
//
//  Created by YangChao on 28/7/15.
//  Copyright (c) 2015年 cdrcb. All rights reserved.
//

#import "ChatFunctionView.h"

@interface ChatFunctionView ()<UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate>
{
    chooseChatFunction _chatFun;
    NSArray *_sourceDatas;
}
@end

@implementation ChatFunctionView

- (instancetype)init{
    self = [super init];
    if (self) {
        self.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.0];
        [self initView];
    }
    return self;
}

- (void)initView
{
    _sourceDatas = @[@"发起聊天"];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    tap.numberOfTapsRequired = 1;
    tap.numberOfTouchesRequired = 1;
    tap.delegate = self;
    [self addGestureRecognizer:tap];
    
    UITableView *listTable = [[UITableView alloc] init];
    listTable.frame = CGRectMake([UIScreen mainScreen].bounds.size.width - 150, 64, 120, 44);
    listTable.dataSource = self;
    listTable.delegate = self;
    listTable.backgroundColor = [UIColor blackColor];
    listTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self addSubview:listTable];
    
    [self show];
}

#pragma mark -- UITaleView的数据源和代理
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _sourceDatas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *iD = @"FunctionCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:iD];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:iD];
        cell.contentView.backgroundColor = [UIColor blackColor];
        cell.textLabel.font = [UIFont systemFontOfSize:16];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
    }
    
    cell.textLabel.text = _sourceDatas[indexPath.row];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0;
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_chatFun) {
        _chatFun(indexPath);
    }
    [self removeFromSuperview];
}

- (void)show{
    UIView *windowView = [UIApplication sharedApplication].keyWindow;
    [windowView addSubview:self];
}

- (void)setFrame:(CGRect)frame
{
    frame.size.width = [UIScreen mainScreen].bounds.size.width;
    frame.size.height = [UIScreen mainScreen].bounds.size.height;
    frame.origin.x = 0;
    frame.origin.y = 0;
    [super setFrame:frame];
}

- (void)showViewHandleClickEventHandle:(chooseChatFunction)chatFun
{
    _chatFun = chatFun;
}

- (void)tap:(UITapGestureRecognizer *)tap
{
    [self removeFromSuperview];
}

#pragma mark -- 手势代理
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view.superview isKindOfClass:[UITableViewCell class]]) {
        return NO;
    }
    return YES;
}

@end
