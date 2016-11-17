//
//  OpenChatController.m
//  ChatDemo
//
//  Created by YangChao on 20/1/16.
//  Copyright © 2016年 swy. All rights reserved.
//

#import "OpenChatController.h"
#import "MessagesController.h"
#import "Message.h"
#import "ContactorCell.h"
#import "ChineseString.h"
#import "Chatter.h"
#import "Public.h"
#import "Config.h"
#import "HttpManager.h"
#import "ChatDBManager.h"
#import "DatabaseManageHelper.h"
#import "CoreDataManager.h"
#import "AppProduct.h"
#import "ImageAlertView.h"
#import "MyUtils.h"
#import "GTMBase64.h"
#import <CIBBaseSDK/CIBBaseSDK.h>
#import "AppDelegate.h"
#import "JSSendMessageManager.h"

@interface OpenChatController ()<UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>
{
    NSArray *_sourceDatas;
    NSMutableArray *_addingMembers;//将选中的数据加入到现有的群组
}

@property(nonatomic,strong)NSMutableArray *indexArray;
@property(nonatomic,strong)NSMutableArray *letterResultArr;

@property(nonatomic,strong)NSMutableArray *objSortedArr;

@property (weak, nonatomic) IBOutlet UIButton *confirmBtn;

@property (weak, nonatomic) IBOutlet UITableView *contactorsTable;

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (strong, nonatomic) NSMutableArray *chattingContactors;
@end

@implementation OpenChatController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //加载完成后，细节处理
    _confirmBtn.userInteractionEnabled = NO;
    _confirmBtn.layer.cornerRadius = 4;
    [_confirmBtn setBackgroundColor:[UIColor colorWithRed:30/255.0 green:167/255.0 blue:44/255.0 alpha:0.5]];
    
    _chattingContactors = [NSMutableArray array];
    //UItableview右侧的索引 背景色和字体颜色设置
    self.contactorsTable.sectionIndexColor = [UIColor grayColor];
    self.contactorsTable.sectionIndexBackgroundColor = [UIColor clearColor];
    self.contactorsTable.sectionIndexMinimumDisplayRowCount = 1;
    
    //剩余的空白行显示成背景色
    UIView *view = [[UIView alloc]init];
    view.backgroundColor = [UIColor clearColor];
    [self.contactorsTable setTableFooterView:view];
    
    [self getLocalContacts];
    // 下面供测试
    
    if (_isFromShare) {
        _titleLabel.text = @"分享";
    }
    
}

