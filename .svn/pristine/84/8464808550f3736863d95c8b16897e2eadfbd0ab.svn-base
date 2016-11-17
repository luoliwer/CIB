//
//  GroupInfoView.m
//  CIBSafeBrowser
//
//  Created by YangChao on 29/1/16.
//  Copyright © 2016年 cib. All rights reserved.
//

#import "GroupInfoView.h"
#import "GroupIconCell.h"
#import "Public.h"
#import "ChatDBManager.h"
#import "HttpManager.h"
#import "Chatter.h"
#import "Config.h"
#import <CIBBaseSDK/CIBBaseSDK.h>

static CGFloat cellW = 70;
static CGFloat cellH = 90;

@interface GroupInfoView ()<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>
{
    BOOL _deleteFlag;
    int _numOfRows;
}

@property (nonatomic, weak) UIButton *backButton;

//整个群信息布局在scrollview上
@property (nonatomic, weak) UIScrollView *contentScrollView;

@property (nonatomic, weak) UICollectionView *collectionView;

@property (nonatomic, weak) UIButton *quitOutOfGroupBtn;

@end

@implementation GroupInfoView

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
    BOOL isIpad = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad;
    _numOfRows = 4;//iPhone
    if (isIpad) {//iPad
        _numOfRows = 8;
        if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft || [[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeRight) {//横屏
            _numOfRows = 12;
        }
    }
    self.backgroundColor = [UIColor whiteColor];
    //自定义导航视图
    UIView *naviView = [[UIView alloc] init];
    naviView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 64);
    naviView.backgroundColor = [UIColor colorWithRed:18.0/255 green:119.0/255 blue:179.0/255 alpha:1.0];
    [self addSubview:naviView];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 20, 44, 44);
    [button setContentMode:UIViewContentModeCenter];
    [button setImage:[UIImage imageNamed:@"btn_pop_back"] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@"btn_pop_back_p"] forState:UIControlStateHighlighted];
    [button addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button];
    
    self.backButton = button;
    
    UILabel *title = [[UILabel alloc] init];
    CGFloat titleW = 200;
    CGFloat titleH = 44;
    CGFloat titleX = CGRectGetMaxX(button.frame);
    CGFloat titleY = 20;
    title.frame = CGRectMake(titleX, titleY, titleW, titleH);
    title.font = [UIFont systemFontOfSize:18];
    title.textAlignment = NSTextAlignmentLeft;
    title.textColor = [UIColor whiteColor];
    title.text = @"聊天群信息";
    [self addSubview:title];
    
    //内容部分
    UIScrollView *scroll = [[UIScrollView alloc] init];
    scroll.backgroundColor = [UIColor clearColor];
    [self addSubview:scroll];
    
    self.contentScrollView = scroll;
    
    //uicollectionview
    //确定是水平滚动，还是垂直滚动
    UICollectionViewFlowLayout *flowLayout=[[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    
    UICollectionView *collView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, 320, 90) collectionViewLayout:flowLayout];
    collView.backgroundColor = [UIColor whiteColor];
    collView.dataSource = self;
    collView.delegate = self;
    [self.contentScrollView addSubview:collView];
    
    self.collectionView = collView;
    [self.collectionView registerClass:[GroupIconCell class] forCellWithReuseIdentifier:@"GroupIconCell"];
    
    UIButton *quitButton = [UIButton buttonWithType:UIButtonTypeCustom];
    quitButton.layer.cornerRadius = 6;
    quitButton.clipsToBounds = YES;
    quitButton.contentMode = UIViewContentModeScaleToFill;
    UIImage *normalImage = [Public imageFromColor:[UIColor redColor] size:CGSizeMake(120, 44)];
    UIImage *highImage = [Public imageFromColor:[UIColor blueColor] size:CGSizeMake(120, 44)];
    [quitButton setBackgroundImage:normalImage forState:UIControlStateNormal];
    [quitButton setBackgroundImage:highImage forState:UIControlStateHighlighted];
    [quitButton setTitle:@"退出并删除该群" forState:UIControlStateNormal];
    [quitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [quitButton addTarget:self action:@selector(quitOutOfGroup:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentScrollView addSubview:quitButton];
    
    self.quitOutOfGroupBtn = quitButton;
}

- (void)setMembers:(NSMutableArray *)members
{
    _members = members;
    
    [self.collectionView reloadData];
    [self layout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self layout];
}

- (void)layout{
    
    //设置scrollview的frame
    self.contentScrollView.frame = CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 64);
    
    //设置collectionview的frame
    NSInteger rows = (_members.count + 2) % _numOfRows == 0 ? (_members.count + 2) / _numOfRows : (_members.count + 2) / _numOfRows + 1;
    self.collectionView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, (cellH + 10) * rows + 10);
    
    if (CGRectGetMaxY(self.collectionView.frame) + 74 < [UIScreen mainScreen].bounds.size.height) {
        
        self.quitOutOfGroupBtn.frame = CGRectMake(30, self.contentScrollView.bounds.size.height - 74, [UIScreen mainScreen].bounds.size.width - 60, 44);
    } else {
        
        self.quitOutOfGroupBtn.frame = CGRectMake(30, CGRectGetMaxY(self.collectionView.frame) + 30, [UIScreen mainScreen].bounds.size.width - 60, 44);
        self.contentScrollView.contentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, CGRectGetMaxY(self.quitOutOfGroupBtn.frame) + 20);
    }
    
    
}