- (void)getLocalContacts {
    DatabaseManageHelper *helper = [DatabaseManageHelper sharedManagerHelper];
    
    
    // 打开通讯录的数据库
    
    if (![helper openDatabase:[NSString stringWithFormat:@"contact"]]) {
        
        // 获取“通讯录”的appno
        CoreDataManager *cdManager = [[CoreDataManager alloc] init];
        AppProduct *app = [cdManager getAppProductByAppName:@"contact"];
        NSString *appNo = [app.appNo stringValue];
        [helper openDatabase:[NSString stringWithFormat:@"%@.db",appNo]];
    }
    
    // 执行sql语句，查询本地收藏的联系人
    NSString *querySql = [NSString stringWithFormat:@"SELECT * FROM contact"];
    NSString *retJsonString = [helper query:querySql params:nil];
    
    // 解析查询结果的json语句
    NSError *error = nil;
    id result = [NSJSONSerialization JSONObjectWithData:[retJsonString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:&error];
    NSMutableArray *contactsList = [[NSMutableArray alloc] init];
    
    if (!error && result) {
        if ([result isKindOfClass:[NSArray class]]) {
            for (NSDictionary *contactInfo in result) {
                Chatter *chatter = [[Chatter alloc] init];
                chatter.chatterId = [contactInfo objectForKey:@"NOTESID"];
                chatter.chatterName = [contactInfo objectForKey:@"USERNAME"];
                chatter.iconPath = [[contactInfo objectForKey:@"PICSTRING"] stringByRemovingPercentEncoding];
                [contactsList addObject:chatter];
            }
            // 按首字母排序联系人列表
            [self sortContactsArray:contactsList];
        }
    }
    else {
//        [self testModelSort];
    }
}

- (void)testModelSort
{
    Chatter *chatter1 = [[Chatter alloc] init];
    chatter1.chatterId = @"001";
    chatter1.chatterName = @"阿三";
    
    Chatter *chatter2 = [[Chatter alloc] init];
    chatter2.chatterId = @"002";
    chatter2.chatterName = @"Bob";
    
    Chatter *chatter3 = [[Chatter alloc] init];
    chatter3.chatterId = @"003";
    chatter3.chatterName = @"chary";
    
    Chatter *chatter4 = [[Chatter alloc] init];
    chatter4.chatterId = @"004";
    chatter4.chatterName = @"杜兴武";
    
    Chatter *chatter5 = [[Chatter alloc] init];
    chatter5.chatterId = @"005";
    chatter5.chatterName = @"额吉";
    
    Chatter *chatter6 = [[Chatter alloc] init];
    chatter6.chatterId = @"006";
    chatter6.chatterName = @"富兴";
    
    Chatter *chatter7 = [[Chatter alloc] init];
    chatter7.chatterId = @"007";
    chatter7.chatterName = @"高志文";
    
    Chatter *chatter8 = [[Chatter alloc] init];
    chatter8.chatterId = @"008";
    chatter8.chatterName = @"胡戈";
    
    Chatter *chatter9 = [[Chatter alloc] init];
    chatter9.chatterId = @"009";
    chatter9.chatterName = @"将星";
    
    Chatter *chatter10 = [[Chatter alloc] init];
    chatter10.chatterId = @"010";
    chatter10.chatterName = @"库克";
    
    Chatter *chatter11 = [[Chatter alloc] init];
    chatter11.chatterId = @"011";
    chatter11.chatterName = @"满天星";
    
    NSArray *objArr = @[chatter1,chatter2,chatter3,chatter4,chatter5,chatter6,chatter7,chatter8,chatter9,chatter10,chatter11];
    
    [self sortContactsArray:objArr];
    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        [self saveContactorsToLocal:objArr];
//    });
//    
//    NSArray *stringArr = @[chatter1.chatterName,chatter2.chatterName,chatter3.chatterName,chatter4.chatterName,chatter5.chatterName,chatter6.chatterName,chatter7.chatterName,chatter8.chatterName,chatter9.chatterName,chatter10.chatterName];
//    
//    self.indexArray = [ChineseString IndexArray:stringArr];
//    NSMutableArray *chatterSortArr = [NSMutableArray array];
//    for (NSString *item in self.indexArray) {
//        NSMutableArray *sameFirstCharacterArr = [NSMutableArray array];
//        for (Chatter *chat in objArr) {
//            NSString *firstCharacter = [[ChineseString IndexArray:@[chat.chatterName]] firstObject];//获取昵称/名字首字母
//            if ([firstCharacter isEqualToString:item]) {
//                [sameFirstCharacterArr addObject:chat];
//            }
//        }
//        [chatterSortArr addObject:sameFirstCharacterArr];
//    }
//    self.objSortedArr = chatterSortArr;
//    self.letterResultArr = [ChineseString LetterSortArray:stringArr];
}

- (void)sortContactsArray:(NSArray *)contactsArray
{
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        [self saveContactorsToLocal:contactsArray];
//    });
    
    NSMutableArray *nameArray = [[NSMutableArray alloc] init];
    for (Chatter *chatter in contactsArray) {
        [nameArray addObject:chatter.chatterName];
    }
    
    self.indexArray = [ChineseString IndexArray:nameArray];
    NSMutableArray *chatterSortArr = [NSMutableArray array];
    for (NSString *item in self.indexArray) {
        NSMutableArray *sameFirstCharacterArr = [NSMutableArray array];
        for (Chatter *chat in contactsArray) {
            NSString *firstCharacter = [[ChineseString IndexArray:@[chat.chatterName]] firstObject];//获取昵称/名字首字母
            if ([firstCharacter isEqualToString:item]) {
                [sameFirstCharacterArr addObject:chat];
            }
        }
        [chatterSortArr addObject:sameFirstCharacterArr];
    }
    self.objSortedArr = chatterSortArr;
    self.letterResultArr = [ChineseString LetterSortArray:nameArray];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)saveContactorsToLocal:(NSArray *)contactors
{
    for (Chatter *chat in contactors) {
        [[ChatDBManager sharedDatabaseManager] addContactor:chat];
    }
}

#pragma mark -- UITaleView的数据源和代理
-(NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return self.indexArray;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [self.indexArray objectAtIndex:section];
    
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.indexArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.objSortedArr objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    if (indexPath.section == 0) {
//        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NormalCell"];
//        if (cell == nil) {
//            cell= [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"NormalCell"];
//            cell.selectionStyle = UITableViewCellSelectionStyleNone;
//        }
//        cell.textLabel.text = [[self.letterResultArr objectAtIndex:indexPath.section]objectAtIndex:indexPath.row];
//        return cell;
//    } else {
        static NSString *iD = @"OpenChatCell";
        ContactorCell *cell = [tableView dequeueReusableCellWithIdentifier:iD];
        
        if (cell == nil) {
            cell = [[NSBundle mainBundle] loadNibNamed:@"ContactorCell" owner:nil options:nil][0];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
    
        Chatter *chatter = [[self.objSortedArr objectAtIndex:indexPath.section]objectAtIndex:indexPath.row];
    
        if ([self hasAddedIntoGroup:chatter.chatterId]) {
            cell.checkBtn.selected = YES;
        } else {
            cell.checkBtn.selected = NO;
        }
        
        cell.name.text = chatter.chatterName;
    
        NSString *picString = chatter.iconPath;
        
        if (picString && ![picString isEqual:[NSNull null]] && ![picString isEqualToString:@"null"] ) {
            
            
        
            NSData *picData = [GTMBase64 decodeString:picString];
            UIImage *image = [UIImage imageWithData:picData];
            if (image) {
                cell.headIcon.image = image;
            }
        }
    
        return cell;
//    }
}

/**
 *  判断该联系人是否已经加入该群组
 *
 *  @param chatterId 联系人id
 *
 *  @return 返回是否加入了该群组
 */
- (BOOL)hasAddedIntoGroup:(NSString *)chatterId
{
    BOOL hasAdded = NO;
    for (NSDictionary *item in _groupHadMembers) {
        NSString *temp = [item valueForKey:@"userid"];
        if ([temp isEqualToString:chatterId]) {
            hasAdded = YES;
            break;
        }
    }
    return hasAdded;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
//    if (section == 0) {
//        return 0;
//    }
    return 20;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width - 0, 20)];
    view.backgroundColor = [UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1.0];
    UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(12, 0, tableView.bounds.size.width - 12, 20)];
    lab.backgroundColor = [UIColor clearColor];
    lab.font = [UIFont systemFontOfSize:16];
    lab.text = [self.indexArray objectAtIndex:section];
    lab.textColor = [UIColor grayColor];
    [view addSubview:lab];
    return view;
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
//    if (indexPath.section == 0) {
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"多人聊天功能正在开发中,请等待..." delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//        [alertView show];
//    } else {
        ContactorCell *cell = (ContactorCell *)[self.contactorsTable cellForRowAtIndexPath:indexPath];
        
        id obj = [[self.objSortedArr objectAtIndex:indexPath.section]objectAtIndex:indexPath.row];
        //通过名字查找对应的对象
        if (!cell.checkBtn.isSelected) {
            [_chattingContactors addObject:obj];
            
        } else {
            [_chattingContactors removeObject:obj];
        }
        cell.checkBtn.selected = !cell.checkBtn.isSelected;
    
        if (_chattingContactors.count < 1) {
            [_confirmBtn setBackgroundColor:[UIColor colorWithRed:30/255.0 green:167/255.0 blue:44/255.0 alpha:0.6]];
            _confirmBtn.userInteractionEnabled = NO;
        } else {
            [_confirmBtn setBackgroundColor:[UIColor colorWithRed:30/255.0 green:167/255.0 blue:44/255.0 alpha:1.0]];
            _confirmBtn.userInteractionEnabled = YES;
        }
//    }
}

#pragma mark -- 顶部导航事件
- (IBAction)confirm:(UIButton *)sender {
    
    if (!_isFromShare) {
        if (_groupId) {//现有群组添加成员
            
            NSMutableString *ids = [NSMutableString stringWithString:@"['"];
            for (Chatter *chat in _chattingContactors) {
                [ids appendString:chat.chatterId];
                [ids appendString:@"','"];
            }
            NSString *temp = [ids substringToIndex:ids.length - 2];
            
            [self addMembers:[NSString stringWithFormat:@"%@]", temp] groupId:_groupId groupName:@""];
        } else {
            
            if (_chattingContactors.count == 1) {
                //单聊对象
                Chatter *chat = [_chattingContactors firstObject];
                // 将单聊的联系人存入数据库
                if (!chat.iconPath || [chat.iconPath isEqual:[NSNull null]] || [chat.iconPath isEqualToString:@""] || [chat.iconPath isEqualToString:@"null"]) { //当前联系人无头像
                    
                    /*
                    id paramDic = @{@"notesid":chat.chatterId};
                    
                    [CIBRequestOperationManager invokeAPI:@"contactsguiv2" byMethod:@"POST" withParameters:paramDic onRequestSucceeded:^(NSString *responseCode, NSString *responseInfo) {
                        
                        if ([responseCode isEqualToString:@"I00"]) {
                            NSString *resultCode = [responseInfo valueForKey:@"resultCode"];
                            if ([resultCode isEqualToString:@"0"]) {
                                NSArray *resultDic = [responseInfo valueForKey:@"result"];
                                NSString *picString = [[resultDic firstObject] valueForKey:@"PICSTRING"];
                                chat.iconPath = picString;
                            }
                        }
                        [[ChatDBManager sharedDatabaseManager] addContactor:chat];
                        
                    } onRequestFailed:^(NSString *responseCode, NSString *responseInfo) {
                        NSLog(@"%@", responseInfo);
                        [[ChatDBManager sharedDatabaseManager] addContactor:chat];
                    }];
                     */
                    [self updateContact:chat];
                    
                }
                else {
                    if ([[ChatDBManager sharedDatabaseManager] queryContactor:chat.chatterId]) {
                        [[ChatDBManager sharedDatabaseManager] updateContactor:chat.chatterId name:chat.chatterName iconPath:chat.iconPath];
                    }
                    else {
                        [[ChatDBManager sharedDatabaseManager] addContactor:chat];
                    }
                }
                //设置消息
                Message *msg = [[Message alloc] init];
                msg.msgFromerId = chat.chatterId;
                msg.msgFromerName = chat.chatterName;
                NSString *toID = [AppInfoManager getUserName];
                NSString *toName = [AppInfoManager getValueForKey:kKeyOfUserRealName];
                msg.msgToId = toID;
                msg.msgToName = toName;
                
                MessagesController *msgController = [[MessagesController alloc] init];
                msgController.msg = msg;
                msgController.backToViewControllerName = @"NewsListController";
                [self.navigationController pushViewController:msgController animated:YES];
            } else {
                //创建群
                //            NSString *groupId = [Public stringFromDate:[NSDate date] formatt:@"yyyyMMddHHmmss"];
                NSString *groupId = [Public createUUID];
                
                NSLog(@"新建群号：%@", groupId);
                
                //创建群接口
                [self createGroup:groupId];
            }
        }
    }
    else { // 来自分享
        if (_chattingContactors.count != 1) {
            NSLog(@"分享目前暂时只能选择一位联系人");
            if (currentOSVersion >= 9.0) {
                UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"分享暂时只支持单人分享" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                   
                }];
                
                [alertVc addAction:cancel];
                [self presentViewController:alertVc animated:YES completion:nil];
            }
            else {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"分享暂时只支持单人分享" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alertView show];
            }
        }
        else {
            
            Chatter *receiver = [_chattingContactors firstObject];
            
            [self updateContact:receiver];
            
            NSString *receiverNotesId = receiver.chatterId; // 当前收件人的id
            NSString *messageUuid = [Public createUUID];
            NSString *message = [NSString stringWithFormat:@"[\"%@\", \"%@\", %@, \"%@\", \"false\"]", _shareType, receiverNotesId, _shareContent, messageUuid];
            JFRWebSocket *socket = [AppDelegate delegate].socket;
            JSSendMessageManager *manager = [JSSendMessageManager sharedManager];
            // 请求当连接断开先隐藏 在弹出连接断开提示框
            __block BOOL isConntect = NO;
            void(^disBlock)() = ^() {
                isConntect=YES;
                [self back:nil];
            };
            [manager sendMessage:message socket:socket disConnectBlock:disBlock];
            if(!isConntect){
                [self back:nil];
            }
            
        }
    }
    
}