//每个section的item个数
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _members.count + 2;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    GroupIconCell *cell = (GroupIconCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"GroupIconCell" forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"GroupIconCell" owner:nil options:nil] firstObject];
    }
    
    if (_deleteFlag && indexPath.row < _members.count) {
        cell.delBtn.hidden = NO;
    } else {
        cell.delBtn.hidden = YES;
    }
    //图片名称
    //加载图片
    if (indexPath.row == _members.count + 1) {
        cell.icon.image = [UIImage imageNamed:@"DelGroupMember"];
        //设置label文字
        cell.nickName.text = @"";
    } else if (indexPath.row == _members.count) {
        cell.icon.image = [UIImage imageNamed:@"btn_add"];
        //设置label文字
        cell.nickName.text = @"";
    } else {
        NSDictionary *dic = _members[indexPath.row];
        NSString *userId = [dic valueForKey:@"userid"];
//        NSString *userName = [dic valueForKey:@"username"];
        //查询本地，是否存储了当前用户的信息，如果没有 调用下列接口 如果存在 则取本地数据库数据
        Chatter *chat = [[ChatDBManager sharedDatabaseManager] queryContactor:userId];
        
        if (chat) {
            //存在用户信息
//            chat.chatterName = userName;
            cell.chatter = chat;
        } else {
            //本地无记录数据
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                //调用接口，获取用户头像和姓名
                [self achieveUserNameAndIcon:userId cell:cell];
            });
        }
        
    }
    
    //踢人事件
    cell.DeleteGroupMember = ^(Chatter *chatter) {
        NSLog(@"删除%ld中...", indexPath.row);
        if (_DelGroupMember) {
            _DelGroupMember(chatter);
        }
    };
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == _members.count) {
        if (_AddNewMembers) {
            _AddNewMembers();
        }
    } else if (indexPath.row == _members.count + 1) {
        //刷新试图
        _deleteFlag = !_deleteFlag;//删除或者取消删除标识
        [self.collectionView reloadData];
    }
}

#pragma mark --UICollectionViewDelegateFlowLayout
//定义每个UICollectionView 的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(cellW, cellH);
}
//定义每个UICollectionView 的 margin
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    CGFloat wholeW = [UIScreen mainScreen].bounds.size.width;
    CGFloat spcing = (wholeW - cellW * _numOfRows) / 8;
    return UIEdgeInsetsMake(10, spcing, 10, spcing);
}

- (void)back
{
    if (_BackBlock) {
        _BackBlock();
    }
}

- (void)quitOutOfGroup:(UIButton *)btn
{
    if (_QuitOutOfGroup) {
        _QuitOutOfGroup();
    }
}

#pragma mark -- 获取用户姓名和头像

- (void)achieveUserNameAndIcon:(NSString *)ID cell:(GroupIconCell *)cell
{
    /*
    
    //通过id获取用户信息
    id noteIdDic = @{@"notesId":ID};
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
            
            NSString *userName = [[[dic objectForKey:@"result"] firstObject] valueForKey:@"USERNAME"] ? : ID;
            NSString *iconPath = [[[dic objectForKey:@"result"] firstObject] valueForKey:@"PICSTRING"];
            
            Chatter *chat = [[Chatter alloc] init];
            chat.chatterId = ID;
            chat.chatterName = userName;
            chat.iconPath = iconPath;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                cell.chatter = chat;
            });
        }
    } fail:^(NSError *error) {
        NSLog(@"网络异常：%@", error);
        Chatter *chat = [[Chatter alloc] init];
        chat.chatterId = ID;
        chat.chatterName = @"";
        chat.iconPath = @"";
        
        dispatch_async(dispatch_get_main_queue(), ^{
            cell.chatter = chat;
        });
    }];
     */
    
    id noteIdDic = @{@"notesid":ID};
    [CIBRequestOperationManager invokeAPI:@"contactsguiv2" byMethod:@"POST" withParameters:noteIdDic onRequestSucceeded:^(NSString *responseCode, NSString *responseInfo) {
        
        if ([responseCode isEqualToString:@"I00"]) {
            NSString *resultCode = [responseInfo valueForKey:@"resultCode"];
            if ([resultCode isEqualToString:@"0"]) {
                NSArray *resultDic = [responseInfo valueForKey:@"result"];
                NSString *userName = [[resultDic firstObject] valueForKey:@"USERNAME"] ? : ID;
                NSLog(@"用户姓名：%@", userName);
                NSString *iconPath = [[resultDic firstObject] valueForKey:@"PICSTRING"];
                
                Chatter *chat = [[Chatter alloc] init];
                chat.chatterId = ID;
                chat.chatterName = userName;
                chat.iconPath = iconPath;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    cell.chatter = chat;
                });
            }
        }
        
    } onRequestFailed:^(NSString *responseCode, NSString *responseInfo) {
        NSLog(@"%@", responseInfo);
        Chatter *chat = [[Chatter alloc] init];
        chat.chatterId = ID;
        chat.chatterName = @"";
        chat.iconPath = @"";
        
        dispatch_async(dispatch_get_main_queue(), ^{
            cell.chatter = chat;
        });

    }];
}

@end