//创建群接口
- (void)createGroup:(NSString *)groupId
{
    
    NSString *parameter = [NSString stringWithFormat:@"%@parameter=['addGroup','%@']", kServerURL, groupId];
    NSLog(@"创建群参数：%@", parameter);
    [[HttpManager sharedHttpManager] createGroupUrl:[parameter stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] parameters:nil success:^(NSDictionary *dic) {
        if (dic) {
            
            BOOL created = [[dic valueForKey:@"flag"] boolValue];
            
            if (created) {
                
                NSMutableString *groupName = [NSMutableString string];
                NSMutableString *ids = [NSMutableString stringWithString:@"['"];
                for (Chatter *chat in _chattingContactors) {
                    [ids appendString:chat.chatterId];
                    [ids appendString:@"','"];
                    [groupName appendString:chat.chatterName];
                    [groupName appendString:@"、"];
                }
                NSString *userID = [AppInfoManager getUserName];
                [ids appendFormat:@"%@']", userID];
                [self addMembers:ids groupId:groupId groupName:[groupName substringToIndex:groupName.length - 1]];
            }
        }
    } fail:^(NSError *error) {
        
        NSLog(@"返回消息：%@", error);
    }];
}

//添加群成员
- (void)addMembers:(id)members groupId:(NSString *)groupId groupName:(NSString *)groupName
{
    NSString *parameter = [NSString stringWithFormat:@"%@parameter=['addGroupMembers','%@', %@]",kServerURL, groupId, members];
    NSLog(@"添加群成员参数：%@", parameter);
    [[HttpManager sharedHttpManager] addMemberToGroupUrl:[parameter stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] parameters:nil success:^(NSDictionary *dic) {
        
        if (dic) {
            if ([[dic valueForKey:@"flag"] boolValue]) {
                if (_groupId) {//添加成员到现有群 成功后
                    [self.navigationController popViewControllerAnimated:YES];
                } else {
                    //添加成员成功
                    Message *msg = [[Message alloc] init];
                    msg.groupId = groupId;
                    msg.msgFromerId = groupId;
                    msg.msgFromerName = [NSString stringWithFormat:@"%@", groupName];
                    msg.msgContent = [NSString stringWithFormat:@"你邀请了%@对话", groupName];
                    NSString *toID = [AppInfoManager getUserName];
                    NSString *toName = [AppInfoManager getValueForKey:kKeyOfUserRealName];
                    msg.msgToId = toID;
                    msg.msgToName = toName;
                    msg.msgTime = [Public stringFromDate:[NSDate date] formatt:@"yyyy-MM-dd HH:mm:ss"];
                    msg.chatType = 1;//群聊
                    
                    //将该消息保存到本地最新消息表中
                    [[ChatDBManager sharedDatabaseManager] addNewestMessage:msg];
                    
                    //跳入到聊天界面，发起聊天
                    MessagesController *controller = [[MessagesController alloc] init];
                    controller.chatType = ChatTypeGroup;
                    controller.backToViewControllerName = @"NewsListController";
                    controller.msg = msg;
                    [self.navigationController pushViewController:controller animated:YES];
                }
            }
        }
        
    } fail:^(NSError *error) {
        
        NSLog(@"返回消息：%@", error);
    }];
}

- (IBAction)back:(UIButton *)sender
{
    if (!_isFromShare) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark -- 搜索框事件

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
//    NSString *chatters = searchBar.text;
//    NSArray *chatterArray = [chatters componentsSeparatedByString:@" "];
//    for (NSString *chatterId in chatterArray) {
//        Chatter *chatter = [[Chatter alloc] init];
//        chatter.chatterId = chatterId;
//        chatter.chatterName = chatterId;
//        [_chattingContactors addObject:chatter];
//    }
//    [self confirm:nil];
    [searchBar endEditing:YES];
    NSString *keyString = searchBar.text;
    if (keyString) {
        [self searchContacts:keyString];
    }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(nonnull NSString *)searchText {
    if (!searchText || [searchText isEqualToString:@""]) {
        [self getLocalContacts];
        [self.contactorsTable reloadData];
    }
}

- (void)searchContacts:(NSString *)keyString {
    
    ImageAlertView *alertView = [[ImageAlertView alloc] initWithFrame:self.view.frame];
    alertView.isHasBtn = NO;
    [alertView viewShowWithImage:[UIImage imageNamed:@"ic_refresh"] message:@"搜索中..."];
    [self.view addSubview:alertView];
    
    NSMutableArray *contactsList = [[NSMutableArray alloc] init];
    
    NSMutableDictionary *paramDic = [[NSMutableDictionary alloc] init];
    [paramDic setObject:[keyString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] forKey:@"key"];
    [paramDic setObject:@"1" forKey:@"pageno"];
    [paramDic setObject:@"20" forKey:@"pagesize"];
    
    [CIBRequestOperationManager invokeAPI:@"contactsusv2" byMethod:@"POST" withParameters:paramDic onRequestSucceeded:^(NSString *responseCode, NSString *responseInfo) {
        [alertView removeFromSuperview];
        
        if ([responseCode isEqualToString:@"I00"]) {
            if ([responseInfo isKindOfClass:[NSDictionary class]]) {
                NSString *resultCode = [responseInfo valueForKey:@"resultCode"];
                if ([resultCode isEqualToString:@"0"]) {
                    id result = [responseInfo valueForKey:@"result"];
                    if ([result isKindOfClass:[NSArray class]]) {
                        for (NSDictionary *contactInfo in result) {
                            Chatter *chatter = [[Chatter alloc] init];
                            chatter.chatterId = [contactInfo objectForKey:@"USERID"];
                            chatter.chatterName = [contactInfo objectForKey:@"USERNAME"];
//                            chatter.iconPath = [contactInfo objectForKey:@"PICSTRING"];
                            [contactsList addObject:chatter];
                        }
                        [self sortContactsArray:contactsList];
                        [self.contactorsTable reloadData];
                    }
                }
            }
        }
        else {
            [MyUtils showAlertWithTitle:responseInfo message:nil];
        }
    } onRequestFailed:^(NSString *responseCode, NSString *responseInfo) {
        [alertView removeFromSuperview];
        [MyUtils showAlertWithTitle:responseInfo message:nil];
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

- (void)updateContact:(Chatter *)chatter {
    if (!chatter) {
        return;
    }
    
    NSString *notesId = chatter.chatterId;
    
    // 首先查询本地数据库里是否已经存在此联系人
    Chatter *oldChatter = [[ChatDBManager sharedDatabaseManager] queryContactor:notesId];
    BOOL isChatterAlreadyInTable = (oldChatter != nil);
    
    if (isChatterAlreadyInTable) { // 联系人存在
        
        // 向服务端查询此联系人的最新信息
        id noteIdDic = @{@"notesid":notesId};
        [CIBRequestOperationManager invokeAPI:@"contactsguiv2" byMethod:@"POST" withParameters:noteIdDic onRequestSucceeded:^(NSString *responseCode, NSString *responseInfo) {
            
            if ([responseCode isEqualToString:@"I00"]) {
                NSString *resultCode = [responseInfo valueForKey:@"resultCode"];
                if ([resultCode isEqualToString:@"0"]) {
                    NSArray *resultArray = [responseInfo valueForKey:@"result"];
                    if ([resultArray count] > 0) {
                        NSDictionary *result = [resultArray firstObject];
                        NSString *userName = [result objectForKey:@"USERNAME"] ? : notesId;
                        NSString *picString = [result objectForKey:@"PICSTRING"];
                        [[ChatDBManager sharedDatabaseManager] updateContactor:notesId name:userName iconPath:picString];
                        return;
                    }
                }
            }
            [[ChatDBManager sharedDatabaseManager] updateContactor:notesId name:chatter.chatterName iconPath:chatter.iconPath];
            
        } onRequestFailed:^(NSString *responseCode, NSString *responseInfo) {
            [[ChatDBManager sharedDatabaseManager] updateContactor:notesId name:chatter.chatterName iconPath:chatter.iconPath];
        }];
    }
    else { // 联系人不存在
        
        // 向服务端查询此联系人的信息
        id noteIdDic = @{@"notesid":notesId};
        [CIBRequestOperationManager invokeAPI:@"contactsguiv2" byMethod:@"POST" withParameters:noteIdDic onRequestSucceeded:^(NSString *responseCode, NSString *responseInfo) {
            
            if ([responseCode isEqualToString:@"I00"]) {
                NSString *resultCode = [responseInfo valueForKey:@"resultCode"];
                if ([resultCode isEqualToString:@"0"]) {
                    NSArray *resultArray = [responseInfo valueForKey:@"result"];
                    if ([resultArray count] > 0) {
                        NSDictionary *result = [resultArray firstObject];
                        NSString *userName = [result objectForKey:@"USERNAME"] ? : notesId;
                        NSString *picString = [result objectForKey:@"PICSTRING"];
                        chatter.chatterName = userName;
                        chatter.iconPath = picString;
                        [[ChatDBManager sharedDatabaseManager] addContactor:chatter];
                        return;
                    }
                }
            }
            [[ChatDBManager sharedDatabaseManager] addContactor:chatter];
            
        } onRequestFailed:^(NSString *responseCode, NSString *responseInfo) {
            [[ChatDBManager sharedDatabaseManager] addContactor:chatter];
        }];
        
    }
    
}

@end
